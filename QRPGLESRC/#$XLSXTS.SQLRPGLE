**Free
Ctl-Opt Option(*SrcStmt:*NoDebugIO:*NoShowCpy) DftActGrp(*No) BndDir('#$XLSX1.0/#$XLSX') main(Main);

// Create pretty Excel File test

Dcl-Ds dta;
  item Char(10);
  desc Varchar(30);
  setup packed(8);
  qtyOh packed(7:2);
  price packed(9:2);
End-Ds;

Dcl-S COLORS Char(30) dim(48) ctdata perrcd(1);

Dcl-S FILLS Char(61) dim(18) ctdata perrcd(1);
Dcl-S FILLSPTR pointer Inz(%Addr(fills));
Dcl-Ds FILL dim(18) Qualified based(fillsptr);
  CODE1 Char(30);
  CODE2 Char(30);
  CODE3 Char(1);
End-Ds;

Dcl-S cmd Char(1000);
Dcl-S sqlStm Char(1000);
Dcl-S i zoned(5);
Dcl-S j zoned(5);
Dcl-S x zoned(5);
Dcl-S EOR Char(2) Inz( x'0D25' );
Dcl-S #date packed(8);
Dcl-S #time packed(6);

Dcl-Ds defaultPath dtaara('#$XLSX1.0/#$XLSXTEMP');
  path Char(100) pos(1);
End-Ds;

/Include #$XLSX1.0/QRPGLESRC,#$XLSX_H


Dcl-Proc Main;

  // Get default path from data area
  In defaultPath;

  #date = %Dec(%Char(%Date():*iso0):8:0);
  #time = %Dec(%Char(%time():*hms0):6:0);

  // create xls file in the ifs - must be done before creating styles
  #$XLSXOpen('OutputName:'+%Trim(path)+
      '/#$XLSXTS.xlsx'
      : 'Debug:*Off'
      : 'Creator:Tim Tognazzini'
      : 'Company:myCompany, Inc.'
      : 'Title:myTitle'
      : 'Subject:mySubject'
      : 'Manager:myManager'
      : 'Tags:tag1;tag2;'
      : 'Category:myCategory'
      : 'Status:myStatus'
      : 'Comments: wholatta + comments'+eor+ 'line 2 of comments'+eor+ 'line 3 of comments'
      : 'HyperLinkBase:myHyperLinkBase.com'
      : 'CustomProperty:testText:Text:myText'
      : 'CustomProperty:testdate:Date:20200225'
      : 'CustomProperty:testnum1:number:12345'
      : 'CustomProperty:testnum2:number:123.45'
      : 'CustomProperty:testnum3:number:-123.45'
      : 'CustomProperty:testyes:yesorno:yes'
      : 'CustomProperty:teston:yesorno:yes'
      : 'CustomProperty:test1:yesorno:yes'
      : 'CustomProperty:testtrue:yesorno:yes'
      : 'CustomProperty:testno:boolean:no'
      : 'CustomProperty:testoff:boolean:*off'
      : 'CustomProperty:test0:yesorno:0'
      : 'CustomProperty:testfalse:yesorno:false'
      : 'Buffering:1');

  // add a report looking sheet for tab 1
  AddReport();

  // adds a seperate page with formatting examples
  AddFormats();

  // adds a seperate page with formatting examples
  AddColors();

  // add a tab for header/footer testing
  AddHeadersFooters();

  // ADD A TAB FOR testing #$XSLXCELL
  AddCellReferences();

  // ADD A TAB FOR testing adding data
  AddInvalidData();

  // Close the open XLS File
  #$XLSXClose();

End-Proc;


