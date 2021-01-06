# Author: @reg0bs
# Credits go to Christian Wojner (@Didelphodon) for creating DensityScout
# This script executes DensityScout and saves the results as a pipe delimited file
# The results are returned by the script to be picked up by Splunk

$DensityScoutExe = $PSScriptRoot + "\densityscout.exe"
$DensityScoutResults = $PSScriptRoot + "\densityscout.txt"
$DensityScoutThreshold = "0.1"

# Check if exe was downloaded
If (!(Test-Path $DensityScoutExe)) {
    Write-Host "File not found: " + $DensityScoutExe + ". Please download from https://www.cert.at/en/downloads/software/software-densityscout and place it into the app's bin folder" 
    Exit -1
}

# Remove previous results
Remove-Item $DensityScoutResults -ErrorAction Ignore

## densityscout.exe flags:
# -pe          Only scan files with MZ magic byte
# -o           Output file
# -r           Recursive scanning

Start-Process -FilePath $DensityScoutExe -ArgumentList "-pe", "-o `"$($DensityScoutResults)`"", "-r", "C:\windows\system32\" -Wait -WindowStyle hidden
$Densities = Import-Csv $DensityScoutResults -Delimiter "|" -Header "density", "file"
Foreach ($Item In $Densities) {
    $Item.Density = $Item.Density -replace "\(|\)", ""
    If ([decimal]$Item.Density -lt $DensityScoutThreshold) {
        Write-Output $Item
    }
}
