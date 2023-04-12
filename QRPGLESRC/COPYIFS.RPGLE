**free
   Ctl-Opt DFTACTGRP(*NO) Option(*NoDebugIO:*SrcStmt);

// defaults
   dcl-s root char(10) inz('#$XLSX');
   dcl-s olib char(10) inz('#$XLSX1.0');
   dcl-s slib char(10) inz('#$XLSX1.0');

// program status data structure
   dcl-ds *n psds;
     errmsgid char(7) pos(42); // Exception type
   end-ds;

// setup source files if they do not exist
   CMD('CRTSRCPF '+%TRIM(OLIB)+'/H RCDLEN(150)');
   CMD('CRTSRCPF '+%TRIM(OLIB)+'/QCLSRC RCDLEN(112)');
   CMD('CRTSRCPF '+%TRIM(OLIB)+'/QCMDSRC RCDLEN(112)');
   CMD('CRTSRCPF '+%TRIM(OLIB)+'/QCSRC RCDLEN(150)');
   CMD('CRTSRCPF '+%TRIM(OLIB)+'/QPNLSRC RCDLEN(112)');
   CMD('CRTSRCPF '+%TRIM(OLIB)+'/QRPGLESRC RCDLEN(112)');
   CMD('CRTSRCPF '+%TRIM(OLIB)+'/QSRVSRC RCDLEN(112)');

// copy h files                        1         2         3         4         5
// copy('1234567890':'1234567890':'12345678901234567890123456789012345678901234567890');
   copy('CRC32     ':'H         ':'TABLES FOR RAPID CRC CALCULATION                  ');
   copy('CRYPT     ':'H         ':'BASE CODE FOR CRYPT/UNCRYPT ZIPFILE               ');
   copy('DEFLATE   ':'H         ':'INTERNAL COMPRESSION STATE                        ');
   copy('INFFAST   ':'H         ':'HEADER TO USE INFFAST.C                           ');
   copy('INFFIXED  ':'H         ':'TABLE FOR DECODING FIXED CODES                    ');
   copy('INFLATE   ':'H         ':'INTERNAL INFLATE STATE DEFINITION                 ');
   copy('INFTREES  ':'H         ':'HEADER TO USE INFTREES.C                          ');
   copy('IOAPI     ':'H         ':'IO BASE FUNCTION HEADER FOR COMPRESS/UNCOMP. .ZIP ');
   copy('TREES     ':'H         ':'OUTPUT DEFLATED DATA USING HUFFMAN CODING         ');
   copy('UNZIP     ':'H         ':'IO FOR UNCOMPRESS .ZIP FILES USING ZLIB           ');
   copy('ZCONF     ':'H         ':'CONFIGURATION OF THE ZLIB COMPRESSION LIBRARY     ');
   copy('ZCONF.IN  ':'H         ':'CONFIGURATION OF THE ZLIB COMPRESSION LIBRARY     ');
   copy('ZIP       ':'H         ':'IO ON .ZIP FILES USING ZLIB                       ');
   copy('ZLIB      ':'H         ':'INTERFACE OF THE ''ZLIB'' LIBRARY                   ');
   copy('ZUTIL     ':'H         ':'INTERNAL INTERFACE AND CONFIGURATION OF ZLIB      ');

// copy QCLSRC
   copy('#$XLSXMSG ':'CLLE      ':'CREATE MESSAGE FILE FOR THE #$XLSX SERVICE PGM 2.0');
   copy('#$ZIPMSG  ':'CLLE      ':'CREATE MESSAGE FILE FOR THE #$ZIP SERVICE PGM     ');
   copy('DSPZIP    ':'CLLE      ':'DISPLAY ZIP FILE                                  ');
   copy('IFS2SRC   ':'CLLE      ':'COPY SOURCE MEMBER FROM IFS FILE                  ');
   copy('LICENSE   ':'MD        ':'LICENSE FROM CHRIS HIRD 2017                      ');
   copy('MAKE      ':'CLLE      ':'REBUILD THE FULL SYSTEM                           ');
   copy('MAKESAVE  ':'REXX      ':'OLD REXX PROGRAM FOR BUILD OF ORIGINAL ZLIB PORT  ');
   copy('README    ':'MD        ':'README FROM CHRIS HIRD                            ');
   copy('RTVIFSA   ':'CLLE      ':'RETRIEVE IFS FILE ATTRIBUTES                      ');
   copy('RTVIFSAT  ':'CLLE      ':'RETRIEVE IFS FILE ATTRIBUTES - TEST               ');
   copy('SRC2IFS   ':'CLLE      ':'COPY SOURCE MEMBER TO IFS FILE                    ');
   copy('UNZIP     ':'CLLE      ':'UNPACK ZIPPED FILE                                ');
   copy('ZIP       ':'CLLE      ':'ZIP (COMPRESS) FILE                               ');

