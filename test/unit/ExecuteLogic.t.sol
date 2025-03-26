// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest, Vm} from "../BaseTest.t.sol";

contract ExecuteLogicTest is BaseTest {
    /// @notice the functions/uploadSecrets.js script will have to be run before this test if the DON-hosted secret has expired
    function test_did_executeLogic_success() public {
        vm.recordLogs();

        vm.prank(address(clcRouter));
        manager.executeLogic(user);

        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 eventSignature = keccak256("CLFRequestSent(address,bytes32)");
        address emittedUser;
        bytes32 emittedRequestId;

        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == eventSignature) {
                emittedUser = address(uint160(uint256(logs[i].topics[1])));
                emittedRequestId = logs[i].topics[2];
            }
        }

        assertEq(manager.getRequestIdToUser(emittedRequestId), user);
    }

    function test_did_executeLogic_revertsWhen_notClcRouter() public {
        vm.expectRevert(abi.encodeWithSignature("CompliantLogic__OnlyCompliantRouter()"));
        manager.executeLogic(user);
    }
}
