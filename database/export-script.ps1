
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null

$srvname = "poc-db-instance.cr6mkeog42cv.ap-south-1.rds.amazonaws.com"
$user = "adminUser"
$pwd = "StrongPassword123!"
$database = "TestDb"

$connection = new-object Microsoft.SqlServer.Management.Common.ServerConnection
$connection.ServerInstance = $srvname
$connection.LoginSecure = $false
$connection.Login = $user
$connection.Password = $pwd

$SMOserver = New-Object Microsoft.SqlServer.Management.SMO.Server($connection)

# $SMOserver = New-Object ("Microsoft.SqlServer.Management.Smo.Server") -argumentlist $server


$db = $SMOserver.databases[$database]

$Objects = $db.Tables

# $Objects += $db.Views

# $Objects = $db.StoredProcedures

# $Objects = $db.UserDefinedFunctions #| Where-object { $_.IsSystemObject -eq $false } 

#Build this portion of the directory structure out here in case scripting takes more than one minute.

$SavePath = Get-Location

# "Save path set to => $SavePath"

# $DateFolder = get-date -format yyyyMMddHHmm

# new-item -type directory -name "$DateFolder"-path "$SavePath"
 

foreach ($ScriptThis in $Objects) {
    #| where { !($_.IsSystemObject) }

    #Need to Add Some mkDirs for the different $Fldr=$ScriptThis.GetType().Name

    $scriptr = new-object ("Microsoft.SqlServer.Management.Smo.Scripter") ($SMOserver)

    $scriptr.Options.AppendToFile = $True

    $scriptr.Options.AllowSystemObjects = $False

    $scriptr.Options.ClusteredIndexes = $True

    $scriptr.Options.DriAll = $True

    $scriptr.Options.ScriptDrops = $False

    $scriptr.Options.IncludeHeaders = $True

    $scriptr.Options.ToFileOnly = $True

    $scriptr.Options.Indexes = $True

    $scriptr.Options.Permissions = $True

    $scriptr.Options.WithDependencies = $False

    <#Script the Drop too#>

    $ScriptDrop = new-object ("Microsoft.SqlServer.Management.Smo.Scripter") ($SMOserver)

    $ScriptDrop.Options.AppendToFile = $True

    $ScriptDrop.Options.AllowSystemObjects = $False

    $ScriptDrop.Options.ClusteredIndexes = $True

    $ScriptDrop.Options.DriAll = $True

    $ScriptDrop.Options.ScriptDrops = $True

    $ScriptDrop.Options.IncludeHeaders = $True

    $ScriptDrop.Options.ToFileOnly = $True

    $ScriptDrop.Options.Indexes = $True

    $ScriptDrop.Options.WithDependencies = $False

 

    <#This section builds folder structures.  Remove the date folder if you want to overwrite#>

    $TypeFolder = $ScriptThis.GetType().Name
    $FirstVersion = "v1";
    $SecondVersion = "v2";

    if ((Test-Path -Path "$SavePath\$TypeFolder") -eq "true") {
        "Scripting Out $TypeFolder $ScriptThis" 
    } 
    else {
        new-item -type directory -name "$TypeFolder"-path "$SavePath" 
    }

    $ScriptFile = $ScriptThis -replace "\[|\]"

    # "Type of object $TypeFolder";

    if (($TypeFolder -eq "StoredProcedure") -or ($TypeFolder -eq "UserDefinedFunction") ) {

        $Procedureversion = ""

        if ((Test-Path -Path "$SavePath\$TypeFolder\$FirstVersion") -eq "true") {
            
        }
        else {
            new-item -type directory -name "$FirstVersion" -path "$SavePath\$TypeFolder"
        }
        if ((Test-Path -Path "$SavePath\$TypeFolder\$SecondVersion") -eq "true") {
            
        }
        else {
            new-item -type directory -name "$SecondVersion" -path "$SavePath\$TypeFolder"
        }

        # "Script file name $ScriptFile"

        # $containStatus = $ScriptFile.Contains("usp_dp")            
        # "Script file name containes $containStatus"
        if ($ScriptFile.ToLower().Contains(".usp") -or $ScriptFile.ToLower().Contains(".udf") -or $ScriptFile.ToLower().Contains(".ufn")) {
            $Procedureversion = $SecondVersion
        }
        else {
            $Procedureversion = $FirstVersion
        }

        # "Procedure Version $Procedureversion"

        $ScriptDrop.Options.FileName = "" + $($SavePath) + "\" + $($TypeFolder) + "\" + $Procedureversion + "\" + $($ScriptFile) + ".sql"

        $scriptr.Options.FileName = "$SavePath\$TypeFolder\$Procedureversion\$ScriptFile.sql"
    }
    elseif ($TypeFolder -eq "Table") {
 
        $pos = $ScriptFile.IndexOf(".")
        $schemaName = $ScriptFile.Substring(0, $pos)
        $rightPart = $ScriptFile.Substring($pos + 1)         

        # "Table schema name $schemaName"
        # "Table name $rightPart"

        if ((Test-Path -Path "$SavePath\$TypeFolder\$schemaName") -eq "true") {
            
        }
        else {
            new-item -type directory -name "$schemaName" -path "$SavePath\$TypeFolder"
        }
        $ScriptDrop.Options.FileName = "" + $($SavePath) + "\" + $($TypeFolder) + "\" + $schemaName + "\" + $($ScriptFile) + ".sql"

        $scriptr.Options.FileName = "$SavePath\$TypeFolder\$schemaName\$ScriptFile.sql"
    }
    else {
        $ScriptDrop.Options.FileName = "" + $($SavePath) + "\" + $($TypeFolder) + "\" + $($ScriptFile) + ".sql"

        $scriptr.Options.FileName = "$SavePath\$TypeFolder\$ScriptFile.sql"
    }

 

    #This is where each object actually gets scripted one at a time.

    $ScriptDrop.Script($ScriptThis)

    $scriptr.Script($ScriptThis)

} #This ends the loop