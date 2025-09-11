const {
  CROSS_CHAIN_ROLE,
  BURNER_FROM_ROLE,
  MINTER_ROLE,
  ZERO_ADDRESS
} = require('../utils')
const { expect } = require('chai')
// const REASON = 'BURN_TEST'
const REASON_STRING = 'CrosschainBurn'
const REASON_EVENT = ethers.toUtf8Bytes(REASON_STRING)
const REASON_MINT_EVENT = ethers.toUtf8Bytes('CrosschainMint')
const REASON = ethers.Typed.bytes(REASON_EVENT)
const REASON_EMPTY = ethers.Typed.bytes(ethers.toUtf8Bytes(''))
const REASON_EMPTY_EVENT = ethers.toUtf8Bytes('')
function ERC20CrossChainModuleCommon () {
  context('CrosschainBurn', function () {
    const INITIAL_SUPPLY = 50

    const VALUE1 = 20
    const DIFFERENCE = INITIAL_SUPPLY - VALUE1

    async function testBurn (sender) {
      // Act
      // Burn 20
      this.logs = await this.cmtat
        .connect(sender)
        .crosschainBurn(this.address1, VALUE1)
      // Assert
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, VALUE1)
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'CrosschainBurn')
        .withArgs(this.address1, VALUE1, sender)
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(DIFFERENCE)
      expect(await this.cmtat.totalSupply()).to.equal(DIFFERENCE)

      // Burn 30
      // Act
      this.logs = await this.cmtat
        .connect(sender)
        .crosschainBurn(this.address1, DIFFERENCE)

      // Assert
      // Emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, DIFFERENCE)
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'CrosschainBurn')
        .withArgs(this.address1, DIFFERENCE, sender)
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(0n)
      expect(await this.cmtat.totalSupply()).to.equal(0n)
    }

    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY)
      expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
      await this.cmtat
        .connect(this.address1)
        .approve(this.admin, INITIAL_SUPPLY)
      await this.cmtat
        .connect(this.address1)
        .approve(this.address2, INITIAL_SUPPLY)
    })

    it('testCanBeBurntByAdmin', async function () {
      const bindTest = testBurn.bind(this)
      await bindTest(this.admin)
    })

    it('testCanBeBurntByBurnerRole', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(CROSS_CHAIN_ROLE, this.address2)
      // Act
      const bindTest = testBurn.bind(this)
      await bindTest(this.address2)
    })

    it('testCanReturnSupportedInterface', async function () {
      const IERC721Interface = '0x80ac58cd'
      const IERC165Id = '0x01ffc9a7'
      const crossChainInterface = '0x33331994'
      expect(await this.cmtat.supportsInterface(crossChainInterface)).to.equal(
        true
      )
      expect(await this.cmtat.supportsInterface(IERC165Id)).to.equal(
        true
      )
      expect(await this.cmtat.supportsInterface(IERC721Interface)).to.equal(
        false
      )
    })

    it('testCannotBeBurntIfBalanceExceeds', async function () {
      const AMOUNT_TO_BURN = 200n
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(this.address1)
      await this.cmtat
        .connect(this.address1)
        .approve(this.admin, AMOUNT_TO_BURN)
      // Act
      await expect(
        this.cmtat
          .connect(this.admin)
          .crosschainBurn(this.address1, AMOUNT_TO_BURN)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(this.address1.address, ADDRESS1_BALANCE, AMOUNT_TO_BURN)
    })

    it('testCannotBeBurntWithoutCrossChainRole', async function () {
      await expect(
        this.cmtat.connect(this.address2).crosschainBurn(this.address1, 20n)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, CROSS_CHAIN_ROLE)
    })

    /* //////////////////////////////////////////////////////////////
          COMPLIANCE
    ////////////////////////////////////////////////////////////// */

    it('testCannotBeBurnIfContractIsDeactivated', async function () {
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      await expect(
        this.cmtat.connect(this.admin).crosschainBurn(this.address1, VALUE1)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeBurnIfContractIsPaused', async function () {
      await this.cmtat.connect(this.admin).pause()
      await expect(
        this.cmtat.connect(this.admin).crosschainBurn(this.address1, VALUE1)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeBurnIfAddressIsFrozen', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)

      // Act
      const VALUE = 20
      await expect(
        this.cmtat.connect(this.admin).crosschainBurn(this.address1, VALUE)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.address1.address, ZERO_ADDRESS, VALUE)
    })
  })

  context('burn sender tokens', function () {
    const INITIAL_SUPPLY = 50n
    const INITIAL_SUPPLY_TYPED = ethers.Typed.uint256(50)
    const VALUE1 = 20n
    const VALUE_TYPED = ethers.Typed.uint256(20)
    const DIFFERENCE = INITIAL_SUPPLY - VALUE1
    const DIFFERENCE_TYPED = ethers.Typed.uint256(30)
    async function testBurn (sender) {
      // Act
      // Burn 20
      this.logs = await this.cmtat.connect(sender).burn(VALUE1)
      // Assert
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(sender, ZERO_ADDRESS, VALUE1)
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'BurnFrom')
        .withArgs(sender, sender, sender, VALUE1)
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(sender)).to.equal(DIFFERENCE)
      expect(await this.cmtat.totalSupply()).to.equal(DIFFERENCE)

      // Burn 30
      // Act
      this.logs = await this.cmtat.connect(sender).burn(DIFFERENCE)

      // Assert
      // Emits a Transfer event
      await expect(this.logs).to.emit(this.cmtat, 'Transfer')
      // Emits a Burn event
      await expect(this.logs)
        .to.emit(this.cmtat, 'BurnFrom')
        .withArgs(sender, sender, sender, DIFFERENCE)
      // Check balances and total supply
      expect(await this.cmtat.balanceOf(sender)).to.equal(0)
      expect(await this.cmtat.totalSupply()).to.equal(0)
    }

    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY)
      expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
    })

    /* //////////////////////////////////////////////////////////////
         ACCESS CONTROL
    ////////////////////////////////////////////////////////////// */

    it('testCanBeBurntByBurnerRole', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_FROM_ROLE, this.address1)
      // Act
      const bindTest = testBurn.bind(this)
      await bindTest(this.address1)
    })

    it('testCannotBeBurntWithoutBurnerRole', async function () {
      await expect(this.cmtat.connect(this.address2).burn(20n))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, BURNER_FROM_ROLE)

      // Without reason
      await expect(this.cmtat.connect(this.address2).burn(20n))
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, BURNER_FROM_ROLE)
    })

    /* //////////////////////////////////////////////////////////////
          ERC-20 check
    ////////////////////////////////////////////////////////////// */

    it('testCannotBeBurntIfBalanceExceeds', async function () {
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_FROM_ROLE, this.address1)
      // error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
      const AMOUNT_TO_BURN = 200n
      const ADDRESS1_BALANCE = await this.cmtat.balanceOf(this.address1)
      // Act
      await expect(this.cmtat.connect(this.address1).burn(AMOUNT_TO_BURN))
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientBalance')
        .withArgs(this.address1.address, ADDRESS1_BALANCE, AMOUNT_TO_BURN)
    })

    /* //////////////////////////////////////////////////////////////
          COMPLIANCE
    ////////////////////////////////////////////////////////////// */

    it('testCannotBeMBurnIfContractIsDeactivated', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      // Act
      await expect(
        this.cmtat.connect(this.admin).burn(VALUE_TYPED)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCanBeBurnEvenIfContractIsPaused', async function () {
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_FROM_ROLE, this.address1)
      await this.cmtat.connect(this.admin).pause()
      await expect(
        this.cmtat.connect(this.admin).burn(VALUE_TYPED)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeBurnIfAddressIsFrozen', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_FROM_ROLE, this.address1)
      // Act
      const VALUE = 20
      const VALUE_TYPED = ethers.Typed.uint256(20)
      await expect(this.cmtat.connect(this.address1).burn(VALUE_TYPED))
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.address1.address, ZERO_ADDRESS, VALUE)
    })
  })

  context('burnFrom', function () {
    const INITIAL_SUPPLY = 50n
    const VALUE1 = 20n

    beforeEach(async function () {
      await this.cmtat.connect(this.admin).mint(this.address1, INITIAL_SUPPLY)
      expect(await this.cmtat.totalSupply()).to.equal(INITIAL_SUPPLY)
    })

    /* //////////////////////////////////////////////////////////////
         ACCESS CONTROL
    ////////////////////////////////////////////////////////////// */

    it('canBeBurnFrom', async function () {
      // Arrange
      const AMOUNT_TO_BURN = 20n
      await this.cmtat
        .connect(this.admin)
        .grantRole(BURNER_FROM_ROLE, this.address2)
      await this.cmtat.connect(this.address1).approve(this.address2, 50n)
      // Act
      this.logs = await this.cmtat
        .connect(this.address2)
        .burnFrom(this.address1, AMOUNT_TO_BURN)
      // Assert
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(this.address1, ZERO_ADDRESS, AMOUNT_TO_BURN)
      await expect(this.logs)
        .to.emit(this.cmtat, 'BurnFrom')
        .withArgs(this.address2, this.address1, this.address2, AMOUNT_TO_BURN)
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(30n)
      expect(await this.cmtat.totalSupply()).to.equal(30n)
    })

    it('testCannotBeBurntWithoutBurnerFromRole', async function () {
      await expect(
        this.cmtat.connect(this.address2).burnFrom(this.address1, 20n)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address2.address, BURNER_FROM_ROLE)
    })

    /* //////////////////////////////////////////////////////////////
          ERC-20 check
    ////////////////////////////////////////////////////////////// */

    it('TestCannotBeBurnWithoutAllowance', async function () {
      const AMOUNT_TO_BURN = 20n
      await expect(
        this.cmtat.connect(this.admin).burnFrom(this.address1, AMOUNT_TO_BURN)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'ERC20InsufficientAllowance')
        .withArgs(this.admin.address, 0, AMOUNT_TO_BURN)
    })

    /* //////////////////////////////////////////////////////////////
          COMPLIANCE
    ////////////////////////////////////////////////////////////// */

    it('testCannotBeBurnFromIfContractIsPaused', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.address1).approve(this.admin, 50n)
      // Act
      await expect(
        this.cmtat.connect(this.admin).burnFrom(this.address1, 20n)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeBurnFromIfContractIsDeactivated', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      await this.cmtat.connect(this.address1).approve(this.admin, 50n)
      // Act
      await expect(
        this.cmtat.connect(this.admin).burnFrom(this.address1, 20n)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeBurnFromIfAccountIsFrozen', async function () {
      await this.cmtat.connect(this.address1).approve(this.admin, 50n)
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)
      // Act
      await expect(this.cmtat.connect(this.admin).burnFrom(this.address1, 20n))
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(this.address1, ZERO_ADDRESS, VALUE1)
    })
  })
  context('CrossChainMinting', function () {
    const VALUE1 = 20n
    const VALUE2 = 50n
    async function testMint (sender) {
      // Arrange

      // Arrange - Assert
      // Check first balance
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(0n)

      // Act
      // Issue 20 and check balances and total supply
      this.logs = await this.cmtat
        .connect(sender)
        .crosschainMint(this.address1, VALUE1)

      // Assert
      expect(await this.cmtat.balanceOf(this.address1)).to.equal(VALUE1)
      expect(await this.cmtat.totalSupply()).to.equal(VALUE1)

      // Assert event
      // emits a Transfer event
      await expect(this.logs)
        .to.emit(this.cmtat, 'Transfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE1)
      await expect(this.logs)
        .to.emit(this.cmtat, 'CrosschainMint')
        .withArgs(this.address1, VALUE1, sender)

      // Act
      // Issue 50 and check intermediate balances and total supply
      this.logs = await this.cmtat
        .connect(sender)
        .crosschainMint(this.address2, VALUE2)

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
        .to.emit(this.cmtat, 'CrosschainMint')
        .withArgs(this.address2, VALUE2, sender)
    }

    /**
    The admin is assigned the MINTER role when the contract is deployed
     */
    it('testCanBeMintedByAdmin', async function () {
      const bindTest = testMint.bind(this)
      await bindTest(this.admin)
    })

    it('testCanMintByANewMinter', async function () {
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(CROSS_CHAIN_ROLE, this.address1)

      const bindTest = testMint.bind(this)
      await bindTest(this.address1)
    })

    it('testCannotMintByNonMinter', async function () {
      await expect(
        this.cmtat.connect(this.address1).crosschainMint(this.address1, VALUE1)
      )
        .to.be.revertedWithCustomError(
          this.cmtat,
          'AccessControlUnauthorizedAccount'
        )
        .withArgs(this.address1.address, CROSS_CHAIN_ROLE)
    })

    /* //////////////////////////////////////////////////////////////
          COMPLIANCE
    ////////////////////////////////////////////////////////////// */

    it('testCannotBeMintedIfContractIsPaused', async function () {
      await this.cmtat.connect(this.admin).pause()
      await expect(
        this.cmtat.connect(this.admin).crosschainMint(this.address1, VALUE1)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeMintedIfContractIsDeactivated', async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause()
      await this.cmtat.connect(this.admin).deactivateContract()
      // Act
      await expect(
        this.cmtat.connect(this.admin).crosschainMint(this.address1, VALUE1)
      ).to.be.revertedWithCustomError(this.cmtat, 'EnforcedPause')
    })

    it('testCannotBeMintedIfToIsFrozen', async function () {
      await this.cmtat
        .connect(this.admin)
        .setAddressFrozen(this.address1, true)
      await expect(
        this.cmtat.connect(this.admin).crosschainMint(this.address1, VALUE1)
      )
        .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
        .withArgs(ZERO_ADDRESS, this.address1, VALUE1)
    })
  })
}
module.exports = ERC20CrossChainModuleCommon
