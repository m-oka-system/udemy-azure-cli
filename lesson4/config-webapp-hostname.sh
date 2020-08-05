#!/usr/bin/env bash
set -e

# 変数
rgName="azcli-rg"
location="japaneast"
appServicePlanName="e-azcli-pln"
webAppName="e-azcli-app12345"
dnsName=""
recordSetName="www"
webAppHostName=`az webapp show --resource-group $rgName --name $webAppName --query defaultHostName --output tsv`
fqdn=${recordSetName}.${dnsName}

# 変数入力済みチェック
if [ -z "$dnsName" ]; then
  echo "未定義の変数があります。変数：dnsNameの値を定義してください。"
  exit 1
fi

# AppServiceプランをS1にスケールアップ
az appservice plan update --resource-group $rgName \
  --name $appServicePlanName \
  --sku S1

# WebAppsにカスタムドメインを割り当て
az webapp config hostname add --resource-group $rgName \
  --webapp-name $webAppName \
  --hostname $fqdn
