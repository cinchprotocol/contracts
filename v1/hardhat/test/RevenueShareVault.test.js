const { expect } = require("chai");
const { upgrades } = require("hardhat");

let accounts;
let owner, user1, user2, user3;
let mockERC20, mockProtocol, vault, mockAttackerERC20, mockAttacker;
let mockERC20Decimals = 6;
let referral1, referral2, referral3;

const depositAmount1 = ethers.utils.parseUnits("1000", mockERC20Decimals);
const depositAmount2 = ethers.utils.parseUnits("1000", mockERC20Decimals);
const depositAmount3 = ethers.utils.parseUnits("1000", mockERC20Decimals);
const revenueShareAmount3 = ethers.utils.parseUnits("100", mockERC20Decimals);
const initCinchPerformanceFeePercentage = ethers.utils.parseUnits("0", 2);
const cinchPerformanceFeePercentage10 = ethers.utils.parseUnits("10", 2);
const cinchPerformanceFeePercentage100 = ethers.utils.parseUnits("100", 2);
const ZERO_ADDRESS = ethers.constants.AddressZero;
const mockSwapperAddress = ZERO_ADDRESS;

before(async function () {
    // get accounts from hardhat
    accounts = await ethers.getSigners();
    owner = accounts[0];
    user1 = accounts[1];
    user2 = accounts[2];
    user3 = accounts[3];
    referral1 = user1.address;
    referral2 = user2.address;
    referral3 = user3.address;
});

