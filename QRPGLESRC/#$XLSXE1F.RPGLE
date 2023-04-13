     H DATEDIT(*YMD) OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY) DEBUG INDENT('| ')
     H DFTACTGRP(*NO) BNDDIR('#$XLSX1.0/#$XLSX')
     F* #$XLSX Hello World Program Fixed Format
     D/INCLUDE #$XLSX/QRPGLESRC,#$XLSX_H
     D defaultPath     DS                  dtaara('#$XLSX1.0/#$XLSXTEMP')
     D   path                  1    100
     C******************************************************************
     C*
     C* Get default path from data area
     C                   In        defaultPath
     C*
     C* Start the Excel Work book - MUST BE DONE FIRST
     C                   CALLP     #$XLSXOpen('OutputName:'+%trim(path) +
     C                                                   '#$XLSXE1.xlsx')
     C*
     C* CREATE A NEW SHEET(TAB)
     C                   CALLP     #$XLSXWkSh()
     C*
     C* POPULATE THE FIRST CELL IN THE FIRST ROW
     C                   CALLP     #$XLSXCHAR('Hello World')
     C*
     C* Close the open XLS File
     C                   CALLP     #$XLSXClose
     C*
     C                   SETON                                        LR
     C                   RETURN
     C******************************************************************
