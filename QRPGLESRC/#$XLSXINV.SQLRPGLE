       // static SQL statements to create and populate temp file for #$XLSXINV

     D #$XLSXINV       PR                  EXTPGM('#$XLSXINV')
     D   OLIB                        10
     D #$XLSXINV       Pi
     D   OLIB                        10
     D sqlstm          s           1000    VARYING

       //Set SQL options
        exec sql SET OPTION commit=*none;

       // Create or replace the table
       sqlstm='create or replace table ' + %trim(olib) + '/#$XLSXInv ( +
                      ITEM char(10), +
                      DESC varchar(30), +
                      SETUP dec(8,0), +
                      QTYOH dec(7,2), +
                      PRICE dec(9,2) +
                      ) rcdfmt #$XLSXInvR';
       exec sql execute immediate :sqlstm;

      //Update description for SQL table
       sqlstm='LABEL on TABLE ' + %trim(olib) + '/#$XLSXinv is +
                       ''Test Data for #$XLSXT1-3''';
       exec sql execute immediate :sqlstm;

      //Update Column Heading for SQL table
       sqlstm='LABEL on column ' + %trim(olib) + '/#$XLSXinv ( +
           ITEM   IS ''Item'', +
           DESC   IS ''Item Description'', +
           SETUP  IS ''Setup Date'', +
           QTYOH  IS ''Qty on Hand'', +
           PRICE  IS ''Price'')';
       exec sql execute immediate :sqlstm;

      //Update Column Text for SQL table
       sqlstm='LABEL on column ' + %trim(olib) + '/#$XLSXinv ( +
           ITEM   TEXT IS ''Item'', +
           DESC   TEXT IS ''Item Description'', +
           SETUP  TEXT IS ''Setup Date'', +
           QTYOH  TEXT IS ''Qty on Hand'', +
           PRICE  TEXT IS ''Price'')';
       exec sql execute immediate :sqlstm;

       // add items to the table
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXinv +
               values(''WIDGET'', ''BASE WIDGET'', 19950621, 150.00, 100.00)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXinv values( +
              ''WIDGET-B'', ''LIGHT BLUE WIDGET'', 20050413, 12.00, 123.99)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXinv +
               values(''WIDGET-R'', ''RED WIDGET'', 20131130, 13.00, 125.75)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXinv +
               values(''WIDGET-H'', ''WIDGET HOLDER'', 20200315, 12.00, 15.99)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXinv +
               values(''PAINT-B'', ''LIGHT BLUE PAINT'', 20130712, 12.56, 0)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXinv +
               values(''PAINT-R'', ''RED PAINT'', 20191013, 13.25, 0)';

       *inlr = *on;
       return;
