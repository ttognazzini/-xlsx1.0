       // static SQL statements to create and populate temp file for #$XLSXT9

     D #$XLSXINV       PR                  EXTPGM('#$XLSXINV')
     D   OLIB                        10
     D #$XLSXINV       Pi
     D   OLIB                        10
     D sqlstm          s           1000    VARYING

       //Set SQL options
        exec sql SET OPTION commit=*none;

       // Create or replace the table
       sqlstm='create or replace table ' + %trim(olib) + '/#$XLSXE9PF ( +
           TPSKU  dec(9,0) NOT NULL PRIMARY KEY +
                  GENERATED ALWAYS AS IDENTITY +
                     (START WITH 500 INCREMENT BY 1 CYCLE), +
           TPDESC varchar(30) NOt NULL, +
           TPYEAR dec(4,0), +
           TPSD01 dec(9,2), +
           TPSD02 dec(9,2), +
           TPSD03 dec(9,2), +
           TPSD04 dec(9,2), +
           TPSD05 dec(9,2), +
           TPSD06 dec(9,2), +
           TPSD07 dec(9,2), +
           TPSD08 dec(9,2), +
           TPSD09 dec(9,2), +
           TPSD10 dec(9,2), +
           TPSD11 dec(9,2), +
           TPSD12 dec(9,2) )';
       exec sql execute immediate :sqlstm;

      //Update description for SQL table
       sqlstm='label on table ' + %trim(olib) + '/#$XLSXE9PF is +
           ''Test Data for #$xlsxt9''';
       exec sql execute immediate :sqlstm;

      //Update Column Heading for SQL table
       sqlstm='label on column ' + %trim(olib) + '/#$XLSXE9PF ( +
           TPSKU  IS ''Item SKU'', +
           TPDESC IS ''Item Description'', +
           TPYEAR IS ''Sales Year'', +
           TPSD01 IS ''January Sales'', +
           TPSD02 IS ''February Sales'', +
           TPSD03 IS ''March Sales'', +
           TPSD04 IS ''April Sales'', +
           TPSD05 IS ''May Sales'', +
           TPSD06 IS ''June Sales'', +
           TPSD07 IS ''July Sales'', +
           TPSD08 IS ''August Sales'', +
           TPSD09 IS ''September Sales'', +
           TPSD10 IS ''October Sales'', +
           TPSD11 IS ''November Sales'', +
           TPSD12 IS ''December Sales'')';
       exec sql execute immediate :sqlstm;

      //Update Column Text for SQL table
       sqlstm='label on column ' + %trim(olib) + '/#$XLSXE9PF ( +
           TPSKU  TEXT IS ''Item SKU'', +
           TPDESC TEXT IS ''Item Description'', +
           TPYEAR TEXT IS ''Sales Year'', +
           TPSD01 TEXT IS ''January Sales'', +
           TPSD02 TEXT IS ''February Sales'', +
           TPSD03 TEXT IS ''March Sales'', +
           TPSD04 TEXT IS ''April Sales'', +
           TPSD05 TEXT IS ''May Sales'', +
           TPSD06 TEXT IS ''June Sales'', +
           TPSD07 TEXT IS ''July Sales'', +
           TPSD08 TEXT IS ''August Sales'', +
           TPSD09 TEXT IS ''September Sales'', +
           TPSD10 TEXT IS ''October Sales'', +
           TPSD11 TEXT IS ''November Sales'', +
           TPSD12 TEXT IS ''December Sales'')';
       exec sql execute immediate :sqlstm;

       // add 4 records to the table
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXE9PF (tpdesc,tpyear,+
                       tpsd01,tpsd02,tpsd03,tpsd04,tpsd05,tpsd06,tpsd07,tpsd08,+
                       tpsd09,tpsd10,tpsd11,tpsd12) +
               values(''Plain Widget'',2021, +
               1234,2234,3234,4234,5234,6234,7234,8234,9234,6543,5897,5897)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXE9PF (tpdesc,tpyear,+
                       tpsd01,tpsd02,tpsd03,tpsd04,tpsd05,tpsd06,tpsd07,tpsd08,+
                       tpsd09,tpsd10,tpsd11,tpsd12) +
               values(''Green Widget'',2021, +
               1234,2234,3234,4234,5234,6234,7234,8234,9234,2654,3197,2765)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXE9PF (tpdesc,tpyear,+
                       tpsd01,tpsd02,tpsd03,tpsd04,tpsd05,tpsd06,tpsd07,tpsd08,+
                       tpsd09,tpsd10,tpsd11,tpsd12) +
               values(''Yellow Widget'',2021,+
               1234,2234,3234,4234,5234,6234,7234,8234,9234,3564,2493,3195)';
       exec sql execute immediate :sqlstm;
       sqlstm='insert into ' + %trim(olib) + '/#$XLSXE9PF (tpdesc,tpyear,+
                       tpsd01,tpsd02,tpsd03,tpsd04,tpsd05,tpsd06,tpsd07,tpsd08,+
                       tpsd09,tpsd10,tpsd11,tpsd12) +
               values(''Brown Widget'',2021,+
                1234,2234,3234,4234,5234,6234,7234,8234,9234,1684,1296,1864)';
       exec sql execute immediate :sqlstm;

       *inlr = *on;
       return;
