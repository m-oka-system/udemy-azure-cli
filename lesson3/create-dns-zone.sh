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

# 変数入力済みチェック
if [ -z "$dnsName" ]; then
  echo "未定義の変数があります。変数：dnsNameの値を定義してください。"
  exit 1
fi

# DNSゾーンを作成
az network dns zone create --resource-group $rgName --name $dnsName

# CNAMEレコードを作成
az network dns record-set cname set-record --resource-group $rgName \
  --zone-name $dnsName \
  --record-set-name $recordSetName \
  --cname $webAppHostName
