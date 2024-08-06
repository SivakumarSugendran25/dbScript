param (
    [string]$Server,
    [string]$Database,
    [string]$User,
    [string]$Password,
    [string]$S3BucketName,
    [string]$S3BackupPath
)

function Backup-Database {
    param (
        [string]$Server,
        [string]$Database,
        [string]$User,
        [string]$Password,
        [string]$BackupPath
    )

    $backupFileName = "${Database}_Backup_$(Get-Date -Format 'yyyyMMddHHmmss').bak"
    $backupFilePath = Join-Path -Path $BackupPath -ChildPath $backupFileName

    $sqlcmdCommand = "sqlcmd -S $Server -U $User -P $Password -Q `"BACKUP DATABASE [$Database] TO DISK = '$backupFilePath' WITH INIT`""
    Write-Host "Executing backup command: $sqlcmdCommand"
    Invoke-Expression $sqlcmdCommand

    Write-Host "Backup completed: $backupFilePath"
    return $backupFilePath
}

function Upload-ToS3 {
    param (
        [string]$FilePath,
        [string]$S3BucketName,
        [string]$S3BackupPath
    )

    $awsCliCommand = "aws s3 cp $FilePath s3://$S3BucketName/$S3BackupPath/"
    Write-Host "Uploading backup to S3: $awsCliCommand"
    Invoke-Expression $awsCliCommand
}

# Define paths and connection string
$sqlScriptDirectory = 'database/StoredProcedure/'
$connectionString = "Server=$Server;Database=$Database;User Id=$User;Password=$Password;"

# Take a backup before executing scripts
$backupPath = "C:\Backups"  # Local backup path
$backupFilePath = Backup-Database -Server $Server -Database $Database -User $User -Password $Password -BackupPath $backupPath

# Upload the backup to S3
Upload-ToS3 -FilePath $backupFilePath -S3BucketName $S3BucketName -S3BackupPath $S3BackupPath

# Open SQL connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Get all SQL script files from the directory
$sqlScriptFiles = Get-ChildItem -Path $sqlScriptDirectory -Filter *.sql

foreach ($file in $sqlScriptFiles) {
    Write-Host "Executing script: $($file.FullName)"
    $sqlScript = Get-Content -Path $file.FullName -Raw
    
    $command = $connection.CreateCommand()
    $command.CommandText = $sqlScript
    $command.ExecuteNonQuery()
}

$connection.Close()

Write-Host "All SQL scripts executed successfully."
