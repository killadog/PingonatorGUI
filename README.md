# PingonatorGUI

![Powershell >= 7.0](https://img.shields.io/badge/Powershell-%3E=7.0-blue.svg)

## Parallel network check

*fast and furious*

##Prepare your own oui.txt
*IEEE Public OUI and Company ID*

Download https://standards.ieee.org/develop/regauth/oui/oui.csv

Replace in [Notepad++](https://notepad-plus-plus.org/downloads/)
```
MA-L,
<nothing!>
```
```
([0-9a-fA-F]{6},)("(.*?)")((,".*")|(.*))
\1\2
```
```
^([0-9a-fA-F]{6}),
"\1",
```
```
^("[0-9a-fA-F]{6}",)(.*?)$
\1\2"
```
```
^("[0-9a-fA-F]{6}",)([^"](.*?))$
\1"\2
```
```
","
=
```
```
"
<nothing!>
```

Strange dublicates:
080030 
0001C8


