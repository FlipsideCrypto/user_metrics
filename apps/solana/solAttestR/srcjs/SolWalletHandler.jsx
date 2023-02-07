import React from 'react';
import { reactShinyInput } from 'reactR';
import SolWalletWrapper from './SolWalletWrapper.jsx';
import { SolWalletMultiButton } from './SolWalletMultiButton.jsx';

const SolWalletHandler = (props) => {
    return (
        <SolWalletWrapper>
            <SolWalletMultiButton setAddressForR={props.setValue} />
        </SolWalletWrapper>
    );
}

export default function initSolWalletHandler() {
    reactShinyInput(
      '.SolWalletHandler', 
      'solAttestR.SolWalletHandler', 
      SolWalletHandler
    );
}