// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

// Safe Deployments (https://github.com/safe-global/safe-deployments/tree/main/src/assets/v1.4.1)
address constant SAFE = 0x41675C099F32341bf84BFc5382aF534df5C7461a;
address constant SAFE_PROXY_FACTORY = 0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67;
address constant MULTI_SEND_CALL_ONLY = 0x9641d764fc13c8B624c04430C7356C1C7C8102e2;

// Safer Safe
address constant SAFE_ENTRYPOINT_FACTORY = address(0x5afe); // TODO: Replace with the address of the SafeEntrypointFactory contract once deployed

// Wonderland Safer Safe
address constant WONDERLAND_SAFE = 0x74fEa3FB0eD030e9228026E7F413D66186d3D107;
address constant EMERGENCY_CALLER = address(0); // TODO: Replace with the address of the emergency caller (can be contract or EOA)
uint256 constant SHORT_TX_EXECUTION_DELAY = 1 hours;
uint256 constant LONG_TX_EXECUTION_DELAY = 7 days;
uint256 constant DEFAULT_TX_EXPIRY_DELAY = 7 days;

// Ethereum tokens
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
address constant USDS = 0xdC035D45d973E3EC169d2276DDab16f1e407384F;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant L3 = 0x88909D489678dD17aA6D9609F89B0419Bf78FD9a;
address constant GRT = 0xc944E90C64B2c07662A292be6244BDf05Cda44a7;
address constant GTC = 0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F;
address constant CLEAR = 0x58b9cB810A68a7f3e1E4f8Cb45D1B9B3c79705E8;
address constant NEXT = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a;
address constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
address constant EIGEN = 0xec53bF9167f50cDEB3Ae105f56099aaaB9061F83;
address constant KP3R = 0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44;

// Optimism tokens
address constant OP = 0x4200000000000000000000000000000000000042;
address constant KITE = 0xf467C7d5a4A9C4687fFc7986aC6aD5A4c81E1404;
address constant WLD = 0xdC6fF44d5d932Cbd77B52E5612Ba0529DC6226F1;
