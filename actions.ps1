$Button_Scan.Add_Click({
        . $PSScriptRoot\scan.ps1    
    })

$TextBox_net.Add_GotFocus({
        $TextBox_net.Foreground = "Black"
    })

$CheckBox_exclude.Add_Click({
        $CheckBox_exclude.isChecked ? ($TextBox_exclude.isEnabled = $true) : ($TextBox_exclude.isEnabled = $false)
    })

$TextBox_ports.Add_GotFocus({
        $TextBox_ports.Foreground = "Black"
    })

$CheckBox_ports.Add_Click( {
        ($CheckBox_ports.isChecked) ? ($TextBox_ports.isEnabled = $true) : ($TextBox_ports.isEnabled = $false)
    })

$CheckBox_mac.Add_Click({
        if ($CheckBox_mac.isChecked) {
            $CheckBox_vendor.IsEnabled = $true
            $CheckBox_vendor.Foreground = "Black"
        }
        else {
            $CheckBox_vendor.IsEnabled = $false
            $CheckBox_vendor.Foreground = "Gray"
        }
    })

$Window.Add_KeyDown({
        if ($_.Key -eq 'Enter') {
            . $PSScriptRoot\scan.ps1
        }
    })

$Splitter.add_LostMouseCapture({
        $RichTextBox_Log.ScrollToEnd()
    })