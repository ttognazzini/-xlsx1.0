     H DATEDIT(*YMD) OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY) DEBUG INDENT('| ')
     H DFTACTGRP(*NO) BNDDIR('#$XLSX1.0/#$XLSX')
     F*
     F* #$XLSX Test
     F*
     D defaultPath     DS                  dtaara('#$XLSX/#$XLSXTEMP')
     D   path                  1    100
     D*
     D/INCLUDE #$XLSX1.0/QRPGLESRC,#$XLSX_H

       // Get default path from data area
          In defaultPath;

       // CREATE XLS FILE IN THE IFS - MUST BE DONE BEFORE CREATING STYLES
          #$XLSXOpen('OutputName:'+%trim(path)+'/#$XLSXTS3.xlsx'
                   : 'Buffering:1');
       //          : 'Debug:*On'

       // CREATE A NEW SHEET(TAB)
          #$XLSXWkSh();

          #$XLSXCHAR('É');

       // Close the open XLS File
          #$XLSXClose();

          *inlr=*on;
          RETURN;

