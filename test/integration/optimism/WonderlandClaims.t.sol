// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ISimpleActions} from 'src/interfaces/actions-builders/ISimpleActions.sol';
import {IntegrationOptimismBase} from 'test/integration/optimism/IntegrationOptimismBase.sol';

contract IntegrationWonderlandClaims is IntegrationOptimismBase {
  address internal _actionsBuilder;

  address internal _opx = 0x1828Bff08BD244F7990edDCd9B19cc654b33cDB4;
  address internal _kiteVestingPlans = 0x1bb64AF7FE05fc69c740609267d2AbE3e119Ef82;
  address internal _wldVestingWallet = 0x5823c2D5cDB86547d10c312E7d3260603CdD085b;

  uint256 internal _claimableOP = 1_838_470_586_676_954_568_000;
  uint256 internal _claimableKITE = 1_026_331_380_010_145_208_370;
  uint256 internal _claimableWLD = 25_000 ether;

  function setUp() public override {
    super.setUp();

    // Deploy the SimpleActions contract
    uint256 _opxBalance = IERC20(_opx).balanceOf(address(SAFE_PROXY));
    ISimpleActions.SimpleAction memory _claimOP = ISimpleActions.SimpleAction({
      target: address(_opx),
      signature: 'downgrade(uint256)',
      data: abi.encode(_opxBalance),
      value: 0
    });

    uint256[] memory _plans = new uint256[](1);
    _plans[0] = 9;
    ISimpleActions.SimpleAction memory _claimKITE = ISimpleActions.SimpleAction({
      target: address(_kiteVestingPlans),
      signature: 'redeemPlans(uint256[])',
      data: abi.encode(_plans),
      value: 0
    });

    ISimpleActions.SimpleAction memory _claimWLD = ISimpleActions.SimpleAction({
      target: address(_wldVestingWallet),
      signature: 'release(address)',
      data: abi.encode(address(WLD)),
      value: 0
    });

    ISimpleActions.SimpleAction[] memory _simpleActions = new ISimpleActions.SimpleAction[](3);
    _simpleActions[0] = _claimOP;
    _simpleActions[1] = _claimKITE;
    _simpleActions[2] = _claimWLD;

    _actionsBuilder = simpleActionsFactory.createSimpleActions(_simpleActions);
  }

  function test_ExecuteTransaction() public {
    assertEq(OP.balanceOf(address(SAFE_PROXY)), _safeBalance);
    assertEq(KITE.balanceOf(address(SAFE_PROXY)), _safeBalance);
    assertEq(WLD.balanceOf(address(SAFE_PROXY)), _safeBalance);

    // Allow the SafeEntrypoint to call the SimpleTransfers contract
    uint256 _approvalDuration = block.timestamp + 1 days;

    vm.prank(address(SAFE_PROXY));
    safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration);

    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(_actionsBuilder);

    // Wait for the timelock period
    vm.warp(block.timestamp + SHORT_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(_actionsBuilder);

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(_actionsBuilder);

    // Assert the token balances
    assertEq(OP.balanceOf(address(SAFE_PROXY)), _claimableOP + _safeBalance);
    assertEq(KITE.balanceOf(address(SAFE_PROXY)), _claimableKITE + _safeBalance);
    assertEq(WLD.balanceOf(address(SAFE_PROXY)), _claimableWLD + _safeBalance);
  }
}
