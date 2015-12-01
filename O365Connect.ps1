#Get command line options
Param(
	[Parameter(Mandatory=$true,ParameterSetName='Connect')]
		[switch]$Connect,
	[Parameter(Mandatory=$true,ParameterSetName='Disconnect')]
		[switch]$Disconnect
)

if($connect){
	#prompt for tenant creds
	$credential = Get-Credential

	Write-host	"Connecting to Tenant"
	#Load MSOL module
	if (-not (Get-Module MsOnline)){ Import-Module MsOnline}
	#Conenct to Tenant
	Connect-MsolService -Credential $credential

	#Get Tenant Name
	$tenantName=(Get-MsolAccountSku)[0].AccountSkuId.split(':')[0]
	Write-host "`tTenant Name ====>    $tenantName"
	$fullTenantName=$tenantName + '.onmicrosoft.com'
	
	#Exchange
	Write-host "Connecting to Exchange Online"
	$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
	Import-PSSession $exchangeSession -DisableNameChecking

	#SharePoint
	Write-host "Connecting to SharePoint Online"
	#Load MSOL module
	if (-not (Get-Module Microsoft.Online.SharePoint.PowerShell)){ Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking }
	#build sharepoint url
	$url='https://'+ $tenantName +'-admin.sharepoint.com'
	Write-host "`tUsing URL:" $url
	Connect-SPOService -Url $url -credential $credential


	#SfB ----connecting to hybrid
	Write-host "Connecting to Skype for Business Online"
	if (-not (Get-Module LyncOnlineConnector)){ Import-Module LyncOnlineConnector}
	#Connect to Hybrid
	Write-host "`tUsing OverrideDomain:" $fullTenantName
	$sfboSession = New-CsOnlineSession -Credential $credential -OverrideAdminDomain $fullTenantName
	#to connect to Non-Hybrid use the line below
	#$sfboSession = New-CsOnlineSession -Credential $credential
	Import-PSSession $sfboSession

	#Compliance Center
	Write-host "Connecting to Compliance Center"
	$ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
	Import-PSSession $ccSession -Prefix cc
}

#remove all
if($disconnect){
	Write-host "Removing All Sessions"
	Get-PSSession | Remove-PSSession
}
