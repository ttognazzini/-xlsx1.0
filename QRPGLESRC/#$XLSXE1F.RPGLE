**free
   Ctl-Opt DatEdit(*YMD) Option(*NoDebugIO:*SrcStmt:*NoShowCpy) Debug Indent('| ')
           DftActGrp(*NO) BNDDIR('#$XLSX1.0/#$XLSX');
   // #$XLSX Hello World Program Free Format
   /INCLUDE #$XLSX1.0/QRPGLESRC,#$XLSX_H   //copy book for prototype definitions
   DCL-DS defaultPath DTAARA(*AUTO:*USRCTL:'#$XLSX1.0/#$XLSXTEMP');
      path CHAR(100);
   END-DS;

   // Get default path from data area
      In defaultPath;

   // Start the Excel Work book - MUST BE DONE FIRST
      #$XLSXOpen('OutputName:/EMAIL/TMP/#$XLSXE1.xlsx');

   // Create a New Sheet(Tab)
      #$XLSXWkSh();

   // Populate the First Cell in the First Row
      #$XLSXChar('Hello World');

   // Close the open XLS File
      #$XLSXClose();

      *inlr=*on;
      return;

