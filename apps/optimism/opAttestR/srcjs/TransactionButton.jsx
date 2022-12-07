import { ethers } from "ethers";
import { useState, useEffect, useMemo } from "react";
import { usePrepareContractWrite, useContractWrite } from "wagmi"
  
const TransactionButton = ({ configuration }) => {
    const [ response, setResponse ] = useState(null);
    const [ formattedArgs, setFormattedArgs ] = useState(null);
    const [ signature, setSignature ] = useState(null);

    // Check if the transaction is enabled
    const txEnabled = useMemo(() => {
        return configuration.enabled ?? true;
    }, [configuration.enabled])

    // Make abi ethers friendly
    const RPCprovider = new ethers.providers.JsonRpcProvider(
        configuration.provider, 
        { 
            name: "flipside", 
            chainId: configuration.chainId 
        }
    )
    const wallet = new ethers.Wallet(process.env.SIGNER_PRIVATE_KEY, RPCprovider);
    const abi = new ethers.utils.Interface(configuration.contract_abi);

    // Prepare the contract write (estimate gas, get nonce, etc.)
    const { config, isSuccess } = usePrepareContractWrite({
        address: configuration.contract_address,
        abi: abi,
        functionName: configuration.contract_method,
        args: formattedArgs ? 
            [...formattedArgs, signature] : [...configuration.args, "0x"],
        enabled: Boolean(
            formattedArgs?.length === configuration.args.length 
            && signature 
            && txEnabled
        ),
        onError(error) {
            console.error('error: ', error);
            setResponse({status: 'error', data: error});
        }
    })

    // Use the prepared contract write
    const { data: writeData, writeAsync } = useContractWrite({
        ...config,
    });

    const formatArguments = (userAddress, flipsideKey, score) => {
        try {
            userAddress = ethers.utils.getAddress(userAddress);
            flipsideKey = ethers.utils.formatBytes32String(flipsideKey);
            score = ethers.utils.hexlify([parseInt(score)]);
        } catch (e) {
            console.error('Write arguments are invalid: ', e)
            setResponse({status: 'error', data: e});
        }

        const arr = [userAddress, flipsideKey, score];

        console.log('Flipside Attestation Key: ', flipsideKey)
        setFormattedArgs(arr);
        return arr;
    }

    // Signs the attest message with arguments of [user]
    const signMessage = async (userAddress, flipsideKey, score) => {
        const signArguments = formatArguments(userAddress, flipsideKey, score);
        if (!signArguments) return;

        const messageHash = ethers.utils.solidityKeccak256(
            ["address", "bytes32", "bytes"],
            signArguments
        )

        const signature = await wallet.signMessage(ethers.utils.arrayify(messageHash))

        return signature;
    }

    // Handle contract write event
    const onContractWrite = async () => {
        try {
            const tx = await writeAsync?.();
            const txReceipt = await tx.wait();
            if (txReceipt.status !== 1) {
                throw new Error('Transaction failed: ' + writeData);
            }
            setResponse({status: 'success', data: "Hash: " + txReceipt.transactionHash})
        } catch (e) {
            e = JSON.parse(e);
            setResponse({status: 'error', data: e?.reason || e?.message || e?.reason || e});
        }
    }

    // Sign the data as we get it.
    useEffect(() => {
        if (!configuration.args?.[0] || !configuration.args?.[1] || !configuration.args?.[2]) return;

        signMessage(configuration.args[0], configuration.args[1], configuration.args[2])
            .then((signature) => {
                setSignature(signature);
            })
            .catch((e) => {
                console.error('Error signing message: ', e);
            })
    }, [configuration.args])

    return (
        <>
            <button
                disabled={!isSuccess || !txEnabled}
                onClick={() => onContractWrite()}
            >
                {configuration.label}
            </button>

            {response?.status &&
                <p>{`Transaction ${response.status}! (${response?.data})`}</p>
            }
        </>
    )
}

export default TransactionButton;