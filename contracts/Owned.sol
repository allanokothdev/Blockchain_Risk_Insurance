// contracts/Owned.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

contract  Owned  {

    address public owner;

    //Modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //Change Smart Contract admin
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}
