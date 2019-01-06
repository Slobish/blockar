pragma solidity ^0.4.25;

import "./Ownable.sol";
import "./ElectionPool.sol";
/*
*   Authored by Franco Scucchiero
*/

contract ElectionPool {

    struct Proposer {
        address _address;
        string _name;
    }

    string public reason;
    Proposer public proposer;
    uint256 public duration;
    uint128 public votes;
    int256 public balance;
    uint256 public required_votes;
    ElectionPool public election_pool;

    constructor(string memory election_reason, uint256 election_duration, ElectionPool _election_pool, string pname) public {
        require(duration > 0, "Election duration must be greater than zero");
        required_votes = _election_poool.required_votes();
        reason = election_reason;
        duration = election_duration;
        proposer = new Proposer ({ _address: msg.sender, _name: pname});
        election_pool = _election_pool;
    }

    function() public{
        doSomething();
    }


    function doSomething() public {
        
    }

    function vote(int8 vote_option) public onlyPadron notFinished {
        require(vote_option == 1 || vote_option == -1, "Only 1 or -1 options are available");
        votes = votes + 1;
        balance = balance + vote;

        if(votes >= required_votes && balance > 0) {
            require(election_pool.call(), "Failed internal call");
        }
    }
    modifier onlyPadron() {
        require(election_pool.isAllowedToVote(msg.sender), "You are not allowed to vote");
        _;
    }

    modifier notFinished() {
        require(balance < required_votes, "The election is finished");
        _;
    }
}   