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

# マネージド証明書を作成
thumbprint=`az webapp config ssl create --resource-group $rgName \
  --name $webAppName \
  --hostname $fqdn \
  --query thumbprint \
  --output tsv`

# create時にthumbprintを変数に格納できない場合があるためshowコマンドでの取得を追加(2021/5/21)
thumbprint=`az webapp config ssl show --resource-group $rgName \
  --certificate-name $fqdn \
  --query thumbprint \
  --output tsv`

# TLS/SSLバインディングの追加
az webapp config ssl bind --resource-group $rgName \
  --name $webAppName \
  --certificate-thumbprint $thumbprint \
  --ssl-type SNI
