function Alert {
	param(
		[string]$msg
	)

	Write-Host ""
	Write-Host "**** $msg ***" -BackgroundColor Black -ForegroundColor Yellow
	Write-Host ""
}

Alert "Update User Profiles Using CSV Data - START"

Alert "1 - Start work in the context of 'master' database"
Set-Location -Path master:\content

Alert "2 - Get all external domain users"

$domain = "extranet"

$users = Get-User -Filter "$domain\*"
foreach ($user in $users) {
	$profile = $user.Profile

    #some mapping for the user profile custom properties.
    #change as needed for your needs
	$Salutations = $profile.GetCustomProperty("Salutations")
	$FirstName = $profile.GetCustomProperty("FirstName")
	$LastName = $profile.GetCustomProperty("LastName")
	$Company = $profile.GetCustomProperty("Company")

	$Name = $profile.Name
	$DisplayName = $profile.DisplayName
	$Username = $profile.Username

	Write-Host "Username=$Username|Salutation=$Salutations|FirstName=$FirstName|LastName=$LastName|Email=$Email|Company=$Company"
}

Alert "3 - Read all user data from CSV"

$csvUsers = Import-Csv -Path "C:\s\DB_USERS.csv"
#$csvUsers | Get-Member
#$csvUsers | Format-Table

Write-Host ""
Write-Host "Total CSV Users =" $csvUsers.Count

Alert "4 - For each existin user in SC no anoynmous, look for matching CSV data"
$users = Get-User -Filter "$domain\*"
foreach ($user in $users) {
	$profile = $user.Profile

	if ($profile.Username -eq "extranet\Anonymous") {
		Write-Host "skipping =" $profile.Username
		Write-Host "--------------------------"
		continue
	}

	Write-Host "processing =" $profile.Username

	$csvUser = $csvUsers.Where({ $PSItem.Username -eq $profile.Username })
	#Write-Host $csvUser

	$identity = $profile.Username
	if ($csvUser) {
		#"4.1 - If matching CSV data exists, update profile info
		Write-Host "Found" $profile.Username " from CSV. Updating account..."

		#change user profile last name
		Set-User -Identity $identity -CustomProperties @{ "LastName" = $csvUser.LastName }

		#enable user
		Enable-User -Identity $identity
	}
	else {
		#"4.2 - If no matching CSV data, disable"
		Write-Host "Cannot find" $profile.Username " from CSV. Disabling account..."
		Disable-User -Identity $identity
	}


	Write-Host "--------------------------"
}

Alert "Checking Updates..."

$users = Get-User -Filter "$domain\*"
foreach ($user in $users) {
	$profile = $user.Profile

    #some mapping for the user profile custom properties.
    #change as needed for your needs
	$Salutations = $profile.GetCustomProperty("Salutations")
	$FirstName = $profile.GetCustomProperty("FirstName")
	$LastName = $profile.GetCustomProperty("LastName")
	$Company = $profile.GetCustomProperty("Company")

	$Name = $profile.Name
	$DisplayName = $profile.DisplayName
	$Username = $profile.Username

	Write-Host "Username=$Username|Salutation=$Salutations|FirstName=$FirstName|LastName=$LastName|Email=$Email|Company=$Company"
}

Alert "Update User Profiles Using CSV Data - END" 