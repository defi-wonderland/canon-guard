# Safer Safe Invariant tests

## Scope

- `SafeEntrypoint`
- `SafeEntrypointFactory`
- `SimpleActions`
- `SimpleTransfers`
- `CappedTokenTransfers`
- `AllowanceClaimor`

## Invariants

The core of the security relying on the Safe contract, these tests are privileging non-revertion/system "froze" over access control.

## Delays assumptions

Some assumptions are introduced as extra-constraints to the reconfiguration of the entrypoint:

- `SHORT_TX_EXECUTION_DELAY` must be less than `LONG_TX_EXECUTION_DELAY`
- `LONG_TX_EXECUTION_DELAY` must be more than `SHORT_TX_EXECUTION_DELAY`
- `TX_EXPIRY_DELAY` must be less than 10 years.
These constraints prevent overflows in `_queueTransaction` (as described in the internal review findings).
