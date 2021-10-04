# The purpose of this script is to add new namespace targets to existing paths with new shares. This will aid in migrations to new hardware.
# 
# *** WARNING ***
# By default all entries are set to disabled on creation. This is to allow for pre-staging the environment before a cut over.
#
# Import CSV
# Headers for the CSV should be the following
# TargetPath,SharePath,PriorityClass
# 
# TargetPath: Should contain the namespace path. For example: \\domain.com\share\path
#
# SharePath: Should contain the share path that the target will point to. For example: \\servername\share\path
#
# PriorityClass: Should be set to the preferred setting for use in the environment, and understand that if you use target costs it is using AD site costs.
#
# GlobalHigh = Overrides referral ordering and makes it FIRST among all targets
# GlobalLow = Overrides referral ordering and makes it LAST among all targets
# SiteCostHigh = Overrides referral ordering and makes it FIRST among equal cost targets
# SiteCostLow = Overrides referral ordering and makes it LAST among equal cost targets
# SiteCostNormal = No override. Accessed based on site cost

# Getting the desktop path of the user launching the script. Just as a default starting path
$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

# Prompt the user to select the CSV file for the script
Function Get-FileName($initialDirectory){
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.Title = "Select ADD NAMESPACE CSV"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}

$FilePath  = Get-FileName -initialDirectory $DesktopPath
$csv      = @() 
$csv      = Import-Csv -Path $FilePath 

# Set count for activity status
$i = 0

#Loop through all items in the CSV 
ForEach ($item In $csv) 
{

    # Put the objects into string variables, because new-dfsnfoldertarget likes strings
    [string]$TargetPath = $item.TargetPath
    [string]$SharePath = $item.SharePath
    [string]$PriorityClass = $item.PriorityClass

    # This little diddy will provide a progress bar!
    $i = $i+1
    Write-Progress -Activity "Adding entry to $TargetPath" -Status "Progress:" -PercentComplete ($i/$csv.Count*100)

    # Doing the work
    New-DfsnFolderTarget -Path $TargetPath -TargetPath $SharePath -State Offline -ReferralPriorityClass $PriorityClass
}
