//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATStandalone} from "../deployment/CMTATStandalone.sol";
import {CMTATStandaloneAllowlist} from "../deployment/allowlist/CMTATStandaloneAllowlist.sol";
import {CMTATStandaloneERC1363} from "../deployment/ERC1363/CMTATStandaloneERC1363.sol";
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";

/*
* @title Mock contracts to test _msgData() coverage
*/
contract CMTATStandaloneMsgDataMock is CMTATStandalone {
    event MsgDataReturned(bytes data);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_
    ) CMTATStandalone(forwarderIrrevocable, admin, ERC20Attributes_, extraInformationAttributes_, engines_) {}

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
