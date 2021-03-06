$Global:net = $TextBox_net.Text.ToString()
if ($net -notmatch '^(((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$|[,]|(-(25[0-5]|(2[0-4]|1\d|[1-9]|)\d),*))){3})+$') {
    $PSStyle.Formatting.Error = $PSStyle.Background.BrightRed + $PSStyle.Foreground.BrightWhite
    To_Log("Not valid IP address! Syntax: 192.168.0 or 192.168.0,10.10.12-16")
    $err = $true
    #$TextBox_net.Foreground = "Red"
    $TextBox_net.Background = "Pink"
}
else {
    $net = $net.split(",")
    $net_from_range = @()
    foreach ($n in $net) {
        if ($n -like "*-*") {
            $splitter = $n.split(".")
            $splitter2 = $splitter[2].split("-")
            $net_range = $splitter2[0]..$splitter2[1]
            foreach ($r in $net_range) {
                $net_from_range += $splitter[0] + "." + $splitter[1] + "." + $r
            }
        }
        else {
            $net_from_range += $n
        }
    }
    $net = $net_from_range | Select-Object -Unique
}

if ($CheckBox_ports.IsChecked -and ($TextBox_ports.Text.ToString() -ne '')) {
    $ports_list = @()
    $ports = $TextBox_ports.Text.ToString()
    $ports = $ports.split(",")
    foreach ($p in $ports) {
        if ($p -match '(^([1-9]|[1-5]?[0-9]{2,4}|6[1-4][0-9]{3}|65[1-4][0-9]{2}|655[1-2][0-9]|6553[1-5])$)|(^([1-9]|[1-5]?[0-9]{2,4}|6[1-4][0-9]{3}|65[1-4][0-9]{2}|655[1-2][0-9]|6553[1-5])-([1-9]|[1-5]?[0-9]{2,4}|6[1-4][0-9]{3}|65[1-4][0-9]{2}|655[1-2][0-9]|6553[1-5])$)|((?<=,|^)([1-9]|[1-5]?[0-9]{2,4}|6[1-4][0-9]{3}|65[1-4][0-9]{2}|655[1-2][0-9]|6553[1-5])(?=,|$),?)|((?<=,|^)([1-9]|[1-5]?[0-9]{2,4}|6[1-4][0-9]{3}|65[1-4][0-9]{2}|655[1-2][0-9]|6553[1-5])-([1-9]|[1-5]?[0-9]{2,4}|6[1-4][0-9]{3}|65[1-4][0-9]{2}|655[1-2][0-9]|6553[1-5])(?=,|$),?)') {
            if ($p -like "*-*") {
                $splitter = $p.split("-")
                $splitter_array = $splitter[0]..$splitter[1]
                $ports_list += $splitter_array 
            }
            else {
                $ports_list += $p
            }
        }
        else {
            Write-Error "Not valid ports! Only [1..65535]. Syntax: 25,80,135,1096-2048"
            $err = $true
            #$TextBox_ports.Foreground = "Red"
            $TextBox_ports.Background = "Pink"
        }
    }
    $ports_list = $ports_list | Select-Object -Unique
} 

$exclude_list = @()
<# if ($exclude) {
foreach ($e in $exclude) {
 if (($e -match '^(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$') -or ($e -match '^(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)-(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$')) {
     if ($e -like "*-*") {
         $splitter = $e.split("-")
         $splitter_array = $splitter[0]..$splitter[1]
         $exclude_list += $splitter_array 
     }
     else {
         $exclude_list += $e    
     }
 } 
 else {
     Write-Error "Not valid ip in -exclude! Only [0..255]. Syntax: 1,23,248-254"
     exit;    
 }
}
$exclude_list = $exclude_list | Select-Object -Unique
} #>

