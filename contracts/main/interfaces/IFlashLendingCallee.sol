// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

interface IFlashLendingCallee {
    function flashLendingCall(
        address caller,
        uint256 debtValueToRepay, // [rad]
        uint256 collateralAmountToLiquidate, // [wad]
        bytes calldata
    ) external;
}
