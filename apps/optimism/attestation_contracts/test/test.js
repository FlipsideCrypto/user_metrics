const { assert } = require('chai')

var chai = require('chai')
    .use(require('chai-as-promised'))
    .should()

const { ethers } = require("hardhat");

describe("FlipsideAttestation", function () {
    before(async () => {
        [owner, signer1, userSigner, flipside, sigSigner] = await ethers.getSigners();

        const MockOPAttestation = await ethers.getContractFactory("AttestationStation");
        mockOPAttestation = await MockOPAttestation.deploy();
        await mockOPAttestation.deployed();

        const FlipsideAttestation = await ethers.getContractFactory("FlipsideAttestation");
        flipAtt = await FlipsideAttestation.deploy(
            sigSigner.address,
            mockOPAttestation.address,
        );
        await flipAtt.deployed();

        console.table({
            "Owner": owner.address,
            "SigSigner": sigSigner.address,
            "MockOP": mockOPAttestation.address,
            "FlipsideAttestation": flipAtt.address,
        })
    });

    it("FlipsideAttestation: Invalid signature", async() => {
        const flipsideUserScoring = ethers.utils.formatBytes32String("flipside_user_score");
        const userScore = ethers.utils.hexlify([5])

        await flipAtt.connect(userSigner).attest(
            userSigner.address,
            flipsideUserScoring,
            userScore,
            "0x0000000000000000000000000000000000000000000000000000000000000000",

        ).should.be.rejectedWith("FlipsideAttestation: Invalid signature");
    })

    it("FlipsideAttestation: attest() success", async () => {
        const flipsideUserScoring = ethers.utils.formatBytes32String("flipside_user_score");
        const userScore = 5;
        const userScoreBytes = ethers.utils.hexlify([userScore])

        const messageHash = ethers.utils.solidityKeccak256(
            ["address", "bytes32", "bytes"],
            [
                userSigner.address,
                flipsideUserScoring,
                userScoreBytes,
            ]
        )

        const signature = await sigSigner.signMessage(ethers.utils.arrayify(messageHash))

        let tx = await flipAtt.connect(userSigner).attest(
            userSigner.address,
            flipsideUserScoring,
            userScoreBytes,
            signature
        )
        tx = await tx.wait()

        const result = await mockOPAttestation.connect(userSigner).attestations(
            flipAtt.address,
            userSigner.address,
            flipsideUserScoring
        )

        assert.equal(parseInt(result), userScore)
    });
})
