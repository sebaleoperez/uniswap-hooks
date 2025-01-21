// SPDX-License-Identifier: MIT
// OpenZeppelin Uniswap Hooks (last updated v0.1.0) (src/base/BaseHook.sol)

pragma solidity ^0.8.24;

import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {BeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";

/**
 * @dev Base hook implementation.
 *
 * This contract defines all hook entry points, as well as security and permission helpers.
 * Based on the https://github.com/Uniswap/v4-periphery/blob/main/src/base/hooks/BaseHook.sol[Uniswap v4 periphery implementation].
 *
 * NOTE: Hook entry points must be overiden and implemented by the inheriting hook to be used. Their respective
 * flags must be set to true in the `getHookPermissions` function as well.
 *
 * WARNING: This is experimental software and is provided on an "as is" and "as available" basis. We do
 * not give any warranties and will not be liable for any losses incurred through any use of this code
 * base.
 *
 * _Available since v0.1.0_
 */
abstract contract BaseHook is IHooks {
    IPoolManager public immutable poolManager;

    /**
     * @dev The hook is not the caller.
     */
    error NotSelf();

    /**
     * @dev The pool is not authorized to use this hook.
     */
    error InvalidPool();

    /**
     * @dev The hook is not unlocked.
     */
    error LockFailure();

    /**
     * @dev The hook function is not implemented.
     */
    error HookNotImplemented();

    /**
     * @notice Thrown when calling unlockCallback where the caller is not `PoolManager`.
     */
    error NotPoolManager();

    /**
     * @dev Set the pool manager and check that the hook address matches the expected permissions and flags.
     */
    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;
        validateHookAddress(this);
    }

    /**
     * @notice Only allow calls from the `PoolManager` contract
     */
    modifier onlyPoolManager() {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        _;
    }

    /**
     * @dev Restrict the function to only be callable by the hook itself.
     */
    modifier onlySelf() {
        if (msg.sender != address(this)) revert NotSelf();
        _;
    }

    /**
     * @dev Restrict the function to only be callable by a valid pool.
     */
    modifier onlyValidPools(IHooks hooks) {
        if (hooks != this) revert InvalidPool();
        _;
    }

    /**
     * @dev Get the hook permissions to signal which hook functions are to be implemented.
     *
     * Used at deployment to validate the address correctly represents the expected permissions.
     *
     * @return permissions The hook permissions.
     */
    function getHookPermissions() public pure virtual returns (Hooks.Permissions memory permissions);

    /**
     * @dev Validate the hook address against the expected permissions.
     */
    function validateHookAddress(BaseHook hook) internal pure {
        Hooks.validateHookPermissions(hook, getHookPermissions());
    }

    /**
     * @dev Force the `onlyPoolManager` modifier by exposing a virtual function after the `onlyPoolManager` check.
     *
     * @param data The calldata to use when unlocking the callback.
     * @return returnData The return data of the callback, which is encoded and decoded according to the implementor's logic
     */
    function unlockCallback(bytes calldata data) external onlyPoolManager returns (bytes memory returnData) {
        returnData = _unlockCallback(data);
    }

    /**
     * @dev Unlock the callback and call itself with the given calldata.
     *
     * @param data The calldata to use, which must be a supported function by the hook.
     */
    function _unlockCallback(bytes calldata data) internal virtual returns (bytes memory) {
        (bool success, bytes memory returnData) = address(this).call(data);
        if (success) return returnData;
        if (returnData.length == 0) revert LockFailure();
        // if the call failed, bubble up the reason
        assembly ("memory-safe") {
            revert(add(returnData, 32), mload(returnData))
        }
    }

    /**
     * @inheritdoc IHooks
     */
    function beforeInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96)
        external
        virtual
        onlyPoolManager
        returns (bytes4)
    {
        return _beforeInitialize(sender, key, sqrtPriceX96);
    }

    /**
     * @dev Hook implementation for `beforeInitialize`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _beforeInitialize(address, PoolKey calldata, uint160) internal virtual returns (bytes4) {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function afterInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, int24 tick)
        external
        virtual
        onlyPoolManager
        returns (bytes4)
    {
        return _afterInitialize(sender, key, sqrtPriceX96, tick);
    }

    /**
     * @dev Hook implementation for `afterInitialize`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _afterInitialize(address, PoolKey calldata, uint160, int24) internal virtual returns (bytes4) {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4) {
        return _beforeAddLiquidity(sender, key, params, hookData);
    }

    /**
     * @dev Hook implementation for `beforeAddLiquidity`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _beforeAddLiquidity(address, PoolKey calldata, IPoolManager.ModifyLiquidityParams calldata, bytes calldata)
        internal
        virtual
        returns (bytes4)
    {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function beforeRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4) {
        return _beforeRemoveLiquidity(sender, key, params, hookData);
    }

    /**
     * @dev Hook implementation for `beforeRemoveLiquidity`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _beforeRemoveLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) internal virtual returns (bytes4) {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta0,
        BalanceDelta delta1,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4, BalanceDelta) {
        return _afterAddLiquidity(sender, key, params, delta0, delta1, hookData);
    }

    /**
     * @dev Hook implementation for `afterAddLiquidity`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _afterAddLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    ) internal virtual returns (bytes4, BalanceDelta) {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function afterRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta0,
        BalanceDelta delta1,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4, BalanceDelta) {
        return _afterRemoveLiquidity(sender, key, params, delta0, delta1, hookData);
    }

    /**
     * @dev Hook implementation for `afterRemoveLiquidity`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _afterRemoveLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    ) internal virtual returns (bytes4, BalanceDelta) {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4, BeforeSwapDelta, uint24) {
        return _beforeSwap(sender, key, params, hookData);
    }

    /**
     * @dev Hook implementation for `beforeSwap`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _beforeSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, bytes calldata)
        internal
        virtual
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4, int128) {
        return _afterSwap(sender, key, params, delta, hookData);
    }

    /**
     * @dev Hook implementation for `afterSwap`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _afterSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, BalanceDelta, bytes calldata)
        internal
        virtual
        returns (bytes4, int128)
    {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function beforeDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4) {
        return _beforeDonate(sender, key, amount0, amount1, hookData);
    }

    /**
     * @dev Hook implementation for `beforeDonate`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _beforeDonate(address, PoolKey calldata, uint256, uint256, bytes calldata)
        internal
        virtual
        returns (bytes4)
    {
        revert HookNotImplemented();
    }

    /**
     * @inheritdoc IHooks
     */
    function afterDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata hookData
    ) external virtual onlyPoolManager returns (bytes4) {
        return _afterDonate(sender, key, amount0, amount1, hookData);
    }

    /**
     * @dev Hook implementation for `afterDonate`, to be overriden by the inheriting hook. The
     * flag must be set to true in the `getHookPermissions` function.
     */
    function _afterDonate(address, PoolKey calldata, uint256, uint256, bytes calldata)
        internal
        virtual
        returns (bytes4)
    {
        revert HookNotImplemented();
    }
}