Dcl-Proc AddReport;

  // setup styles
  #$XLSXStyle('name:S_DTL' : 'Font:Arial' : 'PointSize:10'
            : 'BorderTop:THIN' : 'BorderBottom:THIN' : 'BorderLeft:THIN' : 'BorderRight:THIN');
  #$XLSXStyle('name:S_DATE' : 'Font:Arial' : 'PointSize:10' : 'Alignment:CENTER'
            : 'DataFormat:yyyy/mm/dd'
            : 'BorderTop:THIN' : 'BorderBottom:THIN' : 'BorderLeft:THIN' : 'BorderRight:THIN' );
  #$XLSXStyle('name:S_DOLLAR' : 'Font:Arial' : 'PointSize:10'
            : 'BorderTop:THIN' : 'BorderBottom:THIN' : 'BorderLeft:THIN' : 'BorderRight:THIN'
            : 'DataFormat:#,##0.00');
  #$XLSXStyle('name:S_TITLE' : 'Font:Arial' : 'PointSize:18' : 'WrapText:Yes'
            : 'Alignment:CENTER' : 'BoldWeight:BOLD');
  #$XLSXStyle('name:S_HDR' : 'Font:Arial' : 'PointSize:10' : 'WrapText:YES'
            : 'Alignment:CENTER' : 'BoldWeight:BOLD'
            : 'BorderTop:THIN' : 'BorderBottom:THIN' : 'BorderLeft:THIN' : 'BorderRight:THIN');
  #$XLSXStyle('name:S_HDR2' : 'Font:Arial' : 'PointSize:10' : 'WrapText:YES'
            : 'Alignment:CENTER' : 'BoldWeight:BOLD' : 'BorderBottom:THIN');

  // create a new sheet(tab)
  #$XLSXWkSh('SheetName:#$XLSXTS'
           : 'FreezeRows:3'
           : 'ColumnWidth:1:12'
           : 'ColumnWidth:2:30'
           : 'ColumnWidth:3:12'
           : 'ColumnWidth:4:12'
           : 'ColumnWidth:5:12'
           : 'ColumnWidth:6:12'
           : 'ColumnWidth:7:12'
           : 'ColumnWidth:8:12');

  // adding heading options, this could have been done in the previous statement
  // but this shows how you can add on until data has been added
  #$XLSXWkSh('Header:Pgm: #$XLSXTS:Arial Narrow:24:Italic:Left:subscript'
           : 'Header:Inventory Report:Arial:24:Bold'
           : 'Header:*DATE *TIME:Calibri:10:Right:Bold:Italic'
           : 'Footer:*PATH*FILE:Arial:8:Left:Color:Red:DoubleUnderline:superscript'
           : 'Footer:*PAGE of *PAGES:Arial:12:Color:Green:Underline:StrikeThrough'
           : 'Footer:Sheet *NAME:Arial:8:right');

  // add header record 1 and 2
  #$XLSXChar('TEST #$XLSX - Pretty Excel Files':'S_TITLE':3);
  #$XLSXChar('#$XLSXTS');
  #$XLSXChar(%EditW(#DATE:'    /  / 0'));
  #$XLSXChar(%EditW(#TIME:'  :  : 0'));

  // skip 2 lines and add a header row
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Item':'S_HDR');
  #$XLSXChar('Description':'S_HDR');
  #$XLSXChar('Setup' + eor + 'Date':'S_HDR');
  #$XLSXChar('Quantity'+eor+'on Hand':'S_HDR');
  #$XLSXChar('Price':'S_HDR');

  // loop through test items
  sqlStm='SELECT * FROM #$XLSXINV';
  Exec SQL Prepare SQL1 From :sqlStm;
  Exec SQL Declare SQLCRS1 Cursor For SQL1;
  Exec SQL Open SQLCRS1;
  Exec SQL Fetch Next From SQLCRS1 Into :dta;
  DoW SQLState<'02';
    AddDetail();
    Exec SQL Fetch Next From SQLCRS1 Into :dta;
  EndDo;
  Exec SQL Close SQLCRS1;

End-Proc;


Dcl-Proc AddDetail;

  #$XLSXNext();
  #$XLSXChar(ITEM:'S_DTL');
  #$XLSXChar(DESC:'S_DTL');
  #$XLSXYYMD(SETUP:'S_DATE');
  #$XLSXNumr(QTYOH:'S_DOLLAR');
  #$XLSXNumr(PRICE:'S_DOLLAR');

End-Proc;


