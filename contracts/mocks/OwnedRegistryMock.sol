
//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import * as LoadPeriodMock from "@frontier-token-research/cron/contracts/mocks/PeriodMock.sol";
import "../OwnedRegistry.sol";

pragma solidity 0.4.24;

contract OwnedRegistryMock is OwnedRegistry {
    using SafeMath for uint256;
    
    //uint256 public counter;
    
    ///// Aux

    constructor(address[] _whiteListedAccounts , address _periodAddress)
        OwnedRegistry()
        public
    {
        if(_whiteListedAccounts.length > 0){
            uint256 _hardMaxNumListingsLimit = 5;
            uint256 _initMaxNumListings = 5;
            init(_hardMaxNumListingsLimit, _initMaxNumListings,  _periodAddress);    
        }
        for (uint i = 0; i < _whiteListedAccounts.length; i++){
            whitelistCurrentPeriod(_whiteListedAccounts[i]);
        }
    }

    // function height() internal view returns (uint){
    //     return counter;
    // }

    // function next() public {
    //     counter=counter;
    // }

    // Debug

    function debug_getArchive(uint256 _index) public view returns (address[20]){
        return _getEpochFromArchive(_index).whiteListed;
    }

    function debug_forceUpdate() public updatable() {
        return;
    }
    // function debug_get0() public view returns (uint, address[5]){
    //     return (strg[0].listingCounter, strg[0].whiteListed);
    // }
    
    // function debug_get1() public view returns (uint, address[5]){
    //     return (strg[1].listingCounter, strg[1].whiteListed);
    // }
    
    // function debug_getCurrent() public view returns (uint, address[5]) {
    //     if (height() > lastSync){
    //         return (strg[1].listingCounter, strg[1].whiteListed);
    //     }
    //     return (strg[0].listingCounter, strg[0].whiteListed);
    // }

    // function debug_getArchiveAndPeriod(uint256 _index) public view returns (uint256,address[5]){
    //     Archive memory arch = archive[_index]; 
    //     return (arch.epoch, arch.item.whiteListed);
    // }


    // function debug_getArchiveSize() public view returns (uint256){
    //     return archive.length;
    // }
}
