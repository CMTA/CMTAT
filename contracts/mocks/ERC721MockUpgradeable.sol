// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IERC165} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "../modules/CMTATBaseGeneric.sol";

/**
 * @dev This is an example contract implementation of NFToken.
 */
contract ERC721MockUpgradeable is ERC721Upgradeable, CMTATBaseGeneric {
  error CMTAT_InvalidTransfer(address from, address to, uint256 tokenId);

    function initialize(
      string memory name_, string memory symbol_, 
      address admin, ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,IERC1643 documentEngine) public virtual initializer{
        __ERC721_init_unchained(name_, symbol_);
        __CMTAT_init(admin, baseModuleAttributes_, documentEngine);
  }
  /**
   * @notice Mints a new NFT.
   * @param to The address that will own the minted NFT.
   * @param tokenId NFT tokenId
   */
  function mint(address to, uint256 tokenId) public {
    require(
      _canMintBurnByModule(to),
      CMTAT_InvalidTransfer(address(0), to, tokenId)
    );
    ERC721Upgradeable._mint(to, tokenId);
  }

  function burn(uint256 tokenId) external {
    address currentOwner = ownerOf(tokenId);
    require(
      _canMintBurnByModule(currentOwner),
      CMTAT_InvalidTransfer(currentOwner, address(0), tokenId)
    );
    ERC721Upgradeable._burn( tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) public virtual override {
    require(_canTransferGenericByModule(msg.sender, from, to), CMTAT_InvalidTransfer(from, to, tokenId));
    ERC721Upgradeable.safeTransferFrom(from, to, tokenId, data);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public override {
    require(_canTransferGenericByModule(msg.sender, from, to), CMTAT_InvalidTransfer(from, to, tokenId));
    ERC721Upgradeable.transferFrom(from, to, tokenId);
  }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return ERC721Upgradeable.supportsInterface(interfaceId) || AccessControlUpgradeable.supportsInterface(interfaceId);
    }


}
