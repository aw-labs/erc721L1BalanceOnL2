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

interface IFeeVault {
    function depositNative(address _account) external payable;
    // function deposit(address _account, address _token, uint256 _amount) external;
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract L2VotingOnChainRequest {
    event Voted(address indexed holder);

    address public STATE_QUERY_GATEWAY = address(0x1b132819aFE2AFD5b76eF6721bCCC6Ede40cd9eC);
    address public FEE_VAULT = address(0x608c92Cfc42cd214FCbc3AF9AD799a7E1DfA6De2);
    address public addressERC721 = address(0x9C8fF314C9Bc7F6e59A9d9225Fb22946427eDC03); //nouns
    uint32 public chainId = 1;
    uint64 public snapshotBlock = 20012312;

    mapping(address => uint256) public addrToVote;
    address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    function vote(uint256 option, address holder) external {
        require(option == 1 || option == 2, "Invalid option");
        if (addrToVote[holder] != 0) {
            revert("Cannot vote twice");
        }

        StateQuery memory stateQuery = StateQuery({
            chainId: chainId,
            blockNumber: snapshotBlock,
            fromAddress: address(0),
            toAddress: addressERC721,
            toCalldata: abi.encodeWithSelector(IERC721.balanceOf.selector, holder)
        });
        IStateQueryGateway(STATE_QUERY_GATEWAY).requestStateQuery(
            stateQuery,
            L2VotingOnChainRequest.continueVote.selector, // Which function to call after async call is done
            abi.encode(option, holder) // What other data to pass to the callback
        );
        uint256 feePerRequest = 0.003 ether + 100000 gwei;
        IFeeVault(FEE_VAULT).depositNative{value: feePerRequest}(address(this));
    }

    function continueVote(bytes memory _requestResult, bytes memory _callbackExtraData) external {
        require(msg.sender == STATE_QUERY_GATEWAY);
        uint256 balance = abi.decode(_requestResult, (uint256));
        (uint256 option, address holder) = abi.decode(_callbackExtraData, (uint256, address));
        if (balance >= 1) {
            addrToVote[holder] = option;
        }
        emit Voted(holder);
    }

    function withdraw() external {
        require(msg.sender == deployer);
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
