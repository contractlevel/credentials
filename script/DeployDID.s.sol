// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {LevelDID} from "../src/LevelDID.sol";
import {DIDRequestManager} from "../src/DIDRequestManager.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IFunctionsSubscriptions} from
    "@chainlink/contracts/src/v0.8/functions/v1_0_0/interfaces/IFunctionsSubscriptions.sol";

contract DeployDID is Script {
    function run() public returns (LevelDID did, DIDRequestManager manager, HelperConfig config) {
        config = new HelperConfig();
        (
            address clcRouter,
            address clfRouter,
            address link,
            bytes32 donId,
            uint64 clfSubId,
            uint8 donHostedSecretsSlotId,
            uint64 clfSecretsVersion
        ) = config.activeNetworkConfig();

        vm.startBroadcast();

        did = new LevelDID();
        manager = new DIDRequestManager(
            address(did), clcRouter, clfRouter, link, donId, clfSubId, donHostedSecretsSlotId, clfSecretsVersion
        );
        did.transferOwnership(address(manager));

        // IFunctionsSubscriptions(clfRouter).addConsumer(clfSubId, address(manager));

        vm.stopBroadcast();

        return (did, manager, config);
    }
}
