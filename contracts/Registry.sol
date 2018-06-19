pragma solidity 0.4.24;


/**
* Generic Registry Interface, used for Candidates and Voters
* Potentially enabling Any king of registry (Centralized or decentralized, like TCR)
**/

contract Registry {


    /**
    * @dev Adds a new account to the registry
    * @param _accountToWhiteList account to be added to the registry
    **/

    function whiteList(address _accountToWhiteList) public;


    /**
    * @dev Removes an account from the registry
    * @param _accountToRemove account to be removed from the Registry
    **/

    function remove(address _accountToRemove) public;


    /**
    *  @dev Returns true when a listing Hash is already Whitelisted
    *  @param _accountChecked identifier queried listing
    */

    function isWhitelisted(address _accountChecked) view public returns (bool whitelisted);

   
    // A new registry listing was created
    event WhiteList(address _whiteListedAccount); 


    // A registry listing was removed
    event Remove(address _removedAccount);
    
}
