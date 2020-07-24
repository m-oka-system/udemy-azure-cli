#!/usr/bin/env bash

# 変数
rgName="azcli-rg"
location="japaneast"

webAppName="e-azcli-app26957"

sqlServerName="e-paas-sql${RANDOM}"
sqlLogin="sqladmin"
sqlPassword="My5up3rStr0ngPaSw0rd!"
firewallRuleName="AllowAzureService"
startIP="0.0.0.0"
endIP="0.0.0.0"

databaseName="MyDatabase"
sqlEdition="Basic"
sqlSize="2GB"
connectionString=$(az sql db show-connection-string --client ado.net --server $sqlServerName --name $databaseName | sed -e "s/<username>/$sqlLogin/" -e "s/<password>/$sqlPassword/")

# Configure local Git and get deployment URL
kuduUrl=$(az webapp deployment source config-local-git --resource-group $rgName --name $webAppName --query url --output tsv)

# Set the account-level deployment credentials
# az webapp deployment user set --user-name $gitLogin --password $gitPassword

# WebAppsにSQLデータベースの接続文字列を登録
az webapp config connection-string set --resource-group $rgName --name $webAppName --settings MyDbConnection="$connectionString" --connection-string-type SQLAzure


todoAppURL="https://github.com/Azure-Samples/dotnet-sqldb-tutorial.git"
todoAppDir="dotnet-sqldb-tutorial"
beforeCode='@Html.ActionLink("My TodoList App", "Index", "Home", new { area = "" }, new { @class = "navbar-brand" })'
afterCode='@Html.ActionLink((string)Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME"), "Index", new { controller = "Todos" }, new { @class = "navbar-brand" })'

git config --global user.name "<your username>"
git config --global user.email "<your email>"

# Git clone todo app
git clone $todoAppURL
cd $todoAppDir
sed -i -e "s/$beforeCode/$afterCode/" ./DotNetAppSqlDb/Views/Shared/_Layout.cshtml # Bug fix
git add .
git commit -m "Update Layout.cshtml"

# Add the Azure remote to your local Git respository and push your code
# Get app-level deployment credentials
webAppCred=$(az webapp deployment list-publishing-credentials --resource-group $rgName --name $webAppName --query scmUri --output tsv)
# Deploy todo app to web apps
git remote add $webAppName $webAppCred
git push $webAppName master
