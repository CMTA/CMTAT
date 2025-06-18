const { expect } = require('chai')
const { RULE_MOCK_AMOUNT_MAX, RULE_MOCK_MINT_AMOUNT_MAX, ZERO_ADDRESS } = require('../../utils')

function ValidationModuleCommon () {
  // Transferring with Rule Engine set
  context('RuleEngineTransferTest', function () {
    beforeEach(async function () {
      if (!this.definedAtDeployment) {
        this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [this.admin])
      }
      if ((await this.cmtat.ruleEngine()) === ZERO_ADDRESS) {
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
    it('testCanCanTransferWithoutRuleEngine', async function () {
      if (!this.erc1404) {
        // Arrange
        await this.cmtat.connect(this.admin).setRuleEngine(ZERO_ADDRESS)
      }

      // Act + Assert
      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 10)
      ).to.equal(true)
    })

    it('testCanDetectTransferRestrictionValidTransfer', async function () {
      if (!this.erc1404) {
        // Act + Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            11
          )
        ).to.equal(0)
      }

      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 11)
      ).to.equal(true)
    })

    it('testCanReturnMessageValidTransfer', async function () {
      if (!this.erc1404) {
        // Act + Assert
        expect(await this.cmtat.messageForTransferRestriction(0)).to.equal(
          'NoRestriction'
        )
      }
    })

    it('testCanDetectTransferRestrictionWithAmountTooHigh', async function () {
      if (!this.erc1404) {
        // Act + Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            this.address1,
            this.address2,
            RULE_MOCK_AMOUNT_MAX + 1
          )
        ).to.equal(10n)
      }

      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          RULE_MOCK_AMOUNT_MAX + 1
        )
      ).to.equal(false)
    })

    it('testCanReturnMessageWithAmountTooHigh', async function () {
      if (!this.erc1404) {
        // Act + Assert
        expect(await this.cmtat.messageForTransferRestriction(10)).to.equal(
          'Amount too high'
        )
      }
    })

    it('testCanReturnMessageWithUnknownRestrictionCode', async function () {
      // Act + Assert
      expect(await this.cmtat.messageForTransferRestriction(254)).to.equal(
        'UnknownRestrictionCode'
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
  context('RuleEngineTransferFromTest', function () {
    beforeEach(async function () {
      if (!this.erc1404) {
        if ((await this.cmtat.ruleEngine()) === ZERO_ADDRESS) {
          this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [this.admin])
          await this.cmtat
            .connect(this.admin)
            .setRuleEngine(this.ruleEngineMock.target)
        }
      }
    })
    it('testCanTransferFrom', async function () {
      // Admin is an authorized spender
      expect(
        await this.cmtat.connect(this.address1).canTransferFrom(this.admin, this.address1, this.address2, 10)
      ).to.equal(true)
      expect(
        await this.cmtat.connect(this.address1).canTransferFrom(this.address2, this.address1, this.admin, 10)
      ).to.equal(false)
    })

    it('testCanCanTransferFromWithoutRuleEngine', async function () {
      // Arrange
      if (!this.erc1404) {
        await this.cmtat.connect(this.admin).setRuleEngine(ZERO_ADDRESS)
      }
      // Act + Assert
      expect(
        await this.cmtat.canTransferFrom(this.address1, this.admin, this.address2, 10)
      ).to.equal(true)
      expect(
        await this.cmtat.canTransferFrom(this.address1, this.address2, this.admin, 10)
      ).to.equal(true)
    })

    it('testCannotTransferFromIfNotAllowedByRuleEngine', async function () {
      const AMOUNT_TO_TRANSFER = RULE_MOCK_AMOUNT_MAX + 1
      // Act
      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)
      expect(
        await this.cmtat.canTransferFrom(this.address1, this.address2, this.admin, AMOUNT_TO_TRANSFER)
      ).to.equal(false)
      // Act
      await expect(
        this.cmtat
          .connect(this.address1)
          .transferFrom(this.address2, this.admin, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          this.address2.address,
          this.admin,
          AMOUNT_TO_TRANSFER
        )
    })
    it('testCanApproveAllowedByRuleEngine', async function () {
      const AMOUNT_TO_TRANSFER = 11n
      // Act
      expect(
        await this.cmtat.connect(this.admin).canTransferFrom(
          this.admin,
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)
      // Act
      await this.cmtat
        .connect(this.address1)
        .approve(this.admin, AMOUNT_TO_TRANSFER)
      // Assert
      expect(await this.cmtat.allowance(this.address1, this.admin)).to.equal(
        AMOUNT_TO_TRANSFER
      )
      await this.cmtat
        .connect(this.admin)
        .transferFrom(this.address1, this.address2, AMOUNT_TO_TRANSFER)
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        this.ADDRESS1_INITIAL_BALANCE - AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        this.ADDRESS2_INITIAL_BALANCE + AMOUNT_TO_TRANSFER)
    })
  })
  // Transferring with Rule Engine set
  context('RuleEngineMintTest', function () {
    beforeEach(async function () {
      if ((await this.cmtat.ruleEngine()) === ZERO_ADDRESS) {
        this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [this.admin])
        await this.cmtat
          .connect(this.admin)
          .setRuleEngine(this.ruleEngineMock.target)
      }
    })

    it('testCanCanMintWithoutRuleEngine', async function () {
      if (!this.erc1404) {
        // Arrange
        await this.cmtat.connect(this.admin).setRuleEngine(ZERO_ADDRESS)
      }

      // Act + Assert
      expect(
        await this.cmtat.canTransfer(ZERO_ADDRESS, this.address2, 10)
      ).to.equal(true)
    })

    it('testCanDetectTransferRestrictionValidTransfer', async function () {
      if (!this.erc1404) {
        // Act + Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            ZERO_ADDRESS,
            this.address2,
            11
          )
        ).to.equal(0)
      }

      expect(
        await this.cmtat.canTransfer(this.address1, this.address2, 11)
      ).to.equal(true)
    })

    it('testCanDetectTransferRestrictionWitMintAmountTooHigh', async function () {
      if (!this.erc1404) {
        // Act + Assert
        expect(
          await this.cmtat.detectTransferRestriction(
            ZERO_ADDRESS,
            this.address2,
            RULE_MOCK_MINT_AMOUNT_MAX + 1
          )
        ).to.equal(20n)
      }

      expect(
        await this.cmtat.canTransfer(
          this.address1,
          this.address2,
          RULE_MOCK_MINT_AMOUNT_MAX + 1
        )
      ).to.equal(false)
    })

    it('testCanReturnMessageWithMintAmountTooHigh', async function () {
      if (!this.erc1404) {
        // Act + Assert
        expect(await this.cmtat.messageForTransferRestriction(20)).to.equal(
          'Mint amount too high'
        )
      }
    })

    // this.address1 may transfer tokens to this.address2
    it('testCanMintAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = 11n
      // Act
      expect(
        await this.cmtat.canTransfer(
          ZERO_ADDRESS,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(true)
      // Act
      await this.cmtat
        .connect(this.admin)
        .mint(this.address2, AMOUNT_TO_TRANSFER)
        // Assert

      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        this.ADDRESS2_INITIAL_BALANCE + AMOUNT_TO_TRANSFER
      )
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(
        this.ADDRESS3_INITIAL_BALANCE
      )
    })

    // reverts if this.address1 transfers more tokens than rule allows
    it('testCannotMintIfNotAllowedByRule', async function () {
      const AMOUNT_TO_TRANSFER = RULE_MOCK_AMOUNT_MAX + 1
      // Act
      expect(
        await this.cmtat.canTransfer(
          ZERO_ADDRESS,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false)
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .mint(this.address2, AMOUNT_TO_TRANSFER)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(
          ZERO_ADDRESS,
          this.address2.address,
          AMOUNT_TO_TRANSFER
        )
    })
  })
}
module.exports = ValidationModuleCommon
