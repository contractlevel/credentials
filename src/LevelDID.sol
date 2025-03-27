// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ILevelDID} from "./interfaces/ILevelDID.sol";

/// @notice This contract is the Level DID NFT that gets minted to the user
/// It will be a unique token, representing a Cheqd DID, that can only be minted for a user who has completed
/// Sybil-resistant KYC with a licensed entity.
/// @notice The compliant verified user that the DID token is minted to is considered the "originalOwner"
/// The original owner can transfer the token to any other address, but that recipient can only transfer it back
/// to the original owner.
contract LevelDID is ERC721, Ownable, ILevelDID {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error LevelDID__SoulBound();
    error LevelDID__CanOnlyTransferBackToOriginalOwner();

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @dev Token ID counter (initialized to 1)
    uint256 internal s_tokenIdCounter;
    /// @dev Track the original DID owner
    mapping(uint256 tokenId => address originalOwner) internal s_originalOwners;
    /// @dev Track the DID associated with the tokenId
    mapping(uint256 tokenId => string did) internal s_tokenDID;

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
    /// @notice called by the DIDRequestManager via Chainlink Functions fulfillRequest() callback
    /// @notice mints a Level DID SBT to a compliant onchain actor
    /// @param to compliant user to mint to
    /// @param did Cheqd DID identifier
    function mintDID(address to, string memory did) external onlyOwner {
        uint256 tokenId = s_tokenIdCounter;
        s_tokenIdCounter += 1;
        s_originalOwners[tokenId] = to;
        s_tokenDID[tokenId] = did;

        _safeMint(to, tokenId);
        emit DIDMinted(to, tokenId, did);
    }

    /// @notice the original owner can transfer to any recipient, but that recipient can only transfer back to original owner
    function transferFrom(address from, address to, uint256 tokenId) public override {
        address originalOwner = s_originalOwners[tokenId];

        // If current owner is not original owner, restrict transfer to original owner only
        if (from != originalOwner) {
            if (to != originalOwner) {
                revert LevelDID__CanOnlyTransferBackToOriginalOwner();
            }
        }

        super.transferFrom(from, to, tokenId);
    }

    /// @notice the original owner can transfer to any recipient, but that recipient can only transfer back to original owner
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        address originalOwner = s_originalOwners[tokenId];

        // If current owner is not original owner, restrict transfer to original owner only
        if (from != originalOwner) {
            if (to != originalOwner) {
                revert LevelDID__CanOnlyTransferBackToOriginalOwner();
            }
        }

        super.safeTransferFrom(from, to, tokenId, data);
    }

    /*//////////////////////////////////////////////////////////////
                                 GETTER
    //////////////////////////////////////////////////////////////*/
    /// @notice The token URI for each token is the Cheqd DID associated with it
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenDID[tokenId];
    }

    function getTokenIdCounter() external view returns (uint256) {
        return s_tokenIdCounter;
    }
}
