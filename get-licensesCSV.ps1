<#
Script to pull the license utilization for your O365 Tenant.
The script will enumerate all the accountskuIDs on your tenant and
output a .csv file for each license containing the users assigned the license.
#>

#enter your folder path for the output files
$path="c:\bin\licenseReports"


#import the MSOnline module
Import-Module MSOnline
#connect to tenant; prompt for creds
Connect-MsolService -Credential $Office365credentials

#get licensed users
$users= Get-MsolUser -all | ?{$_.islicensed -eq "true"}
#Get available Licenses in Tenant
$licenses=Get-MsolAccountSku | select accountskuid


#loop through each of the Licenses
foreach ($license in $licenses) {
    $output=@()
    #now loop through all of the users
	foreach ($user in $users) {
        #find the users with the license you're looking for and then grab the info you want
		if ($user.islicensed -eq "True" -and $user.licenses.accountskuid -contains $license.accountskuid) {
            #grab the info you want and push it into your output variable
			$objuser = new-object system.object
			$objuser | add-member -type NoteProperty -name DisplayName -value $user.DisplayName
			$objuser | add-member -type NoteProperty -name UPN	-value $user.userprincipalname
			$output +=$objuser
		}
	}
    #setup your file name based off the license name
	$filename=$path+"\LicenseReport"+$license.accountskuid.split(':')[1]+".csv"
    #create the output file
	$output | export-csv $filename -notypeinformation
}