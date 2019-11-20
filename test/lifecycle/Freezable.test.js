const { expectEvent, shouldFail } = require('openzeppelin-test-helpers');

const FreezableMock = artifacts.require('FreezableMock');

contract('Freezable', function ([_, owner, other]) {
  beforeEach(async function () {
    this.freezable = await FreezableMock.new({ from: owner });
  });

  context('when unfrozen', function () {
    beforeEach(async function () {
      (await this.freezable.frozen()).should.equal(false);
    });

    it('can perform normal process when not frozen', async function () {
      (await this.freezable.count()).should.be.bignumber.equal('0');

      await this.freezable.normalProcess({ from: other });
      (await this.freezable.count()).should.be.bignumber.equal('1');
    });

    it('cannot call actionWhenFrozen when not frozen', async function () {
      await shouldFail.reverting.withMessage(this.freezable.actionWhenFrozen({ from: other }), 'FR02');
      (await this.freezable.isContractFrozen()).should.equal(false);
    });

    describe('freezing', function () {
      it('is freezable by the owner', async function () {
        await this.freezable.freeze({ from: owner });
        (await this.freezable.frozen()).should.equal(true);
      });

      it('reverts when freezing from non-owner', async function () {
        await shouldFail.reverting.withMessage(this.freezable.freeze({ from: other }), 'OW01');
      });

      context('when frozen', function () {
        beforeEach(async function () {
          ({ logs: this.logs } = await this.freezable.freeze({ from: owner }));
        });

        it('emits a LogFrozen event', function () {
          expectEvent.inLogs(this.logs, 'LogFrozen', { });
        });

        it('cannot perform normal process when frozen', async function () {
          await shouldFail.reverting.withMessage(this.freezable.normalProcess({ from: other }), 'FR01');
        });

        it('can call actionWhenFrozen when frozen', async function () {
          await this.freezable.actionWhenFrozen({ from: other });
          (await this.freezable.isContractFrozen()).should.equal(true);
        });

        it('reverts when re-freezing', async function () {
          await shouldFail.reverting.withMessage(this.freezable.freeze({ from: owner }), 'FR01');
        });

        describe('unfreezing', function () {
          it('is unfreezable by the owner', async function () {
            await this.freezable.unfreeze({ from: owner });
            (await this.freezable.frozen()).should.equal(false);
          });

          it('reverts when unfreezing from non-owner', async function () {
            await shouldFail.reverting.withMessage(this.freezable.unfreeze({ from: other }), 'OW01');
          });

          context('when unfrozen', function () {
            beforeEach(async function () {
              ({ logs: this.logs } = await this.freezable.unfreeze({ from: owner }));
            });

            it('emits an LogUnfrozen event', function () {
              expectEvent.inLogs(this.logs, 'LogUnfrozen', { });
            });

            it('should resume allowing normal process', async function () {
              (await this.freezable.count()).should.be.bignumber.equal('0');
              await this.freezable.normalProcess({ from: other });
              (await this.freezable.count()).should.be.bignumber.equal('1');
            });

            it('should prevent call to actionWhenFrozen', async function () {
              await shouldFail.reverting.withMessage(this.freezable.actionWhenFrozen({ from: other }), 'FR02');
            });

            it('reverts when re-unfreezing', async function () {
              await shouldFail.reverting.withMessage(this.freezable.unfreeze({ from: owner }), 'FR02');
            });
          });
        });
      });
    });
  });
});