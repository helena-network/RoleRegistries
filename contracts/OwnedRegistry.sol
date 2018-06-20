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

    struct Application {
        uint256 stakedAmount;
        string data;
        bool approved;
    }

    mapping(bytes32 => Application) applications;

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
        emit _WhiteList(_accountToWhiteList);
    }

    /**
    * @dev Removes an account from the registry
    * @param _accountToRemove account to be removed from
    **/

    function remove(address _accountToRemove) public {
        require(msg.sender == owner);
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

    function apply(bytes32 _id, uint _amount, string _data) external{
        require(_id == keccak256(msg.sender, amount, data));
        require(token.transferFrom(msg.sender, address(this), _amount));
        applications[_id] = Application(_amount, _data, false);
        emit Application(_id, _amount, _data, msg.sender);
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
