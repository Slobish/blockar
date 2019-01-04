pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./Election.sol";
import "./SafeMath.sol";

/*
*   Authored by Franco Scucchiero
*/


contract ElectionPool is Ownable {

    using SafeMath for int256;

    struct ElectionRegistration {
        bool registered;
        bool voted;
        bool done_action;
        bool accepted;
        Election election_contract;
        uint256 registered_timestamp;
        uint256 index;
    }

    struct Moderator {
        bool isRegistered;
        address moderatorAddress;
        uint256 timestampRegistration;
        uint256 weight;
        uint256 index;
    }

    struct Votes {
        int256 balance;
        uint256 votes;
    }

    mapping (bytes32 => Votes) public moderators_votes;
    mapping (bytes32 => ElectionRegistration) public registered_elections;
    mapping (address => Moderator) public moderators;
    
    bytes32[] iterable_elections;
    address[] iterable_moderators;
    uint8 required_confirmations = 0;

    constructor(address[] initial_moderators, uint8 initial_required_confirmations) public {
        require (len(initial_moderators) > 0, "There must be at least 1 initial moderator.");
        require (initial_required_confirmations > 0, "There must be at least 1 initial required confirmation.");

        for(int i = 0; i < initial_moderators.length; i++) {
            uint256 current_index = iterable_moderators.push(initial_moderators).sub(1);
            Moderator memory newModerator = Moderator({
                isRegistered : true,
                moderatorAddress: initial_moderators[i],
                timestampRegistration: now,
                weight: 1,
                index: current_index
            });
            moderators[initial_moderators[i]] = newModerator;
        }

        required_confirmations = initial_required_confirmations;
    }
    
    function() external payable {
        fallback();
    }

    function fallback() internal onlyAllowedActors{

    }
    /*
    *   Duration in seconds
    */
    function registerElection(address election) public {
        require (Election != address(0), "Specified address is not valid.");
        bytes32 key = keccak256(abi.encodePacked(election.reason()));
        require (! registered_elections[key].registered, "Same reason election is registered.");
        
        uint index = iterable_elections.push(token_key).sub(1);
        ElectionRegistration memory newElection = ElectionRegistration({
            registered: true,
            accepted: false,
            election_contract: election,
            registered_timestamp: now,
            index: index
        });
        registered_tokens[token_key] = newElection;
    }

    /*
    *   Voting options: 
    *    1 : Yes
    *   -1 : No
    */
    function voteElection(string election_reason, int8 vote) public onlyModerators {
        require(vote == 1 || vote == -1, "Only 1 or -1 are allowed");
        bytes32 reason_hash = keccak256(election_reason);
        require(iterable_elections[reason_hash] != 0, "Election doesn't exists");
        
        current_balance = moderators_votes[reason_hash].balance;
        current_votes = moderators_votes[reason_hash].votes;
        moderators_votes[reason_hash].balance = current_balance - moderators[msg.sender].weight * vote;
        moderators_votes[reason_hash].votes = current_votes + 1;

        if(moderators_votes[reason_hash].votes >= required_confirmations) {
            registered_elections[reason_hash].voted = true;

            if(moderators_votes[reason_hash].balance > 0) {
                registered_elections[reason_hash].accepted = true;
                registered_elections[reason_hash].Election.fallback();
            }
            else{
                registered_elections[reason_hash].accepted = false;
            }
        }
    }

    modifier onlyModerators() {
        require(moderators[msg.sender], "You are not registered as a moderator");
        _;
    }
    
}