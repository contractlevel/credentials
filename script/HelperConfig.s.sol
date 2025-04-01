// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    /*//////////////////////////////////////////////////////////////
                             NETWORK CONFIG
    //////////////////////////////////////////////////////////////*/
    struct NetworkConfig {
        address clcRouter;
        address clfRouter;
        address link;
        bytes32 donId;
        uint64 clfSubId;
        uint8 donHostedSecretsSlotId;
        uint64 clfSecretsVersion;
    }

    NetworkConfig public activeNetworkConfig;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getEthSepoliaConfig();
        }
    }

    /*//////////////////////////////////////////////////////////////
                                 GETTER
    //////////////////////////////////////////////////////////////*/

    function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            clcRouter: 0x921715E7b78d53f80ae0e5C7b086BCD4213A6AD2,
            clfRouter: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            clfSubId: 4467,
            donHostedSecretsSlotId: 0,
            clfSecretsVersion: 1743081919 // needs to be replaced everytime functions/uploadSecrets.js is run
        });
    }
}
