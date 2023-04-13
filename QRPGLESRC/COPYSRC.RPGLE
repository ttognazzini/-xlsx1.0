**free
   Ctl-Opt DftActGrp(*NO) Option(*NoDebugIO:*SrcStmt);

// defaults
   dcl-s root char(10) inz('/#$XLSX1.0');
   dcl-s olib char(10) inz('#$XLSX1.0');

// copy h files
   copy('H         ':'CRC32     ':'h    ');
   copy('H         ':'CRYPT     ':'h    ');
   copy('H         ':'DEFLATE   ':'h    ');
   copy('H         ':'INFFAST   ':'h    ');
   copy('H         ':'INFFIXED  ':'h    ');
   copy('H         ':'INFLATE   ':'h    ');
   copy('H         ':'INFTREES  ':'h    ');
   copy('H         ':'IOAPI     ':'h    ');
   copy('H         ':'TREES     ':'h    ');
   copy('H         ':'UNZIP     ':'h    ');
   copy('H         ':'ZCONF     ':'h    ');
   copy('H         ':'ZCONF.IN  ':'h    ');
   copy('H         ':'ZIP       ':'h    ');
   copy('H         ':'ZLIB      ':'h    ');
   copy('H         ':'ZUTIL     ':'h    ');

// copy qclsrc files
   copy('QCLSRC    ':'#$XLSXMSG ':'CLLE ');
   copy('QCLSRC    ':'#$ZIPMSG  ':'CLLE ');
   copy('QCLSRC    ':'DSPZIP    ':'CLLE ');
   copy('QCLSRC    ':'IFS2SRC   ':'CLLE ');
   copy('QCLSRC    ':'LICENSE   ':'MD   ');
   copy('QCLSRC    ':'MAKE      ':'CLLE ');
   copy('QCLSRC    ':'MAKESAVE  ':'REXX ');
   copy('QCLSRC    ':'README    ':'MD   ');
   copy('QCLSRC    ':'RTVIFSA   ':'CLLE ');
   copy('QCLSRC    ':'RTVIFSAT  ':'CLLE ');
   copy('QCLSRC    ':'SRC2IFS   ':'CLLE ');
   copy('QCLSRC    ':'UNZIP     ':'CLLE ');
   copy('QCLSRC    ':'ZIP       ':'CLLE ');

// copy qcmdsrc files
   copy('QCMDSRC   ':'DSPZIP    ':'CMD  ');
   copy('QCMDSRC   ':'IFS2SRC   ':'CMD  ');
   copy('QCMDSRC   ':'RTVIFSA   ':'CMD  ');
   copy('QCMDSRC   ':'SRC2IFS   ':'CMD  ');
   copy('QCMDSRC   ':'UNZIP     ':'CMD  ');
   copy('QCMDSRC   ':'ZIP       ':'CMD  ');

// copy qcsrc files
   copy('QCSRC     ':'ADLER32   ':'C    ');
   copy('QCSRC     ':'CHANGELOG ':'TXT  ');
   copy('QCSRC     ':'COMPRESS  ':'C    ');
   copy('QCSRC     ':'CRC32     ':'C    ');
   copy('QCSRC     ':'DEFLATE   ':'C    ');
   copy('QCSRC     ':'EBCDIC    ':'C    ');
   copy('QCSRC     ':'EXAMPLE   ':'C    ');
   copy('QCSRC     ':'FAQ       ':'TXT  ');
   copy('QCSRC     ':'GZIO      ':'C    ');
   copy('QCSRC     ':'INDEX     ':'TXT  ');
   copy('QCSRC     ':'INFBACK   ':'C    ');
   copy('QCSRC     ':'INFFAST   ':'C    ');
   copy('QCSRC     ':'INFLATE   ':'C    ');
   copy('QCSRC     ':'INFTREES  ':'C    ');
   copy('QCSRC     ':'IOAPI     ':'C    ');
   copy('QCSRC     ':'MINIUNZ   ':'C    ');
   copy('QCSRC     ':'MINIZIP   ':'C    ');
   copy('QCSRC     ':'README    ':'TXT  ');
   copy('QCSRC     ':'TREES     ':'C    ');
   copy('QCSRC     ':'UNCOMPR   ':'C    ');
   copy('QCSRC     ':'UNZIP     ':'C    ');
   copy('QCSRC     ':'ZIP       ':'C    ');
   copy('QCSRC     ':'ZUTIL     ':'C    ');

// copy qpnlsrc files
   copy('QPNLSRC   ':'DSPZIP    ':'PNLGRP');
   copy('QPNLSRC   ':'IFS2SRC   ':'PNLGRP');
   copy('QPNLSRC   ':'RTVIFSA   ':'PNLGRP');
   copy('QPNLSRC   ':'SRC2IFS   ':'PNLGRP');
   copy('QPNLSRC   ':'UNZIP     ':'PNLGRP');
   copy('QPNLSRC   ':'ZIP       ':'PNLGRP');

