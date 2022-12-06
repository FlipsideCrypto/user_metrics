import { useState, useEffect } from "react";
import { ethers } from "ethers";
import { reactShinyInput } from "reactR";


// TODO: This is not currently dynamic and only serves for the OP attestation contract
// messageArguments = [userAddress, flipsideUserScoring, userScoreBytes]
// private key of the signer wallet and the provider endpoint including API key are required from R.

export const SignMessageBackend = ({ configuration }) => {
    const { privateKey, provider, messageArguments } = configuration;
    const [ signature, setSignature ] = useState("")
    console.log('privateKey', configuration.privateKey, 'provider', configuration.provider, 'messageArguments', configuration.messageArguments)

    const RPCprovider = new ethers.providers.JsonRpcProvider(provider, { name: "flipside", chainId: configuration.chainId })
    const wallet = new ethers.Wallet(privateKey, RPCprovider);

    useEffect(() => {
        async function getSignature() {
            const userAddress = messageArguments[0];
            const flipsideUserScoring = ethers.utils.formatBytes32String(messageArguments[1]);
            const userScoreBytes = ethers.utils.hexlify([parseInt(messageArguments[2])]);

            if (!userAddress || !flipsideUserScoring || !userScoreBytes) {
                return;
            }

            const messageHash = ethers.utils.solidityKeccak256(
                ["address", "bytes32", "bytes"],
                [
                    userAddress,
                    flipsideUserScoring,
                    userScoreBytes,
                ]
            )

            const signature = await wallet.signMessage(ethers.utils.arrayify(messageHash))
            console.log('signature', signature)
            setSignature(signature)
        }

        getSignature();
    }, [configuration])

    return (
        <p>
            {`signature: ${signature}`}
        </p>
    )
}

export default function initSignMessageBackend() {
    reactShinyInput(
      '.SignMessageBackend', 
      'opAttestR.SignMessageBackend', 
      SignMessageBackend
    );
 }