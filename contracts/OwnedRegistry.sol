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
    
    /**
    * @dev Adds a new account to the registry
    * @param _accountToWhiteList account to be added to the registry
    **/

    function whiteList(address _accountToWhiteList) public {
        require(msg.sender == owner());
        require(!isWhitelisted(_accountToWhiteList));
        require(_getNextListingCounter() < _getMaxNumListings());
        _whiteListAddress(_accountToWhiteList);
        emit _WhiteList(_accountToWhiteList);
    }

    /**
    * @dev Removes an account from the registry
    * @param _accountToRemove account to be removed from
    **/

    function remove(address _accountToRemove) public {
        require(msg.sender == owner());
        _blackListAddress(_accountToRemove);
        emit _Remove(_accountToRemove);
    }

    /**
    *  @dev Sets the maximum number of listings to be included in a registry
    *  @param _maxNumListings Maximum number of listings to be set in the registry
    */

    function setMaxNumListings(uint256 _maxNumListings) external {
        require(msg.sender == owner());
        require(_maxNumListings >= _getListingCounter());
        _setMaxNumListings(_maxNumListings);
        emit _MaxListingsEdited(_maxNumListings);
    }

   
    /**
    *  @dev Returns true when a listing Hash is already Whitelisted
    *  @param  _accountChecked address being checked
    *  @return whitelisted boolean specifying if the listing is valid
    */

    function isWhitelisted(address _accountChecked) view public returns (bool whitelisted) {
       whitelisted = _getAccountFromWhiteListed(_accountChecked);
       return whitelisted;
    }

    function wasWhitelisted(address _accountChecked, uint256 _epoch) public view returns (bool whitelisted){
        address[20] memory addressListFromEpoch = _getEpochFromArchive(_epoch).whiteListed;
        uint256 userIndex = _findInArray(_accountChecked, addressListFromEpoch);

        if(userIndex == 101){
            return false;
        }else{
            return true;
        }
    }

    function listingCounter() public view returns (uint256){
        uint256 _counter = _getListingCounter();
        return _counter;
    }

    function maxNumListings() public view returns (uint256){
        uint256 _maxNumListings = _getMaxNumListings();
        return _maxNumListings;
    }
}
