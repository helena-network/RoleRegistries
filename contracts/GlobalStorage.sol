
//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
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
        address[10] whiteListed;
        uint256 listingCounter;
        uint256 maxNumListings; // By default, only limited by EVM max word
    }

   function init() public{
        address[10] memory b;
        b[0] = address(this);
        AddressRegistryStorage memory a = AddressRegistryStorage(b,0,30);
        strg[0] = a;
        strg[1] = a;
    }


    function _deleteAddress(address _target, address[10] _list) internal pure returns (address[10]){
        uint256 len = _list.length;
        uint256 targetIndex = _findInArray(_target, _list);
        require(targetIndex<9, "Address does not exist");
        _list[targetIndex] = _list[len-1];
        delete _list[len-1];
        return _list;
    }

    function _findInArray(address _target, address[10] _list) internal pure returns (uint256){
        uint256 len = _list.length;
        
        for(uint i = 0; i<len; i++){
            if(_list[i] == _target){
                return i;
            }
        }
        return 101; // return out of bounds if not found
    }

    /****************
    *     Setters
    *****************/

    //TODO: should be internal, making it public to facilitate unit testing
    function _whiteListAddress(address _accountToWhiteList) public {
        AddressRegistryStorage memory currentState = getNext();
        uint256 targetIndex = _findInArray(_accountToWhiteList, currentState.whiteListed);
        require(targetIndex>9, "Address already whitelisted exist");
        currentState.whiteListed[currentState.listingCounter+1] = _accountToWhiteList;
        currentState.listingCounter = currentState.listingCounter.add(1);
        set(currentState);
    }
    //TODO: should be internal, making it public to facilitate unit testing
    function _blackListAddress(address _accountToWhiteList) public {
        AddressRegistryStorage memory currentState = getNext();
        currentState.whiteListed = _deleteAddress(_accountToWhiteList, currentState.whiteListed);
        currentState.listingCounter = currentState.listingCounter.sub(1);
        set(currentState);
    }

    //TODO: should be internal, making it public to facilitate unit testing
    function _setMaxNumListings(uint256 _newMaxNumListings) public {
        AddressRegistryStorage memory currentState = getNext();
        currentState.maxNumListings = _newMaxNumListings;
        set(currentState);
    }

    /****************
    *     Getters 
    *****************/

    //TODO: should be internal, making it public to facilitate unit testing
    function _getAccountFromWhiteListed(address _accountChecked) internal view returns (bool) {
        AddressRegistryStorage memory currentState = getCurrent();
        bool found = _findInArray(_accountChecked, currentState.whiteListed) < 101;
        return found;
    }
    //TODO: should be internal, making it public to facilitate unit testing
    function _getMaxNumListings() public view returns (uint256) {
        AddressRegistryStorage memory currentState = getCurrent();
        return currentState.maxNumListings;
    }

    

    //TODO: should be internal, making it public to facilitate unit testing
    function _getListingCounter() public view returns (uint256) {
        AddressRegistryStorage memory currentState = getCurrent();
        return currentState.listingCounter;
    }

    function getCurrent() internal view returns (AddressRegistryStorage) {
        if (height() > lastSync){
            return strg[1];
        }
        return strg[0];
    }
    
    function updateState() public {
        AddressRegistryStorage memory next = strg[1];
        strg[0] = next;
        lastSync = height();
    }
    
    modifier updatable(){
        if (height() > lastSync){
            updateState();
        }
        _;
    }
    
    function set(AddressRegistryStorage memory _a) internal updatable(){
        // We will always set it in the next one 
        strg[1] = _a;
    }
    
    function getNext() internal updatable() returns (AddressRegistryStorage memory) {
        AddressRegistryStorage memory temp = strg[1];
        return temp;
    }


    ///// Aux

    function height() internal view returns (uint){
        return counter;
    }

    function next() public {
        counter ++;
    }

        // Debug

    function debug_get0() public view returns (uint, address[10]){
        return (strg[0].listingCounter, strg[0].whiteListed);
    }
    
    function debug_get1() public view returns (uint, address[10]){
        return (strg[1].listingCounter, strg[1].whiteListed);
    }
    
    function debug_getCurrent() public view returns (uint, address[10]) {
        if (height() > lastSync){
            return (strg[1].listingCounter, strg[1].whiteListed);
        }
        return (strg[0].listingCounter, strg[0].whiteListed);
    }

}
