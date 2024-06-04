 TITLE 'zvector-e6-15-comparedecimal: VECTOR E6 VRR-h instruction'
***********************************************************************
*
*        Zvector E6 instruction tests for VRR-h encoded:
*
*        E677 VCP     - VECTOR COMPARE DECIMAL
*
*        James Wekel June 2024
***********************************************************************

***********************************************************************
*
*        basic instruction tests
*
***********************************************************************
*  This program tests proper functioning of the z/arch E6 VRR-h vector
*  compare decimal. Exceptions are not tested.
*
*  PLEASE NOTE that the tests are very SIMPLE TESTS designed to catch
*  obvious coding errors.  None of the tests are thorough.  They are
*  NOT designed to test all aspects of any of the instructions.
*
***********************************************************************
*
*   *Testcase zvector-e6-15-comparedecimal: VECTOR E6 VRR-h instruction
*   *
*   *   Zvector E6 tests for VRR-h encoded instruction:
*   *
*   *   E677 VCP     - VECTOR COMPARE DECIMAL
*   *
*   *   # -------------------------------------------------------
*   *   #  This tests only the basic function of the instruction.
*   *   #  Exceptions are NOT tested.
*   *   # -------------------------------------------------------
*   *
*   mainsize    2
*   numcpu      1
*   sysclear
*   archlvl     z/Arch
*
*   diag8cmd    enable    # (needed for messages to Hercules console)
*   loadcore    "$(testpath)/zvector-e6-15-comparedecimal.core" 0x0
*   diag8cmd    disable   # (reset back to default)
*
*   *Done
*
***********************************************************************
                                                                SPACE 2
ZVE6TST  START 0
         USING ZVE6TST,R0            Low core addressability

SVOLDPSW EQU   ZVE6TST+X'140'        z/Arch Supervisor call old PSW
                                                                SPACE 2
         ORG   ZVE6TST+X'1A0'        z/Architecure RESTART PSW
         DC    X'0000000180000000'
         DC    AD(BEGIN)
                                                                SPACE 2
         ORG   ZVE6TST+X'1D0'        z/Architecure PROGRAM CHECK PSW
         DC    X'0002000180000000'
         DC    AD(X'DEAD')
                                                                SPACE 3
         ORG   ZVE6TST+X'200'        Start of actual test program...

                                                                EJECT
***********************************************************************
*               The actual "ZVE6TST" program itself...
***********************************************************************
*
*  Architecture Mode: z/Arch
*  Register Usage:
*
*   R0       (work)
*   R1-4     (work)
*   R5       Testing control table - current test base
*   R6-R7    (work)
*   R8       First base register
*   R9       Second base register
*   R10      Third base register
*   R11      E6TEST call return
*   R12      E6TESTS register
*   R13      (work)
*   R14      Subroutine call
*   R15      Secondary Subroutine call or work
*
***********************************************************************
                                                                SPACE
         USING  BEGIN,R8        FIRST Base Register
         USING  BEGIN+4096,R9   SECOND Base Register
                                                                SPACE
BEGIN    BALR  R8,0             Initalize FIRST base register
         BCTR  R8,0             Initalize FIRST base register
         BCTR  R8,0             Initalize FIRST base register
                                                                SPACE
         LA    R9,2048(,R8)     Initalize SECOND base register
         LA    R9,2048(,R9)     Initalize SECOND base register
                                                                SPACE
         LA    R10,2048(,R9)    Initalize THIRD base register
         LA    R10,2048(,R10)   Initalize THIRD base register

         STCTL R0,R0,CTLR0      Store CR0 to enable AFP
         OI    CTLR0+1,X'04'    Turn on AFP bit
         OI    CTLR0+1,X'02'    Turn on Vector bit
         LCTL  R0,R0,CTLR0      Reload updated CR0
                                                                EJECT
***********************************************************************
*              Do tests in the E6TESTS table
***********************************************************************

         L     R12,E6TADR       get table of test addresses

NEXTE6   EQU   *
         L     R5,0(0,R12)       get test address
         LTR   R5,R5                have a test?
         BZ    ENDTEST                 done?

         XGR   R0,R0             no cc error

         USING E6TEST,R5

         L     R11,TSUB          get address of test routine
         BALR  R11,R11           do test

         LB    R1,CCMASK         (failure CC mask)
         SLL   R1,4              (shift to BC instr CC position)
         EX    R1,TESTCC            fail if...

         LA    R12,4(0,R12)      next test address
         B     NEXTE6

TESTCC   BC    0,CCMSG          (fail if unexpected condition code)

                                                                 EJECT
