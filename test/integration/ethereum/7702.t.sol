// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISimpleTransfers} from 'interfaces/actions-builders/ISimpleTransfers.sol';
import {Approver} from 'src/contracts/Approver.sol';
import {IntegrationEthereumBase} from 'test/integration/ethereum/IntegrationEthereumBase.sol';

contract Integration7702 is IntegrationEthereumBase {
    // Dummy keys from foundry example
  address payable ALICE_ADDRESS = payable(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
  uint256 constant ALICE_PK = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

  address internal _approverImplementation;
  address internal _actionsBuilder;

  address internal _salariesDeposit = 0xa7242329Fa88d501f2D2Abe7d63FFC8C5dA38A99;

  function setUp() public override {
    super.setUp();

    // Deploy Approver implementation
    _approverImplementation = address(new Approver(address(safeEntrypoint)));

    // Deploy the SimpleTransfers contract
    ISimpleTransfers.TransferAction memory _salariesTransferAction =
      ISimpleTransfers.TransferAction({token: address(USDC), to: _salariesDeposit, amount: _safeBalance});
    ISimpleTransfers.TransferAction[] memory _transferActions = new ISimpleTransfers.TransferAction[](1);
    _transferActions[0] = _salariesTransferAction;
    _actionsBuilder = simpleTransfersFactory.createSimpleTransfers(_transferActions);

    // Add ALICE as a Safe owner, reduce the threshold to 1
    vm.startPrank(address(SAFE_PROXY));
    SAFE_PROXY.addOwnerWithThreshold(ALICE_ADDRESS, 1);
    vm.stopPrank();
  }

  function test_7702() public {
    // Allow the SafeEntrypoint to call the SimpleTransfers contract
    uint256 _approvalDuration = block.timestamp + 1 days;

    vm.prank(address(SAFE_PROXY));
    safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration);

    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(_actionsBuilder);

    // Wait for the timelock period
    vm.warp(block.timestamp + SHORT_TX_EXECUTION_DELAY);

    // Alice signs a delegation allowing `implementation` to execute transactions on her behalf.
    vm.signAndAttachDelegation(_approverImplementation, ALICE_PK);

    // Verify that Alice's account now behaves as a smart contract.
    bytes memory code = address(ALICE_ADDRESS).code;
    require(code.length > 0, 'no code written to Alice');

    // Execute approveTx()
    vm.startPrank(ALICE_ADDRESS);
    Approver(ALICE_ADDRESS).approveTx(address(_actionsBuilder), SAFE_PROXY.nonce());
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(_actionsBuilder);

    // Assert the token balances
    assertEq(USDC.balanceOf(_salariesDeposit), _safeBalance);
    assertEq(USDC.balanceOf(address(SAFE_PROXY)), 0);
  }
}
