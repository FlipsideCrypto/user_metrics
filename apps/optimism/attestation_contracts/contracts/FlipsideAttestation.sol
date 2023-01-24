// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IAttestationStation } from "./AttestationStation/IAttestationStation.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract FlipsideAttestation {
    using ECDSA for bytes32;

    /// @dev The address used to sign attestations and manage the contract.
    address public signer;

    /// @dev The interface for OP's Attestation Station.
    IAttestationStation public attestationStation;

    constructor(
          address _signer
        , address _attestationStation
    ) {
        signer = _signer;
        attestationStation = IAttestationStation(_attestationStation);
    }

    /**
     * @notice Allows the signer to change the AttestationStation implementation.
     * @param _attestationStation The address of the new AttestationStation implementation.
     * 
     * Requirements:
     * - The caller must be the current signer.
     */
    function setAttestationStation(address _attestationStation) public {
        require(msg.sender == signer, "FlipsideAttestation: Only signer can set OP AttestationStation");
        attestationStation = IAttestationStation(_attestationStation);
    }

    /**
     * @notice Allows the signer to transfer signer privilege to another address.
     * @param _signer The address of the new signer.
     * 
     * Requirements:
     * - The caller must be the current signer.
     */
    function setSigner(address _signer) public {
        require(msg.sender == signer, "FlipsideAttestation: Only signer can change signer");
        signer = _signer;
    }

    /**
     * @notice Verifies the attestation data before calling the OP AttestationStation attest.
     * @param _about The address of the account to be attested.
     * @param _key The key of the attestation.
     * @param _val The value of the attestation.
     * @param _signature The signature of the attestation.
     * 
     */
    function attest(
          address _about
        , bytes32 _key
        , bytes memory _val
        , bytes memory _signature
    ) 
        public
    {
        _verifySignature(
              _about
            , _key
            , _val
            , _signature
        );

        // Send the attestation to the Attestation Station.
        IAttestationStation.AttestationData[] memory attestations = new IAttestationStation.AttestationData[](1);
        attestations[0] = IAttestationStation.AttestationData({
              about: _about
            , key: _key
            , val: _val
        });
        attestationStation.attest(attestations);
    }

    /**
     * @notice Verify that an attestation is signed by the correct signer.
     * @param _about The address of the account to be attested.
     * @param _key The key of the attestation.
     * @param _val The value of the attestation.
     * @param _signature The signer's signed message of the attestation.
     * 
     * Requirements:
     * - The signature must resolve to the signer.
     */
    function _verifySignature(
          address _about
        , bytes32 _key
        , bytes memory _val
        , bytes memory _signature
    )
        internal
        view
    {
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                  _about
                , _key
                , _val
            )
        );

        require(messageHash.toEthSignedMessageHash().recover(_signature) == signer, "FlipsideAttestation: Invalid signature");
    }
}
