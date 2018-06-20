pragma solidity 0.4.24;


/**
* Generic Registry Interface, used in Frontier for Candidates and Voters
* Potentially enabling Any king of registry (Centralized or decentralized, like TCR)
**/

contract Registry {


    event _WhiteList(address _whiteListedAccount); 
    event _Remove(address _removedAccount);
    event _Application(bytes32 indexed listingHash, uint deposit, uint appEndDate, string data, address indexed applicant);

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

     /**
    *  @dev Creates an application to be included in the registry
    *  @param _amount Amount of tokens that will be staked initially (some registries might require it, otherwise, 0)
    *  @param _data Used for external information related with the application (e.g IPFS hash)
    */

    function apply(uint _amount, string _data) external;
    
}