// adds a new work sheet(tab) with style examples
Dcl-Proc AddFormats;

  // create a new worksheet(tab) with zoom= 200%
  #$XLSXWkSh('SheetName:Test Styles'
      : 'ColumnWidth: 1: 30'
      : 'ColumnWidth: 2: 30'
      : 'ColumnWidth: 3: 30'
      : 'ColumnWidth: 4: 30'
      : 'ColumnWidth: 5: 30'
      : 'ColumnWidth: 6: 30'
      : 'ColumnWidth: 7: 30'
      : 'ColumnWidth: 8: 30'
      : 'ColumnWidth: 9: 30'
      : 'ColumnWidth:10: 30'
      : 'ColumnWidth:11: 30'
      : 'Filter:A1:B1');

  // add a header row
  #$XLSXChar('Output');
  #$XLSXChar('Options');
  #$XLSXNext();

  // create a test style and add it
  #$XLSXStyle('name:S_TST01' : 'Font:Arial' : 'PointSize:10' : 'BorderBottom:DOUBLE':'Color:BLUE');
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 01':'S_TST01');
  #$XLSXChar('Font:Arial');
  #$XLSXChar('PointSize:10');
  #$XLSXChar('BorderBottom:DOUBLE');
  #$XLSXChar('Color:BLUE');

  #$XLSXStyle('name:S_TST02' : 'Font:Times New Roman' : 'PointSize:18'
            : 'BorderTop:DASH_DOT_DOT' : 'BorderBottom:MEDIUM_DASHED' : 'BorderLeft:DOTTED'
            : 'BorderRight:MEDIUM' : 'Color:MAROON');
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 02':'S_TST02');
  #$XLSXChar('Font:Times New Roman');
  #$XLSXChar('PointSize:18');
  #$XLSXChar('BorderTop:DASH_DOT_DOT');
  #$XLSXChar('BorderBottom:MEDIUM_DASHED');
  #$XLSXChar('BorderLeft:DOTTED');
  #$XLSXChar('BorderRight:MEDIUM');
  #$XLSXChar('Color:MAROON');

  #$XLSXStyle('name:S_TST03' : 'Font:Courier New' : 'PointSize:12'
            : 'FillForegroundColor:DARK_GREEN' : 'FillPattern:THICK_HORZ_BANDS' : 'Color:MAROON');
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 03':'S_TST03');
  #$XLSXChar('Font:Courier New');
  #$XLSXChar('PointSize:12');
  #$XLSXChar('FillForegroundColor:DARK_GREEN');
  #$XLSXChar('FillPattern:THICK_HORZ_BANDS');
  #$XLSXChar('Color:MAROON');

  #$XLSXStyle('name:S_TST04' : 'Font:Courier New' : 'PointSize:12' : 'Italic:YES'
      : 'BoldWeight:BOLD' : 'FillPattern:BIG_SPOTS' : 'Color:YELLOW');
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 04':'S_TST04');
  #$XLSXChar('Font:Courier New');
  #$XLSXChar('PointSize:12');
  #$XLSXChar('BoldWeight:BOLD');
  #$XLSXChar('FillPattern:BIG_SPOTS');
  #$XLSXChar('Color:YELLOW');

  #$XLSXStyle('name:S_TST05' : 'Strikeout:YES' : 'Color:DARK_GREEN');
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 05':'S_TST05');
  #$XLSXChar('Strikeout:YES');
  #$XLSXChar('Color:DARK_GREEN');

  #$XLSXStyle('name:S_TST06' : 'FillForegroundColor:YELLOW' : 'Underline:YES');
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 06':'S_TST06');
  #$XLSXChar('FillForegroundColor:YELLOW');
  #$XLSXChar('Underline:YES');

  #$XLSXStyle('name:S_TST07' : 'Border:Thin');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 07':'S_TST07');
  #$XLSXChar('Border:Thin');

  #$XLSXStyle('name:S_TST08' : 'Border:dash_dot:HAIR');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 08':'S_TST08');
  #$XLSXChar('Border:dash_dot:HAIR');

  #$XLSXStyle('name:S_TST09' : 'Border:Dashed:Double:Medium_Dash_dot:Medium_Dash_dot_Dot');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 09':'S_TST09');
  #$XLSXChar('Border:Dashed:Double:Medium_Dash_dot:Medium_Dash_dot_Dot');

  #$XLSXStyle('name:S_TST10' : 'BorderBottom:Thin' : 'BorderColor:Red');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 10':'S_TST10');
  #$XLSXChar('BorderBottom:Thin');
  #$XLSXChar('BorderColor:Red');

  #$XLSXStyle('name:S_TST11' : 'BorderTop:Medium' : 'BorderColor:Orange');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 11':'S_TST11');
  #$XLSXChar('BorderTop:Medium');
  #$XLSXChar('BorderColor:Orange');

  #$XLSXStyle('name:S_TST12' : 'BorderRight:Thin' : 'BorderColor:FFFF0101');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 12':'S_TST12');
  #$XLSXChar('BorderRight:Thin');
  #$XLSXChar('BorderColor:FFFF0101');

  #$XLSXStyle('name:S_TST13' : 'BorderLeft:Thin');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 13':'S_TST13');
  #$XLSXChar('BorderLeft:Thin');

  #$XLSXStyle('name:S_TST14' : 'BorderDiagonal:Thin' : 'DiagonalOption:Both');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 14':'S_TST14');
  #$XLSXChar('BorderDiagonal:Thin');
  #$XLSXChar('DiagonalOption:Both');

  #$XLSXStyle('name:S_TST15' : 'BorderDiagonal:Thin' : 'DiagonalOption:Down');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 15':'S_TST15');
  #$XLSXChar('BorderDiagonal:Thin');
  #$XLSXChar('DiagonalOption:Down');

  #$XLSXStyle('name:S_TST16' : 'BorderDiagonal:Thin' : 'DiagonalOption:Up');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 16':'S_TST16');
  #$XLSXChar('BorderDiagonal:Thin');
  #$XLSXChar('DiagonalOption:Up');

  #$XLSXStyle('name:S_TST17' : 'TypeOffset:Sub');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 17':'S_TST17');
  #$XLSXChar('TypeOffset:Sub');

  #$XLSXStyle('name:S_TST18' : 'TypeOffset:Super');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 18':'S_TST18');
  #$XLSXChar('TypeOffset:Super');

  #$XLSXStyle('name:S_TST19' : 'WrapText:Yes');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 19,A bunch of text so it actually wraps.':'S_TST19');
  #$XLSXChar('WrapText:Yes, but this cell does not have wrapped Text so +
              you can see the difference.');

  #$XLSXStyle('name:S_TST2002' : 'WrapText:Yes');
  #$XLSXStyle('name:S_TST20'  : 'Alignment:Left' : 'VerticalAlignment:Top');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 20':'S_TST20');
  #$XLSXChar('Alignment:Left');
  #$XLSXChar('VerticalAlignment:Top');
  #$XLSXChar('A bunch of text to cause this To wrap To 3 lines so the +
              vertical alignment is visable.' : 'S_TST2002');

  #$XLSXStyle('name:S_TST21' : 'Alignment:Center' : 'VerticalAlignment:Center');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 21':'S_TST21');
  #$XLSXChar('Alignment:Center');
  #$XLSXChar('VerticalAlignment:Center');
  #$XLSXChar('A bunch of text to cause this to wrap To 3 lines so the +
      vertical alignment is visable.' : 'S_TST2002');

  #$XLSXStyle('name:S_TST22' : 'Alignment:right' : 'VerticalAlignment:Bottom');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 22':'S_TST22');
  #$XLSXChar('Alignment:right');
  #$XLSXChar('VerticalAlignment:Bottom');
  #$XLSXChar('A bunch of text to cause this to wrap To 3 lines so the +
      vertical alignment is visable.' : 'S_TST2002');

  #$XLSXStyle('name:S_TST23' : 'Alignment:Center:Center');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('TEST STYLE 23':'S_TST23');
  #$XLSXChar('Alignment:Center:Center');
  #$XLSXChar(' ');
  #$XLSXChar('A bunch of text to cause this to wrap To 3 lines so the +
      vertical alignment is visable.' : 'S_TST2002');

  #$XLSXStyle('name:S_TST24' : 'DataFormat:yyyy/mm/dd');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXYYMD(20200101:'S_TST24');
  #$XLSXChar('DataFormat:yyyy/mm/dd');

  #$XLSXStyle('name:S_TST25' : 'DataFormat:#,##0.00');
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXNumr(123.456:'S_TST25');
  #$XLSXChar('DataFormat:#,##0.00');

