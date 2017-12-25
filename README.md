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

* get the monitor address

```bash
echo http://$(az network public-ip list -g test-tidb --query "[?name=='pubip-monitor'].dnsSettings.fqdn" -otsv):3000

# grafana login user name and password
username: admin
password: admin
```

* get the tidb server loadBalance dns

```bash
tidb_lb_ip=$(az network public-ip list -g test-tidb --query "[?name=='tidb-lb-pubip'].ipAddress" -otsv)

# login tidb server
mysql -uroot -h${tidb_lb_ip} -P4000
```
