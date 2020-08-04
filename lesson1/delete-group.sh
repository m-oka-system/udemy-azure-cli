#!/usr/bin/env bash
set -e

# 変数
rgName="azcli-rg"

# リソースグループを削除(確認メッセージを表示しない)
az group delete --name $rgName --yes
