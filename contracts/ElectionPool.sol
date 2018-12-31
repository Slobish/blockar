pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./Election.sol";

/*
*   Authored by Franco Scucchiero
*/

contract ElectionPool is Ownable {
    
    struct ElectionRegistration {
        bool registered;
        bool accepted;
        Election election_contract;
        uint256 registered_timestamp;
        uint256 index;
    }

    struct Moderator {
        bool isRegistered;
        address moderatorAddress;
        uint256 timestampRegistration;
        uint8 weight;
        uint256 index;
    }

    struct Votes {
        uint16 balance;
        uint16 votes;
    }

    mapping (bytes32 => mapping (address => int8)) public moderators_votes;
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
                moderatorAddress: initial_moderators[i],
                timestampRegistration: now,
                index: current_index
            });
            moderators[initial_moderators[i]] = newModerator;
        }

        required_confirmations = initial_required_confirmations;
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
        require(iterable_elections[keccak256(election_reason)] != 0, "Election doesn't exists");
        moderators_votes[keccak256(election_reason)] = vote;

    }

    modifier onlyModerators() {
        require(moderators[msg.sender], "You are not registered as a moderator");
        _;
    }
}