# Safer Safe Invariant tests

/!\ As of writing, Forge Foundry does not use corpus and coverage guided fuzzing
by default - use the nightly version (1.3.0) if desired: `foundryup --install nightly` /!\

## Scope

- `SafeEntrypoint`
- `SafeEntrypointFactory`
- `SimpleActions`
- `SimpleTransfers`
- `CappedTokenTransfers` and hub
- `AllowanceClaimor`

## Invariants

The core of the security relying on the Safe contract, these tests are privileging non-revertion/system "frozen" state.

Caps of any capped token transfers are never exceeded.

## Setup

The different action hub targets are all a single mock contract, `ActionTarget`, which is used to test the correct interaction with any arbitrary external contract (by setting flags which are then asserted in the invariants).

Each action builders and hubs are in a dedicated handler, handling both queueing and execution. This should allow enough flexibility to add new action builders in the future.

## Delays assumptions

Some assumptions are introduced as extra-constraints to the reconfiguration of the entrypoint:

- `SHORT_TX_EXECUTION_DELAY` must be less than `LONG_TX_EXECUTION_DELAY`
- `LONG_TX_EXECUTION_DELAY` must be more than `SHORT_TX_EXECUTION_DELAY`
- `TX_EXPIRY_DELAY` must be less than 10 years.
These constraints prevent overflows in `_queueTransaction` (as described in the internal review findings).
