#!/usr/bin/env bash

# 変数
rgName="azcli-rg"
location="japaneast"
appServicePlanName="e-azcli-pln"
webAppName="e-azcli-app12345"

# AppServiceプランをFreeプランで作成
az appservice plan create --resource-group $rgName --location $location \
  --name $appServicePlanName \
  --sku FREE

# WebAppsを作成
az webapp create --resource-group $rgName \
  --name $webAppName \
  --plan $appServicePlanName
