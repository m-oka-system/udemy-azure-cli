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

# マネージド証明書を作成
thumbprint=$(az webapp config ssl create --resource-group $rgName \
  --name $webAppName \
  --hostname $fqdn \
  --query thumbprint \
  --out tsv)

# TLS/SSLバインディングの追加
az webapp config ssl bind --resource-group $rgName \
  --name $webAppName \
  --certificate-thumbprint $thumbprint \
  --ssl-type SNI
