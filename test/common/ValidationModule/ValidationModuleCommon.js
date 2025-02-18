const { expect } = require('chai')
const { RULE_MOCK_AMOUNT_MAX, ZERO_ADDRESS } = require('../../utils')

function ValidationModuleCommon () {
  // Transferring with Rule Engine set
  context('RuleEngineTransferTest', function () {
    beforeEach(async function () {
      if ((await this.cmtat.ruleEngine()) === ZERO_ADDRESS) {
        this.ruleEngineMock = await ethers.deployContract('RuleEngineMock')
        await this.cmtat
          .connect(this.admin)
          .setRuleEngine(this.ruleEngineMock.target)
      }
    })
    it('testCanReturnTheRightAddressIfSet', async function () {
      if (this.definedAtDeployment) {
        expect(this.ruleEngineMock.target).to.equal(
          await this.cmtat.ruleEngine()
        )
      }
    })
    it('testCancanTransferWithoutRuleEngine', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).setRuleEngine(ZERO_ADDRESS)
      // Act + Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(true)
    })

    it('testCanDetectTransferRestrictionValidTransfer', async function () {
      // Act + Assert
      expect(
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.address2,
          11
        )
      ).to.equal(0)
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 11)
      ).to.equal(true)
    })

    it('testCanReturnMessageValidTransfer', async function () {
      // Act + Assert
      expect(await this.cmtat.messageForTransferRestriction(0)).to.equal(
        'No restriction'
      )
    })

    it('testCanDetectTransferRestrictionWithAmountTooHigh', async function () {
      // Act + Assert
      expect(
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.address2,
          RULE_MOCK_AMOUNT_MAX + 1
        )
      ).to.equal(10n)

      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          RULE_MOCK_AMOUNT_MAX + 1
        )
      ).to.equal(false)
    })

    it('testCanReturnMessageWithAmountTooHigh', async function () {
      // Act + Assert
      expect(await this.cmtat.messageForTransferRestriction(10)).to.equal(
        'Amount too high'
      )
    })

    it('testCanReturnMessageWithUnknownRestrictionCode', async function () {
      // Act + Assert
      expect(await this.cmtat.messageForTransferRestriction(254)).to.equal(
        'Unknown restriction code'
      )
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
    it('testCannotTransferIfNotAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = RULE_MOCK_AMOUNT_MAX + 1
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
module.exports = ValidationModuleCommon
