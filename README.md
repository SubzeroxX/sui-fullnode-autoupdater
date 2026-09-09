Requirements: 
 - rust and cargo
 - docker
 - docker compose
Deployment:
1. clone repo to a folder
2. make the following folder ./config, ./db, ./prometheus-storage, ./grafana-storage `{config,db,prometheus-storage,grafana-storage}`
3. in config download genesis.blob from `https://github.com/MystenLabs/sui-genesis/raw/refs/heads/main/mainnet/genesis.blob`
4. in config download fullnode.yaml from `https://github.com/MystenLabs/sui/raw/refs/heads/main/crates/sui-config/data/fullnode-template.yaml`
5. rename fullnode-template.yaml to fullnode.yaml
6. modify `ingestion-url` at line 31 in fullnode.yaml
7. (optional) add crontab job to run `build-sui.sh`
8. add run permissions to `deploy.sh` and `build-sui.sh`
9. fill in report url (discord webhook)
10. run `build-sui.sh`
11. for grafana ui recommended: `https://grafana.com/grafana/dashboards/18141-sui-fullnode-monitor/`