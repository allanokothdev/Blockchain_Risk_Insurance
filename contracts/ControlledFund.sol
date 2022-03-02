// contracts/ControlledFund.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

import  "./Owned.sol";

contract ControlledFund is Owned {

    address public riskManager;
    address public funder;

    uint public fundingBalance;
    ControlledFund private pool;

    //Modifier restricting call to Risk Manager
    modifier onlyRiskManager() {
        require(msg.sender == riskManager);
        _;
    }

    //Modifier restricting call to funder
    modifier onlyFunder() {
        require(msg.sender == owner);
        _;
    }

    function setup(address _riskManager, address _funder) public onlyOwner {
        riskManager = _riskManager;
        funder = _funder;
        pool = ControlledFund(funder);
    }

    function sendFunds(uint _amount) public onlyRiskManager {
        fundingBalance -= _amount;
        pool.receiveFunds{value: _amount};
    }

    function receiveFunds() public onlyFunder payable {
        fundingBalance += msg.value;
    }



}
