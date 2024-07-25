const { should } = require('chai').should()
const { expect } = require('chai');
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError')
const { RULE_MOCK_AMOUNT_MAX, ZERO_ADDRESS } = require('../../utils')

function ValidationModuleCommon () {
  // Transferring with Rule Engine set
  context('RuleEngineTransferTest', function () {
    beforeEach(async function () {
      if ((await this.cmtat.ruleEngine()) === ZERO_ADDRESS) {
        this.ruleEngineMock = await ethers.deployContract("RuleEngineMock")
        await this.cmtat.connect(this.admin).setRuleEngine(this.ruleEngineMock)
      }
    })

    it('testCanValidateTransferWithoutRuleEngine', async function () {
     // Arrange
     await this.cmtat.connect(this.admin).setRuleEngine(ZERO_ADDRESS);
      // Act + Assert
     (
        await this.cmtat.validateTransfer(this.address1, this.address2, 10)
      ).should.be.equal(true)
    })

    it('testCanDetectTransferRestrictionValidTransfer', async function () {
      // Act + Assert
      (
        await this.cmtat.detectTransferRestriction(this.address1, this.address2, 11)
      ).should.be.equal(0n);
      (
        await this.cmtat.validateTransfer(this.address1, this.address2, 11)
      ).should.be.equal(true)
    })

    it('testCanReturnMessageValidTransfer', async function () {
      // Act + Assert
      (await this.cmtat.messageForTransferRestriction(0)).should.equal(
        'No restriction'
      )
    })

    it('testCanDetectTransferRestrictionWithAmountTooHigh', async function () {
      // Act + Assert
      (
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.address2,
          RULE_MOCK_AMOUNT_MAX + 1
        )
      ).should.be.equal(10n);

      (
        await this.cmtat.validateTransfer(
          this.address1,
          this.address2,
          RULE_MOCK_AMOUNT_MAX + 1
        )
      ).should.be.equal(false)
    })

    it('testCanReturnMessageWithAmountTooHigh', async function () {
      // Act + Assert
      (await this.cmtat.messageForTransferRestriction(10)).should.equal(
        'Amount too high'
      )
    })

    it('testCanReturnMessageWithUnknownRestrictionCode', async function () {
      // Act + Assert
      (await this.cmtat.messageForTransferRestriction(254)).should.equal(
        'Unknown restriction code'
      )
    })

    // this.address1 may transfer tokens to this.address2
    it('testCanTransferAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = 11n;
      // Act
      (
        await this.cmtat.validateTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).should.be.equal(true)
      // Act
      await this.cmtat.connect(this.address1).transfer(this.address2, AMOUNT_TO_TRANSFER);
      // Assert
      (await this.cmtat.balanceOf(this.address1)).should.be.equal(
        this.ADDRESS1_INITIAL_BALANCE - AMOUNT_TO_TRANSFER
      );
      (await this.cmtat.balanceOf(this.address2)).should.be.equal(
        this.ADDRESS2_INITIAL_BALANCE + AMOUNT_TO_TRANSFER
      );
      (await this.cmtat.balanceOf(this.address3)).should.be.equal(
        this.ADDRESS3_INITIAL_BALANCE
      )
    })

    // reverts if this.address1 transfers more tokens than rule allows
    it('testCannotTransferIfNotAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = RULE_MOCK_AMOUNT_MAX + 1;
      // Act
      (
        await this.cmtat.validateTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).should.be.equal(false)
      // Act
      await expectRevertCustomError(
        this.cmtat.connect(this.address1).transfer(this.address2, AMOUNT_TO_TRANSFER),
        'CMTAT_InvalidTransfer',
        [this.address1.address, this.address2.address, AMOUNT_TO_TRANSFER]
      )
    })
  })
}
module.exports = ValidationModuleCommon
