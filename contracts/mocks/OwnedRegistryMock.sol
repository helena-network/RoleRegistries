
//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../OwnedRegistry.sol";

pragma solidity 0.4.24;

contract OwnedRegistryMock is OwnedRegistry {
    using SafeMath for uint256;
    
    uint256 public counter;
    
    ///// Aux

    function height() internal view returns (uint){
        return counter;
    }

    function next() public {
        counter ++;
    }

        // Debug

    function debug_get0() public view returns (uint, address[5]){
        return (strg[0].listingCounter, strg[0].whiteListed);
    }
    
    function debug_get1() public view returns (uint, address[5]){
        return (strg[1].listingCounter, strg[1].whiteListed);
    }
    
    function debug_getCurrent() public view returns (uint, address[5]) {
        if (height() > lastSync){
            return (strg[1].listingCounter, strg[1].whiteListed);
        }
        return (strg[0].listingCounter, strg[0].whiteListed);
    }

    function debug_getArchive(uint256 _index) public view returns (address[5]){
        return _getEpochFromArchive(_index).whiteListed;
    }

    function debug_getArchiveAndPeriod(uint256 _index) public view returns (uint256,address[5]){
        Archive memory arch = archive[_index]; 
        return (arch.epoch, arch.item.whiteListed);
    }


    function debug_getArchiveSize() public view returns (uint256){
        return archive.length;
    }

    function debug_forceUpdate() public updatable() {
        return;
    }

}
