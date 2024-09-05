use alloy_eips::eip1559::BaseFeeParams;
use alloy_primitives::{Address, B256};
use alloy_provider::{Provider, ReqwestProvider};
use color_eyre::Result;
use serde::{Deserialize, Serialize};
use superchain_primitives::BlockID;

/// Represents the response containing the l2 output.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OutputResponse {
    /// The output format version.
    pub version: B256,
    /// The hash of the output.
    pub output_root: B256,
    /// The l2 block reference of this output.
    pub block_ref: L2BlockRef,
    /// The storage root of the message passer contract.
    pub withdrawal_storage_root: B256,
    /// The state root at this block reference.
    pub state_root: B256,
}

/// Represents the reference to an L2 block.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct L2BlockRef {
    /// The hash of the block.
    pub hash: B256,
    /// The number of the block.
    pub number: u64,
    /// The parent hash of the block.
    pub parent_hash: B256,
    /// The timestamp of the block.
    pub timestamp: u64,
    /// The l1 origin of the block.
    #[serde(rename = "l1origin")]
    pub l1_origin: BlockID,
    /// The sequence number of the block.
    pub sequence_number: u64,
}

/// Represents the response containing the safe head information.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SafeHeadResponse {
    /// The L1 block reference of the safe head.
    pub l1_block: BlockID,
    /// The L2 block reference of the safe head.
    pub safe_head: BlockID,
}

/// A provider for the rollup node.
#[derive(Debug)]
pub struct RollupProvider {
    /// The inner Ethereum JSON-RPC provider.
    inner: ReqwestProvider,
}

impl RollupProvider {
    /// Creates a new [RollupProvider] with the given alloy provider.
    pub fn new(inner: ReqwestProvider) -> Self {
        Self { inner }
    }

    /// Returns the output at a given block number.
    pub async fn output_at_block(&self, block_number: u64) -> Result<OutputResponse> {
        let block_num_hex = format!("0x{:x}", block_number);
        let raw_output = self
            .inner
            .raw_request("optimism_outputAtBlock".into(), (block_num_hex,))
            .await?;
        let output: OutputResponse = serde_json::from_value(raw_output)?;
        Ok(output)
    }

    /// Returns the safe head at an L1 block number.
    pub async fn safe_head_at_block(&self, block_number: u64) -> Result<SafeHeadResponse> {
        let block_num_hex = format!("0x{:x}", block_number);
        let raw_resp = self
            .inner
            .raw_request("optimism_safeHeadAtL1Block".into(), (block_num_hex,))
            .await?;
        let resp: SafeHeadResponse = serde_json::from_value(raw_resp)?;
        Ok(resp)
    }

    /// Creates a new [RollupProvider] from the provided [reqwest::Url].
    pub fn new_http(url: reqwest::Url) -> Self {
        // let pb = ProviderBuilder::default().
        let inner = ReqwestProvider::new_http(url);
        Self::new(inner)
    }
}

/// RollupConfig type compatible with the Optimism rollup node.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct RollupConfig {
    /// The genesis information.
    pub genesis: Genesis,
    /// The block time.
    pub block_time: u64,
    /// The maximum sequencer drift.
    pub max_sequencer_drift: u64,
    /// The sequence window size.
    pub seq_window_size: u64,

    /// The channel timeout beginning with bedrock.
    #[serde(rename = "channel_timeout")]
    pub channel_timeout_bedrock: u64,
    // The L1 chain ID.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub l1_chain_id: Option<u128>,
    // The L2 chain ID.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub l2_chain_id: Option<u128>,

    /// The regolith activation time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub regolith_time: Option<u64>,
    /// The canyon activation time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub canyon_time: Option<u64>,
    /// The delta activation time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub delta_time: Option<u64>,
    /// The ecotone activation time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub ecotone_time: Option<u64>,
    /// The fjord activation time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub fjord_time: Option<u64>,
    /// The granite activation time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub granite_time: Option<u64>,
    /// The interop activation time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub interop_time: Option<u64>,
    /// The batch inbox address.
    pub batch_inbox_address: Address,
    /// The deposit contract address.
    pub deposit_contract_address: Address,
    /// The L1 system config address.
    pub l1_system_config_address: Address,
    /// The protocol versions address.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub protocol_versions_address: Option<Address>,
    /// The DA challenge address.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub da_challenge_address: Option<Address>,
}

