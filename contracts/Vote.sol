// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Vote is Ownable {
    using SafeMath for uint256;
    
    struct Vote {
        uint256 participantCnt;
        mapping (uint256 => address) participant;
        mapping (address => address) voting;
        mapping (address => bool) isCandidate;
        mapping (address => uint256) voteCnt;
        
        address maxVoteAddr;
        uint256 endTime;
    }

    uint256 voteId;
    mapping (uint256 => Vote) votes;

    uint256 votePrice = 1e16;

    function addVoting(address[] _candidates) external onlyOwner returns(uint256){
        Vote storage v = votes[voteId ++];
        for (uint256 i = 0 ; i < _candidates.length ; i ++){
            v.isCandidate[_candidates[0]] = true;
        }

        v.endTime = block.timestamp + 3 days;
        return voteId-1;
    }

    function vote(uint256 _voteId, address _to) external onlyOwner payable {
        Vote storage v = votes[_voteId];
        require( v.endTime != 0, "Vote not started!" );
        require( v.endTime > block.timestamp, "Vote already ended!");
        require( v.voting[msg.sender] == 0, "Already voted!");
        require( v.isCandidate[_to] == true , "Not a valid candiate!");
        require( msg.value >= votePrice, "Not enough funds!");

        v.participant[participantCnt++] = msg.sender;
        v.voting[msg.sender] = _to;
        v.voteCnt[_to]++;
        if ( v.voteCnt[_to] > v.voteCnt[v.maxVoteAddr])
            maxVoteAddr = _to;
    }

    function finish(uint256 _voteId) external{
        Vote storage v = votes[_voteId];
        require( v.endTime != 0, "Vote not started!" );
        require( v.endTime > block.timestamp, "Vote already ended!");
            
        address(v.maxVoteAddr).transfer(votePrice.mul(v.participantCnt).mul(90).div(100));
    }
    
    function withdraw() external onlyOwner {
        address(msg.sender).transfer(balanceOf(address(this)));
    }

    function participantCount(uint256 _voteId) external view returns(uint256){
        return votes[_voteId].participantCnt;
    }

    function isCandidate(uint _voteId, address _addr) external view returns(bool){
        return votes[_voteId].isCandidate[_addr] == true;
    }

    function voteCount(uint _voteId, address _candidate) external view returns(uint256){
        return votes[_voteId].voteCnt[_candidate];
    }

    function voteInfo(uint _voteId, address _addr) external view returns(address) {
        return votes[_voteId].voting[_addr];
    }
}