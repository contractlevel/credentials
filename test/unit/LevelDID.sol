// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "../BaseTest.t.sol";

contract LevelDIDTest is BaseTest {
    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/
    address public recipient = makeAddr("recipient");
    address public nonOwner = makeAddr("nonOwner");

    /*//////////////////////////////////////////////////////////////
                                 TESTS
    //////////////////////////////////////////////////////////////*/
    /// @notice transferFrom should revert when recipient attempts transferring to non-original owner
    function test_did_transferFrom_revertsWhen_recipient_to_nonOwner() public {
        _mintDid(user, "");
        vm.prank(user);
        did.transferFrom(user, recipient, 1);
        vm.prank(recipient);
        vm.expectRevert(abi.encodeWithSignature("LevelDID__CanOnlyTransferBackToOriginalOwner()"));
        did.transferFrom(recipient, nonOwner, 1);
    }

    /// @notice safeTransferFrom should revert when recipient attempts transferring to non-original owner
    function test_did_safeTransferFrom_revertsWhen_recipient_to_nonOwner() public {
        _mintDid(user, "");
        vm.prank(user);
        did.safeTransferFrom(user, recipient, 1, "");
        vm.prank(recipient);
        vm.expectRevert(abi.encodeWithSignature("LevelDID__CanOnlyTransferBackToOriginalOwner()"));
        did.safeTransferFrom(recipient, nonOwner, 1, "");
    }

    function test_did_tokenUri() public {
        string memory didString = "test-did";
        _mintDid(user, didString);
        assertEq(did.tokenURI(1), didString);
    }

    /*//////////////////////////////////////////////////////////////
                                UTILITY
    //////////////////////////////////////////////////////////////*/
    function _mintDid(address to, string memory didString) internal {
        vm.prank(address(manager));
        did.mintDID(to, didString);
    }
}
