**Free
Ctl-Opt Option(*SrcStmt:*NoDebugIO:*NoShowCpy) DftActGrp(*No) BndDir('#$XLSX1.0/#$XLSX') main(Main);

// #$XLSX Example adding more data

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
  #$XLSXOpen('OutputName:'+%Trim(path) + '/#$XLSXE2.xlsx');

  // create a new sheet(tab)
  #$XLSXWkSh();

  // Add Title row
  #$XLSXChar('Inventory Report':*omit:2);
  #$XLSXNull();
  #$XLSXDATE(%Date());

  // Skip a Line
  #$XLSXNext();

  // Add the header line
  #$XLSXNext();
  #$XLSXChar('Item');
  #$XLSXChar('Description');
  #$XLSXChar('Setup Date');
  #$XLSXChar('Qty on Hand');
  #$XLSXChar('Price');

  // Loop through file and add each detail line, save count so a formula can be added at the bottom
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
    Count += 1;
    #$XLSXNext();
    #$XLSXChar(Item);
    #$XLSXChar(Desc);
    #$XLSXYYMD(Setup);
    #$XLSXNumr(QtyOh);
    #$XLSXNumr(Price);
    Exec Sql fetch next from sqlCrs into :dta;
  EndDo;
  Exec Sql Close sqlCrs;

  // add a total line using a formula to calculate it
  #$XLSXNext();
  #$XLSXNull();
  #$XLSXChar('Total:');
  #$XLSXNull();
  #$XLSXForm('=SUM(D4:D'+%Char(Count+3)+')');

  // Close the open XLS File
  #$XLSXClose();

End-Proc;
