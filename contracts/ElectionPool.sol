pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./Election.sol";

/*
*   Authored by Franco Scucchiero
*/

contract ElectionPool is Ownable {
    
    address[] moderators;
    uint8 required_confirmations = 0;
    
    struct ElectionRegistration {
        bool registered;
        bool accepted;
        Election election_contract;
        uint256 registered_timestamp;
        uint256 index;
    }

    mapping (bytes32 => mapping (address => int8)) public moderators_votes;
    mapping (bytes32 => ElectionRegistration) public registered_elections;
    bytes32[] iterable_elections;

    constructor(address[] initial_moderators, uint8 initial_required_confirmations) public {
        require (len(initial_moderators) > 0, "There must be at least 1 initial moderator.");
        require (initial_required_confirmations > 0, "There must be at least 1 initial required confirmation.");

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

}