//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Voting.sol";

contract ManageVoting {
    Voting voting;
    address public owner;
    string[] public nameElections;
    bool isControlledVoting;

    //sets owner,
    //owner added as a stakeholder
    constructor(address _address) {
        voting = Voting(_address);
        owner = msg.sender;
        staff[owner] = true;
    }

    uint256 private electionsCount = 0;
    //EVENTS
    event CreateElection(address sender, string _electionName);
    event AddCandidate(address sender, string _electionName, string _name);
    event Vote(address sender, string _electionName, uint256 _candidateID);
    //MAPPING
    mapping(address => bool) public stakeholders;
    mapping(string => Voting) public elections;
    mapping(address => bool) public staff;
    mapping(address => bool) public bod;
    mapping(address => bool) public student;

    //MODIFIERS
    modifier onlyChairman() {
        require(msg.sender == owner, "Chairman only access");
        _;
    }
    modifier staffOnly() {
        require(staff[msg.sender], "You are not a staff");
        _;
    }
    modifier voteEnd(string memory _electionName) {
        require(
            elections[_electionName].votingStatus() == false,
            "Election must end"
        );
        _;
    }

    //FUNCTIONS
    function transferChairmanRole(address _adr) public onlyChairman {
        owner = _adr;
    }

    function giveStaffRole(address _adr) public onlyChairman {
        staff[_adr] = true;
    }

    function removeStaffRole(address _adr) public onlyChairman {
        staff[_adr] = false;
    }

    function giveBodRole(address _adr) public onlyChairman {
        bod[_adr] = true;
    }

    function removeBodRole(address _adr) public onlyChairman {
        bod[_adr] = false;
    }

    function giveStudentRole(address _adr) public onlyChairman {
        student[_adr] = true;
    }

    function removeStudentRole(address _adr) public onlyChairman {
        student[_adr] = false;
    }

    function enableVoting(string memory _electionName) public onlyChairman {
        elections[_electionName].enableVoting();
    }

    function disableVoting(string memory _electionName) public onlyChairman {
        elections[_electionName].disableVoting();
    }

    //add stakeholder
    function setStakeholders(address _adr) public staffOnly returns (bool) {
        return stakeholders[_adr] = true;
    }

    /*   //add voters eligibility
    function register(string memory _electionName, address _adr)
        public
        staffOnly
        returns (bool)
    {
        return elections[_electionName].registerVoters(_adr);
    }
 */
    //remove voter eligibility
    /*   function removeVoter(string memory _electionName, address _adr)
        public
        staffOnly
        returns (bool)
    {
        return elections[_electionName].removeVoters(_adr);
    } */

    //Create new instance of the voting contract
    //only chairman can create election
    function createElection(string memory _electionName, string memory category)
        public
        onlyChairman
        returns (bool)
    {
        Voting myVote = new Voting();
        elections[_electionName] = myVote;
        elections[_electionName].setVotingAccess(category);
        //increment the number of elections added
        electionsCount++;
        nameElections.push(_electionName);
        emit CreateElection(msg.sender, _electionName);
        return true;
    }

    //add candidate
    function addCandidate(string memory _electionName, string memory _name)
        public
        onlyChairman
        returns (bool)
    {
        elections[_electionName].addCandidate(_name);
        emit AddCandidate(msg.sender, _electionName, _name);
        return true;
    }

    //stakeholders only vote
    function vote(string memory _electionName, uint256 _candidateID)
        public
        returns (bool)
    {
        // require(stakeholders[msg.sender], "You are not a stakeholder");
        elections[_electionName].vote(_candidateID);
        emit Vote(msg.sender, _electionName, _candidateID);
        return true;
    }

    //get list of all election
    function getAllElection() public view returns (string[] memory) {
        return nameElections;
    }

    //get list of all candidate for election name argument
    function getAllCandidate(string memory _electionName)
        public
        view
        returns (string[] memory, uint256[] memory)
    {
        return elections[_electionName].getAllCandidates();
    }

    //get result of an election name argument
    function getResults(string memory _electionName)
        public
        view
        voteEnd(_electionName)
        returns (string[] memory, uint256[] memory)
    {
        return elections[_electionName].compileResult();
    }
}
