const { expect } = require("chai");
const { upgrades } = require("hardhat");

let accounts;
let owner, user1, user2, user3;
let mockERC20, mockProtocol, vault;
let mockERC20Decimals = 6;
let referral1, referral2, referral3;

const depositAmount1 = ethers.utils.parseUnits("1000", mockERC20Decimals);
const depositAmount2 = ethers.utils.parseUnits("1000", mockERC20Decimals);
const depositAmount3 = ethers.utils.parseUnits("1000", mockERC20Decimals);
const depositShare1 = ethers.utils.parseUnits("1100", mockERC20Decimals);
const depositShare2 = ethers.utils.parseUnits("1100", mockERC20Decimals);
const depositShare3 = ethers.utils.parseUnits("1100", mockERC20Decimals);
const revenueShareAmount3 = ethers.utils.parseUnits("100", mockERC20Decimals);
const initCinchPerformanceFeePercentage = ethers.utils.parseUnits("0", 2);
const cinchPerformanceFeePercentage10 = ethers.utils.parseUnits("10", 2);
const cinchPerformanceFeePercentage100 = ethers.utils.parseUnits("100", 2);
const ZERO_ADDRESS = ethers.constants.AddressZero;

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

describe("RevenueShareVaultRibbonEarn", function () {
    describe("Deployment", function () {
        it("Should deploy MockERC20", async function () {
            const MockERC20 = await ethers.getContractFactory("MockERC20");
            mockERC20 = await MockERC20.deploy();
            mockERC20Decimals = await mockERC20.decimals();
            expect(mockERC20.address).to.not.be.undefined;
            expect(mockERC20Decimals).equal(6);
            console.log("mockERC20", mockERC20.address);
        });
        it("Should deploy MockProtocolRibbonEarn", async function () {
            const MockProtocol = await ethers.getContractFactory("MockProtocolRibbonEarn");
            mockProtocol = await MockProtocol.deploy(mockERC20.address);
            expect(mockProtocol.address).to.not.be.undefined;
            expect(await mockProtocol.convertToShares(depositAmount1)).equal(depositShare1);
            console.log("mockProtocol", mockProtocol.address);
        });
        it("Should deploy and Initialize RevenueShareVaultRibbonEarn", async function () {
            const Vault = await ethers.getContractFactory("RevenueShareVaultRibbonEarn", owner);
            vault = await upgrades.deployProxy(Vault, [
                mockERC20.address,
                "CinchRevenueShare",
                "CRS",
                mockProtocol.address,
                initCinchPerformanceFeePercentage,
            ]);
            expect(vault.address).to.not.be.undefined;
            console.log("vault", vault.address);
        });
        it("Should not be able to re-initialize RevenueShareVaultRibbonEarn", async function () {
            const tx = vault.initialize(mockERC20.address, "CinchRevenueShare", "CRS", mockProtocol.address, initCinchPerformanceFeePercentage);
            await expect(tx).to.be.revertedWith("Initializable: contract is already initialized");
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
        it("should fail if receiver is not sender", async function () {
            const tx = vault
                .connect(user1)
                .depositWithReferral(depositAmount1, user2.address, referral2);
            await expect(tx).to.be.revertedWith("RevenueShareVaultRibbonEarn: sender must be receiver");
        });
        it("should be able to deposit with referral", async function () {
            await vault.connect(user1).depositWithReferral(depositAmount1, user1.address, referral1);
            expect(await vault.balanceOf(user1.address)).to.equal(depositShare1);
            expect(await vault.totalSharesByReferral(referral1)).to.equal(
                depositShare1
            );
            expect(await vault.shareBalanceAtYieldSourceOf(user1.address)).to.equal(depositShare1);

            expect(await vault.totalSharesByReferral(referral2)).equal(0);
            await mockERC20.faucet(user2.address, depositAmount2);
            await mockERC20.connect(user2).approve(vault.address, depositAmount2);
            await vault
                .connect(user2)
                .depositWithReferral(depositAmount2, user2.address, referral2);
            expect(await vault.balanceOf(user2.address)).to.equal(depositShare2);
            expect(await vault.totalSharesByReferral(referral2)).to.equal(
                depositShare2
            );
        });
        it("should be pausable", async function () {
            await vault.pause();
            const tx01 = vault.connect(user1).depositWithReferral(depositAmount1, user1.address, referral1);
            await expect(tx01).to.be.revertedWith("Pausable: paused");
            const tx02 = vault.connect(user2).depositWithReferral(depositAmount2, user2.address, referral2);
            await expect(tx02).to.be.revertedWith("Pausable: paused");
            await vault.unpause();
        });
        it("should not work with zero amount", async function () {
            const tx = vault.connect(user1).depositWithReferral(0, user1.address, referral1);
            await expect(tx).to.be.revertedWith("ZERO_AMOUNT");
        });
        it("should not work with zero address", async function () {
            const tx = vault.connect(user1).depositWithReferral(depositAmount1, ZERO_ADDRESS, referral1);
            await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
        });
        it("should not work with deposit higher than max", async function () {
            const tx = vault.connect(user1).depositWithReferral(ethers.constants.MaxUint256, user1.address, referral1);
            await expect(tx).to.be.revertedWith("RevenueShareVault: max deposit exceeded");
        });
    });

    describe("Redeem/withdraw", function () {
        it("should not be able to call redeemWithReferral", async function () {
            const tx = vault.connect(user1).redeemWithReferral(depositShare1, user1.address, user1.address, referral1);
            await expect(tx).to.be.revertedWith("RevenueShareVaultRibbonEarn: not supported");
        });
        it("should be able to addRevenueShareReferral", async function () {
            const tx01 = await vault.addRevenueShareReferral(referral1);
            expect(tx01)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(referral1);
            const tx02 = await vault.addRevenueShareReferral(referral2);
            expect(tx02)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(referral2);
            expect(await vault.isReferralRegistered(referral1)).to.equal(true);
            expect(await vault.isReferralRegistered(referral2)).to.equal(true);
        });
        it("should be able to redeem from yield source directly", async function () {
            await mockProtocol.connect(user1).redeem(depositShare1, user1.address, user1.address);
            expect(await mockERC20.balanceOf(user1.address)).to.equal(depositAmount1);
            await vault.connect(owner).setTotalSharesInReferralAccordingToYieldSource(referral1, user1.address);
            expect(await vault.totalSharesByReferral(referral1)).to.equal(0);

            await mockProtocol.connect(user2).redeem(depositShare2, user2.address, user2.address);
            expect(await mockERC20.balanceOf(user2.address)).to.equal(depositAmount2);
            await vault.connect(owner).setTotalSharesInReferralAccordingToYieldSource(referral2, user2.address);
            expect(await vault.totalSharesByReferral(referral2)).to.equal(0);
        });
    });

    describe("GeneralRevenueShare", function () {
        it("should be able to addRevenueShareReferral", async function () {
            const tx03 = await vault.addRevenueShareReferral(referral3);
            expect(tx03)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(referral3);
            expect(await vault.isReferralRegistered(referral3)).to.equal(true);
        });
        it("should be able to deposit with referral", async function () {
            await mockERC20.faucet(user3.address, depositAmount3);
            await mockERC20.connect(user3).approve(vault.address, depositAmount3);
            await vault
                .connect(user3)
                .depositWithReferral(depositAmount3, user3.address, referral3);
            expect(await vault.balanceOf(user3.address)).to.equal(depositShare3);
            expect(await vault.totalSharesByReferral(referral3)).to.equal(
                depositShare3
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
            const tx01 = await vault.removeRevenueShareReferral(referral3);
            expect(tx01)
                .to.emit(vault, "RevenueShareReferralRemoved")
                .withArgs(referral3);
            expect(await vault.isReferralRegistered(referral3)).to.equal(false);
        });
        it("undistributed revenue share should be allocated to contract owner", async function () {
            await mockERC20.faucet(user3.address, revenueShareAmount3);
            await mockERC20
                .connect(user3)
                .approve(vault.address, revenueShareAmount3);
            const tx01 = await vault
                .connect(user3)
                .depositToRevenueShare(
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
            const tx03 = await vault.addRevenueShareReferral(referral3);
            expect(tx03)
                .to.emit(vault, "RevenueShareReferralAdded")
                .withArgs(referral3);
            expect(await vault.isReferralRegistered(referral3)).to.equal(true);
        });
    });

    describe("GeneralYieldSourceAdapter", function () {
        it("getYieldSourceVaultTotalShares should return the correct value", async function () {
            expect(await vault.getYieldSourceVaultTotalShares()).equal(
                depositShare3
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
                    mockERC20.address,
                    revenueShareAmount3
                );
            await expect(tx).to.be.revertedWith("Pausable: paused");

            const tx02 = vault
                .connect(user3)
                .depositWithReferral(
                    depositAmount3,
                    user3.address,
                    referral3,
                );
            await expect(tx02).to.be.revertedWith("Pausable: paused");
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
        it("should be able to unpause deposit", async function () {
            const tx = await vault.connect(owner).unpauseDeposit();
            expect(tx)
                .to.emit(vault, "DepositUnpaused")
                .withArgs(owner.address);
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

    describe("setTotalSharesInReferralAccordingToYieldSource", function () {
        it("onlyOwner", async function () {
            const tx = vault.connect(user1).setTotalSharesInReferralAccordingToYieldSource(referral1, user1.address);
            await expect(tx).to.be.revertedWith("Ownable: caller is not the owner");
        });
        it("should not work with zero address", async function () {
            const tx = vault.connect(owner).setTotalSharesInReferralAccordingToYieldSource(referral1, ZERO_ADDRESS);
            await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
        });
        it("should not work with zero address", async function () {
            const tx = vault.connect(owner).setTotalSharesInReferralAccordingToYieldSource(ZERO_ADDRESS, user1.address);
            await expect(tx).to.be.revertedWith("ZERO_ADDRESS");
        });
        it("setTotalSharesInReferralAccordingToYieldSource should work", async function () {
            await mockERC20.faucet(user1.address, depositAmount1);
            await mockERC20.connect(user1).approve(mockProtocol.address, depositAmount1);
            await mockProtocol.connect(user1).depositFor(depositAmount1, user1.address);
            await vault.connect(owner).setTotalSharesInReferralAccordingToYieldSource(referral1, user1.address);
            expect(await vault.connect(owner).totalSharesByUserReferral(referral1, user1.address)).equal(depositShare1);
        });
    });
});