// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

import '../interfaces/IFathomOraclePriceFeed.sol';
import '../interfaces/IFathomOracle.sol';
import '../interfaces/IAccessControlConfig.sol';

contract DelayFathomOraclePriceFeed is PausableUpgradeable, IFathomOraclePriceFeed {
    struct Feed {
        uint256 price;
        uint256 lastUpdateTS;
    }

    Feed public currentPrice;
    uint256 public timeDelay;

    IFathomOracle public fathomOracle;
    IAccessControlConfig public accessControlConfig;
    address public token0;
    address public token1;
    uint256 public priceLife; // [seconds] how old the price is considered stale, default 1 day

    function initialize(
        address _fathomOracle,
        address _token0,
        address _token1,
        address _accessControlConfig
    ) external initializer {
        PausableUpgradeable.__Pausable_init();

        accessControlConfig = IAccessControlConfig(_accessControlConfig);

        fathomOracle = IFathomOracle(_fathomOracle);
        require(_token0 != _token1, 'FathomOraclePriceFeed/wrong-token0-token1');
        token0 = _token0;
        token1 = _token1;
        priceLife = 30 minutes;
        timeDelay = 15 minutes;
    }

    modifier onlyOwner() {
        require(accessControlConfig.hasRole(accessControlConfig.OWNER_ROLE(), msg.sender), '!ownerRole');
        _;
    }

    modifier onlyOwnerOrGov() {
        require(
            accessControlConfig.hasRole(accessControlConfig.OWNER_ROLE(), msg.sender) ||
                accessControlConfig.hasRole(accessControlConfig.GOV_ROLE(), msg.sender),
            '!(ownerRole or govRole)'
        );
        _;
    }

    event LogSetPriceLife(address indexed _caller, uint256 _second);
    event LogSetTimeDelay(address indexed _caller, uint256 _second);

    function setPriceLife(uint256 _second) external onlyOwner {
        require(_second >= 5 minutes && _second <= 1 days, 'FathomOraclePriceFeed/bad-price-life');
        priceLife = _second;
        emit LogSetPriceLife(msg.sender, _second);
    }

    function setTimeDelay(uint256 _second) external onlyOwner {
        require(_second >= 5 minutes && _second <= 1 days, 'FathomOraclePriceFeed/bad-delay-time');
        timeDelay = _second;
        emit LogSetTimeDelay(msg.sender, _second);
    }

    function pause() external onlyOwnerOrGov {
        _pause();
    }

    function unpause() external onlyOwnerOrGov {
        _unpause();
    }

    function readPrice() external view override returns (bytes32) {
        uint256 _price = currentPrice.price;
        return bytes32(_price);
    }

    function peekPrice() external override returns (bytes32, bool) {
        if (currentPrice.price == 0 || block.timestamp >= currentPrice.lastUpdateTS + timeDelay) {
            (uint256 _price, uint256 _lastUpdate) = fathomOracle.getPrice(token0, token1);
            currentPrice.price = _price;
            currentPrice.lastUpdateTS = _lastUpdate;
            return (bytes32(currentPrice.price), _isPriceOk());
        } else {
            return (bytes32(currentPrice.price), _isPriceOk());
        }
    }

    function isPriceOk() external view override returns (bool) {
        return _isPriceOk();
    }

    function _isPriceFresh() internal view returns (bool) {
        return currentPrice.lastUpdateTS >= block.timestamp - priceLife;
    }

    function _isPriceOk() internal view returns (bool) {
        return _isPriceFresh() && !paused();
    }
}
