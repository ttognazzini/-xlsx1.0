     H OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY)
     H DFTACTGRP(*NO) BNDDIR('#$XLSX1.0/#$XLSX')
     F* #$XLSX Example Using Relative Positioned Formulas
     D/INCLUDE #$XLSX1.0/QRPGLESRC,#$XLSX_H
     D defaultPath     DS                  dtaara('#$XLSX1.0/#$XLSXTEMP')
     D   path                  1    100

      * I did this one in free format becasue it looks better with the SQL
      * the logic works the same in fixed format

      * These two would be the year and quarter number passed to the program.
      * They are hard coded for simplicity and because the data is only
      * populated for quarter 4 of 2021.
     D  Year           S              4P 0 INZ(2021)
     D  Quarter        S              2P 0 INZ(4)

      * Toggle this on and off to see how all the functions still work
      * even with different rows and columns.
      * Likewise if you adding more lines of data to the input file
      * all the formulas will adjust accordingly.
      * This works because all formulas use relative positioning.
     D  ShowTitle      S               N   INZ(*On)

      * These are used to save off specific cell locations and duplicate
      * them at the bottom and to count the number of detail lines
     D  SalesTotalLoc  S              4A   INZ('') VARYING
     D  AverageLoc     S              4A   INZ('') VARYING
     D  Count          S              5p 0 INZ(0)

      * Data Structure to read from the input file
     D  InputDS      E ds                  Extname(#$XLSXE9PF)

      * end of line characters
     D eol             s              2a   inz( x'0D25' )

      //****************************************************************

       // Get default path from data area
        In defaultPath;

       // Start the Excel Work book - MUST BE DONE FIRST
       #$XLSXOpen('OutputName:'+%trim(path)+'/#$XLSXE9.xlsx');

       // Setup styles

          // Make the title big, bold and centered
          #$XLSXStyle('name:S_Title'
                    : 'Font:Arial'
                    : 'PointSize:18'
                    : 'WrapText:Yes'
                    : 'Alignment:CENTER'
                    : 'BoldWeight:BOLD');

          // Make the header row, bold and centered
          #$XLSXStyle('name:S_Hdr'
                    : 'Font:Arial'
                    : 'PointSize:10'
                    : 'WrapText:YES'
                    : 'Alignment:CENTER'
                    : 'BoldWeight:BOLD');

          // Used to bold the total titles
          #$XLSXStyle('name:S_Bold'
                    : 'Font:Arial'
                    : 'PointSize:10'
                    : 'Alignment:Right'
                    : 'BoldWeight:BOLD');

          // These two are for the detail row, the first one is
          // a general style, the next one is to make numbers not include
          // decimal positions and include commas
          #$XLSXStyle('name:S_Dtl'
                    : 'Font:Arial'
                    : 'PointSize:10');
          #$XLSXStyle('name:S_Num'
                    : 'Font:Arial'
                    : 'PointSize:10'
                    : 'DataFormat:#,##0');

       // CREATE A NEW SHEET(TAB)
       If ShowTitle;
          #$XLSXWkSh('FreezeRows:4'
                   : 'ColumnWidth:1:11'
                   : 'ColumnWidth:2:30'
                   : 'ColumnWidth:3:11'
                   : 'ColumnWidth:4:11'
                   : 'ColumnWidth:5:11'
                   : 'ColumnWidth:6:11'
                   : 'ColumnWidth:7:11');
       Else;
          #$XLSXWkSh('FreezeRows:1'
                   : 'ColumnWidth:1:30'
                   : 'ColumnWidth:2:11'
                   : 'ColumnWidth:3:11'
                   : 'ColumnWidth:4:11'
                   : 'ColumnWidth:5:11'
                   : 'ColumnWidth:6:11');
       EndIf;

       // Add Title rows
       If ShowTitle;
          #$XLSXChar('Quarterly Sales Report':'S_Title':5);
          #$XLSXNext();
          #$XLSXChar('For quarter ' + %char(quarter) + ' of ' + %char(year));
          #$XLSXNext();
          #$XLSXNext();
       EndIf;

       // Add the header line
       If ShowTitle;
          #$XLSXChar('SKU':'S_Hdr');
       EndIf;
       #$XLSXChar('Description':'S_Hdr');
       If Quarter=1;
          #$XLSXChar('January'+eol+'Sales':'S_Hdr');
          #$XLSXChar('February'+eol+'Sales':'S_Hdr');
          #$XLSXChar('March'+eol+'Sales':'S_Hdr');
       ElseIf Quarter=2;
          #$XLSXChar('April'+eol+'Sales':'S_Hdr');
          #$XLSXChar('May'+eol+'Sales':'S_Hdr');
          #$XLSXChar('June'+eol+'Sales':'S_Hdr');
       ElseIf Quarter=3;
          #$XLSXChar('July'+eol+'Sales':'S_Hdr');
          #$XLSXChar('August'+eol+'Sales':'S_Hdr');
          #$XLSXChar('September'+eol+'Sales':'S_Hdr');
       Else;
          #$XLSXChar('October'+eol+'Sales':'S_Hdr');
          #$XLSXChar('November'+eol+'Sales':'S_Hdr');
          #$XLSXChar('December'+eol+'Sales':'S_Hdr');
       EndIf;
       #$XLSXChar('Quarter'+eol+'Totals':'S_Hdr');
       #$XLSXChar('Month'+eol+'Average':'S_Hdr');

       // Loop through file and add each detail line, save count for formulas
       exec sql declare sqlcrs cursor for
                select * from #$xlsxe9pf where tpyear=:year;
       exec sql open sqlcrs;
       exec sql fetch next from sqlcrs into :InputDS;
       dow sqlstt='00000';
           count +=1;
           #$XLSXNext();
           if ShowTitle;
              #$XLSXNumr(TPSKU:'S_Dtl');
           endif;
           #$XLSXChar(TPDESC:'S_Dtl');
           if quarter=1;
              #$XLSXNumr(TPSD01:'S_Num');
              #$XLSXNumr(TPSD02:'S_Num');
              #$XLSXNumr(TPSD03:'S_Num');
           elseif quarter=2;
              #$XLSXNumr(TPSD04:'S_Num');
              #$XLSXNumr(TPSD05:'S_Num');
              #$XLSXNumr(TPSD06:'S_Num');
           elseif quarter=3;
              #$XLSXNumr(TPSD07:'S_Num');
              #$XLSXNumr(TPSD08:'S_Num');
              #$XLSXNumr(TPSD09:'S_Num');
           else;
              #$XLSXNumr(TPSD10:'S_Num');
              #$XLSXNumr(TPSD11:'S_Num');
              #$XLSXNumr(TPSD12:'S_Num');
           endif;
           #$XLSXForm('sum('+#$XLSXCell('HR:3')+')':'S_Num');
           #$XLSXForm('sum('+#$XLSXCell('HR:3:1')+')':'S_Num');
           exec sql fetch next from sqlcrs into :InputDS;
       enddo;
       exec sql close sqlcrs;

       // ADD A TOTAL LINE USING A FORMUAL TO CALCULATE IT
       #$XLSXNext();
       if ShowTitle;
          #$XLSXNull();
       endif;
       #$XLSXChar('Quarter Totals:':'S_Bold');
       #$XLSXForm('sum('+#$XLSXCell('VR:'+%char(count))+')':'S_Num');
       #$XLSXForm('sum('+#$XLSXCell('VR:'+%char(count))+')':'S_Num');
       #$XLSXForm('sum('+#$XLSXCell('VR:'+%char(count))+')':'S_Num');
       SalesTotalLoc=#$XLSXCell();
       #$XLSXForm('sum('+#$XLSXCell('R:'+%char(count)+':3:1:1')+')':'S_Num');
       AverageLoc=#$XLSXCell();
       #$XLSXForm('average('+#$XLSXCell('HR:3:1')+')':'S_Num');

       // ADD AN AVERAGE LINE USING A FORMUAL TO CALCULATE IT
       #$XLSXNext();
       if ShowTitle;
          #$XLSXNull();
       endif;
       #$XLSXChar('Averages:':'S_Bold');
       #$XLSXForm('average('+#$XLSXCell('VR:'+%char(count)+':1')+')':'S_Num');
       #$XLSXForm('average('+#$XLSXCell('VR:'+%char(count)+':1')+')':'S_Num');
       #$XLSXForm('average('+#$XLSXCell('VR:'+%char(count)+':1')+')':'S_Num');
       #$XLSXForm('average('+#$XLSXCell('VR:'+%char(count)+':1')+')':'S_Num');
       #$XLSXForm('average('+#$XLSXCell('R:'+%char(count)+':3:2:2')+')'
                  :'S_Num');

       // Write out total summary at the bottom
       #$XLSXNext();
       #$XLSXNext();
       if ShowTitle;
          #$XLSXNull();
       endif;
       #$XLSXChar('Quarter ' + %char(Quarter) + ' Totals':'S_Title':2);
       #$XLSXNext();
       if ShowTitle;
          #$XLSXNull();
       endif;
       #$XLSXChar('Total Sales:':'S_Bold');
       #$XLSXForm(SalesTotalLoc:'S_Num');
       #$XLSXNext();
       if ShowTitle;
          #$XLSXNull();
       endif;
       #$XLSXChar('Monthly Averages:':'S_Bold');
       #$XLSXForm(AverageLoc:'S_Num');

       // Close the open XLS File
       #$XLSXClose();

       *inlr = *on;
       return;

