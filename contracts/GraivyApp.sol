pragma solidity ^0.4.11;

import './GraivyProjects.sol';
import './GraivyUsers.sol';

contract GraivyApp is GraivyProjects, GraivyUsers {

  function GraivyApp() {
    usersOracleBot = msg.sender;
    projectsOracleBot = msg.sender;
  }

  // users can withdraw accumulated rewards to their address
  function withdrawRewards() userOnly returns (bool) {
    address payee = msg.sender;
    uint256 reward = rewardAvailable[payee];
    require(reward != 0);
    require(totalRewards >= reward);
    totalRewards = totalRewards.sub(reward);
    rewardAvailable[payee] = 0;
    msg.sender.transfer(reward);
    return true;
  }

  // fully trustless claim, requires adequate user permissions
  function claimProjectReward (
    address projectAddress,
    uint numWorks)
    userOnly
    returns (bool)
  {
    Project storage p = projects[projectAddress];
    require(isProject(projectAddress));
    require(p.active == true);
    require(p.worksPerUser[msg.sender].add(numWorks) <= p.numTasks);
    User storage u = users[msg.sender];
    require(u.permissions >= 1);
    require(u.qualifications == p.qualifications);
    require(numWorks <= p.numTasks.mul(p.redundancy).sub(p.numWorks));
    uint256 reward = p.rewardTotal.div(p.numTasks).div(p.redundancy).mul(numWorks);
    rewardAvailable[msg.sender] = rewardAvailable[msg.sender].add(reward);
    p.numWorks = p.numWorks.add(numWorks);
    p.worksPerUser[msg.sender] = p.worksPerUser[msg.sender].add(numWorks);
    if (p.numWorks >= (p.numTasks.mul(p.redundancy)))
      p.active = false;
    return true;
  }

  // requires some Oracle trust, but bound by Project rules
  function distributeProjectReward (
    address projectAddress,
    address userAddress,
    uint numWorks,
    uint256 reward)
    projectsOracleOnly
    returns (bool)
  {
    Project storage p = projects[projectAddress];
    require(isProject(projectAddress));
    require(isUser(userAddress));
    require(p.active == true);
    User storage u = users[userAddress];
    require(u.qualifications == p.qualifications);
    rewardAvailable[userAddress] = rewardAvailable[userAddress].add(reward);
    p.numWorks = p.numWorks.add(numWorks);
    p.worksPerUser[userAddress] = p.worksPerUser[userAddress].add(numWorks);
    if (p.numWorks >= (p.numTasks.mul(p.redundancy)))
      p.active = false;
    return true;
  }

  // requires more Oracle trust, but cheaper gas costs
  function quickReward (
    address projectAddress,
    address userAddress,
    uint numWorks,
    uint256 reward)
    projectsOracleOnly
    returns (bool)
  {
    Project storage p = projects[projectAddress];
    rewardAvailable[userAddress] = rewardAvailable[userAddress].add(reward);
    p.numWorks = p.numWorks.add(numWorks);
    p.worksPerUser[userAddress] = p.worksPerUser[userAddress].add(numWorks);
    if (p.numWorks >= (p.numTasks.mul(p.redundancy)))
      p.active = false;
    return true;
  }
}
