#!/usr/bin/env bash

# 変数
rgName="azcli-rg"
location="japaneast"
appServicePlanName="e-azcli-pln"
webAppName="e-azcli-app12345"
dnsName="m-oka-system.com"
recordSetName="www"
webAppHostName=$(az webapp show --resource-group $rgName --name $webAppName --query defaultHostName --out tsv)

# DNSゾーンを作成
az network dns zone create --resource-group $rgName --name $dnsName

# CNAMEレコードを作成
az network dns record-set cname set-record --resource-group $rgName \
  --zone-name $dnsName \
  --record-set-name $recordSetName \
  --cname $webAppHostName
