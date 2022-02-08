$Button_Scan.Add_Click({
        . $PSScriptRoot\scan.ps1    
    })

$TextBox_net.Add_GotFocus({
        $TextBox_net.Foreground = "Black"
        $TextBox_net.Background = "White"
    })

$CheckBox_exclude.Add_Click({
        $CheckBox_exclude.isChecked ? ($TextBox_exclude.Visibility = "Visible") : ($TextBox_exclude.Visibility = "Hidden")
    })

$TextBox_ports.Add_GotFocus({
        $TextBox_ports.Foreground = "Black"
        $TextBox_ports.Background = "White"
    })

$CheckBox_ports.Add_Click( {
        $CheckBox_ports.isChecked ? ($TextBox_ports.Visibility = "Visible") : ($TextBox_ports.Visibility = "Hidden")
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