if (!$err) {
    
    $begin = $TextBox_begin.Text.ToString()
    $end = $TextBox_end.Text.ToString()
    $exclude_list = 1
    $ports_list = $TextBox_ports.Text.ToString()

    $range = [Math]::Abs($end - $begin) + 1 - $exclude_list.Name.count
    # $now = Get-Date -UFormat "%Y/%m/%d-%H:%M:%S"
    # $file_name = Get-Date -UFormat "%Y%m%d-%H%M%S"
    $gridout = @()
    $delimeter = (Get-Culture).TextInfo.ListSeparator

    To_Log("Start scan")
 
    $all_time = Measure-Command {
        ForEach ($n in $net) {
            [ref]$counter = 0    
            $live_ips = @()
            To_Log("Checking $range IPs from $n.$begin to $n.$end")

            $ping_time = Measure-Command {
                $pingout = $begin..$end | ForEach-Object -Parallel {
                    if (!($_ -in $($using:exclude_list))) {
                        $ip_list = $using:live_ips
                        $ip = $using:n + "." + $_
                        
                        $($using:counter).Value++
                        $status = " " + $($using:counter).Value.ToString() + "/$using:range - $ip"
                        Write-Progress -Activity "Ping" -Status $status -PercentComplete ($($using:counter).Value / ($using:range / 100))

                        $ping = Test-Connection $ip -Count 1 -IPv4
                        if ($ping.Status -eq "Success") {
                            if ($using:CheckBox_resolve.IsChecked) {            
                                try {
                                    $Name = Test-Connection $ip -Count 1 -IPv4 -ResolveDestination | Select-Object -ExpandProperty Destination
                                    #$Name = Resolve-DnsName -Name $ip -DnsOnly -ErrorAction Stop | Select-Object -ExpandProperty NameHost
                                }
                                catch {
                                    $Name = $null
                                }
                            }
                            if ($using:CheckBox_mac.IsChecked) {
                                $MAC = (arp -a $ip | Select-String '([0-9a-f]{2}-){5}[0-9a-f]{2}').Matches.Value
                                if ($MAC) {
                                    $MAC = $MAC.ToUpper()
                                }
                            }

                            if (($MAC -ne $null) -and $using:CheckBox_vendor.IsEnabled -and $using:CheckBox_vendor.IsChecked) {
                                $oui = $using:oui
                                $vendor = $oui[$MAC.replace(':', '').replace('-', '')[0..5] -join '']
                            }

                            if ($using:CheckBox_latency.IsChecked) {
                                $ms = $ping.Latency
                            }

                            if ($using:CheckBox_ports.IsChecked) { 
                                ForEach ($p in $using:ports_list) {
                                    $check_port = Test-NetConnection -ComputerName $ip -InformationLevel Quiet -Port $p -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                                    if ($check_port) {
                                        $open_ports += "$p "
                                    }
                                } 
                            }
                       
                            $ip_list += [PSCustomObject] @{
                                'IP address'   = $ip
                                'Name'         = $Name
                                'MAC address'  = $MAC
                                'Vendor'       = $vendor
                                'Latency (ms)' = $ms
                                'Open ports'   = $open_ports
                            }                       
                        }
                    }
                    return $ip_list
                    
                } -ThrottleLimit $range
                
                $live_ips = $($pingout.'IP address').count
                $pingout = $pingout | Sort-Object { $_.'IP Address' -as [Version] }
                $all_pingout += $pingout
            }
             
            $DataGridview.ItemsSource = $all_pingout | Select-Object -Property `
            @{Name = 'Grid_ip'; Expression = { $_.'IP address' } }, 
            @{Name = 'Grid_name'; Expression = { $_.Name } },
            @{Name = 'Grid_mac'; Expression = { $_.'MAC address' } },
            @{Name = 'Grid_vendor'; Expression = { $_.'Vendor' } },
            @{Name = 'Grid_latency'; Expression = { $_.'Latency (ms)' } },
            @{Name = 'Grid_ports'; Expression = { $_.'Open ports' } }
            
            <#             if ($grid) {
                $gridout += $pingout
            }

            if ($file) {
                $pingout | Export-Csv -Append -path $env:TEMP\$file_name.csv -NoTypeInformation -Delimiter $delimeter
            } #>
            To_Log("Total $live_ips live IPs from $range [$n.$begin..$n.$end]")
            $ping_time = $ping_time.ToString().SubString(0, 8)
            To_Log("Elapsed time $ping_time")
           
        }
    }  

    $all_time = $all_time.ToString().SubString(0, 8)
    To_Log("All time: $all_time")

    <#         if ($grid) {
    $gridout | Out-GridView -Title "[$now] live IPs from $net"
} #>

    <#         if ($file) {
    Write-Host "CSV file saved to $($PSStyle.Foreground.Yellow)$env:TEMP\$file_name.csv$($PSStyle.Reset)"
    Start-Process $env:TEMP\$file_name.csv
} #>





}
