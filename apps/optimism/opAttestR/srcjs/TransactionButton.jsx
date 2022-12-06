import { ethers } from "ethers";
import { useState, useEffect, useMemo } from "react";
import { usePrepareContractWrite, useContractWrite } from "wagmi"
import { transformArguments } from "./TransformArguments.jsx";
  
const TransactionButton = ({ configuration, value, setValue }) => {
    const [ response, setResponse ] = useState(null);
    const [ signature, setSignature ] = useState(null);

    // Check if the transaction is enabled
    const enabled = useMemo(() => {
        return configuration.enabled ?? true;
    }, [configuration.enabled])

    // Make abi ethers friendly
    const abi = new ethers.utils.Interface(configuration.contract_abi)
    
    // Getting the method from the abi
    const abiMethod = useMemo(() => {
        return abi?.fragments?.find((m) => m.name === configuration.contract_method)
    }, [abi, configuration.contract_method])

    // Cleaning the arguments to match the method signature
    const writeArguments = useMemo(() => {
        if (!configuration.enabled) return configuration.args;
        return transformArguments(configuration.args, abiMethod)
    }, [abiMethod, configuration.args])

    // Prepare the contract write (estimate gas, get nonce, etc.)
    const { config, isSuccess } = usePrepareContractWrite({
        address: configuration.contract_address,
        abi: abi,
        functionName: configuration.contract_method,
        args: writeArguments,
        enabled: enabled,
        onError(error) {
            console.error('error: ', error);
            setResponse({status: 'error', data: error});
        }
    })

    // Use the prepared contract write
    const { data: writeData, writeAsync } = useContractWrite({
        ...config,
    });

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
            setResponse({status: 'error', data: e?.reason || e?.message || e?.reason || e});
        }
    }

    // Validate that all arguments are present
    useEffect(() => {
        function validateArguments() {
            if (!configuration.contract_address) {
                return "Contract Address"
            }
            if (!configuration.contract_abi) {
                return "Contract ABI"
            }
            if (!configuration.contract_method) {
                return "Contract Method"
            }
        }

        const error = validateArguments();
        if (error) {
            console.error(`opAttestR TransactionHandler: Missing configuration -- ${error}}`);
        }
    }, [configuration])

    return (
        <>
            <button
                disabled={!isSuccess || !enabled}
                onClick={() => onContractWrite()}
            >
                {configuration.label}
            </button>

            {response?.status &&
                <p>{`Transaction ${response.status}! (${JSON.stringify(response?.data)})`}</p>
            }
        </>
    )
}

export default TransactionButton;