// copy QCMDSRC
   copy('DSPZIP    ':'CMD       ':'DISPLAY ZIPPED FILE                               ');
   copy('IFS2SRC   ':'CMD       ':'COPY SOURCE MEMBER FROM IFS FILE                  ');
   copy('RTVIFSA   ':'CMD       ':'RETRIEVE IFS FILE ATTRIBUTES                      ');
   copy('SRC2IFS   ':'CMD       ':'COPY SOURCE MEMBER TO IFS FILE                    ');
   copy('UNZIP     ':'CMD       ':'UNPACK ZIPPED FILE                                ');
   copy('ZIP       ':'CMD       ':'ZIP (COMPRESS) FILE                               ');

// copy QCSRC
   copy('ADLER32   ':'C         ':'COMPUTE THE ADLER-32 CHECKSUM OF A DATA STREAM    ');
   copy('CHANGELOG ':'TXT       ':'CHANGELOG FILE FOR ZLIB                           ');
   copy('COMPRESS  ':'C         ':'COMPRESS A MEMORY BUFFER                          ');
   copy('CRC32     ':'C         ':'COMPUTE THE CRC-32 OF A DATA STREAM               ');
   copy('DEFLATE   ':'C         ':'COMPRESS DATA USING THE DEFLATION ALGORITHM       ');
   copy('EBCDIC    ':'C         ':'ASCII/EBCDIC CONVERSIONS                          ');
   copy('EXAMPLE   ':'C         ':'USAGE EXAMPLE OF THE ZLIB COMPRESSION LIBRARY     ');
   copy('FAQ       ':'TXT       ':'FREQUENTLY ASKED QUESTIONS ABOUT ZLIB             ');
   copy('GZIO      ':'C         ':'IO ON .GZ FILES                                   ');
   copy('INDEX     ':'TXT       ':'INDEX OF SOURCE MEMBERS FOR ORIGINAL ZLIB         ');
   copy('INFBACK   ':'C         ':'INFLATE USING A CALL-BACK INTERFACE               ');
   copy('INFFAST   ':'C         ':'FAST DECODING                                     ');
   copy('INFLATE   ':'C         ':'ZLIB DECOMPRESSION                                ');
   copy('INFTREES  ':'C         ':'GENERATE HUFFMAN TREES FOR EFFICIENT DECODING     ');
   copy('IOAPI     ':'C         ':'IO BASE FUNCTION HEADER FOR COMPRESS/UNCOMP. .ZIP ');
   copy('MINIUNZ   ':'C         ':'MINI UNZIP PROGRAM                                ');
   copy('MINIZIP   ':'C         ':'MINI ZIP PROGRAM                                  ');
   copy('README    ':'TXT       ':'ZLIB DATA COMPRESSION LIBRARY                     ');
   copy('TREES     ':'C         ':'OUTPUT DEFLATED DATA USING HUFFMAN CODING         ');
   copy('UNCOMPR   ':'C         ':'DECOMPRESS A MEMORY BUFFER                        ');
   copy('UNZIP     ':'C         ':'IO FOR UNCOMPRESS .ZIP FILES USING ZLIB           ');
   copy('ZIP       ':'C         ':'IO ON .ZIP FILES USING ZLIB                       ');
   copy('ZUTIL     ':'C         ':'TARGET DEPENDENT UTILITY FUNCTIONS FOR ZLIB       ');

