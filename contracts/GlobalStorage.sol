

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

pragma solidity 0.4.24;

contract GlobalStorage {
    using SafeMath for uint256;
    // old/new slots    //epoch    //storage
    //mapping(uint32 => mapping (uint256 => AddressRegistryStorage)) strg;

    AddressRegistryStorage[2] strg;


    uint256 public lastSync;
    uint256 public counter;

    struct AddressRegistryStorage {
        address[100] whiteListed;
        uint256 listingCounter;
        uint256 maxNumListings; // By default, only limited by EVM max word
    }

	function _debug() public view returns (address[100],uint256,uint256){
		return (strg[get()].whiteListed, strg[get()].listingCounter,get());
	}

    function _deleteAddress(address _target, address[100] _list) internal returns (address[100]){
        uint256 len = _list.length;
        uint256 targetIndex = _findInArray(_target, _list);
        require(targetIndex<101, "Address does not exist");
        _list[targetIndex] = _list[len-1];
        delete _list[len-1];
        return _list;
            
    }

    function _findInArray(address _target, address[100] _list) internal returns (uint256){
        uint256 len = _list.length;
        uint256 targetIndex=0;
        bool found = false;

        for(uint i = 0; i<len; i++){
            if(_list[i] == _target){
                return i;
            }
        }
        return 101; // return out of bounds if not found
    }

    //TODO: should be internal, making it public to facilitate unit testing
    function _whiteListAddress(address _accountToWhiteList) public {
        AddressRegistryStorage memory currentState = strg[get()];
        currentState.whiteListed[currentState.listingCounter] = _accountToWhiteList;
        currentState.listingCounter = currentState.listingCounter.add(1);
        set(currentState);
    }
    //TODO: should be internal, making it public to facilitate unit testing
    function _blackListAddress(address _accountToWhiteList) public {
        AddressRegistryStorage memory currentState = strg[get()];
        currentState.whiteListed = _deleteAddress(_accountToWhiteList, currentState.whiteListed);
        currentState.listingCounter = currentState.listingCounter.sub(1);
        set(currentState);
    }
    //TODO: should be internal, making it public to facilitate unit testing
    function _getAccountFromWhiteListed(address _accountChecked) internal view returns (bool) {
        AddressRegistryStorage memory currentState = strg[get()];
        bool found = _findInArray(_accountChecked, currentState.whiteListed) < 101;
        return found;
    }
    //TODO: should be internal, making it public to facilitate unit testing
    function _getMaxNumListings() public view returns (uint256) {
        AddressRegistryStorage memory currentState = strg[get()];
        return currentState.maxNumListings;
    }

    //TODO: should be internal, making it public to facilitate unit testing
    function _setMaxNumListings(uint256 _newMaxNumListings) public view {
        AddressRegistryStorage memory currentState = strg[get()];
        currentState.maxNumListings = _newMaxNumListings;
        set(currentState);
    }

    //TODO: should be internal, making it public to facilitate unit testing
    function _getListingCounter() public view returns (uint256) {
        AddressRegistryStorage memory currentState = strg[get()];
        return currentState.listingCounter;
    }



    function init() public {
        /*
             mapping(address => bool) whiteListed;
        uint256 listingCounter;
        uint256 maxNumListings; // By default, only limited by EVM max word
        */
        address[100] memory _temp;
        AddressRegistryStorage memory initStruct = AddressRegistryStorage(_temp,0,10000);
        strg[0] = initStruct;
        strg[1] = initStruct;
    }


    function set(AddressRegistryStorage _a) internal {
        if(height() > lastSync) {
            strg[0] = _a;  // This should not be set if it is in the cooling period  
        }

        else{
            strg[1] = _a;  // This should not be set if it is in the cooling period 
            lastSync = height();
        }

    }

    function get() internal view returns (uint32) { 
        if(lastSync == height()){
            return  0;
        }
        else{ 
            return  1;
        }
    }


    ///// Aux

    function height() internal view returns (uint){
        return counter;
    }

    function next() public {
        counter ++;
    }

}
