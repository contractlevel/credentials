// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "../BaseTest.t.sol";

contract ConstructorTest is BaseTest {
    function test_did_constructor() public view {
        assertEq(manager.getLink(), link);
        assertEq(manager.getClfSubId(), clfSubId);
        assertEq(manager.getDonId(), donId);
        assertEq(manager.getLevelDID(), address(did));
        assertEq(manager.getDonHostedSecretsSlotId(), donHostedSecretsSlotId);
        assertEq(manager.getSecretsVersion(), clfSecretsVersion);

        assertEq(did.getTokenIdCounter(), 1);
    }
}
