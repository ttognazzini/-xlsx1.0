     H DATEDIT(*YMD) OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY) DEBUG INDENT('| ')
     H DFTACTGRP(*NO) BNDDIR('#$XLSX1.0/#$XLSX')
     F* #$XLSX Example adding more data
     F#$XLSXINV IF   E           K DISK
     D/INCLUDE #$XLSX1.0/QRPGLESRC,#$XLSX_H
     D defaultPath     DS                  dtaara('#$XLSX/#$XLSXTEMP')
     D   path                  1    100
     C******************************************************************
     C*
     C* Get default path from data area
     C                   In        defaultPath
     C*
     C* Start the Excel Work book - MUST BE DONE FIRST
     C                   CALLP     #$XLSXOpen('OutputName:'+%trim(path) +
     C                                                   '#$XLSXE2.xlsx')
     C*
     C* CREATE A NEW SHEET(TAB)
     C                   CALLP     #$XLSXWkSh()
     C*
     C* Add Title row
     C                   MOVE      *DATE         #DATE             8 0
     C                   CALLP     #$XLSXChar('Inventory Report':*omit:2)
     C                   CALLP     #$XLSXNull()
     C                   CALLP     #$XLSXYYMD(#DATE)
     C*
     C* Skip a Line
     C                   CALLP     #$XLSXNext()
     C*
     C* Add the header line
     C                   CALLP     #$XLSXNext()
     C                   CALLP     #$XLSXChar('Item')
     C                   CALLP     #$XLSXChar('Description')
     C                   CALLP     #$XLSXChar('Setup Date')
     C                   CALLP     #$XLSXChar('Qty on Hand')
     C                   CALLP     #$XLSXChar('Price')
     C*
     C* Loop through file and add each detail line, save count so a formula
     C* can be added at the bottom
     C                   MOVE      *ZEROS        COUNT             5 0
     C                   READ      #$XLSXInv
     C                   DOW       NOT %EOF
     C                   ADD       1             COUNT
     C                   CALLP     #$XLSXNext()
     C                   CALLP     #$XLSXChar(Item)
     C                   CALLP     #$XLSXChar(Desc)
     C                   CALLP     #$XLSXYYMD(Setup)
     C                   CALLP     #$XLSXNumr(QtyOh)
     C                   CALLP     #$XLSXNumr(Price)
     C                   READ      #$XLSXInv
     C                   ENDDO
     C*
     C* ADD A TOTAL LINE USING A FORMULA TO CALCULATE IT
     C                   CALLP     #$XLSXNext()
     C                   CALLP     #$XLSXNull()
     C                   CALLP     #$XLSXChar('Total:')
     C                   CALLP     #$XLSXNull()
     C                   CALLP     #$XLSXForm('=SUM(D4:D'+%char(count+3)+')')
     C*
     C* Close the open XLS File
     C                   CALLP     #$XLSXClose
     C*
     C                   SETON                                        LR
     C                   RETURN
     C******************************************************************
