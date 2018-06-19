pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Registry.sol";


/**
* Generic Registry, used for Candidates and Voters
*
**/

contract OwnedRegistry is Registry, Ownable{
    using SafeMath for uint256;

    mapping(address => bool) whiteListed;
    uint256 public listingCounter;

    /**
    * @dev Adds a new account to the registry
    * @param _accountToWhiteList account to be added to the registry
    **/

    function whiteList(address _accountToWhiteList) public {
        require(msg.sender==owner);
        require(!isWhitelisted(_accountToWhiteList));
        whiteListed[_accountToWhiteList] = true;
        listingCounter = listingCounter.add(1);
        emit WhiteList(_accountToWhiteList);
    }

    /**
    * @dev Removes an account from the registry
    * @param _accountToRemove account to be removed from
    **/

    function remove(address _accountToRemove) public {
        require(msg.sender == owner);
        whiteListed[_accountToRemove] = false;
        listingCounter = listingCounter.sub(1);
        emit Remove(_accountToRemove);
    }

   
    /**
    *  @dev Returns true when a listing Hash is already Whitelisted
    *  @param  _accountChecked address being checked
    *  @return whitelisted boolean specifying if the listing is valid
    */

    function isWhitelisted(address _accountChecked) view public returns (bool whitelisted){
        return whiteListed[_accountChecked];
    }

}
