# PingonatorGUI

![Powershell >= 7.0](https://img.shields.io/badge/Powershell-%3E=7.0-blue.svg)

## Parallel network check

*fast and furious*

##Prepare your own oui.txt
*IEEE Public OUI and Company ID*

Download https://standards.ieee.org/develop/regauth/oui/oui.csv.

Open oui.csv in [Notepad++](https://notepad-plus-plus.org/downloads/) and replace 
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
Rename file to **oui.txt**

>Strange dublicates (delete and leave only one):
080030 
0001C8


