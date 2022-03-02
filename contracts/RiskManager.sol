// contracts/RiskManager.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

import "./Insurance.sol";

contract RiskManager {

    address public owner;
    Insurance insurance;

    modifier onlyOwner() {
      if (msg.sender != owner){
        //Only owner is allowed to proceed
        revert();
      }
      _;
    }

    constructor () {
        owner = msg.sender;
    }

    function fundInsurance(uint _amount) onlyOwner external {

    }

    function defundInsurance(uint _amount) onlyOwner external {
        insurance.sendFunds(_amount);
    }

    function setNewTotalSupply(uint _amount) onlyOwner private {

    }

    function setContracts(address _insuranceAddress) onlyOwner external {
      insurance = Insurance(_insuranceAddress);
    }
}