// copy QRPGLESRC files
   copy('QRPGLESRC ':'#$ICONV_H ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSX    ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSX_H  ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXARG ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXE1  ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXE1F ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXE2  ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXE3  ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXE9  ':'SQLRPGLE  ');
   copy('QRPGLESRC ':'#$XLSXE9PF':'SQLRPGLE  ');
   copy('QRPGLESRC ':'#$XLSXINV ':'SQLRPGLE  ');
   copy('QRPGLESRC ':'#$XLSXLARG':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXTS  ':'SQLRPGLE  ');
   copy('QRPGLESRC ':'#$XLSXTS2 ':'RPGLE     ');
   copy('QRPGLESRC ':'#$XLSXTS3 ':'RPGLE     ');
   copy('QRPGLESRC ':'#$ZIP     ':'RPGLE     ');
   copy('QRPGLESRC ':'#$ZIP_H   ':'RPGLE     ');
   copy('QRPGLESRC ':'#$ZIPTS   ':'RPGLE     ');
   copy('QRPGLESRC ':'#$ZIPTS2  ':'RPGLE     ');
   copy('QRPGLESRC ':'COPYIFS   ':'RPGLE     ');
   copy('QRPGLESRC ':'COPYSRC   ':'RPGLE     ');
   copy('QRPGLESRC ':'IFS2SRC2  ':'RPGLE     ');
   copy('QRPGLESRC ':'PGMSTSDS  ':'RPGLE     ');
   copy('QRPGLESRC ':'RTVIFSA2  ':'RPGLE     ');
   copy('QRPGLESRC ':'SRC2IFS2  ':'RPGLE     ');
   copy('QRPGLESRC ':'ZIP.INC   ':'RPGLE     ');
   copy('QRPGLESRC ':'ZIPTEST   ':'RPGLE     ');
   copy('QRPGLESRC ':'ZIPTEST2  ':'RPGLE     ');
   copy('QRPGLESRC ':'ZLIB.INC  ':'RPGLE     ');

// copy qsrvsrc files
   copy('QSRVSRC   ':'#$XLSX    ':'BND       ');
   copy('QSRVSRC   ':'#$ZIP     ':'BND       ');

// end program
   eval *inlr=*on;
   return;


//***************************************************************
// Copy - copy a source file to the ifs
//     €
//   Input: member = name of the source member
//          type   = source type
//          text   = member text
//     €
//   Output: nothing
//     €
//***************************************************************
   dcl-proc copy;
   dcl-pi *n;
      file char(10) const;
      mbr  char(10) const;
      type char(10) const;
   end-pi;

   cmd('SRC2IFS SRCFILE(' +%trim(olib) + '/' + %trim(file) + ') +
                MBR(' +%trim(mbr) + ') +
                RTEPATH(''' + %trim(root) + ''')');

   end-proc;

//***************************************************************
// CMD - This proceudre runs a command.
//     €
//   Input: #$CMD = Command to run.
//   Output: nothing
//     €
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

   Qcmdexc(%trim(cmd):%len(%trim(cmd)));

   end-proc;
//****************************************************************
// upify - Convert to all upper case
// Converts lowercase characters to uppercase                        ‚
// Only€converts english characters.                                 ‚
//   ‚ €                                                             ‚
//   ‚ €  INPUT:  data = Field to convert to all capitals            ‚
//   ‚ €RETURNS:  The data field in all capitals                     ‚
//   ‚ €                                                             ‚
// Examples EVAL    TEXT=#$UPFIY(TEXT)                               ‚
//   ‚ €                                                             ‚
//****************************************************************
   dcl-proc upify;
   dcl-pi *n varchar(32768);
      data varchar(32768) const;
   end-pi;

   dcl-c Lo 'abcdefghijklmnopqrstuvwxyz';
   dcl-c Up 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

   return %xlate(up:lo:data);

   end-proc;

//****************************************************************
// lowfy - Convert to all lowercase
//   ‚ €                                                             ‚
//   ‚ €  INPUT:  data = Field to convert to all lower case          ‚
//   ‚ €RETURNS:  The data field in all lower case                   ‚
//   ‚ €                                                             ‚
// Examples EVAL    TEXT=LOWFY(TEXT)                               ‚
//   ‚ €                                                             ‚
//****************************************************************
   dcl-proc lowfy;
   dcl-pi *n varchar(32768);
      data varchar(32768) const;
   end-pi;

   dcl-c Lo 'abcdefghijklmnopqrstuvwxyz';
   dcl-c Up 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

      return %xlate(lo:up:data);

   end-proc;
