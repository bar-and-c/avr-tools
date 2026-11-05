Get-PnpDevice -Class Ports -PresentOnly |
  Where-Object { $_.InstanceId -like 'USB\VID_1A86&PID_7523*' } |
    ForEach-Object {
      if ($_.FriendlyName -match '\((COM\d+)\)') { $Matches[1] }
    }
