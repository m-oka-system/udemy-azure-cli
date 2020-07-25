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

sqlServerName="e-paas-sql12345"
sqlLogin="sqladmin"
sqlPassword="My5up3rStr0ngPaSw0rd!"
firewallRuleName="AllowAzureService"
startIP="0.0.0.0"
endIP="0.0.0.0"

databaseName="MyDatabase"
sqlEdition="Basic"
sqlSize="2GB"
connectionString=$(az sql db show-connection-string --client ado.net --server $sqlServerName --name $databaseName | sed -e "s/<username>/$sqlLogin/" -e "s/<password>/$sqlPassword/")

todoAppURL="https://github.com/Azure-Samples/dotnet-sqldb-tutorial.git"
todoAppDir="dotnet-sqldb-tutorial"
gitUserName=""
gitUserEmail=""
webAppCred=$(az webapp deployment list-publishing-credentials --resource-group $rgName --name $webAppName --query scmUri --output tsv)
beforeCode='@Html.ActionLink("My TodoList App", "Index", "Home", new { area = "" }, new { @class = "navbar-brand" })'
afterCode='@Html.ActionLink((string)Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME"), "Index", new { controller = "Todos" }, new { @class = "navbar-brand" })'

# Configure local Git and get deployment URL
# kuduUrl=$(az webapp deployment source config-local-git --resource-group $rgName --name $webAppName --query url --output tsv)

# Set the account-level deployment credentials
# az webapp deployment user set --user-name $gitLogin --password $gitPassword

# ローカルGitの有効化は不要
# ログイン情報はアプリ資格情報を利用する

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
