PS C:\Users\warfa> Get-Command Get-* -CommandType Cmdlet | Measure-Object

Count    : 234
Average  :
Sum      :
Maximum  :
Minimum  :
Property :

PS C:\Users\warfa> (Get-Process | Select-Object -First 1 | Get-Member -MemberType Property | Measure-Object).Count

52

/--/

/--/