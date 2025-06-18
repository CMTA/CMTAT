const { expect } = require('chai')
const { RULE_MOCK_AMOUNT_MAX, ZERO_ADDRESS } = require('../../utils')

function ValidationModuleCommonCore () {
  // Transferring with Rule Engine set
  context('ValidationCore test', function () {
    beforeEach(async function () {
      if (this.erc1404) {
        this.ADDRESS1_INITIAL_BALANCE = 31n
        this.ADDRESS2_INITIAL_BALANCE = 32n
        this.ADDRESS3_INITIAL_BALANCE = 33n
        await this.cmtat
          .connect(this.admin)
          .mint(this.address1, this.ADDRESS1_INITIAL_BALANCE)
        await this.cmtat
          .connect(this.admin)
          .mint(this.address2, this.ADDRESS2_INITIAL_BALANCE)
        await this.cmtat
          .connect(this.admin)
          .mint(this.address3, this.ADDRESS3_INITIAL_BALANCE)
      }
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
    it('testCanTransfer', async function () {
      AMOUNT_TO_TRANSFER = 5
      // Act
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)
      await this.cmtat
        .connect(this.address1)
        .transfer(this.address2, AMOUNT_TO_TRANSFER)
    })
  })
}
module.exports = ValidationModuleCommonCore