***********************************************************************
* cc was not as expected
***********************************************************************
CCMSG    EQU   *
*
* extract CC extracted PSW
*
         L     R1,CCPSW
         SRL   R1,12
         N     R1,=XL4'3'
         STC   R1,CCFOUND     save cc
*
* FILL IN MESSAGE
*
         LH    R2,TNUM                 get test number and convert
         CVD   R2,DECNUM
         MVC   PRT3,EDIT
         ED    PRT3,DECNUM
         MVC   CCPRTNUM(3),PRT3+13     fill in message with test #

         MVC   CCPRTNAME,OPNAME        fill in message with instruction

         XGR   R2,R2                   get CC as U8
         IC    R2,CC
         CVD   R2,DECNUM               and convert
         MVC   PRT3,EDIT
         ED    PRT3,DECNUM
         MVC   CCPRTEXP(1),PRT3+15     fill in message with CC field

         XGR   R2,R2                   get CCFOUND as U8
         IC    R2,CCFOUND
         CVD   R2,DECNUM               and convert
         MVC   PRT3,EDIT
         ED    PRT3,DECNUM
         MVC   CCPRTGOT(1),PRT3+15    fill in message with ccfound

         LA    R0,CCPRTLNG            message length
         LA    R1,CCPRTLINE           messagfe address
         BAL   R15,RPTERROR

         B     FAILCONT
                                                                 EJECT
***********************************************************************
* continue after a failed test
***********************************************************************
FAILCONT EQU   *
         L     R0,=F'1'          set GLOBAL failed test indicator
         ST    R0,FAILED

         LA    R12,4(0,R12)      next test address
         B     NEXTE6
                                                                SPACE 2
***********************************************************************
* end of testing; set ending psw
***********************************************************************
ENDTEST  EQU   *
         L     R1,FAILED         did a test fail?
         LTR   R1,R1
         BZ    EOJ                  No, exit
         B     FAILTEST             Yes, exit with BAD PSW

                                                                EJECT
***********************************************************************
*        RPTERROR          Report instruction test in error
*                             R0 = MESSGAE LENGTH
*                             R1 = ADDRESS OF MESSAGE
***********************************************************************
                                                               SPACE
RPTERROR ST    R15,RPTSAVE          Save return address
         ST    R5,RPTSVR5           Save R5
*
*        Use Hercules Diagnose for Message to console
*
         STM   R0,R2,RPTDWSAV       save regs used by MSG
         BAL   R2,MSG               call Hercules console MSG display
         LM    R0,R2,RPTDWSAV       restore regs
                                                               SPACE 2
         L     R5,RPTSVR5           Restore R5
         L     R15,RPTSAVE          Restore return address
         BR    R15                  Return to caller
                                                               SPACE
RPTSAVE  DC    F'0'                 R15 save area
RPTSVR5  DC    F'0'                 R5 save area
                                                               SPACE
RPTDWSAV DC    2D'0'                R0-R2 save area for MSG call
                                                               EJECT
***********************************************************************
*        Issue HERCULES MESSAGE pointed to by R1, length in R0
*              R2 = return address
***********************************************************************

