// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, Vm, console2} from "forge-std/Test.sol";

import {DIDRequestManager} from "../src/DIDRequestManager.sol";
import {LevelDID, ILevelDID} from "../src/LevelDID.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DeployDID} from "../script/DeployDID.s.sol";

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IFunctionsSubscriptions} from
    "@chainlink/contracts/src/v0.8/functions/v1_0_0/interfaces/IFunctionsSubscriptions.sol";

import {MockEverestConsumer} from "@contractlevel/compliance/test/mocks/MockEverestConsumer.sol";
import {ICompliantRouter} from "@contractlevel/compliance/src/interfaces/ICompliantRouter.sol";

contract BaseTest is Test {
    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 public constant USER_LINK_BALANCE = 100 * 1e18;

    uint256 public ethSepoliaFork;

    LevelDID public did;
    DIDRequestManager public manager;
    HelperConfig public config;
    address public clcRouter;
    address public clfRouter;
    address public link;
    bytes32 public donId;
    uint64 public clfSubId;
    uint8 public donHostedSecretsSlotId;
    uint64 public clfSecretsVersion;

    address public user = makeAddr("user");

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/
    function setUp() public {
        /// @dev fork sepolia
        ethSepoliaFork = vm.createSelectFork(vm.envString("ETH_SEPOLIA_RPC_URL"));

        /// @dev run deploy script
        DeployDID deploy = new DeployDID();
        (did, manager, config) = deploy.run();

        /// @dev get constructor args from helper config
        (clcRouter, clfRouter, link, donId, clfSubId, donHostedSecretsSlotId, clfSecretsVersion) =
            config.activeNetworkConfig();

        /// @dev assert script correctly transferred ownership of did to manager
        assertEq(did.owner(), address(manager));

        /// @dev add consumer to CLF subscription
        vm.prank(vm.envAddress("DEPLOYER_PUBLIC_ADDRESS"));
        IFunctionsSubscriptions(clfRouter).addConsumer(clfSubId, address(manager));

        /// @dev fund user with LINK
        deal(link, user, USER_LINK_BALANCE);

        /// @dev set user KYC status to true
        (, bytes memory retData) = clcRouter.call(abi.encodeWithSignature("getEverest()"));
        address everest = abi.decode(retData, (address));
        MockEverestConsumer(everest).setLatestFulfilledRequest(
            false, true, true, clcRouter, user, uint40(block.timestamp)
        );

        /// @dev sanity check
        (, bytes memory retData2) = clcRouter.call(abi.encodeWithSignature("getIsCompliant(address)", user));
        bool isCompliant = abi.decode(retData2, (bool));
        assertTrue(isCompliant);
    }
}
