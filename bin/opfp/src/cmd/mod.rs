//! Module for the CLI.

use clap::Parser;
use color_eyre::eyre::{eyre, Result};
use tracing::Level;

pub mod from_op_program;
pub mod run_op_program;
pub mod util;

/// Main CLI
#[derive(Parser, Clone, Debug)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    /// Subcommands for the CLI
    #[command(subcommand)]
    pub command: Commands,
}

/// Subcommands for the CLI
#[derive(Parser, Clone, Debug)]
pub enum Commands {
    /// Creates the fault proof fixture from the op-program implementation.
    FromOpProgram(from_op_program::FromOpProgram),
    /// Runs the op-program implementation with a given fixture.
    RunOpProgram(run_op_program::RunOpProgram),
}

impl Cli {
    /// Returns the verbosity level for the CLI
    pub fn v(&self) -> u8 {
        match &self.command {
            Commands::FromOpProgram(cmd) => cmd.v,
            Commands::RunOpProgram(cmd) => cmd.v,
        }
    }

    /// Initializes telemtry for the application.
    pub fn init_telemetry(self) -> Result<Self> {
        color_eyre::install()?;
        let subscriber = tracing_subscriber::fmt()
            .with_max_level(match self.v() {
                0 => Level::ERROR,
                1 => Level::WARN,
                2 => Level::INFO,
                3 => Level::DEBUG,
                _ => Level::TRACE,
            })
            .finish();
        tracing::subscriber::set_global_default(subscriber).map_err(|e| eyre!(e))?;
        Ok(self)
    }

    /// Parse the CLI arguments and run the command
    pub async fn run(self) -> Result<()> {
        match self.command {
            Commands::FromOpProgram(cmd) => cmd.run().await,
            Commands::RunOpProgram(cmd) => cmd.run().await,
        }
    }
}
