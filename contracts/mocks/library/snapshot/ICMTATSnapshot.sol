//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @notice minimum interface to represent a CMTAT with snapshot
*/
interface ICMTATSnapshot {
    /** 
    * @notice Return the number of tokens owned by the given owner at the time when the snapshot with the given time was created.
    * @return value stored in the snapshot, or the actual balance if no snapshot
    */
    function snapshotBalanceOf(uint256 time,address owner) external view returns (uint256);
    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    * Retrieves the total supply at the specified time.
    * @return value stored in the snapshot, or the actual totalSupply if no snapshot
    */
    function snapshotTotalSupply(uint256 time) external view returns (uint256);
    /**
    * @notice Return snapshotBalanceOf and snapshotTotalSupply to avoid multiple calls
    * @return ownerBalance ,  totalSupply - see snapshotBalanceOf and snapshotTotalSupply
    */
    function snapshotInfo(uint256 time, address owner) external view returns (uint256 ownerBalance, uint256 totalSupply);
    /**
    * @notice Return snapshotBalanceOf for each address in the array and the total supply
    * @return ownerBalances array with the balance of each address, the total supply
    */
    function snapshotInfoBatch(uint256 time, address[] calldata addresses) external view returns (uint256[] memory ownerBalances, uint256 totalSupply);

    /**
    * @notice Return snapshotBalanceOf for each address in the array and the total supply
    * @return ownerBalances array with the balance of each address, the total supply
    */
    function snapshotInfoBatch(uint256[] calldata times, address[] calldata addresses) external view returns (uint256[][] memory ownerBalances, uint256[] memory totalSupply);


}