End-Proc;


// adds a new work sheet(tab) with color examples
Dcl-Proc AddColors;

  // create a new worksheet(tab)
  #$XLSXWkSh('SheetName:Colors Backgrounds'
      : 'FreezeRows:1'
      : 'ColumnWidth:1:30'
      : 'ColumnWidth:2:30'
      : 'ColumnWidth:3:30'
      : 'ColumnWidth:4:10'
      : 'ColumnWidth:5:37'
      : 'ColumnWidth:6:37'
      : 'ColumnWidth:7:37');

  // add a header row
  #$XLSXChar('Color');
  #$XLSXChar('FillForegroundColor');
  #$XLSXChar('FillBackgroundColor');
  #$XLSXNULL();
  #$XLSXChar('#$XLSX Pattern');
  #$XLSXChar('XML Pattern');
  #$XLSXChar('#$XLSX Code');

  For I=1 To 46;

    // create a test style and add it
    #$XLSXStyle('name:S_CLR1'+%Char(I)
              : 'Color:'+%Trim(COLORS(I))
              : 'Alignment:Center'
              : 'VerticalAlignment:Center');
    #$XLSXStyle('name:S_CLR2'+%Char(I)
              : 'FillForegroundColor:'+%Trim(COLORS(I))
              : 'FillPattern:SOLID'
              : 'Alignment:Center'
              : 'VerticalAlignment:Center');
    #$XLSXStyle('name:S_CLR3'+%Char(I)
              : 'FillBackgroundColor:'+%Trim(COLORS(I))
              : 'FillForegroundColor:'+%Trim(COLORS(47-I))
              : 'FillPattern:MediumGray'
              : 'Alignment:Center'
              : 'VerticalAlignment:Center');
    #$XLSXNext();
    #$XLSXChar(%Trim(COLORS(I)):'S_CLR1'+%Char(I));
    #$XLSXChar(%Trim(COLORS(I)):'S_CLR2'+%Char(I));
    #$XLSXChar(%Trim(COLORS(I)):'S_CLR3'+%Char(I));

    // for the first 18 index add the fill patterns
    If I<=18;
      #$XLSXStyle('name:S_FIL1'+%Char(I)
                : 'FillBackgroundColor:'+%Trim(COLORS(I+2))
                : 'FillForegroundColor:'+%Trim(COLORS(I))
                : 'FillPattern:'+%Trim(FILL(i).CODE1)
                : 'WrapText:yes');
      #$XLSXStyle('name:S_FIL2'+%Char(I)
                : 'FillBackgroundColor:'+%Trim(COLORS(I+3))
                : 'FillForegroundColor:'+%Trim(COLORS(I))
                : 'FillPattern:'+%Trim(FILL(i).CODE2)
                : 'WrapText:yes');
      #$XLSXStyle('name:S_FIL3'+%Char(I)
                : 'FillBackgroundColor:'+%Trim(COLORS(I+4))
                : 'FillForegroundColor:'+%Trim(COLORS(47-I))
                : 'FillPattern:'+%Trim(FILL(i).CODE3)
                : 'WrapText:yes');
      #$XLSXNull();
      #$XLSXChar('FillBackgroundColor:'+%Trim(colors(i+2)) + eor +
                 'FillForegroundColor:'+%Trim(colors(i)) + eor +
                 'FillPattern:'+%Trim(fill(i).code1)
                 :'S_FIL1'+%Char(I));
      #$XLSXChar('FillBackgroundColor:'+%Trim(colors(i+3)) + eor +
                 'FillForegroundColor:'+%Trim(colors(i)) + eor +
                 'FillPattern:'+%Trim(fill(i).code2)
                 :'S_FIL2'+%Char(I));
      #$XLSXChar('FillBackgroundColor:'+%Trim(colors(i+4)) + eor +
                 'FillForegroundColor:'+%Trim(colors(i)) + eor +
                 'FillPattern:'+%Trim(fill(i).code3)
                 :'S_FIL3'+%Char(I));
    EndIf;

  EndFor;

End-Proc;


