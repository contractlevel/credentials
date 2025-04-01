// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {CompliantLogic} from "@contractlevel/compliance/src/CompliantLogic.sol";
import {ICompliantRouter} from "@contractlevel/compliance/src/interfaces/ICompliantRouter.sol";

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {FunctionsClient, FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_3_0/FunctionsClient.sol";

import {ILevelDID} from "./interfaces/ILevelDID.sol";

/// @notice This contract facilitates requests for the compliant status of a user, and then mints a LevelDID NFT
/// with the Cheqd API through Chainlink Functions (CLF) if the user is compliant.
contract DIDRequestManager is CompliantLogic, FunctionsClient {
    /*//////////////////////////////////////////////////////////////
                           TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    using FunctionsRequest for FunctionsRequest.Request;

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint32 internal constant CLF_GAS_LIMIT = 300_000;
    string internal constant SOURCE =
        "async function main(a,s){try{let d=a[0];if(!d)throw'M';let k=s.apiKey;if(!k)throw'K';let r=await Functions.makeHttpRequest({url:`https://studio-api.cheqd.net/did/search/${d}`,method:'GET',headers:{accept:'application/json','x-api-key':k}});if(r.error)throw r.data.error||'E';let p=r.data.didDocument.verificationMethod[0].publicKeyBase58;if(!p)throw'P';return Functions.encodeString(p)}catch(e){return Functions.encodeString(`E:${e}`)}}return main(args,secrets)";

    /// @dev Level DID NFT contract native to this project
    address internal immutable i_levelDID;
    /// @dev LINK token contract address
    address internal immutable i_link;
    /// @dev Chainlink Functions DON ID
    bytes32 internal immutable i_donId;
    /// @dev Chainlink Functions subscription ID
    uint64 internal immutable i_clfSubId;
    /// @dev Chainlink Functions DON-hosted secrets slot ID
    uint8 internal immutable i_donHostedSecretsSlotId;
    /// @dev Chainlink Functions secrets version
    uint64 internal immutable i_clfSecretsVersion;

    /// @notice user to CLF RequestID
    mapping(bytes32 requestId => address user) internal s_requestIdToUser;
    /// @notice DID to retrieve data about for the user
    mapping(address user => string did) internal s_userToDid;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event RequestCompliantStatus(address indexed user);
    event CLFRequestSent(address indexed user, bytes32 indexed requestId);
    event CLFFulfilledRequestError(bytes32 indexed requestId, bytes error);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        address levelDID,
        address clcRouter,
        address clfRouter,
        address link,
        bytes32 donId,
        uint64 clfSubId,
        uint8 donHostedSecretsSlotId,
        uint64 clfSecretsVersion
    ) CompliantLogic(clcRouter) FunctionsClient(clfRouter) {
        i_levelDID = levelDID;
        i_link = link;
        i_donId = donId;
        i_clfSubId = clfSubId;
        i_donHostedSecretsSlotId = donHostedSecretsSlotId;
        i_clfSecretsVersion = clfSecretsVersion;
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/
    // @review - could just change this to ERC677Receiver.onTokenTransfer......
    /// @notice This function calls the CLCRouter to request the compliant status of a user
    /// @notice Users must LINK.approve(address(this), CLCRouter.getFee()) before calling this function
    /// @param did string identifier for Cheqd DID to retrieve info about if user is compliant
    function requestCompliantStatus(string memory did) external {
        s_userToDid[msg.sender] = did;

        /// @review - need to account for CLF cost and take that from user, adding it to clf subscription
        /// not totally important at this stage, but should be considered

        // get fee from router
        uint256 fee = ICompliantRouter(i_compliantRouter).getFee();

        // transfer link from msg.sender
        LinkTokenInterface(i_link).transferFrom(msg.sender, address(this), fee);

        // encode the data to send to clcRouter
        bytes memory data = abi.encode(msg.sender, address(this), 0);

        // use LINK.transferAndCall() to send the request to the CLCRouter
        LinkTokenInterface(i_link).transferAndCall(i_compliantRouter, fee, data);

        emit RequestCompliantStatus(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/
    /// @notice This function is called by the CLCRouter if a user is compliant
    /// @param user The user who has been verified as compliant
    /// @notice This function will call the Cheqd API through Chainlink Functions
    function _executeLogic(address user) internal override {
        string memory did = s_userToDid[user];
        string[] memory args = new string[](1);
        args[0] = did;

        FunctionsRequest.Request memory req;
        req.setArgs(args);
        req.initializeRequestForInlineJavaScript(SOURCE);
        req.addDONHostedSecrets(i_donHostedSecretsSlotId, i_clfSecretsVersion);

        bytes32 requestId = _sendRequest(req.encodeCBOR(), i_clfSubId, CLF_GAS_LIMIT, i_donId);

        s_requestIdToUser[requestId] = user;
        emit CLFRequestSent(user, requestId);
    }

    /// @param requestId The request ID, returned by sendRequest()
    /// @param response Aggregated response from the execution of the user's source code
    /// @param err Aggregated error from the execution of the user code or from the execution pipeline
    /// @dev Either response or error parameter will be set, but never both
    function _fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (err.length > 0) {
            // handle error
            emit CLFFulfilledRequestError(requestId, err);
        } else {
            // handle response from Cheqd API to mint LevelDID NFT
            address user = s_requestIdToUser[requestId];

            string memory did = abi.decode(response, (string));

            ILevelDID(i_levelDID).mintDID(user, did);
        }
    }

    /*//////////////////////////////////////////////////////////////
                                 GETTER
    //////////////////////////////////////////////////////////////*/
    function getLink() external view returns (address) {
        return i_link;
    }

    function getDonId() external view returns (bytes32) {
        return i_donId;
    }

    function getClfSubId() external view returns (uint64) {
        return i_clfSubId;
    }

    function getLevelDID() external view returns (address) {
        return i_levelDID;
    }

    function getDonHostedSecretsSlotId() external view returns (uint8) {
        return i_donHostedSecretsSlotId;
    }

    function getSecretsVersion() external view returns (uint64) {
        return i_clfSecretsVersion;
    }

    function getRequestIdToUser(bytes32 requestId) external view returns (address) {
        return s_requestIdToUser[requestId];
    }

    function getDidToUser(address user) external view returns (string memory) {
        return s_userToDid[user];
    }
}
