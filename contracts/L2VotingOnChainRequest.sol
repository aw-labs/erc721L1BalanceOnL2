/**
 *Submitted for verification at goerli-optimism.etherscan.io on 2023-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

struct StateQuery {
    uint32 chainId;
    uint64 blockNumber;
    address fromAddress;
    address toAddress;
    bytes toCalldata;
}

interface IStateQueryGateway {
    function requestStateQuery(
        StateQuery calldata _query,
        bytes4 _callbackMethod,
        bytes calldata _callbackData
    ) external;
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract L2VotingOnChainRequest {
    address public STATE_QUERY_GATEWAY = address(0x1b132819aFE2AFD5b76eF6721bCCC6Ede40cd9eC);
    uint32 public chainId = 1;

    // erc721Address => holder => blocknumber => balance
    mapping(address => mapping(address => mapping(uint256 => uint256))) public erc721SnapBalance;
    address public deployer;


    function vote(address _addressERC721, uint64 _snapshotBlock) external {
        address holder = msg.sender;
        if (erc721SnapBalance[_addressERC721][holder][_snapshotBlock] != 0) {
            revert("Don't have to check balance anymore");
        }

        StateQuery memory stateQuery = StateQuery({
            chainId: chainId,
            blockNumber: _snapshotBlock,
            fromAddress: address(0),
            toAddress: _addressERC721,
            toCalldata: abi.encodeWithSelector(IERC721.balanceOf.selector, holder)
        });
        IStateQueryGateway(STATE_QUERY_GATEWAY).requestStateQuery(
            stateQuery,
            L2VotingOnChainRequest.continueVote.selector,
            abi.encode(_addressERC721, holder, _snapshotBlock) 
        );
    }

    function continueVote(bytes memory _requestResult, bytes memory _callbackExtraData) external {
        require(msg.sender == STATE_QUERY_GATEWAY, "Only STATE_QUERY_GATEWAY can call this function");
        uint256 balance = abi.decode(_requestResult, (uint256));
        (address addressERC721, address holder, uint256 snapshotBlock) = abi.decode(_callbackExtraData, (address, address, uint256));
        erc721SnapBalance[addressERC721][holder][snapshotBlock] = balance;
    }
    
    receive() external payable {}
}