Dcl-Proc AddHeadersFooters;

  // create a new sheet(tab)
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

  // add some garabage
  #$XLSXChar('Test Header and footer options');

  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('This sheet has different first page and odd and even page headers.');

  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Use print preview to see how these look.');

  #$XLSXNext();
  #$XLSXChar('The parameters used for this page are:');
  #$XLSXNext();
  #$XLSXChar( 'SheetName:Header-Footer');
  #$XLSXNext();
  #$XLSXChar( 'Header:First Left:Arial:24:First:Left');
  #$XLSXNext();
  #$XLSXChar( 'Header:First Center:Arial:24:First:Center');
  #$XLSXNext();
  #$XLSXChar( 'Header:First Right:Arial:24:First:Right');
  #$XLSXNext();
  #$XLSXChar( 'Header:Odd Left:Arial:24:Odd:Left');
  #$XLSXNext();
  #$XLSXChar( 'Header:Odd Center:Arial:24:Odd:Center');
  #$XLSXNext();
  #$XLSXChar( 'Header:Odd Right:Arial:24:Odd:Right');
  #$XLSXNext();
  #$XLSXChar( 'Header:Even Left:Arial:24:Even:Left');
  #$XLSXNext();
  #$XLSXChar( 'Header:Even Center:Arial:24:Even:Center');
  #$XLSXNext();
  #$XLSXChar( 'Header:Even Right:Arial:24:Even:Right');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr First Left:Arial:24:First:Left');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr First Center:Arial:24:First:Center');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr First Right:Arial:24:First:Right');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr Odd Left:Arial:24:Odd:Left');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr Odd Center:Arial:24:Odd:Center');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr Odd Right:Arial:24:Odd:Right');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr Even Left:Arial:24:Even:Left');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr Even Center:Arial:24:Even:Center');
  #$XLSXNext();
  #$XLSXChar( 'Footer:Ftr Even Right:Arial:24:Even:Right');
  #$XLSXNext();
  #$XLSXChar( 'DifferentOddAndEvenPages:On');
  #$XLSXNext();
  #$XLSXChar( 'DifferentFirstPage:Yes');

  #$XLSXNext();
  #$XLSXChar('Below is just a bunch of garbage so it goes to more pages.');


  // add a bunch of lines so it goes to at least 5 pages
  For x = 1 To 100;
    #$XLSXNext();
    #$XLSXChar('Garbage');
    #$XLSXNext();
    #$XLSXChar('Garbage');
    #$XLSXNext();
    #$XLSXChar('Garbage');
    #$XLSXNext();
    #$XLSXChar('Garbage');
    #$XLSXNext();
    #$XLSXChar('Trash');
  EndFor;

End-Proc;


