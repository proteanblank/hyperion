# This test file was generated from offline assembler source
# by bldhtc.rexx 16 Jan 2016 12:11:11
# Treat as object code.  That is, modifications will be lost.
# assemble and listing files are provided for information only.
*Testcase agf processed 16 Jan 2016 12:11:11 by bldhtc.rexx
sysclear
archmode z
r    1A0=00000001800000000000000000000200
r    1D0=0002000180000000FFFFFFFFDEADDEAD
r    200=410000094110025041F009005B800008
r    210=E3401000000458501008E34010080018
r    220=B2220080E340F00000245080F00841F0
r    230=F010411010104600
r    238=0210B2B20240
r    240=00020001800000000000000000000000
r    250=00000000000000050000000300000000
r    260=FFFFFFFFFFFFFFFBFFFFFFFD00000000
r    270=FFFFFFFFFFFFFFFB
r    278=00000003000000008000000000000000
r    288=00000001000000007FFFFFFFFFFFFFFF
r    298=800000000000000000000000FFFFFFFF
r    2A8=0000000100000000
r    2B0=00000001000000000000000100000000
r    2C0=0000000100000000FFFFFFFF00000000
r    2D0=000000000000000000000000
runtest .1
*Compare
r 900.9
*Want 00000000 00000008 20
r 910.9
*Want FFFFFFFF FFFFFFF8 10
r 920.9
*Want FFFFFFFF FFFFFFFE 10
r 930.9
*Want 80000000 00000001 10
r 940.9
*Want 7FFFFFFF 7FFFFFFF 20
r 950.9
*Want 00000001 00000000 20
r 960.9
*Want 00000001 00000001 20
r 970.9
*Want 00000000 FFFFFFFF 20
r 980.9
*Want 00000000 00000000 00
*Done
