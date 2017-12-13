# deploy TiDB cluster to azure

### This tutorial is just for Chinese users

* install azure CLI 2.0 (example for macOS)

```bash
brew install azure-cli
```
The installation of azure CLI 2.0 in other platforms can refer to [here](https://docs.azure.cn/zh-cn/cli/install-azure-cli?view=azure-cli-latest)

* list registered clouds

```bash
az cloud list --query "[].name" -otsv
```

* set the active cloud then login

```bash
az cloud set --name AzureChinaCloud
az login
```

* create a new resource group if there is no resource group

```
az group create --resource-group test-rg --location chinanorth
```

* deploy TiDB cluster to azure cloud

```bash
git clone https://github.com/onlymellb/tidb-cluster.git

cd tidb-cluste

az group deployment create \
--template-file ./azuredeploy.json \
--group test-rg \
--name tidbcluster \
--parameters @azuredeploy.parameters.json
```
