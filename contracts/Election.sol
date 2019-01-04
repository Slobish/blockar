pragma solidity ^0.4.25;

import "./Ownable.sol";
import "./ElectionPool.sol";
/*
*   Authored by Franco Scucchiero
*/

contract ElectionPool {
    string public reason;
    address public proposer;
    uint256 public duration;
    ElectionPool public election_pool;

    constructor(string memory election_reason, uint256 election_duration, ElectionPool _election_pool) public {
        require(duration > 0, "Election duration must be greater than zero");
        
        reason = election_reason;
        duration = election_duration;
        proposer = msg.sender;
        election_pool = _election_pool;
    }

    function() public{
        doSomething();
    }


    function doSomething() public{
        continue;
    }
}