impl From<&superchain_primitives::RollupConfig> for RollupConfig {
    fn from(cfg: &superchain_primitives::RollupConfig) -> Self {
        let syscfg = cfg.genesis.system_config.clone().unwrap();
        let genesis = Genesis {
            l1: cfg.genesis.l1,
            l2: cfg.genesis.l2,
            l2_time: cfg.genesis.l2_time,
            system_config: SystemConfig {
                batcher_addr: syscfg.batcher_address,
                overhead: syscfg.overhead.into(),
                scalar: syscfg.scalar.into(),
                gas_limit: syscfg.gas_limit,
            },
        };
        let rollup_config = Self {
            genesis: genesis.clone(),
            block_time: cfg.block_time,
            max_sequencer_drift: cfg.max_sequencer_drift,
            seq_window_size: cfg.seq_window_size,
            channel_timeout_bedrock: cfg.channel_timeout,
            // channel_timeout_granite: cfg.granite_channel_timeout,
            l1_chain_id: Some(cfg.l1_chain_id.into()),
            l2_chain_id: Some(cfg.l2_chain_id.into()),
            regolith_time: cfg.regolith_time,
            canyon_time: cfg.canyon_time,
            delta_time: cfg.delta_time,
            ecotone_time: cfg.ecotone_time,
            fjord_time: cfg.fjord_time,
            granite_time: cfg.granite_time,
            interop_time: None,
            batch_inbox_address: cfg.batch_inbox_address,
            deposit_contract_address: cfg.deposit_contract_address,
            l1_system_config_address: cfg.l1_system_config_address,
            protocol_versions_address: Some(cfg.protocol_versions_address),
            da_challenge_address: cfg.da_challenge_address,
            // da_challenge_window: 0,
            // da_resolve_window: 0,
            // use_plasma: false,
        };
        rollup_config
    }
}

impl Into<superchain_primitives::RollupConfig> for RollupConfig {
    fn into(self) -> superchain_primitives::RollupConfig {
        superchain_primitives::RollupConfig {
            genesis: superchain_primitives::ChainGenesis {
                l1: self.genesis.l1,
                l2: self.genesis.l2,
                l2_time: self.genesis.l2_time,
                extra_data: None,
                system_config: Some(superchain_primitives::SystemConfig {
                    batcher_address: self.genesis.system_config.batcher_addr,
                    overhead: self.genesis.system_config.overhead.into(),
                    scalar: self.genesis.system_config.scalar.into(),
                    gas_limit: self.genesis.system_config.gas_limit,
                    base_fee_scalar: None,
                    blob_base_fee_scalar: None,
                }),
            },
            block_time: self.block_time,
            max_sequencer_drift: self.max_sequencer_drift,
            seq_window_size: self.seq_window_size,
            channel_timeout: self.channel_timeout_bedrock,
            granite_channel_timeout: 50,
            l1_chain_id: u64::try_from(self.l1_chain_id.unwrap_or(0)).unwrap(),
            l2_chain_id: u64::try_from(self.l2_chain_id.unwrap_or(0)).unwrap(),
            base_fee_params: BaseFeeParams::optimism(),
            canyon_base_fee_params: Some(BaseFeeParams::optimism_canyon()),
            regolith_time: self.regolith_time,
            canyon_time: self.canyon_time,
            delta_time: self.delta_time,
            ecotone_time: self.ecotone_time,
            fjord_time: self.fjord_time,
            granite_time: self.granite_time,
            holocene_time: None,
            batch_inbox_address: self.batch_inbox_address,
            deposit_contract_address: self.deposit_contract_address,
            l1_system_config_address: self.l1_system_config_address,
            protocol_versions_address: self.protocol_versions_address.unwrap_or_default(),
            superchain_config_address: None,
            blobs_enabled_l1_timestamp: None,
            da_challenge_address: self.da_challenge_address,
        }
    }
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct Genesis {
    pub l1: BlockID,
    pub l2: BlockID,
    pub l2_time: u64,
    pub system_config: SystemConfig,
}

// https://github.com/ethereum-optimism/optimism/blob/c7ad0ebae5dca3bf8aa6f219367a95c15a15ae41/op-service/eth/types.go#L371
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SystemConfig {
    pub batcher_addr: Address,
    pub overhead: B256,
    pub scalar: B256,
    pub gas_limit: u64,
}