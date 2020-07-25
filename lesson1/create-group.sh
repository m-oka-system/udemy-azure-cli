#!/usr/bin/env bash
set -e

# 変数
rgName="azcli-rg"
location="japaneast"

# リソースグループを作成
az group create --name $rgName --location $location
