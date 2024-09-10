const { PAUSER_ROLE, DEFAULT_ADMIN_ROLE } = require("../utils");
const { expect } = require('chai');
function PauseModuleCommon() {
  context("Pause", function () {
    /**
    The admin is assigned the PAUSER role when the contract is deployed
    */
    it("testCanBePausedByAdmin", async function () {
      const AMOUNT_TO_TRANSFER = 10n;
      // Act
      this.logs = await this.cmtat.connect(this.admin).pause();

      // Assert
      expect(await this.cmtat.paused()).to.equal(true);
      // emits a Paused event
      await expect(this.logs)
        .to.emit(this.cmtat, "Paused")
        .withArgs(this.admin);
      // Transfer is reverted
      await expect(  this.cmtat
        .connect(this.address1)
        .transfer(this.address2, AMOUNT_TO_TRANSFER))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
      .withArgs(this.address1.address, this.address2.address, AMOUNT_TO_TRANSFER);
    });

    it("testCanBePausedByPauserRole", async function () {
      const AMOUNT_TO_TRANSFER = 10n;
      // Arrange
      await this.cmtat
        .connect(this.admin)
        .grantRole(PAUSER_ROLE, this.address1);

      // Act
      this.logs = await this.cmtat.connect(this.address1).pause();

      // Assert
      expect(await this.cmtat.paused()).to.equal(true);
      // emits a Paused event
      await expect(this.logs)
        .to.emit(this.cmtat, "Paused")
        .withArgs(this.address1);
      // Transfer is reverted
      await expect( this.cmtat.connect(this.address1).transfer(this.address2, AMOUNT_TO_TRANSFER))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
      .withArgs(this.address1.address, this.address2.address, AMOUNT_TO_TRANSFER);
    });

    it("testCannotBePausedByNonPauser", async function () {
      await expect( this.cmtat.connect(this.address1).pause())
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address1.address, PAUSER_ROLE);
    });

    it("testCanBeUnpausedByAdmin", async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause();

      // Act
      this.logs = await this.cmtat.connect(this.admin).unpause();

      // Assert
      expect(await this.cmtat.paused()).to.equal(false);
      // emits a Unpaused event
      await expect(this.logs)
        .to.emit(this.cmtat, "Unpaused")
        .withArgs(this.admin);
      // Transfer works
      this.cmtat.connect(this.address1).transfer(this.address2, 10n);
    });

    it("testCanBeUnpausedByANewPauser", async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause();
      await this.cmtat.connect(this.admin).grantRole(PAUSER_ROLE, this.address1);

      // Act
      this.logs = await this.cmtat.connect(this.address1).unpause();

      // Assert
      expect(await this.cmtat.paused()).to.equal(false);
      // emits a Unpaused event
      await expect(this.logs).to.emit(this.cmtat, "Unpaused").withArgs( this.address1);
      // Transfer works
      this.cmtat.connect(this.address1).transfer(this.address2, 10n);
    });

    it("testCannotBeUnpausedByNonPauser", async function () {
      // Arrange
      await this.cmtat.connect(this.admin).pause();
      // Act
      await expect( this.cmtat.connect(this.address1).unpause())
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address1.address, PAUSER_ROLE);
    });

    // reverts if address1 transfers tokens to address2 when paused
    it("testCannotTransferTokenWhenPausedWithTransfer", async function () {
      const AMOUNT_TO_TRANSFER = 10n;
      // Act
      await this.cmtat.connect(this.admin).pause();
      // Act + Assert
      expect(
        await this.cmtat.validateTransfer(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal(false);
      // Assert
      expect(
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal("1");
      expect(await this.cmtat.messageForTransferRestriction(1)).to.equal(
        "All transfers paused"
      );
      await expect( this.cmtat
        .connect(this.address1)
        .transfer(this.address2, AMOUNT_TO_TRANSFER))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
      .withArgs(this.address1.address, this.address2.address, AMOUNT_TO_TRANSFER);
    });

    // reverts if address3 transfers tokens from address1 to address2 when paused
    it("testCannotTransferTokenWhenPausedWithTransferFrom", async function () {
      const AMOUNT_TO_TRANSFER = 10n;
      // Arrange
      // Define allowance
      await this.cmtat.connect(this.address1).approve(this.address3, 20);

      // Act
      await this.cmtat.connect(this.admin).pause();

      // Assert
      expect(
        await this.cmtat.detectTransferRestriction(
          this.address1,
          this.address2,
          AMOUNT_TO_TRANSFER
        )
      ).to.equal("1");
      expect(await this.cmtat.messageForTransferRestriction(1)).to.equal(
        "All transfers paused"
      );
      await expect( this.cmtat
        .connect(this.address3)
        .transferFrom(this.address1, this.address2, AMOUNT_TO_TRANSFER))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
      .withArgs(this.address1.address, this.address2.address, AMOUNT_TO_TRANSFER);
    });
  });

  context("DeactivateContract", function () {
    /**
    The admin is assigned the PAUSER role when the contract is deployed
    */
    it("testCanDeactivatedByAdmin", async function () {
      const AMOUNT_TO_TRANSFER = 10n;
      // Act
      this.logs = await this.cmtat.connect(this.admin).deactivateContract();

      // Assert
      expect(await this.cmtat.deactivated()).to.equal(true);
      // Contract is in pause state
      expect(await this.cmtat.paused()).to.equal(true);
      // emits a Deactivated event
      await expect(this.logs).to.emit(this.cmtat, 'Deactivated').withArgs(this.admin);
      // Transfer is reverted because contract is in paused state
      await expect(this.cmtat.connect(this.address1).transfer(this.address2, AMOUNT_TO_TRANSFER))
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_InvalidTransfer')
      .withArgs(this.address1.address, this.address2.address, AMOUNT_TO_TRANSFER);

      // Unpause is reverted
      await expect( this.cmtat.connect(this.admin).unpause())
      .to.be.revertedWithCustomError(this.cmtat, 'CMTAT_PauseModule_ContractIsDeactivated')
    });

    it("testCannotBeDeactivatedByNonAdmin", async function () {
      // Act
      await expect( this.cmtat.connect(this.address1).deactivateContract())
      .to.be.revertedWithCustomError(this.cmtat, 'AccessControlUnauthorizedAccount')
      .withArgs(this.address1.address, DEFAULT_ADMIN_ROLE);
      // Assert
      expect(await this.cmtat.deactivated()).to.equal(false);
    });
  });
}
module.exports = PauseModuleCommon;
