
//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "@frontier-token-research/cron/contracts/IPeriod.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

pragma solidity 0.4.24;

contract GlobalStorage {
    using SafeMath for uint256;
    // old/new slots    //epoch    //storage
    //mapping(uint32 => mapping (uint256 => AddressRegistryStorage)) strg;

    AddressRegistryStorage[2] strg;

    Archive[] archive;


    uint256 public lastSync;
    uint256 public hardMaxNumListingsLimit;
    bool    public isInit = false;

    IPeriod period;

    struct AddressRegistryStorage {
        address[5] whiteListed;
        uint256 listingCounter;
        uint256 maxNumListings; // By default, only limited by EVM max word
    }

    struct Archive{
        uint256 epoch;
        AddressRegistryStorage item;
    }

    modifier onlyOnce() {
        require(!isInit);
        _;
    }

   function init(uint256 _hardMaxNumListingsLimit, uint256 _initMaxNumListings, address _periodAddress) public onlyOnce() {
        require(!isInit);
        address[5] memory b;
        AddressRegistryStorage memory a = AddressRegistryStorage(b,0,_initMaxNumListings);
        strg[0] = a;
        strg[1] = a;
        //_addToArchive(0,a);
        period = IPeriod(_periodAddress);
        isInit = true;
    }


    function _deleteAddress(address _target, address[5] _list) internal pure returns (address[5]){
        uint256 len = _list.length;
        uint256 targetIndex = _findInArray(_target, _list);
        require(targetIndex<9, "Address does not exist");
        _list[targetIndex] = _list[len-1];
        delete _list[len-1];
        return _list;
    }

    function _findInArray(address _target, address[5] _list) internal pure returns (uint256){
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
        currentState.whiteListed[currentState.listingCounter] = _accountToWhiteList;
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

    

    function _addToArchive(uint256 _epoch, AddressRegistryStorage _item) internal {
        Archive memory newItem = Archive(_epoch, _item);
        archive.push(newItem);
    }

    /****************
    *     Getters 
    *****************/

    function _findArchiveTarget(uint256 _epoch) internal view returns (uint256) {
        uint256 archiveLength = archive.length;
       
       for(uint256 i = 0; i<archiveLength;i++){
        if(archive[i].epoch == _epoch){
            return i;
        }
       } 
    }

    function _getEpochFromArchive(uint256 _epoch) internal view returns (AddressRegistryStorage) {
       require(_epoch < height(),"Can not get current epoch from archive");
       uint256 targetIndex = _findArchiveTarget(_epoch);
       AddressRegistryStorage memory target = archive[targetIndex].item;
       return target;
    }

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

    //TODO: should be internal, making it public to facilitate unit testing
    function _getNextListingCounter() public view returns (uint256) {
        AddressRegistryStorage memory currentState = getNext();
        return currentState.listingCounter;
    }

    function getCurrent() internal view returns (AddressRegistryStorage) {
        if (height() > lastSync){
            return strg[1];
        }
        return strg[0];
    }

    function getWhitelistedFromEpoch(uint256 _epoch) public view returns (address[5] elements) {
        return _getEpochFromArchive(_epoch).whiteListed;

    }

    // this was updatable before, I removed it because didnt see a need for it
    // to be updatable, but I might be wrong
    function getNext() internal view returns (AddressRegistryStorage memory) {
        AddressRegistryStorage memory temp = strg[1];
        return temp;
    }
    
    function updateState(uint256 _height) public {
        AddressRegistryStorage memory curr = strg[0];
        _addToArchive(_height-1, curr);
        AddressRegistryStorage memory next = strg[1];
        strg[0] = next;
        lastSync = _height;
    }
    
    modifier updatable() {
        uint256 currHeight = height();
        if (currHeight > lastSync) {
            updateState(currHeight);
        }
        _;
    }
    
    function set(AddressRegistryStorage memory _a) internal updatable() {
        // We will always set it in the next one 
        strg[1] = _a;
    }
    
    ///// Aux
    function height() internal view returns (uint){
        return period.height();
    }

    /***********
    Override functions
    This set of functions exists to allow the addition/removal of users during the same period
    ************/

    function whitelistCurrentPeriod(address _accountToWhiteList) public updatable(){
        AddressRegistryStorage memory currentState = strg[0];
        AddressRegistryStorage memory nextState = strg[1];

        bool addTo0 = _findInArray(_accountToWhiteList, currentState.whiteListed) == 101;
        bool addTo1 = _findInArray(_accountToWhiteList, nextState.whiteListed) == 101;

        require(addTo0, "Address already whitelisted");

        currentState.whiteListed[currentState.listingCounter] = _accountToWhiteList;
        currentState.listingCounter = currentState.listingCounter.add(1);
        strg[0] = currentState;

        if(addTo1){
            nextState.whiteListed[nextState.listingCounter] = _accountToWhiteList;
            nextState.listingCounter = nextState.listingCounter.add(1);
            strg[1] = nextState;                
        }
    }

    function blacklistCurrentPeriod(address _accountToBlacklist) public updatable(){
        AddressRegistryStorage memory currentState = strg[0];
        AddressRegistryStorage memory nextState = strg[1];

        bool removeFrom1 = _findInArray(_accountToBlacklist, currentState.whiteListed) < 101;
        bool removeFrom2 = _findInArray(_accountToBlacklist, nextState.whiteListed) < 101;

        require(removeFrom1, "Address is not whitelisted");

        currentState.whiteListed = _deleteAddress(_accountToBlacklist, currentState.whiteListed);
        currentState.listingCounter = currentState.listingCounter.sub(1);
        strg[0] = currentState;

        if(removeFrom2){
            nextState.whiteListed = _deleteAddress(_accountToBlacklist, nextState.whiteListed);
            nextState.listingCounter = nextState.listingCounter.sub(1);
            strg[1] = nextState;                
        }
        
    }
}
