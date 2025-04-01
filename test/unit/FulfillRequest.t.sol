// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest, Vm} from "../BaseTest.t.sol";

contract FulfillRequestTest is BaseTest {
    function test_did_fulfillRequest_error() public {
        bytes32 requestId = keccak256("testRequest");
        bytes memory response;
        bytes memory err = "1";

        vm.recordLogs();

        vm.prank(clfRouter);
        manager.handleOracleFulfillment(requestId, response, err);

        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 eventSignature = keccak256("CLFFulfilledRequestError(bytes32,bytes)");
        bytes32 emittedRequestId;
        bytes memory emittedErr;

        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == eventSignature) {
                emittedRequestId = logs[i].topics[1];
                emittedErr = abi.decode(logs[i].data, (bytes));
            }
        }

        assertEq(emittedRequestId, requestId);
        assertEq(emittedErr, err);
    }

    function test_did_fulfillRequest_success() public {
        /// @dev prank clcRouter calling executeLogic to get requestId
        vm.recordLogs();
        vm.prank(address(clcRouter));
        manager.executeLogic(user);

        Vm.Log[] memory requestLogs = vm.getRecordedLogs();
        bytes32 clfRequestSentEvent = keccak256("CLFRequestSent(address,bytes32)");
        bytes32 requestId;

        for (uint256 i = 0; i < requestLogs.length; i++) {
            if (requestLogs[i].topics[0] == clfRequestSentEvent) {
                requestId = requestLogs[i].topics[2];
                break;
            }
        }

        /// @dev params for handleOracleFulfillment call which leads to fulfillRequest
        string memory cheqdDid = "test-string";
        bytes memory response = bytes(cheqdDid);
        bytes memory err;

        vm.recordLogs();

        vm.prank(clfRouter);
        manager.handleOracleFulfillment(requestId, response, err);

        Vm.Log[] memory fulfillLogs = vm.getRecordedLogs();
        bytes32 didMintedEvent = keccak256("DIDMinted(address,uint256,string)");
        address emittedTo;
        uint256 emittedTokenId;
        string memory emittedDid;
        for (uint256 i = 0; i < fulfillLogs.length; i++) {
            if (fulfillLogs[i].topics[0] == didMintedEvent) {
                emittedTo = address(uint160(uint256(fulfillLogs[i].topics[1])));
                requestId = fulfillLogs[i].topics[2];
                emittedTokenId = uint256(fulfillLogs[i].topics[2]);
                emittedDid = abi.decode(fulfillLogs[i].data, (string));
                break;
            }
        }

        assertEq(emittedTo, user);
        assertEq(emittedTokenId, 1);
        assertEq(emittedDid, cheqdDid);
        assertEq(did.balanceOf(user), 1);
    }
}
