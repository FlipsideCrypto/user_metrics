import { ethers } from "ethers";

export const transformArguments = (args, abiMethod) => {
    if (!abiMethod) {
        return args;
    }
    
    args = toArray(args);

    if (args.length !== abiMethod.inputs.length) {
        console.error("Invalid number of arguments");
        return;
    }

    let transformedArgs = [];
    // for each argument in args check if it matches the type in the abi
    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        const type = abiMethod.inputs[i].type;

        if (type === "array") {
            transformedArgs.push(toArray(arg));
        }
        if (type === "address") {
            transformedArgs.push(toAddress(arg));
        }
        if (type === "bytes32") {
            transformedArgs.push(toBytes32(arg));
        }
        if (type === "bytes" && typeof(arg) === "string") {
            transformedArgs.push(stringToBytes(arg));
        }
    }

    return transformedArgs;
}

export const toArray = (value) => {
    if (typeof(value) !== "array") {
        return [value];
    }
    return value;
}

export const toAddress = (value) => {
    let transformed;
    try {
        transformed = ethers.utils.getAddress(value);
    } catch (e) {
        console.error("Invalid address: " + value, ' error: ', e);
    }

    return transformed;
}

export const toBytes32 = (value) => {
    let transformed;
    try {
        transformed = ethers.utils.formatBytes32String(value);
    } catch (e) {
        console.error("Invalid bytes32: " + value, ' error: ', e);
    }

    return transformed;
}

export const intToBytes = (value) => {
    let transformed;
    try {
        const arr = toArray(parseInt(value))
        transformed = ethers.utils.hexlify(arr);
    } catch (e) {
        console.error("Invalid bytes: " + value, ' error: ', e);
    }

    return transformed
}

export const stringToBytes = (value) => {
    let transformed;
    try {
        transformed = ethers.utils.hexlify([parseInt(value)]);
    } catch (e) {
        console.error("Invalid bytes: " + value, ' error: ', e);
    }

    return transformed
}