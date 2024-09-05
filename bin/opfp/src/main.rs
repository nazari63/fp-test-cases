use clap::Parser;

#[tokio::main]
async fn main() -> color_eyre::Result<()> {
    opfp::Cli::parse().init_telemetry()?.run().await
}
