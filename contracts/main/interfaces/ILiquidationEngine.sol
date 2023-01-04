// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

interface ILiquidationEngine {
  function liquidate(
    bytes32 _collateralPoolId,
    address _positionAddress,
    uint256 _debtShareToBeLiquidated, // [rad]
    uint256 _maxDebtShareToBeLiquidated, // [rad]
    address _collateralRecipient,
    bytes calldata data
  ) external;

  function liquidate(
    bytes32 _collateralPoolId,
    address _positionAddress,
    uint256 _debtShareToBeLiquidated, // [rad]
    uint256 _maxDebtShareToBeLiquidated, // [rad]
    address _collateralRecipient,
    bytes calldata data,
    address sender
  ) external;

  function batchLiquidate(
    bytes32[] calldata _collateralPoolIds,
    address[] calldata _positionAddresses,
    uint256[] calldata _debtShareToBeLiquidateds, // [rad]
    uint256[] calldata _maxDebtShareToBeLiquidateds, // [rad]
    address[] calldata _collateralRecipients,
    bytes[] calldata datas
  ) external;

  function live() external view returns (uint256);
}