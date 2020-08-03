#!/usr/bin/env bash
set -e

# 変数
rgName="azcli-rg"
# location="japaneast"
# appServicePlanName="e-azcli-pln"
webAppName="e-azcli-app12345"
# dnsName=""
# recordSetName="www"
# webAppHostName=`az webapp show --resource-group $rgName --name $webAppName --query defaultHostName --output tsv`
# fqdn=${recordSetName}.${dnsName}

sqlServerName="e-azcli-sql12345"
sqlLogin="sqladmin"
sqlPassword="My5up3rStr0ngPaSw0rd!"
# firewallRuleName="AllowAllWindowsAzureIps"
# startIP="0.0.0.0"
# endIP="0.0.0.0"

databaseName="MyDatabase"
# sqlEdition="Basic"
# sqlSize="2GB"
connectionString=`az sql db show-connection-string --client ado.net --server $sqlServerName --name $databaseName | sed -e "s/<username>/$sqlLogin/" -e "s/<password>/$sqlPassword/"`

todoAppURL="https://github.com/Azure-Samples/dotnet-sqldb-tutorial.git"
todoAppDir="dotnet-sqldb-tutorial"
gitUserName=""
gitUserEmail=""
webAppCred=`az webapp deployment list-publishing-credentials --resource-group $rgName --name $webAppName --query scmUri --output tsv`
beforeCode='@Html.ActionLink("My TodoList App", "Index", "Home", new { area = "" }, new { @class = "navbar-brand" })'
afterCode='@Html.ActionLink((string)Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME"), "Index", new { controller = "Todos" }, new { @class = "navbar-brand" })'

# 変数入力済みチェック
if [ -z "$gitUserName" ] || [ -z "$gitUserEmail" ]; then
  echo "未定義の変数があります。変数：gitUserName、gitUserEmailの値を定義してください。"
  exit 1
fi

# ローカルGitの有効化
az webapp deployment source config-local-git --resource-group $rgName --name $webAppName

# WebAppsにSQLデータベースの接続文字列を登録
az webapp config connection-string set --resource-group $rgName \
  --name $webAppName \
  --settings MyDbConnection="$connectionString" \
  --connection-string-type SQLAzure

# GitHubからToDoアプリをダウンロード
git clone $todoAppURL
cd $todoAppDir

# ローカルGitの設定
git config --global user.name $gitUserName
git config --global user.email $gitUserEmail
git remote add $webAppName $webAppCred

# ソースを修正してコミット
sed -i -e "s/$beforeCode/$afterCode/" ./DotNetAppSqlDb/Views/Shared/_Layout.cshtml
git add .
git commit -m "Update Layout.cshtml"

# ToDoアプリをWeb Appsにデプロイ
git push $webAppName master
