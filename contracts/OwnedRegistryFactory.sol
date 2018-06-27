pragma solidity ^0.4.24;

import "./OwnedRegistry.sol";

/**
* Factory to deploy Owned Registries
**/

contract OwnedRegistryFactory{

    mapping (bytes32 => address) public registries;

    /**
    * Creates a new Owned Registry
    * @param _label a bytes32 label to identify the new created registry
    */

    function newRegistry(bytes32 _label) public returns (OwnedRegistry _reg){
        require(registries[_label] == 0x00);
        OwnedRegistry reg = new OwnedRegistry();
        emit OwnedRegistryCreation(msg.sender);
        reg.transferOwnership(msg.sender);
        registries[_label] = address(reg);
        return reg;
    }

    function getRegistry(bytes32 _label) public view returns (address){
        return registries[_label];
    }

    event OwnedRegistryCreation(address indexed creator);

}