describe("RevenueShareVault", function () {
    describe("Deployment", function () {
        it("Should deploy MockERC20", async function () {
            const MockERC20 = await ethers.getContractFactory("MockERC20");
            mockERC20 = await MockERC20.deploy();
            mockERC20Decimals = await mockERC20.decimals();
            expect(mockERC20.address).to.not.be.undefined;
            expect(mockERC20Decimals).equal(6);
            console.log("mockERC20", mockERC20.address);
        });
        it("Should deploy MockProtocol", async function () {
            const MockProtocol = await ethers.getContractFactory("MockProtocol");
            mockProtocol = await MockProtocol.deploy(mockERC20.address);
            expect(mockProtocol.address).to.not.be.undefined;
            console.log("mockProtocol", mockProtocol.address);
        });
        it("Should deploy and Initialize RevenueShareVault", async function () {
            const Vault = await ethers.getContractFactory("RevenueShareVault", owner);
            vault = await upgrades.deployProxy(Vault, [
                mockERC20.address,
                "CinchRevenueShare",
                "CRS",
                mockProtocol.address,
                mockSwapperAddress,
                initCinchPerformanceFeePercentage,
            ]);
            expect(vault.address).to.not.be.undefined;
            console.log("vault", vault.address);
        });
        it("Should not be able to re-initialized", async function () {
            const tx = vault.initialize(mockERC20.address,
                "CinchRevenueShare",
                "CRS",
                mockProtocol.address,
                mockSwapperAddress,
                initCinchPerformanceFeePercentage);
            await expect(tx).to.be.revertedWith("Initializable: contract is already initialized");
        });
    });

    describe("depositToRevenueShare", function () {
        it("should be reverted with zero totalSharesInReferral", async function () {
            const tx = vault.depositToRevenueShare(
                user3.address,
                user3.address,
                revenueShareAmount3
            );
            await expect(tx).to.be.revertedWith("GeneralRevenueShareLogic: totalSharesInReferral is zero");
        });
    });

    describe("Deposit", function () {
        it("should fail without mockERC20 approval", async function () {
            const tx = vault
                .connect(user1)
                .depositWithReferral(depositAmount1, user1.address, user1.address);
            await expect(tx).to.be.revertedWith("ERC20: insufficient allowance");
        });
        it("should fail if sender doesn't have enough funds", async function () {
            await mockERC20.faucet(user1.address, depositAmount1);
            await mockERC20.connect(user1).approve(vault.address, depositAmount1);
            const tx = vault
                .connect(user1)
                .depositWithReferral(depositAmount1.add(1), user1.address, user1.address);
            await expect(tx).to.be.revertedWith("ERC20: insufficient allowance");
        });
        it("should be able to deposit", async function () {
            await vault.connect(user1).depositWithReferral(depositAmount1, user1.address, referral1);
            expect(await vault.balanceOf(user1.address)).to.equal(depositAmount1);
            expect(await vault.totalSharesByReferral(user1.address)).to.equal(
                depositAmount1
            );
            /*
            expect(
                await vault.assetBalanceAtYieldSourceOf(user1.address, referral1)
            ).to.equal(depositAmount1);
            */
        });
        it("should be able to deposit with referral", async function () {
            expect(await vault.totalSharesByReferral(referral2)).equal(0);
            await mockERC20.faucet(user2.address, depositAmount2);
            await mockERC20.connect(user2).approve(vault.address, depositAmount2);
            await vault
                .connect(user2)
                .depositWithReferral(depositAmount2, user2.address, referral2);
            expect(await vault.balanceOf(user2.address)).to.equal(depositAmount2);
            expect(await vault.totalSharesByReferral(user2.address)).to.equal(
                depositAmount2
            );
        });
        /*
        it("should not be able to mint", async function () {
            const tx = vault
                .connect(user2)
                .mint(depositAmount2, user2.address);
            await expect(tx).to.be.revertedWith("RevenueShareVault: not supported");
        });
        */
        it("should be pausable", async function () {
            await vault.pause();
            const tx01 = vault.connect(user1).depositWithReferral(depositAmount1, user1.address, referral1);
            await expect(tx01).to.be.revertedWith("Pausable: paused");
            const tx02 = vault.connect(user2).depositWithReferral(depositAmount2, user2.address, referral2);
            await expect(tx02).to.be.revertedWith("Pausable: paused");
            await vault.unpause();
        });
        it("should not work with zero assets", async function () {
            const tx = vault.connect(user1).depositWithReferral(0, user1.address, referral1);
            await expect(tx).to.be.revertedWith("ZERO_AMOUNT");
        });
        it("should not work with zero address", async function () {
            const tx = vault.connect(user1).depositWithReferral(depositAmount1, ZERO_ADDRESS, referral1);
            await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
        });
    });

    describe("Redeem/withdraw", function () {
        it("non-share-owner should fail to redeem without approval", async function () {
            const tx = vault
                .connect(user2)
                .redeemWithReferral(depositAmount1.div(2), user1.address, user1.address, referral1);
            await expect(tx).to.be.revertedWith("ERC20: insufficient allowance");
        });
        it("should not work with insufficient referral", async function () {
            const tx = vault.connect(user1).redeemWithReferral(depositAmount1, user1.address, user1.address, referral2);
            await expect(tx).to.be.revertedWith("RevenueShareVault: insufficient shares by referral");
        });
        it("should be able to redeem partial", async function () {
            await vault
                .connect(user1)
                .redeemWithReferral(depositAmount1.div(2), user1.address, user1.address, referral1);
            expect(await vault.balanceOf(user1.address)).to.equal(
                depositAmount1.div(2)
            );
            expect(await mockERC20.balanceOf(user1.address)).to.equal(depositAmount1.div(2));
        });
        it("should be able to redeem remaining with referral", async function () {
            expect(await vault.totalSharesByReferral(referral1)).to.equal(
                depositAmount1.div(2)
            );
            await vault
                .connect(user1)
                .redeemWithReferral(depositAmount1.div(2), user1.address, user1.address, referral1);
            expect(await vault.balanceOf(user1.address)).to.equal(0);
            expect(await mockERC20.balanceOf(user1.address)).to.equal(depositAmount1);
            expect(await vault.totalSharesByReferral(referral1)).to.equal(0);

            await vault
                .connect(user2)
                .redeemWithReferral(depositAmount2, user2.address, user2.address, referral2);
            expect(await vault.balanceOf(user2.address)).to.equal(
                0
            );
            expect(await mockERC20.balanceOf(user2.address)).to.equal(depositAmount2);
        });
        /*
        it("should be able to withdraw partial", async function () {
            await vault
                .connect(user2)
                .withdraw(depositAmount2, user2.address, user2.address);
            expect(await vault.balanceOf(user2.address)).to.equal(
                0
            );
            expect(await mockERC20.balanceOf(user2.address)).to.equal(depositAmount2);
        });
        it("should be able to withdraw remaining with referral", async function () {
            expect(await vault.totalSharesByReferral(referral2)).to.equal(
                depositAmount2.div(2)
            );
            await vault
                .connect(user2)
                .withdrawWithReferral(depositAmount2.div(2), user2.address, user2.address, referral2);
            expect(await vault.balanceOf(user2.address)).to.equal(0);
            expect(await mockERC20.balanceOf(user2.address)).to.equal(depositAmount2);
            expect(await vault.totalSharesByReferral(referral2)).to.equal(0);
        });
        */
        it("should be pausable", async function () {
            await vault.pause();
            const tx01 = vault.connect(user2).redeemWithReferral(depositAmount2, user2.address, user2.address, referral2);
            await expect(tx01).to.be.revertedWith("Pausable: paused");
            await vault.unpause();
        });
        it("should not work with zero shares", async function () {
            const tx = vault.connect(user1).redeemWithReferral(0, user1.address, user1.address, referral1);
            await expect(tx).to.be.revertedWith("ZERO_SHARES");
        });
        it("should not work with insufficient shares", async function () {
            const tx = vault.connect(user1).redeemWithReferral(depositAmount1.mul(10), user1.address, user1.address, referral1);
            await expect(tx).to.be.revertedWith("RevenueShareVault: max redeem exceeded");
        });
    });

    describe("GeneralRevenueShare", function () {
        it("should be able to addRevenueShareReferral", async function () {
            const tx01 = await vault.addRevenueShareReferral(user1.address);
            expect(tx01)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(user1.address);
            const tx02 = await vault.addRevenueShareReferral(user2.address);
            expect(tx02)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(user2.address);
            const tx03 = await vault.addRevenueShareReferral(user3.address);
            expect(tx03)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(user3.address);
            expect((await vault.getRevenueShareReferralSet()).length).equal(3);
        });
        it("should be able to deposit with referral", async function () {
            await mockERC20.faucet(user3.address, depositAmount3);
            await mockERC20.connect(user3).approve(vault.address, depositAmount3);
            await vault
                .connect(user3)
                .depositWithReferral(depositAmount3, user3.address, referral3);
            expect(await vault.balanceOf(user3.address)).to.equal(depositAmount3);
            expect(await vault.totalSharesByReferral(referral3)).to.equal(
                depositAmount3
            );
        });
        it("should be able to deposit to revenue share", async function () {
            await mockERC20.faucet(user3.address, revenueShareAmount3);
            await mockERC20
                .connect(user3)
                .approve(vault.address, revenueShareAmount3);
            const tx01 = await vault
                .connect(user3)
                .depositToRevenueShare(
                    user3.address,
                    mockERC20.address,
                    revenueShareAmount3
                );
            expect(tx01)
                .to.emit(vault, "RevenueShareDeposited")
                .withArgs(user3.address, mockERC20.address, revenueShareAmount3);

            const totalSharesInReferral = await vault.totalSharesInReferral();
            const totalSharesByReferral = await vault.totalSharesByReferral(
                user3.address
            );
            const revenueShareBalanceByAssetReferral =
                await vault.revenueShareBalanceByAssetReferral(
                    mockERC20.address,
                    user3.address
                );
            expect(revenueShareBalanceByAssetReferral).equal(
                revenueShareAmount3
                    .mul(totalSharesByReferral)
                    .div(totalSharesInReferral)
            );
        });
        it("should be able to withdraw from revenue share", async function () {
            const user3assets0 = await mockERC20.balanceOf(user3.address);
            const revenueShareBalanceByAssetReferral01 =
                await vault.revenueShareBalanceByAssetReferral(
                    mockERC20.address,
                    user3.address
                );
            const tx01 = await vault
                .connect(user3)
                .withdrawFromRevenueShare(
                    mockERC20.address,
                    revenueShareBalanceByAssetReferral01,
                    user3.address
                );
            expect(tx01)
                .to.emit(vault, "RevenueShareWithdrawn")
                .withArgs(
                    mockERC20.address,
                    revenueShareBalanceByAssetReferral01,
                    user3.address,
                    user3.address
                );
            expect(
                await vault.revenueShareBalanceByAssetReferral(
                    mockERC20.address,
                    user3.address
                )
            ).equal(0);
            const user3assets1 = await mockERC20.balanceOf(user3.address);
            expect(user3assets1.sub(user3assets0)).equal(
                revenueShareBalanceByAssetReferral01
            );
            expect(
                await vault.totalRevenueShareProcessedByAsset(mockERC20.address)
            ).equal(revenueShareAmount3);
        });
        it("should be able to removeRevenueShareReferral", async function () {
            const tx01 = await vault.removeRevenueShareReferral(user3.address);
            expect(tx01)
                .to.emit(vault, "RevenueShareReferralRemoved")
                .withArgs(user3.address);
        });
        it("should not be able to removeRevenueShareReferral with non-existing referral", async function () {
            const tx = vault.removeRevenueShareReferral(user3.address);
            await expect(tx).to.be.revertedWith("GeneralRevenueShare: referral does not exist");
        });
        it("undistributed revenue share should be allocated to contract owner", async function () {
            await mockERC20.faucet(user3.address, revenueShareAmount3);
            await mockERC20
                .connect(user3)
                .approve(vault.address, revenueShareAmount3);
            const tx01 = await vault
                .connect(user3)
                .depositToRevenueShare(
                    user3.address,
                    mockERC20.address,
                    revenueShareAmount3
                );
            expect(tx01)
                .to.emit(vault, "RevenueShareDeposited")
                .withArgs(user3.address, mockERC20.address, revenueShareAmount3);

            const revenueShareBalanceByAssetReferral =
                await vault.revenueShareBalanceByAssetReferral(
                    mockERC20.address,
                    owner.address
                );
            expect(revenueShareBalanceByAssetReferral).equal(
                revenueShareAmount3
            );
        });
        it("should be able to addRevenueShareReferral again", async function () {
            const tx03 = await vault.addRevenueShareReferral(user3.address);
            expect(tx03)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(user3.address);
            expect((await vault.getRevenueShareReferralSet()).length).equal(3);
        });
        it("should not be able to addRevenueShareReferral with existing referral", async function () {
            const tx = vault.addRevenueShareReferral(user3.address);
            await expect(tx).to.be.revertedWith("GeneralRevenueShare: referral already exists");
        });
    });

    describe("GeneralYieldSourceAdapter", function () {
        it("getYieldSourceVaultTotalShares should return the correct value", async function () {
            expect(await vault.getYieldSourceVaultTotalShares()).equal(
                depositAmount3
            );
        });
        it("sharePriceOfYieldSource should return the correct value", async function () {
            expect(await vault.sharePriceOfYieldSource()).equal(
                1
            );
        });
    });

    describe("Pause/unpause", function () {
        it("only owner can pause", async function () {
            const tx = vault.connect(user1).pause();
            await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("should be able to pause", async function () {
            const tx = await vault.connect(owner).pause();
            expect(tx)
                .to.emit(vault, "Paused")
                .withArgs(owner.address);
        });
        it("whenNotPaused function should not work when paused", async function () {
            const tx = vault
                .connect(user3)
                .depositToRevenueShare(
                    user3.address,
                    mockERC20.address,
                    revenueShareAmount3
                );
            await expect(tx).to.be.revertedWith("Pausable: paused");
        });
        it("only owner can unpause", async function () {
            const tx = vault.connect(user1).unpause();
            await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("should be able to unpause", async function () {
            const tx = await vault.connect(owner).unpause();
            expect(tx)
                .to.emit(vault, "Unpaused")
                .withArgs(owner.address);
        });
    });

    describe("DepositPausableUpgradeable", function () {
        it("only owner can pause deposit", async function () {
            const tx = vault.connect(user1).pauseDeposit();
            await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("should be able to pause deposit", async function () {
            const tx = await vault.connect(owner).pauseDeposit();
            expect(tx)
                .to.emit(vault, "DepositPaused")
                .withArgs(owner.address);
        });
        it("pauseDeposit should not work when already paused", async function () {
            const tx = vault.connect(owner).pauseDeposit();
            await expect(tx).to.be.revertedWith("DepositPausable: paused");
        });
        it("whenDepositNotPaused function should not work when paused", async function () {
            const tx = vault
                .connect(user3)
                .depositWithReferral(
                    depositAmount3,
                    user3.address,
                    referral3
                );
            await expect(tx).to.be.revertedWith("DepositPausable: paused");
        });
        it("only owner can unpause deposit", async function () {
            const tx = vault.connect(user1).unpauseDeposit();
            await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("should be able to unpause deposit", async function () {
            const tx = await vault.connect(owner).unpauseDeposit();
            expect(tx)
                .to.emit(vault, "DepositUnpaused")
                .withArgs(owner.address);
        });
        it("unpauseDeposit should not work when already unpaused", async function () {
            const tx = vault.connect(owner).unpauseDeposit();
            await expect(tx).to.be.revertedWith("DepositPausable: unpaused");
        });
    });

    describe("CinchPerformanceFee", function () {
        it("setCinchPerformanceFeePercentage should update the value correctly", async function () {
            const tx = await vault.setCinchPerformanceFeePercentage(
                cinchPerformanceFeePercentage10
            );
            expect(tx)
                .to.emit(vault, "CinchPerformanceFeePercentageUpdated")
                .withArgs(cinchPerformanceFeePercentage10);
        });
        it("should extract the Cinch performance fee correctly", async function () {
            const revenueShareBalanceByAssetReferral0 =
                await vault.revenueShareBalanceByAssetReferral(
                    mockERC20.address,
                    owner.address
                );
            await mockERC20.faucet(user3.address, revenueShareAmount3);
            await mockERC20
                .connect(user3)
                .approve(vault.address, revenueShareAmount3);
            const tx01 = await vault
                .connect(user3)
                .depositToRevenueShare(
                    user3.address,
                    mockERC20.address,
                    revenueShareAmount3
                );
            expect(tx01)
                .to.emit(vault, "RevenueShareDeposited")
                .withArgs(user3.address, mockERC20.address, revenueShareAmount3);

            const revenueShareBalanceByAssetReferral1 =
                await vault.revenueShareBalanceByAssetReferral(
                    mockERC20.address,
                    owner.address
                );
            expect(revenueShareBalanceByAssetReferral1 - revenueShareBalanceByAssetReferral0).equal(
                revenueShareAmount3
                    .mul(cinchPerformanceFeePercentage10)
                    .div(cinchPerformanceFeePercentage100)
            );
        });
    });

    describe("Fixing data by contract owner", function () {
        it("setTotalSharesByReferral onlyOwner", async function () {
            const tx = vault.connect(user3).setTotalSharesByReferral(
                referral3,
                depositAmount3
            );
            await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("setTotalSharesInReferral onlyOwner", async function () {
            const tx = vault.connect(user3).setTotalSharesInReferral(
                depositAmount3
            );
            await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("should be able to setTotalSharesByReferral", async function () {
            const tx01 = await vault.connect(owner).setTotalSharesByReferral(
                referral3,
                depositAmount3.mul(2)
            );
            expect(tx01)
                .to.emit(vault, "TotalSharesByReferralUpdated")
                .withArgs(referral3, depositAmount3.mul(2));
            expect(await vault.totalSharesByReferral(referral3)).equal(depositAmount3.mul(2));

            const tx02 = await vault.connect(owner).setTotalSharesByReferral(
                referral3,
                depositAmount3
            );
            expect(tx02)
                .to.emit(vault, "TotalSharesByReferralUpdated")
                .withArgs(referral3, depositAmount3);
            expect(await vault.totalSharesByReferral(referral3)).equal(depositAmount3);
        });
        it("should be able to setTotalSharesInReferral", async function () {
            const tx01 = await vault.connect(owner).setTotalSharesInReferral(
                depositAmount3.mul(2)
            );
            expect(tx01)
                .to.emit(vault, "TotalSharesInReferralUpdated")
                .withArgs(depositAmount3.mul(2));
            expect(await vault.totalSharesInReferral()).equal(depositAmount3.mul(2));

            const tx02 = await vault.connect(owner).setTotalSharesInReferral(
                depositAmount3
            );
            expect(tx02)
                .to.emit(vault, "TotalSharesInReferralUpdated")
                .withArgs(depositAmount3);
            expect(await vault.totalSharesInReferral()).equal(depositAmount3);
        });
    });

    describe("GeneralRevenueShareLogic", function () {
        describe("addRevenueShareReferral", function () {
            it("onlyOwner", async function () {
                const tx = vault.connect(user3).addRevenueShareReferral(
                    ZERO_ADDRESS
                );
                await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
            });
            it("should be reverted with zero address referral", async function () {
                const tx = vault.addRevenueShareReferral(
                    ZERO_ADDRESS
                );
                await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
            });
        });
        describe("removeRevenueShareReferral", function () {
            it("onlyOwner", async function () {
                const tx = vault.connect(user3).removeRevenueShareReferral(
                    ZERO_ADDRESS
                );
                await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
            });
            it("should be reverted with zero address referral", async function () {
                const tx = vault.removeRevenueShareReferral(
                    ZERO_ADDRESS
                );
                await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
            });
        });
        describe("depositToRevenueShare", function () {
            it("should be reverted with zero address assetsFrom_", async function () {
                const tx = vault.depositToRevenueShare(
                    ZERO_ADDRESS,
                    user3.address,
                    revenueShareAmount3
                );
                await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
            });
            it("should be reverted with zero amount_", async function () {
                const tx = vault.depositToRevenueShare(
                    user3.address,
                    user3.address,
                    ZERO_ADDRESS
                );
                await expect(tx).to.be.revertedWith("ZERO_AMOUNT");
            });
            it("should be pausable", async function () {
                const tx01 = await vault.connect(owner).pause();
                const tx02 = vault
                    .connect(user3)
                    .depositToRevenueShare(
                        user3.address,
                        mockERC20.address,
                        revenueShareAmount3
                    );
                await expect(tx02).to.be.revertedWith("Pausable: paused");
                const tx03 = await vault.connect(owner).unpause();
            });
        });
        describe("withdrawFromRevenueShare", function () {
            it("should be reverted with zero address asset_", async function () {
                const tx = vault.withdrawFromRevenueShare(
                    ZERO_ADDRESS,
                    revenueShareAmount3,
                    user3.address
                );
                await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
            });
            it("should be reverted with zero amount_", async function () {
                const tx = vault.withdrawFromRevenueShare(
                    user3.address,
                    ZERO_ADDRESS,
                    user3.address
                );
                await expect(tx).to.be.revertedWith("ZERO_AMOUNT");
            });
            it("should be reverted with zero address receiver_", async function () {
                const tx = vault.withdrawFromRevenueShare(
                    user3.address,
                    revenueShareAmount3,
                    ZERO_ADDRESS
                );
                await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
            });
            it("should be reverted with insufficient shares balance", async function () {
                const tx = vault
                    .connect(user3)
                    .withdrawFromRevenueShare(
                        mockERC20.address,
                        ethers.utils.parseUnits("100000", 18),
                        user3.address
                    );
                await expect(tx).to.be.revertedWith("GeneralRevenueShareLogic: insufficient shares balance");
            });
            it("should be pausable", async function () {
                const tx01 = await vault.connect(owner).pause();
                const tx02 = vault
                    .connect(user3)
                    .withdrawFromRevenueShare(
                        mockERC20.address,
                        ethers.utils.parseUnits("100000", 18),
                        user3.address
                    );
                await expect(tx02).to.be.revertedWith("Pausable: paused");
                const tx03 = await vault.connect(owner).unpause();
            });
        });
        describe("setCinchPerformanceFeePercentage", function () {
            it("onlyOwner", async function () {
                const tx = vault.connect(user3).setCinchPerformanceFeePercentage(
                    ethers.utils.parseUnits("1000000", 2)
                );
                await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
            });
            it("should be reverted with invalid feePercentage_", async function () {
                const tx = vault.setCinchPerformanceFeePercentage(
                    ethers.utils.parseUnits("1000000", 2)
                );
                await expect(tx).to.be.revertedWith("GeneralRevenueShare: invalid fee percentage");
            });
        });
    });

    describe("Mock Attacker", function () {
        it("Should deploy MockAttackerERC20", async function () {
            const MockAttackerERC20 = await ethers.getContractFactory("MockAttackerERC20");
            mockAttackerERC20 = await MockAttackerERC20.deploy();
            expect(mockAttackerERC20.address).to.not.be.undefined;
        });
        it("Should deploy MockAttacker", async function () {
            const MockAttacker = await ethers.getContractFactory("MockAttacker", owner);
            mockAttacker = await upgrades.deployProxy(MockAttacker, [
                mockAttackerERC20.address,
                "MockAttackerCinchRevenueShare",
                "ACRS",
                mockProtocol.address,
                mockSwapperAddress,
                initCinchPerformanceFeePercentage,
            ]);
            expect(mockAttacker.address).to.not.be.undefined;
        });
        it("should not be able to re-initialize", async function () {
            const tx01 = mockAttacker.reInitGeneralRevenueShareLogic();
            await expect(tx01).to.be.revertedWith("Initializable: contract is not initializing");

            const tx02 = mockAttacker.reInitGeneralRevenueShareLogicUnChained();
            await expect(tx02).to.be.revertedWith("Initializable: contract is not initializing");

            const tx03 = mockAttacker.reInitGeneralYieldSourceAdapter();
            await expect(tx03).to.be.revertedWith("Initializable: contract is not initializing");

            const tx04 = mockAttacker.reInitGeneralYieldSourceAdapterUnChained();
            await expect(tx04).to.be.revertedWith("Initializable: contract is not initializing");

            const tx05 = mockAttacker.reInitDepositPausable();
            await expect(tx05).to.be.revertedWith("Initializable: contract is not initializing");

            const tx06 = mockAttacker.reInitDepositPausableUnChained();
            await expect(tx06).to.be.revertedWith("Initializable: contract is not initializing");
        });
        it("should not be able to reentrant", async function () {
            await mockAttackerERC20.faucet(user3.address, depositAmount3);
            await mockAttackerERC20.connect(user3).approve(mockAttacker.address, depositAmount3);
            const tx01 = mockAttacker
                .connect(user3)
                .depositWithReferral(depositAmount3, user3.address, referral3);
            await expect(tx01).to.be.revertedWith("ReentrancyGuard: reentrant call");

            await mockAttacker.forceFakeDepositState(depositAmount3, user3.address, referral3);
            const tx02 = mockAttacker
                .connect(user3)
                .redeemWithReferral(depositAmount3, user3.address, user3.address, referral3);
            await expect(tx02).to.be.revertedWith("ReentrancyGuard: reentrant call");
        });
    });
});