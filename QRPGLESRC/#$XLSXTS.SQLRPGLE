     H DATEDIT(*YMD) OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY) DEBUG INDENT('| ')
     H DFTACTGRP(*NO) BNDDIR('#$XLSX1.0/#$XLSX')
     F* Create pretty Excel File test
     D*
     D  INVDS        E DS                  EXTNAME(#$XLSXINV)
     D*
     D COLORS          S             30A   DIM(48) CTDATA PERRCD(1)
     D*
     D FILLS           S             61A   DIM(18) CTDATA PERRCD(1)
     D FILLSPTR        S               *   INZ(%ADDR(FILLS))
     D FILL            DS                  DIM(18) QUALIFIED BASED(FILLSPTR)
     D   CODE1                       30A
     D   CODE2                       30A
     D   CODE3                        1A
     D*
     D cmd             s           1000A
     D SQLSTM          s           1000A
     D i               S              5S 0
     D j               S              5S 0
     D EOR             s              2a   inz( x'0D25' )
     D*
     D defaultPath     DS                  dtaara('#$XLSX/#$XLSXTEMP')
     D   path                  1    100
     D*
     D/INCLUDE #$XLSX1.0/QRPGLESRC,#$XLSX_H
     D*
     C******************************************************************
     C*
     C* Get default path from data area
     C                   In        defaultPath
     C*
     C*                  EVAL      FILSPTR=%ADDR(FILLS)
     C*
     C                   MOVE      *DATE         #DATE             8 0
     C                   TIME                    #TIME             6 0
     C*
     C* CREATE XLS FILE IN THE IFS - MUST BE DONE BEFORE CREATING STYLES
     C                   CALLP     #$XLSXOpen('OutputName:'+%trim(path)+
     C                                         '/#$XLSXTS.xlsx'
     C                                       : 'Debug:*Off'
     C                                       : 'Creator:Tim Tognazzini'
     C                                       : 'Company:myCompany, Inc.'
     C                                       : 'Title:myTitle'
     C                                       : 'Subject:mySubject'
     C                                       : 'Manager:myManager'
     C                                       : 'Tags:tag1;tag2;'
     C                                       : 'Category:myCategory'
     C                                       : 'Status:myStatus'
     C                                       : 'Comments: wholatta +
     C                                          comments'+eor+
     C                                         'line 2 of comments'+eor+
     C                                         'line 3 of comments'
     C                                       : 'HyperLinkBase:+
     C                                          myHyperLinkBase.com'
     C                                       : 'CustomProperty:+
     C                                          testText:text:mytext'
     C                                       : 'CustomProperty:+
     C                                          testdate:Date:20200225'
     C                                       : 'CustomProperty:+
     C                                          testnum1:number:12345'
     C                                       : 'CustomProperty:+
     C                                          testnum2:number:123.45'
     C                                       : 'CustomProperty:+
     C                                          testnum3:number:-123.45'
     C                                       : 'CustomProperty:+
     C                                          testyes:yesorno:yes'
     C                                       : 'CustomProperty:+
     C                                          teston:yesorno:yes'
     C                                       : 'CustomProperty:+
     C                                          test1:yesorno:yes'
     C                                       : 'CustomProperty:+
     C                                          testtrue:yesorno:yes'
     C                                       : 'CustomProperty:+
     C                                          testno:boolean:no'
     C                                       : 'CustomProperty:+
     C                                          testoff:boolean:*off'
     C                                       : 'CustomProperty:+
     C                                          test0:yesorno:0'
     C                                       : 'CustomProperty:+
     C                                          testfalse:yesorno:false'
     C                                       : 'Buffering:1')
     C*
     C* ADD A REPORT LOOKING SHEET FOR TAB 1
     C                   EXSR      ADDRPT
     C*
     C* ADDS A SEPERATE PAGE WITH FORMATTING EXAMPLES
     C                   EXSR      ADDFMTTS
     C*
     C* ADDS A SEPERATE PAGE WITH FORMATTING EXAMPLES
     C                   EXSR      ADDCOLORS
     C*
     C* ADD A TAB FOR HEADER/FOOTER TESTING
     C                   EXSR      ADDHDR
     C*
     C* ADD A TAB FOR testing #$XSLXCELL
     C                   EXSR      ADDCELL
     C*
     C* ADD A TAB FOR testing adding data
     C                   EXSR      ADDDATA
     C*
     C* Close the open XLS File
     C                   CALLP     #$XLSXClose
     C*
     C                   SETON                                        LR
     C                   RETURN
     C******************************************************************
     C     ADDRPT        BEGSR
     C*
     C* SETUP STYLES
     C                   CALLP     #$XLSXStyle('name:S_DTL'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:THIN'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN')
     C                   CALLP     #$XLSXStyle('name:S_DATE'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'Alignment:CENTER'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:THIN'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN'
     C                                       : 'DataFormat:yyyy/mm/dd')
     C                   CALLP     #$XLSXStyle('name:S_DOLLAR'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:THIN'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN'
     C                                       : 'DataFormat:#,##0.00')
     C                   CALLP     #$XLSXStyle('name:S_TITLE'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:18'
     C                                       : 'WrapText:Yes'
     C                                       : 'Alignment:CENTER'
     C                                       : 'BoldWeight:BOLD')
     C                   CALLP     #$XLSXStyle('name:S_HDR'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'WrapText:YES'
     C                                       : 'Alignment:CENTER'
     C                                       : 'BoldWeight:BOLD'
     C                                       : 'BorderTop:THIN'
     C                                       : 'BorderBottom:THIN'
     C                                       : 'BorderLeft:THIN'
     C                                       : 'BorderRight:THIN')
     C                   CALLP     #$XLSXStyle('name:S_HDR2'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'WrapText:YES'
     C                                       : 'Alignment:CENTER'
     C                                       : 'BoldWeight:BOLD'
     C                                       : 'BorderBottom:THIN')
     C*
     C* CREATE A NEW SHEET(TAB)
     C                   CALLP     #$XLSXWkSh('SheetName:#$XLSXTS'
     C                                      : 'FreezeRows:3'
     C                                      : 'ColumnWidth:1:12'
     C                                      : 'ColumnWidth:2:30'
     C                                      : 'ColumnWidth:3:12'
     C                                      : 'ColumnWidth:4:12'
     C                                      : 'ColumnWidth:5:12'
     C                                      : 'ColumnWidth:6:12'
     C                                      : 'ColumnWidth:7:12'
     C                                      : 'ColumnWidth:8:12')
     C*
     C* ADDING HEADING OPTIONS, THIS COULD HAVE BEEN DONE IN THE PREVIOUS STATEMENT
     C* BUT THIS SHOWS HOW YOU CAN ADD ON UNTIL DATA HAS BEEN ADDED
     C* FREE FORAMT BECAUSE IT DIDN'T FIT ON ONE LINE
            #$XLSXWkSh('Header:Pgm: #$XLSXTS:Arial Narrow:24:Italic:+
                               Left:subscript'
                     : 'Header:Inventory Report:Arial:24:Bold'
                     : 'Header:*DATE *TIME:Calibri:10:Right:Bold:Italic'
                     : 'Footer:*PATH*FILE:Arial:8:Left:Color:Red:+
                               DoubleUnderline:superscript'
                     : 'Footer:*PAGE of *PAGES:Arial:12:Color:Green:+
                               Underline:StrikeThrough'
                     : 'Footer:Sheet *NAME:Arial:8:right');
     C*
     C* ADD HEADER RECORD 1 AND 2
     C                   CALLP     #$XLSXCHAR('TEST #$XLSX - Pretty +
     C                                        Excel Files':'S_TITLE':3)
     C                   CALLP     #$XLSXCHAR('#$XLSXTS')
     C                   CALLP     #$XLSXCHAR(%EDITW(#DATE:'    /  / 0'))
     C                   CALLP     #$XLSXCHAR(%EDITW(#TIME:'  :  : 0'))
     C*
     C* SKIP 2 LINES AND ADD A HEADER ROW
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('Item':'S_HDR')
     C                   CALLP     #$XLSXCHAR('Description':'S_HDR')
     C                   CALLP     #$XLSXCHAR('Setup' + eor + 'Date':'S_HDR')
     C                   CALLP     #$XLSXCHAR('Quantity'+eor+'on Hand':'S_HDR')
     C                   CALLP     #$XLSXCHAR('Price':'S_HDR')
     C*
     C* LOOP THROUGH TEST ITEMS
     C                   EVAL      SQLSTM='SELECT * FROM #$XLSXINV'
       EXEC SQL PREPARE SQL1 FROM :SQLSTM;
       EXEC SQL DECLARE SQLCRS1 CURSOR FOR SQL1;
       EXEC SQL OPEN SQLCRS1;
       EXEC SQL FETCH NEXT FROM SQLCRS1 INTO :INVDS;
       DOW SQLSTT='00000';
          EXSR ADDDTL;
          EXEC SQL FETCH NEXT FROM SQLCRS1 INTO :INVDS;
       ENDDO;
       EXEC SQL CLOSE SQLCRS1;
     C*
     C                   ENDSR
     C******************************************************************
     C     ADDDTL        BEGSR
     C*
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR(ITEM:'S_DTL')
     C                   CALLP     #$XLSXCHAR(DESC:'S_DTL')
     C                   CALLP     #$XLSXYYMD(SETUP:'S_DATE')
     C                   CALLP     #$XLSXNUMR(QTYOH:'S_DOLLAR')
     C                   CALLP     #$XLSXNUMR(PRICE:'S_DOLLAR')
     C*
     C                   ENDSR
     C******************************************************************
     C* ADDS A NEW WORK SHEET(TAB) WITH STYLE EXAMPLES
     C     ADDFMTTS      BEGSR
     C*
     C* CREATE A NEW WORKSHEET(TAB) WITH ZOOM= 200%
     C                   CALLP     #$XLSXWkSh('SheetName:Test Styles'
     C                                      : 'ColumnWidth: 1: 30'
     C                                      : 'ColumnWidth: 2: 30'
     C                                      : 'ColumnWidth: 3: 30'
     C                                      : 'ColumnWidth: 4: 30'
     C                                      : 'ColumnWidth: 5: 30'
     C                                      : 'ColumnWidth: 6: 30'
     C                                      : 'ColumnWidth: 7: 30'
     C                                      : 'ColumnWidth: 8: 30'
     C                                      : 'ColumnWidth: 9: 30'
     C                                      : 'ColumnWidth:10: 30'
     C                                      : 'ColumnWidth:11: 30'
     C                                      : 'Filter:A1:B1')
     C*
     C* ADD A HEADER ROW
     C                   CALLP     #$XLSXCHAR('Output')
     C                   CALLP     #$XLSXCHAR('Options')
     C                   CALLP     #$XLSXNEXT
     C*
     C* CREATE A TEST STYLE AND ADD IT
     C                   CALLP     #$XLSXStyle('name:S_TST01'
     C                                       : 'Font:Arial'
     C                                       : 'PointSize:10'
     C                                       : 'BorderBottom:DOUBLE'
     C                                       : 'Color:BLUE')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 01':'S_TST01')
     C                   CALLP     #$XLSXCHAR('Font:Arial')
     C                   CALLP     #$XLSXCHAR('PointSize:10')
     C                   CALLP     #$XLSXCHAR('BorderBottom:DOUBLE')
     C                   CALLP     #$XLSXCHAR('Color:BLUE')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST02'
     C                                       : 'Font:Times New Roman'
     C                                       : 'PointSize:18'
     C                                       : 'BorderTop:DASH_DOT_DOT'
     C                                       : 'BorderBottom:MEDIUM_DASHED'
     C                                       : 'BorderLeft:DOTTED'
     C                                       : 'BorderRight:MEDIUM'
     C                                       : 'Color:MAROON')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 02':'S_TST02')
     C                   CALLP     #$XLSXCHAR('Font:Times New Roman')
     C                   CALLP     #$XLSXCHAR('PointSize:18')
     C                   CALLP     #$XLSXCHAR('BorderTop:DASH_DOT_DOT')
     C                   CALLP     #$XLSXCHAR('BorderBottom:MEDIUM_DASHED')
     C                   CALLP     #$XLSXCHAR('BorderLeft:DOTTED')
     C                   CALLP     #$XLSXCHAR('BorderRight:MEDIUM')
     C                   CALLP     #$XLSXCHAR('Color:MAROON')
     C                   CALLP     #$XLSXCHAR('')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST03'
     C                                     : 'Font:Courier New'
     C                                     : 'PointSize:12'
     C                                     : 'FillForegroundColor:DARK_GREEN'
     C                                     : 'FillPattern:THICK_HORZ_BANDS'
     C                                     : 'Color:MAROON')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 03':'S_TST03')
     C                   CALLP     #$XLSXCHAR('Font:Courier New')
     C                   CALLP     #$XLSXCHAR('PointSize:12')
     C                   CALLP     #$XLSXCHAR('FillForegroundColor:+
     C                                        DARK_GREEN')
     C                   CALLP     #$XLSXCHAR('FillPattern:THICK_HORZ_BANDS')
     C                   CALLP     #$XLSXCHAR('Color:MAROON')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST04'
     C                                   : 'Font:Courier New'
     C                                   : 'PointSize:12'
     C                                   : 'Italic:YES'
     C                                   : 'BoldWeight:BOLD'
     C                                   : 'FillPattern:BIG_SPOTS'
     C                                   : 'Color:YELLOW')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 04':'S_TST04')
     C                   CALLP     #$XLSXCHAR('Font:Courier New')
     C                   CALLP     #$XLSXCHAR('PointSize:12')
     C                   CALLP     #$XLSXCHAR('BoldWeight:BOLD')
     C                   CALLP     #$XLSXCHAR('FillPattern:BIG_SPOTS')
     C                   CALLP     #$XLSXCHAR('Color:YELLOW')
     C                   CALLP     #$XLSXCHAR('')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST05'
     C                                   : 'Strikeout:YES'
     C                                   : 'Color:DARK_GREEN')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 05':'S_TST05')
     C                   CALLP     #$XLSXCHAR('Strikeout:YES')
     C                   CALLP     #$XLSXCHAR('Color:DARK_GREEN')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST06'
     C                                   : 'FillForegroundColor:YELLOW'
     C                                   : 'Underline:YES')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 06':'S_TST06')
     C                   CALLP     #$XLSXCHAR('FillForegroundColor:YELLOW')
     C                   CALLP     #$XLSXCHAR('Underline:YES')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST07'
     C                                   : 'Border:Thin')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 07':'S_TST07')
     C                   CALLP     #$XLSXCHAR('Border:Thin')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST08'
     C                                   : 'Border:dash_dot:HAIR')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 08':'S_TST08')
     C                   CALLP     #$XLSXCHAR('Border:dash_dot:HAIR')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST09'
     C                                   : 'Border:Dashed:Double+
     C                                      :Medium_Dash_dot+
     C                                      :Medium_Dash_dot_Dot')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 09':'S_TST09')
     C                   CALLP     #$XLSXCHAR('Border:Dashed:Double+
     C                                         :Medium_Dash_dot+
     C                                         :Medium_Dash_dot_Dot')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST10'
     C                                   : 'BorderBottom:Thin'
     C                                   : 'BorderColor:Red')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 10':'S_TST10')
     C                   CALLP     #$XLSXCHAR('BorderBottom:Thin')
     C                   CALLP     #$XLSXCHAR('BorderColor:Red')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST11'
     C                                   : 'BorderTop:Medium'
     C                                   : 'BorderColor:Orange')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 11':'S_TST11')
     C                   CALLP     #$XLSXCHAR('BorderTop:Medium')
     C                   CALLP     #$XLSXCHAR('BorderColor:Orange')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST12'
     C                                   : 'BorderRight:Thin'
     C                                   : 'BorderColor:FFFF0101')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 12':'S_TST12')
     C                   CALLP     #$XLSXCHAR('BorderRight:Thin')
     C                   CALLP     #$XLSXCHAR('BorderColor:FFFF0101')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST13'
     C                                   : 'BorderLeft:Thin')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 13':'S_TST13')
     C                   CALLP     #$XLSXCHAR('BorderLeft:Thin')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST14'
     C                                   : 'BorderDiagonal:Thin'
     C                                   : 'DiagonalOption:Both')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 14':'S_TST14')
     C                   CALLP     #$XLSXCHAR('BorderDiagonal:Thin')
     C                   CALLP     #$XLSXCHAR('DiagonalOption:Both')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST15'
     C                                   : 'BorderDiagonal:Thin'
     C                                   : 'DiagonalOption:Down')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 15':'S_TST15')
     C                   CALLP     #$XLSXCHAR('BorderDiagonal:Thin')
     C                   CALLP     #$XLSXCHAR('DiagonalOption:Down')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST16'
     C                                   : 'BorderDiagonal:Thin'
     C                                   : 'DiagonalOption:Up')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 16':'S_TST16')
     C                   CALLP     #$XLSXCHAR('BorderDiagonal:Thin')
     C                   CALLP     #$XLSXCHAR('DiagonalOption:Up')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST17'
     C                                   : 'TypeOffset:Sub')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 17':'S_TST17')
     C                   CALLP     #$XLSXCHAR('TypeOffset:Sub')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST18'
     C                                   : 'TypeOffset:Super')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 18':'S_TST18')
     C                   CALLP     #$XLSXCHAR('TypeOffset:Super')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST19'
     C                                   : 'WrapText:Yes')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 19,A bunch of text +
     C                                         so it actually wraps.':'S_TST19')
     C                   CALLP     #$XLSXCHAR('WrapText:Yes, but this cell +
     C                                         does not have wrapped text so +
     C                                         you can see the difference.')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST2002'
     C                                   : 'WrapText:Yes')
     C                   CALLP     #$XLSXStyle('name:S_TST20'
     C                                       : 'Alignment:Left'
     C                                       : 'VerticalAlignment:Top')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 20':'S_TST20')
     C                   CALLP     #$XLSXCHAR('Alignment:Left')
     C                   CALLP     #$XLSXCHAR('VerticalAlignment:Top')
     C                   CALLP     #$XLSXCHAR('A bunch of text to cause this +
     C                                         to wrap to 3 lines so the +
     C                                         vertical alignment is visable.'
     C                                       : 'S_TST2002')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST21'
     C                                       : 'Alignment:Center'
     C                                       : 'VerticalAlignment:Center')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 21':'S_TST21')
     C                   CALLP     #$XLSXCHAR('Alignment:Center')
     C                   CALLP     #$XLSXCHAR('VerticalAlignment:Center')
     C                   CALLP     #$XLSXCHAR('A bunch of text to cause this +
     C                                         to wrap to 3 lines so the +
     C                                         vertical alignment is visable.'
     C                                       : 'S_TST2002')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST22'
     C                                       : 'Alignment:right'
     C                                       : 'VerticalAlignment:Bottom')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 22':'S_TST22')
     C                   CALLP     #$XLSXCHAR('Alignment:right')
     C                   CALLP     #$XLSXCHAR('VerticalAlignment:Bottom')
     C                   CALLP     #$XLSXCHAR('A bunch of text to cause this +
     C                                         to wrap to 3 lines so the +
     C                                         vertical alignment is visable.'
     C                                       : 'S_TST2002')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST23'
     C                                       : 'Alignment:Center:Center')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXCHAR('TEST STYLE 23':'S_TST23')
     C                   CALLP     #$XLSXCHAR('Alignment:Center:Center')
     C                   CALLP     #$XLSXCHAR(' ')
     C                   CALLP     #$XLSXCHAR('A bunch of text to cause this +
     C                                         to wrap to 3 lines so the +
     C                                         vertical alignment is visable.'
     C                                       : 'S_TST2002')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST24'
     C                                       : 'DataFormat:yyyy/mm/dd')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXYYMD(20200101:'S_TST24')
     C                   CALLP     #$XLSXCHAR('DataFormat:yyyy/mm/dd')
     C*
     C                   CALLP     #$XLSXStyle('name:S_TST25'
     C                                       : 'DataFormat:#,##0.00')
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNEXT
     C                   CALLP     #$XLSXNUMR(123.456:'S_TST25')
     C                   CALLP     #$XLSXCHAR('DataFormat:#,##0.00')
     C*
     C                   ENDSR
     C******************************************************************
     C* ADDS A NEW WORK SHEET(TAB) WITH COLOR EXAMPLES
     C     ADDCOLORS     BEGSR
     C*
     C* CREATE A NEW WORKSHEET(TAB)
     C                   CALLP     #$XLSXWkSh('SheetName:Colors Backgrounds'
     C                                      : 'FreezeRows:1'
     C                                      : 'ColumnWidth:1:30'
     C                                      : 'ColumnWidth:2:30'
     C                                      : 'ColumnWidth:3:30'
     C                                      : 'ColumnWidth:4:10'
     C                                      : 'ColumnWidth:5:37'
     C                                      : 'ColumnWidth:6:37'
     C                                      : 'ColumnWidth:7:37')
     C*
     C* ADD A HEADER ROW
     C                   CALLP     #$XLSXCHAR('Color')
     C                   CALLP     #$XLSXCHAR('FillForegroundColor')
     C                   CALLP     #$XLSXCHAR('FillBackgroundColor')
     C                   CALLP     #$XLSXNULL()
     C                   CALLP     #$XLSXCHAR('#$XLSX Pattern')
     C                   CALLP     #$XLSXCHAR('XML Pattern')
     C                   CALLP     #$XLSXCHAR('#$XLSX Code')
     C*
     C                   FOR       I=1 TO 46
     C*
     C* CREATE A TEST STYLE AND ADD IT
          #$XLSXStyle('name:S_CLR1'+%CHAR(I)
                    : 'Color:'+%TRIM(COLORS(I))
                    : 'Alignment:Center'
                    : 'VerticalAlignment:Center');
          #$XLSXStyle('name:S_CLR2'+%CHAR(I)
                    : 'FillForegroundColor:'+%TRIM(COLORS(I))
                    : 'FillPattern:SOLID'
                    : 'Alignment:Center'
                    : 'VerticalAlignment:Center');
          #$XLSXStyle('name:S_CLR3'+%CHAR(I)
                    : 'FillBackgroundColor:'+%TRIM(COLORS(I))
                    : 'FillForegroundColor:'+%TRIM(COLORS(47-I))
                    : 'FillPattern:MediumGray'
                    : 'Alignment:Center'
                    : 'VerticalAlignment:Center');
          #$XLSXNEXT();
          #$XLSXCHAR(%TRIM(COLORS(I)):'S_CLR1'+%CHAR(I));
          #$XLSXCHAR(%TRIM(COLORS(I)):'S_CLR2'+%CHAR(I));
          #$XLSXCHAR(%TRIM(COLORS(I)):'S_CLR3'+%CHAR(I));
     C*
     C* FOR THE FIRST 18 INDEX ADD THE FILL PATTERNS
          IF I<=18;
             #$XLSXStyle('name:S_FIL1'+%CHAR(I)
                       : 'FillBackgroundColor:'+%TRIM(COLORS(I+2))
                       : 'FillForegroundColor:'+%TRIM(COLORS(I))
                       : 'FillPattern:'+%TRIM(FILL(i).CODE1)
                       : 'WrapText:yes');
             #$XLSXStyle('name:S_FIL2'+%CHAR(I)
                       : 'FillBackgroundColor:'+%TRIM(COLORS(I+3))
                       : 'FillForegroundColor:'+%TRIM(COLORS(I))
                       : 'FillPattern:'+%TRIM(FILL(i).CODE2)
                       : 'WrapText:yes');
             #$XLSXStyle('name:S_FIL3'+%CHAR(I)
                       : 'FillBackgroundColor:'+%TRIM(COLORS(I+4))
                       : 'FillForegroundColor:'+%TRIM(COLORS(47-I))
                       : 'FillPattern:'+%TRIM(FILL(i).CODE3)
                       : 'WrapText:yes');
             #$XLSXNull();
             #$XLSXCHAR('FillBackgroundColor:'+%trim(colors(i+2)) + eor +
                        'FillForegroundColor:'+%trim(colors(i)) + eor +
                        'FillPattern:'+%trim(fill(i).code1)
                        :'S_FIL1'+%CHAR(I));
             #$XLSXCHAR('FillBackgroundColor:'+%trim(colors(i+3)) + eor +
                        'FillForegroundColor:'+%trim(colors(i)) + eor +
                        'FillPattern:'+%trim(fill(i).code2)
                        :'S_FIL2'+%CHAR(I));
             #$XLSXCHAR('FillBackgroundColor:'+%trim(colors(i+4)) + eor +
                        'FillForegroundColor:'+%trim(colors(i)) + eor +
                        'FillPattern:'+%trim(fill(i).code3)
                        :'S_FIL3'+%CHAR(I));
          ENDIF;
     C*
     C                   ENDFOR
     C*
     C                   ENDSR
     C******************************************************************
     C     ADDHDR        BEGSR
     C*
     C* CREATE A NEW SHEET(TAB)
            #$XLSXWkSh('SheetName:Header-Footer'
                     : 'Header:First Left:Arial:24:First:Left'
                     : 'Header:First Center:Arial:24:First:Center'
                     : 'Header:First Right:Arial:24:First:Right'
                     : 'Header:Odd Left:Arial:24:Odd:Left'
                     : 'Header:Odd Center:Arial:24:Odd:Center'
                     : 'Header:Odd Right:Arial:24:Odd:Right'
                     : 'Header:Even Left:Arial:24:Even:Left'
                     : 'Header:Even Center:Arial:24:Even:Center'
                     : 'Header:Even Right:Arial:24:Even:Right'
                     : 'Footer:Ftr First Left:Arial:24:First:Left'
                     : 'Footer:Ftr First Center:Arial:24:First:Center'
                     : 'Footer:Ftr First Right:Arial:24:First:Right'
                     : 'Footer:Ftr Odd Left:Arial:24:Odd:Left'
                     : 'Footer:Ftr Odd Center:Arial:24:Odd:Center'
                     : 'Footer:Ftr Odd Right:Arial:24:Odd:Right'
                     : 'Footer:Ftr Even Left:Arial:24:Even:Left'
                     : 'Footer:Ftr Even Center:Arial:24:Even:Center'
                     : 'Footer:Ftr Even Right:Arial:24:Even:Right'
                     : 'DifferentOddAndEvenPages:On'
                     : 'DifferentFirstPage:Yes');
     C*
     C* ADD SOME GARABAGE
     C                   CALLP     #$XLSXCHAR('Test Header and footer options')
     C*
           #$XLSXNEXT();
           #$XLSXNEXT();
           #$XLSXCHAR('This sheet has different first page and odd and +
                        even page headers.');
     C*
           #$XLSXNEXT();
           #$XLSXNEXT();
           #$XLSXCHAR('Use print preview to see how these look.');
     C*
           #$XLSXNEXT();
           #$XLSXCHAR('The parameters used for this page are:');
           #$XLSXNEXT();
           #$XLSXCHAR( 'SheetName:Header-Footer');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:First Left:Arial:24:First:Left');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:First Center:Arial:24:First:Center');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:First Right:Arial:24:First:Right');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:Odd Left:Arial:24:Odd:Left');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:Odd Center:Arial:24:Odd:Center');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:Odd Right:Arial:24:Odd:Right');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:Even Left:Arial:24:Even:Left');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:Even Center:Arial:24:Even:Center');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Header:Even Right:Arial:24:Even:Right');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr First Left:Arial:24:First:Left');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr First Center:Arial:24:First:Center');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr First Right:Arial:24:First:Right');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr Odd Left:Arial:24:Odd:Left');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr Odd Center:Arial:24:Odd:Center');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr Odd Right:Arial:24:Odd:Right');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr Even Left:Arial:24:Even:Left');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr Even Center:Arial:24:Even:Center');
           #$XLSXNEXT();
           #$XLSXCHAR( 'Footer:Ftr Even Right:Arial:24:Even:Right');
           #$XLSXNEXT();
           #$XLSXCHAR( 'DifferentOddAndEvenPages:On');
           #$XLSXNEXT();
           #$XLSXCHAR( 'DifferentFirstPage:Yes');
     C*
           #$XLSXNEXT();
           #$XLSXCHAR('Below is just a bunch of garbage so it goes to more +
                       pages.');
     C*
     C*
     C* ADD A BUNCH OF LINES SO IT GOES TO AT LEAST 5 PAGES
     C                   DO        100
     C                   CALLP     #$XLSXNEXT()
     C                   CALLP     #$XLSXCHAR('Garbage')
     C                   CALLP     #$XLSXNEXT()
     C                   CALLP     #$XLSXCHAR('Garbage')
     C                   CALLP     #$XLSXNEXT()
     C                   CALLP     #$XLSXCHAR('Garbage')
     C                   CALLP     #$XLSXNEXT()
     C                   CALLP     #$XLSXCHAR('Garbage')
     C                   CALLP     #$XLSXNEXT()
     C                   CALLP     #$XLSXCHAR('Trash')
     C                   ENDDO
     C*
     C                   ENDSR
     C******************************************************************
     C     ADDCELL       BEGSR
     C*
     C* CREATE A NEW SHEET(TAB)
            #$XLSXWkSh('SheetName:#$XLSXCell'
                     : 'ColumnWidth:1:30'
                     : 'ColumnWidth:2:30'
                     : 'ColumnWidth:3:15'
                     : 'ColumnWidth:4:40'
                     : 'ColumnWidth:5:15'
                     : 'ColumnWidth:6:40'
                     : 'ColumnWidth:7:15');
     C*
     C* ADD SHEET INFORMATION
           #$XLSXCHAR('Tests all parameters for the $XSLXCell +
                       function':'S_TITLE':4);

           #$XLSXNEXT();
           #$XLSXCHAR('This function returns a cells or a range +
                       relative to the current cell.':*omit:4);

           #$XLSXNEXT();
           #$XLSXCHAR('Each example shows the function used, a +
                       description of what should +
                       happen and the results.':*omit:4);

     C* ADD HEADERS
           #$XLSXNEXT();
           #$XLSXCHAR('Description':'S_HDR2');
           #$XLSXCHAR('Function-Shortcut':'S_HDR2');
           #$XLSXCHAR('Output':'S_HDR2');
           #$XLSXCHAR('Function-Full':'S_HDR2');
           #$XLSXCHAR('Output':'S_HDR2');
           #$XLSXCHAR('#$XLSXC':'S_HDR2');
           #$XLSXCHAR('Output':'S_HDR2');


           #$XLSXNEXT();
           #$XLSXCHAR('Return the current cell');
           #$XLSXCHAR('#$XLSXCell()');
           #$XLSXCHAR(#$XLSXCell());
           #$XLSXNull();
           #$XLSXNull();
           #$XLSXCHAR('#$XLSXC()');
           #$XLSXCHAR(#$XLSXC());
           #$XLSXNEXT();
           #$XLSXCHAR('Return the current cell');
           #$XLSXCHAR('#$XLSXCell(''R:0:0:0:0'')');
           #$XLSXCHAR(#$XLSXCell('R:0:0:0:0'));
           #$XLSXCHAR('#$XLSXCell(''Range:0:0:0:0'')');
           #$XLSXCHAR(#$XLSXCell('Range:0:0:0:0'));
           #$XLSXCHAR('#$XLSXC(''R'':0:0:0:0)');
           #$XLSXCHAR(#$XLSXC('R':0:0:0:0));
           #$XLSXNEXT();
           #$XLSXCHAR('Return the previous cell');
           #$XLSXCHAR('#$XLSXCell(''r:0:0:1:0'')');
           #$XLSXCHAR(#$XLSXCell('r:0:0:1:0'));
           #$XLSXCHAR('#$XLSXCell(''range:0:0:1:0'')');
           #$XLSXCHAR(#$XLSXCell('range:0:0:1:0'));
           #$XLSXCHAR('#$XLSXC(''r'':0:0:1:0)');
           #$XLSXCHAR(#$XLSXC('r':0:0:1:0));
           #$XLSXNEXT();
           #$XLSXCHAR('Return the previous cell');
           #$XLSXCHAR('#$XLSXCell(''VO:1'')');
           #$XLSXCHAR(#$XLSXCell('VO:1'));
           #$XLSXCHAR('#$XLSXCell(''VerticalOffset:1'')');
           #$XLSXCHAR(#$XLSXCell('VerticalOffset:1'));
           #$XLSXCHAR('#$XLSXC(''VO'':1)');
           #$XLSXCHAR(#$XLSXC('VO':1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return the previous cell');
           #$XLSXCHAR('#$XLSXCell(''O:1:0'')');
           #$XLSXCHAR(#$XLSXCell('O:1:0'));
           #$XLSXCHAR('#$XLSXCell(''Offset:1:0'')');
           #$XLSXCHAR(#$XLSXCell('Offset:1:0'));
           #$XLSXCHAR('#$XLSXC(''O'':1:0)');
           #$XLSXCHAR(#$XLSXC('O':1:0));
           #$XLSXNEXT();
           #$XLSXCHAR('Return the next cell');
           #$XLSXCHAR('#$XLSXCell(''R:0:0:-1:0'')');
           #$XLSXCHAR(#$XLSXCell('R:0:0:-1:0'));
           #$XLSXCHAR('#$XLSXCell(''RANGE:0:0:-1:0'')');
           #$XLSXCHAR(#$XLSXCell('RANGE:0:0:-1:0'));
           #$XLSXCHAR('#$XLSXC(''O'':1:0)');
           #$XLSXCHAR(#$XLSXC('O':1:0));
           #$XLSXNEXT();
           #$XLSXCHAR('Return the next cell');
           #$XLSXCHAR('#$XLSXCell(''VO:-1'')');
           #$XLSXCHAR(#$XLSXCell('VO:-1'));
           #$XLSXCHAR('#$XLSXCell(''VERTICALOFFSET:-1'')');
           #$XLSXCHAR(#$XLSXCell('VERTICALOFFSET:-1'));
           #$XLSXCHAR('#$XLSXC(''VO'':-1)');
           #$XLSXCHAR(#$XLSXC('VO':-1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return the next cell');
           #$XLSXCHAR('#$XLSXCell(''O:-1:0'')');
           #$XLSXCHAR(#$XLSXCell('O:-1:0'));
           #$XLSXCHAR('#$XLSXCell(''OFFSET:-1:0'')');
           #$XLSXCHAR(#$XLSXCell('OFFSET:-1:0'));
           #$XLSXCHAR('#$XLSXC(''O'':-1:0)');
           #$XLSXCHAR(#$XLSXC('O':-1:0));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell to the left');
           #$XLSXCHAR('#$XLSXCell(''R:0:0:0:1'')');
           #$XLSXCHAR(#$XLSXCell('R:0:0:0:1'));
           #$XLSXCHAR('#$XLSXCell(''Range:0:0:0:1'')');
           #$XLSXCHAR(#$XLSXCell('Range:0:0:0:1'));
           #$XLSXCHAR('#$XLSXC(''R'':0:0:0:1)');
           #$XLSXCHAR(#$XLSXC('R':0:0:0:1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell to the left');
           #$XLSXCHAR('#$XLSXCell(''HO:1'')');
           #$XLSXCHAR(#$XLSXCell('HO:1'));
           #$XLSXCHAR('#$XLSXCell(''HorizontalOffset:1'')');
           #$XLSXCHAR(#$XLSXCell('HorizontalOffset:1'));
           #$XLSXCHAR('#$XLSXC(''HO'':1)');
           #$XLSXCHAR(#$XLSXC('HO':1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell to the left');
           #$XLSXCHAR('#$XLSXCell(''O:0:1'')');
           #$XLSXCHAR(#$XLSXCell('O:0:1'));
           #$XLSXCHAR('#$XLSXCell(''Offset:0:1'')');
           #$XLSXCHAR(#$XLSXCell('Offset:0:1'));
           #$XLSXCHAR('#$XLSXC(''O'':0:1)');
           #$XLSXCHAR(#$XLSXC('O':0:1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell to the right');
           #$XLSXCHAR('#$XLSXCell(''R:0:0:0:-1'')');
           #$XLSXCHAR(#$XLSXCell('R:0:0:0:-1'));
           #$XLSXCHAR('#$XLSXCell(''range:0:0:0:-1'')');
           #$XLSXCHAR(#$XLSXCell('range:0:0:0:-1'));
           #$XLSXCHAR('#$XLSXC(''R'':0:0:0:-1)');
           #$XLSXCHAR(#$XLSXC('R':0:0:0:-1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell to the right');
           #$XLSXCHAR('#$XLSXCell(''HO:-1'')');
           #$XLSXCHAR(#$XLSXCell('HO:-1'));
           #$XLSXCHAR('#$XLSXCell(''HORIZONTALOFFSET:-1'')');
           #$XLSXCHAR(#$XLSXCell('HORIZONTALOFFSET:-1'));
           #$XLSXCHAR('#$XLSXC(''HO'':-1)');
           #$XLSXCHAR(#$XLSXC('HO':-1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell to the right');
           #$XLSXCHAR('#$XLSXCell(''O:0:-1'')');
           #$XLSXCHAR(#$XLSXCell('O:0:-1'));
           #$XLSXCHAR('#$XLSXCell(''offset:0:-1'')');
           #$XLSXCHAR(#$XLSXCell('offset:0:-1'));
           #$XLSXCHAR('#$XLSXC(''O'':0:-1)');
           #$XLSXCHAR(#$XLSXC('O':0:-1));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell up 2 and left 2');
           #$XLSXCHAR('#$XLSXCell(''R:0:0:2:2'')');
           #$XLSXCHAR(#$XLSXCell('R:0:0:2:2'));
           #$XLSXCHAR('#$XLSXCell(''range:0:0:2:2'')');
           #$XLSXCHAR(#$XLSXCell('range:0:0:2:2'));
           #$XLSXCHAR('#$XLSXC(''R'':0:0:2:2)');
           #$XLSXCHAR(#$XLSXC('R':0:0:2:2));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell up 2 and left 2');
           #$XLSXCHAR('#$XLSXCell(''o:2:2'')');
           #$XLSXCHAR(#$XLSXCell('o:2:2'));
           #$XLSXCHAR('#$XLSXCell(''offset:2:2'')');
           #$XLSXCHAR(#$XLSXCell('offset:2:2'));
           #$XLSXCHAR('#$XLSXC(''o'':2:2)');
           #$XLSXCHAR(#$XLSXC('o':2:2));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell down 2 and right 2');
           #$XLSXCHAR('#$XLSXCell(''R:0:0:-2:-2'')');
           #$XLSXCHAR(#$XLSXCell('R:0:0:-2:-2'));
           #$XLSXCHAR('#$XLSXCell(''range:0:0:-2:-2'')');
           #$XLSXCHAR(#$XLSXCell('range:0:0:-2:-2'));
           #$XLSXCHAR('#$XLSXC(''R'':0:0:-2:-2)');
           #$XLSXCHAR(#$XLSXC('R':0:0:-2:-2));
           #$XLSXNEXT();
           #$XLSXCHAR('Return cell down 2 and right 2');
           #$XLSXCHAR('#$XLSXCell(''o:-2:-2'')');
           #$XLSXCHAR(#$XLSXCell('o:-2:-2'));
           #$XLSXCHAR('#$XLSXCell(''offset:-2:-2'')');
           #$XLSXCHAR(#$XLSXCell('offset:-2:-2'));
           #$XLSXCHAR('#$XLSXC(''o'':-2:-2)');
           #$XLSXCHAR(#$XLSXC('o':-2:-2));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of the last 2 cells');
           #$XLSXCHAR('#$XLSXCell(''R:2:0:1:0'')');
           #$XLSXCHAR(#$XLSXCell('R:2:0:1:0'));
           #$XLSXCHAR('#$XLSXCell(''Range:2:0:1:0'')');
           #$XLSXCHAR(#$XLSXCell('Range:2:0:1:0'));
           #$XLSXCHAR('#$XLSXC(''R'':2:0:1:0)');
           #$XLSXCHAR(#$XLSXC('R':2:0:1:0));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of the last 2 cells');
           #$XLSXCHAR('#$XLSXCell(''VR:2'')');
           #$XLSXCHAR(#$XLSXCell('VR:2'));
           #$XLSXCHAR('#$XLSXCell(''VerticalRange:2'')');
           #$XLSXCHAR(#$XLSXCell('VerticalRange:2'));
           #$XLSXCHAR('#$XLSXC(''VR'':2)');
           #$XLSXCHAR(#$XLSXC('VR':2));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of the 2 cells 2 cells up');
           #$XLSXCHAR('#$XLSXCell(''R:2:0:2:0'')');
           #$XLSXCHAR(#$XLSXCell('R:2:0:2:0'));
           #$XLSXCHAR('#$XLSXCell(''Range:2:0:2:0'')');
           #$XLSXCHAR(#$XLSXCell('Range:2:0:2:0'));
           #$XLSXCHAR('#$XLSXC(''R'':2:0:2:0)');
           #$XLSXCHAR(#$XLSXC('R':2:0:2:0));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of the 2 cells 2 cells up');
           #$XLSXCHAR('#$XLSXCell(''VR:2:1'')');
           #$XLSXCHAR(#$XLSXCell('VR:2:1'));
           #$XLSXCHAR('#$XLSXCell(''VerticalRange:2:1'')');
           #$XLSXCHAR(#$XLSXCell('VerticalRange:2:1'));
           #$XLSXCHAR('#$XLSXC(''VR'':2:1)');
           #$XLSXCHAR(#$XLSXC('VR':2:1));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of 2 cells left');
           #$XLSXCHAR('#$XLSXCell(''R:0:2:0:1'')');
           #$XLSXCHAR(#$XLSXCell('R:0:2:0:1'));
           #$XLSXCHAR('#$XLSXCell(''Range:0:2:0:1'')');
           #$XLSXCHAR(#$XLSXCell('Range:0:2:0:1'));
           #$XLSXCHAR('#$XLSXC(''R'':0:2:0:1)');
           #$XLSXCHAR(#$XLSXC('R':0:2:0:1));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of 2 cells left');
           #$XLSXCHAR('#$XLSXCell(''HR:2'')');
           #$XLSXCHAR(#$XLSXCell('HR:2'));
           #$XLSXCHAR('#$XLSXCell(''HorizontalRange:2'')');
           #$XLSXCHAR(#$XLSXCell('HorizontalRange:2'));
           #$XLSXCHAR('#$XLSXC(''HR'':2)');
           #$XLSXCHAR(#$XLSXC('HR':2));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of 2 cells right offset by 1');
           #$XLSXCHAR('#$XLSXCell(''R:0:-2:0:1'')');
           #$XLSXCHAR(#$XLSXCell('R:0:-2:0:1'));
           #$XLSXCHAR('#$XLSXCell(''Range:0:-2:0:1'')');
           #$XLSXCHAR(#$XLSXCell('Range:0:-2:0:1'));
           #$XLSXCHAR('#$XLSXC(''R'':0:-2:0:1)');
           #$XLSXCHAR(#$XLSXC('R':0:-2:0:1));
           #$XLSXNEXT();
           #$XLSXCHAR('A Range of 2 cells right offset by 1');
           #$XLSXCHAR('#$XLSXCell(''HR:-2:1'')');
           #$XLSXCHAR(#$XLSXCell('HR:-2:1'));
           #$XLSXCHAR('#$XLSXCell(''HorizontalRange:-2:1'')');
           #$XLSXCHAR(#$XLSXCell('HorizontalRange:-2:1'));
           #$XLSXCHAR('#$XLSXC(''HR'':-2:1)');
           #$XLSXCHAR(#$XLSXC('HR':-2:1));
           #$XLSXNEXT();
           #$XLSXCHAR('A 3x2 range, up and left 1');
           #$XLSXCHAR('#$XLSXCell(''R:3:2:1:1'')');
           #$XLSXCHAR(#$XLSXCell('R:3:2:1:1'));
           #$XLSXCHAR('#$XLSXCell(''Range:3:2:1:1'')');
           #$XLSXCHAR(#$XLSXCell('Range:3:2:1:1'));
           #$XLSXCHAR('#$XLSXC(''R'':3:2:1:1)');
           #$XLSXCHAR(#$XLSXC('R':3:2:1:1));
           #$XLSXNEXT();
           #$XLSXCHAR('A 3x2 range, down and right 1');
           #$XLSXCHAR('#$XLSXCell(''R:-3:-2:-1:-1'')');
           #$XLSXCHAR(#$XLSXCell('R:-3:-2:-1:-1'));
           #$XLSXCHAR('#$XLSXCell(''Range:-3:-2:-1:-1'')');
           #$XLSXCHAR(#$XLSXCell('Range:-3:-2:-1:-1'));
           #$XLSXCHAR('#$XLSXC(''R'':-3:-2:-1:-1)');
           #$XLSXCHAR(#$XLSXC('R':-3:-2:-1:-1));
           #$XLSXNEXT();
           #$XLSXCHAR('TODO Negative ranges don''t work');
           #$XLSXNEXT();
           #$XLSXCHAR('need to swap cell order in the range.');
           #$XLSXNEXT();
           #$XLSXCHAR('and the range size is off by 2.');
     C*
     C*
     C                   ENDSR
     C******************************************************************
     C     ADDDATA       BEGSR

       // CREATE A NEW SHEET(TAB)
          #$XLSXWkSh('SheetName:#$XLSXData'
                   : 'ColumnWidth:1:30'
                   : 'ColumnWidth:2:40'
                   : 'ColumnWidth:3:30'
                   : 'ColumnWidth:4:60' );

       // ADD SHEET INFORMATION
          #$XLSXCHAR('Tests adding data.':'S_TITLE':3);

          #$XLSXNEXT();
          #$XLSXCHAR('There was an issue with invalid dates +
                      that caused the program to error out.':*omit:3);
          #$XLSXNEXT();
          #$XLSXCHAR('The intent of this sheet is to test adding invalid +
                      data to see how the program handles it.':*omit:3);

          #$XLSXNEXT();
          #$XLSXNEXT();
          #$XLSXCHAR('Issue being tested':'S_HDR');
          #$XLSXCHAR('Function and parms':'S_HDR');
          #$XLSXCHAR('Result':'S_HDR');
          #$XLSXCHAR('Comments':'S_HDR');

       // test for an invalid date
          #$XLSXNEXT();
          #$XLSXCHAR('Valid date':'S_dtl');
          #$XLSXCHAR('#$XLSXYYMD(20210101:''S_DATE'')':'S_DTL');
          #$XLSXYYMD(20210101:'S_DATE');
          #$XLSXCHAR('Should add the date':'S_DTL');
          #$XLSXNEXT();
          #$XLSXCHAR('Valid date':'S_DTL');
          #$XLSXCHAR('#$XLSXmdy(010121:''S_DATE'')':'S_DTL');
          #$XLSXMDY(010121:'S_DATE');
          #$XLSXCHAR('Should add the date':'S_DTL');
          #$XLSXNEXT();
          #$XLSXCHAR('Valid date':'S_DTL');
          #$XLSXCHAR('#$XLSXMDYY(01012021:''S_DATE'')':'S_DTL');
          #$XLSXMDYY(01012021:'S_DATE');
          #$XLSXCHAR('Should add the date':'S_DTL');
          #$XLSXNEXT();
          #$XLSXCHAR('Invalid date':'S_DTL');
          #$XLSXCHAR('#$XLSXYYMD(20210100:''S_DATE'')':'S_DTL');
          #$XLSXYYMD(20210100:'S_DATE');
          #$XLSXCHAR('This should add an empty cell and log an +
                      informational error':'S_DTL');
          #$XLSXNEXT();
          #$XLSXCHAR('Invalid date':'S_DTL');
          #$XLSXCHAR('#$XLSXmdy(010021:''S_DATE'')':'S_DTL');
          #$XLSXMDY(010021:'S_DATE');
          #$XLSXCHAR('This should add an empty cell and log an +
                      informational error':'S_DTL');
          #$XLSXNEXT();
          #$XLSXCHAR('Invalid date':'S_DTL');
          #$XLSXCHAR('#$XLSXMDYY(01002021:''S_DATE'')':'S_DTL');
          #$XLSXMDYY(01002021:'S_DATE');
          #$XLSXCHAR('This should add an empty cell and log an +
                      informational error':'S_DTL');

     C                   ENDSR
     C******************************************************************
