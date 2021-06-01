pragma solidity ^0.8.0;

// required OZ imports here
import "./openzeppelin-contacts/contracts/proxy/uutils/Initializable.sol"
import "./openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol"
import "./openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol"


contract CMTAT is Initializable, ERC20Burnable, ERC20Upgradeable{

    function initialize () public initializer {
        //__ERC20_init("My Token", "MT");
        //_mint(msg.sender, 1000000000000000000000000);
    }
}
