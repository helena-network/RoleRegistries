pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Registry.sol";


/**
* Generic Registry, used for Candidates and Voters
*
**/

contract OwnedRegistry is Registry, Ownable {
    using SafeMath for uint256;

    event _MaxListingsEdited(uint256 _number); 

    mapping(address => bool) whiteListed;
    uint256 public listingCounter;
    uint256 public maxNumListings = 2 ** 256 - 1; // By default, only limited by EVM max word

    struct Application {
        uint256 stakedAmount;
        string data;
        bool approved;
    }

    mapping(bytes32 => Application) public applications;


    /**
    * @dev Adds a new account to the registry
    * @param _accountToWhiteList account to be added to the registry
    **/

    function whiteList(address _accountToWhiteList) public {
        require(msg.sender == owner());
        require(!isWhitelisted(_accountToWhiteList));
        require(listingCounter < maxNumListings);
        whiteListed[_accountToWhiteList] = true;
        listingCounter = listingCounter.add(1);
        emit _WhiteList(_accountToWhiteList);
    }

    /**
    * @dev Removes an account from the registry
    * @param _accountToRemove account to be removed from
    **/

    function remove(address _accountToRemove) public {
        require(msg.sender == owner());
        whiteListed[_accountToRemove] = false;
        listingCounter = listingCounter.sub(1);
        emit _Remove(_accountToRemove);
    }

    /**
    *  @dev Creates an application to be included in the registry
    *  @param _id Inherited from Registry interface, in this case, required to be the same as msg.sender
    *  @param _amount Inherited from Registry interface, not required (set to 0)
    *  @param _data Used for external information related with the application (e.g IPFS hash)
    */

    function apply(bytes32 _id, uint256 _amount, string _data) external {
        applications[_id] = Application(_amount, _data, false);
        emit _Application(_id, _amount, _data, msg.sender);
    }

    /**
    *  @dev Sets the maximum number of listings to be included in a registry
    *  @param _maxNumListings Maximum number of listings to be set in the registry
    */

    function setMaxNumListings(uint256 _maxNumListings) external {
        require(msg.sender == owner());
        require(_maxNumListings >= listingCounter);
        maxNumListings = _maxNumListings;
        emit _MaxListingsEdited(_maxNumListings);
    }

   
    /**
    *  @dev Returns true when a listing Hash is already Whitelisted
    *  @param  _accountChecked address being checked
    *  @return whitelisted boolean specifying if the listing is valid
    */

    function isWhitelisted(address _accountChecked) view public returns (bool whitelisted) {
        return whiteListed[_accountChecked];
    }

    /**
    *  @dev Returns data associated with an application
    *  @param  _accountChecked address being checked
    *  @return data string (link to the data)
    */

    function applicationData(bytes32 _accountChecked) view public returns (string data) {
        return applications[_accountChecked].data;
    }


    /**
    *  @dev Returns true when an application has been approved
    *  @param  _accountChecked address being checked
    *  @return approved if the app was already approved
    */

    function applicationIsApproved(bytes32 _accountChecked) view public returns (bool approved) {
        return applications[_accountChecked].approved;
    }

    /**
    *  @dev Returns the amount associated with an application
    *  @param  _accountChecked address being checked
    *  @return amount, specifying the amount that was staked
    */

    function applicationAmount(bytes32 _accountChecked) view public returns (uint256 amount) {
        return applications[_accountChecked].stakedAmount;
    }

}