** COLOR ARRAY
AQUA                                   1
BLACK                                  2
BLUE                                   3
BLUE_GREY                              4
BRIGHT_GREEN                           5
BROWN                                  6
CORAL                                  7
CORNFLOWER_BLUE                        8
DARK_BLUE                              9
DARK_RED                              10
DARK_TEAL                             11
DARK_YELLOW                           12
DARK_GOLD                             13
DARK_GREEN                            14
GREY_25                               15
GREY_40                               16
GREY_50                               17
GREY_80                               18
INDIGO                                19
LAVENDER                              20
LEMON_CHIFFON                         21
LIGHT_BLUE                            22
LIGHT_CORNFLOWER_BLUE                 23
LIGHT_GREEN                           24
LIGHT_ORANGE                          25
LIGHT_TURQUOISE                       26
LIGHT_YELLOW                          27
LIME                                  28
MAROON                                29
OLIVE_GREEN                           30
ORANGE                                31
ORCHID                                32
PALE_BLUE                             33
PINK                                  34
PLUM                                  35
RED                                   36
ROSE                                  37
ROYAL_BLUE                            38
SEA_GREEN                             39
SKY_BLUE                              40
TAN                                   41
TEAL                                  42
TURQUOISE                             43
VIOLET                                44
WHITE                                 45
YELLOW                                46
NORMAL                                47
AUTOMATIC                             48
** FILL ARRAY   1-30=EXCEL VALUE, 31-60 #$XLSX VALUE,  61-CODE
SOLID                         SOLID                         1      1
75%Gray                       LIGHTGRAY                     2      2
50%Gray                       MEDIUMGRAY                    3      3
25%Gray                       DARKGRAY                      4      4
12.5%Gray                     GRAY125                       5      5
6.25%Gray                     GRAY0625                      6      6
HorizontalStripe              DARKHORIZONTAL                7      7
VerticalStripe                DARKVERTICAL                  8      8
ReverseDiagonalStripe         DARKDOWN                      9      9
DiagonalStripe                DARKUP                        A     10
DiagonalCrosshatch            DARKGRID                      B     11
ThickDiagonalCrosshatch       DARKTRELLIS                   C     12
ThinHorizontalStripe          LIGHTHORIZONTAL               D     13
ThinVerticalStripe            LIGHTVERTICAL                 E     14
ThinReverseDiagonalStripe     LIGHTDOWN                     F     15
ThinDiagonalStripe            LIGHTUP                       G     16
ThinCrossHatch                LIGHTGRID                     H     17
ThinDiagonalCrossHatch        LIGHTTRELLIS                  I     18
