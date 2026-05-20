//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATStandardStandalone} from "../deployment/CMTATStandardStandalone.sol";
import {CMTATStandaloneAllowlist} from "../deployment/allowlist/CMTATStandaloneAllowlist.sol";
import {CMTATStandaloneERC1363} from "../deployment/ERC1363/CMTATStandaloneERC1363.sol";
import {CMTATUpgradeableERC1363} from "../deployment/ERC1363/CMTATUpgradeableERC1363.sol";
import {CMTATStandaloneSnapshot} from "../deployment/snapshot/CMTATStandaloneSnapshot.sol";
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";

/*
* @title Mock contracts to test _msgData() coverage
*/
contract CMTATStandaloneMsgDataMock is CMTATStandardStandalone {
    event MsgDataReturned(bytes data);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_
    ) CMTATStandardStandalone(forwarderIrrevocable, admin, ERC20Attributes_, extraInformationAttributes_, engines_) {}

    function getMsgData() external returns (bytes memory) {
        bytes memory data = _msgData();
        emit MsgDataReturned(data);
        return data;
    }
}

contract CMTATStandaloneAllowlistMsgDataMock is CMTATStandaloneAllowlist {
    event MsgDataReturned(bytes data);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_
    ) CMTATStandaloneAllowlist(forwarderIrrevocable, admin, ERC20Attributes_, extraInformationAttributes_) {}

    function getMsgData() external returns (bytes memory) {
        bytes memory data = _msgData();
        emit MsgDataReturned(data);
        return data;
    }
}

contract CMTATStandaloneERC1363MsgDataMock is CMTATStandaloneERC1363 {
    event MsgDataReturned(bytes data);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_
    ) CMTATStandaloneERC1363(forwarderIrrevocable, admin, ERC20Attributes_, extraInformationAttributes_, engines_) {}

    function getMsgData() external returns (bytes memory) {
        bytes memory data = _msgData();
        emit MsgDataReturned(data);
        return data;
    }
}

contract CMTATUpgradeableERC1363MsgDataMock is CMTATUpgradeableERC1363 {
    event MsgDataReturned(bytes data);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address forwarderIrrevocable) CMTATUpgradeableERC1363(forwarderIrrevocable) {}

    function getMsgData() external returns (bytes memory) {
        bytes memory data = _msgData();
        emit MsgDataReturned(data);
        return data;
    }
}

contract CMTATStandaloneSnapshotMsgDataMock is CMTATStandaloneSnapshot {
    event MsgDataReturned(bytes data);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_
    ) CMTATStandaloneSnapshot(forwarderIrrevocable, admin, ERC20Attributes_, extraInformationAttributes_, engines_) {}

    function getMsgData() external returns (bytes memory) {
        bytes memory data = _msgData();
        emit MsgDataReturned(data);
        return data;
    }
}
