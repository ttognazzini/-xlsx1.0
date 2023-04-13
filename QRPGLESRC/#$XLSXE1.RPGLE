**Free
Ctl-Opt DatEdit(*YMD) Option(*NoDebugIO:*SrcStmt:*NoShowCpy) Debug Indent('| ')
        DftActGrp(*No) BndDir('#$XLSX1.0/#$XLSX');

// #$XLSX Hello World Program Free Format

/Include #$XLSX1.0/QRPGLESRC,#$XLSX_H   //copy book for prototype definitions

Dcl-Ds defaultPath DTAARA(*AUTO:*USRCTL:'#$XLSX1.0/#$XLSXTEMP');
  path Char(100);
End-Ds;

// Get default path from data area
In defaultPath;

// Start the Excel Work book - MUST BE DONE FIRST
#$XLSXOpen('OutputName:'+%Trim(path) + '/#$XLSXE1.xlsx');


// Create a New Sheet(Tab)
#$XLSXWkSh();

// Populate the First Cell in the First Row
#$XLSXChar('Hello World');

// Close the open XLS File
#$XLSXClose();

*inlr=*on;
Return;

