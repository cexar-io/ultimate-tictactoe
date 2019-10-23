pragma solidity 0.5.10;

import "ownable.sol";

contract DelegatedGas is Ownable {

    address public proxy = address(0);

    function setProxy (address p) external onlyOwner {
        proxy = p;
    }
    
    function msg_sender() internal view returns(address) {
        uint addr;
        if (proxy != address(0) && msg.sender == proxy) {
            addr = getUint(msg.data,msg.data.length-20, 20);
            return address((addr));
        }
        return msg.sender;
    }

    
    function getUint(bytes memory item, uint offset, uint len) internal pure returns (uint) {
        uint ptr;
        uint ret;
        
        if (len == 1) 
            return uint8(item[offset]);

        assembly {
            ptr := add(add(item, 0x20),offset)
            ret := div(mload(ptr), exp(0x100, sub(0x20, len)))
        }
        return ret;
    }
}