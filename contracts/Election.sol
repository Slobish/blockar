pragma solidity ^0.4.25;

import "./Ownable.sol";

/*
*   Authored by Franco Scucchiero
*/

contract ElectionPool {
    string public reason;
    address public proposer;
    uint256 public duration;

    constructor(string memory election_reason, uint256 election_duration) public {
        require(duration > 0, "Election duration must be greater than zero");
        
        reason = election_reason;
        duration = election_duration;
        proposer = msg.sender;
    }

}
