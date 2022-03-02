// contracts/ControlledFund.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

import  "./ControlledFund.sol";

contract Insurance is ControlledFund {

    uint private policyCount = 0;
    /// @notice
    uint public minPremium = 50 ether;
    /// @notice
    uint public maxPremium = 50 ether;
    /// @notice
    uint public maxPayout = 500 ether;

    /// @notice
    address public oracle;
    /// @notice
    uint public balance;

    /// @notice
    policy[] public policies;

    enum policyState {Applied, Accepted, Revoked, PaidOut, Expired, Declined, SendFailed }

    struct policy {
        address payable customer;
        uint premium;
        string risk;
        uint probability;
        policyState state;
        uint stateTime;
        string stateMessage;
        uint calculatedPayout;
        uint actualPayout;
    }

    constructor () {
        owner = msg.sender;
    }


    modifier onlyOracle() {
        require(msg.sender == oracle);
        _;
    }

    event PolicyApplied(uint policyId, address customer, string risk, uint premium);
    event PolicyAccepted(uint policyId);
    event PolicyPaidOut(uint policyId, uint amount);
    event PolicyExpired(uint policyId);
    event PolicyDeclined(uint policyId, string reason);
    event SendFailed(uint policyId, string reason);

          function createPolicy(string calldata _risk) external payable {
              if (msg.value < minPremium || msg.value > maxPremium){
                  emit PolicyDeclined(0, "Invalid Premium Value");

                  if(!payable(msg.sender).send(msg.value)){
                      emit SendFailed(0, "new Policy sendback failed (1)");
                  }
                  return;
              }

              balance += msg.value;

              uint policyId = policyCount++;
              policy memory p = policies[policyId];

              p.customer = payable(msg.sender);

              p.premium = msg.value;
              p.risk = _risk;
              p.state = policyState.Applied;
              p.stateMessage = "Policy applied by Customer";
              p.stateTime = block.timestamp;
              emit PolicyApplied(policyId, msg.sender, _risk, p.premium);
          }


        function underwrite(uint _policyId, uint _probability, bool _doUnderwrite) external onlyOracle {
            policy memory p = policies[_policyId];
            require(p.state == policyState.Applied);

            p.stateTime = block.timestamp;
            if (_doUnderwrite) {
                p.probability = _probability;
                p.state = policyState.Accepted;
                p.stateMessage = "Policy underwritten";
                emit PolicyAccepted(_policyId);
            } else {
                p.state = policyState.Declined;
                p.stateMessage = "Policy Declined";
                emit PolicyDeclined(_policyId, "Declined");
            }
        }

        function expirePolicy(uint _policyId) public {
            policy memory p = policies[_policyId];
            require(p.state == policyState.Accepted);

            p.state = policyState.Expired;
            p.stateMessage = "Policy Expired";
            p.stateTime = block.timestamp;
            emit PolicyExpired(_policyId);
        }

        function payOut(uint _policyId, uint _payOut) public onlyOracle {
            policy memory p = policies[_policyId];
            require(p.state == policyState.Accepted);

            if (_payOut == 0) {
                p.state = policyState.Expired;
                p.stateMessage = "Policy Expired - No payout";
                p.stateTime = block.timestamp;
                emit PolicyExpired(_policyId);

            } else {
                p.calculatedPayout = _payOut;

                if (_payOut > maxPayout) {
                    _payOut = maxPayout;
                }

                if (_payOut > balance) {
                    _payOut = balance;
                }

                p.actualPayout = _payOut;

                if (!p.customer.send(_payOut)){
                    p.state = policyState.SendFailed;
                    p.stateMessage = "Payout, send Failed";
                    p.actualPayout = 0;
                    emit SendFailed(_policyId, "Payout sending Failed");
                } else {
                    p.state = policyState.PaidOut;
                    p.stateMessage = "Payout Successful";
                    p.stateTime = block.timestamp;
                    balance -= _payOut;
                    emit PolicyPaidOut(_policyId, _payOut);
                }
            }

        }

        function setOracle (address _oracle) public onlyOwner {
            oracle = _oracle;
        }

        function getPolicyCount() public view returns (uint _count) {
            return policies.length;
        }

    }
