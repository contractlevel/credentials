// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ILevelDID} from "./interfaces/ILevelDID.sol";

/// @notice This contract is the Level DID NFT that gets minted to the user
/// It will be a unique token, representing a Cheqd DID, that can only be minted for a user who has completed
/// Sybil-resistant KYC with a licensed entity.
contract LevelDID is ERC721, Ownable, ILevelDID {
    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 internal s_tokenIdCounter;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event DIDMinted(address indexed to, uint256 indexed tokenId, string did);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /// @notice ownership of this contract must be transferred to the DIDRequestManager
    constructor() ERC721("Level DID", "DID") Ownable(msg.sender) {
        s_tokenIdCounter = 1;
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/
    function mintDID(address to, string memory did) external onlyOwner {
        uint256 tokenId = s_tokenIdCounter;
        s_tokenIdCounter += 1;

        _safeMint(to, tokenId);
        emit DIDMinted(to, tokenId, did);
    }

    // @review if this is going to be an SBT, should we be overriding and reverting transfer, transferFrom and approvals?

    /*//////////////////////////////////////////////////////////////
                                 GETTER
    //////////////////////////////////////////////////////////////*/
    function getTokenIdCounter() external view returns (uint256) {
        return s_tokenIdCounter;
    }
}
