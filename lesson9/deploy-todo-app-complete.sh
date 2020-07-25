#!/usr/bin/env bash
set -e

# 共通
rgName="azcli-rg"
location="japaneast"

# AppService
appServicePlanName="e-azcli-pln"
webAppName="e-azcli-app${RANDOM}"

# DNSゾーン
dnsName=""
recordSetName="www"
fqdn=${recordSetName}.${dnsName}

# SQLServer
sqlServerName="e-paas-sql${RANDOM}"
sqlLogin="sqladmin"
sqlPassword="My5up3rStr0ngPaSw0rd!"
firewallRuleName="AllowAzureService"
startIP="0.0.0.0"
endIP="0.0.0.0"

# SQLデータベース
databaseName="MyDatabase"
sqlEdition="Basic"
sqlSize="2GB"

# Git設定情報
todoAppURL="https://github.com/Azure-Samples/dotnet-sqldb-tutorial.git"
todoAppDir="dotnet-sqldb-tutorial"
gitUserName=""
gitUserEmail=""
beforeCode='@Html.ActionLink("My TodoList App", "Index", "Home", new { area = "" }, new { @class = "navbar-brand" })'
afterCode='@Html.ActionLink((string)Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME"), "Index", new { controller = "Todos" }, new { @class = "navbar-brand" })'

# 変数入力済みチェック
if [ -z "$dnsName" ] || [ -z "$gitUserName" ] || [ -z "$gitUserEmail" ]; then
  echo "未定義の変数があります。変数：dnsName、gitUserName、gitUserEmailの値を定義してください。"
  exit 1
fi

# リソースグループを作成
az group create --name $rgName --location $location

# AppServiceプランをFreeプランで作成
az appservice plan create --resource-group $rgName --location $location \
  --name $appServicePlanName \
  --sku FREE

# WebAppsを作成
az webapp create --resource-group $rgName \
  --name $webAppName \
  --plan $appServicePlanName

# DNSゾーンを作成
az network dns zone create --resource-group $rgName --name $dnsName

# CNAMEレコードを作成
webAppHostName=$(az webapp show --resource-group $rgName --name $webAppName --query defaultHostName --out tsv)
az network dns record-set cname set-record --resource-group $rgName \
  --zone-name $dnsName \
  --record-set-name $recordSetName \
  --cname $webAppHostName

echo "外部のドメイン登録サービスのネームサーバをAzureDNSに変更してください。"
read -p "変更が反映したら [Enter] を押してください。"

# AppServiceプランをS1にスケールアップ
az appservice plan update --resource-group $rgName --name $appServicePlanName --sku S1

# WebAppsにカスタムドメインを割り当て
az webapp config hostname add --resource-group $rgName \
  --webapp-name $webAppName \
  --hostname $fqdn

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

# SQLServerを作成
az sql server create --resource-group $rgName --location $location \
  --name $sqlServerName  \
  --admin-user $sqlLogin \
  --admin-password $sqlPassword

#　ファイアウォール規則でAzureサービスからのアクセスを許可
az sql server firewall-rule create --resource-group $rgName \
  --server $sqlServerName \
  --name $firewallRuleName \
  --start-ip-address $startIP \
  --end-ip-address $endIP

# SQLデータベースを作成
az sql db create --resource-group $rgName \
  --name $databaseName \
  --server $sqlServerName \
  --service-objective $sqlEdition \
  --max-size $sqlSize \
  --collation "JAPANESE_CI_AS"

# ローカルGitの有効化
az webapp deployment source config-local-git --resource-group $rgName --name $webAppName

# ユーザー資格情報を登録
# az webapp deployment user set --user-name <your user name> --password <your password>

# WebAppsにSQLデータベースの接続文字列を登録
connectionString=$(az sql db show-connection-string --client ado.net --server $sqlServerName --name $databaseName | sed -e "s/<username>/$sqlLogin/" -e "s/<password>/$sqlPassword/")
az webapp config connection-string set --resource-group $rgName \
  --name $webAppName \
  --settings MyDbConnection="$connectionString" \
  --connection-string-type SQLAzure

# GitHubからToDoアプリをダウンロード
git clone $todoAppURL
cd $todoAppDir

# ローカルGitの設定
webAppCred=$(az webapp deployment list-publishing-credentials --resource-group $rgName --name $webAppName --query scmUri --output tsv)
git config --global user.name $gitUserName
git config --global user.email $gitUserEmail
git remote add $webAppName $webAppCred

# ソースを修正してコミット
sed -i -e "s/$beforeCode/$afterCode/" ./DotNetAppSqlDb/Views/Shared/_Layout.cshtml
git add .
git commit -m "Update Layout.cshtml"

# ToDoアプリをWeb Appsにデプロイ
git push $webAppName master
