﻿#get all the licensed users
$users=Get-MsolUser -All | Where-Object { $_.isLicensed -eq "TRUE" }
#setup a var to hold your output
$CRMlicensedusers=@()
#loop through the users
foreach($user in $users){
    #the Licenses.AccountSkuID is what we're interested in
    Foreach($license in $user.licenses.accountskuid){
        #look for %yourtenantname%:CRMSTANDARD
        #so for me its Anexinet:CRMSTANDARD
        if ($license -eq "Anexinet:CRMIUR") {
            #add the License value to the object, this gives us a single value
            $user | Add-Member -Type NoteProperty -Name License -Value $license
            #push the object into the output
            $CRMlicensedusers+=$user
        }
    }
}
#Convert your output object to a CSV file, we're only interested in the License and first,last,UPN,and displaynames
$CRMlicensedusers | Select-Object FirstName,LastName,DisplayName,UserPrincipalName,License | Export-Csv crmlicensedusers.csv -NoTypeInformation