     H DATEDIT(*YMD) OPTION(*SRCSTMT:*NODEBUGIO:*NOSHOWCPY) DEBUG INDENT('| ')
     H DFTACTGRP(*NO) BNDDIR('#$XLSX1.0/#$XLSX')
     F*
     F* #$XLSX Test big files
     D*
     D EOR             s              2a   inz( x'0D25' )
     D col             s              5p 0
     D row             s              5p 0
     D teststring      s            200     inz('12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980+
     D                                           12345678901234567980')
     D*
     D defaultPath     DS                  dtaara('#$XLSX/#$XLSXTEMP')
     D   path                  1    100
     D*
     D/INCLUDE #$XLSX1.0/QRPGLESRC,#$XLSX_H
     D*
     C******************************************************************
     C*
     C                   MOVE      *DATE         #DATE             8 0
     C                   TIME                    #TIME             6 0
     C*
     C* Get default path from data area
     C                   In        defaultPath
     C*

       // CREATE XLS FILE IN THE IFS - MUST BE DONE BEFORE CREATING STYLES
       // TODO change path to file, was /Email/Tmp/..
          #$XLSXOpen('OutputName:'+%trim(path)+'/#$XLSXTS2.xlsx'
                   : 'Buffering:1');
       //          : 'Debug:*On'

       // SETUP STYLES
          #$XLSXStyle('name:TITLE'
                    : 'PointSize:18'
                    : 'BoldWeight:BOLD');
          #$XLSXStyle('name:HDR'
                    : 'WrapText:YES'
                    : 'Alignment:CENTER'
                    : 'BoldWeight:BOLD');
          #$XLSXStyle('name:WRAP'
                    : 'WrapText:YES');

          exsr addbig;
          exsr addcol;

       // Close the open XLS File
          #$XLSXClose();

          *inlr=*on;
          RETURN;

       // ***************************************************************
          begsr addbig;

       // CREATE A NEW SHEET(TAB)
          #$XLSXWkSh('SheetName:Lots of Data'
                   : 'FreezeRows:4'
                   : 'ColumnWidth: 1:10'
                   : 'ColumnWidth: 2:10'
                   : 'ColumnWidth: 3:10'
                   : 'ColumnWidth: 4:10'
                   : 'ColumnWidth: 5:10'
                   : 'ColumnWidth: 6:10'
                   : 'ColumnWidth: 7:10'
                   : 'ColumnWidth: 8:10'
                   : 'ColumnWidth: 9:10'
                   : 'ColumnWidth:10:12'
                   : 'ColumnWidth:11:13'
                   : 'ColumnWidth:12:14'
                   : 'ColumnWidth:13:15'
                   : 'ColumnWidth:14:16'
                   : 'ColumnWidth:15:17'
                   : 'ColumnWidth:16:18'
                   : 'ColumnWidth:17:19'
                   : 'ColumnWidth:18:20'
                   : 'ColumnWidth:19:21'
                   : 'ColumnWidth:20:22'
                   : 'ColumnWidth:21:23'
                   : 'ColumnWidth:22:24'
                   : 'ColumnWidth:23:25'
                   : 'ColumnWidth:24:26'
                   : 'ColumnWidth:25:27'
                   : 'ColumnWidth:26:28'
                   : 'ColumnWidth:27:29'
                   : 'ColumnWidth:28:30'
                   : 'ColumnWidth:29:31'
                   : 'ColumnWidth:30:32'
                   : 'ColumnWidth:31:33'
                   : 'ColumnWidth:32:34'
                   : 'ColumnWidth:33:35'
                   : 'ColumnWidth:34:36'
                   : 'ColumnWidth:35:37'
                   : 'ColumnWidth:36:38'
                   : 'ColumnWidth:37:39'
                   : 'ColumnWidth:38:40'
                   : 'ColumnWidth:39:41'
                   : 'ColumnWidth:40:42'
                   : 'ColumnWidth:41:43'
                   : 'ColumnWidth:42:44'
                   : 'ColumnWidth:43:45'
                   : 'ColumnWidth:44:46'
                   : 'ColumnWidth:45:47'
                   : 'ColumnWidth:46:48'
                   : 'ColumnWidth:47:49'
                   : 'ColumnWidth:48:50'
                   : 'ColumnWidth:49:51'
                   : 'ColumnWidth:50:52');

       // ADD HEADER RECORD 1 AND 2
          #$XLSXCHAR('#$XLSXTS2 - Test a large File':'TITLE':5);
          #$XLSXCHAR('#$XLSXTS');
          #$XLSXCHAR(%EDITW(#DATE:'    /  / 0'));
          #$XLSXCHAR(%EDITW(#TIME:'  :  : 0'));

       // ADD HEADER RECORD 1 AND 2
          #$XLSXNEXT();
          #$XLSXCHAR('There was an issue with large files, this +
                      program is designed to test it.');
          #$XLSXNEXT();
          #$XLSXNEXT();
          for col=1 to 50;
              #$XLSXCHAR('Column ' + %char(col):'hdr');
          endfor;

       // test using longer strings to see if that causes the error
          for row=1 to 2000;
              #$XLSXNEXT();
              for col=1 to 50;
                  if %rem(row:4)=1;
                     #$XLSXCHAR(%subst(TestString:1:col):'wrap');
                  elseif %rem(row:4)=2;
                     #$XLSXCHAR(%subst(TestString:1:col) + eor +
                                %subst(TestString:1:col):'wrap');
                  elseif %rem(row:4)=3;
                     #$XLSXCHAR(%subst(TestString:1:col) + eor +
                                %subst(TestString:1:col) + eor +
                                %subst(TestString:1:col):'wrap');
                  else;
                     #$XLSXCHAR(%subst(TestString:1:col) + eor +
                                %subst(TestString:1:col) + eor +
                                %subst(TestString:1:col) + eor +
                                %subst(TestString:1:col):'wrap');
                  endif;
              endfor;
          endfor;

       // add like 10,000 rows of 50 columns of garabage
       // #$XLSXNEXT();
       // for row=1 to 10000;
       //     #$XLSXNEXT();
       //     for col=1 to 50;
       //         #$XLSXCHAR(#$XLSXCell());
       //     endfor;
       // endfor;

          endsr;
       // ***************************************************************
          begsr addcol;

       // CREATE A NEW SHEET(TAB)
          #$XLSXWkSh('SheetName:Lots of Columns');

       // ADD SHEET INFORMATION
          #$XLSXCHAR('Tests using a lot of columns':'TITLE':8);

          #$XLSXNEXT();
          #$XLSXCHAR('There was an issue with using a bunch +
                      of columns, this just tests that it is fixed.':*omit:8);
          #$XLSXNEXT();
          #$XLSXCHAR('After fixing that issue I added an error for adding +
                      data to a cell past the max of 16384.':*omit:8);
          #$XLSXNEXT();
          #$XLSXCHAR('16384 is the max columns allowed in a sheet in +
                      excel. Now it sends an inquiry message':*omit:8);
          #$XLSXNEXT();
          #$XLSXCHAR('and automatically wraps to the next row.':*omit:8);
          #$XLSXNEXT();
          #$XLSXCHAR('This was discovered because I forgot to put a +
                      #$XLSNext function before the start of a row':*omit:8);
          #$XLSXNEXT();
          #$XLSXCHAR('so it just kept moving out. I figured it was +
                      bound to happen to someone else at some point':*omit:8);
          #$XLSXNEXT();
          #$XLSXCHAR('so I went ahead and handled it.':*omit:8);

       // for loop to add 17,000 columns adding character data
          #$XLSXNEXT();
          for col = 1 to 17000;
              #$XLSXCHAR(#$XLSXCell());
          endfor;

       // for loop to add 17,000 columns adding numeric data
          #$XLSXNEXT();
          for col = 1 to 17000;
              #$XLSXNumr(col);
          endfor;

          endsr;