// copy QPNLSRC
   copy('DSPZIP    ':'PNLGRP    ':'DSPZIP COMMAND HELP PANEL                         ');
   copy('IFS2SRC   ':'PNLGRP    ':'COPY SOURCE MEMBER FROM IFS FILE                  ');
   copy('RTVIFSA   ':'PNLGRP    ':'RETRIEVE IFS FILE ATTRIBUTE                       ');
   copy('SRC2IFS   ':'PNLGRP    ':'COPY SOURCE MEMBER TO IFS FILE                    ');
   copy('UNZIP     ':'PNLGRP    ':'UNZIP COMMAND HELP PANEL                          ');
   copy('ZIP       ':'PNLGRP    ':'ZIP COMMAND HELP PANEL                            ');

// copy QRPGLESRC
   copy('#$ICONV_H ':'RPGLE     ':'Copy book for ICONV API                           ');
   copy('#$XLSX    ':'RPGLE     ':'Create Excel File - Service Program               ');
   copy('#$XLSX_H  ':'RPGLE     ':'Create Pretty Excel File - Include                ');
   copy('#$XLSXARG ':'RPGLE     ':'Create Excel File - Copybook - Args               ');
   copy('#$XLSXE1  ':'RPGLE     ':'#$XLSX Example Hello World - Fixed Format         ');
   copy('#$XLSXE1F ':'RPGLE     ':'#$XLSX Example Hello World - Free Format          ');
   copy('#$XLSXE2  ':'RPGLE     ':'#$XLSX Example Adding More Data                   ');
   copy('#$XLSXE3  ':'RPGLE     ':'#$XLSX Example Adding Styles                      ');
   copy('#$XLSXE9  ':'SQLRPGLE  ':'#$XLSX Example Using Relative Positioned Formulas ');
   copy('#$XLSXE9PF':'SQLRPGLE  ':'SQL to Create and Populate Temp File for #$XLSXT9 ');
   copy('#$XLSXINV ':'SQLRPGLE  ':'SQL to Create and Populate Test File for #$XLSINV ');
   copy('#$XLSXLARG':'RPGLE     ':'Create Excel File - Copybook - LoadArgs           ');
   copy('#$XLSXTS  ':'SQLRPGLE  ':'#$XLSX Test Every Feature                         ');
   copy('#$XLSXTS2 ':'RPGLE     ':'#$XLSX Test big files                             ');
   copy('#$XLSXTS3 ':'RPGLE     ':'#$XLSX Test Small files                           ');
   copy('#$ZIP     ':'RPGLE     ':'#$Zip Service Program                             ');
   copy('#$ZIP_H   ':'RPGLE     ':'Include file for #$Zip service Program            ');
   copy('#$ZIPTS   ':'RPGLE     ':'Test #$Zip service program                        ');
   copy('#$ZIPTS2  ':'RPGLE     ':'Test #$Zip service program                        ');
   copy('COPYIFS   ':'RPGLE     ':'Copy all source from the IFS                      ');
   copy('COPYSRC   ':'RPGLE     ':'Copy all source to the IFS                        ');
   copy('IFS2SRC2  ':'RPGLE     ':'Get the extension from a path                     ');
   copy('RTVIFSA2  ':'RPGLE     ':'Retrieve IFS File Attributes                      ');
   copy('SRC2IFS2  ':'RPGLE     ':'lowercase the file extensions                     ');
   copy('ZIP.INC   ':'RPGLE     ':'Include for ZIP Prototypes and Costants           ');
   copy('ZIPTEST   ':'RPGLE     ':'Example Using ZIP service program                 ');
   copy('ZIPTEST2  ':'RPGLE     ':'Example Using ZIP with inner folder and file      ');
   copy('ZLIB.INC  ':'RPGLE     ':'Include for ZLIB Prototypes and Costants          ');

// copy QSRVSRC
   copy('#$XLSX    ':'BND       ':'Binder Source for the #$XLSX Service Program      ');
   copy('#$ZIP     ':'BND       ':'Binder Source for the #$ZIP Service Program       ');

