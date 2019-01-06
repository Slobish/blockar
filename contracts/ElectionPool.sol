pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./Election.sol";
import "./SafeMath.sol";

/*
*   Authored by Franco Scucchiero
*/


contract ElectionPool {

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
    mapping (address => bool) public padron;

    bytes32[] public iterable_elections;
    address[] public iterable_moderators;
    uint8 public required_confirmations = 0;

    constructor(address[] initial_moderators, uint8 initial_required_confirmations) public {
        require (len(initial_moderators) > 0, "There must be at least 1 initial moderator.");
        require (initial_required_confirmations > 0, "There must be at least 1 initial required confirmation.");

        for(int i = 0; i < initial_moderators.length; i++) {
            uint256 current_index = iterable_moderators.push(initial_moderators).sub(1);
            Moderator memory newModerator = Moderator({
                isRegistered: true,
                moderatorAddress: initial_moderators[i],
                timestampRegistration: now,
                weight: 1,
                index: current_index
            });
            moderators[initial_moderators[i]] = newModerator;
        }

        required_confirmations = initial_required_confirmations;
    }

    function addModerator(address _newModerator) public onlyPower {
        uint256 current_index = iterable_moderators.push(_newModerator).sub(1);
        Moderator memory newModerator = Moderator({
            isRegistered: true,
            moderatorAddress: _newModerator,
            timestampRegistration: now,
            weight: 1,
            index: current_index
        });
        moderators[_newModerator] = newModerator;
    }

    function removeModerator(address punishedModerator) public onlyPower {
        require (moderators[punishedModerator].registered, "Address is not a registered moderator");
        // CHECK IF IT IS ENOUGH
        uint256 index = moderators[punishedModerator].index;
        delete iterable_moderators[index];
        moderators[punishedModerator].registered = false;
    }

    function changeRequiredConfirmations(uint256 newRequired) public {
        requiredConfirmations = newRequired;
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

    function addPadron(address[] allowed) public onlySomeone{
        for(int i=0; i < allowed.length; i++){
            padron[allowed[i]] = true;
        }
    }

    function isAllowedToVote(address _address) public returns (bool){
        return padron[_address];
    }

    function getElectionsAmount() public view {
        return iterable_elections.length;
    }

    function getElectionByIndex(uint256 index) public view returns(Election) {
        return iterable_elections[index];
    }

    modifier onlyModerators() {
        require(moderators[msg.sender], "You are not registered as a moderator");
        _;
    }

    modifier onlyPower() {
        require(registered_elections[msg.sender].registered == true, "The election is not registered yet");
        require(registered_elections[msg.sender].voted == true, "The election is not voted yet");
        require(registered_elections[msg.sender].accepted == true, "The election is not accepted yet");
        require(registered_elections[msg.sender].done_action == false, "The election already acted");
        _;
    }

    // Decide the criteria to allow someone to vote
    modifier onlySomeone(){
        _;
    }    

}