Dcl-Proc AddCellReferences;

  // create a new sheet(tab)
  #$XLSXWkSh('SheetName:#$XLSXCell'
           : 'ColumnWidth:1:30'
           : 'ColumnWidth:2:30'
           : 'ColumnWidth:3:15'
           : 'ColumnWidth:4:40'
           : 'ColumnWidth:5:15'
           : 'ColumnWidth:6:40'
           : 'ColumnWidth:7:15');

  // add sheet information
  #$XLSXChar('Tests all parameters for the $XSLXCell function':'S_TITLE':4);

  #$XLSXNext();
  #$XLSXChar('This function returns a cells or a range relative To the current cell.':*omit:4);

  #$XLSXNext();
  #$XLSXChar('Each example shows the function used, a description of what should +
              happen and the results.':*omit:4);

  // add headers
  #$XLSXNext();
  #$XLSXChar('Description':'S_HDR2');
  #$XLSXChar('Function-Shortcut':'S_HDR2');
  #$XLSXChar('Output':'S_HDR2');
  #$XLSXChar('Function-Full':'S_HDR2');
  #$XLSXChar('Output':'S_HDR2');
  #$XLSXChar('#$XLSXC':'S_HDR2');
  #$XLSXChar('Output':'S_HDR2');


  #$XLSXNext();
  #$XLSXChar('Return the current cell');
  #$XLSXChar('#$XLSXCell()');
  #$XLSXChar(#$XLSXCell());
  #$XLSXNull();
  #$XLSXNull();
  #$XLSXChar('#$XLSXC()');
  #$XLSXChar(#$XLSXC());
  #$XLSXNext();
  #$XLSXChar('Return the current cell');
  #$XLSXChar('#$XLSXCell(''R:0:0:0:0'')');
  #$XLSXChar(#$XLSXCell('R:0:0:0:0'));
  #$XLSXChar('#$XLSXCell(''Range:0:0:0:0'')');
  #$XLSXChar(#$XLSXCell('Range:0:0:0:0'));
  #$XLSXChar('#$XLSXC(''R'':0:0:0:0)');
  #$XLSXChar(#$XLSXC('R':0:0:0:0));
  #$XLSXNext();
  #$XLSXChar('Return the previous cell');
  #$XLSXChar('#$XLSXCell(''r:0:0:1:0'')');
  #$XLSXChar(#$XLSXCell('r:0:0:1:0'));
  #$XLSXChar('#$XLSXCell(''range:0:0:1:0'')');
  #$XLSXChar(#$XLSXCell('range:0:0:1:0'));
  #$XLSXChar('#$XLSXC(''r'':0:0:1:0)');
  #$XLSXChar(#$XLSXC('r':0:0:1:0));
  #$XLSXNext();
  #$XLSXChar('Return the previous cell');
  #$XLSXChar('#$XLSXCell(''VO:1'')');
  #$XLSXChar(#$XLSXCell('VO:1'));
  #$XLSXChar('#$XLSXCell(''VerticalOffset:1'')');
  #$XLSXChar(#$XLSXCell('VerticalOffset:1'));
  #$XLSXChar('#$XLSXC(''VO'':1)');
  #$XLSXChar(#$XLSXC('VO':1));
  #$XLSXNext();
  #$XLSXChar('Return the previous cell');
  #$XLSXChar('#$XLSXCell(''O:1:0'')');
  #$XLSXChar(#$XLSXCell('O:1:0'));
  #$XLSXChar('#$XLSXCell(''Offset:1:0'')');
  #$XLSXChar(#$XLSXCell('Offset:1:0'));
  #$XLSXChar('#$XLSXC(''O'':1:0)');
  #$XLSXChar(#$XLSXC('O':1:0));
  #$XLSXNext();
  #$XLSXChar('Return the next cell');
  #$XLSXChar('#$XLSXCell(''R:0:0:-1:0'')');
  #$XLSXChar(#$XLSXCell('R:0:0:-1:0'));
  #$XLSXChar('#$XLSXCell(''RANGE:0:0:-1:0'')');
  #$XLSXChar(#$XLSXCell('RANGE:0:0:-1:0'));
  #$XLSXChar('#$XLSXC(''O'':1:0)');
  #$XLSXChar(#$XLSXC('O':1:0));
  #$XLSXNext();
  #$XLSXChar('Return the next cell');
  #$XLSXChar('#$XLSXCell(''VO:-1'')');
  #$XLSXChar(#$XLSXCell('VO:-1'));
  #$XLSXChar('#$XLSXCell(''VERTICALOFFSET:-1'')');
  #$XLSXChar(#$XLSXCell('VERTICALOFFSET:-1'));
  #$XLSXChar('#$XLSXC(''VO'':-1)');
  #$XLSXChar(#$XLSXC('VO':-1));
  #$XLSXNext();
  #$XLSXChar('Return the next cell');
  #$XLSXChar('#$XLSXCell(''O:-1:0'')');
  #$XLSXChar(#$XLSXCell('O:-1:0'));
  #$XLSXChar('#$XLSXCell(''OFFSET:-1:0'')');
  #$XLSXChar(#$XLSXCell('OFFSET:-1:0'));
  #$XLSXChar('#$XLSXC(''O'':-1:0)');
  #$XLSXChar(#$XLSXC('O':-1:0));
  #$XLSXNext();
  #$XLSXChar('Return cell to the left');
  #$XLSXChar('#$XLSXCell(''R:0:0:0:1'')');
  #$XLSXChar(#$XLSXCell('R:0:0:0:1'));
  #$XLSXChar('#$XLSXCell(''Range:0:0:0:1'')');
  #$XLSXChar(#$XLSXCell('Range:0:0:0:1'));
  #$XLSXChar('#$XLSXC(''R'':0:0:0:1)');
  #$XLSXChar(#$XLSXC('R':0:0:0:1));
  #$XLSXNext();
  #$XLSXChar('Return cell to the left');
  #$XLSXChar('#$XLSXCell(''HO:1'')');
  #$XLSXChar(#$XLSXCell('HO:1'));
  #$XLSXChar('#$XLSXCell(''HorizontalOffset:1'')');
  #$XLSXChar(#$XLSXCell('HorizontalOffset:1'));
  #$XLSXChar('#$XLSXC(''HO'':1)');
  #$XLSXChar(#$XLSXC('HO':1));
  #$XLSXNext();
  #$XLSXChar('Return cell to the left');
  #$XLSXChar('#$XLSXCell(''O:0:1'')');
  #$XLSXChar(#$XLSXCell('O:0:1'));
  #$XLSXChar('#$XLSXCell(''Offset:0:1'')');
  #$XLSXChar(#$XLSXCell('Offset:0:1'));
  #$XLSXChar('#$XLSXC(''O'':0:1)');
  #$XLSXChar(#$XLSXC('O':0:1));
  #$XLSXNext();
  #$XLSXChar('Return cell to the right');
  #$XLSXChar('#$XLSXCell(''R:0:0:0:-1'')');
  #$XLSXChar(#$XLSXCell('R:0:0:0:-1'));
  #$XLSXChar('#$XLSXCell(''range:0:0:0:-1'')');
  #$XLSXChar(#$XLSXCell('range:0:0:0:-1'));
  #$XLSXChar('#$XLSXC(''R'':0:0:0:-1)');
  #$XLSXChar(#$XLSXC('R':0:0:0:-1));
  #$XLSXNext();
  #$XLSXChar('Return cell to the right');
  #$XLSXChar('#$XLSXCell(''HO:-1'')');
  #$XLSXChar(#$XLSXCell('HO:-1'));
  #$XLSXChar('#$XLSXCell(''HORIZONTALOFFSET:-1'')');
  #$XLSXChar(#$XLSXCell('HORIZONTALOFFSET:-1'));
  #$XLSXChar('#$XLSXC(''HO'':-1)');
  #$XLSXChar(#$XLSXC('HO':-1));
  #$XLSXNext();
  #$XLSXChar('Return cell to the right');
  #$XLSXChar('#$XLSXCell(''O:0:-1'')');
  #$XLSXChar(#$XLSXCell('O:0:-1'));
  #$XLSXChar('#$XLSXCell(''offset:0:-1'')');
  #$XLSXChar(#$XLSXCell('offset:0:-1'));
  #$XLSXChar('#$XLSXC(''O'':0:-1)');
  #$XLSXChar(#$XLSXC('O':0:-1));
  #$XLSXNext();
  #$XLSXChar('Return cell up 2 and left 2');
  #$XLSXChar('#$XLSXCell(''R:0:0:2:2'')');
  #$XLSXChar(#$XLSXCell('R:0:0:2:2'));
  #$XLSXChar('#$XLSXCell(''range:0:0:2:2'')');
  #$XLSXChar(#$XLSXCell('range:0:0:2:2'));
  #$XLSXChar('#$XLSXC(''R'':0:0:2:2)');
  #$XLSXChar(#$XLSXC('R':0:0:2:2));
  #$XLSXNext();
  #$XLSXChar('Return cell up 2 and left 2');
  #$XLSXChar('#$XLSXCell(''o:2:2'')');
  #$XLSXChar(#$XLSXCell('o:2:2'));
  #$XLSXChar('#$XLSXCell(''offset:2:2'')');
  #$XLSXChar(#$XLSXCell('offset:2:2'));
  #$XLSXChar('#$XLSXC(''o'':2:2)');
  #$XLSXChar(#$XLSXC('o':2:2));
  #$XLSXNext();
  #$XLSXChar('Return cell down 2 and right 2');
  #$XLSXChar('#$XLSXCell(''R:0:0:-2:-2'')');
  #$XLSXChar(#$XLSXCell('R:0:0:-2:-2'));
  #$XLSXChar('#$XLSXCell(''range:0:0:-2:-2'')');
  #$XLSXChar(#$XLSXCell('range:0:0:-2:-2'));
  #$XLSXChar('#$XLSXC(''R'':0:0:-2:-2)');
  #$XLSXChar(#$XLSXC('R':0:0:-2:-2));
  #$XLSXNext();
  #$XLSXChar('Return cell down 2 and right 2');
  #$XLSXChar('#$XLSXCell(''o:-2:-2'')');
  #$XLSXChar(#$XLSXCell('o:-2:-2'));
  #$XLSXChar('#$XLSXCell(''offset:-2:-2'')');
  #$XLSXChar(#$XLSXCell('offset:-2:-2'));
  #$XLSXChar('#$XLSXC(''o'':-2:-2)');
  #$XLSXChar(#$XLSXC('o':-2:-2));
  #$XLSXNext();
  #$XLSXChar('A Range of the last 2 cells');
  #$XLSXChar('#$XLSXCell(''R:2:0:1:0'')');
  #$XLSXChar(#$XLSXCell('R:2:0:1:0'));
  #$XLSXChar('#$XLSXCell(''Range:2:0:1:0'')');
  #$XLSXChar(#$XLSXCell('Range:2:0:1:0'));
  #$XLSXChar('#$XLSXC(''R'':2:0:1:0)');
  #$XLSXChar(#$XLSXC('R':2:0:1:0));
  #$XLSXNext();
  #$XLSXChar('A Range of the last 2 cells');
  #$XLSXChar('#$XLSXCell(''VR:2'')');
  #$XLSXChar(#$XLSXCell('VR:2'));
  #$XLSXChar('#$XLSXCell(''VerticalRange:2'')');
  #$XLSXChar(#$XLSXCell('VerticalRange:2'));
  #$XLSXChar('#$XLSXC(''VR'':2)');
  #$XLSXChar(#$XLSXC('VR':2));
  #$XLSXNext();
  #$XLSXChar('A Range of the 2 cells 2 cells up');
  #$XLSXChar('#$XLSXCell(''R:2:0:2:0'')');
  #$XLSXChar(#$XLSXCell('R:2:0:2:0'));
  #$XLSXChar('#$XLSXCell(''Range:2:0:2:0'')');
  #$XLSXChar(#$XLSXCell('Range:2:0:2:0'));
  #$XLSXChar('#$XLSXC(''R'':2:0:2:0)');
  #$XLSXChar(#$XLSXC('R':2:0:2:0));
  #$XLSXNext();
  #$XLSXChar('A Range of the 2 cells 2 cells up');
  #$XLSXChar('#$XLSXCell(''VR:2:1'')');
  #$XLSXChar(#$XLSXCell('VR:2:1'));
  #$XLSXChar('#$XLSXCell(''VerticalRange:2:1'')');
  #$XLSXChar(#$XLSXCell('VerticalRange:2:1'));
  #$XLSXChar('#$XLSXC(''VR'':2:1)');
  #$XLSXChar(#$XLSXC('VR':2:1));
  #$XLSXNext();
  #$XLSXChar('A Range of 2 cells left');
  #$XLSXChar('#$XLSXCell(''R:0:2:0:1'')');
  #$XLSXChar(#$XLSXCell('R:0:2:0:1'));
  #$XLSXChar('#$XLSXCell(''Range:0:2:0:1'')');
  #$XLSXChar(#$XLSXCell('Range:0:2:0:1'));
  #$XLSXChar('#$XLSXC(''R'':0:2:0:1)');
  #$XLSXChar(#$XLSXC('R':0:2:0:1));
  #$XLSXNext();
  #$XLSXChar('A Range of 2 cells left');
  #$XLSXChar('#$XLSXCell(''HR:2'')');
  #$XLSXChar(#$XLSXCell('HR:2'));
  #$XLSXChar('#$XLSXCell(''HorizontalRange:2'')');
  #$XLSXChar(#$XLSXCell('HorizontalRange:2'));
  #$XLSXChar('#$XLSXC(''HR'':2)');
  #$XLSXChar(#$XLSXC('HR':2));
  #$XLSXNext();
  #$XLSXChar('A Range of 2 cells right offset by 1');
  #$XLSXChar('#$XLSXCell(''R:0:-2:0:1'')');
  #$XLSXChar(#$XLSXCell('R:0:-2:0:1'));
  #$XLSXChar('#$XLSXCell(''Range:0:-2:0:1'')');
  #$XLSXChar(#$XLSXCell('Range:0:-2:0:1'));
  #$XLSXChar('#$XLSXC(''R'':0:-2:0:1)');
  #$XLSXChar(#$XLSXC('R':0:-2:0:1));
  #$XLSXNext();
  #$XLSXChar('A Range of 2 cells right offset by 1');
  #$XLSXChar('#$XLSXCell(''HR:-2:1'')');
  #$XLSXChar(#$XLSXCell('HR:-2:1'));
  #$XLSXChar('#$XLSXCell(''HorizontalRange:-2:1'')');
  #$XLSXChar(#$XLSXCell('HorizontalRange:-2:1'));
  #$XLSXChar('#$XLSXC(''HR'':-2:1)');
  #$XLSXChar(#$XLSXC('HR':-2:1));
  #$XLSXNext();
  #$XLSXChar('A 3x2 range, up and left 1');
  #$XLSXChar('#$XLSXCell(''R:3:2:1:1'')');
  #$XLSXChar(#$XLSXCell('R:3:2:1:1'));
  #$XLSXChar('#$XLSXCell(''Range:3:2:1:1'')');
  #$XLSXChar(#$XLSXCell('Range:3:2:1:1'));
  #$XLSXChar('#$XLSXC(''R'':3:2:1:1)');
  #$XLSXChar(#$XLSXC('R':3:2:1:1));
  #$XLSXNext();
  #$XLSXChar('A 3x2 range, down and right 1');
  #$XLSXChar('#$XLSXCell(''R:-3:-2:-1:-1'')');
  #$XLSXChar(#$XLSXCell('R:-3:-2:-1:-1'));
  #$XLSXChar('#$XLSXCell(''Range:-3:-2:-1:-1'')');
  #$XLSXChar(#$XLSXCell('Range:-3:-2:-1:-1'));
  #$XLSXChar('#$XLSXC(''R'':-3:-2:-1:-1)');
  #$XLSXChar(#$XLSXC('R':-3:-2:-1:-1));
  #$XLSXNext();
  #$XLSXChar('TODO Negative ranges don''t work');
  #$XLSXNext();
  #$XLSXChar('need to swap cell order in the range.');
  #$XLSXNext();
  #$XLSXChar('and the range size is off by 2.');
