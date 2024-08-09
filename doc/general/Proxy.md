# Proxy

This documents explains some details about the proxy architecture


## Initialize function

For wrapper modules, we have removed the public function `{ContractName}_init`to reduce the size of the contracts since inside the public initializer function to initialize your proxy, you have to call the difference functions `__{ContractName}_init_unchained`.

Do not forget to call the functions `init_unchained` from the parent initializer if you create your own contract from the different modules.

As indicated in the [OpenZeppelin documentation](https://docs.openzeppelin.com/contracts/5.x/upgradeable#multiple-inheritance): 

> Initializer functions are not linearized by the compiler like constructors. Because of this, each `__{ContractName}_init` function embeds the linearized calls to all parent initializers. As a consequence, calling two of these `init` functions can potentially initialize the same contract twice.
>
> The function `__{ContractName}_init_unchained` found in every contract is the initializer function minus the calls to parent initializers, and can be used to avoid the double initialization problem, but doing this manually is not recommended. We hope to be able to implement safety checks for this in future versions of the Upgrades Plugins.

## ERC-7201

To manage memory and avoid storage collisions, CMTAT implements, like OpenZeppelin, the [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201)

More information on a [RareSkills article](https://www.rareskills.io/post/erc-7201)

## Deployment with a proxy

The CMTAT supports deployment via a proxy contract.  Furthermore, using a proxy permits to upgrade the contract, using a standard proxy upgrade pattern.

The contract version to use as an implementation is the `CMTAT_PROXY`.

Please see the OpenZeppelin [upgradeable contracts documentation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable) for more information about the proxy requirements applied to the contract.

Please see the OpenZeppelin [Upgrades plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for more information about plugin upgrades in general.

Note that deployment via a proxy is not mandatory, but is recommended by CMTA.
