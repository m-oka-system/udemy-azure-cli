#!/usr/bin/env bash

# 変数
rgName="azcli-rg"
location="japaneast"
appServicePlanName="e-azcli-pln"
webAppName="e-azcli-app26957"
webAppHostName=$(az webapp show --resource-group $rgName --name $webAppName --query defaultHostName --out tsv)
dnsName="m-oka-system.com"
recordSetName="www"
fqdn=${recordSetName}.${dnsName}

# AppServiceプランをS1にスケールアップ
az appservice plan update --resource-group $rgName --name $appServicePlanName --sku S1

# WebAppsにカスタムドメインを割り当て
az webapp config hostname add --resource-group $rgName \
  --webapp-name $webAppName \
  --hostname $fqdn
