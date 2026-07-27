const { expect } = require('chai')
const { ZERO_ADDRESS, MINTER_ROLE } = require('../utils.js')
const VALUE1 = 20n
const VALUE2 = 50n

const REASON_STRING = 'MINT_TEST'
const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON = ethers.Typed.bytes(REASON_EVENT)
function ERC20MintModuleCommon () {
  context('Minting', function () {
    async function testMint (sender) {
      // Arrange

      // Arrange - Assert
      // Check first balance
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(0n)

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat.connect(sender).mint(this.address1, VALUE1)

      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(VALUE1)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE1)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(sender, this.address1, VALUE1, '0x')

      // Act
      // Issue 50 and check intermediate balances and total supply
      this.logs = await this.cmtat.connect(sender).mint(this.address2, VALUE2)

      // Assert
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(VALUE2)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1 + VALUE2)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address2, VALUE2)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(sender, this.address2, VALUE2, '0x')
    }

    async function testMintReason (sender) {
      // Arrange

      // Arrange - Assert
      // Check first balance
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(0n)

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(sender)
        .mint(this.address1, VALUE1, REASON)

      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(VALUE1)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE1)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(sender, this.address1, VALUE1, REASON_EVENT)

      // Act
      // Issue 50 and check intermediate balances and total supply
      this.logs = await this.cmtat
        .connect(sender)
        .mint(this.address2, VALUE2, REASON)

      // Assert
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(VALUE2)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1 + VALUE2)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address2, VALUE2)
      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Mint')
        .withArgs(sender, this.address2, VALUE2, REASON_EVENT)
    }

    /* //////////////////////////////////////////////////////////////
                        ACCESS CONTROL
    ////////////////////////////////////////////////////////////// */

    /**
     * The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      const bindTest = testMint.bind(this)
      await bindTest(this.admin)
    })

    it('testCanMintByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address1)

      const bindTest = testMint.bind(this)
      await bindTest(this.address1)
    })

    it('testCanBeMintedWithReasonByAdmin', async function () {
      const bindTest = testMintReason.bind(this)
      await bindTest(this.admin)
    })

    it('testCanMintWithReasonByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address1)

      const bindTest = testMintReason.bind(this)
      await bindTest(this.address1)
    })

    // reverts when issuing by a non minter
    it('testCannotMintByNonMinter', async function () {
      await expect(
        this.cmtat.connect(this.address1).mint(this.address1, VALUE1)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, MINTER_ROLE)
    })

    /* //////////////////////////////////////////////////////////////
                      COMPLIANCE
    ////////////////////////////////////////////////////////////// */

    it('testCanBeMintedEvenIfContractIsPaused', async function () {
      await this.cmtat.connect(this.admin).pause()
      const bindTest = testMint.bind(this)
      await bindTest(this.admin)
    })

    it('testCannotBeMintedIfContractIsDeactivated', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      // Act
      await expect(
        this.cmtat.connect(this.admin).mint(this.address1, VALUE1)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedDeactivation')
    })

    it('testCannotBeMintedIfToIsFrozen', async function () {
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)
      await expect(
        this.cmtat.connect(this.admin).mint(this.address1, VALUE1)
      ).to.be.revertedWithCustomError(this.cmtat, 'ERC7943CannotReceive')
    })

    it('testFrozenMinterCanStillMint', async function () {
      // NM-5 / documented behaviour: CMTAT's own freeze logic does NOT block mint — only the
      // recipient (and deactivation) is checked, not the operator. A frozen MINTER_ROLE holder
      // can still mint. (Standard version: a configured RuleEngine could still reject via the
      // spender it receives, but none is set by default here; Light has no RuleEngine.)
      // To stop a compromised minter, revoke its role — freezing does not.
      await this.cmtat.connect(this.admin).setAddressFrozen(this.admin, true)
      expect(await this.cmtat.isFrozen(this.admin)).to.equal(true)

      await expect(this.cmtat.connect(this.admin).mint(this.address2, VALUE1)).to
        .not.be.reverted
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(VALUE1)
    })

    it('testFrozenMinterCanStillBatchMint', async function () {
      await this.cmtat.connect(this.admin).setAddressFrozen(this.admin, true)

      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint([this.address2.address, this.address3.address], [
            VALUE1,
            VALUE2
          ])
      ).to.not.be.reverted
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(VALUE1)
      expect(await this.cmtat.balanceOf(this.address3)).to.equal(VALUE2)
    })

    it('testMintPropagatesSpenderToRuleEngine', async function () {
      if (!this.cmtat.setRuleEngine) {
        this.skip()
      }

      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
        this.admin
      ])
      await this.cmtat.connect(this.admin).setRuleEngine(this.ruleEngineMock)
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address2)

      await expect(this.cmtat.connect(this.address2).mint(this.address1, 10n))
        .to.be.revertedWithCustomError(
          this.ruleEngineMock,
          'RuleEngine_InvalidTransfer'
        )
        .withArgs(ZERO_ADDRESS, this.address1, 10n)
    })

    it('testMintWithRuleEngineAuthorizedSpenderCanMint', async function () {
      if (!this.cmtat.setRuleEngine) {
        this.skip()
      }

      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
        this.admin
      ])
      await this.cmtat.connect(this.admin).setRuleEngine(this.ruleEngineMock)

      await expect(
        this.cmtat.connect(this.admin).mint(this.address1, 10n)
      ).to.not.be.reverted
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(10n)
    })
  })

  context('Batch Minting', function () {
    const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
    async function testMintBatch (sender) {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Arrange - Assert
      // Check first balance
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(0n)
      }

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(sender)
        .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)

      // Assert
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_HOLDER[i])).to.equal(
          TOKEN_SUPPLY_BY_HOLDERS[i]
        )
      }

      expect(await this.cmtat.totalSupply()).to.equal(
        TOKEN_SUPPLY_BY_HOLDERS.reduce((a, b) => {
          return a + b
        })
      )
      // Assert event
      // emits a Transfer event
      for (let i = 0; i < TOKEN_HOLDER.length; ++i) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'Transfer')
          .withArgs(ZERO_ADDRESS, TOKEN_HOLDER[i], TOKEN_SUPPLY_BY_HOLDERS[i])
      }

      // emits a Mint event
      await expect(this.logs)
        .to.emit(this.cmtat, 'BatchMint')
        .withArgs(sender, TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
    }

    /* //////////////////////////////////////////////////////////////
                        ACCESS CONTROL
    ////////////////////////////////////////////////////////////// */

    /**
     * The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedBatchByAdmin', async function () {
      const bindTest = testMintBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testCanBeMintBatchedByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address1)
      const bindTest = testMintBatch.bind(this)
      await bindTest(this.address1)
    })

    it('testBatchMintPropagatesSpenderToRuleEngine', async function () {
      if (!this.cmtat.setRuleEngine) {
        this.skip()
      }

      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]

      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
        this.admin
      ])
      await this.cmtat.connect(this.admin).setRuleEngine(this.ruleEngineMock)
      await this.cmtat
        .connect(this.admin)
        .grantRole(MINTER_ROLE, this.address3)

      await expect(
        this.cmtat
          .connect(this.address3)
          .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(
          this.ruleEngineMock,
          'RuleEngine_InvalidTransfer'
        )
        .withArgs(ZERO_ADDRESS, this.admin, TOKEN_SUPPLY_BY_HOLDERS[0])
    })

    it('testBatchMintWithRuleEngineAuthorizedSpenderCanMint', async function () {
      if (!this.cmtat.setRuleEngine) {
        this.skip()
      }

      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      // Keep values below RuleMockMint threshold (< 25) so this test
      // validates authorized spender propagation, not mock rule limits.
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 11n, 12n]

      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
        this.admin
      ])
      await this.cmtat.connect(this.admin).setRuleEngine(this.ruleEngineMock)
      await this.cmtat.connect(this.admin).grantRole(MINTER_ROLE, this.admin)

      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.not.be.reverted
      expect(await this.cmtat.balanceOf(this.admin)).to.equal(
        TOKEN_SUPPLY_BY_HOLDERS[0]
      )
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(
        TOKEN_SUPPLY_BY_HOLDERS[1]
      )
      expect(await this.cmtat.balanceOf(this.address2)).to.equal(
        TOKEN_SUPPLY_BY_HOLDERS[2]
      )
    })

    it('testCannotBatchMintByNonMinter', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.address1)
          .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, MINTER_ROLE)
    })

    /* //////////////////////////////////////////////////////////////
                         INPUT PARAMETERS
    ////////////////////////////////////////////////////////////// */

    it('testCannotBatchMintIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_HOLDER_INVALID = [this.admin, this.address1]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotBatchMintIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const TOKEN_HOLDER_INVALID = [
        this.admin,
        this.address1,
        this.address1,
        this.address1
      ]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_AccountsValueslengthMismatch'
      )
    })

    it('testCannotBatchMintIfTOSIsEmpty', async function () {
      const TOKEN_HOLDER_INVALID = []
      const TOKEN_SUPPLY_BY_HOLDERS = []
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER_INVALID, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_EmptyAccounts'
      )
    })

    /* //////////////////////////////////////////////////////////////
                          COMPLIANCE
    ////////////////////////////////////////////////////////////// */

    it('testCanBeMintedBatchEvenIfContractIsPaused', async function () {
      await this.cmtat.connect(this.admin).pause()
      const bindTest = testMintBatch.bind(this)
      await bindTest(this.admin)
    })

    it('testCannotBeBatchMintedIfContractIsDeactivated', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedDeactivation')
    })

    it('testCannotBeBatchMintedIfToIsFrozen', async function () {
      const TOKEN_HOLDER = [this.address1, this.admin, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchMint(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC7943CannotReceive')
        .withArgs(this.address1)
    })
  })

  context('batchTransfer', function () {
    const TOKEN_AMOUNTS = [10n, 100n, 1000n]

    beforeEach(async function () {
      // Only the admin has tokens
      await this.cmtat.connect(this.admin).mint(
        this.admin,
        TOKEN_AMOUNTS.reduce((a, b) => {
          return a + b
        })
      )
    })

    it('testbatchTransfer', async function () {
      const TOKEN_ADDRESS_TOS = [this.address1, this.address2, this.address3]
      // Act
      this.logs = await this.cmtat
        .connect(this.admin)
        .batchTransfer(TOKEN_ADDRESS_TOS, TOKEN_AMOUNTS)
      // Assert
      for (let i = 0; i < TOKEN_ADDRESS_TOS.length; ++i) {
        expect(await this.cmtat.balanceOf(TOKEN_ADDRESS_TOS[i])).to.equal(
          TOKEN_AMOUNTS[i]
        )
      }
      // emits a Transfer event
      for (let i = 0; i < TOKEN_ADDRESS_TOS.length; ++i) {
        await expect(this.logs)
          .to.emit(this.cmtat, 'Transfer')
          .withArgs(this.admin, TOKEN_ADDRESS_TOS[i], TOKEN_AMOUNTS[i])
      }
    })

    // ADDRESS1 -> ADDRESS2
    it('testCannotBatchTransferMoreTokensThanOwn', async function () {
      const TOKEN_ADDRESS_TOS = [this.address1, this.address2, this.address3]
      const BALANCE_AFTER_FIRST_TRANSFER =
        (await this.cmtat.balanceOf(this.admin)) - TOKEN_AMOUNTS[0]
      const AMOUNT_TO_TRANSFER_SECOND = BALANCE_AFTER_FIRST_TRANSFER + 1n
      // Second amount is invalid
      const TOKEN_AMOUNTS_INVALID = [
        TOKEN_AMOUNTS[0],
        AMOUNT_TO_TRANSFER_SECOND,
        TOKEN_AMOUNTS[2]
      ]
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS, TOKEN_AMOUNTS_INVALID)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(
          this.admin.address,
          BALANCE_AFTER_FIRST_TRANSFER,
          AMOUNT_TO_TRANSFER_SECOND
        )
    })

    /* //////////////////////////////////////////////////////////////
                           INPUT PARAMETERS
    ////////////////////////////////////////////////////////////// */

    it('testCannotBatchTransferIfLengthMismatchMissingAddresses', async function () {
      // Number of addresses is insufficient
      const TOKEN_ADDRESS_TOS_INVALID = [this.address1, this.address2]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS_INVALID, TOKEN_AMOUNTS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_TosValueslengthMismatch'
      )
    })

    it('testCannotBatchTransferIfLengthMismatchTooManyAddresses', async function () {
      // There are too many addresses
      const TOKEN_ADDRESS_TOS_INVALID = [
        this.address1,
        this.address2,
        this.address1,
        this.address1
      ]
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS_INVALID, TOKEN_AMOUNTS)
      ).to.be.revertedWithCustomError(
        this.cmtat,
        'CMTAT_MintModule_TosValueslengthMismatch'
      )
    })

    it('testCannotBatchTransferIfTOSIsEmpty', async function () {
      const TOKEN_ADDRESS_TOS_INVALID = []
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS_INVALID, TOKEN_AMOUNTS)
      ).to.be.revertedWithCustomError(this.cmtat, 'CMTAT_MintModule_EmptyTos')
    })

    /* //////////////////////////////////////////////////////////////
                          COMPLIANCE
    ////////////////////////////////////////////////////////////// */

    it('testCannotBeBatchTransferIfContractIsPaused', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      const TOKEN_HOLDER_ADMIN = [this.admin, this.admin, this.admin]

      await this.cmtat
        .connect(this.admin)
        .batchMint(TOKEN_HOLDER_ADMIN, TOKEN_SUPPLY_BY_HOLDERS)
      await this.cmtat.connect(this.admin).pause()
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeBatchMTransferIfContractIsDeactivated', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      const TOKEN_HOLDER_ADMIN = [this.admin, this.admin, this.admin]

      await this.cmtat
        .connect(this.admin)
        .batchMint(TOKEN_HOLDER_ADMIN, TOKEN_SUPPLY_BY_HOLDERS)
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeBatchTransferIfToIsFrozen', async function () {
      const TOKEN_HOLDER = [this.admin, this.address1, this.address2]
      const TOKEN_SUPPLY_BY_HOLDERS = [10n, 100n, 1000n]
      const TOKEN_HOLDER_ADMIN = [this.admin, this.admin, this.admin]
      await this.cmtat
        .connect(this.admin)
        .batchMint(TOKEN_HOLDER_ADMIN, TOKEN_SUPPLY_BY_HOLDERS)
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)

      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_HOLDER, TOKEN_SUPPLY_BY_HOLDERS)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC7943CannotReceive')
        .withArgs(TOKEN_HOLDER[1])
    })

    it('testCannotBatchTransferIfMinterIsFrozen', async function () {
      // NM-5: the minter-transfer path threads the operator (_msgSender()) as spender in
      // every base (Light and full), so freezing the minter blocks its own batchTransfer.
      const TOKEN_ADDRESS_TOS = [this.address1, this.address2, this.address3]
      // The batchTransfer beforeEach minted TOKEN_AMOUNTS to the admin (the minter)
      await this.cmtat.connect(this.admin).setAddressFrozen(this.admin, true)
      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS, TOKEN_AMOUNTS)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC7943CannotSend')
        .withArgs(this.admin.address)
    })

    it('testBatchTransferPropagatesSpenderToRuleEngine', async function () {
      if (!this.cmtat.setRuleEngine) {
        this.skip()
      }

      const TOKEN_ADDRESS_TOS = [this.address1, this.address2, this.address3]
      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
        this.address3
      ])
      await this.cmtat.connect(this.admin).setRuleEngine(this.ruleEngineMock)

      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS, TOKEN_AMOUNTS)
      )
        .to.be.revertedWithCustomError(
          this.ruleEngineMock,
          'RuleEngine_InvalidTransfer'
        )
        .withArgs(this.admin, this.address1, TOKEN_AMOUNTS[0])
    })

    it('testBatchTransferWithRuleEngineAuthorizedSpenderCanTransfer', async function () {
      if (!this.cmtat.setRuleEngine) {
        this.skip()
      }

      const TOKEN_ADDRESS_TOS = [this.address1, this.address2, this.address3]
      const TOKEN_AMOUNTS_AUTHORIZED = [10n, 11n, 12n]
      this.ruleEngineMock = await ethers.deployContract('RuleEngineMock', [
        this.admin
      ])
      await this.cmtat.connect(this.admin).setRuleEngine(this.ruleEngineMock)

      await expect(
        this.cmtat
          .connect(this.admin)
          .batchTransfer(TOKEN_ADDRESS_TOS, TOKEN_AMOUNTS_AUTHORIZED)
      ).to.not.be.reverted
    })
  })
}
module.exports = ERC20MintModuleCommon
