pragma solidity ^0.4.11;

contract GraivyUsers {

  struct User {
    uint qualifications;
    uint permissions; // allows various types of reward collection to save gas based on trust
    uint index;
  }

  mapping(address => User) public users;
  address[] public userIndex;

  address public usersOracleBot;

  modifier userOracleOnly() {
    require(msg.sender == usersOracleBot);
    _;
  }

  modifier userOnly() {
    require(msg.sender == userIndex[users[msg.sender].index]);
    _;
  }

  function isUser(address userAddress)
    public
    constant
    returns(bool)
  {
    if(userIndex.length == 0) return false;
    return (userIndex[users[userAddress].index] == userAddress);
  }

  function authenticateUser(address userAddress)
    public
    constant
    returns(bool)
  {
    require(msg.sender == userAddress);
    if(userIndex.length == 0) return false;
    return (userIndex[users[userAddress].index] == userAddress);
  }

  function insertUser()
    returns(uint index, address userAddress)
  {
    require(!isUser(userAddress));
    userAddress = msg.sender;
    users[userAddress].qualifications = 0;
    users[userAddress].permissions = 0;
    users[userAddress].index = userIndex.push(userAddress)-1;
    return (userIndex.length-1, userAddress);
  }

  function deleteUser()
    userOnly
    returns(uint index)
  {
    uint rowToDelete = users[msg.sender].index;
    address keyToMove = userIndex[userIndex.length-1];
    userIndex[rowToDelete] = keyToMove;
    users[keyToMove].index = rowToDelete;
    userIndex.length--;
    return rowToDelete;
  }

  function getUser(address userAddress)
    public
    constant
    returns(uint qualifications, uint permissions, uint index)
  {
    require(isUser(userAddress));
    qualifications = users[userAddress].qualifications;
    permissions = users[userAddress].permissions;
    index = users[userAddress].index;
    return(qualifications, permissions, index);
  }

  function getUserQualifications(address userAddress)
    public
    constant
    returns(uint qualifications)
  {
    require(isUser(userAddress));
    qualifications = users[userAddress].qualifications;
    return(qualifications);
  }

  function getUserPermissions(address userAddress)
    public
    constant
    returns(uint permissions)
  {
    require(isUser(userAddress));
    permissions = users[userAddress].permissions;
    return(permissions);
  }

  function updateUserQualifications(address userAddress, uint qualifications)
    userOracleOnly
    returns(bool success)
  {
    require(isUser(userAddress));
    users[userAddress].qualifications = qualifications;
    return true;
  }

  function updateUserPermissions(address userAddress, uint permissions)
    userOracleOnly
    returns(bool success)
  {
    require(isUser(userAddress));
    users[userAddress].permissions = permissions;
    return true;
  }

  function getUserCount()
    public
    constant
    returns(uint count)
  {
    return userIndex.length;
  }

  function getUserAtIndex(uint index)
    public
    constant
    returns(address userAddress)
  {
    return userIndex[index];
  }

}
