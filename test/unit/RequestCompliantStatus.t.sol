// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "../BaseTest.t.sol";
import {ICompliantRouter} from "@contractlevel/compliance/src/interfaces/ICompliantRouter.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract RequestCompliantStatusTest is BaseTest {
    function test_did_requestCompliantStatus_success() public {
        uint256 fee = ICompliantRouter(manager.getCompliantRouter()).getFee();

        vm.startPrank(user);
        LinkTokenInterface(link).approve(address(manager), fee);
        uint256 linkBalanceBefore = LinkTokenInterface(link).balanceOf(user);

        manager.requestCompliantStatus();
        vm.stopPrank();

        uint256 linkBalanceAfter = LinkTokenInterface(link).balanceOf(user);

        assertEq(linkBalanceAfter, linkBalanceBefore - fee);
    }
}
