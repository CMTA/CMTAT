const { expect } = require('chai')
const { RULE_MOCK_AMOUNT_MAX, ZERO_ADDRESS } = require('../../utils')

function ValidationModuleCommonCore () {
  // Transferring with Rule Engine set
  context('ValidationCore test', function () {
    beforeEach(async function () {
    
    })
   
    it('testCanCanTransferWithoutRuleEngine', async function () {
      // Act + Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(true)
    })

    it('testCanDetectTransferRestrictionValidTransfer', async function () {
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 11)
      ).to.equal(true)
    })


    // this.address1 may transfer tokens to this.address2
    it('testCanTransferAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = 11n

      expect(
        await this.ruleEngineMock.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)
      // Act
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)
      // Act
      await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, AMOUNT_TO_TRANSFER)
      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        this.ADDRESS1_INITIAL_BALANCE - AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        this.ADDRESS2_INITIAL_BALANCE + AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        this.ADDRESS3_INITIAL_BALANCE
      )
    })

    // reverts if this.address1 transfers more tokens than rule allows
    it('testCannotTransferIfNotAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = RULE_MOCK_AMOUNT_MAX + 1
      expect(
        await this.ruleEngineMock.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)
      // Act
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .transfer(this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          this.address1.address,
          this.address2.address,
          AMOUNT_TO_TRANSFER
        )
    })
  })
}
module.exports = ValidationModuleCommonCore
