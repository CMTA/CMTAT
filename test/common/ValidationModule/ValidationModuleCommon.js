const { should } = require('chai').should()
const {
  expectRevertCustomError
} = require('../../../openzeppelin-contracts-upgradeable/test/helpers/customError')
const RuleEngineMock = artifacts.require('RuleEngineMock')
const { RULE_MOCK_AMOUNT_MAX, ZERO_ADDRESS } = require('../../utils')

function ValidationModuleCommon (
  admin,
  address1,
  address2,
  address3,
  address1InitialBalance,
  address2InitialBalance,
  address3InitialBalance
) {
  // Transferring with Rule Engine set
  context('RuleEngineTransferTest', function () {
    beforeEach(async function () {
      if ((await this.cmtat.ruleEngine()) === ZERO_ADDRESS) {
        this.ruleEngineMock = await RuleEngineMock.new({ from: admin })
        await this.cmtat.setRuleEngine(this.ruleEngineMock.address, {
          from: admin
        })
      }
    })

    it('testCanValidateTransferWithoutRuleEngine', async function () {
      // Arrange
      await this.cmtat.setRuleEngine(ZERO_ADDRESS, {
        from: admin
      });
      // Act + Assert
      (await this.cmtat.validateTransfer(address1, address2, 10)).should.be.equal(true)
    })

    it('testCanDetectTransferRestrictionValidTransfer', async function () {
      // Act + Assert
      (
        await this.cmtat.detectTransferRestriction(address1, address2, 11)
      ).should.be.bignumber.equal('0');
      (await this.cmtat.validateTransfer(address1, address2, 11)).should.be.equal(true)
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
          address1,
          address2,
          RULE_MOCK_AMOUNT_MAX + 1
        )
      ).should.be.bignumber.equal('10');

      (await this.cmtat.validateTransfer(address1, address2, RULE_MOCK_AMOUNT_MAX + 1))
        .should.be.equal(false)
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

    // ADDRESS1 may transfer tokens to ADDRESS2
    it('testCanTransferAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = 11;
      // Act
      (await this.cmtat.validateTransfer(address1, address2, AMOUNT_TO_TRANSFER)).should.be.equal(true)
      // Act
      await this.cmtat.transfer(address2, AMOUNT_TO_TRANSFER, {
        from: address1
      });
      // Assert
      (await this.cmtat.balanceOf(address1)).should.be.bignumber.equal(
        (address1InitialBalance - AMOUNT_TO_TRANSFER).toString()
      );
      (await this.cmtat.balanceOf(address2)).should.be.bignumber.equal(
        (address2InitialBalance + AMOUNT_TO_TRANSFER).toString()
      );
      (await this.cmtat.balanceOf(address3)).should.be.bignumber.equal(
        address3InitialBalance.toString()
      )
    })

    // reverts if ADDRESS1 transfers more tokens than rule allows
    it('testCannotTransferIfNotAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = RULE_MOCK_AMOUNT_MAX + 1;
      // Act
      (await this.cmtat.validateTransfer(address1, address2, AMOUNT_TO_TRANSFER)).should.be.equal(false)
      // Act
      await expectRevertCustomError(
        this.cmtat.transfer(address2, AMOUNT_TO_TRANSFER, { from: address1 }),
        'CMTAT_InvalidTransfer',
        [address1, address2, AMOUNT_TO_TRANSFER]
      )
    })
  })
}
module.exports = ValidationModuleCommon
