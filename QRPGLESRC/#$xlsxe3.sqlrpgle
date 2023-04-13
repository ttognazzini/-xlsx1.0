**Free
Ctl-Opt Option(*SrcStmt:*NoDebugIO:*NoShowCpy) Main(Main) DftActGrp(*No) BndDir('#$XLSX1.0/#$XLSX');

// #$XLSX Example adding styles

/Include #$XLSX1.0/QRPGLESRC,#$XLSX_H

Dcl-Ds defaultPath dtaara('#$XLSX1.0/#$XLSXTEMP');
  path Char(100) pos(1);
End-Ds;

Dcl-Proc Main;

  Dcl-Ds dta;
    item char(10);
    desc varchar(30);
    setup packed(8);
    qtyOh packed(7:2);
    price packed(9:2);
  End-Ds;

  Dcl-S Count packed(5);


  // Get default path from data area
  In defaultPath;

  // Start the Excel Work book - MUST BE DONE FIRST
  #$XLSXOpen('OutputName:'+%Trim(path) + '/#$XLSXE3.xlsx');

  // setup styles

  // make the title big, bold and centered
  #$XLSXStyle('name:TITLE'
      : 'Font:Arial'
      : 'PointSize:18'
      : 'WrapText:Yes'
      : 'Alignment:CENTER'
      : 'BoldWeight:BOLD');
  // the date on the title row needs a data format so it is edited correctly
  #$XLSXStyle('name:TDATE'
      : 'DataFormat:yyyy/mm/dd');

  // make the header row, bold, centered with borders...
  #$XLSXStyle('name:HDR'
      : 'Font:Arial'
      : 'PointSize:10'
      : 'WrapText:YES'
      : 'Alignment:CENTER'
      : 'BoldWeight:BOLD'
      : 'BorderTop:THIN'
      : 'BorderBottom:MEDIUM'
      : 'BorderLeft:THIN'
      : 'BorderRight:THIN');

  // these three are all for the detail row, the first one is
  // a general style, the next two show formating for the date
  // and dollar fields
  #$XLSXStyle('name:DTL'
      : 'Font:Arial'
      : 'PointSize:10'
      : 'BorderTop:THIN'
      : 'BorderBottom:THIN'
      : 'BorderLeft:THIN'
      : 'BorderRight:THIN');
  #$XLSXStyle('name:DATE'
      : 'Font:Arial'
      : 'PointSize:10'
      : 'Alignment:CENTER'
      : 'BorderTop:THIN'
      : 'BorderBottom:THIN'
      : 'BorderLeft:THIN'
      : 'BorderRight:THIN'
      : 'DataFormat:yyyy/mm/dd');
  #$XLSXStyle('name:DOLLAR'
      : 'Font:Arial'
      : 'PointSize:10'
      : 'BorderTop:THIN'
      : 'BorderBottom:THIN'
      : 'BorderLeft:THIN'
      : 'BorderRight:THIN'
      : 'DataFormat:#,##0.00');

  // create a new sheet(tab), set the sheet name, freeze the top 3 rows
  #$XLSXWkSh('SheetName:#$XLSXT3'
      : 'FreezeRows:3'
      : 'FreezeColumns:1');

  // set some column widths.
  // these could have been done on the line above, but they are left
  // here to show how additional properties can be added by re-running
  // THE #$XLSXWkSh FUNCTION, THE FUNCTION ACCEPTS UP TO 200 PROPERTIES
  // so the only reason this would be done is if there are hundreds of
  // columns you want to set the width for.
  #$XLSXWkSh('ColumnWidth:1:11'
      : 'ColumnWidth:2:30'
      : 'ColumnWidth:3:11'
      : 'ColumnWidth:4:8'
      : 'ColumnWidth:5:11');

  // Add Title row
  // Notice on the #$XLSChar for the title we have added the style name
  // as the second parameter. There is also a third parameter, that is the
  // number of cells to merge in to the cell we are using. This formats the
  // with the properties from the style and makes it span 3 columns.
  // All add data type functions have style and merge for the 2nd and 3rd parm.
  #$XLSXChar('Inventory Report':'TITLE':2);
  #$XLSXNull();
  #$XLSXDATE(%date():'TDATE');

  // Skip a Line
  #$XLSXNext();

  // Add the header line
  #$XLSXNext();
  #$XLSXChar('Item':'HDR');
  #$XLSXChar('Description':'HDR');
  #$XLSXChar('Setup Date':'HDR');
  #$XLSXChar('Qty on Hand':'HDR');
  #$XLSXChar('Price':'HDR');

  // Loop through file and add each detail line, save count so a formula
  // can be added at the bottom
  Count = 0;
  Exec sql Declare sqlCrs cursor for
    Select
      item,
      desc,
      setup,
      qtyOh,
      price
    from #$XLSXINV;
  Exec Sql Open sqlCrs;
  Exec Sql fetch next from sqlCrs into :dta;
  DoW sqlState < '02';
    count +=1;
    #$XLSXNext();
    #$XLSXChar(Item:'DTL');
    #$XLSXChar(Desc:'DTL');
    #$XLSXYYMD(Setup:'DATE');
    #$XLSXNumr(QtyOh:'DTL');
    #$XLSXNumr(Price:'DOLLAR');
    Exec Sql fetch next from sqlCrs into :dta;
  EndDo;
  Exec Sql Close sqlCrs;

  // Add a total line using a formual to calculate it
  #$XLSXNext();
  #$XLSXNull();
  #$XLSXChar('Total:');
  #$XLSXNull();
  #$XLSXForm('=SUM(D4:D'+%Char(Count+3)+')');

  // Close the open XLS File
  #$XLSXClose();

End-Proc;