End-Proc;


Dcl-Proc AddInvalidData;

  // create a new sheet(tab)
  #$XLSXWkSh('SheetName:#$XLSXData'
           : 'ColumnWidth:1:30'
           : 'ColumnWidth:2:40'
           : 'ColumnWidth:3:30'
           : 'ColumnWidth:4:60' );

  // add sheet information
  #$XLSXChar('Tests adding data.':'S_TITLE':3);

  #$XLSXNext();
  #$XLSXChar('There was an issue with invalid dates +
              that caused the program to error out.':*omit:3);
  #$XLSXNext();
  #$XLSXChar('The intent of this sheet is to test adding invalid +
              data To see how the program handles it.':*omit:3);

  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Issue being tested':'S_HDR');
  #$XLSXChar('Function and parms':'S_HDR');
  #$XLSXChar('Result':'S_HDR');
  #$XLSXChar('Comments':'S_HDR');

  // test for an invalid date
  #$XLSXNext();
  #$XLSXChar('Valid date':'S_dtl');
  #$XLSXChar('#$XLSXYYMD(20210101:''S_DATE'')':'S_DTL');
  #$XLSXYYMD(20210101:'S_DATE');
  #$XLSXChar('Should add the date':'S_DTL');
  #$XLSXNext();
  #$XLSXChar('Valid date':'S_DTL');
  #$XLSXChar('#$XLSXmdy(010121:''S_DATE'')':'S_DTL');
  #$XLSXMDY(010121:'S_DATE');
  #$XLSXChar('Should add the date':'S_DTL');
  #$XLSXNext();
  #$XLSXChar('Valid date':'S_DTL');
  #$XLSXChar('#$XLSXMDYY(01012021:''S_DATE'')':'S_DTL');
  #$XLSXMDYY(01012021:'S_DATE');
  #$XLSXChar('Should add the date':'S_DTL');
  #$XLSXNext();
  #$XLSXChar('Invalid date':'S_DTL');
  #$XLSXChar('#$XLSXYYMD(20210100:''S_DATE'')':'S_DTL');
  #$XLSXYYMD(20210100:'S_DATE');
  #$XLSXChar('This should add an empty cell and log an informational error':'S_DTL');
  #$XLSXNext();
  #$XLSXChar('Invalid date':'S_DTL');
  #$XLSXChar('#$XLSXmdy(010021:''S_DATE'')':'S_DTL');
  #$XLSXMDY(010021:'S_DATE');
  #$XLSXChar('This should add an empty cell and log an informational error':'S_DTL');
  #$XLSXNext();
  #$XLSXChar('Invalid date':'S_DTL');
  #$XLSXChar('#$XLSXMDYY(01002021:''S_DATE'')':'S_DTL');
  #$XLSXMDYY(01002021:'S_DATE');
  #$XLSXChar('This should add an empty cell and log an informational error':'S_DTL');

End-Proc;


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
** FILL ARRAY   1-30=EXCEL Value, 31-60 #$XLSX Value,  61-CODE
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
