<#
.SYNOPSIS 
Parallel network scan
.NOTES
Author: Rad
Date: December 9, 2021
URL: https://github.com/killadog/PingonatorGUI 
#>

#Requires -Version 7.0

function To_Log {
    param (
        $Log_text
    )
    $now = Get-Date -UFormat "`n[%Y/%m/%d-%H:%M:%S] "
    $RichTextBox_Log.AppendText("$now $Log_text")
    $RichTextBox_Log.ScrollToEnd(); 
}

Add-Type -AssemblyName presentationframework

[xml]$XAML = Get-Content "$PSScriptRoot\app.xaml"
$XAMLReader = New-Object System.Xml.XmlNodeReader $XAML
$Window = [Windows.Markup.XamlReader]::Load($XAMLReader)
$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) }

$oui = Get-Content -raw .\oui.txt | ConvertFrom-StringData

. $PSScriptRoot\actions.ps1

[void]$Window.ShowDialog() | out-null 