// BUILD THE MAKE PROGRAM AND RUN IT
   CMD('CRTBNDCL '+%TRIM(OLIB)+'/MAKE SRCFILE('+%TRIM(SLIB)+'/QCLSRC)');
   CMD('CALL MAKE');

// end program
   eval *inlr=*on;
   return;


//***************************************************************
// Copy - copy a source file
//     
//   Input: member = name of the source member
//          type   = source type
//          text   = member text
//     
//   Output: nothing
//     
//***************************************************************
   dcl-proc copy;
   dcl-pi *n;
      mbr  char(10) const;
      type char(10) const;
      text char(50) const;
   end-pi;

   dcl-s ifsPath char(100);
   dcl-s srcPath char(100);
   dcl-s file char(10);

   ifsPath=%trim(root) + '/';
   srcPath='/QSYS.lib/'+%trim(olib)+'.lib/';
   file=' ';

   // add source file based on type
   if type='H';
      ifsPath=%trim(ifsPath) + 'H/' + %trim(mbr);
      ifsPath=%trim(ifsPath) + 'H.file/' +%trim(mbr) + '.mbr';
      file='H';
   elseif type='CLLE' or type='CLP' or
          type='MD  ' or type='REXX';
      ifsPath=%trim(ifsPath) + 'QCLSRC/' + %trim(mbr);
      ifsPath=%trim(ifsPath) + 'QCLSRC.file/' +%trim(mbr) + '.mbr';
      file='QCLSRC';
   elseif type='CMD';
      ifsPath=%trim(ifsPath) + 'QCMDSRC/' + %trim(mbr);
      ifsPath=%trim(ifsPath) + 'QCMDSRC.file/' +%trim(mbr) + '.mbr';
      file='QCMDSRC';
   elseif type='C';
      ifsPath=%trim(ifsPath) + 'QCSRC/' + %trim(mbr);
      ifsPath=%trim(ifsPath) + 'QCSRC.file/' +%trim(mbr) + '.mbr';
      file='QCSRC';
   elseif type='PNL';
      ifsPath=%trim(ifsPath) + 'QPNLSRC/' + %trim(mbr);
      ifsPath=%trim(ifsPath) + 'QPNLSRC.file/' +%trim(mbr) + '.mbr';
      file='QPNLSRC';
   elseif type='RPG' or type='RPGLE' or
          type='TXT' or type='SQLRPGLE';
      ifsPath=%trim(ifsPath) + 'QRPGLESRC/' + %trim(mbr);
      ifsPath=%trim(ifsPath) + 'QRPGLESRC.file/' +%trim(mbr) + '.mbr';
      file='QRPGLESRC';
   elseif type='BND';
      ifsPath=%trim(ifsPath) + 'QSRVSRC/' + %trim(mbr);
      ifsPath=%trim(ifsPath) + 'QSRVSRC.file/' +%trim(mbr) + '.mbr';
      file='QSRVSRC';
   else;
      // todo handle error
   endif;

   // copy from the IFS file to source member
   cmd('CPYFRMSTMF FROMSTMF('+%trim(ifsPath)+') +
                   TOMBR('+%trim(srcPath)+') +
                   MBROPT(*REPLACE)');

   // set source type and text
   cmd('CHGPFM FILE('+%trim(olib)+'/'+%trim(file)+') +
               MBR('+%trim(mbr)+') +
               SRCTYPE('+%trim(type)+') +
               TEXT('''+%trim(text)+''')');

   end-proc;

//***************************************************************
// CMD - This proceudre runs a command.
//     
//   Input: #$CMD = Command to run.
//   Output: nothing
//     
//***************************************************************
   dcl-proc cmd;
   dcl-pi *n;
      cmd  varchar(32768) const;
   end-pi;

   // PROTOTYPE FOR QCMDEXC
   dcl-pr Qcmdexc extpgm('QCMDEXC');
    *n char(125) options(*VarSize) CONST;
    *n packed(15: 5) const;
   end-pr;

   MONITOR;
      Qcmdexc(%trim(cmd):%len(%trim(cmd)));
   ON-ERROR;
      select;
        when errmsgid='CPF5813';
        other;
        // todo handle error here
      endsl;
   ENDMON;

   end-proc;
