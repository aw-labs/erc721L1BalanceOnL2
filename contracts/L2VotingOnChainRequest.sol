/**
 *Submitted for verification at goerli-optimism.etherscan.io on 2023-07-08
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IFunctionGateway} from "./IFunctionGateway.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract L2VotingOnChainRequest {
    address public FUNCTION_GATEWAY =
        address(0x852a94F8309D445D27222eDb1E92A4E83DdDd2a8);
    bytes32 public FUNCTION_ID =
        0x936ce1359edb760ca8dda03f1fa09666c0e49496478a0b696f8fdebf7701ccd5;

    uint32 public chainId = 1;

    // erc721Address => holder => blocknumber => balance
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public erc721SnapBalance;
    address public deployer;

    function updateFunctionId(bytes32 _functionId) external {
        require(msg.sender == deployer, "Only deployer can call this function");
        FUNCTION_ID = _functionId;
    }

    function updateFunctionGateway(address _functionGateway) external {
        require(msg.sender == deployer, "Only deployer can call this function");
        FUNCTION_GATEWAY = _functionGateway;
    }

    function vote(
        address _addressERC721,
        uint64 _snapshotBlock
    ) external payable {
        address holder = msg.sender;
        if (erc721SnapBalance[_addressERC721][holder][_snapshotBlock] != 0) {
            revert("Don't have to check balance anymore");
        }

        IFunctionGateway(FUNCTION_GATEWAY).request{value: msg.value}(
            FUNCTION_ID,
            abi.encode(
                chainId,
                _snapshotBlock,
                address(0),
                _addressERC721,
                abi.encodeWithSelector(IERC721.balanceOf.selector, holder)
            ),
            L2VotingOnChainRequest.continueVote.selector,
            abi.encode(_addressERC721, holder, _snapshotBlock)
        );
    }

    function continueVote(
        bytes memory _requestResult,
        bytes memory _context
    ) external {
        require(
            msg.sender == FUNCTION_GATEWAY,
            "Only FUNCTION_GATEWAY can call this function"
        );
        uint256 balance = abi.decode(_requestResult, (uint256));
        (address addressERC721, address holder, uint256 snapshotBlock) = abi
            .decode(_context, (address, address, uint256));
        erc721SnapBalance[addressERC721][holder][snapshotBlock] = balance;
    }

    receive() external payable {}
}