MSG      CH    R0,=H'0'               Do we even HAVE a message?
         BNHR  R2                     No, ignore

         STM   R0,R2,MSGSAVE          Save registers

         CH    R0,=AL2(L'MSGMSG)      Message length within limits?
         BNH   MSGOK                  Yes, continue
         LA    R0,L'MSGMSG            No, set to maximum

MSGOK    LR    R2,R0                  Copy length to work register
         BCTR  R2,0                   Minus-1 for execute
         EX    R2,MSGMVC              Copy message to O/P buffer

         LA    R2,1+L'MSGCMD(,R2)     Calculate true command length
         LA    R1,MSGCMD              Point to true command

         DC    X'83',X'12',X'0008'    Issue Hercules Diagnose X'008'
         BZ    MSGRET                 Return if successful
         DC    H'0'                   CRASH for debugging purposes

MSGRET   LM    R0,R2,MSGSAVE          Restore registers
         BR    R2                     Return to caller
                                                                SPACE 4
MSGSAVE  DC    3F'0'                  Registers save area
MSGMVC   MVC   MSGMSG(0),0(R1)        Executed instruction
                                                                SPACE 2
MSGCMD   DC    C'MSGNOH * '           *** HERCULES MESSAGE COMMAND ***
MSGMSG   DC    CL95' '                The message text to be displayed

                                                                EJECT
***********************************************************************
*        Normal completion or Abnormal termination PSWs
***********************************************************************
                                                                SPACE 4
EOJPSW   DC    0D'0',X'0002000180000000',AD(0)
                                                                SPACE
EOJ      LPSWE EOJPSW               Normal completion
                                                                SPACE 4
FAILPSW  DC    0D'0',X'0002000180000000',AD(X'BAD')
                                                                SPACE
FAILTEST LPSWE FAILPSW              Abnormal termination
                                                                SPACE 4
***********************************************************************
*        Working Storage
***********************************************************************
                                                                SPACE 2
CTLR0    DS    F                CR0
         DS    F

E6TADR   DC    A(E6TESTS)       address of E6 test table
                                                                SPACE 2
         LTORG ,                Literals pool

*        some constants

K        EQU   1024             One KB
PAGE     EQU   (4*K)            Size of one page
K64      EQU   (64*K)           64 KB
MB       EQU   (K*K)             1 MB


REG2PATT EQU   X'AABBCCDD'    Polluted Register pattern
REG2LOW  EQU         X'DD'    (last byte above)
                                                                EJECT
*======================================================================
*
*  NOTE: start data on an address that is easy to display
*        within Hercules
*
*======================================================================

         ORG   ZVE6TST+X'1000'
FAILED   DC    F'0'                     some test failed?
                                                               SPACE 2
***********************************************************************
*        TEST failed : CC message
***********************************************************************
*
*        failed message and associated editting
*
CCPRTLINE DC   C'         Test # '
CCPRTNUM DC    C'xxx'
         DC    c' wrong cc for instruction '
CCPRTNAME DC    CL8'xxxxxxxx'
         DC    C' expected: cc='
CCPRTEXP DC    C'x'
         DC    C','
         DC    C' received: cc='
CCPRTGOT DC    C'x'
         DC    C'.'
CCPRTLNG   EQU   *-CCPRTLINE
                                                               EJECT
***********************************************************************
*        TEST failed : message working storge
***********************************************************************
EDIT     DC    XL18'402120202020202020202020202020202020'

         DC    C'===>'
PRT3     DC    CL18' '
         DC    C'<==='
DECNUM   DS    CL16
*
*        CC extrtaction
*
CCPSW    DS    2F          extract PSW after test (has CC)
CCFOUND  DS    X           extracted cc
                                                                SPACE 2
***********************************************************************
*        Vector instruction results, pollution and input
***********************************************************************
         DS    0FD
R1FUDGE  DC    XL8'AABBCCDDEEFFAABB'                     R1 FUDGE
         DS    XL16                                          gap
V1OUTPUT DS    XL16                                      V1 OUTPUT
         DS    XL16                                          gap
R1OUTPUT DS    FD                                        R1 OUTPUT
         DS    XL16                                          gap
V1FUDGE  DC    XL16'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'    V1 FUDGE
V1FUDGEB DC    XL16'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'    V1 FUDGE b
V1INPUT  DC    CL16'1234567890123456'                    V1 input
         DC    CL14'78901234567890'
         DC    X'D9'
         DS    XL16                                          gap
                                                                EJECT
***********************************************************************
*        E6TEST DSECT
***********************************************************************
                                                                SPACE 2
E6TEST   DSECT ,
TSUB     DC    A(0)           pointer  to test
TNUM     DC    H'00'          Test Number
         DC    XL1'00'
M3       DC    HL1'00'        m3
CC       DC    HL1'00'        cc
CCMASK   DC    HL1'00'        not expected CC mask

OPNAME   DC    CL8' '         E6 name

RELEN    DC    A(0)           RESULT LENGTH
READDR   DC    A(0)           expected result address

**
*        test routine will be here (from VRR_H  macro)
* followed by
*        16-byte v1 source
*        16-byte v2 source
                                                                EJECT
***********************************************************************
*     Macros to help build test tables
*----------------------------------------------------------------------
*     VRR_H Macro to help build test tables
***********************************************************************
         MACRO
         VRR_H &INST,&M3,&CC
.*                               &INST  - instruction under test
.*                               &CC    - expected CC
.*
         LCLA  &XCC(4)  &CC has mask values for FAILED condition codes
&XCC(1)  SETA  7                 CC != 0
&XCC(2)  SETA  11                CC != 1
&XCC(3)  SETA  13                CC != 2
&XCC(4)  SETA  14                CC != 3

         GBLA  &TNUM
&TNUM    SETA  &TNUM+1

         DS    0FD
         USING *,R5              base for test data and test routine

T&TNUM   DC    A(X&TNUM)         address of test routine
         DC    H'&TNUM'          test number
         DC    XL1'00'
         DC    HL1'&M3'          m3
         DC    HL1'&CC'          cc
         DC    HL1'&XCC(&CC+1)'  cc failed mask

         DC    CL8'&INST'        instruction name

         DC    A(16)             result length
REA&TNUM DC    A(RE&TNUM)        result address
.*
*                                INSTRUCTION UNDER TEST ROUTINE
X&TNUM   DS    0F
         VL    V1,RE&TNUM        get V1 source
         VL    V2,RE&TNUM+16     get V2 source

         &INST V1,V2,&M3         test instruction

         EPSW  R2,R0             exptract psw
         ST    R2,CCPSW              to save CC

         BR    R11               return

RE&TNUM  DC    0F
         DROP  R5

         MEND
                                                               EJECT
***********************************************************************
*     PTTABLE Macro to generate table of pointers to individual tests
***********************************************************************

         MACRO
         PTTABLE
         GBLA  &TNUM
         LCLA  &CUR
&CUR     SETA  1
.*
TTABLE   DS    0F
.LOOP    ANOP
.*
         DC    A(T&CUR)          address of test
.*
&CUR     SETA  &CUR+1
         AIF   (&CUR LE &TNUM).LOOP
*
         DC    A(0)              END OF TABLE
         DC    A(0)
.*
         MEND
                                                                EJECT
***********************************************************************
*        E6 VRR_H tests
***********************************************************************
ZVE6TST  CSECT ,
         DS    0F
                                                                SPACE 2
         PRINT DATA
*
*        E677 VCP     - VECTOR COMPARE DECIMAL
*        VRR_H instr, m3, cc
*              followed by
*              v1     - 16 byte source
*              v2     - 16 byte source
*
*---------------------------------------------------------------------
* VCP     - VECTOR COMPARE DECIMAL
*---------------------------------------------------------------------
* VCP simple                                    m3= 0   (P1=0, P2=0)
*                                               m3= 4   (P1=0, P2=1)
*                                               m3= 8   (P1=1, P2=0)
*                                               m3=12   (P1=1, P2=1)
* m3= 0   (P1=0, P2=0)
         VRR_H VCP,0,0
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,0,0
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,0,1
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000C'   V2 source

         VRR_H VCP,0,1
         DC    XL16'0000099000000000000234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,0,2
         DC    XL16'0000000000000000001234500000000C'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,0,2
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000000234500000000C'   V2 source

* m3= 4   (P1=0, P2=1)
         VRR_H VCP,4,1
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,4,0
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,4,1
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000C'   V2 source

         VRR_H VCP,4,1
         DC    XL16'0000099000000000000234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,4,0
         DC    XL16'0000000000000000001234500000000C'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,4,2
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000000234500000000C'   V2 source

* m3= 8   (P1=1, P2=0)
         VRR_H VCP,8,2
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,8,0
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,8,0
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000C'   V2 source

         VRR_H VCP,8,1
         DC    XL16'0000099000000000000234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,8,2
         DC    XL16'0000000000000000001234500000000C'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,8,2
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000000234500000000C'   V2 source

* m3=12   (P1=1, P2=1)
         VRR_H VCP,12,0
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,12,0
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,12,0
         DC    XL16'0000000000000000001234500000000D'   V1 source
         DC    XL16'0000000000000000001234500000000C'   V2 source

         VRR_H VCP,12,1
         DC    XL16'0000099000000000000234500000000C'   V1 source
         DC    XL16'0000099000000000001234500000000C'   V2 source

         VRR_H VCP,12,0
         DC    XL16'0000000000000000001234500000000C'   V1 source
         DC    XL16'0000000000000000001234500000000D'   V2 source

         VRR_H VCP,12,2
         DC    XL16'0000099000000000001234500000000C'   V1 source
         DC    XL16'0000099000000000000234500000000C'   V2 source

         DC    F'0'     END OF TABLE
         DC    F'0'
*
* table of pointers to individual load test
*
E6TESTS  DS    0F
         PTTABLE

         DC    F'0'     END OF TABLE
         DC    F'0'
                                                                 EJECT
***********************************************************************
*        Register equates
***********************************************************************
                                                                SPACE 2
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
                                                                SPACE 8
***********************************************************************
*        Register equates
***********************************************************************
                                                                SPACE 2
V0       EQU   0
V1       EQU   1
V2       EQU   2
V3       EQU   3
V4       EQU   4
V5       EQU   5
V6       EQU   6
V7       EQU   7
V8       EQU   8
V9       EQU   9
V10      EQU   10
V11      EQU   11
V12      EQU   12
V13      EQU   13
V14      EQU   14
V15      EQU   15
V16      EQU   16
V17      EQU   17
V18      EQU   18
V19      EQU   19
V20      EQU   20
V21      EQU   21
V22      EQU   22
V23      EQU   23
V24      EQU   24
V25      EQU   25
V26      EQU   26
V27      EQU   27
V28      EQU   28
V29      EQU   29
V30      EQU   30
V31      EQU   31

         END
