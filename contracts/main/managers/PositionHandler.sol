// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.6.12;

import '../interfaces/IBookKeeper.sol';

contract PositionHandler {
    constructor(address _bookKeeper) public {
        IBookKeeper(_bookKeeper).whitelist(msg.sender);
    }
}
