param (
    [string]$Server,
    [string]$Database,
    [string]$User,
    [string]$Password
)

$sqlScriptDirectory = 'database/StoredProcedure/'
$connectionString = "Server=$Server;Database=$Database;User Id=$User;Password=$Password;"

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
