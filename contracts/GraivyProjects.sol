pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract GraivyProjects {

  using SafeMath for uint256;

  struct Project {
    bool active;
    address owner;
    uint qualifications;
    uint redundancy;
    bytes32 tasksLocation;
    uint numTasks;
    uint numWorks;
    uint256 rewardTotal;
    bytes32 results;
    uint index;
    mapping(address => uint) worksPerUser;
  }

  mapping(address => Project) public projects;
  address[] public projectIndex;

  uint256 public totalRewards;
  address public projectsOracleBot;
  mapping(address => uint256) public rewardAvailable;

  modifier projectsOracleOnly() {
    require(msg.sender == projectsOracleBot);
    _;
  }

  function isProject(address projectAddress)
    public
    constant
    returns(bool)
  {
    if(projectIndex.length == 0) return false;
    return (projectIndex[projects[projectAddress].index] == projectAddress);
  }

  function insertProject(
    address projectAddress,
    address owner,
    uint qualifications,
    uint256 redundancy,
    bytes32 tasksLocation,
    uint256 numTasks,
    uint256 rewardTotal,
    bytes32 results)
    public
    payable
    returns(uint index)
  {
    require(!isProject(projectAddress));
    require(msg.value >= rewardTotal);
    totalRewards = totalRewards.add(rewardTotal);
    projects[projectAddress] = Project(
      true,
      owner,
      qualifications,
      redundancy,
      tasksLocation,
      numTasks,
      0,
      rewardTotal,
      results,
      projectIndex.push(projectAddress)-1
      );
    return projectIndex.length-1;
  }

  function deleteProject(address projectAddress)
    public
    returns(uint index)
  {
    require(msg.sender == projects[projectAddress].owner);
    require(isProject(projectAddress));
    uint rowToDelete = projects[projectAddress].index;
    address keyToMove = projectIndex[projectIndex.length-1];
    projectIndex[rowToDelete] = keyToMove;
    projects[keyToMove].index = rowToDelete;
    projectIndex.length--;
    return rowToDelete;
  }

  function getProjectOwner(address projectAddress)
    public
    constant
    returns(address owner)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].owner);
  }

  function getProjectActive(address projectAddress)
    public
    constant
    returns(bool active)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].active);
  }

  function getProjectQualifications(address projectAddress)
    public
    constant
    returns(uint qualifications)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].qualifications);
  }

  function getProjectRedundancy(address projectAddress)
    public
    constant
    returns(uint redundancy)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].redundancy);
  }

  function getProjectTasksLocation(address projectAddress)
    public
    constant
    returns(bytes32 tasksLocation)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].tasksLocation);
  }

  function getProjectNumTasks(address projectAddress)
    public
    constant
    returns(uint numTasks)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].numTasks);
  }

  function getProjectNumWorks(address projectAddress)
    public
    constant
    returns(uint numWorks)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].numWorks);
  }

  function getProjectRewardTotal(address projectAddress)
    public
    constant
    returns(uint256 rewardTotal)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].rewardTotal);
  }

  function getProjectResults(address projectAddress)
    public
    constant
    returns(bytes32 results)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].results);
  }

  function getProjectIndex(address projectAddress)
    public
    constant
    returns(uint index)
  {
    require(isProject(projectAddress));
    return(projects[projectAddress].index);
  }

  function getProjectCount()
    public
    constant
    returns(uint count)
  {
    return projectIndex.length;
  }

  function getProjectAtIndex(uint index)
    public
    constant
    returns(address projectAddress)
  {
    return projectIndex[index];
  }

}
