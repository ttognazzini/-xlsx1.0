     H DATEDIT(*YMD) OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY) DEBUG INDENT('| ')
     H DFTACTGRP(*NO)BNDDIR('#$XLSX1.0/#$XLSX')
     F* #$XLSX Example adding styles
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
     C                                                   '#$XLSXE3.xlsx')
     C*
     C* SETUP STYLES
     C*
     C* MAKE THE TITLE BIG, BOLD AND CENTERED
     C                   CALLP     #$XLSXStyle('name:TITLE'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:18'
     C                                       : 'WrapText:Yes'
     C                                       : 'Alignment:CENTER'
     C                                       : 'BoldWeight:BOLD')
     C* THE DATE ON THE TITLE ROW NEEDS A DATA FORMAT SO IT IS EDITED CORRECTLY
     C                   CALLP     #$XLSXStyle('name:TDATE'
     C                                       : 'DataFormat:yyyy/mm/dd')
     C*
     C* MAKE THE HEADER ROW, BOLD, CENTERED WITH BORDERS...
     C                   CALLP     #$XLSXStyle('name:HDR'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'WrapText:YES'
     C                                       : 'Alignment:CENTER'
     C                                       : 'BoldWeight:BOLD'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:MEDIUM'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN')
     C*
     C* THESE THREE ARE ALL FOR THE DETAIL ROW, THE FIRST ONE IS
     C* A GENERAL STYLE, THE NEXT TWO SHOW FORMATING FOR THE DATE
     C* AND DOLLAR FIELDS
     C                   CALLP     #$XLSXStyle('name:DTL'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:THIN'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN')
     C                   CALLP     #$XLSXStyle('name:DATE'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'Alignment:CENTER'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:THIN'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN'
     C                                       : 'DataFormat:yyyy/mm/dd')
     C                   CALLP     #$XLSXStyle('name:DOLLAR'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:THIN'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN'
     C                                       : 'DataFormat:#,##0.00')
     C*
     C* CREATE A NEW SHEET(TAB), SET THE SHEET NAME, FREEZE THE TOP 3 ROWS
     C                   CALLP     #$XLSXWkSh('SheetName:#$XLSXT3'
     C                                      : 'FreezeRows:3'
     C                                      : 'FreezeColumns:1')
     C*
     C* SET SOME COLUMN WIDTHS.
     C* THESE COULD HAVE BEEN DONE ON THE LINE ABOVE, BUT THEY ARE LEFT
     C* HERE TO SHOW HOW ADDITIONAL PROPERTIES CAN BE ADDED BY RE-RUNNING
     C* THE #$XLSXWkSh FUNCTION, THE FUNCTION ACCEPTS UP TO 200 PROPERTIES
     C* SO THE ONLY REASON THIS WOULD BE DONE IS IF THERE ARE HUNDREDS OF
     C* COLUMNS YOU WANT TO SET THE WIDTH FOR.
     C                   CALLP     #$XLSXWkSh('ColumnWidth:1:11'
     C                                      : 'ColumnWidth:2:30'
     C                                      : 'ColumnWidth:3:11'
     C                                      : 'ColumnWidth:4:8'
     C                                      : 'ColumnWidth:5:11')
     C*
     C* Add Title row
     C* Notice on the #$XLSChar for the title we have added the style name
     C* as the second parameter. There is also a third parameter, that is the
     C* number of cells to merge in to the cell we are using. This formats the
     C* with the properties from the style and makes it span 3 columns.
     C* All add data type functions have style and merge for the 2nd and 3rd parm.
     C                   MOVE      *DATE         #DATE             8 0
     C                   CALLP     #$XLSXChar('Inventory Report':'TITLE':2)
     C                   CALLP     #$XLSXNull()
     C                   CALLP     #$XLSXYYMD(#DATE:'TDATE')
     C*
     C* Skip a Line
     C                   CALLP     #$XLSXNext()
     C*
     C* Add the header line
     C                   CALLP     #$XLSXNext()
     C                   CALLP     #$XLSXChar('Item':'HDR')
     C                   CALLP     #$XLSXChar('Description':'HDR')
     C                   CALLP     #$XLSXChar('Setup Date':'HDR')
     C                   CALLP     #$XLSXChar('Qty on Hand':'HDR')
     C                   CALLP     #$XLSXChar('Price':'HDR')
     C*
     C* Loop through file and add each detail line, save count so a formula
     C* can be added at the bottom
     C                   MOVE      *ZEROS        COUNT             5 0
     C                   READ      #$XLSXInv
     C                   DOW       NOT %EOF
     C                   ADD       1             COUNT
     C                   CALLP     #$XLSXNext()
     C                   CALLP     #$XLSXChar(Item:'DTL')
     C                   CALLP     #$XLSXChar(Desc:'DTL')
     C                   CALLP     #$XLSXYYMD(Setup:'DATE')
     C                   CALLP     #$XLSXNumr(QtyOh:'DTL')
     C                   CALLP     #$XLSXNumr(Price:'DOLLAR')
     C                   READ      #$XLSXInv
     C                   ENDDO
     C*
     c* Add a total line using a formual to calculate it
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
