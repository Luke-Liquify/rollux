// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console2 as console } from "forge-std/console2.sol";
import { SafeBuilder } from "../universal/SafeBuilder.sol";
import { IGnosisSafe, Enum } from "../interfaces/IGnosisSafe.sol";
import { IMulticall3 } from "forge-std/interfaces/IMulticall3.sol";
import { Predeploys } from "../../src/libraries/Predeploys.sol";
import { ProxyAdmin } from "../../src/universal/ProxyAdmin.sol";
import { Deployer } from "../Deployer.sol";

/// @title PostSherlockL2
/// @notice Upgrades the L2 contracts.
contract PostSherlockL2 is SafeBuilder, Deployer {
    /// @notice The proxy admin predeploy on L2.
    ProxyAdmin immutable PROXY_ADMIN = ProxyAdmin(Predeploys.PROXY_ADMIN);

    /// @notice Represents a set of L2 predepploy contracts. Used to represent a set of
    ///         implementations and also a set of proxies.
    struct ContractSet {
        address BaseFeeVault;
        address GasPriceOracle;
        address L1Block;
        address L1FeeVault;
        address L2CrossDomainMessenger;
        address L2ERC721Bridge;
        address L2StandardBridge;
        address L2ToL1MessagePasser;
        address SequencerFeeVault;
        address OptimismMintableERC20Factory;
        address OptimismMintableERC721Factory;
        address EAS;
        address SchemaRegistry;
    }

    /// @notice A mapping of chainid to a ContractSet of implementations.
    mapping(uint256 => ContractSet) internal implementations;

    /// @notice A mapping of chainid to ContractSet of proxy addresses.
    mapping(uint256 => ContractSet) internal proxies;

    /// @notice The expected versions for the contracts to be upgraded to.
    string constant internal BaseFeeVault_Version = "1.2.0";
    string constant internal GasPriceOracle_Version = "1.0.0";
    string constant internal L1Block_Version = "1.0.0";
    string constant internal L1FeeVault_Version = "1.2.0";
    string constant internal L2CrossDomainMessenger_Version = "1.4.0";
    string constant internal L2ERC721Bridge_Version = "1.1.0";
    string constant internal L2StandardBridge_Version = "1.1.0";
    string constant internal L2ToL1MessagePasser_Version = "1.0.0";
    string constant internal SequencerFeeVault_Version = "1.2.0";
    string constant internal OptimismMintableERC20Factory_Version = "1.1.0";
    string constant internal OptimismMintableERC721Factory_Version = "1.2.0";
    string constant internal EAS_Version = "1.3.0";
    string constant internal SchemaRegistry_Version = "1.3.0";

    /// @notice Place the contract addresses in storage so they can be used when building calldata.
    function setUp() public override {
        super.setUp();
        implementations[OP_GOERLI] = ContractSet({
            BaseFeeVault: 0x73ae51299eCA0167a5956e3D1DaE3D98b06CcD9D,
            GasPriceOracle: 0xD6EA7Ac2455c4f8D52c0feAb893c6F0d71e43dC9,
            L1Block: 0x48d6759fe9d583a7f685d8FfB96B62e5fddfE655,
            L1FeeVault: 0x8ABee9676742a71b1b96F2e5E9c180E8f621793F,
            L2CrossDomainMessenger: 0x77e4F622a2903149D00ACf3398Bf6288618f6AbD,
            L2ERC721Bridge: 0xDd9D39bB7760De3b4b7672f2537Bdee172b67f7C,
            L2StandardBridge: 0xCca5e2FD156D0eC93F12Aa5147a72176E3059ab1,
            L2ToL1MessagePasser: 0x7C12CFc99386F775a63bd95642299843e185e50E,
            SequencerFeeVault: 0xbb0D433fFCeE8738bB60dd82AF9207e2ddD30372,
            OptimismMintableERC20Factory: 0x9C1b34e67daD1441fcf379A000f06D4b061Aa1cF,
            OptimismMintableERC721Factory: 0xF118Fa4553b9c1CB38a1822234014B3550cF09e2,
            EAS: 0x7a7a83998F737d126FE3742F638E571C47928BD1,
            SchemaRegistry: 0x9f49A8d186b89d98Fd44e14d61c899627D5818c0
        });

        proxies[OP_GOERLI] = ContractSet({
            BaseFeeVault: Predeploys.BASE_FEE_VAULT,
            GasPriceOracle: Predeploys.GAS_PRICE_ORACLE,
            L1Block: Predeploys.L1_BLOCK_ATTRIBUTES,
            L1FeeVault: Predeploys.L1_FEE_VAULT,
            L2CrossDomainMessenger: Predeploys.L2_CROSS_DOMAIN_MESSENGER,
            L2ERC721Bridge: Predeploys.L2_ERC721_BRIDGE,
            L2StandardBridge: Predeploys.L2_STANDARD_BRIDGE,
            L2ToL1MessagePasser: Predeploys.L2_TO_L1_MESSAGE_PASSER,
            SequencerFeeVault: Predeploys.SEQUENCER_FEE_WALLET,
            OptimismMintableERC20Factory: Predeploys.OPTIMISM_MINTABLE_ERC20_FACTORY,
            OptimismMintableERC721Factory: Predeploys.OPTIMISM_MINTABLE_ERC721_FACTORY,
            EAS: Predeploys.EAS,
            SchemaRegistry: Predeploys.SCHEMA_REGISTRY
        });
        implementations[OP_MAINNET] = ContractSet({
            BaseFeeVault: 0x63D297aa3feCbf6eEdE0aCd15B0308B9C8379afb,
            GasPriceOracle: 0xf2ad472ade2009Ef5eeb26B7fe27BA9fd27dE46A,
            L1Block: 0x92e692a4E075D09B1a66347b5cB26aE0c1839482,
            L1FeeVault: 0x51ac8093D762BBD17C8d898634916dAc14e1BCC1,
            L2CrossDomainMessenger: 0x2b76AaE10952527b8b34Ead1C1703F53fCfC8B27,
            L2ERC721Bridge: 0x04E0Bc2f892C2C0214f7868d4aDE7378d9ec6873,
            L2StandardBridge: 0x921537110D0a929B7Ab56e6E5058306A7112aC19,
            L2ToL1MessagePasser: 0xd513d73EeF8A464A65b76770491FDE9BacEb5b83,
            SequencerFeeVault: 0x39CadECd381928F1330D1B2c13c8CAC358Dce65A,
            OptimismMintableERC20Factory: 0x61200B9fcBB421aFD0Bb5A732fe48ec98482E39C,
            OptimismMintableERC721Factory: 0x1a196196C3afD9f702cA722095904Fc97812Ee02,
            EAS: 0x7a7a83998F737d126FE3742F638E571C47928BD1,
            SchemaRegistry: 0x9f49A8d186b89d98Fd44e14d61c899627D5818c0
        });

        proxies[OP_MAINNET] = ContractSet({
            BaseFeeVault: Predeploys.BASE_FEE_VAULT,
            GasPriceOracle: Predeploys.GAS_PRICE_ORACLE,
            L1Block: Predeploys.L1_BLOCK_ATTRIBUTES,
            L1FeeVault: Predeploys.L1_FEE_VAULT,
            L2CrossDomainMessenger: Predeploys.L2_CROSS_DOMAIN_MESSENGER,
            L2ERC721Bridge: Predeploys.L2_ERC721_BRIDGE,
            L2StandardBridge: Predeploys.L2_STANDARD_BRIDGE,
            L2ToL1MessagePasser: Predeploys.L2_TO_L1_MESSAGE_PASSER,
            SequencerFeeVault: Predeploys.SEQUENCER_FEE_WALLET,
            OptimismMintableERC20Factory: Predeploys.OPTIMISM_MINTABLE_ERC20_FACTORY,
            OptimismMintableERC721Factory: Predeploys.OPTIMISM_MINTABLE_ERC721_FACTORY,
            EAS: Predeploys.EAS,
            SchemaRegistry: Predeploys.SCHEMA_REGISTRY
        });
    }

    /// @notice
    function name() public pure override returns (string memory) {
        return "PostSherlockL2";
    }

    /// @notice Follow up assertions to ensure that the script ran to completion.
    function _postCheck() internal view override {
        ContractSet memory prox = getProxies();
        require(_versionHash(prox.BaseFeeVault) == keccak256(bytes(BaseFeeVault_Version)), "BaseFeeVault");
        require(_versionHash(prox.GasPriceOracle) == keccak256(bytes(GasPriceOracle_Version)), "GasPriceOracle");
        require(_versionHash(prox.L1Block) == keccak256(bytes(L1Block_Version)), "L1Block");
        require(_versionHash(prox.L1FeeVault) == keccak256(bytes(L1FeeVault_Version)), "L1FeeVault");
        require(
            _versionHash(prox.L2CrossDomainMessenger) == keccak256(bytes(L2CrossDomainMessenger_Version)),
            "L2CrossDomainMessenger"
        );
        require(_versionHash(prox.L2ERC721Bridge) == keccak256(bytes(L2ERC721Bridge_Version)), "L2ERC721Bridge");
        require(_versionHash(prox.L2StandardBridge) == keccak256(bytes(L2StandardBridge_Version)), "L2StandardBridge");
        require(
            _versionHash(prox.L2ToL1MessagePasser) == keccak256(bytes(L2ToL1MessagePasser_Version)),
            "L2ToL1MessagePasser"
        );
        require(
            _versionHash(prox.SequencerFeeVault) == keccak256(bytes(SequencerFeeVault_Version)), "SequencerFeeVault"
        );
        require(
            _versionHash(prox.OptimismMintableERC20Factory) == keccak256(bytes(OptimismMintableERC20Factory_Version)),
            "OptimismMintableERC20Factory"
        );
        require(
            _versionHash(prox.OptimismMintableERC721Factory) == keccak256(bytes(OptimismMintableERC721Factory_Version)),
            "OptimismMintableERC721Factory"
        );
        require( _versionHash(prox.EAS) == keccak256(bytes(EAS_Version)), "EAS");
        require( _versionHash(prox.SchemaRegistry) == keccak256(bytes(SchemaRegistry_Version)), "SchemaRegistry");
        // Check that the codehashes of all implementations match the proxies set implementations.
        ContractSet memory impl = getImplementations();
        require(PROXY_ADMIN.getProxyImplementation(prox.BaseFeeVault).codehash == impl.BaseFeeVault.codehash);
        require(PROXY_ADMIN.getProxyImplementation(prox.GasPriceOracle).codehash == impl.GasPriceOracle.codehash);
        require(PROXY_ADMIN.getProxyImplementation(prox.L1Block).codehash == impl.L1Block.codehash);
        require(PROXY_ADMIN.getProxyImplementation(prox.L1FeeVault).codehash == impl.L1FeeVault.codehash);
        require(
            PROXY_ADMIN.getProxyImplementation(prox.L2CrossDomainMessenger).codehash
                == impl.L2CrossDomainMessenger.codehash
        );
        require(PROXY_ADMIN.getProxyImplementation(prox.L2ERC721Bridge).codehash == impl.L2ERC721Bridge.codehash);
        require(PROXY_ADMIN.getProxyImplementation(prox.L2StandardBridge).codehash == impl.L2StandardBridge.codehash);
        require(
            PROXY_ADMIN.getProxyImplementation(prox.L2ToL1MessagePasser).codehash == impl.L2ToL1MessagePasser.codehash
        );
        require(PROXY_ADMIN.getProxyImplementation(prox.SequencerFeeVault).codehash == impl.SequencerFeeVault.codehash);
        require(
            PROXY_ADMIN.getProxyImplementation(prox.OptimismMintableERC20Factory).codehash
                == impl.OptimismMintableERC20Factory.codehash
        );
        require(
            PROXY_ADMIN.getProxyImplementation(prox.OptimismMintableERC721Factory).codehash
                == impl.OptimismMintableERC721Factory.codehash
        );
        require(PROXY_ADMIN.getProxyImplementation(prox.EAS).codehash == impl.EAS.codehash);
        require(PROXY_ADMIN.getProxyImplementation(prox.SchemaRegistry).codehash == impl.SchemaRegistry.codehash);
    }


    /// @notice Builds the calldata that the multisig needs to make for the upgrade to happen.
    ///         A total of 9 calls are made to the proxy admin to upgrade the implementations
    ///         of the predeploys.
    function buildCalldata(address _proxyAdmin) internal view override returns (bytes memory) {
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](13);

        ContractSet memory impl = getImplementations();
        ContractSet memory prox = getProxies();

        // Upgrade the BaseFeeVault
        calls[0] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.BaseFeeVault), impl.BaseFeeVault))
        });

        // Upgrade the GasPriceOracle
        calls[1] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.GasPriceOracle), impl.GasPriceOracle))
        });

        // Upgrade the L1Block predeploy
        calls[2] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.L1Block), impl.L1Block))
        });

        // Upgrade the L1FeeVault
        calls[3] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.L1FeeVault), impl.L1FeeVault))
        });

        // Upgrade the L2CrossDomainMessenger
        calls[4] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(
                ProxyAdmin.upgrade, (payable(prox.L2CrossDomainMessenger), impl.L2CrossDomainMessenger)
                )
        });

        // Upgrade the L2ERC721Bridge
        calls[5] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.L2ERC721Bridge), impl.L2ERC721Bridge))
        });

        // Upgrade the L2StandardBridge
        calls[6] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.L2StandardBridge), impl.L2StandardBridge))
        });

        // Upgrade the L2ToL1MessagePasser
        calls[7] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.L2ToL1MessagePasser), impl.L2ToL1MessagePasser))
        });

        // Upgrade the SequencerFeeVault
        calls[8] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.SequencerFeeVault), impl.SequencerFeeVault))
        });

        // Upgrade the OptimismMintableERC20Factory
        calls[9] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(
                ProxyAdmin.upgrade, (payable(prox.OptimismMintableERC20Factory), impl.OptimismMintableERC20Factory)
                )
        });

        // Upgrade the OptimismMintableERC721Factory
        calls[10] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(
                ProxyAdmin.upgrade, (payable(prox.OptimismMintableERC721Factory), impl.OptimismMintableERC721Factory)
                )
        });
        // Upgrade EAS
        calls[11] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.EAS), impl.EAS))
        });

        // Upgrade SchemaRegistry
        calls[12] = IMulticall3.Call3({
            target: _proxyAdmin,
            allowFailure: false,
            callData: abi.encodeCall(ProxyAdmin.upgrade, (payable(prox.SchemaRegistry), impl.SchemaRegistry))
        });
        return abi.encodeCall(IMulticall3.aggregate3, (calls));
    }

    /// @notice Returns the ContractSet that represents the implementations for a given network.
    function getImplementations() internal view returns (ContractSet memory) {
        ContractSet memory set = implementations[block.chainid];
        require(set.BaseFeeVault != address(0), "no implementations for this network");
        return set;
    }

    /// @notice Returns the ContractSet that represents the proxies for a given network.
    function getProxies() internal view returns (ContractSet memory) {
        ContractSet memory set = proxies[block.chainid];
        require(set.BaseFeeVault != address(0), "no proxies for this network");
        return set;
    }
}
