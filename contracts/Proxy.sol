// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Proxy {
    address public owner;
    address public logicContract;

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    fallback() external payable {
        address target = logicContract;

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), target, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    function updateLogicContract(address _newLogicContract) external {
        require(msg.sender == owner, "Only the owner can update the logic contract");
        logicContract = _newLogicContract;
    }

    receive() external payable {
        // Receive Ether logic here, if needed
    }
}
