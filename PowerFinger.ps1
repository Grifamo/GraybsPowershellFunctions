﻿$finger = @"
....................../´¯/) 
....................,/¯../ 
.................../..../ 
............./´¯/'...'/´¯¯`·¸ 
........../'/.../..../......./¨¯\ 
........('(...´...´.... ¯~/'...') 
.........\.................'...../ 
..........''...\.......... _.·´ 
............\..............( 
..............\.............\...
"@

$box = new-object -comobject wscript.shell
$popup = $box.popup($finger,0,"PowerFinger",0x10)