#!/usr/bin/env bash

# 変数
rgName="azcli-rg"
location="japaneast"
appServicePlanName="e-azcli-pln"
webAppName="e-azcli-app12345"
dnsName="m-oka-system.com"
recordSetName="www"
webAppHostName=$(az webapp show --resource-group $rgName --name $webAppName --query defaultHostName --out tsv)
fqdn=${recordSetName}.${dnsName}

sqlServerName="e-paas-sql12345"
sqlLogin="sqladmin"
sqlPassword="My5up3rStr0ngPaSw0rd!"
firewallRuleName="AllowAzureService"
startIP="0.0.0.0"
endIP="0.0.0.0"

databaseName="MyDatabase"
sqlEdition="Basic"
sqlSize="2GB"

# SQLServerを作成
az sql server create --resource-group $rgName --location $location \
  --name $sqlServerName  \
  --admin-user $sqlLogin \
  --admin-password $sqlPassword

#　ファイアウォール規則でAzureサービスからのアクセスを許可
az sql server firewall-rule create --resource-group $rgName \
  --server $sqlServerName \
  --name $firewallRuleName \
  --start-ip-address $startIP \
  --end-ip-address $endIP

# SQLデータベースを作成
az sql db create --resource-group $rgName \
  --name $databaseName \
  --server $sqlServerName \
  --service-objective $sqlEdition \
  --max-size $sqlSize \
  --collation "JAPANESE_CI_AS"
