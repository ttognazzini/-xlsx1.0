**Free
//**************************************************************
// #$XLSX Functions
//**************************************************************
//
// Exported Function List
//   #$XLSXOpen - Open a new Excel file
//   #$XLSXWkSh - Create a new Worksheet
//   #$XLSXChar - Add a character string to the open XLS file
//   #$XLSXNumr - Add a number to the open XLSX Sheet
//   #$XLSXDate - Add a date string to the open XLS file
//   #$XLSXYYMD - Add a date in YYYYMMDD format
//   #$XLSXMDY  - Add a date in MMDDYY format
//   #$XLSXMDYY - Add a date in MMDDYYYY format
//   #$XLSXForm - Add a Formula to the open XLS file
//   #$XLSXNull - Skips a column, but does not create the cell
//   #$XLSXNext - Moves Cursor to the start of the next row
//   #$XLSXCell - Returns cell or range relative to position
//   #$XLSXC    - Shorcut for #$XLSXCell
//   #$XLSXStyle - Shortcut to create a style
//   #$XLSXClose - Close an Existing open file
//   #$XLSXBreak - Forces a page break before the current row
//   #$XLSXGetRow- Returns the current row number
//
// Internal Function List
//   StrSheet - Sets up a worksheet so data can be added
//   EndSheet - Closes out a worksheet
//   XLSXDate - used by #$XLSXDate, #$XLSXYYMD, #$XLSXMDY and
//              #$XLSXMDYY to actually add a date
//   GetColor - Convert color codes to a color value
//   Color2RBG - Convert color codes to a HEX RBG Value
//   ValStyle - Make Sure Style Name has already been setup
//   GetStyle - Return the style number for a Style Name
//   CrtRels - tempfolder/_rels/.rels
//   CrtDocPropsApp   - tempfolder/docProps/app.xml
//   CrtDocPropsCore  - tempfolder/docProps/core.xml
//   CrtDocPropsCustom - tempfolder/docProps/custom.xml
//   CrtWorkbook   - tempfolder/xl/workbook.xml
//   CrtWorkbookRel- tempfolder/xl/_rels/workbook.xml.rels
//   CrtStyles - tempfolder/xl/styles.xml
//   CrtContents - tempfolder/[content_Types].xml
//   rtnColor - returns a formattted color
//   rtnBorderStyle returns a border style from a code
//   openf - create and open a file in the ifs
//   writef - write a record to the open file
//   CLOSEF - Closes the open file
//   upify - Convert to all upper case
//   lowfy - Convert to all lower case
//   rvl - returns a number from a character string
//   last - returns the last characters from a string
//   ColRow Returns the column and row number as a string
//   Col - Returns the character Value of column
//   Col2 - Returns the numeric value of a character column
//   cmd - run a command
//   SNDMSG - Send Message
//   ExcDate - Convert YYYYMMDD date field to Excel number date.
//   XMLESC - Escapes special characters in a string for XML
//   VDat - validates a text date
//   VNum - validates a text number
//   SplitArg - Splits a single argument into the arg DS
//   OvrSpecial - Override special values in Footer/Header text
//   AddHeader - Adds the meat of one header or footer entry.
//
//
// See #$XLXSTS for an example.
//
// To Create this program:
//  crtrpgmod  module(qtemp/#$xlsx) tgtrls(v7r1m0)
//             srcfile(#$xlsx1.0/qrpglesrc) dbgview(*all)
//  crtsrvpgm  srvpgm(#$xlsx1.0/#$xlsx) module(qtemp/#$xlsx)
//             export(*srcfile) bndsrvpgm(#$xlsx1.0/#$zip)
//             TEXT('Create Pretty Excel File') TGTRLS(V7R1M0)
//  dltmod     module(qtemp/#$xlsx)
//
//  First time only
//
//  addbnddire bnddir(#$xlsx1.0/#$xlsx) obj((#$xlsx1.0/#$xlsx *srvpgm))
//
//**************************************************************
//
// Uses Message File #$XLSXV1R0/#$XLSXV1R0
// See CL program #$XLSXMSG for the definitions.
//
// All Prototypes are stored in #$XLSXV1R0/QRGPLESRC,#$INCXLSX
//
//**************************************************************

Ctl-Opt Option(*SrcStmt : *NoDebugIO:*NoShowCpy) Indent('| ') Debug  nomain ALLOC(*TERASPACE);

/Copy #$XLSX/QRPGLESRC,#$ZIP_H

// This field is used for the memory buffer.
// In theory a larger buffer will be faster but use more memory.
Dcl-S buffer Varchar(64000);

// Style Data Structure, 1000 are stored in the workbook data structure.
Dcl-Ds Style Qualified;
  Name Char(50) Inz('');
  FillStyle Char(8) Inz('');
  FillForeground Char(8) Inz('');
  FillBackGround Char(8) Inz('');
  Color Char(8) Inz('');
  FontSize packed(3) Inz(0);
  Font Char(50) Inz('');
  FontWeight Char(1) Inz('');
  Underline Char(1) Inz('');
  StrikeOut Char(1) Inz('');
  TypeOffset Char(1) Inz('');
  Alignment Char(1) Inz('');
  DataFormat Char(50) Inz('');
  BottomBorder Char(1) Inz('');
  TopBorder Char(1) Inz('');
  RightBorder Char(1) Inz('');
  LeftBorder Char(1) Inz('');
  DiagonalBorder Char(1) Inz('');
  DiagonalOption Char(1) Inz('');
  BorderColor Char(8) Inz('');
  WrapText Char(1) Inz('');
  VAlignment Char(1) Inz('');
  Italic Char(1) Inz('');
  NumFmt packed(4) Inz(0); // Location in Styles
  FontElem packed(4) Inz(0); // "
  Fill packed(4) Inz(0); // "
  Border packed(4) Inz(0); // "
End-Ds;

// Custom Property Data structure, 30 are stored in the workbook data structure.
Dcl-Ds CustomProperty Qualified;
  Name Varchar(128) Inz('');
  Type Char(1) Inz('');
  Value Varchar(128) Inz('');
End-Ds;

// Data structure to hold all workbook properties
Dcl-Ds WorkBook Qualified;
  Status packed(1) Inz(0); // 1=open
  Sheets Char(124) dim(100) Inz('');
  SheetCount packed(4) Inz(0);
  Styles dim(1000) likeds(style);
  StyleCount packed(4) Inz(0);
  Creator Varchar(1024) Inz('#$XLSX');
  Company Varchar(1024) Inz('');
  Title Varchar(1024) Inz('');
  Subject Varchar(1024) Inz('');
  Manager Varchar(1024) Inz('');
  Tags Varchar(1024) Inz('');
  Category Varchar(1024) Inz('');
  ContentStatus Varchar(1024) Inz('');
  Comments Varchar(1024) Inz('');
  HyperLinkBase Varchar(1024) Inz('');
  CustomPCount packed(2) Inz(0);
  CustomProperties dim(30) likeds(customproperty);
  Debug ind Inz(*off);
  TempFolder Varchar(100) Inz('');
  OutputName Varchar(1024) Inz('');
  Buffering ind Inz(*on);
  Repeating ind Inz(*on);
  RepeatingColumns packed(5) dim(100) Inz(*all'0');
  RepeatingColumnsEnd packed(5) dim(100) Inz(*all'0');
  RepeatingRows packed(5) dim(100) Inz(*all'0');
  RepeatingRowsEnd packed(5) dim(100) Inz(*all'0');
  NamedRange Char(124) dim(100) Inz('');
  NamedRanges packed(4) Inz(0);
End-Ds;

// Structure for one header or footer section,
// There are 9 headers and 9 footers stored in the WorkSheet
// data structure, they are for first/odd/even pages and then
// left/center/right orientation
// positions are:  1=first/left  2=first/center  3=first/right
//                 4=odd/left    5=odd/center    6=odd/right
//                 7=even/left   8=even/center   9=even/right
Dcl-S HeaderPos Char(10) Inz('center');
Dcl-S HeaderPage Char(10) Inz('odd');
Dcl-Ds Header Qualified;
  Text Varchar(1024) Inz('');
  Font Varchar(50) Inz('');
  FontSize packed(3) Inz(0);
  Underline Char(1) Inz(''); // s=single,d=double
  Bold ind Inz(*off);
  Strikethrough ind Inz(*off);
  Color Char(8) Inz(' ');
  TypeOffset Char(1) Inz(''); // s=subscript,p=super
  NormalFont ind Inz(*off);
  Italic ind Inz(*off);
End-Ds;

// Data structure to hold all current sheet properties
Dcl-Ds WorkSheet Qualified;
  Name Char(124) Inz('');
  Status packed(1) Inz(0); // 1=open,2-data,3=clos
  FrzRows packed(2) Inz(0); // Freeze Rows
  FrzCols packed(2) Inz(0); // Freeze Columns
  ZoomPct packed(3) Inz(100);
  PrintScale packed(3) Inz(100);
  AutoBreaks ind Inz(*off);
  Row zoned(9) Inz(1); // Current Row
  Col zoned(5) Inz(1); // Current Column
  Landscape ind Inz(*off);
  MarginLeft packed(5: 2) Inz(0.7);
  MarginRight packed(5: 2) Inz(0.7);
  MarginTop packed(5: 2) Inz(0.75);
  MarginBottom packed(5: 2) Inz(0.75);
  MarginHeader packed(5: 2) Inz(0.3);
  MarginFooter packed(5: 2) Inz(0.3);
  Widths packed(5: 2) Inz(0) dim(2000);
  WidthsSet ind Inz(*off);
  WidthsMax packed(4) Inz(0);
  Merges Char(20) dim(50000) Inz(*all' ');
  MergeCount packed(5) Inz(0);
  Headers dim(9) likeds(header);
  Footers dim(9) likeds(header);
  DifferentOddAndEvenPages ind Inz(*off);
  DifferentFirstpage ind Inz(*off);
  ScaleWithDocument ind Inz(*off);
  AlignWithPageMargins ind Inz(*off);
  PaperSize Varchar(50) Inz('Letter');
  PrtAreaStrCol packed(5) Inz(-1);
  PrtAreaEndCol packed(5) Inz(-1);
  PrtAreaStrRow packed(5) Inz(-1);
  PrtAreaEndRow packed(5) Inz(-1);
  PrintQuality Varchar(50) Inz('');
  PrintCenterHorizontally ind Inz(*off);
  PrintCenterVertically ind Inz(*off);
  PageOrder Char(1) Inz('D');
  FilterStart Char(5) Inz('');
  FilterEnd Char(5) Inz('');
  Breaks packed(7) dim(10000) Inz(*all'0');
  BreakCount packed(5) Inz(0);
End-Ds;

// Argument data structure
// Arguments are passed as option variables up to 200 options
// with each option having one key value and up to 20 optional
// values, since RPG doesn't have generic argument handling
// they have to be passed as individual parameters, then function
// buildArgs converts each argument to this data structure
Dcl-Ds Arg Qualified;
  Parm Varchar(2048) Inz('');
  Key Varchar(50) Inz('');
  Values packed(3) Inz(0);
  Error Char(1) Inz('');
  Value Varchar(1024) Inz('') dim(20);
End-Ds;
Dcl-Ds Args Qualified;
  Count packed(3) Inz(0);
  Arg dim(200) likeds(arg);
End-Ds;

// Standalone Fields
Dcl-S i zoned(5);
Dcl-S y zoned(5);

// Program status data structure
Dcl-Ds psds PSDS;
  psdsdata Char(429); // The data
  PgmNam Char(10) overlay(psdsdata:001); // Program name
  StsCde zoned(5) overlay(psdsdata:011); // Status code
  StsPrv zoned(5) overlay(psdsdata:016); // Previous status code
  StmNbr Char(8) overlay(psdsdata:021); // Statment Number
  ErrRtn Char(8) overlay(psdsdata:029); // Error Routine
  ExcTyp Char(3) overlay(psdsdata:040); // Exception Type
  ExcNbr Char(4) overlay(psdsdata:043); // Exception Number
  ExcDta Char(80) overlay(psdsdata:091); // Exception Data
  ExcID Char(4) overlay(psdsdata:171); // Exceptin ID
  JobName Char(10) overlay(psdsdata:244); // Job Name
  JobUser Char(10) overlay(psdsdata:254); // Job User
  JobNbr Char(6) overlay(psdsdata:264); // Job Number
  CurUser Char(10) overlay(psdsdata:358); // Current User
  PARMS *PARMS;
End-Ds;

Dcl-S EOR Varchar(2) Inz( x'0D25' );
Dcl-S TAB Varchar(2) Inz( '  ' );
Dcl-S Null Char(1) Inz( x'00' );



// #$XLSXOpen - Open an existing file or create a new one.
//     input = #$XLSXFile = file name in the IFS
//                Example: /email/tmp/Output.xlsx
Dcl-Proc #$XLSXOpen EXPORT;
  Dcl-Pi *n;
    /Copy #$XLSX1.0/QRPGLESRC,#$XLSXARG
  End-Pi;

  Dcl-S x packed(5);

  // If a work book is already open give an error
  If Workbook.Status<>0;
    SndMsg('':1001);
    Return;
  EndIf;

  Clear WorkBook;
  Reset WorkBook;

  // Load all parameters into the worksheet data structure
  ExSr loadparms;

  // Give error if the output name is not passed
  If WorkBook.OutputName=' ';
    SndMsg('':1002);
  EndIf;

  // Set the workbook status to 1 showing that it is open
  Workbook.status=1;

  // fix file name, remove trailing spaces, add / if needed  remove leading \
  If (%subst(WorkBook.OutputName:1:1) = '\');
    WorkBook.OutputName = %subst(WorkBook.OutputName:2:
                                 %Len(WorkBook.OutputName)-1);
  EndIf;
  If (%subst(WorkBook.OutputName:1:1) <> '/');
    WorkBook.OutputName = '/' + WorkBook.OutputName;
  EndIf;

  // Add .xlsx extension if not there
  If LOWFY(LAST(WorkBook.OutputName:5))<>'.xlsx';
    WorkBook.OutputName=%Trim(WorkBook.OutputName)+ '.xlsx';
  EndIf;

  // The file needs the following structure in a zip file
  // with a .xlsx extension

  // _rels/.rels
  // docProps/app.xml
  // docProps/core.xml
  // xl/_rels/workbook.xml.rels
  // xl/worksheets/sheet1.xml
  // xl/styles.xml
  // xl/workbook.xml
  // [content_Types].xml

  // Blank out TAB and EOR for a more compact file
  If WorkBook.Debug<>*On;
    tab='';
    eor='';
  EndIf;

  // open a zip file in the IFS to contain the XLSX file
  #$ZipOpen(WorkBook.OutputName);

  //**************************************************************
  // Load all parameters into the Worksheet Data Structure
  //**************************************************************
  BegSr LoadParms;

    // load all parameters into the arg datastructure
    ExSr LoadArgs;

    For x=1 To Args.Count;
      ExSr valarg;
      ExSr prcarg;
    EndFor;

  EndSr;

  // load arguments into Args data structure
  /Copy #$XLSX1.0/QRPGLESRC,#$XLSXLARG

  // validate parameters
  BegSr valArg;

    // Validate Keys
    If Args.Arg(x).Key<>'OUTPUTNAME' and
       Args.Arg(x).Key<>'DEBUG' and
       Args.Arg(x).Key<>'CREATOR' and
       Args.Arg(x).Key<>'AUTHOR' and
       Args.Arg(x).Key<>'COMPANY' and
       Args.Arg(x).Key<>'TITLE' and
       Args.Arg(x).Key<>'SUBJECT' and
       Args.Arg(x).Key<>'MANAGER' and
       Args.Arg(x).Key<>'TAGS' and
       Args.Arg(x).Key<>'KEYWORDS' and
       Args.Arg(x).Key<>'CUSTOMPROPERTY' and
       Args.Arg(x).Key<>'CATEGORY' and
       Args.Arg(x).Key<>'STATUS' and
       Args.Arg(x).Key<>'COMMENTS' and
       Args.Arg(x).Key<>'HYPERLINKBASE' and
       Args.Arg(x).Key<>'BUFFERING';
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:1005:1);
      LeaveSr;
    EndIf;

    // make sure custom value has a name
    If Args.Arg(x).Key='CUSTOMPROPERTY' and Args.Arg(x).value(1)='';
      SndMsg(Args.Arg(x).Parm:1006:1);
      Args.Arg(x).Error='Y';
      LeaveSr;
    EndIf;

    // make sure custom value has a valid type
    If Args.Arg(x).Key='CUSTOMPROPERTY' and
       Args.Arg(x).value(2)<>'TEXT' and
       Args.Arg(x).value(2)<>'DATE' and
       Args.Arg(x).value(2)<>'NUMBER' and
       Args.Arg(x).value(2)<>'YESORNO' and
       Args.Arg(x).value(2)<>'BOOLEAN';
      SndMsg(Args.Arg(x).Parm:1007:1);
      Args.Arg(x).Error='Y';
      LeaveSr;
    EndIf;

    // make sure custom value of type date has a valid date
    If Args.Arg(x).Key='CUSTOMPROPERTY' and
       Args.Arg(x).value(2)='DATE';
      If Vdat(Args.Arg(x).value(3));
        SndMsg(Args.Arg(x).Parm:1007:1);
        Args.Arg(x).Error='Y';
        LeaveSr;
      EndIf;
    EndIf;

    // if they use a type of BOOLEAN change it to YESORNO
    If Args.Arg(x).Key='CUSTOMPROPERTY' and
       Args.Arg(x).value(2)='BOOLEAN';
      Args.Arg(x).value(2)='YESORNO';
    EndIf;

    // make sure custom value of type YESORNO has a valid value
    If Args.Arg(x).Key='CUSTOMPROPERTY' and
       Args.Arg(x).value(2)='YESORNO';
      Args.Arg(x).value(3)=upify(Args.Arg(x).value(3));
      If Args.Arg(x).VALUE(3)<>'YES'  and
         Args.Arg(x).VALUE(3)<>'Y'    and
         Args.Arg(x).VALUE(3)<>'1'    and
         Args.Arg(x).VALUE(3)<>'*ON'  and
         Args.Arg(x).VALUE(3)<>'ON'   and
         Args.Arg(x).VALUE(3)<>'TRUE' and
         Args.Arg(x).VALUE(3)<>'NO'   and
         Args.Arg(x).VALUE(3)<>'N'    and
         Args.Arg(x).VALUE(3)<>'0'    and
         Args.Arg(x).VALUE(3)<>'*OFF' and
         Args.Arg(x).VALUE(3)<>'OFF'  and
         Args.Arg(x).VALUE(3)<>'FALSE';
        SndMsg(Args.Arg(x).Parm:1008:1);
        Args.Arg(x).Error='Y';
        LeaveSr;
      EndIf;
    EndIf;

    // make sure custom value of type number has a valid number
    If Args.Arg(x).Key='CUSTOMVALUE' and
       Args.Arg(x).value(2)='NUMBER';
      If VNum(Args.Arg(x).value(3));
        SndMsg(Args.Arg(x).Parm:1008:1);
        Args.Arg(x).Error='Y';
        LeaveSr;
      EndIf;
    EndIf;

    // make sure buffering value is valid
    If Args.Arg(x).Key='BUFFERING';
      Args.Arg(x).value(1)=upify(Args.Arg(x).value(1));
      If Args.Arg(x).VALUE(1)<>'YES'  and
         Args.Arg(x).VALUE(1)<>'Y'    and
         Args.Arg(x).VALUE(1)<>'1'    and
         Args.Arg(x).VALUE(1)<>'*ON'  and
         Args.Arg(x).VALUE(1)<>'ON'   and
         Args.Arg(x).VALUE(1)<>'TRUE' and
         Args.Arg(x).VALUE(1)<>'NO'   and
         Args.Arg(x).VALUE(1)<>'N'    and
         Args.Arg(x).VALUE(1)<>'0'    and
         Args.Arg(x).VALUE(1)<>'*OFF' and
         Args.Arg(x).VALUE(1)<>'OFF'  and
         Args.Arg(x).VALUE(1)<>'FALSE';
        SndMsg(Args.Arg(x).value(1):1011:1);
        Args.Arg(x).Error='Y';
        LeaveSr;
      EndIf;
    EndIf;

  // todo add validation for the rest of the types

  EndSr;

  // Process a parameter
  BegSr prcArg;

    // skip if the argument is not valid
    If Args.Arg(x).error='Y';
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='OUTPUTNAME';
      WorkBook.OutputName=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='DEBUG' and
        (upify(Args.Arg(x).Value(1))='Y' or
         upify(Args.Arg(x).Value(1))='YES' or
         upify(Args.Arg(x).Value(1))='TRUE' or
         upify(Args.Arg(x).Value(1))='ON' or
         upify(Args.Arg(x).Value(1))='*ON' or
         Args.Arg(x).Value(1) ='1');
      WorkBook.Debug=*On;
    EndIf;

    If Args.Arg(x).Key='CREATOR' or
       Args.Arg(x).Key='AUTHOR';
      WorkBook.Creator=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='COMPANY';
      WorkBook.Company=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='TITLE';
      WorkBook.Title=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='SUBJECT';
      WorkBook.Subject=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='MANAGER';
      WorkBook.Manager=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='CATEGORY';
      WorkBook.Category=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='STATUS';
      WorkBook.ContentStatus=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='COMMENTS';
      WorkBook.Comments=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='HYPERLINKBASE';
      WorkBook.HyperLinkBase=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='TAGS' or Args.Arg(x).Key='KEYWorDS';
      WorkBook.Tags=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='CUSTOMPROPERTY';
      WorkBook.CustomPCount+=1;
      WorkBook.customProperties(WorkBook.CustomPCount).Name=
         Args.Arg(x).Value(1);
      If Args.Arg(x).Value(2)='TEXT';
        WorkBook.customProperties(WorkBook.CustomPCount).Type='1';
      ElseIf Args.Arg(x).Value(2)='DATE';
        WorkBook.customProperties(WorkBook.CustomPCount).Type='2';
      ElseIf Args.Arg(x).Value(2)='NUMBER';
        WorkBook.customProperties(WorkBook.CustomPCount).Type='3';
      ElseIf Args.Arg(x).Value(2)='YESORNO';
        WorkBook.customProperties(WorkBook.CustomPCount).Type='4';
      EndIf;
      If Args.Arg(x).Value(2)='YESORNO';
        If Args.Arg(x).Value(3)='*ON' or
           Args.Arg(x).Value(3)='ON' or
           Args.Arg(x).Value(3)='YES' or
           Args.Arg(x).Value(3)='Y' or
           Args.Arg(x).Value(3)='1' or
           Args.Arg(x).value(3)='TRUE';
          WorkBook.customProperties(WorkBook.CustomPCount).Value=
              'true';
        Else;
          WorkBook.customProperties(WorkBook.CustomPCount).Value=
              'false';
        EndIf;
      Else;
        WorkBook.customProperties(WorkBook.CustomPCount).Value=
               Args.Arg(x).Value(3);
      EndIf;
    EndIf;

    If Args.Arg(x).Key='BUFFERING' and
        (upify(Args.Arg(x).Value(1))='N' or
         upify(Args.Arg(x).Value(1))='NO' or
         upify(Args.Arg(x).Value(1))='FALSE' or
         upify(Args.Arg(x).Value(1))='OFF' or
         upify(Args.Arg(x).Value(1))='*OFF' or
         Args.Arg(x).Value(1) ='0');
      WorkBook.Buffering=*Off;
    EndIf;

  EndSr;
End-Proc;

// #$XLSXWkSh - Create a new Worksheet
//     input = Arguments, see documentation for all options
// Example: #$XLSXWkSh('Name:Sheet 1'  Sets the sheets tab to say Sheet 1
//                   : 'Zoom:150'      Sets the zoom to 150%
//                  : 'FreezeRows:2') Freezes the top 2 rows when scrolling down
Dcl-Proc #$XLSXWkSh EXPORT;
  Dcl-Pi *n;
    /Copy #$XLSX1.0/QRPGLESRC,#$XLSXARG
  End-Pi;
  Dcl-S x packed(5);

  // If there is not an open workbook throw error
  If WorkBook.Status<>1;
    SndMsg('#$XLSXWkSh':3001);
    Return;
  EndIf;

  // If the current status is 2=data close the prior sheet
  // so this starts a new one
  If WorkSheet.Status=2;
    EndSheet();
  EndIf;

  // If this is a new sheet, clear the properties
  If WorkSheet.Status<>1;
    Clear WorkSheet;
    Reset WorkSheet;
    // Default the sheet name, this may be overridden later
    WorkSheet.Name='Sheet ' + %Char(WorkBook.SheetCount+1);
    // reset all the headers, don't know why it doesnt work above
    Reset Header;
    WorkSheet.Headers(1) = Header;
    WorkSheet.Headers(2) = Header;
    WorkSheet.Headers(3) = Header;
    WorkSheet.Headers(4) = Header;
    WorkSheet.Headers(5) = Header;
    WorkSheet.Headers(6) = Header;
    WorkSheet.Headers(7) = Header;
    WorkSheet.Headers(8) = Header;
    WorkSheet.Headers(9) = Header;
    WorkSheet.Footers(1) = Header;
    WorkSheet.Footers(2) = Header;
    WorkSheet.Footers(3) = Header;
    WorkSheet.Footers(4) = Header;
    WorkSheet.Footers(5) = Header;
    WorkSheet.Footers(6) = Header;
    WorkSheet.Footers(7) = Header;
    WorkSheet.Footers(8) = Header;
    WorkSheet.Footers(9) = Header;
  EndIf;

  // Load the passed arguments
  ExSr loadparms;

  // set the status to 1 which is started but no data yet.
  WorkSheet.Status=1;

  //**************************************************************
  BegSr LoadParms;

    // load all parameters into the arg datastructure
    ExSr LoadArgs;

    For x=1 To Args.Count;
      ExSr valarg;
      ExSr prcarg;
    EndFor;

  EndSr;

  // load arguments into Args data structure
  /Copy #$XLSX1.0/QRPGLESRC,#$XLSXLARG

  // validate parameters
  BegSr valArg;

    // Validate Keys
    If Args.Arg(x).Key<>'SHEETNAME' and
       Args.Arg(x).Key<>'AUTOBREAKS' and
       Args.Arg(x).Key<>'COLUMNWIDTH' and
       Args.Arg(x).Key<>'ZOOM' and
       Args.Arg(x).Key<>'HEADER' and
       Args.Arg(x).Key<>'FOOTER' and
       Args.Arg(x).Key<>'DIFFERENTODDANDEVENPAGES' and
       Args.Arg(x).Key<>'DIFFERENTFIRSTPAGE' and
       Args.Arg(x).Key<>'SCALEWITHDOCUMENT' and
       Args.Arg(x).Key<>'ALIGNWITHPAGEMARGINS' and
       Args.Arg(x).Key<>'REPEATINGCOLUMNS' and
       Args.Arg(x).Key<>'REPEATINGROWS' and
       Args.Arg(x).Key<>'FREEZEROWS' and
       Args.Arg(x).Key<>'FREEZECOLUMNS' and
       Args.Arg(x).Key<>'PRINTORIENTATION' and
       Args.Arg(x).Key<>'PRINTSCALE' and
       Args.Arg(x).Key<>'FILTER' and
       Args.Arg(x).Key<>'MARGINS' and
       Args.Arg(x).Key<>'SIDEMARGINS' and
       Args.Arg(x).Key<>'LEFTMARGIN' and
       Args.Arg(x).Key<>'RIGHTMARGIN' and
       Args.Arg(x).Key<>'TOPMARGIN' and
       Args.Arg(x).Key<>'BOTTOMMARGIN' and
       Args.Arg(x).Key<>'HEADERMARGIN' and
       Args.Arg(x).Key<>'FOOTERMARGIN' and
       Args.Arg(x).Key<>'PAPERSIZE' and
       Args.Arg(x).Key<>'PRINTAREA' and
       Args.Arg(x).Key<>'PRINTQUALITY' and
       Args.Arg(x).Key<>'PRINTCENTERHORIZONTALLY' and
       Args.Arg(x).Key<>'PRINTCENTERVERTICALLY' and
       Args.Arg(x).Key<>'PRINTPAGEORDER';
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:3002:1);
      LeaveSr;
    EndIf;

    // make sure sheet name has a name
    If Args.Arg(x).Key='SHEETNAME' and Args.Arg(x).value(1)='';
      SndMsg(Args.Arg(x).Parm:3003:1);
      Args.Arg(x).Error='Y';
      LeaveSr;
    EndIf;

    // purge imbeded spaces and * from the sheet name
    If Args.Arg(x).Key='SHEETNAME';
      Args.Arg(x).value(1)=%ScanRpl('*':'':Args.Arg(x).value(1));
      Args.Arg(x).value(1)=%ScanRpl(' ':'_':Args.Arg(x).value(1));
    EndIf;

    // Make sure the name doesn't match an existing sheet
    If Args.Arg(x).Key='SHEETNAME';
      For i=1 To WorkBook.SheetCount;
        If Args.Arg(x).value(1)=WorkBook.Sheets(i);
          SndMsg(Args.Arg(x).Value(1):3005:1);
          Args.Arg(x).Error='Y';
          LeaveSr;
        EndIf;
      EndFor;
    EndIf;

    // make sure column widths has a column number between 1 and 2000
    If Args.Arg(x).Key='COLUMNWIDTH' and
       (RVL(Args.Arg(x).Value(1))<=0 or
        RVL(Args.Arg(x).Value(1))>2000);
      SndMsg(Args.Arg(x).Parm:3004:1);
      Args.Arg(x).Error='Y';
      LeaveSr;
    EndIf;

    // make sure column widths has a width between 0 and 255
    If Args.Arg(x).Key='COLUMNWIDTH' and
       (RVL(Args.Arg(x).Value(2))<0 or
        RVL(Args.Arg(x).Value(2))>255);
      If COL2(Args.Arg(x).Value(2))<0 or
         COL2(Args.Arg(x).Value(2))>255;
        SndMsg(Args.Arg(x).Parm:3004:1);
        Args.Arg(x).Error='Y';
        LeaveSr;
      EndIf;
    EndIf;

  // TODO Validate all options

  EndSr;

  // Process a parameter
  BegSr prcArg;

    // skip if the argument is not valid
    If Args.Arg(x).error='Y';
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='SHEETNAME';
      WorkSheet.Name=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='FREEZEROWS' and RVL(Args.Arg(x).VALUE(1))<>0;
      WorkSheet.FrzRows = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='FREEZECOLUMNS' and
       RVL(Args.Arg(x).VALUE(1))<>0;
      WorkSheet.FrzCols = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='PRINTORIENTATION';
      If upIfy(%subst(Args.Arg(x).Value(1):1:1))='L';
        WorkSheet.Landscape=*on;
      Else;
        WorkSheet.Landscape=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='ZOOM' and
       RVL(Args.Arg(x).VALUE(1))>=10 and
       RVL(Args.Arg(x).VALUE(1))<=500;
      WorkSheet.ZoomPct = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='PRINTSCALE' and
       RVL(Args.Arg(x).VALUE(1))>=1 and
       RVL(Args.Arg(x).VALUE(1))<=400;
      WorkSheet.PrintScale = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='AUTOBREAKS';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON'  or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y'   or
         Args.Arg(x).Value(1)='1'   or
         Args.Arg(x).value(1)='TRUE';
        WorkSheet.AutoBreaks=*on;
      Else;
        WorkSheet.AutoBreaks=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='DIFFERENTODDANDEVENPAGES';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON'  or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y'   or
         Args.Arg(x).Value(1)='1'   or
         Args.Arg(x).Value(1)='TRUE';
        WorkSheet.DifferentOddAndEvenPages=*on;
      Else;
        WorkSheet.DifferentOddAndEvenPages=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='DIFFERENTFIRSTPAGE';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON'  or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y'   or
         Args.Arg(x).Value(1)='1'   or
         Args.Arg(x).Value(1)='TRUE';
        WorkSheet.DifferentFirstpage=*on;
      Else;
        WorkSheet.DifferentFirstpage=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='SCALEWITHDOCUMENT';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON'  or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y'   or
         Args.Arg(x).Value(1)='1'   or
         Args.Arg(x).Value(1)='TRUE';
        WorkSheet.ScaleWithDocument=*on;
      Else;
        WorkSheet.ScaleWithDocument=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='ALIGNWITHPAGEMARGINS';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON'  or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y'   or
         Args.Arg(x).Value(1)='1'   or
         Args.Arg(x).Value(1)='TRUE';
        WorkSheet.AlignWithPageMargins=*on;
      Else;
        WorkSheet.AlignWithPageMargins=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='PRINTCENTERHORIZONTALLY';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON'  or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y'   or
         Args.Arg(x).Value(1)='1'   or
         Args.Arg(x).Value(1)='TRUE';
        WorkSheet.PrintCenterHorizontally=*on;
      Else;
        WorkSheet.PrintCenterHorizontally=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='PRINTCENTERVERTICALLY';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON'  or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y'   or
         Args.Arg(x).Value(1)='1'   or
         Args.Arg(x).Value(1)='TRUE';
        WorkSheet.PrintCenterVertically=*on;
      Else;
        WorkSheet.PrintCenterVertically=*off;
      EndIf;
    EndIf;

    If Args.Arg(x).Key='LEFTMARGIN' and
       RVL(Args.Arg(x).VALUE(1))>=1 and
       RVL(Args.Arg(x).VALUE(1))<=400;
      WorkSheet.MarginLeft = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='RIGHTMARGIN' and
       RVL(Args.Arg(x).VALUE(1))>=1 and
       RVL(Args.Arg(x).VALUE(1))<=400;
      WorkSheet.MarginRight = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='TOPMARGIN' and
       RVL(Args.Arg(x).VALUE(1))>=1 and
       RVL(Args.Arg(x).VALUE(1))<=400;
      WorkSheet.MarginTop = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='BOTTOMMARGIN' and
       RVL(Args.Arg(x).VALUE(1))>=1 and
       RVL(Args.Arg(x).VALUE(1))<=400;
      WorkSheet.MarginBottom = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='HEADERMARGIN' and
       RVL(Args.Arg(x).VALUE(1))>=1 and
       RVL(Args.Arg(x).VALUE(1))<=400;
      WorkSheet.MarginHeader = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='FOOTERMARGIN' and
       RVL(Args.Arg(x).VALUE(1))>=1 and
       RVL(Args.Arg(x).VALUE(1))<=400;
      WorkSheet.MarginFooter = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    // Process Margin Keyword with 1 parameter, sets all margins
    If Args.Arg(x).Key='MARGIN' and Args.Arg(x).Values=1;
      If RVL(Args.Arg(x).VALUE(1))>=0 and
         RVL(Args.Arg(x).VALUE(1))<=21;
        WorkSheet.MarginLeft   = RVL(Args.Arg(x).VALUE(1));
        WorkSheet.MarginRight  = RVL(Args.Arg(x).VALUE(1));
        WorkSheet.MarginTop    = RVL(Args.Arg(x).VALUE(1));
        WorkSheet.MarginBottom = RVL(Args.Arg(x).VALUE(1));
        WorkSheet.MarginHeader = RVL(Args.Arg(x).VALUE(1));
        WorkSheet.MarginFooter = RVL(Args.Arg(x).VALUE(1));
      EndIf;
    EndIf;

    // Process Margin Keyword with 2 parameter, sets Top/Bottom them Right/Left
    If Args.Arg(x).Key='MARGIN' and Args.Arg(x).Values=2;
      If RVL(Args.Arg(x).VALUE(1))>=0 and
         RVL(Args.Arg(x).VALUE(1))<=21;
        WorkSheet.MarginTop    = RVL(Args.Arg(x).VALUE(1));
        WorkSheet.MarginBottom = RVL(Args.Arg(x).VALUE(1));
      EndIf;
      If RVL(Args.Arg(x).VALUE(2))>=0 and
         RVL(Args.Arg(x).VALUE(2))<=21;
        WorkSheet.MarginLeft   = RVL(Args.Arg(x).VALUE(2));
        WorkSheet.MarginRight  = RVL(Args.Arg(x).VALUE(2));
      EndIf;
    EndIf;

    // Process Margin Keyword with 3 parameter, Top, Sides, Bottom
    If Args.Arg(x).Key='MARGIN' and Args.Arg(x).Values=3;
      If RVL(Args.Arg(x).VALUE(1))>=0 and
         RVL(Args.Arg(x).VALUE(1))<=21;
        WorkSheet.MarginTop    = RVL(Args.Arg(x).VALUE(1));
      EndIf;
      If RVL(Args.Arg(x).VALUE(2))>=0 and
         RVL(Args.Arg(x).VALUE(2))<=21;
        WorkSheet.MarginLeft   = RVL(Args.Arg(x).VALUE(2));
        WorkSheet.MarginRight  = RVL(Args.Arg(x).VALUE(2));
      EndIf;
      If RVL(Args.Arg(x).VALUE(3))>=0 and
         RVL(Args.Arg(x).VALUE(3))<=21;
        WorkSheet.MarginBottom = RVL(Args.Arg(x).VALUE(3));
      EndIf;
    EndIf;

    // Process Margin Keyword with 4 parameter, top, right, bottom, left
    If Args.Arg(x).Key='MARGIN' and Args.Arg(x).Values=4;
      If RVL(Args.Arg(x).VALUE(1))>=0 and
         RVL(Args.Arg(x).VALUE(1))<=21;
        WorkSheet.MarginTop    = RVL(Args.Arg(x).VALUE(1));
      EndIf;
      If RVL(Args.Arg(x).VALUE(2))>=0 and
         RVL(Args.Arg(x).VALUE(2))<=21;
        WorkSheet.MarginRight  = RVL(Args.Arg(x).VALUE(2));
      EndIf;
      If RVL(Args.Arg(x).VALUE(3))>=0 and
         RVL(Args.Arg(x).VALUE(3))<=21;
        WorkSheet.MarginBottom = RVL(Args.Arg(x).VALUE(3));
      EndIf;
      If RVL(Args.Arg(x).VALUE(4))>=0 and
         RVL(Args.Arg(x).VALUE(4))<=21;
        WorkSheet.MarginLeft   = RVL(Args.Arg(x).VALUE(4));
      EndIf;
    EndIf;

    // Process Margin Keyword with 6 parameters, top,right,bottom,left,header,footer
    If Args.Arg(x).Key='MARGIN' and Args.Arg(x).Values=6;
      If RVL(Args.Arg(x).VALUE(1))>=0 and
         RVL(Args.Arg(x).VALUE(1))<=21;
        WorkSheet.MarginTop    = RVL(Args.Arg(x).VALUE(1));
      EndIf;
      If RVL(Args.Arg(x).VALUE(2))>=0 and
         RVL(Args.Arg(x).VALUE(2))<=21;
        WorkSheet.MarginRight  = RVL(Args.Arg(x).VALUE(2));
      EndIf;
      If RVL(Args.Arg(x).VALUE(3))>=0 and
         RVL(Args.Arg(x).VALUE(3))<=21;
        WorkSheet.MarginBottom = RVL(Args.Arg(x).VALUE(3));
      EndIf;
      If RVL(Args.Arg(x).VALUE(4))>=0 and
         RVL(Args.Arg(x).VALUE(4))<=21;
        WorkSheet.MarginLeft   = RVL(Args.Arg(x).VALUE(4));
      EndIf;
      If RVL(Args.Arg(x).VALUE(5))>=0 and
         RVL(Args.Arg(x).VALUE(5))<=21;
        WorkSheet.MarginHeader = RVL(Args.Arg(x).VALUE(5));
      EndIf;
      If RVL(Args.Arg(x).VALUE(6))>=0 and
         RVL(Args.Arg(x).VALUE(6))<=21;
        WorkSheet.MarginFooter = RVL(Args.Arg(x).VALUE(6));
      EndIf;
    EndIf;

    // Process SideMargin Keyword, sets the right and left margins
    If Args.Arg(x).Key='SIDEMARGIN' and
       RVL(Args.Arg(x).VALUE(1))>=0 and
       RVL(Args.Arg(x).VALUE(1))<=21;
      WorkSheet.MarginRight  = RVL(Args.Arg(x).VALUE(1));
      WorkSheet.MarginLeft   = RVL(Args.Arg(x).VALUE(1));
    EndIf;

    If Args.Arg(x).Key='PAPERSIZE';
      WorkSheet.PaperSize = Args.Arg(x).VALUE(1);
    EndIf;

    If Args.Arg(x).Key='PRINTQUALITY';
      WorkSheet.PrintQuality = Args.Arg(x).VALUE(1);
    EndIf;

    If Args.Arg(x).Key='PRINTPAGEORDER';
      If Args.Arg(x).VALUE(1)='OVERTHENDOWN';
        WorkSheet.PageOrder = 'O';
      Else;
        WorkSheet.PageOrder = 'D';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='COLUMNWIDTH';
      If rvl(Args.Arg(x).Value(2))=0;
        WorkSheet.Widths(%int(RVL(Args.Arg(x).value(1))))=
            col2(Args.Arg(x).Value(2));
      Else;
        WorkSheet.Widths(%int(RVL(Args.Arg(x).value(1))))=
            rvl(Args.Arg(x).Value(2));
      EndIf;
      WorkSheet.WidthsSet=*on;
      If WorkSheet.WidthsMax<RVL(Args.Arg(x).value(1));
        WorkSheet.WidthsMax=RVL(Args.Arg(x).value(1));
      EndIf;
    EndIf;

    If Args.Arg(x).Key='REPEATINGCOLUMNS';
      WorkBook.Repeating=*on;
      WorkBook.RepeatingColumns(WorkBook.SheetCount+1)=
                               RVL(Args.Arg(x).VALUE(1));
      If RVL(Args.Arg(x).VALUE(2))<>0;
        WorkBook.RepeatingColumnsEnd(WorkBook.SheetCount+1)=
                              RVL(Args.Arg(x).VALUE(2));
      Else;
        WorkBook.RepeatingColumnsEnd(WorkBook.SheetCount+1)=
                              RVL(Args.Arg(x).VALUE(1));
      EndIf;
    EndIf;

    If Args.Arg(x).Key='REPEATINGROWS';
      Workbook.Repeating=*on;
      WorkBook.RepeatingRows(WorkBook.SheetCount+1)=
                             RVL(Args.Arg(x).VALUE(1));
      If RVL(Args.Arg(x).VALUE(2))<>0;
        WorkBook.RepeatingRowsEnd(WorkBook.SheetCount+1)=
                              RVL(Args.Arg(x).VALUE(2));
      Else;
        WorkBook.RepeatingRowsEnd(WorkBook.SheetCount+1)=
                              RVL(Args.Arg(x).VALUE(1));
      EndIf;
    EndIf;

    If Args.Arg(x).Key='PRINTAREA';
      WorkSheet.PrtAreaStrCol = RVL(Args.Arg(x).VALUE(1));
      WorkSheet.PrtAreaEndCol = RVL(Args.Arg(x).VALUE(2));
      WorkSheet.PrtAreaStrRow = RVL(Args.Arg(x).VALUE(3));
      WorkSheet.PrtAreaEndRow = RVL(Args.Arg(x).VALUE(4));
    EndIf;

    // For Headers and Footers, build the options in the header ds and then
    // once the location is determined move them into the Headers/Footers array
    If (Args.Arg(x).Key='HEADER' or Args.Arg(x).Key='FOOTER') and
       Args.Arg(x).Value(1)<>' ';
      Clear header;
      Reset headerPos;
      Reset headerPage;
      Header.Text = %Trim(Args.Arg(x).Value(1));
      If Args.Arg(x).Value(2)<>' ';
        Header.Font = %Trim(Args.Arg(x).Value(2));
      EndIf;
      If rvl(Args.Arg(x).Value(3))>=1 and
         rvl(Args.Arg(x).Value(3))<=409;
        Header.FontSize = rvl(Args.Arg(x).Value(3));
      EndIf;
      // Process optional values in 4-13
      For y = 4 To 13;
        If Args.Arg(x).Value(y)<>' ';
          If lowfy(Args.Arg(x).Value(y))='underline';
            Header.Underline='s';
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='doubleunderline';
            Header.Underline='d';
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='bold';
            Header.Bold=*on;
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='italic';
            Header.Italic=*on;
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='strikethrough';
            Header.Strikethrough=*on;
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='subscript';
            Header.TypeOffset='s';
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='superscript';
            Header.TypeOffset='p';
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='left' or
             lowfy(Args.Arg(x).Value(y))='center' or
             lowfy(Args.Arg(x).Value(y))='right';
            HeaderPos=lowfy(Args.Arg(x).Value(y));
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='odd' or
             lowfy(Args.Arg(x).Value(y))='even' or
             lowfy(Args.Arg(x).Value(y))='first';
            HeaderPage=lowfy(Args.Arg(x).Value(y));
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='color';
            Header.Color=GetColor(upify(Args.Arg(x).Value(y+1)));
          EndIf;
          If lowfy(Args.Arg(x).Value(y))='normalfont';
            Header.NormalFont=*on;
          EndIf;
        EndIf;
      EndFor;
      // add the header DS to the correct header or footer DS
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='left' and headerPage='first';
        WorkSheet.Headers(1)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='center' and headerPage='first';
        WorkSheet.Headers(2)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='right' and headerPage='first';
        WorkSheet.Headers(3)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='left' and headerPage='odd';
        WorkSheet.Headers(4)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='center' and headerPage='odd';
        WorkSheet.Headers(5)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='right' and headerPage='odd';
        WorkSheet.Headers(6)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='left' and headerPage='even';
        WorkSheet.Headers(7)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='center' and headerPage='even';
        WorkSheet.Headers(8)=Header;
      EndIf;
      If Args.Arg(x).Key='HEADER' and
         HeaderPos='right' and headerPage='even';
        WorkSheet.Headers(9)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='left' and headerPage='first';
        WorkSheet.Footers(1)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='center' and headerPage='first';
        WorkSheet.Footers(2)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='right' and headerPage='first';
        WorkSheet.Footers(3)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='left' and headerPage='odd';
        WorkSheet.Footers(4)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='center' and headerPage='odd';
        WorkSheet.Footers(5)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='right' and headerPage='odd';
        WorkSheet.Footers(6)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='left' and headerPage='even';
        WorkSheet.Footers(7)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='center' and headerPage='even';
        WorkSheet.Footers(8)=Header;
      EndIf;
      If Args.Arg(x).Key='FOOTER' and
         HeaderPos='right' and headerPage='even';
        WorkSheet.Footers(9)=Header;
      EndIf;
    EndIf;

    // Todo left off here

    If Args.Arg(x).Key='FILTER' and
       Args.Arg(x).Values=1;
      WorkSheet.FilterStart='A1';
      WorkSheet.FilterEnd=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='FILTER' and
       Args.Arg(x).Values=2;
      WorkSheet.FilterStart=Args.Arg(x).Value(1);
      WorkSheet.FilterEnd=Args.Arg(x).Value(2);
    EndIf;

  EndSr;
End-Proc;


// StrSheet - Sets up a worksheet so data can be added
//    This gets called when the first cell is added or skipped.

//    This sets the status to 1 so no more properties can be set
//    for the sheet. It then creates the actual sheet XML file and
//    gets it ready to start adding data to.

Dcl-Proc strSheet;

  // Change the status to 2 to prevent any sheet settings
  // from being changed.
  WorkSheet.Status=2;

  // Create the sheet file and open it for writing
  openf(%Trim(WorkBook.TempFolder)+'xl/worksheets/sheet'+
            %Char(Workbook.SheetCount+1)+'.xml');

  // Write everything that comes before the sheet data
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<worksheet +
          xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/+
                 main" +
         xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/+
                   relationships" +
          xmlns:mc="http://schemas.openxmlformats.org/markup-+
                    compatibility/2006">'+eor);

  // Add columns if any are set
  If WorkSheet.PrintScale=-1 or           // Fit all columns on one page
     WorkSheet.PrintScale=-2 or           // Fit all rows on one page
     WorkSheet.PrintScale=-3;             // Fit full sheet on one page
    writef(tab+'<sheetPr>'+eor+
           tab+tab+'<pageSetUpPr fitToPage="1"/>'+eor+
           tab+'</sheetPr>+eor');
  EndIf;

  writef(tab+'<dimension ref="A1:C7"/>'+eor);
  writef(tab+'<sheetViews>'+eor);
  writef(tab+tab+'<sheetView tabSelected="1"');
  If WorkSheet.ZoomPct<>100;
    writef(' zoomScale="'+%Char(WorkSheet.zoomPct)+'" +
             zoomScaleNormal="'+%Char(WorkSheet.zoomPct)+'"');
  EndIf;
  writef(' workbookViewId="0">'+eor);
  If WorkSheet.FrzRows<>0 and WorkSheet.FrzCols=0;
    writef(tab+tab+tab+'<pane ySplit="'+%Char(WorkSheet.FrzRows)+'" +
                     topLeftCell="A'+%Char(WorkSheet.FrzRows+1)+'" +
                     activePane="bottomLeft" +
                     state="frozen"/>'+eor);
    writef(tab+tab+tab+'<selection pane="bottomLeft" +
                     activeCell="A'+%Char(WorkSheet.FrzRows+1)+'" +
                     sqref="A'+%Char(WorkSheet.FrzRows+1)+'"/>'+eor);
  EndIf;
  If WorkSheet.FrzRows=0 and WorkSheet.FrzCols<>0;
    writef(tab+tab+tab+'<pane xSplit="'+%Char(WorkSheet.FrzCols)+'" +
                     topLeftCell="'+Col(WorkSheet.FrzCols+1)+'1" +
                     activePane="topRight" +
                     state="frozen"/>'+eor);
    writef(tab+tab+tab+'<selection pane="topRight" +
                     activeCell="'+Col(WorkSheet.FrzCols+1)+'2" +
                     sqref="'+Col(WorkSheet.FrzCols+1)+'2"/>'+eor);
  EndIf;
  If WorkSheet.FrzRows<>0 and WorkSheet.FrzCols<>0;
    writef(tab+tab+tab+'<pane +
                     xSplit="'+%Char(WorkSheet.FrzCols)+'" +
                     ySplit="'+%Char(WorkSheet.FrzRows)+'" +
                     topLeftCell="'+Col(WorkSheet.FrzCols+1)+
                                    %Char(WorkSheet.FrzRows+1)+'" +
                     activePane="bottomRight" +
                     state="frozen"/>'+eor);
    writef(tab+tab+tab+'<selection pane="topRight" +
                     activeCell="'+Col(WorkSheet.FrzCols+1)+'1" +
                     sqref="'+Col(WorkSheet.FrzCols+1)+'1"/>'+eor);
    writef(tab+tab+tab+'<selection pane="bottomLeft" +
                     activeCell="A'+%Char(WorkSheet.FrzRows+1)+'" +
                     sqref="A'+%Char(WorkSheet.FrzRows+1)+'"/>'+eor);
    writef(tab+tab+tab+'<selection pane="bottomRight" +
                     activeCell="'+ Col(WorkSheet.FrzCols+1) +
                           %Char(WorkSheet.FrzRows+1)+'" +
                     sqref="'+ Col(WorkSheet.FrzCols+1) +
                           %Char(WorkSheet.FrzRows+1)+'"/>'+eor);
  EndIf;
  writef(tab+tab+'</sheetView>'+eor);
  writef(tab+'</sheetViews>'+eor);

  writef(tab+'<sheetFormatPr defaultRowHeight="15"/>'+eor);

  // Add columns if any are set
  If WorkSheet.WidthsSet;
    writef(tab+'<cols>'+eor);
    For i=1 To 1000;
      If WorkSheet.Widths(i)>0;
        writef(tab+tab+'<col +
                        min="' + %Char(i) + '" +
                        max="' + %Char(i) + '" +
                        width="' + %Char(WorkSheet.Widths(i)) + '" +
                        customWidth="1"/>'+eor);
      EndIf;
    EndFor;
    writef(tab+'</cols>'+eor);
  EndIf;

  writef(tab+'<sheetData>'+eor);


  WorkSheet.Row= 1;
  WorkSheet.Col= 1;

  // start the first row
  writef(tab+tab+'<row r="' + %Char(WorkSheet.Row) + '">'+eor);

End-Proc;

// EndSheet - Closes out a worksheet
//    This gets called maunally,
//    if a new sheet is started and the current sheet status is 1,
//    or if a workbook is closed and the current sheet status is 1.

//    This sets closes the current sheet and finishes writing the
//    end of the file. It sets the status to 2 so no more data can
//   be added.

Dcl-Proc EndSheet;

  // Change the status to 3 to prevent any more data from
  // being added.
  WorkSheet.Status=3;

  // Write everything that comes after the sheet data
  writef(tab+tab+'</row>'+eor);
  writef(tab+'</sheetData>'+eor);

  // Add Auto Filters
  If WorkSheet.FilterStart<>' ';
    writef(tab+'<autoFilter ref="'+
               %Trim(WorkSheet.FilterStart) + ':' +
               %Trim(WorkSheet.FilterEnd) + '"/>'+eor);
  EndIf;

  // Add merge cells if any exist
  If WorkSheet.MergeCount>0;
    writef(tab+'<mergeCells count="'+
               %Char(WorkSheet.MergeCount)+'">'+eor);
    For i = 1 To WorkSheet.MergeCount;
      writef(tab+tab+'<mergeCell ref="'+
             %Trim(WorkSheet.Merges(i))+'"/>'+eor);
    EndFor;
    writef(tab+'</mergeCells>'+eor);
  EndIf;

  // Add Page Margins
  writef(tab+'<pageMargins +
              Left="'   + %Char(WorkSheet.MarginLeft)   + '" +
              right="'  + %Char(WorkSheet.MarginRight)  + '" +
              top="'    + %Char(WorkSheet.MarginTop)    + '" +
              bottom="' + %Char(WorkSheet.MarginBottom) + '" +
              header="' + %Char(WorkSheet.MarginHeader) + '" +
              footer="' + %Char(WorkSheet.MarginFooter) + '"/>'+eor);

  writef(tab+'<pageSetup');
  // Scaling options
  If WorkSheet.PrintScale=-1;             // Fit all columns on one page
    writef(' fitToHeight="0"');
  ElseIf WorkSheet.PrintScale=-2;         // Fit all rows on one page
    writef(' fitToWidth="0"');
  ElseIf WorkSheet.PrintScale>1;          // Set print scale
    writef(' scale="'+%Char(WorkSheet.PrintScale)+'"');
  EndIf;
  // Add Portrait/Landscape Option
  If WorkSheet.Landscape;
    writef(' orientation="landscape"');
  Else;
    writef(' orientation="portrait"');
  EndIf;
  writef(' horizontalDpi="4294967295" +
           verticalDpi="4294967295" +
           r:id="rId1"/>'+eor);

  // add header and footer options
  If Worksheet.headers(1).text<>'' or  Worksheet.footers(1).text<>'' or
     Worksheet.headers(2).text<>'' or  Worksheet.footers(2).text<>'' or
     Worksheet.headers(3).text<>'' or  Worksheet.footers(3).text<>'' or
     Worksheet.headers(4).text<>'' or  Worksheet.footers(4).text<>'' or
     Worksheet.headers(5).text<>'' or  Worksheet.footers(5).text<>'' or
     Worksheet.headers(6).text<>'' or  Worksheet.footers(6).text<>'' or
     Worksheet.headers(7).text<>'' or  Worksheet.footers(7).text<>'' or
     Worksheet.headers(8).text<>'' or  Worksheet.footers(8).text<>'' or
     Worksheet.headers(9).text<>'' or  Worksheet.footers(9).text<>'';
    writef(tab+'<headerFooter');
    If Worksheet.DifferentOddAndEvenPages;
      writef(' differentOddEven="1"');
    EndIf;
    If Worksheet.DifferentFirstPage;
      writef(' differentFirst="1"');
    EndIf;
    writef('>'+eor);
    // Add Odd Header row
    If Worksheet.headers(4).text<>' ' or
       Worksheet.headers(5).text<>' ' or
       Worksheet.headers(6).text<>' ';
      writef(tab+tab+'<oddHeader>');
      If Worksheet.headers(4).text<>' ';
        writef('&amp;L');
        addHeader(Worksheet.headers(4));
      EndIf;
      If Worksheet.headers(5).text<>' ';
        writef('&amp;C');
        addHeader(Worksheet.headers(5));
      EndIf;
      If Worksheet.headers(6).text<>' ';
        writef('&amp;R');
        addHeader(Worksheet.headers(6));
      EndIf;
      writef('</oddHeader>'+eor);
    EndIf;
    // Add Odd Footer row
    If Worksheet.footers(4).text<>' ' or
       Worksheet.footers(5).text<>' ' or
       Worksheet.footers(6).text<>' ';
      writef(tab+tab+'<oddFooter>');
      If Worksheet.footers(4).text<>' ';
        writef('&amp;L');
        addHeader(Worksheet.Footers(4));
      EndIf;
      If Worksheet.footers(5).text<>' ';
        writef('&amp;C');
        addHeader(Worksheet.Footers(5));
      EndIf;
      If Worksheet.footers(6).text<>' ';
        writef('&amp;R');
        addHeader(Worksheet.Footers(6));
      EndIf;
      writef('</oddFooter>'+eor);
    EndIf;
    // Add Even Header row
    If Worksheet.headers(7).text<>' ' or
       Worksheet.headers(8).text<>' ' or
       Worksheet.headers(9).text<>' ';
      writef(tab+tab+'<evenHeader>');
      If Worksheet.headers(7).text<>' ';
        writef('&amp;L');
        addHeader(Worksheet.headers(7));
      EndIf;
      If Worksheet.headers(8).text<>' ';
        writef('&amp;C');
        addHeader(Worksheet.headers(8));
      EndIf;
      If Worksheet.headers(9).text<>' ';
        writef('&amp;R');
        addHeader(Worksheet.headers(9));
      EndIf;
      writef('</evenHeader>'+eor);
    EndIf;
    // Add Even Footer row
    If Worksheet.Footers(7).text<>' ' or
       Worksheet.Footers(8).text<>' ' or
       Worksheet.Footers(9).text<>' ';
      writef(tab+tab+'<evenFooter>');
      If Worksheet.Footers(7).text<>' ';
        writef('&amp;L');
        addHeader(Worksheet.Footers(7));
      EndIf;
      If Worksheet.Footers(8).text<>' ';
        writef('&amp;C');
        addHeader(Worksheet.Footers(8));
      EndIf;
      If Worksheet.Footers(9).text<>' ';
        writef('&amp;R');
        addHeader(Worksheet.Footers(9));
      EndIf;
      writef('</evenFooter>'+eor);
    EndIf;
    // Add First Header row
    If Worksheet.headers(1).text<>' ' or
       Worksheet.headers(2).text<>' ' or
       Worksheet.headers(3).text<>' ';
      writef(tab+tab+'<firstHeader>');
      If Worksheet.headers(1).text<>' ';
        writef('&amp;L');
        addHeader(Worksheet.headers(1));
      EndIf;
      If Worksheet.headers(2).text<>' ';
        writef('&amp;C');
        addHeader(Worksheet.headers(2));
      EndIf;
      If Worksheet.headers(3).text<>' ';
        writef('&amp;R');
        addHeader(Worksheet.headers(3));
      EndIf;
      writef('</firstHeader>'+eor);
    EndIf;
    // Add First Footer row
    If Worksheet.Footers(1).text<>' ' or
       Worksheet.Footers(2).text<>' ' or
       Worksheet.Footers(3).text<>' ';
      writef(tab+tab+'<firstFooter>');
      If Worksheet.Footers(1).text<>' ';
        writef('&amp;L');
        addHeader(Worksheet.Footers(1));
      EndIf;
      If Worksheet.Footers(2).text<>' ';
        writef('&amp;C');
        addHeader(Worksheet.Footers(2));
      EndIf;
      If Worksheet.Footers(3).text<>' ';
        writef('&amp;R');
        addHeader(Worksheet.Footers(3));
      EndIf;
      writef('</firstFooter>'+eor);
    EndIf;
    writef(tab+'</headerFooter>'+eor);
  EndIf;

  // add page breaks if any are set
  If Worksheet.Breakcount>0;
    writef(tab+'<rowBreaks count="'+
                %Trim(%Char(Worksheet.BreakCount)) +
                '" manualBreakCount="'+
                %Trim(%Char(Worksheet.BreakCount)) +
                '">'+eor);
    For i = 1 To Worksheet.BreakCount;
      writef(tab+tab+'<brk id="' +
                       %Trim(%Char(Worksheet.Breaks(i))) +
                       '" max="16383" man="1"/>'+eor);
    EndFor;
    writef(tab+'</rowBreaks>'+eor);
  EndIf;

  writef('</worksheet>');
  closef();

  // Add the sheet to the work book array
  // do not do until it is closed because it can be
  // changed up till this point
  WorkBook.SheetCount += 1;
  WorkBook.Sheets(WorkBook.SheetCount)= WorkSheet.Name;

End-Proc;


// #$XLSXChar- Add a character string to the open XLS file
//     input:  Char   = Field containing the Value to add
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc #$XLSXChar export;
  Dcl-Pi *n;
    Char  Char(4096) const;
    Style Varchar(50) const options(*nopass : *omit);
    Merge zoned(2:0) const options(*nopass : *OMIT);
  End-Pi;

  Dcl-S Field Char(4096);
  Dcl-S i zoned(2);

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXChar':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXChar':4002);
    Return;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If a Style is passed, make sure it has been configured
  If %Parms>=2 and %Addr(Style) <> *null and Style<>'';
    If ValStyle(Style);
      SndMsg('#$XLSXChar':4003:0:Style);
      Return;
    EndIf;
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384 or
     (%Parms>=3 and %Addr(Merge) <> *null and Merge>0
     and WorkSheet.col+1+Merge>16384);
    SndMsg('#$XLSXChar':4004:1);
    #$XLSXNext();
  EndIf;

  // Add to merge array
  If %Parms>=3 and %Addr(Merge) <> *null and Merge>0;
    WorkSheet.MergeCount+=1;
    WorkSheet.Merges(WorkSheet.MergeCount)=colrow() + ':' +
                       colrow(WorkSheet.col+Merge:WorkSheet.row);
  EndIf;

  // Add Value and style to cell if passed
  Field=%Trim(Char);
  If %Parms>=2 and %Addr(Style)<>*null;
    writef(tab+tab+tab+'<c r="'+ColRow()+'" +
                       t="inlineStr" +
                       s="'+GetStyle(Style)+'">'+eor);
  Else;
    writef(tab+tab+tab+'<c r="'+colrow()+'" t="inlineStr">'+eor);
  EndIf;
  writef(tab+tab+tab+tab+'<is>'+eor);
  writef(tab+tab+tab+tab+tab+'<t>'+XMLESC(field)+'</t>'+eor);
  writef(tab+tab+tab+tab+'</is>'+eor);
  writef(tab+tab+tab+'</c>'+eor);

  WorkSheet.col += 1;

  // add blank cells to make up the merged cells
  If %Parms>=3 and %Addr(Merge) <> *null;
    If merge>0;
      For i = 1 To Merge;
        If %Parms>=2 and %Addr(Style)<>*null and Style<>'';
          writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col:
                                             WorkSheet.row)+'" +
                               s="'+GetStyle(Style)+'"/>'+eor);
        Else;
          writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col:
                                     WorkSheet.row)+'" />'+eor);
        EndIf;
        WorkSheet.Col += 1;
      EndFor;
    EndIf;
  EndIf;

End-Proc;


// #$XLSXNumr - Add a number to the open XLSX Sheet
//     input:  Number = Field containing the Value to add
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc #$XLSXNumr EXPORT;
  Dcl-Pi *n;
    Number Zoned(30:10) const;
    Style  Varchar(50)  const options(*nopass:*omit);
    Merge  Zoned(2:0) const options(*nopass : *OMIT);
  End-Pi;

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXNumr':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXNumr':4002);
    Return;
  EndIf;

  // If a Style is passed, make sure it has been configured
  If %Parms>=2 and %Addr(Style) <> *null and Style<>'';
    If ValStyle(Style);
      SndMsg('#$XLSXNumr':4003:0:Style);
      Return;
    EndIf;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384 or
     (%Parms>=3 and %Addr(Merge) <> *null and Merge>0
      and WorkSheet.col+1+Merge>16384);
    SndMsg('#$XLSXNumr':4004:1);
    #$XLSXNext();
  EndIf;

  // Add to merge array
  If %Parms>=3 and %Addr(Merge) <> *null and merge>0;
    WorkSheet.MergeCount+=1;
    WorkSheet.Merges(WorkSheet.MergeCount)=colrow() + ':' +
                       colrow(WorkSheet.col+Merge:WorkSheet.row);
  EndIf;

  // Add Value and style to cell if passed
  If %Parms>=2 and %Addr(Style)<>*null;
    writef(tab+tab+tab+'<c r="'+ColRow()+'" +
                        s="'+GetStyle(Style)+'">'+eor);
  Else;
    writef(tab+tab+tab+'<c r="'+colrow()+'">'+eor);
  EndIf;
  writef(tab+tab+tab+tab+'<v>'+%TrimR(%Char(Number):'0')+'</v>'+eor);
  writef(tab+tab+tab+'</c>'+eor);

  WorkSheet.col += 1;

  // add blank cells to make up the merged cells
  If %Parms>=3 and %Addr(Merge) <> *null;
    If merge>0;
      For i = 1 To Merge;
        If %Parms>=2 and %Addr(Style)<>*null and Style<>'';
          writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col+merge:
                                             WorkSheet.row)+'" +
                                 s="'+GetStyle(Style)+'"/>'+eor);
        Else;
          writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col+merge:
                                WorkSheet.row)+'" />'+eor);
        EndIf;
        WorkSheet.Col += 1;
      EndFor;
    EndIf;
  EndIf;

End-Proc;


// #$XLSXDate- Add a date string to the open XLS file
//     input:  Date   = Field containing the date to add YYYYMMDD
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc #$XLSXDate Export;
  Dcl-Pi *n;
    Date date const;
    psStyle Varchar(50) const options(*nopass:*omit);
    psMerge zoned(2:0) Const options(*nopass : *OMIT);
  End-Pi;
  Dcl-S ExcelDate packed(8:0);
  Dcl-S Style     Varchar(50);
  Dcl-S Merge     packed(2:0);

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXDate':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXDate':4002);
    Return;
  EndIf;

  // If a Style is passed, make sure it has been configured
  If %Parms>=2 and %Addr(Style) <> *null and Style<>'';
    If ValStyle(Style);
      SndMsg('#$XLSXDate':4003:0:Style);
      Return;
    EndIf;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384 or
      (%Parms>=3 and %Addr(Merge) <> *null and Merge>0
       and WorkSheet.col+1+Merge>16384);
    SndMsg('#$XLSXDate':4004:1);
    #$XLSXNext();
  EndIf;

  // get optional parameters
  If %Parms>=2 and %Addr(psStyle) <> *null;
    Style=psStyle;
  Else;
    Style=' ';
  EndIf;
  If %Parms>=3 and %Addr(psMerge) <> *null;
    Merge=psMerge;
  Else;
    Merge=0;
  EndIf;

  // Convert the date to an Excel date
  Monitor;
    ExcelDate=ExcDate(Date);
  On-Error;
    ExcelDate=0;
    SndMsg('#$XLSXDate':4005:1:%Char(date):'a date data field');
  EndMon;

  // Add Value and style to cell if passed
  XLSXDate(ExcelDate:Style:Merge);

End-Proc;

// #$XLSXYYMD- Add a date string to the open XLS file

//     input:  Date   = Field containing the date to add YYYYMMDD
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc #$XLSXYYMD EXPORT;
  Dcl-Pi *n;
    psDate packed(8) const;
    psStyle Varchar(50) const options(*nopass:*omit);
    psMerge packed(2) Const options(*nopass : *OMIT);
  End-Pi;
  Dcl-S ExcelDate zoned(8);
  Dcl-S Style Varchar(50);
  Dcl-S Merge zoned(2);
  Dcl-S Date date;

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXYYMD':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXYYMD':4002);
    Return;
  EndIf;

  // If a Style is passed, make sure it has been configured
  If %Parms>=2 and %Addr(Style) <> *null and Style<>'';
    If ValStyle(Style);
      SndMsg('#$XLSXYYMD':4003:0:Style);
      Return;
    EndIf;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384 or
      (%Parms>=3 and %Addr(Merge) <> *null and Merge>0
       and WorkSheet.col+1+Merge>16384);
    SndMsg('#$XLSXYYMD':4004:1);
    #$XLSXNext();
  EndIf;

  // get optional parameters
  If %Parms>=2 and %Addr(psStyle) <> *null;
    Style=psStyle;
  Else;
    Style=' ';
  EndIf;
  If %Parms>=3 and %Addr(psMerge) <> *null;
    Merge=psMerge;
  Else;
    Merge=0;
  EndIf;

  // Convert the date to an Excel date
  Monitor;
    Date=%Date(psDate : *iso);
    ExcelDate=ExcDate(Date);
  On-Error;
    ExcelDate=0;
    SndMsg('#$XLSXYYMD':4005:1:%Char(psDate):'YYYYMMDD');
  EndMon;

  // Add Value and style to cell if passed
  XLSXDate(ExcelDate:Style:Merge);

End-Proc;

// #$XLSXMDY - Add a date string to the open XLS file

//     input:  Date   = Field containing the date to add MMDDYY
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc #$XLSXMDY EXPORT;
  Dcl-Pi *n;
    psDate packed(6) const;
    psStyle Varchar(50) const options(*nopass:*omit);
    psMerge packed(2) Const options(*nopass : *OMIT);
  End-Pi;
  Dcl-S ExcelDate zoned(8);
  Dcl-S Style Varchar(50);
  Dcl-S Merge zoned(2);
  Dcl-S Date date;

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXMDY':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXMDY':4002);
    Return;
  EndIf;

  // If a Style is passed, make sure it has been configured
  If %Parms>=2 and %Addr(Style) <> *null and Style<>'';
    If ValStyle(Style);
      SndMsg('#$XLSXMDY':4003:0:Style);
      Return;
    EndIf;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384 or
      (%Parms>=3 and %Addr(Merge) <> *null and Merge>0
       and WorkSheet.col+1+Merge>16384);
    SndMsg('#$XLSXMDY':4004:1);
    #$XLSXNext();
  EndIf;

  // get optional parameters
  If %Parms>=2 and %Addr(psStyle) <> *null;
    Style=psStyle;
  Else;
    Style=' ';
  EndIf;
  If %Parms>=3 and %Addr(psMerge) <> *null;
    Merge=psMerge;
  Else;
    Merge=0;
  EndIf;

  // Convert the date to an Excel date
  Monitor;
    Date=%Date(psDate : *MDY);
    ExcelDate=ExcDate(Date);
  On-Error;
    ExcelDate=0;
    SndMsg('#$XLSXMDY':4005:1:%Char(psDate):'MMDDYY');
  EndMon;

  // Add Value and style to cell if passed
  XLSXDate(ExcelDate:Style:Merge);

End-Proc;


// #$XLSXMDYY - Add a date string to the open XLS file
//     input:  Date   = Field containing the date to add MMDDYYYY
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc #$XLSXMDYY EXPORT;
  Dcl-Pi *n;
    psDate packed(8) const;
    psStyle Varchar(50) const options(*nopass:*omit);
    psMerge packed(2) Const options(*nopass : *OMIT);
  End-Pi;
  Dcl-S ExcelDate zoned(8);
  Dcl-S Style Varchar(50);
  Dcl-S Merge zoned(2);
  Dcl-S Date date;

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXMDYY':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXMDYY':4002);
    Return;
  EndIf;

  // If a Style is passed, make sure it has been configured
  If %Parms>=2 and %Addr(Style) <> *null and Style<>'';
    If ValStyle(Style);
      SndMsg('#$XLSXMDYY':4003:0:Style);
      Return;
    EndIf;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384 or
      (%Parms>=3 and %Addr(Merge) <> *null and Merge>0
       and WorkSheet.col+1+Merge>16384);
    SndMsg('#$XLSXMDYY':4004:1);
    #$XLSXNext();
  EndIf;

  // get optional parameters
  If %Parms>=2 and %Addr(psStyle) <> *null;
    Style=psStyle;
  Else;
    Style=' ';
  EndIf;
  If %Parms>=3 and %Addr(psMerge) <> *null;
    Merge=psMerge;
  Else;
    Merge=0;
  EndIf;

  // Convert the date to an Excel date
  Monitor;
    Date=%Date(psDate : *USA);
    ExcelDate=ExcDate(Date);
  On-Error;
    ExcelDate=0;
    SndMsg('#$XLSXMDYY':4005:1:%Char(psDate):'MMDDYYYY');
  EndMon;

  // Add Value and style to cell if passed
  XLSXDate(ExcelDate:Style:Merge);

End-Proc;


// XLSXDate- Add a date to the open XLS file
// this function is used by #$XLSXDate, #$XLSXYYMD, #$XLSXMDY and
// #$XLSXMDYY to actually add the date to the file.
//     input:  Date   = Field containing the date to add YYYYMMDD
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc XLSXDate;
  Dcl-Pi *n;
    ExcelDate packed(9) const;
    Style Varchar(50) const;
    Merge packed(2) Const;
  End-Pi;

  // Add to merge array
  If Merge>0;
    WorkSheet.MergeCount+=1;
    WorkSheet.Merges(WorkSheet.MergeCount)=colrow() + ':' +
                       colrow(WorkSheet.col+Merge:WorkSheet.row);
  EndIf;

  // Add Value and style to cell if passed
  If Style<>'';
    writef(tab+tab+tab+'<c r="'+ColRow()+'" +
                             s="'+GetStyle(Style)+'">'+eor);
  Else;
    writef(tab+tab+tab+'<c r="'+colrow()+'">'+eor);
  EndIf;
  writef(tab+tab+tab+tab+'<v>'+%Trim(%Char(ExcelDate))+
                          '</v>'+eor);
  writef(tab+tab+tab+'</c>'+eor);

  WorkSheet.col += 1;

  // add blank cells to make up the merged cells
  If merge>0;
    For i = 1 To Merge;
      If Style<>'';
        writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col+merge:
                                           WorkSheet.row)+'" +
                               s="'+GetStyle(Style)+'"/>'+eor);
      Else;
        writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col+merge:
                            WorkSheet.row)+'" />'+eor);
      EndIf;
      WorkSheet.Col += 1;
    EndFor;
  EndIf;

End-Proc;


// #$XLSXForm - Add a Formula to the open XLS file
//     input:  Date   = Field containing the formula
//             Style  = Name of a previously defined style
//             Merge  = number of cell to merg into this one.
Dcl-Proc #$XLSXForm EXPORT;
  Dcl-Pi *n;
    #$Form Char(512) Const;
    Style  Varchar(50) const options(*nopass:*omit);
    Merge  packed(2) Const options(*nopass : *OMIT);
  End-Pi;

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXForm':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXForm':4002);
    Return;
  EndIf;

  // If a Style is passed, make sure it has been configured
  If %Parms>=2 and %Addr(Style) <> *null and Style<>'';
    If ValStyle(Style);
      SndMsg('#$XLSXForm':4003:0:Style);
      Return;
    EndIf;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384 or
      (%Parms>=3 and %Addr(Merge) <> *null and Merge>0
       and WorkSheet.col+1+Merge>16384);
    SndMsg('#$XLSXForm':4004:1);
    #$XLSXNext();
  EndIf;

  // Add to merge array
  If %Parms>=3 and %Addr(Merge) <> *null and merge>0;
    WorkSheet.MergeCount+=1;
    WorkSheet.Merges(WorkSheet.MergeCount)=colrow() + ':' +
                       colrow(WorkSheet.col+Merge:WorkSheet.row);
  EndIf;

  // Add Value and style to cell if passed
  If %Parms>=2 and %Addr(Style)<>*null;
    writef(tab+tab+tab+'<c r="'+ColRow()+'" +
                       s="'+GetStyle(Style)+'">'+eor);
  Else;
    writef(tab+tab+tab+'<c r="'+colrow()+'">'+eor);
  EndIf;
  writef(tab+tab+tab+tab+'<f>'+XMLESC(#$Form)+'</f>'+eor);
  writef(tab+tab+tab+'</c>'+eor);

  WorkSheet.col += 1;

  // add blank cells to make up the merged cells
  If %Parms>=3 and %Addr(Merge) <> *null;
    If merge>0;
      For i = 1 To Merge;
        If %Parms>=2 and %Addr(Style)<>*null and Style<>'';
          writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col+merge:
                                           WorkSheet.row)+'" +
                             s="'+GetStyle(Style)+'"/>'+eor);
        Else;
          writef(tab+tab+tab+'<c r="'+ColRow(WorkSheet.col+merge:
                                WorkSheet.row)+'" />'+eor);
        EndIf;
        WorkSheet.Col += 1;
      EndFor;
    EndIf;
  EndIf;

End-Proc;


// ------------------------------------------------------------------ *
// #$XLSXNull - Skips a column, but does not create the cell
// ------------------------------------------------------------------ *
Dcl-Proc #$XLSXnull EXPORT;

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXNull':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXNull':4002);
    Return;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  // If this cell will extend past row 16384 give warning and wrap
  // to the next column
  If WorkSheet.col>16384;
    SndMsg('#$XLSXNull':4004:1);
    #$XLSXNext();
  EndIf;

  WorkSheet.Col += 1;

End-Proc;

// #$XLSXNext - Write a line to the open XLSX file and start the next
//             record
Dcl-Proc #$XLSXNext EXPORT;

  // If the work sheet is not open given an error
  If WorkSheet.Status=0;
    SndMsg('#$XLSXNext':4001);
    Return;
  EndIf;

  // If the work book has already been closed give error
  If WorkSheet.Status=3;
    SndMsg('#$XLSXNext':4002);
    Return;
  EndIf;

  // If data has not been written yet, start it
  If WorkSheet.Status=1;
    StrSheet();
  EndIf;

  WorkSheet.Row += 1;
  WorkSheet.Col = 1;

  // end the previous row and start a new one
  writef(tab+tab+'</row>'+eor);
  writef(tab+tab+'<row r="' + %Char(WorkSheet.Row) + '">'+eor);

End-Proc;

// #$XLSXCell - Returns cell or range to relative current position.
Dcl-Proc #$XLSXCell EXPORT;
  Dcl-Pi *n Varchar(20);
    /Copy #$XLSX1.0/QRPGLESRC,#$XLSXARG
  End-Pi;
  Dcl-S x packed(5);
  Dcl-S VertOffset packed(9);
  Dcl-S HorzOffset packed(9);
  Dcl-S VertRange packed(9);
  Dcl-S HorzRange packed(9);
  Dcl-S BegRangeCol# packed(9);
  Dcl-S BegRangeRow# packed(9);
  Dcl-S Col# packed(9);
  Dcl-S Row# packed(9);
  Dcl-S Output Varchar(20);

  // If the work book is not open given an error
  If Workbook.Status<>1;
    SndMsg('#$XLSXNext':6005);
    Return '';
  EndIf;

  // If the work sheet is not open given an error
  If WorkSheet.Status<>2;
    SndMsg('#$XLSXNext':6006);
    Return '';
  EndIf;

  // Load all parameters into the worksheet data structure
  ExSr loadparms;

  // Validate final range and offsets after all parsm are loaded
  ExSr ValdFinal;

  // Get the current cell based on the offset
  output='';
  Row#=Worksheet.row-VertOffset;
  Col#=Worksheet.col-HorzOffset;
  output=Col(Col#) + %Char(Row#);

  // Add begining cell based on the ranges
  If VertRange<>0 or HorzRange<>0;
    If VertRange<>0;
      Row#-=VertRange-1;
    EndIf;
    If HorzRange<>0;
      Col#-=HorzRange-1;
    EndIf;
    output=Col(Col#) + %Char(Row#) + ':' + output;
  EndIf;

  Return output;

  // Load all parameters into the Style Data Structure
  BegSr LoadParms;

    // load all parameters into the arg datastructure
    ExSr LoadArgs;

    For x=1 To Args.Count;
      ExSr valarg;
      ExSr prcarg;
    EndFor;

  EndSr;

  // load arguments into Args data structure
  /Copy #$XLSX1.0/QRPGLESRC,#$XLSXLARG

  // Validate passed argument
  BegSr ValArg;

    // Validate Keys
    If Args.Arg(x).Key<>'VERTICALRANGE' and
       Args.Arg(x).Key<>'VR' and
       Args.Arg(x).Key<>'HORIZONTALRANGE' and
       Args.Arg(x).Key<>'HR' and
       Args.Arg(x).Key<>'RANGE' and
       Args.Arg(x).Key<>'R' and
       Args.Arg(x).Key<>'VERTICALOFFSET' and
       Args.Arg(x).Key<>'VO' and
       Args.Arg(x).Key<>'HORIZONTALOFFSET' and
       Args.Arg(x).Key<>'HO' and
       Args.Arg(x).Key<>'OFFSET' and
       Args.Arg(x).Key<>'O';
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:6000);
      LeaveSr;
    EndIf;

    // Validation for Vertical Range
    If (Args.Arg(x).Key='VERTICALRANGE' or Args.Arg(x).Key='VR');
      // make sure 1 or 2 parameters are passed
      If (Args.Arg(x).Values<1 or Args.Arg(x).Values>2);
        Args.Arg(x).Error='Y';
        SndMsg('Vertical Range (VR)':6001:0:'1':'2'
               :%Char(Args.Arg(x).Values):Args.Arg(x).Parm);
        LeaveSr;
      EndIf;
      // make sure parameter 1 is a valid number
      If (VNum(Args.Arg(x).Value(1)));
        Args.Arg(x).Error='Y';
        SndMsg('Vertical Range (VR)':6001:0
               :Args.Arg(x).Parm:'1');
        LeaveSr;
      EndIf;
      // make sure parameter 2 is a valid number if passed
      If (Args.Arg(x).Value(2)<>''
          and VNum(Args.Arg(x).Value(2)));
        Args.Arg(x).Error='Y';
        SndMsg('Vertical Range (VR)':6001:0
               :Args.Arg(x).Parm:'2');
        LeaveSr;
      EndIf;
    EndIf;

    // Validation for Horizontal Range
    If (Args.Arg(x).Key='HORIZONTALRANGE' or Args.Arg(x).Key='HR');
      // make sure 1 or 2 parameters are passed
      If (Args.Arg(x).Values<1 or Args.Arg(x).Values>2);
        Args.Arg(x).Error='Y';
        SndMsg('Horizontal Range (HR)':6001:0:'1':'2'
               :%Char(Args.Arg(x).Values):Args.Arg(x).Parm);
        LeaveSr;
      EndIf;
      // make sure parameter 1 is a valid number
      If (VNum(Args.Arg(x).Value(1)));
        Args.Arg(x).Error='Y';
        SndMsg('Horizontal Range (HR)':6001:0
               :Args.Arg(x).Parm:'1');
        LeaveSr;
      EndIf;
      // make sure parameter 2 is a valid number if passed
      If (Args.Arg(x).Value(2)<>''
          and VNum(Args.Arg(x).Value(2)));
        Args.Arg(x).Error='Y';
        SndMsg('Horizontal Range (HR)':6001:0
               :Args.Arg(x).Parm:'2');
        LeaveSr;
      EndIf;
    EndIf;

    // Validation for Range
    If (Args.Arg(x).Key='RANGE' or Args.Arg(x).Key='R');
      // make sure exactly 4 parameters are passed
      If (Args.Arg(x).Values<>4);
        Args.Arg(x).Error='Y';
        SndMsg('Range (R)':6003:0:'4'
               :%Char(Args.Arg(x).Values):Args.Arg(x).Parm);
        LeaveSr;
      EndIf;
      // make sure parameter 1 is a valid number
      If (VNum(Args.Arg(x).Value(1)));
        Args.Arg(x).Error='Y';
        SndMsg('Range (R)':6001:0:Args.Arg(x).Parm:'1');
        LeaveSr;
      EndIf;
      // make sure parameter 2 is a valid number
      If (VNum(Args.Arg(x).Value(2)));
        Args.Arg(x).Error='Y';
        SndMsg('Range (R)':6001:0:Args.Arg(x).Parm:'2');
        LeaveSr;
      EndIf;
      // make sure parameter 3 is a valid number
      If (VNum(Args.Arg(x).Value(3)));
        Args.Arg(x).Error='Y';
        SndMsg('Range (R)':6001:0:Args.Arg(x).Parm:'3');
        LeaveSr;
      EndIf;
      // make sure parameter 4 is a valid number
      If (VNum(Args.Arg(x).Value(4)));
        Args.Arg(x).Error='Y';
        SndMsg('Range (R)':6001:0:Args.Arg(x).Parm:'4');
        LeaveSr;
      EndIf;
    EndIf;

    // Validation for Vertical Offset
    If (Args.Arg(x).Key='VERTICALOFFSET' or Args.Arg(x).Key='VO');
      // make sure 1 parameter is passed
      If (Args.Arg(x).Values<>1);
        Args.Arg(x).Error='Y';
        SndMsg('Vertical Offset (VO)':6003:0:'1'
               :%Char(Args.Arg(x).Values):Args.Arg(x).Parm);
        LeaveSr;
      EndIf;
      // make sure parameter 1 is a valid number
      If (VNum(Args.Arg(x).Value(1)));
        Args.Arg(x).Error='Y';
        SndMsg('Vertical Range (VR)':6001:0
               :Args.Arg(x).Parm:'1');
        LeaveSr;
      EndIf;
    EndIf;

    // Validation for Horizontal Offset
    If (Args.Arg(x).Key='HORIZONTALOFFSET' or Args.Arg(x).Key='HO');
      // make sure 1 parameter is passed
      If (Args.Arg(x).Values<>1);
        Args.Arg(x).Error='Y';
        SndMsg('Horizontal Offset (HO)':6003:0:'1'
               :%Char(Args.Arg(x).Values):Args.Arg(x).Parm);
        LeaveSr;
      EndIf;
      // make sure parameter 1 is a valid number
      If (VNum(Args.Arg(x).Value(1)));
        Args.Arg(x).Error='Y';
        SndMsg('Horizontal Offset (HO)':6002:0
               :Args.Arg(x).Parm:'1');
        LeaveSr;
      EndIf;
    EndIf;

    // Validation for Offset
    If (Args.Arg(x).Key='OFFSET' or Args.Arg(x).Key='O');
      // make sure 1 parameter is passed
      If (Args.Arg(x).Values<>2);
        Args.Arg(x).Error='Y';
        SndMsg('Offset (O)':6003:0:'2'
               :%Char(Args.Arg(x).Values):Args.Arg(x).Parm);
        LeaveSr;
      EndIf;
      // make sure parameter 1 is a valid number
      If (VNum(Args.Arg(x).Value(1)));
        Args.Arg(x).Error='Y';
        SndMsg('Offset (O)':6002:0
               :Args.Arg(x).Parm:'1');
        LeaveSr;
      EndIf;
      // make sure parameter 2 is a valid number
      If (VNum(Args.Arg(x).Value(2)));
        Args.Arg(x).Error='Y';
        SndMsg('Offset (O)':6002:0
               :Args.Arg(x).Parm:'2');
        LeaveSr;
      EndIf;
    EndIf;

  EndSr;

  // Process passed argument
  BegSr PrcArg;

    // skip if the argument is not valid
    If Args.Arg(x).error='Y';
      LeaveSr;
    EndIf;

    // Handle Vertical Range Options
    If (Args.Arg(x).Key='VERTICALRANGE' or Args.Arg(x).Key='VR');
      If (not VNum(Args.Arg(x).Value(1)));
        VertRange = rvl(Args.Arg(x).Value(1));
      EndIf;
      If (not VNum(Args.Arg(x).Value(2)));
        VertOffset = rvl(Args.Arg(x).Value(2)) + 1;
      Else;
        VertOffset = 1;
      EndIf;
    EndIf;

    // Handle Horizontal Range Options
    If (Args.Arg(x).Key='HORIZONTALRANGE' or Args.Arg(x).Key='HR');
      If (not VNum(Args.Arg(x).Value(1)));
        HorzRange = rvl(Args.Arg(x).Value(1));
      EndIf;
      If (not VNum(Args.Arg(x).Value(2)));
        HorzOffset = rvl(Args.Arg(x).Value(2)) + 1;
      Else;
        HorzOffset = 1;
      EndIf;
    EndIf;

    // Handle Range Options
    If (Args.Arg(x).Key='RANGE' or Args.Arg(x).Key='R');
      If not VNum(Args.Arg(x).Value(1));
        VertRange = rvl(Args.Arg(x).Value(1));
      EndIf;
      If not VNum(Args.Arg(x).Value(2));
        HorzRange = rvl(Args.Arg(x).Value(2));
      EndIf;
      If not VNum(Args.Arg(x).Value(3));
        VertOffset = rvl(Args.Arg(x).Value(3));
      EndIf;
      If not VNum(Args.Arg(x).Value(4));
        HorzOffset = rvl(Args.Arg(x).Value(4));
      EndIf;
    EndIf;

    // Handle Vertical Offset Options
    If (Args.Arg(x).Key='VERTICALOFFSET' or Args.Arg(x).Key='VO');
      If (not VNum(Args.Arg(x).Value(1)));
        VertOffset = rvl(Args.Arg(x).Value(1));
      EndIf;
    EndIf;

    // Handle Horizontal Offset Options
    If (Args.Arg(x).Key='HORIZONTALOFFSET' or Args.Arg(x).Key='HO');
      If (not VNum(Args.Arg(x).Value(1)));
        HorzOffset = rvl(Args.Arg(x).Value(1));
      EndIf;
    EndIf;

    // Handle Offset Options
    If (Args.Arg(x).Key='OFFSET' or Args.Arg(x).Key='O');
      If not VNum(Args.Arg(x).Value(1));
        VertOffset = rvl(Args.Arg(x).Value(1));
      EndIf;
      If not VNum(Args.Arg(x).Value(2));
        HorzOffset = rvl(Args.Arg(x).Value(2));
      EndIf;
    EndIf;

  EndSr;

  // Validate all values after all parms are loaded
  BegSr ValdFinal;

    // Make sure a vertical offset doesn't go before the start of the page
    If (Worksheet.row-VertOffset<=0);
      SndMsg('row 1':6004:0:'2'
            :%Char(Worksheet.Row):%Char(Worksheet.Col)
            :'The current Row of ' +
              %Char(Worksheet.Row) +
             ' minus the vertical offset of ' +
              %Char(VertOffset) +
             ' created the invalid cell reference.');
      LeaveSr;
    EndIf;

    // Make sure a horizontal offset doesn't go before the start of the page
    If (Worksheet.col-HorzOffset<=0);
      SndMsg('column 1':6004:0:'2'
            :%Char(Worksheet.Row):%Char(Worksheet.Col)
            :'The current colum of ' +
              %Char(Worksheet.Col) +
             ' minus the horizontal offset of ' +
              %Char(HorzOffset) +
             ' created the invalid cell reference.');
      LeaveSr;
    EndIf;

    // Make sure a vertical offset plus the vertical range
    // doesn't go before the start of the page
    If (Worksheet.row-VertOffset-VertRange+1<=0);
      SndMsg('row 1':6004:0:'2'
            :%Char(Worksheet.Row):%Char(Worksheet.Col)
            :'The current Row of ' +
              %Char(Worksheet.Row) +
             ' minus the vertical offset of ' +
              %Char(VertOffset) +
             ' minus the vertical range of ' +
              %Char(VertRange) +
             ' created the invalid cell reference.');
      LeaveSr;
    EndIf;

    // Make sure a horizontal offset plus the Horizontal range
    // doesn't go before the start of the page
    If (Worksheet.col-HorzOffset-HorzRange+1<=0);
      SndMsg('column 1':6004:0:'2'
            :%Char(Worksheet.Row):%Char(Worksheet.Col)
            :'The current column of ' +
              %Char(Worksheet.Col) +
             ' minus the horizontal offset of ' +
              %Char(HorzOffset) +
             ' minus the horizontal range of ' +
              %Char(HorzRange) +
             ' created the invalid cell reference.');
      LeaveSr;
    EndIf;

  EndSr;

End-Proc;


// #$XLSXC    - Shortcut for #$XLSXCell
Dcl-Proc #$XLSXC EXPORT;
  Dcl-Pi *n Varchar(20);
    type Char(20) const options(*nopass);
    parm1 packed(5) Value options(*nopass);
    parm2 packed(5) Value options(*nopass);
    parm3 packed(5) Value options(*nopass);
    parm4 packed(5) Value options(*nopass);
  End-Pi;
  Dcl-S parms Char(60);

  // build text version of parameters
  If %Parms>=1;
    parms=%Trim(type);
  EndIf;
  If %Parms>=2;
    parms=%Trim(parms) + ':' + %Trim(%Char(parm1));
  EndIf;
  If %Parms>=3;
    parms=%Trim(parms) + ':' + %Trim(%Char(parm2));
  EndIf;
  If %Parms>=4;
    parms=%Trim(parms) + ':' + %Trim(%Char(parm3));
  EndIf;
  If %Parms>=5;
    parms=%Trim(parms) + ':' + %Trim(%Char(parm4));
  EndIf;

  // call #$XLSXCELL and retrun the result
  Return #$XLSXCell(parms);

End-Proc;


// #$XLSXStyle - Shortcut to create a style
Dcl-Proc #$XLSXStyle EXPORT;
  Dcl-Pi *n;
    /Copy #$XLSX1.0/QRPGLESRC,#$XLSXARG
  End-Pi;
  Dcl-S x packed(5);

  // If the work book is not open given an error
  If Workbook.Status<>1;
    SndMsg('':2001:1);
    Return;
  EndIf;

  // setup a new style
  Clear Style;
  Reset Style;

  // Load all parameters into the worksheet data structure
  ExSr loadparms;

  // add new style to workbooks style array
  WorkBook.StyleCount +=1;
  WorkBook.Styles(WorkBook.StyleCount)=Style;

  Return;

  // Load all parameters into the Style Data Structure
  BegSr LoadParms;

    // load all parameters into the arg datastructure
    ExSr LoadArgs;

    For x=1 To Args.Count;
      ExSr valarg;
      ExSr prcarg;
    EndFor;

  EndSr;

  // load arguments into Args data structure
  /Copy #$XLSX1.0/QRPGLESRC,#$XLSXLARG

  // Validate passed argument
  BegSr ValArg;

    // Validate Keys
    If Args.Arg(x).Key<>'NAME' and                    // Style Name
       Args.Arg(x).Key<>'BOLDWEIGHT' and              // Font Options
       Args.Arg(x).Key<>'POINTSIZE' and
       Args.Arg(x).Key<>'FONT' and
       Args.Arg(x).Key<>'COLOR' and
       Args.Arg(x).Key<>'ITALIC' and
       Args.Arg(x).Key<>'STRIKEOUT' and
       Args.Arg(x).Key<>'TYPEOFFSET' and
       Args.Arg(x).Key<>'UNDERLINE' and
       Args.Arg(x).Key<>'ALIGNMENT' and               // Style Options
       Args.Arg(x).Key<>'DATAFORMAT' and
       Args.Arg(x).Key<>'BORDER' and
       Args.Arg(x).Key<>'BORDERBOTTOM' and
       Args.Arg(x).Key<>'BORDERTOP' and
       Args.Arg(x).Key<>'BORDERLEFT' and
       Args.Arg(x).Key<>'BORDERRIGHT' and
       Args.Arg(x).Key<>'BORDERDIAGONAL' and
       Args.Arg(x).Key<>'DIAGONALOPTION' and
       Args.Arg(x).Key<>'BORDERCOLOR' and
       Args.Arg(x).Key<>'WRAPTEXT' and
       Args.Arg(x).Key<>'FILLFOREGROUNDCOLOR' and
       Args.Arg(x).Key<>'FILLBACKGROUNDCOLOR' and
       Args.Arg(x).Key<>'FILLPATTERN' and
       Args.Arg(x).Key<>'VERTICALALIGNMENT';
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:2002:1);
      LeaveSr;
    EndIf;

    // Validate Values
    If Args.Arg(x).Key='NAME' and
       Args.Arg(x).Value(1)=' ';
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='BOLDWEIGHT' and
       (Args.Arg(x).Value(1)<>'NORMAL' and
        Args.Arg(x).Value(1)<>'BOLD');
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='POINTSIZE' and
       (RVL(Args.Arg(x).Value(1))<1 or
        RVL(Args.Arg(x).Value(1))>409);
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='FONT' and
       Args.Arg(x).Value(1)=' ';
      Args.Arg(x).Error='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    // TODO handle RBG and Theme colors
    If (Args.Arg(x).Key='COLOR' or
        Args.Arg(x).Key='FILLFOREGROUNDCOLOR' or
        Args.Arg(x).Key='FILLBACKGROUNDCOLOR' or
        Args.Arg(x).Key='BORDERCOLOR') and
       Args.Arg(x).Value(1)<>'AQUA'            and
       Args.Arg(x).Value(1)<>'49'              and
       Args.Arg(x).Value(1)<>'BLACK'           and
       Args.Arg(x).Value(1)<>'8'               and
       Args.Arg(x).Value(1)<>'BLUE'            and
       Args.Arg(x).Value(1)<>'12'              and
       Args.Arg(x).Value(1)<>'BLUE_GREY'       and
       Args.Arg(x).Value(1)<>'54'              and
       Args.Arg(x).Value(1)<>'BRIGHT_GREEN'    and
       Args.Arg(x).Value(1)<>'11'              and
       Args.Arg(x).Value(1)<>'BROWN'           and
       Args.Arg(x).Value(1)<>'60'              and
       Args.Arg(x).Value(1)<>'CORAL'           and
       Args.Arg(x).Value(1)<>'29'              and
       Args.Arg(x).Value(1)<>'CORNFLOWER_BLUE' and
       Args.Arg(x).Value(1)<>'24'              and
       Args.Arg(x).Value(1)<>'DARK_BLUE'       and
       Args.Arg(x).Value(1)<>'18'              and
       Args.Arg(x).Value(1)<>'DARK_RED'        and
       Args.Arg(x).Value(1)<>'16'              and
       Args.Arg(x).Value(1)<>'DARK_TEAL'       and
       Args.Arg(x).Value(1)<>'46'              and
       Args.Arg(x).Value(1)<>'DARK_YELLOW'     and
       Args.Arg(x).Value(1)<>'19'              and
       Args.Arg(x).Value(1)<>'DARK_GOLD'       and
       Args.Arg(x).Value(1)<>'51'              and
       Args.Arg(x).Value(1)<>'DARK_GREEN'      and
       Args.Arg(x).Value(1)<>'17'              and
       Args.Arg(x).Value(1)<>'GREY_25'         and
       Args.Arg(x).Value(1)<>'22'              and
       Args.Arg(x).Value(1)<>'GREY_40'         and
       Args.Arg(x).Value(1)<>'55'              and
       Args.Arg(x).Value(1)<>'GREY_50'         and
       Args.Arg(x).Value(1)<>'23'              and
       Args.Arg(x).Value(1)<>'GREY_80'         and
       Args.Arg(x).Value(1)<>'63'              and
       Args.Arg(x).Value(1)<>'INDIGO'          and
       Args.Arg(x).Value(1)<>'62'              and
       Args.Arg(x).Value(1)<>'LAVENDER'        and
       Args.Arg(x).Value(1)<>'46'              and
       Args.Arg(x).Value(1)<>'LEMON_CHIFFON'   and
       Args.Arg(x).Value(1)<>'26'              and
       Args.Arg(x).Value(1)<>'LIGHT_BLUE'      and
       Args.Arg(x).Value(1)<>'48'              and
       Args.Arg(x).Value(1)<>'LIGHT_CORNFLOWER_BLUE' and
       Args.Arg(x).Value(1)<>'31'              and
       Args.Arg(x).Value(1)<>'LIGHT_GREEN'     and
       Args.Arg(x).Value(1)<>'42'              and
       Args.Arg(x).Value(1)<>'LIGHT_ORANGE'    and
       Args.Arg(x).Value(1)<>'52'              and
       Args.Arg(x).Value(1)<>'LIGHT_TURQUOISE' and
       Args.Arg(x).Value(1)<>'27'              and
       Args.Arg(x).Value(1)<>'LIGHT_YELLOW'    and
       Args.Arg(x).Value(1)<>'43'              and
       Args.Arg(x).Value(1)<>'LIME'            and
       Args.Arg(x).Value(1)<>'50'              and
       Args.Arg(x).Value(1)<>'MAROON'          and
       Args.Arg(x).Value(1)<>'25'              and
       Args.Arg(x).Value(1)<>'OLIVE_GREEN'     and
       Args.Arg(x).Value(1)<>'59'              and
       Args.Arg(x).Value(1)<>'ORANGE'          and
       Args.Arg(x).Value(1)<>'53'              and
       Args.Arg(x).Value(1)<>'ORCHID'          and
       Args.Arg(x).Value(1)<>'28'           and
       Args.Arg(x).Value(1)<>'PALE_BLUE'       and
       Args.Arg(x).Value(1)<>'44'           and
       Args.Arg(x).Value(1)<>'PINK'            and
       Args.Arg(x).Value(1)<>'14'           and
       Args.Arg(x).Value(1)<>'PLUM'            and
       Args.Arg(x).Value(1)<>'61'           and
       Args.Arg(x).Value(1)<>'RED'             and
       Args.Arg(x).Value(1)<>'10'           and
       Args.Arg(x).Value(1)<>'ROSE'            and
       Args.Arg(x).Value(1)<>'45'           and
       Args.Arg(x).Value(1)<>'ROYAL_BLUE'      and
       Args.Arg(x).Value(1)<>'30'           and
       Args.Arg(x).Value(1)<>'SEA_GREEN'       and
       Args.Arg(x).Value(1)<>'57'           and
       Args.Arg(x).Value(1)<>'SKY_BLUE'        and
       Args.Arg(x).Value(1)<>'40'           and
       Args.Arg(x).Value(1)<>'TAN'             and
       Args.Arg(x).Value(1)<>'47'           and
       Args.Arg(x).Value(1)<>'TEAL'            and
       Args.Arg(x).Value(1)<>'21'           and
       Args.Arg(x).Value(1)<>'TURQUOISE'       and
       Args.Arg(x).Value(1)<>'15'           and
       Args.Arg(x).Value(1)<>'VIOLET'          and
       Args.Arg(x).Value(1)<>'20'           and
       Args.Arg(x).Value(1)<>'WHITE'           and
       Args.Arg(x).Value(1)<>'9'            and
       Args.Arg(x).Value(1)<>'YELLOW'          and
       Args.Arg(x).Value(1)<>'13'           and
       Args.Arg(x).Value(1)<>'NORMAL'          and
       Args.Arg(x).Value(1)<>'32767'        and
       Args.Arg(x).Value(1)<>'AUTOMATIC'       and
       Args.Arg(x).Value(1)<>'64'              and
       %Len(Args.Arg(x).Value(1))<>8;
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='ITALIC' and
       Args.Arg(x).Value(1)<>'ON'    and
       Args.Arg(x).Value(1)<>'*ON'   and
       Args.Arg(x).Value(1)<>'TRUE'  and
       Args.Arg(x).Value(1)<>'1'     and
       Args.Arg(x).Value(1)<>'Y'     and
       Args.Arg(x).Value(1)<>'YES'   and
       Args.Arg(x).Value(1)<>'OFF'   and
       Args.Arg(x).Value(1)<>'*OFF'  and
       Args.Arg(x).Value(1)<>'FALSE' and
       Args.Arg(x).Value(1)<>'0'     and
       Args.Arg(x).Value(1)<>'N'     and
       Args.Arg(x).Value(1)<>'NO'    and
       Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='STRIKEOUT' and
       Args.Arg(x).Value(1)<>'ON'    and
       Args.Arg(x).Value(1)<>'*ON'   and
       Args.Arg(x).Value(1)<>'TRUE'  and
       Args.Arg(x).Value(1)<>'1'     and
       Args.Arg(x).Value(1)<>'Y'     and
       Args.Arg(x).Value(1)<>'YES'   and
       Args.Arg(x).Value(1)<>'OFF'   and
       Args.Arg(x).Value(1)<>'*OFF'  and
       Args.Arg(x).Value(1)<>'FALSE' and
       Args.Arg(x).Value(1)<>'0'     and
       Args.Arg(x).Value(1)<>'N'     and
       Args.Arg(x).Value(1)<>'NO'    and
       Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='TYPEOFFSET' and
       Args.Arg(x).Value(1)<>'NONE' and
       Args.Arg(x).Value(1)<>'0' and
       Args.Arg(x).Value(1)<>'SUB' and
       Args.Arg(x).Value(1)<>'SUBSCRIPT' and
       Args.Arg(x).Value(1)<>'2' and
       Args.Arg(x).Value(1)<>'SUP' and
       Args.Arg(x).Value(1)<>'SUPERSCRIPT' and
       Args.Arg(x).Value(1)<>'SUPER' and
       Args.Arg(x).Value(1)<>'1';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='UNDERLINE' and
       Args.Arg(x).Value(1)<>'NONE' and
       Args.Arg(x).Value(1)<>'YES' and
       Args.Arg(x).Value(1)<>'SINGLE' and
       Args.Arg(x).Value(1)<>'DOUBLE';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='ALIGNMENT' and            // style options
       Args.Arg(x).Value(1)<>'CENTER' and
       Args.Arg(x).Value(1)<>'CENTER_SELECTION' and
       Args.Arg(x).Value(1)<>'FILL' and
       Args.Arg(x).Value(1)<>'GENERAL' and
       Args.Arg(x).Value(1)<>'JUSTIFY' and
       Args.Arg(x).Value(1)<>'LEFT' and
       Args.Arg(x).Value(1)<>'RIGHT';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='ALIGNMENT' and
       Args.Arg(x).Values=2 and
       Args.Arg(x).Value(2)<>'TOP' and
       Args.Arg(x).Value(2)<>'0' and
       Args.Arg(x).Value(2)<>'CENTER' and
       Args.Arg(x).Value(2)<>'1' and
       Args.Arg(x).Value(2)<>'BOTTOM' and
       Args.Arg(x).Value(2)<>'2' and
       Args.Arg(x).Value(2)<>'JUSTIFY' and
       Args.Arg(x).Value(2)<>'3' and
       Args.Arg(x).Value(2)<>'DISTRIBUTED' and
       Args.Arg(x).Value(2)<>'4';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='VERTICALALIGNMENT' and
       Args.Arg(x).Value(1)<>'TOP' and
       Args.Arg(x).Value(1)<>'0' and
       Args.Arg(x).Value(1)<>'CENTER' and
       Args.Arg(x).Value(1)<>'1' and
       Args.Arg(x).Value(1)<>'BOTTOM' and
       Args.Arg(x).Value(1)<>'2' and
       Args.Arg(x).Value(1)<>'JUSTIFY' and
       Args.Arg(x).Value(1)<>'3' and
       Args.Arg(x).Value(1)<>'DISTRIBUTED' and
       Args.Arg(x).Value(1)<>'4';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If (Args.Arg(x).Key='BORDERBOTTOM' or
        Args.Arg(x).Key='BORDERTOP' or
        Args.Arg(x).Key='BORDERLEFT' or
        Args.Arg(x).Key='BORDERRIGHT' or
        Args.Arg(x).Key='BORDERDIAGONAL' ) and
       Args.Arg(x).Value(1)<>'DASH_DOT' and
       Args.Arg(x).Value(1)<>'DASH_DOT_DOT' and
       Args.Arg(x).Value(1)<>'DASHED' and
       Args.Arg(x).Value(1)<>'DOTTED' and
       Args.Arg(x).Value(1)<>'DOUBLE' and
       Args.Arg(x).Value(1)<>'HAIR' and
       Args.Arg(x).Value(1)<>'MEDIUM' and
       Args.Arg(x).Value(1)<>'MEDIUM_DASH_DOT' and
       Args.Arg(x).Value(1)<>'MEDIUM_DASH_DOT_DOT' and
       Args.Arg(x).Value(1)<>'MEDIUM_DASHED' and
       Args.Arg(x).Value(1)<>'THIN' and
       Args.Arg(x).Value(1)<>'NONE';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    // For Border, test up to the first 4 arguments
    If (Args.Arg(x).Key='BORDER');
      For y= 1 To 4;
        If Args.Arg(x).Value(y)<>'DASH_DOT' and
           Args.Arg(x).Value(y)<>'DASH_DOT_DOT' and
           Args.Arg(x).Value(y)<>'DASHED' and
           Args.Arg(x).Value(y)<>'DOTTED' and
           Args.Arg(x).Value(y)<>'DOUBLE' and
           Args.Arg(x).Value(y)<>'HAIR' and
           Args.Arg(x).Value(y)<>'MEDIUM' and
           Args.Arg(x).Value(y)<>'MEDIUM_DASH_DOT' and
           Args.Arg(x).Value(y)<>'MEDIUM_DASH_DOT_DOT' and
           Args.Arg(x).Value(y)<>'MEDIUM_DASHED' and
           Args.Arg(x).Value(y)<>'THIN' and
           Args.Arg(x).Value(y)<>'NONE' and
           Args.Arg(x).Value(y)<>' ';
          Args.Arg(x).ERROR='Y';
          SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(y));
          LeaveSr;
        EndIf;
      EndFor;
    EndIf;

    If Args.Arg(x).Key='DIAGONALOPTION' and
       Args.Arg(x).Value(1)<>'NONE' and
       Args.Arg(x).Value(1)<>'BOTH' and
       Args.Arg(x).Value(1)<>'DOWN' and
       Args.Arg(x).Value(1)<>'UP';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='WRAPTEXT' and
       Args.Arg(x).Value(1)<>'ON' and
       Args.Arg(x).Value(1)<>'OFF' and
       Args.Arg(x).Value(1)<>'*ON' and
       Args.Arg(x).Value(1)<>'*OFF' and
       Args.Arg(x).Value(1)<>'FALSE' and
       Args.Arg(x).Value(1)<>'FALSE' and
       Args.Arg(x).Value(1)<>'1' and
       Args.Arg(x).Value(1)<>'0' and
       Args.Arg(x).Value(1)<>'Y' and
       Args.Arg(x).Value(1)<>'N' and
       Args.Arg(x).Value(1)<>'YES' and
       Args.Arg(x).Value(1)<>'NO';
      Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

    If Args.Arg(x).Key='FILLPATTERN' and
       Args.Arg(x).Value(1)<>'NONE'                       and
       Args.Arg(x).Value(1)<>'SOLID'                      and
       Args.Arg(x).Value(1)<>'75%GRAY'                    and
       Args.Arg(x).Value(1)<>'50%GRAY'                    and
       Args.Arg(x).Value(1)<>'25%GRAY'                    and
       Args.Arg(x).Value(1)<>'12.5%GRAY'                  and
       Args.Arg(x).Value(1)<>'6.25%GRAY'                  and
       Args.Arg(x).Value(1)<>'HORIZONTALSTRIPE'           and
       Args.Arg(x).Value(1)<>'VERTICALSTRIPE'             and
       Args.Arg(x).Value(1)<>'REVERSEDIAGONALSTRIPE'      and
       Args.Arg(x).Value(1)<>'DIAGONALSTRIPE'             and
       Args.Arg(x).Value(1)<>'DIAGONALCROSSHATCH'         and
       Args.Arg(x).Value(1)<>'THICKDIAGONALCROSSHATCH'    and
       Args.Arg(x).Value(1)<>'THINHORIZONTALSTRIPE'       and
       Args.Arg(x).Value(1)<>'THINVERTICALSTRIPE'         and
       Args.Arg(x).Value(1)<>'THINREVERSEDIAGONALSTRIPE'  and
       Args.Arg(x).Value(1)<>'THINDIAGONALSTRIPE'         and
       Args.Arg(x).Value(1)<>'THINCROSSHATCH'             and
       Args.Arg(x).Value(1)<>'THINDIAGONALCROSSHATCH'     and
       Args.Arg(x).Value(1)<>'SOLID'              and
       Args.Arg(x).Value(1)<>'LIGHTGRAY'          and
       Args.Arg(x).Value(1)<>'MEDIUMGRAY'         and
       Args.Arg(x).Value(1)<>'DARKGRAY'           and
       Args.Arg(x).Value(1)<>'GRAY125'            and
       Args.Arg(x).Value(1)<>'GRAY0625'           and
       Args.Arg(x).Value(1)<>'DARKHORIZONTAL'     and
       Args.Arg(x).Value(1)<>'DARKVERTICAL'       and
       Args.Arg(x).Value(1)<>'DARKDOWN'           and
       Args.Arg(x).Value(1)<>'DARKUP'             and
       Args.Arg(x).Value(1)<>'DARKGRID'           and
       Args.Arg(x).Value(1)<>'DARKTRELLIS'        and
       Args.Arg(x).Value(1)<>'LIGHTHORIZONTAL'    and
       Args.Arg(x).Value(1)<>'LIGHTVERTICAL'      and
       Args.Arg(x).Value(1)<>'LIGHTDOWN'          and
       Args.Arg(x).Value(1)<>'LIGHTUP'            and
       Args.Arg(x).Value(1)<>'LIGHTGRID'          and
       Args.Arg(x).Value(1)<>'LIGHTTRELLIS'       and
       Args.Arg(x).Value(1)<>'0'                  and
       Args.Arg(x).Value(1)<>'1'                  and
       Args.Arg(x).Value(1)<>'2'                  and
       Args.Arg(x).Value(1)<>'3'                  and
       Args.Arg(x).Value(1)<>'4'                  and
       Args.Arg(x).Value(1)<>'5'                  and
       Args.Arg(x).Value(1)<>'6'                  and
       Args.Arg(x).Value(1)<>'7'                  and
       Args.Arg(x).Value(1)<>'8'                  and
       Args.Arg(x).Value(1)<>'9'                  and
       Args.Arg(x).Value(1)<>'A'                  and
       Args.Arg(x).Value(1)<>'B'                  and
       Args.Arg(x).Value(1)<>'C'                  and
       Args.Arg(x).Value(1)<>'D'                  and
       Args.Arg(x).Value(1)<>'E'                  and
       Args.Arg(x).Value(1)<>'F'                  and
       Args.Arg(x).Value(1)<>'G'                  and
       Args.Arg(x).Value(1)<>'H'                  and
       Args.Arg(x).Value(1)<>'I'                  and
       Args.Arg(x).ERROR='Y';
      SndMsg(Args.Arg(x).Key:2003:1:Args.Arg(x).Value(1));
      LeaveSr;
    EndIf;

  EndSr;

  // Process passed argument
  BegSr PrcArg;

    // skip if the argument is not valid
    If Args.Arg(x).error='Y';
      LeaveSr;
    EndIf;


    // Set Values
    If Args.Arg(x).Key='NAME';
      Style.Name=Args.Arg(x).Value(1);
    EndIf;

    If Args.Arg(x).Key='BOLDWEIGHT';
      If Args.Arg(x).Value(1)='NORMAL';
        Style.FontWeight=' ';
      EndIf;
      If Args.Arg(x).Value(1)='BOLD';
        Style.FontWeight='Y';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='POINTSIZE' and
       RVL(Args.Arg(x).Value(1))>=1 and
       RVL(Args.Arg(x).Value(1))<=409;
      Style.FontSize=RVL(Args.Arg(x).Value(1));
    EndIf;

    If Args.Arg(x).Key='FONT';
      Style.Font=%Trim(Args.Arg(x).Value(1));
    EndIf;

    // TODO handle RBG and Theme colors
    If Args.Arg(x).Key='COLOR';
      Style.Color=GetColor(Args.Arg(x).Value(1));
    EndIf;

    If Args.Arg(x).Key='ITALIC';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON' or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y' or
         Args.Arg(x).Value(1)='1' or
         Args.Arg(x).value(1)='TRUE';
        Style.Italic='Y';
      Else;
        Style.Italic=' ';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='STRIKEOUT';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON' or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y' or
         Args.Arg(x).Value(1)='1' or
         Args.Arg(x).value(1)='TRUE';
        Style.StrikeOut='Y';
      Else;
        Style.StrikeOut=' ';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='TYPEOFFSET';
      If Args.Arg(x).Value(1)='SUB' or
             Args.Arg(x).Value(1)='SUBSCRIPT' or
             Args.Arg(x).Value(1)='2';
        Style.TypeOffset='S';
      ElseIf Args.Arg(x).Value(1)='SUP' or
             Args.Arg(x).Value(1)='SUPER' or
             Args.Arg(x).Value(1)='SUPERSCRIPT' or
             Args.Arg(x).Value(1)='1';
        Style.TypeOffset='P';
      Else;
        Style.TypeOffset=' ';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='UNDERLINE';
      If Args.Arg(x).Value(1)='SINGLE' or
         Args.Arg(x).Value(1)='YES';
        Style.Underline='1';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.Underline='2';
      Else;
        Style.Underline=' ';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='FILLFOREGROUNDCOLOR';
      Style.FillForeground=GetColor(Args.Arg(x).Value(1));
    EndIf;

    If Args.Arg(x).Key='FILLBACKGROUNDCOLOR';
      Style.FillBackground=GetColor(Args.Arg(x).Value(1));
    EndIf;

    If Args.Arg(x).Key='ALIGNMENT';
      If Args.Arg(x).Value(1)='GENERAL';
        Style.Alignment=' ';
      ElseIf Args.Arg(x).Value(1)='LEFT';
        Style.Alignment='1';
      ElseIf Args.Arg(x).Value(1)='RIGHT';
        Style.Alignment='2';
      ElseIf Args.Arg(x).Value(1)='CENTER';
        Style.Alignment='3';
      ElseIf Args.Arg(x).Value(1)='JUSTIFY';
        Style.Alignment='4';
      ElseIf Args.Arg(x).Value(1)='CENTER_SELECTION';
        Style.Alignment='5';
      ElseIf Args.Arg(x).Value(1)='FILL';
        Style.Alignment='6';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='DATAFORMAT';
      Style.DataFormat=Args.Arg(x).Value(1);
    EndIf;

    // handle BORDER with one value, change all borders
    If Args.Arg(x).Key='BORDER' and Args.Arg(x).Values=1;
      If Args.Arg(x).Value(1)='NONE';
        Style.BottomBorder=' ';
        Style.TopBorder   =' ';
        Style.LeftBorder  =' ';
        Style.RightBorder =' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.BottomBorder='1';
        Style.TopBorder   ='1';
        Style.LeftBorder  ='1';
        Style.RightBorder ='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.BottomBorder='2';
        Style.TopBorder   ='2';
        Style.LeftBorder  ='2';
        Style.RightBorder ='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.BottomBorder='3';
        Style.TopBorder   ='3';
        Style.LeftBorder  ='3';
        Style.RightBorder ='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.BottomBorder='4';
        Style.TopBorder   ='4';
        Style.LeftBorder  ='4';
        Style.RightBorder ='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.BottomBorder='5';
        Style.TopBorder   ='5';
        Style.LeftBorder  ='5';
        Style.RightBorder ='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.BottomBorder='6';
        Style.TopBorder   ='6';
        Style.LeftBorder  ='6';
        Style.RightBorder ='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.BottomBorder='7';
        Style.TopBorder   ='7';
        Style.LeftBorder  ='7';
        Style.RightBorder ='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.BottomBorder='8';
        Style.TopBorder   ='8';
        Style.LeftBorder  ='8';
        Style.RightBorder ='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.BottomBorder='9';
        Style.TopBorder   ='9';
        Style.LeftBorder  ='9';
        Style.RightBorder ='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.BottomBorder='A';
        Style.TopBorder   ='A';
        Style.LeftBorder  ='A';
        Style.RightBorder ='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.BottomBorder='B';
        Style.TopBorder   ='B';
        Style.LeftBorder  ='B';
        Style.RightBorder ='B';
      EndIf;
    EndIf;

    // handle BORDER with two values,
    //   value 1 = top and bottom
    //   value 2 = left and right
    If Args.Arg(x).Key='BORDER' and Args.Arg(x).Values=2;
      If Args.Arg(x).Value(1)='NONE';
        Style.BottomBorder=' ';
        Style.TopBorder   =' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.BottomBorder='1';
        Style.TopBorder   ='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.BottomBorder='2';
        Style.TopBorder   ='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.BottomBorder='3';
        Style.TopBorder   ='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.BottomBorder='4';
        Style.TopBorder   ='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.BottomBorder='5';
        Style.TopBorder   ='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.BottomBorder='6';
        Style.TopBorder   ='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.BottomBorder='7';
        Style.TopBorder   ='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.BottomBorder='8';
        Style.TopBorder   ='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.BottomBorder='9';
        Style.TopBorder   ='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.BottomBorder='A';
        Style.TopBorder   ='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.BottomBorder='B';
        Style.TopBorder   ='B';
      EndIf;
      If Args.Arg(x).Value(2)='NONE';
        Style.LeftBorder  =' ';
        Style.RightBorder =' ';
      ElseIf Args.Arg(x).Value(2)='THIN';
        Style.LeftBorder  ='1';
        Style.RightBorder ='1';
      ElseIf Args.Arg(x).Value(2)='MEDIUM';
        Style.LeftBorder  ='2';
        Style.RightBorder ='2';
      ElseIf Args.Arg(x).Value(2)='HAIR';
        Style.LeftBorder  ='3';
        Style.RightBorder ='3';
      ElseIf Args.Arg(x).Value(2)='DASHED';
        Style.LeftBorder  ='4';
        Style.RightBorder ='4';
      ElseIf Args.Arg(x).Value(2)='DOTTED';
        Style.LeftBorder  ='5';
        Style.RightBorder ='5';
      ElseIf Args.Arg(x).Value(2)='DOUBLE';
        Style.LeftBorder  ='6';
        Style.RightBorder ='6';
      ElseIf Args.Arg(x).Value(2)='DASH_DOT';
        Style.LeftBorder  ='7';
        Style.RightBorder ='7';
      ElseIf Args.Arg(x).Value(2)='DASH_DOT_DOT';
        Style.LeftBorder  ='8';
        Style.RightBorder ='8';
      ElseIf Args.Arg(x).Value(2)='MEDIUM_DASH_DOT';
        Style.LeftBorder  ='9';
        Style.RightBorder ='9';
      ElseIf Args.Arg(x).Value(2)='MEDIUM_DASH_DOT_DOT';
        Style.LeftBorder  ='A';
        Style.RightBorder ='A';
      ElseIf Args.Arg(x).Value(2)='MEDIUM_DASHED';
        Style.LeftBorder  ='B';
        Style.RightBorder ='B';
      EndIf;
    EndIf;

    // handle BORDER with four values,
    //   value 1 = top
    //   value 2 = bottom
    //   value 3 = left
    //   value 4 = right
    If Args.Arg(x).Key='BORDER' and Args.Arg(x).Values=4;
      If Args.Arg(x).Value(1)='NONE';
        Style.TopBorder   =' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.TopBorder   ='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.TopBorder   ='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.TopBorder   ='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.TopBorder   ='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.TopBorder   ='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.TopBorder   ='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.TopBorder   ='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.TopBorder   ='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.TopBorder   ='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.TopBorder   ='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.TopBorder   ='B';
      EndIf;
      If Args.Arg(x).Value(2)='NONE';
        Style.BottomBorder=' ';
      ElseIf Args.Arg(x).Value(2)='THIN';
        Style.BottomBorder='1';
      ElseIf Args.Arg(x).Value(2)='MEDIUM';
        Style.BottomBorder='2';
      ElseIf Args.Arg(x).Value(2)='HAIR';
        Style.BottomBorder='3';
      ElseIf Args.Arg(x).Value(2)='DASHED';
        Style.BottomBorder='4';
      ElseIf Args.Arg(x).Value(2)='DOTTED';
        Style.BottomBorder='5';
      ElseIf Args.Arg(x).Value(2)='DOUBLE';
        Style.BottomBorder='6';
      ElseIf Args.Arg(x).Value(2)='DASH_DOT';
        Style.BottomBorder='7';
      ElseIf Args.Arg(x).Value(2)='DASH_DOT_DOT';
        Style.BottomBorder='8';
      ElseIf Args.Arg(x).Value(2)='MEDIUM_DASH_DOT';
        Style.BottomBorder='9';
      ElseIf Args.Arg(x).Value(2)='MEDIUM_DASH_DOT_DOT';
        Style.BottomBorder='A';
      ElseIf Args.Arg(x).Value(2)='MEDIUM_DASHED';
        Style.BottomBorder='B';
      EndIf;
      If Args.Arg(x).Value(3)='NONE';
        Style.LeftBorder  =' ';
      ElseIf Args.Arg(x).Value(3)='THIN';
        Style.LeftBorder  ='1';
      ElseIf Args.Arg(x).Value(3)='MEDIUM';
        Style.LeftBorder  ='2';
      ElseIf Args.Arg(x).Value(3)='HAIR';
        Style.LeftBorder  ='3';
      ElseIf Args.Arg(x).Value(3)='DASHED';
        Style.LeftBorder  ='4';
      ElseIf Args.Arg(x).Value(3)='DOTTED';
        Style.LeftBorder  ='5';
      ElseIf Args.Arg(x).Value(3)='DOUBLE';
        Style.LeftBorder  ='6';
      ElseIf Args.Arg(x).Value(3)='DASH_DOT';
        Style.LeftBorder  ='7';
      ElseIf Args.Arg(x).Value(3)='DASH_DOT_DOT';
        Style.LeftBorder  ='8';
      ElseIf Args.Arg(x).Value(3)='MEDIUM_DASH_DOT';
        Style.LeftBorder  ='9';
      ElseIf Args.Arg(x).Value(3)='MEDIUM_DASH_DOT_DOT';
        Style.LeftBorder  ='A';
      ElseIf Args.Arg(x).Value(3)='MEDIUM_DASHED';
        Style.LeftBorder  ='B';
      EndIf;
      If Args.Arg(x).Value(4)='NONE';
        Style.RightBorder =' ';
      ElseIf Args.Arg(x).Value(4)='THIN';
        Style.RightBorder ='1';
      ElseIf Args.Arg(x).Value(4)='MEDIUM';
        Style.RightBorder ='2';
      ElseIf Args.Arg(x).Value(4)='HAIR';
        Style.RightBorder ='3';
      ElseIf Args.Arg(x).Value(4)='DASHED';
        Style.RightBorder ='4';
      ElseIf Args.Arg(x).Value(4)='DOTTED';
        Style.RightBorder ='5';
      ElseIf Args.Arg(x).Value(4)='DOUBLE';
        Style.RightBorder ='6';
      ElseIf Args.Arg(x).Value(4)='DASH_DOT';
        Style.RightBorder ='7';
      ElseIf Args.Arg(x).Value(4)='DASH_DOT_DOT';
        Style.RightBorder ='8';
      ElseIf Args.Arg(x).Value(4)='MEDIUM_DASH_DOT';
        Style.RightBorder ='9';
      ElseIf Args.Arg(x).Value(4)='MEDIUM_DASH_DOT_DOT';
        Style.RightBorder ='A';
      ElseIf Args.Arg(x).Value(4)='MEDIUM_DASHED';
        Style.RightBorder ='B';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='BORDERBOTTOM';
      If Args.Arg(x).Value(1)='NONE';
        Style.BottomBorder=' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.BottomBorder='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.BottomBorder='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.BottomBorder='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.BottomBorder='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.BottomBorder='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.BottomBorder='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.BottomBorder='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.BottomBorder='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.BottomBorder='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.BottomBorder='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.BottomBorder='B';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='BORDERTOP';
      If Args.Arg(x).Value(1)='NONE';
        Style.TopBorder=' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.TopBorder='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.TopBorder='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.TopBorder='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.TopBorder='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.TopBorder='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.TopBorder='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.TopBorder='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.TopBorder='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.TopBorder='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.TopBorder='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.TopBorder='B';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='BORDERLEFT';
      If Args.Arg(x).Value(1)='NONE';
        Style.LeftBorder=' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.LeftBorder='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.LeftBorder='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.LeftBorder='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.LeftBorder='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.LeftBorder='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.LeftBorder='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.LeftBorder='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.LeftBorder='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.LeftBorder='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.LeftBorder='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.LeftBorder='B';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='BORDERRIGHT';
      If Args.Arg(x).Value(1)='NONE';
        Style.RightBorder=' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.RightBorder='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.RightBorder='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.RightBorder='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.RightBorder='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.RightBorder='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.RightBorder='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.RightBorder='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.RightBorder='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.RightBorder='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.RightBorder='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.RightBorder='B';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='BORDERDIAGONAL';
      If Args.Arg(x).Value(1)='NONE';
        Style.DiagonalBorder=' ';
      ElseIf Args.Arg(x).Value(1)='THIN';
        Style.DiagonalBorder='1';
      ElseIf Args.Arg(x).Value(1)='MEDIUM';
        Style.DiagonalBorder='2';
      ElseIf Args.Arg(x).Value(1)='HAIR';
        Style.DiagonalBorder='3';
      ElseIf Args.Arg(x).Value(1)='DASHED';
        Style.DiagonalBorder='4';
      ElseIf Args.Arg(x).Value(1)='DOTTED';
        Style.DiagonalBorder='5';
      ElseIf Args.Arg(x).Value(1)='DOUBLE';
        Style.DiagonalBorder='6';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT';
        Style.DiagonalBorder='7';
      ElseIf Args.Arg(x).Value(1)='DASH_DOT_DOT';
        Style.DiagonalBorder='8';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT';
        Style.DiagonalBorder='9';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASH_DOT_DOT';
        Style.DiagonalBorder='A';
      ElseIf Args.Arg(x).Value(1)='MEDIUM_DASHED';
        Style.DiagonalBorder='B';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='DIAGONALOPTION';
      If Args.Arg(x).Value(1)='NONE';
        Style.DiagonalOption=' ';
      ElseIf Args.Arg(x).Value(1)='BOTH';
        Style.DiagonalOption='1';
      ElseIf Args.Arg(x).Value(1)='DOWN';
        Style.DiagonalOption='2';
      ElseIf Args.Arg(x).Value(1)='UP';
        Style.DiagonalOption='3';
      EndIf;
    EndIf;

    // TODO handle RBG and Theme colors
    If Args.Arg(x).Key='BORDERCOLOR';
      Style.BorderColor=GetColor(Args.Arg(x).Value(1));
    EndIf;

    If Args.Arg(x).Key='WRAPTEXT';
      If Args.Arg(x).Value(1)='*ON' or
         Args.Arg(x).Value(1)='ON' or
         Args.Arg(x).Value(1)='YES' or
         Args.Arg(x).Value(1)='Y' or
         Args.Arg(x).Value(1)='1' or
         Args.Arg(x).value(1)='TRUE';
        Style.WrapText='1';
      Else;
        Style.WrapText=' ';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='FILLPATTERN';
      If Args.Arg(x).Value(1)='NONE' or
         Args.Arg(x).Value(1)='0';
        Style.FillStyle='0';
      ElseIf Args.Arg(x).Value(1)='SOLID' or
             Args.Arg(x).Value(1)='1';
        Style.FillStyle='1';
      ElseIf Args.Arg(x).Value(1)='75%GRAY' or
             Args.Arg(x).Value(1)='LIGHTGRAY' or
             Args.Arg(x).Value(1)='2';
        Style.FillStyle='2';
      ElseIf Args.Arg(x).Value(1)='50%GRAY' or
             Args.Arg(x).Value(1)='MEDIUMGRAY' or
             Args.Arg(x).Value(1)='3';
        Style.FillStyle='3';
      ElseIf Args.Arg(x).Value(1)='25%GRAY' or
             Args.Arg(x).Value(1)='DARKGRAY' or
             Args.Arg(x).Value(1)='4';
        Style.FillStyle='4';
      ElseIf Args.Arg(x).Value(1)='12.5%GRAY' or
             Args.Arg(x).Value(1)='GRAY125' or
             Args.Arg(x).Value(1)='5';
        Style.FillStyle='5';
      ElseIf Args.Arg(x).Value(1)='6.25%GRAY' or
             Args.Arg(x).Value(1)='GRAY0625' or
             Args.Arg(x).Value(1)='6';
        Style.FillStyle='6';
      ElseIf Args.Arg(x).Value(1)='HORIZONTALSTRIPE' or
             Args.Arg(x).Value(1)='DARKHORIZONTAL' or
             Args.Arg(x).Value(1)='7';
        Style.FillStyle='7';
      ElseIf Args.Arg(x).Value(1)='VERTICALSTRIPE' or
             Args.Arg(x).Value(1)='DARKVERTICAL' or
             Args.Arg(x).Value(1)='8';
        Style.FillStyle='8';
      ElseIf Args.Arg(x).Value(1)='REVERSEDIAGONALSTRIPE' or
             Args.Arg(x).Value(1)='DARKDOWN' or
             Args.Arg(x).Value(1)='9';
        Style.FillStyle='9';
      ElseIf Args.Arg(x).Value(1)='DIAGONALSTRIPE' or
             Args.Arg(x).Value(1)='DARKUP' or
             Args.Arg(x).Value(1)='A';
        Style.FillStyle='A';
      ElseIf Args.Arg(x).Value(1)='DIAGONALCROSSHATCH' or
             Args.Arg(x).Value(1)='DARKGRID' or
             Args.Arg(x).Value(1)='B';
        Style.FillStyle='B';
      ElseIf Args.Arg(x).Value(1)='THICKDIAGONALCROSSHATCH' or
             Args.Arg(x).Value(1)='DARKTRELLIS' or
             Args.Arg(x).Value(1)='C';
        Style.FillStyle='C';
      ElseIf Args.Arg(x).Value(1)='THINHORIZONTALSTRIPE' or
             Args.Arg(x).Value(1)='LIGHTHORIZONTAL' or
             Args.Arg(x).Value(1)='D';
        Style.FillStyle='D';
      ElseIf Args.Arg(x).Value(1)='THINVERTICALSTRIPE' or
             Args.Arg(x).Value(1)='LIGHTVERTICAL' or
             Args.Arg(x).Value(1)='E';
        Style.FillStyle='E';
      ElseIf Args.Arg(x).Value(1)='THINREVERSEDIAGONALSTRIPE' or
             Args.Arg(x).Value(1)='LIGHTDOWN' or
             Args.Arg(x).Value(1)='F';
        Style.FillStyle='F';
      ElseIf Args.Arg(x).Value(1)='THINDIAGONALSTRIPE' or
             Args.Arg(x).Value(1)='LIGHTUP' or
             Args.Arg(x).Value(1)='G';
        Style.FillStyle='G';
      ElseIf Args.Arg(x).Value(1)='THINCROSSHATCH' or
             Args.Arg(x).Value(1)='LIGHTGRID' or
             Args.Arg(x).Value(1)='H';
        Style.FillStyle='H';
      ElseIf Args.Arg(x).Value(1)='THINDIAGONALCROSSHATCH' or
             Args.Arg(x).Value(1)='LIGHTTRELLIS' or
             Args.Arg(x).Value(1)='I';
        Style.FillStyle='I';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='ALIGNMENT' and Args.Arg(x).Values=2;
      If Args.Arg(x).Value(2)='DEFAULT' or
         Args.Arg(x).Value(2)='0';
        Style.VAlignment=' ';
      ElseIf Args.Arg(x).Value(2)='BOTTOM' or
         Args.Arg(x).Value(2)='1';
        Style.VAlignment='1';
      ElseIf Args.Arg(x).Value(2)='TOP' or
         Args.Arg(x).Value(2)='2';
        Style.VAlignment='2';
      ElseIf Args.Arg(x).Value(2)='CENTER' or
         Args.Arg(x).Value(2)='3';
        Style.VAlignment='3';
      ElseIf Args.Arg(x).Value(2)='JUSTIFY' or
         Args.Arg(x).Value(2)='4';
        Style.VAlignment='4';
      ElseIf Args.Arg(x).Value(2)='DISTRIBUTED' or
         Args.Arg(x).Value(2)='5';
        Style.VAlignment='5';
      EndIf;
    EndIf;

    If Args.Arg(x).Key='VERTICALALIGNMENT';
      If Args.Arg(x).Value(1)='DEFAULT' or
         Args.Arg(x).Value(1)='0';
        Style.VAlignment=' ';
      ElseIf Args.Arg(x).Value(1)='BOTTOM' or
         Args.Arg(x).Value(1)='1';
        Style.VAlignment='1';
      ElseIf Args.Arg(x).Value(1)='TOP' or
         Args.Arg(x).Value(1)='2';
        Style.VAlignment='2';
      ElseIf Args.Arg(x).Value(1)='CENTER' or
         Args.Arg(x).Value(1)='3';
        Style.VAlignment='3';
      ElseIf Args.Arg(x).Value(1)='JUSTIFY' or
         Args.Arg(x).Value(1)='4';
        Style.VAlignment='4';
      ElseIf Args.Arg(x).Value(1)='DISTRIBUTED' or
         Args.Arg(x).Value(1)='5';
        Style.VAlignment='5';
      EndIf;
    EndIf;

  EndSr;

End-Proc;


// GetColor - Convert color codes to a color value
Dcl-Proc GetColor;
  Dcl-Pi *n Char(8);
    Value Char(30) const;
  End-Pi;

  If Value='AQUA' or Value='49';
    Return '49';
  ElseIf Value='BLACK' or Value='8';
    Return '8';
  ElseIf Value='BLUE' or Value='12';
    Return '12';
  ElseIf Value='BLUE_GREY' or Value='54';
    Return '54';
  ElseIf Value='BRIGHT_GREEN' or Value='11';
    Return '11';
  ElseIf Value='BROWN' or Value='60';
    Return '60';
  ElseIf Value='CORAL' or Value='29';
    Return '29';
  ElseIf Value='CORNFLOWER_BLUE' or Value='24';
    Return '24';
  ElseIf Value='DARK_BLUE' or Value='18';
    Return '18';
  ElseIf Value='DARK_RED' or Value='16';
    Return '16';
  ElseIf Value='DARK_TEAL' or Value='46';
    Return '46';
  ElseIf Value='DARK_YELLOW' or Value='19';
    Return '19';
  ElseIf Value='DARK_GOLD' or Value='51';
    Return '51';
  ElseIf Value='DARK_GREEN' or Value='17';
    Return '17';
  ElseIf Value='GREY_25' or Value='22';
    Return '22';
  ElseIf Value='GREY_40' or Value='55';
    Return '55';
  ElseIf Value='GREY_50' or Value='23';
    Return '23';
  ElseIf Value='GREY_80' or Value='63';
    Return '63';
  ElseIf Value='INDIGO' or Value='62';
    Return '62';
  ElseIf Value='LAVENDER' or Value='46';
    Return '46';
  ElseIf Value='LEMON_CHIFFON' or Value='26';
    Return '26';
  ElseIf Value='LIGHT_BLUE' or Value='48';
    Return '48';
  ElseIf Value='LIGHT_CORNFLOWER_BLUE' or Value='31';
    Return '31';
  ElseIf Value='LIGHT_GREEN' or Value='42';
    Return '42';
  ElseIf Value='LIGHT_ORANGE' or Value='52';
    Return '52';
  ElseIf Value='LIGHT_TURQUOISE' or Value='27';
    Return '27';
  ElseIf Value='LIGHT_YELLOW' or Value='43';
    Return '43';
  ElseIf Value='LIME' or Value='50';
    Return '50';
  ElseIf Value='MAROON' or Value='25';
    Return '25';
  ElseIf Value='OLIVE_GREEN' or Value='59';
    Return '59';
  ElseIf Value='ORANGE' or Value='53';
    Return '53';
  ElseIf Value='ORCHID' or Value='28';
    Return '28';
  ElseIf Value='PALE_BLUE' or Value='44';
    Return '44';
  ElseIf Value='PINK' or Value='14';
    Return '14';
  ElseIf Value='PLUM' or Value='61';
    Return '61';
  ElseIf Value='RED' or Value='10';
    Return '10';
  ElseIf Value='ROSE' or Value='45';
    Return '45';
  ElseIf Value='ROYAL_BLUE' or Value='30';
    Return '30';
  ElseIf Value='SEA_GREEN' or Value='57';
    Return '57';
  ElseIf Value='SKY_BLUE' or Value='40';
    Return '40';
  ElseIf Value='TAN' or Value='47';
    Return '47';
  ElseIf Value='TEAL' or Value='21';
    Return '21';
  ElseIf Value='TURQUOISE' or Value='15';
    Return '15';
  ElseIf Value='VIOLET' or Value='20';
    Return '20';
  ElseIf Value='WHITE' or Value='9';
    Return '9';
  ElseIf Value='YELLOW' or Value='13';
    Return '13';
  ElseIf Value='NORMAL' or Value='32767';
    Return '32767';
  ElseIf Value='AUTOMATIC' or Value='64';
    Return '64';
  EndIf;

  Return %subst(Value:1:8);

End-Proc;

// ------------------------------------------------------------------ *
// Color2RBG - Convert color codes to a HEX RBG Value
// ------------------------------------------------------------------ *
Dcl-Proc Color2RBG;
  Dcl-Pi *n Char(6);
    Value Char(30) const;
  End-Pi;

  If Value='AQUA' or Value='49';
    Return '33CCCC';
  ElseIf Value='BLACK' or Value='8' or Value='0';
    Return '000000';
  ElseIf Value='BLUE' or Value='12' or Value='4' or Value='39';
    Return '0000FF';
  ElseIf Value='BLUE_GREY' or Value='54';
    Return '666699';
  ElseIf Value='BRIGHT_GREEN' or Value='11';
    Return '00FF00';
  ElseIf Value='BROWN' or Value='60';
    Return '993300';
  ElseIf Value='CORAL' or Value='29';
    Return 'FF8080';
  ElseIf Value='CORNFLOWER_BLUE' or Value='24';
    Return '9999FF';
  ElseIf Value='DARK_BLUE' or Value='18';
    Return '000080';
  ElseIf Value='DARK_RED' or Value='16';
    Return '800000';
  ElseIf Value='DARK_TEAL' or Value='46';
    Return 'CC99FF';
  ElseIf Value='DARK_YELLOW' or Value='19';
    Return '808000';
  ElseIf Value='DARK_GOLD' or Value='51';
    Return 'FFCC00';
  ElseIf Value='GREEN' or Value='17';
    Return '008000';
  ElseIf Value='GREY_25' or Value='22';
    Return 'C0C0C0';
  ElseIf Value='GREY_40' or Value='55';
    Return '969696';
  ElseIf Value='GREY_50' or Value='23';
    Return '808080';
  ElseIf Value='GREY_80' or Value='63';
    Return '333333';
  ElseIf Value='INDIGO' or Value='62';
    Return '333399';
  ElseIf Value='LAVENDER' or Value='46';
    Return 'FFCCFF';
  ElseIf Value='LEMON_CHIFFON' or Value='26';
    Return 'FFFFCC';
  ElseIf Value='LIGHT_BLUE' or Value='48';
    Return '3366FF';
  ElseIf Value='LIGHT_CORNFLOWER_BLUE' or Value='31';
    Return 'CCCCFF';
  ElseIf Value='LIGHT_GREEN' or Value='42';
    Return 'CCFFCC';
  ElseIf Value='LIGHT_ORANGE' or Value='52';
    Return 'FF9900';
  ElseIf Value='LIGHT_TURQUOISE' or Value='27';
    Return 'CCFFFF';
  ElseIf Value='LIGHT_YELLOW' or Value='43';
    Return 'FFFF99';
  ElseIf Value='LIME' or Value='50';
    Return '99CC00';
  ElseIf Value='MAROON' or Value='25';
    Return '99SS66';
  ElseIf Value='OLIVE_GREEN' or Value='59';
    Return '333300';
  ElseIf Value='ORANGE' or Value='53';
    Return 'FF6600';
  ElseIf Value='ORCHID' or Value='28';
    Return '660066';
  ElseIf Value='PALE_BLUE' or Value='44';
    Return '99CCFF';
  ElseIf Value='PINK' or Value='14';
    Return 'FF00FF';
  ElseIf Value='PLUM' or Value='61';
    Return '993399';
  ElseIf Value='RED' or Value='10';
    Return 'FF0000';
  ElseIf Value='ROSE' or Value='45';
    Return 'FF99CC';
  ElseIf Value='ROYAL_BLUE' or Value='30';
    Return '0066CC';
  ElseIf Value='SEA_GREEN' or Value='57';
    Return '339966';
  ElseIf Value='SKY_BLUE' or Value='40';
    Return '00CCFF';
  ElseIf Value='TAN' or Value='47';
    Return 'FFCC99';
  ElseIf Value='TEAL' or Value='21';
    Return '008080';
  ElseIf Value='TURQUOISE' or Value='15';
    Return '00FFFF';
  ElseIf Value='VIOLET' or Value='20';
    Return '800080';
  ElseIf Value='WHITE' or Value='9';
    Return 'FFFFFF';
  ElseIf Value='YELLOW' or Value='13';
    Return 'FFFF00';
  ElseIf Value='NORMAL' or Value='32767';
    Return '000000';
  ElseIf Value='AUTOMATIC' or Value='64';
    Return '000000';
  EndIf;

  // of 8 character sent assume it is an RBG color stripoff the first 2
  If %Len(%Trim(Value))=8;
    Return %subst(%Trim(Value):3:6);
  EndIf;

  // For any other value send back black
  Return '000000';

End-Proc;


// ValStyle - Make Sure Style Name has already been setup
Dcl-Proc ValStyle;
  Dcl-Pi *n  Ind;
    psStyle  Varchar(50) const;
  End-Pi;

  // Check style array for this name
  For i=1 To WorkBook.StyleCount;
    If WorkBook.Styles(i).Name=upify(psStyle);
      Return *off;
    EndIf;
  EndFor;

  Return *on;

End-Proc;


// GetStyle - Return the style number for a Style Name
Dcl-Proc GetStyle;
  Dcl-Pi *n Varchar(4);
    psStyle Varchar(50) const;
  End-Pi;

  // Check style array for this name
  For i=1 To WorkBook.StyleCount;
    If WorkBook.Styles(i).Name=upify(psStyle);
      Return %Trim(%Char(i));
    EndIf;
  EndFor;

  Return '0';

End-Proc;


// #$XLSXClose - Close an Existing open file
Dcl-Proc #$XLSXClose EXPORT;

  // If there is not an open workbook throw error
  If WorkBook.Status<>1;
    SndMsg('':9001:1);
    Return;
  EndIf;

  // If a sheet is still open close it
  If WorkSheet.Status=1 or WorkSheet.Status=2;
    EndSheet();
  EndIf;

  // Create each file
  CrtRels();
  If WorkBook.CustomPCount>0;
    CrtDocPropsCustom();
  EndIf;
  CrtWorkbook();
  CrtDocPropsApp();
  CrtDocPropsCore();
  CrtWorkbookRel();
  CrtStyles();
  CrtContents();

  // close the zip file in the IFS
  #$ZipClose();

  // Clear the workbook status so a new one can be written
  WorkBook.Status=0;

End-Proc;


// #$XLSXBreak - Forces a page break above the current row
Dcl-Proc #$XLSXBreak EXPORT;
  WorkSheet.BreakCount+=1;
  WorkSheet.Breaks(WorkSheet.BreakCount)=WorkSheet.Row;
End-Proc;


// #$XLSXGetRow- Returns the current row number
Dcl-Proc #$XLSXGetRow EXPORT;
  Dcl-Pi *n packed(9) End-Pi;
  Return WorkSheet.row;
End-Proc;


// CrtRels - tempfolder/_rels/.rels
Dcl-Proc CrtRels;
  openf(%Trim(WorkBook.TempFolder)+'_rels/.rels');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<Relationships xmlns="http://schemas.openxmlformats.org/+
          package/2006/relationships">'+eor);
  writef(tab+'<Relationship Id="rId3" Type="http://schemas.openxmlformats+
             .org/officeDocument/2006/relationships/extended-properties" +
               Target="docProps/app.xml"/>'+eor);
  writef(tab+'<Relationship Id="rId2" Type="http://schemas.openxmlformats+
              .org/package/2006/relationships/metadata/core-properties" +
               Target="docProps/core.xml"/>'+eor);
  writef(tab+'<Relationship Id="rId1" Type="http://schemas.openxmlformats+
              .org/officeDocument/2006/relationships/officeDocument" +
               Target="xl/workbook.xml"/>'+eor);
  If WorkBook.CustomPCount>0;
    writef(tab+'<Relationship Id="rId4" +
            Type="http://schemas.openxmlformats.org/+
            officeDocument/2006/relationships/custom-properties" +
            Target="docProps/custom.xml"/>');
  EndIf;
  writef('</Relationships>');
  closef();
End-Proc;


// CrtDocPropsApp   - tempfolder/docProps/app.xml
Dcl-Proc CrtDocPropsApp;
  openf(%Trim(WorkBook.TempFolder)+'docProps/app.xml');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<Properties +
          xmlns="http://schemas.openxmlformats.org/officeDocument/2006+
                /extended-properties" +
         xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006+
                /docPropsVTypes">'+eor);
  writef(tab+'<Application>#$XLSX - RPGLE Excel Service Program+
              </Application>'+eor);

  // Add heading pairs, these include all worksheets and defined names,
  // Defined names currently only come from repeating rows and columns
  writef(tab+'<HeadingPairs>'+eor);
  writef(tab+tab+'<vt:vector size="');
  If Workbook.NamedRanges>0;
    writef('4');
  Else;
    writef('2');
  EndIf;
  writef('" baseType="variant">'+eor);
  // add all worksheets
  writef(tab+tab+tab+'<vt:variant>'+eor);
  writef(tab+tab+tab+tab+'<vt:lpstr>Worksheets</vt:lpstr>'+eor);
  writef(tab+tab+tab+'</vt:variant>'+eor);
  writef(tab+tab+tab+'<vt:variant>'+eor);
  writef(tab+tab+tab+tab+'<vt:i4>'+
                         %Trim(%Char(Workbook.SheetCount)) +
                         '</vt:i4>'+eor);
  writef(tab+tab+tab+'</vt:variant>'+eor);
  // add named ranges
  If Workbook.NamedRanges>0;
    writef(tab+tab+tab+'<vt:variant>'+eor);
    writef(tab+tab+tab+tab+'<vt:lpstr>Named Ranges</vt:lpstr>'+eor);
    writef(tab+tab+tab+'</vt:variant>'+eor);
    writef(tab+tab+tab+'<vt:variant>'+eor);
    writef(tab+tab+tab+tab+'<vt:i4>'+
                           %Trim(%Char(Workbook.NamedRanges)) +
                           '</vt:i4>'+eor);
    writef(tab+tab+tab+'</vt:variant>'+eor);
  EndIf;
  writef(tab+tab+'</vt:vector>'+eor);
  writef(tab+'</HeadingPairs>'+eor);

  // Add titles of parts, this is an array that has titles for the names ranges
  writef(tab+'<TitlesOfParts>'+eor);
  writef(tab+tab+'<vt:vector size="'+
                 %Trim(%Char(Workbook.SheetCount +
                             Workbook.NamedRanges)) +
                 '" baseType="lpstr">'+eor);
  // add all worksheets
  For i = 1 To Workbook.SheetCount;
    writef(tab+tab+tab+'<vt:lpstr>'+
                       %Trim(Workbook.Sheets(i)) +
                           '</vt:lpstr>'+eor);
  EndFor;
  // add named ranges
  If Workbook.NamedRanges>0;
    For i = 1 To Workbook.NamedRanges;
      writef(tab+tab+tab+'<vt:lpstr>'+
                      %Trim(Workbook.NamedRange(i)) +
                          '</vt:lpstr>'+eor);
    EndFor;
  EndIf;
  writef(tab+tab+'</vt:vector>'+eor);
  writef(tab+'</TitlesOfParts>'+eor);

  If WorkBook.Manager<>' ';
    writef(tab+'<Manager>'+%Trim(WorkBook.Manager)+'</Manager>'+eor);
  EndIf;
  If WorkBook.Company<>' ';
    writef(tab+'<Company>'+%Trim(WorkBook.Company)+'</Company>'+eor);
  EndIf;
  If WorkBook.HyperLinkBase<>' ';
    writef(tab+'<HyperlinkBase>'+%Trim(WorkBook.HyperLinkBase)+
               '</HyperlinkBase>'+eor);
  EndIf;
  writef('</Properties>');
  closef();

End-Proc;


// CrtDocPropsCore  - tempfolder/docProps/core.xml
Dcl-Proc CrtDocPropsCore;
  openf(%Trim(WorkBook.TempFolder)+'docProps/core.xml');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<cp:coreProperties +
        xmlns:cp="http://schemas.openxmlformats.org/package/2006+
                 /metadata/core-properties" +
        xmlns:dc="http://purl.org/dc/elements/1.1/" +
        xmlns:dcterms="http://purl.org/dc/terms/" +
        xmlns:dcmitype="http://purl.org/dc/dcmitype/" +
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+eor);
  If WorkBook.Title<>' ';
    writef(tab+'<dc:title>'+%Trim(WorkBook.Title)+
              '</dc:title>'+eor);
  EndIf;
  If WorkBook.Subject<>' ';
    writef(tab+'<dc:subject>'+%Trim(WorkBook.Subject)+
              '</dc:subject>'+eor);
  EndIf;
  If WorkBook.Creator<>' ';
    writef(tab+'<dc:creator>'+%Trim(WorkBook.Creator)+
              '</dc:creator>'+eor);
  EndIf;
  If WorkBook.Tags<>' ';
    writef(tab+'<cp:keywords>'+%Trim(WorkBook.Tags)+
              '</cp:keywords>'+eor);
  EndIf;
  If WorkBook.Comments<>' ';
    writef(tab+'<dc:description>'+%Trim(WorkBook.Comments)+
               '</dc:description>'+eor);
  EndIf;
  // Get the current system time in the format of:2020-02-14T13:48:45Z
  writef(tab+'<dcterms:created xsi:type="dcterms:W3CDTF">'+
            %EditW(%Dec(%Date():*iso):'    -  -  ') + 'T' +
            %EditW(%Dec(%time():*iso):'  :  :  ') + 'Z' +
           '</dcterms:created>'+eor);
  If WorkBook.Category<>' ';
    writef(tab+'<cp:category>'+%Trim(WorkBook.Category)+
              '</cp:category>'+eor);
  EndIf;
  If WorkBook.ContentStatus<>' ';
    writef(tab+'<cp:contentStatus>'+%Trim(WorkBook.ContentStatus)+
              '</cp:contentStatus>'+eor);
  EndIf;
  writef('</cp:coreProperties>');
  closef();

End-Proc;


// CrtDocPropsCustom - tempfolder/docProps/custom.xml
Dcl-Proc CrtDocPropsCustom;

  openf(%Trim(WorkBook.TempFolder)+'docProps/custom.xml');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<Properties +
          xmlns="http://schemas.openxmlformats.org/officeDocument/+
                 2006/custom-properties" +
          xmlns:vt="http://schemas.openxmlformats.org/officeDocument/+
                 2006/docPropsVTypes">'+eor);

  For i = 1 To WorkBook.CustomPCount;
    writef(tab+'<property +
          fmtid="{D5CDD505-2E9C-101B-9397-08002B2CF9AE}" +
          pid="'+%Char(i+1)+'" +
          name="'+%Trim(WorkBook.CustomProperties(i).Name)+'">'+eor);
    If WorkBook.CustomProperties(i).Type='1';
      writef(tab+tab+'<vt:lpwstr>'+
                      %Trim(WorkBook.CustomProperties(i).Value)+
                      '</vt:lpwstr>'+eor);
    EndIf;
    If WorkBook.CustomProperties(i).Type='2';
      writef(tab+tab+'<vt:filetime>'+
             %EditW(
                    %Dec(WorkBook.CustomProperties(i).Value:8:0)
                    :'    -  -  ')+
             'T10:00:00Z'+
             '</vt:filetime>'+eor);
    EndIf;
    If WorkBook.CustomProperties(i).Type='3';
      writef(tab+tab+'<vt:r8>'+
                      %Trim(WorkBook.CustomProperties(i).Value)+
                      '</vt:r8>'+eor);
    EndIf;
    If WorkBook.CustomProperties(i).Type='4';
      writef(tab+tab+'<vt:bool>'+
                      %Trim(WorkBook.CustomProperties(i).Value)+
                      '</vt:bool>'+eor);
    EndIf;
    writef(tab+'</property>'+eor);
  EndFor;

  writef('</Properties>'+eor);
  closef();

End-Proc;


// CrtWorkbook   - tempfolder/xl/workbook.xml
Dcl-Proc CrtWorkbook;
  openf(%Trim(WorkBook.TempFolder)+'xl/workbook.xml');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<workbook +
          xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/+
                 main" +
          xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/+
                   relationships" +
          xmlns:mc="http://schemas.openxmlformats.org/+
                    markup-compatibility/2006" +
          mc:Ignorable="x15" +
          xmlns:x15="http://schemas.microsoft.com/office/spreadsheetml/+
                     2010/11/main">'+eor);
  writef(tab+'<fileVersion appName="xl" lastEdited="6" lowestEdited="6" +
                rupBuild="14420"/>'+eor);
  writef(tab+'<workbookPr defaultThemeVersion="164011"/>'+eor);
  writef(tab+'<mc:AlternateContent +
               xmlns:mc="http://schemas.openxmlformats.org/+
               markup-compatibility/2006">'+eor);
  writef(tab+tab+'<mc:Choice Requires="x15">'+eor);
  writef(tab+tab+tab+'<x15ac:absPath url="C:\Users\ttognazzin\Desktop\" +
              xmlns:x15ac="http://schemas.microsoft.com/office/+
              spreadsheetml/2010/11/ac"/>'+eor);
  writef(tab+tab+'</mc:Choice>'+eor);
  writef(tab+'</mc:AlternateContent>'+eor);
  writef(tab+'<bookViews>'+eor);
  writef(tab+tab+'<workbookView xWindow="0" yWindow="0" +
               windowWidth="23730" windowHeight="10515"/>'+eor);
  writef(tab+'</bookViews>'+eor);

  // add Sheet names from sheet array
  writef(tab+'<sheets>'+eor);
  For i = 1 To Workbook.SheetCount;
    writef(tab+tab+'<sheet name="' + %Trim(Workbook.Sheets(i))+
                               '" sheetId="'+%Char(i)+'" +
                                  r:id="rId'+%Char(i)+'"/>'+eor);
  EndFor;
  writef(tab+'</sheets>'+eor);

  // add repeating rows/columns if any are setup
  If Workbook.Repeating;
    writef(tab+'<definedNames>'+eor);
    For i = 1 To Workbook.SheetCount;
      If Workbook.RepeatingColumns(i)<>0 or
         Workbook.RepeatingRows(i)<>0;
        Workbook.NamedRanges+=1;
        WorkBook.NamedRange(Workbook.NamedRanges)=
                  %Trim(Workbook.Sheets(i)) + '!Print_Titles';
        writef(tab+tab+'<definedName +
                         name="_xlnm.Print_Titles" +
                         localSheetId="' + %Trim(%Char(i-1)) + '">');
        If Workbook.RepeatingColumns(i)<>0;
          writef(%Trim(Workbook.Sheets(i))+'!$' +
                   col(Workbook.RepeatingColumns(i)) + ':$' +
                   col(Workbook.RepeatingColumnsEnd(i)));
        EndIf;
        If Workbook.RepeatingRows(i)<>0;
          If Workbook.RepeatingColumns(i)<>0;
            writef(',');
          EndIf;
          writef(%Trim(Workbook.Sheets(i))+'!$' +
                   %Trim(%Char(Workbook.RepeatingRows(i))) + ':$' +
                   %Trim(%Char(Workbook.RepeatingRowsEnd(i))));
        EndIf;
        writef('</definedName>'+eor);
      EndIf;
    EndFor;
    writef(tab+'</definedNames>'+eor);
  EndIf;

  writef(tab+'<calcPr calcId="162913"/>'+eor);
  writef(tab+'<extLst>'+eor);
  writef(tab+tab+'<ext uri="{140A7094-0E35-4892-8432-C4D2E57EDEB5}" +
              xmlns:x15="http://schemas.microsoft.com/office/+
              spreadsheetml/2010/11/main">'+eor);
  writef(tab+tab+tab+'<x15:workbookPr chartTrackingRefBase="1"/>'+eor);
  writef(tab+tab+'</ext>'+eor);
  writef(tab+'</extLst>'+eor);
  writef('</workbook>');
  closef();

End-Proc;


// CrtWorkbookRel- tempfolder/xl/_rels/workbook.xml.rels
Dcl-Proc CrtWorkbookRel;

  openf(%Trim(WorkBook.TempFolder)+'xl/_rels/workbook.xml.rels');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<Relationships +
           xmlns="http://schemas.openxmlformats.org/package/+
           2006/relationships">'+eor);
  For i = 1 To Workbook.SheetCount;
    writef(tab+'<Relationship Id="rId'+%Char(i)+'" +
                 Type="http://schemas.openxmlformats.org/officeDocument/+
                 2006/relationships/worksheet" +
                 Target="worksheets/sheet'+%Char(i)+
                 '.xml"/>'+eor);
  EndFor;
  writef(tab+'<Relationship Id="rId'+%Char(WorkBook.SheetCount+1)+'" +
               Type="http://schemas.openxmlformats.org/officeDocument/+
               2006/relationships/styles" +
               Target="styles.xml"/>'+eor);
  writef('</Relationships>');
  closef();

End-Proc;


// CrtStyles - tempfolder/xl/styles.xml
Dcl-Proc CrtStyles;
  Dcl-S numFmtCnt packed(4);
  Dcl-S fontCnt packed(4);
  Dcl-S fillCnt packed(4);
  Dcl-S borderCnt packed(4);
  Dcl-S counter packed(4);

  openf(%Trim(WorkBook.TempFolder)+'xl/styles.xml');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<styleSheet +
           xmlns="http://schemas.openxmlformats.org/spreadsheetml/+
                  2006/main" +
           xmlns:mc="http://schemas.openxmlformats.org/+
                     markup-compatibility/2006">'+eor);

  // Get count of styles that have number formats, fonts, fills and borders
  numFmtCnt=0;
  fontCnt=0;
  fillCnt=0;
  borderCnt=0;
  For i = 1 To WorkBook.StyleCount;
    If WorkBook.Styles(i).DataFormat<>' ';
      numFmtCnt +=1;
    EndIf;
    If WorkBook.Styles(i).Color<>' ' or
       WorkBook.Styles(i).FontSize<>0 or
       WorkBook.Styles(i).Font<>' ' or
       WorkBook.Styles(i).FontWeight<>' ' or
       WorkBook.Styles(i).Underline<>' ' or
       WorkBook.Styles(i).Italic<>' ';
      fontCnt +=1;
    EndIf;
    If WorkBook.Styles(i).FillStyle<>' ' or
       WorkBook.Styles(i).FillForeground<>' ' or
       WorkBook.Styles(i).FillBackGround<>' ';
      fillCnt +=1;
    EndIf;
    If WorkBook.Styles(i).BorderColor   <>' ' or
       WorkBook.Styles(i).BottomBorder  <>' ' or
       WorkBook.Styles(i).TopBorder     <>' ' or
       WorkBook.Styles(i).RightBorder   <>' ' or
       WorkBook.Styles(i).LeftBorder    <>' ' or
       WorkBook.Styles(i).DiagonalBorder<>' ' or
       WorkBook.Styles(i).DiagonalOption<>' ';
      borderCnt +=1;
    EndIf;
  EndFor;

  // Add number formats
  If numFmtCnt>0;
    writef(tab+'<numFmts count="'+%Char(numFmtCnt)+'">'+eor);
    counter=0;
    For i = 1 To WorkBook.StyleCount;
      If WorkBook.Styles(i).DataFormat<>' ';
        counter+=1;
        writef(tab+tab+'<numFmt numFmtId="'+%Char(counter+163)+
                  '" formatCode="'+
                  %Trim(WorkBook.Styles(i).DataFormat)+'"/>'+eor);
        WorkBook.Styles(i).NumFmt=counter;
      EndIf;
    EndFor;
    writef(tab+'</numFmts>'+eor);
  EndIf;

  // Add font formatting
  writef(tab+'<fonts count="'+%Char(fontCnt+1)+'">'+eor);
  writef(tab+tab+'<font> val="11"/>'+eor);
  writef(tab+tab+tab+'<sz val="11"/>'+eor);
  writef(tab+tab+tab+'<color theme="1"/>'+eor);
  writef(tab+tab+tab+'<name val="Calibri"/>'+eor);
  writef(tab+tab+tab+'<family val="2"/>'+eor);
  writef(tab+tab+tab+'<scheme val="minor"/>'+eor);
  writef(tab+tab+'</font>'+eor);
  counter=0;
  For i = 1 To WorkBook.StyleCount;
    If WorkBook.Styles(i).Color<>' ' or
       WorkBook.Styles(i).FontSize<>0 or
       WorkBook.Styles(i).Font<>' ' or
       WorkBook.Styles(i).FontWeight<>' ' or
       WorkBook.Styles(i).Underline<>' ' or
       WorkBook.Styles(i).StrikeOut<>' ' or
       WorkBook.Styles(i).TypeOffset<>' ' or
       WorkBook.Styles(i).Italic<>' ';
      writef(tab+tab+'<font>'+eor);
      If WorkBook.Styles(i).Font<>' ';
        writef(tab+tab+tab+'<name val="'+
               %Trim(WorkBook.Styles(i).Font) +
               '"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).FontSize<>0;
        writef(tab+tab+tab+'<sz val="'+
               %Char(WorkBook.Styles(i).FontSize) +
               '"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).FontWeight='Y';
        writef(tab+tab+tab+'<b val="true"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).TypeOffset='P';
        writef(tab+tab+tab+'<vertAlign val="superscript"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).TypeOffset='S';
        writef(tab+tab+tab+'<vertAlign val="subscript"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).StrikeOut='Y';
        writef(tab+tab+tab+'<strike/>'+eor);
      EndIf;
      If WorkBook.Styles(i).Underline='1';
        writef(tab+tab+tab+'<u val="single"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).Underline='2';
        writef(tab+tab+tab+'<u val="double"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).Italic<>' ';
        writef(tab+tab+tab+'<i val="true"/>'+eor);
      EndIf;
      If WorkBook.Styles(i).Color<>' ';
        writef(tab+tab+tab+'<color ' +
               rtnColor(WorkBook.Styles(i).Color) +
               '/>'+eor);
      EndIf;
      counter+=1;
      WorkBook.Styles(i).FontElem=counter;
      writef(tab+tab+'</font>'+eor);
    EndIf;
  EndFor;
  writef(tab+'</fonts>'+eor);

  // Add fills
  // for some reason we have to put defaults in for 1 and 2.
  writef(tab+'<fills count="'+%Char(fillCnt+2)+'">'+eor);
  writef(tab+tab+'<fill>'+eor);
  writef(tab+tab+tab+'<patternFill patternType="none"/>'+eor);
  writef(tab+tab+'</fill>'+eor);
  writef(tab+tab+'<fill>'+eor);
  writef(tab+tab+tab+'<patternFill patternType="gray125"/>'+eor);
  writef(tab+tab+'</fill>'+eor);
  counter=0;
  For i = 1 To WorkBook.StyleCount;
    If WorkBook.Styles(i).FillStyle<>' ' or
       WorkBook.Styles(i).FillForeground<>' ' or
       WorkBook.Styles(i).FillBackGround<>' ';
      writef(tab+tab+'<fill>'+eor);
      writef(tab+tab+tab+'<patternFill');
      If WorkBook.Styles(i).FillStyle='1';
        writef(' patternType="solid"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='2';
        writef(' patternType="lightGray"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='3';
        writef(' patternType="mediumGray"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='4';
        writef(' patternType="darkGray"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='5';
        writef(' patternType="gray125"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='6';
        writef(' patternType="gray0625"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='7';
        writef(' patternType="darkHorizontal"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='8';
        writef(' patternType="darkVertical"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='9';
        writef(' patternType="darkDown"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='A';
        writef(' patternType="darkUp"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='B';
        writef(' patternType="darkGrid"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='C';
        writef(' patternType="darkTrellis"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='D';
        writef(' patternType="lightHorizontal"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='E';
        writef(' patternType="lightVertical"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='F';
        writef(' patternType="lightDown"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='G';
        writef(' patternType="lightUp"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='H';
        writef(' patternType="lightGrid"');
      EndIf;
      If WorkBook.Styles(i).FillStyle='I';
        writef(' patternType="lightTrellis"');
      EndIf;
      writef('>'+eor);
      If WorkBook.Styles(i).FillForeground<>' ';
        writef(tab+tab+tab+tab+'<fgColor ' +
               rtnColor(WorkBook.Styles(i).FillForeground) +
               '/>'+eor);
      EndIf;
      If WorkBook.Styles(i).FillBackground<>' ';
        writef(tab+tab+tab+tab+'<bgColor ' +
               rtnColor(WorkBook.Styles(i).FillBackground) +
               '/>'+eor);
      EndIf;
      counter+=1;
      WorkBook.Styles(i).Fill=counter+1;
      writef(tab+tab+tab+'</patternFill>'+eor);
      writef(tab+tab+'</fill>'+eor);
    EndIf;
  EndFor;
  writef(tab+'</fills>'+eor);

  // Add borders
  writef(tab+'<borders count="'+%Char(borderCnt+1)+'">'+eor);
  writef(tab+tab+'<border>'+eor);
  writef(tab+tab+tab+'<left/>'+eor);
  writef(tab+tab+tab+'<right/>'+eor);
  writef(tab+tab+tab+'<top/>'+eor);
  writef(tab+tab+tab+'<bottom/>'+eor);
  writef(tab+tab+tab+'<diagonal/>'+eor);
  writef(tab+tab+'</border>'+eor);
  counter=0;
  For i = 1 To WorkBook.StyleCount;
    If WorkBook.Styles(i).BorderColor   <>' ' or
       WorkBook.Styles(i).BottomBorder  <>' ' or
       WorkBook.Styles(i).TopBorder     <>' ' or
       WorkBook.Styles(i).RightBorder   <>' ' or
       WorkBook.Styles(i).LeftBorder    <>' ' or
       WorkBook.Styles(i).DiagonalBorder<>' ' or
       WorkBook.Styles(i).DiagonalOption<>' ';
      writef(tab+tab+'<border');
      If WorkBook.Styles(i).DiagonalOption='1';
        writef(' diagonalUp="1" diagonalDown="1"');
      EndIf;
      If WorkBook.Styles(i).DiagonalOption='2';
        writef(' diagonalDown="1"');
      EndIf;
      If WorkBook.Styles(i).DiagonalOption='3';
        writef(' diagonalUp="1"');
      EndIf;
      writef('>'+eor);
      If WorkBook.Styles(i).leftBorder<>' ';
        writef(tab+tab+tab+'<Left '+
               rtnBorderStyle(WorkBook.Styles(i).leftBorder) +
               '>'+eor);
        If WorkBook.Styles(i).BorderColor<>' ';
          writef(tab+tab+tab+tab+'<color '+
                 rtnColor(WorkBook.Styles(i).BorderColor) +
                 '/>'+eor);
        EndIf;
        writef(tab+tab+tab+'</left>'+eor);
      Else;
        writef(tab+tab+tab+'<left/>'+eor);
      EndIf;
      If WorkBook.Styles(i).rightBorder<>' ';
        writef(tab+tab+tab+'<right '+
               rtnBorderStyle(WorkBook.Styles(i).rightBorder) +
               '>'+eor);
        If WorkBook.Styles(i).BorderColor<>' ';
          writef(tab+tab+tab+tab+'<color '+
                 rtnColor(WorkBook.Styles(i).BorderColor) +
                 '/>'+eor);
        EndIf;
        writef(tab+tab+tab+'</right>'+eor);
      Else;
        writef(tab+tab+tab+'<right/>'+eor);
      EndIf;
      If WorkBook.Styles(i).topBorder<>' ';
        writef(tab+tab+tab+'<top '+
               rtnBorderStyle(WorkBook.Styles(i).topBorder) +
               '>'+eor);
        If WorkBook.Styles(i).BorderColor<>' ';
          writef(tab+tab+tab+tab+'<color '+
                 rtnColor(WorkBook.Styles(i).BorderColor) +
                 '/>'+eor);
        EndIf;
        writef(tab+tab+tab+'</top>'+eor);
      Else;
        writef(tab+tab+tab+'<top/>'+eor);
      EndIf;
      If WorkBook.Styles(i).bottomBorder<>' ';
        writef(tab+tab+tab+'<bottom '+
               rtnBorderStyle(WorkBook.Styles(i).bottomBorder) +
               '>'+eor);
        If WorkBook.Styles(i).BorderColor<>' ';
          writef(tab+tab+tab+tab+'<color '+
                 rtnColor(WorkBook.Styles(i).BorderColor) +
                 '/>'+eor);
        EndIf;
        writef(tab+tab+tab+'</bottom>'+eor);
      Else;
        writef(tab+tab+tab+'<bottom/>'+eor);
      EndIf;
      If WorkBook.Styles(i).diagonalBorder<>' ';
        writef(tab+tab+tab+'<diagonal '+
               rtnBorderStyle(WorkBook.Styles(i).diagonalBorder) +
               '>'+eor);
        If WorkBook.Styles(i).BorderColor<>' ';
          writef(tab+tab+tab+tab+'<color '+
                 rtnBorderStyle(WorkBook.Styles(i).BorderColor) +
                 '/>'+eor);
        EndIf;
        writef(tab+tab+tab+'</diagonal>'+eor);
      Else;
        writef(tab+tab+tab+'<diagonal/>'+eor);
      EndIf;
      writef(tab+tab+'</border>'+eor);
      counter+=1;
      WorkBook.Styles(i).Border=counter;
    EndIf;
  EndFor;
  writef(tab+'</borders>'+eor);

  writef(tab+'<cellStyleXfs count="1">'+eor);
  writef(tab+tab+'<xf numFmtId="0" fontId="0" +
                      fillId="0" borderId="0"/>'+eor);
  writef(tab+'</cellStyleXfs>'+eor);

  // Add Xfs - Crossreference of style to Fumfnt,font,fill and border
  writef(tab+'<cellXfs count="'+%Char(WorkBook.StyleCount+1)+'">'+eor);
  writef(tab+tab+'<xf numFmtId="0" fontId="0" fillId="0" +
                      borderId="0" xfId="0"/>'+eor);
  For i = 1 To WorkBook.StyleCount;
    writef(tab+tab+'<xf ');
    If WorkBook.Styles(i).NumFmt<>0;
      writef(' numFmtId="'+%Char(WorkBook.Styles(i).NumFmt+163)+ '"');
    Else;
      writef(' numFmtId="0"');
    EndIf;
    writef(' fontId="'+%Char(WorkBook.Styles(i).FontElem)+ '" +
           fillId="'+%Char(WorkBook.Styles(i).Fill)+ '" +
           borderId="'+%Char(WorkBook.Styles(i).Border)+ '" +
           xfId="0"');
    If WorkBook.Styles(i).NumFmt<>0;
      writef(' applyNumberFormat="1"');
    EndIf;
    If WorkBook.Styles(i).FontElem<>0;
      writef(' applyFont="1"');
    EndIf;
    If WorkBook.Styles(i).Fill<>0;
      writef(' applyFill="1"');
    EndIf;
    If WorkBook.Styles(i).Border<>0;
      writef(' applyBorder="1"');
    EndIf;
    If WorkBook.Styles(i).Alignment<>' ' or
       WorkBook.Styles(i).VAlignment<>' ' or
       WorkBook.Styles(i).WrapText<>' ';
      writef(' applyAlignment="1"');
    EndIf;
    // If no inner elements just close the <xf element, otherwise add inner elems
    If WorkBook.Styles(i).Alignment=' ' and
       WorkBook.Styles(i).VAlignment=' ' and
       WorkBook.Styles(i).WrapText=' ';
      writef('/>'+eor);
    Else;
      writef('>'+eor);
      writef(tab+tab+tab+'<alignment');
      If WorkBook.Styles(i).Alignment='1';
        writef(' horizontal="left"');
      ElseIf WorkBook.Styles(i).Alignment='2';
        writef(' horizontal="right"');
      ElseIf WorkBook.Styles(i).Alignment='3';
        writef(' horizontal="center"');
      ElseIf WorkBook.Styles(i).Alignment='4';
        writef(' horizontal="justify"');
      ElseIf WorkBook.Styles(i).Alignment='5';
        writef(' horizontal="centerContinuous"');
      ElseIf WorkBook.Styles(i).Alignment='6';
        writef(' horizontal="fill"');
      EndIf;
      If WorkBook.Styles(i).VAlignment='2';
        writef(' vertical="top"');
      ElseIf WorkBook.Styles(i).VAlignment='3';
        writef(' vertical="center"');
      ElseIf WorkBook.Styles(i).VAlignment='4';
        writef(' vertical="justify"');
      ElseIf WorkBook.Styles(i).VAlignment='5';
        writef(' vertical="distributed"');
      EndIf;
      If WorkBook.Styles(i).WrapText='1';
        writef(' wrapText="1"');
      EndIf;
      writef('/>'+eor);
      writef(tab+tab+'</xf>'+eor);
    EndIf;
  EndFor;
  writef(tab+'</cellXfs>'+eor);


  writef(tab+'<cellStyles count="1">'+eor);
  writef(tab+tab+'<cellStyle name="Normal" xfId="0" +
                             builtinId="0"/>'+eor);
  writef(tab+'</cellStyles>'+eor);

  writef(tab+'<dxfs count="0"/>'+eor);

  writef(tab+'<tableStyles count="0" +
               defaultTableStyle="TableStyleMedium2" +
               defaultPivotStyle="PivotStyleLight16"/>'+eor);
  writef(tab+'<extLst>'+eor);
  writef(tab+tab+'<ext uri="{EB79DEF2-80B8-43e5-95BD-54CBDDF9020C}" +
               xmlns:x14="http://schemas.microsoft.com/office/+
                    spreadsheetml/2009/9/main">'+eor);
  writef(tab+tab+tab+'<x14:slicerStyles +
               defaultSlicerStyle="SlicerStyleLight1"/>'+eor);
  writef(tab+tab+'</ext>'+eor);
  writef(tab+tab+'<ext uri="{9260A510-F301-46a8-8635-F512D64BE5F5}" +
               xmlns:x15="http://schemas.microsoft.com/+
               office/spreadsheetml/2010/11/main">'+eor);
  writef(tab+tab+tab+'<x15:timelineStyles +
               defaultTimelineStyle="TimeSlicerStyleLight1"/>'+eor);
  writef(tab+tab+'</ext>'+eor);
  writef(tab+'</extLst>'+eor);
  writef('</styleSheet>');
  closef();

End-Proc;


// CrtContents - tempfolder/[content_Types].xml
Dcl-Proc CrtContents;

  openf(%Trim(WorkBook.TempFolder)+'[content_Types].xml');
  writef('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+eor);
  writef('<Types +
           xmlns="http://schemas.openxmlformats.org/package/+
                  2006/content-types">'+eor);
  writef(tab+'<Default Extension="rels" +
               ContentType="application/vnd.openxmlformats+
                  -package.relationships+xml"/>'+eor);
  writef(tab+'<Default Extension="xml" +
               ContentType="application/xml"/>'+eor);
  writef(tab+'<Override PartName="/xl/workbook.xml" +
           ContentType="application/vnd.openxmlformats-officedocument+
           .spreadsheetml.sheet.main+xml"/>'+eor);
  For i = 1 To Workbook.SheetCount;
    writef(tab+'<Override PartName="/xl/worksheets/sheet'+%Char(i)+'.xml" +
             ContentType="application/vnd.openxmlformats-officedocument+
             .spreadsheetml.worksheet+xml"/>'+eor);
  EndFor;
  writef(tab+'<Override PartName="/xl/styles.xml" +
           ContentType="application/vnd.openxmlformats-officedocument+
           .spreadsheetml.styles+xml"/>'+eor);
  writef(tab+'<Override PartName="/docProps/core.xml" +
           ContentType="application/vnd.openxmlformats-package+
           .core-properties+xml"/>'+eor);
  writef(tab+'<Override PartName="/docProps/app.xml" +
           ContentType="application/vnd.openxmlformats-officedocument+
           .extended-properties+xml"/>'+eor);
  If WorkBook.CustomPCount>0;
    writef(tab+'<Override PartName="/docProps/custom.xml" +
          ContentType="application/vnd.openxmlformats-officedocument+
          .custom-properties+xml"/>'+eor);
  EndIf;
  writef('</Types>');
  closef();

End-Proc;


// rtnColor - returns a formattted color
//            00-99 = Indexed Color      = indexed="xx"
//        1000-1999 = Themed Color       = TODO
//           %len=8 = RGB Color          = rgb="FFFFEB9C"
Dcl-Proc rtnColor;
  Dcl-Pi *n Varchar(100);
    psColor  Char(8);
  End-Pi;

  Dcl-S dec0 packed(5);

  // Indexed Color
  If %Len(%Trim(psColor))<=2;
    dec0=RVL(psColor);
    Return 'indexed="'+%Char(Dec0)+'"';
  EndIf;

  // Themed Color
  If %Len(%Trim(psColor))=4;
    Return 'theme="TODO"';
  EndIf;

  // RGB Color
  If %Len(%Trim(psColor))=8;
    Return 'rgb="'+psColor+'"';
  EndIf;

End-Proc;


// rtnBorderStyle returns a border style from a code
// Example   rtnBorderStyle(1) = 'style="thin"'
Dcl-Proc rtnBorderStyle;
  Dcl-Pi *n Varchar(100);
    psCode Char(1);
  End-Pi;

  // Indexed Color
  If pscode='1';
    Return 'style="thin"';
  ElseIf pscode='2';
    Return 'style="medium"';
  ElseIf pscode='3';
    Return 'style="hair"';
  ElseIf pscode='4';
    Return 'style="dashed"';
  ElseIf pscode='5';
    Return 'style="dotted"';
  ElseIf pscode='6';
    Return 'style="double"';
  ElseIf pscode='7';
    Return 'style="dashDot"';
  ElseIf pscode='8';
    Return 'style="dashDotDot"';
  ElseIf pscode='9';
    Return 'style="mediumDashDot"';
  ElseIf pscode='A';
    Return 'style="mediumDashDotDot"';
  ElseIf pscode='B';
    Return 'style="mediumDashed"';
  Else;
    Return '';
  EndIf;

End-Proc;


// openf - create and open a file in the ifs
Dcl-Proc OPENF;
  Dcl-Pi *n;
    file Varchar(256) Value;
  End-Pi;

  #$ZipFile(%Trim(File));

  // if Buffering is on clear the buffer
  If WorkBook.Buffering;
    buffer='';
  EndIf;

End-Proc;


// writef - write a record to the open file
Dcl-Proc WRITEF;
  Dcl-Pi *n;
    data Varchar(32000) Value;
  End-Pi;

  // Write data to memory or file based on buffering option, data
  // length and buffer size
  If  WorkBook.Buffering;
    If %Len(data)>=%Len(buffer:*max)-1;
      // write buffered data, then reset the buffer, then add data to buffer
      If %Len(buffer)<>0;
        #$zipWriteB(%Addr(buffer)+4:%Len(buffer));
      EndIf;
      buffer='';
      #$zipWrite(Data);
    ElseIf %Len(buffer)+%Len(data)>=%Len(buffer:*max)-1;
      // write buffered data, then reset the buffer, then add data to buffer
      If %Len(buffer)<>0;
        #$zipWriteB(%Addr(buffer)+4:%Len(buffer));
      EndIf;
      buffer='';
      buffer=buffer+data;
    Else;
      buffer=buffer+data;
    EndIf;
  Else;
    #$zipWrite(Data);
  EndIf;

End-Proc;


// CLOSEF - Closes the open file
Dcl-Proc CLOSEF;
  // If buffering is on write whatever is left in the buffer and clear it
  If WorkBook.Buffering;
    #$zipWriteB(%Addr(buffer)+4:%Len(buffer));
    buffer='';
  EndIf;
End-Proc;

// upify - Convert to all upper case
// Only converts english characters.
//        INPUT:  data = Field to convert to all capitals
//      RETURNS:  The data field in all capitals
Dcl-Proc upify;
  Dcl-Pi *n Varchar(32767);
    data  Varchar(32767) const;
  End-Pi;
  Dcl-C EngLow 'abcdefghijklmnopqrstuvwxyz';
  Dcl-C EngUp 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  Return %xlate(EngLow:EngUp:data);

End-Proc;


// lowfy - Convert to all lower case
// Only converts english characters.
//       INPUT:  data = Field to convert to all capitals
//     RETURNS:  The data field in all capitals
Dcl-Proc lowfy;
  Dcl-Pi *n Varchar(32767);
    data Varchar(32767) const;
  End-Pi;
  Dcl-C EngLow 'abcdefghijklmnopqrstuvwxyz';
  Dcl-C EngUp 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Return %xlate(EngUp:EngLow:data);
End-Proc;


// rvl - returns a number from a character string

//  INPUT:  #$TXET = Input string
//  RETURNS:  Numeric Value

//  examples
//  rvl('1')                     returns 1
//  rvl('-1')                    returns -1
//  rvl('1-')                    returns -1
//  rvl('1-123')                 returns -1123
//  rvl('1-1.23')                returns -11.23
//  rvl('1.1.23')                returns 1.123
// TODO this is old school and needs to be evaluated/re-written
Dcl-Proc RVL;
  Dcl-Pi *n packed(30:10);
    #$TEXT Char(30) CONST;
  End-Pi;

  Dcl-Ds Text;
    txt Char(1) dim(30);
  End-Ds;
  Dcl-Ds chars;
    N21 Char(1) dim(20);
    decimalPoint Char(1);
    N10 Char(1) dim(10);
    negative Char(1);
  End-Ds;

  Dcl-S N20 Char(1) dim(20);
  Dcl-S x packed(2);
  Dcl-S y packed(2);
  Dcl-S z packed(2);
  Dcl-S decimalReached Ind;

  Text = #$text;
  decimalPoint = '.';
  x = 0;
  y = 0;
  z = 0;
  Clear n10;
  Clear n20;
  Clear n21;
  decimalReached = *OFF;

  For x = 1 To 30;
    If negative = ' ' and txt(x) = '-';
      negative = '-';
    EndIf;
    If not decimalReached and txt(x) = '.';
      decimalReached = *on;
    EndIf;
    If not decimalReached and txt(x) >= '0' and txt(x) <= '9';
      y += 1;
      If y > 15;
        iter;
      EndIf;
      n20(y) = txt(x);
    EndIf;
    If decimalReached and txt(x) >= '0' and txt(x) <= '9';
      z += 1;
      n10(z) = txt(x);
      If z >= 10;
        Leave;
      EndIf;
    EndIf;
  EndFor;

  // right justify n20 to n21
  z = 0;
  For x = 1 To 20;
    y =   21 - X;
    If N20(Y) <> *BLANKS;
      z -= 1;
      n21(z) = N20(Y);
    EndIf;
  EndFor;

  // zero fill n21
  For x = 1 To 20;
    If N21(X) < '0' or N21(X) > '9';
      n21(x) = '0';
    EndIf;
  EndFor;

  // zero fill n10
  For x = 1 To 10;
    If N10(X) < '0' or N10(X) > '9';
      n10(x) = '0';
    EndIf;
  EndFor;

  Return %Dec(%Trim(chars):20:10);

End-Proc;


// last - returns the last characters from a string

//  Input: #$STRING = The character string.
//         #$CHARS  = The number of characters to return
//  Output: the characters from the string

//  Examples
//   LAST('/tog/test.pdf':4) = '.pdf'

Dcl-Proc LAST;
  Dcl-Pi *n Varchar(99);
    #$STRING Varchar(2048) CONST;
    #$CHARS  packed(2) Value;
  End-Pi;

  // if the number of character is 0 or less return blanks
  If #$CHARS<=0;
    Return ' ';
  EndIf;

  // if the length is greate than the string length return the
  // full field
  If %Len(%Trim(#$STRING))<=#$CHARS;
    Return %Trim(#$STRING);
  EndIf;

  // return the last number of characters
  Return  %SUBST(%Trim(#$STRING):
                (%Len(%Trim(#$STRING))-#$CHARS+1):
                #$CHARS);
End-Proc;


// ColRow Returns the column and row number as a string
// The column is converted into alpha and the row is left
// numeric. If either is not passed it uses the current column
// and row for the current sheet.
//   Input: Col = the Column
//          Row = the row
//   Output: the character version of column and row

//   Examples
//    ColRow(1:3) = A3
//    ColRow(27:1387) = AA1387
Dcl-Proc ColRow;
  Dcl-Pi *n Varchar(10);
    psCol packed(5) CONST options(*nopass);
    psRow packed(9) CONST options(*nopass);
  End-Pi;
  Dcl-S rCol zoned(5);
  Dcl-S rRow zoned(9);

  // Set defaults if not passed
  If %Parms()>=1;
    rCol=psCol;
  Else;
    rCol=WorkSheet.Col;
  EndIf;
  If %Parms()>=2;
    rRow=psRow;
  Else;
    rRow=WorkSheet.Row;
  EndIf;

  // return the string
  Return %Trim((Col(rCol) + %Trim(%Char(rRow))));

End-Proc;


// Col - Returns the character Value of column

//  Examples
//   Col(1) = A  Col(2) = B  Col(27) = AA
Dcl-Proc Col;
  Dcl-Pi *n Varchar(3);
    Col packed(5) CONST;
  End-Pi;
  Dcl-C ALPHA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Dcl-S n packed(5);
  Dcl-S remainder packed(5);
  Dcl-S result Char(3);

  Result='';
  n=Col;
  DoW n>0;
    remainder=%rem(n-1:26);
    n=%div(n-1:26);
    result=%subst(ALPHA:remainder+1:1) + %Trim(result);
  EndDo;

  Return %Trim(result);

End-Proc;


// Col2 - Returns the numeric value of a character column

//  Examples: Col2('A') = 1  Col2('B') = 2  Col2('AA') = 27
Dcl-Proc Col2;
  Dcl-Pi *n packed(5);
    Col Char(3) CONST;
  End-Pi;
  Dcl-Ds *n;
    Alpha Char(26) Inz('ABCDEFGHIJKLMNOPQRSTUVWXYZ') pos(1);
    CHARS Char(1) dim(26) pos(1);
  End-Ds;
  Dcl-S Result zoned(5);
  Dcl-Ds tempds;
    ds1 Char(1);
    ds2 Char(1);
    ds3 Char(1);
  End-Ds;

  Result=0;
  evalr tempds=%Trim(col);

  // first character and times by 26*26
  If ds1<>' ';
    Result+=%Lookup(ds1:Chars)*26*26;
  EndIf;

  // Second character and times by 26
  If ds2<>' ';
    Result+=%Lookup(ds2:Chars)*26;
  EndIf;

  // Add in third character
  If ds1<>' ';
    Result+=%Lookup(ds2:Chars);
  EndIf;

  // return the result
  Return Result;

End-Proc;


// cmd - run a command
Dcl-Proc CMD;
  Dcl-Pi *n;
    #$Cmd Varchar(32768) const;
  End-Pi;
  Dcl-S #$LEN packed(15: 5);
  // prototype for qcmdexc
  Dcl-Pr RunCmd extpgm('QCMDEXC');
    *n Char(32768) const; // command
    *n packed(15: 5) const; // length
  End-Pr;
  RunCmd(%Trim(#$Cmd):%Len(%Trim(#$Cmd)));
End-Proc;


// SNDMSG - Send Message
// Sends an escape message to the calling program.
//  INPUT: MESSAGE = Message text or variable string.
//         NUMBER  = If passed it uses the message description
//                   XLSXXXX where XXXX is the value passed,
//                   if not passed or ommitted sends
//                   a default message with the text
//                   passed in MESSAGE, XLS0001 is used.
//         INQUIRY = If a 1 is passed it sends an inquiry
//                   message, otherwise it sends an escape
//                   message.
//         REPLACETEXT = Up to 7 additional Replacement texts,
//                   requires a message id number to be used
Dcl-Proc SNDMSG;
  Dcl-Pi *n;
    MSG      Varchar(1024) CONST;
    MSG#     packed(4) const options(*nopass:*omit);
    inquiry  packed(1) const options(*nopass:*omit);
    Replace2 Varchar(1024) CONST options(*nopass);
    Replace3 Varchar(1024) CONST options(*nopass);
    Replace4 Varchar(1024) CONST options(*nopass);
    Replace5 Varchar(1024) CONST options(*nopass);
    Replace6 Varchar(1024) CONST options(*nopass);
    Replace7 Varchar(1024) CONST options(*nopass);
    Replace8 Varchar(1024) CONST options(*nopass);
  End-Pi;

  Dcl-Ds myAPIErrorDS;
    dsECBytesP int(10) Inz(256) pos(1); // Bytes Provided
    dsECBytesA int(10) Inz(0) pos(5); // Bytes Available
    dsECMsgID Char(7) Inz(*all' ') pos(9); // Exception Id
    dsECReserv Char(1) Inz(*all' ') pos(16); // Reserved
    dsECMsgDta Char(240) Inz(*all' ') pos(17); // Msg Data
  End-Ds;

  // Message ID, File and Type
  Dcl-S msgid Char(7) Inz('XLS0000');
  Dcl-Ds msgf len(21);
    MsgFile Char(10) Inz('#$XLSX');
    MsgLib Char(10) Inz('#$XLSX');
  End-Ds;
  Dcl-S msgtype Char(10) Inz('*ESCAPE');

  // Multiple Replacement Values
  Dcl-S RplMulti ind;
  Dcl-S Rpl1 Char(1024);
  Dcl-S Rpl2 Char(1024);
  Dcl-S Rpl3 Char(1024);
  Dcl-S Rpl4 Char(1024);
  Dcl-S Rpl5 Char(1024);
  Dcl-S Rpl6 Char(1024);
  Dcl-S Rpl7 Char(1024);
  Dcl-S Rpl8 Char(1024);

  Dcl-S RtnMsgKey Char(4);

  // prototype for ibm send message api
  Dcl-Pr QMHSNDPM extpgm('QMHSNDPM');
    *n Char(7) const; // szMsgID
    *n Char(20) const; // szMsgFile
    *n Char(10000) const options(*varsize); // szMsgData
    *n int(10) const; // nMsgDataLen
    *n Char(10) const; // psmsgtype
    *n Char(10) const; // szCallStkEntry
    *n int(10) const; // nRelativeCallStkEntr
    *n Char(4); // szRtnMsgKey
    *n likeds(myapierrords) options(*varsize); // apiErrorDS
  End-Pr;

  // if a message id is passed use it
  If %Parms>=2 and %Addr(MSG#)<>*null;
    msgid='XLS'+ %EditC(MSG#:'X');
  Else;
    msgid='XLS0000';
  EndIf;

  // if a message id is passed see if there are additional replacement
  // text values
  RplMulti=*off;
  If msgFile='#$XLSX' and %Parms>=4;
    Rpl1=MSG;
    RplMulti=*on;
    If %Parms>=4 and %Addr(Replace2)<>*null;
      Rpl2=Replace2;
    EndIf;
    If %Parms>=5 and %Addr(Replace3)<>*null;
      Rpl3=Replace3;
    EndIf;
    If %Parms>=6 and %Addr(Replace4)<>*null;
      Rpl4=Replace4;
    EndIf;
    If %Parms>=7 and %Addr(Replace5)<>*null;
      Rpl5=Replace5;
    EndIf;
    If %Parms>=8 and %Addr(Replace6)<>*null;
      Rpl6=Replace6;
    EndIf;
    If %Parms>=9 and %Addr(Replace7)<>*null;
      Rpl7=Replace7;
    EndIf;
    If %Parms>=10 and %Addr(Replace8)<>*null;
      Rpl8=Replace8;
    EndIf;
  EndIf;

  // if flagged as inquiry, change type in inquiry
  If %Parms>=3 and %Addr(INQUIRY)<> *null;
    If inquiry=1;
      msgtype='*INFO';
    Else;
      msgtype='*ESCAPE';
    EndIf;
  Else;
    msgtype='*ESCAPE';
  EndIf;

  If RplMulti;
    CallP(e)  QMHSNDPM(msgid: msgf
       : rpl1 + rpl2 + rpl3 + rpl4 + rpl5 + rpl6 + Rpl7 + Rpl8
       : 1024*8 : msgtype : '*' : 1 : RTNMSGKey : MYAPIERRORDS);
  Else;
    CallP(e)  QMHSNDPM(msgid: msgf
       : %Trim(MSG): %Len(%Trim(MSG))
       : msgtype   : '*' : 1 : RTNMSGKey : MYAPIERRORDS);
  EndIf;

  Return;

End-Proc;


// ExcDate
// Convert date data type field to Excel number date.

//  INPUT:  Date in a date data type field
// RETURN:  Excels numeric representation of a date.
Dcl-Proc ExcDate;
  Dcl-Pi *n packed(8);
    DATE Date Value;
  End-Pi;
  Dcl-S WrkDate date(*iso) Inz(d'1900-01-01');
  // excel date = days since 1900-01-01 - 2
  Return %diff(Date:WrkDate:*days) + 2;
End-Proc;


// XMLESC - Escapes special characters in a string for XML
// This procedure replaces special characters for an XML
// output field
//     & to &#38;       < to &#60;    > to &#62;
//     ' to &#39,       " to &#34;

//        INPUT:  #$IN = String in
//      RETURNS:  Fixed String

// Example #$XMLESC('<DATA>')='&#60;DATA&#62;'
Dcl-Proc XMLESC;
  Dcl-Pi *n Varchar(4096);
    #$TXT Varchar(4096) const;
  End-Pi;
  Dcl-S txt Varchar(4096);
  TXT = %Trim(#$TXT);
  TXT=%ScanRpl('&':'&#38;':TXT);
  TXT=%ScanRpl('<':'&#60;':TXT);
  TXT=%ScanRpl('>':'&#62;':TXT);
  TXT=%ScanRpl('''':'&#39;':TXT);
  TXT=%ScanRpl('"':'&#34;':TXT);
  TXT=%ScanRpl(Null:'':TXT);
  Return %Trim(TXT);
End-Proc;


// Vdat - validates a text date
// This checks a text field for a valid numeric date in
// YYYYMMDD format.

//        INPUT:  #$IN = String in
//      RETURNS:  Boolean, on for error, otherwise off

// Example vdat('20200101')=*Off
//         vdat('20201301')=*On
Dcl-Proc vdat;
  Dcl-Pi *n Ind;
    #$IN Varchar(2048) const;
  End-Pi;
  Dcl-S DATE zoned(8);

  // convert to a date
  Monitor;
    DATE=%Dec(%Trim(#$IN):8:0);
  On-Error;
    Return *ON;
  EndMon;

  // validate date
  Test(DE) *ISO DATE;
  If %ERROR;
    Return *ON;
  EndIf;

  Return *OFF;
End-Proc;


// VNum - validates a text number
// This checks a text field for a valid numer.

//        INPUT:  #$IN = String in
//      RETURNS:  Boolean, on for error, otherwise off

// Example vnum('a123')=*On
//         vnum('123')=*Off
Dcl-Proc VNum;
  Dcl-Pi *n Ind;
    #$IN Varchar(2048) const;
  End-Pi;
  Dcl-S number packed(30: 10);
  // convert to a number
  Monitor;
    number=%Dec(%Trim(#$IN):30:10);
  On-Error;
    Return *ON;
  EndMon;
  Return *OFF;
End-Proc;


// SplitArg - Splits a single argument into the arg DS and adds it to the Args DS.
Dcl-Proc SplitArg;
  Dcl-Pi *n;
    psArg Varchar(2048) CONST;
  End-Pi;
  Dcl-S tpArg Varchar(2048);
  Dcl-S x packed(4);

  // Clear the single Arg DS first
  Reset arg;
  arg.parm=psArg;

  tpArg=psArg;

  // look for the first semicolon, if not found just update
  // the key and leave
  x=%Scan(':':tpArg);
  If x<=0;
    arg.key=tpArg;
    args.count+=1;
    args.arg(args.count)=arg;
    Return;
  EndIf;

  // Split argument into a Key and the remaining text
  arg.Key=upify(%subst(tpArg:1:x-1));
  tpArg=%subst(tpArg:x+1:%Len(tpArg)-x);

  // if nothing is after the first semicolon, save key leave
  If tpArg='';
    args.count+=1;
    args.arg(args.count)=arg;
    Return;
  EndIf;

  // Try to split up to 20 values out of the remaining text
  DoW 1=1;
    // Find the first semicolon, if quotes don't start till after
    // the closing quote
    If %subst(tparg:1:1)='"';
      // todo figure out quote logic later, has to handle double quotes
      x=%Scan(':':tpArg);
    Else;
      x=%Scan(':':tpArg);
    EndIf;

    // if no semicolon is found, assume this is the last value and leave
    If x=0;
      arg.Values+=1;
      arg.Value(arg.values)=tpArg;
      Leave;
    EndIf;

    // if a semicolon is found save value up to it in the
    // next value element and split it out of the remaining text
    arg.Values+=1;
    arg.value(arg.Values)=%subst(tpArg:1:x-1);
    tpArg=%subst(tpArg:x+1:%Len(tpArg)-x);

    // if we hit 20 values just leave and ignore the rest, there
    // is no parameter that includes 20 values
    If arg.values>=20;
      Leave;
    EndIf;

  EndDo;

  // Uppercase all but specific values
  If arg.key<>'OUTPUTNAME' and           // #$XLSXOpen options
     arg.key<>'AUTHOR' and
     arg.key<>'COMPANY' and
     arg.key<>'TITLE' and
     arg.key<>'SUBJECT' and
     arg.key<>'MANAGER' and
     arg.key<>'CATEGORY' and
     arg.key<>'STATUS' and
     arg.key<>'COMMENTS' and
     arg.key<>'HYPERLINKBASE' and
     arg.key<>'CUSTOMPROPERTY' and
     arg.key<>'FONT' and                 // #$XLSXStyle Options
     arg.key<>'DATAFORMAT' and
     arg.key<>'SHEETNAME' and            // #$XLSXWkSh Options
     arg.key<>'HEADER' and
     arg.key<>'FOOTER' and
     arg.key<>'PAPERSIZE' and
     arg.key<>'PRINTQUALITY';
    For x=1 To arg.values;
      arg.value(X)=upify(arg.value(x));
    EndFor;
  Else;
    For x=2 To arg.values;
      arg.value(X)=upify(arg.value(x));
    EndFor;
  EndIf;

  // Add the single argument to the ARGS DS Array
  args.count+=1;
  args.arg(args.count)=arg;

End-Proc;


// OvrSpecial - Override special values in footer and header text.
Dcl-Proc OvrSpecial;
  Dcl-Pi *n Varchar(2048);
    psin Varchar(2048) Const;
  End-Pi;
  Dcl-S tpOut Varchar(2048);

  // Clear the single Arg DS first
  tpOut=psin;

  // Convert special values
  tpOut=%ScanRpl('*NAME' :'&amp;A':tpOut);
  tpOut=%ScanRpl('*FILE' :'&amp;F':tpOut);
  tpOut=%ScanRpl('*PATH' :'&amp;Z':tpOut);
  tpOut=%ScanRpl('*PAGES':'&amp;N':tpOut);
  tpOut=%ScanRpl('*PAGE' :'&amp;P':tpOut);
  tpOut=%ScanRpl('*DATE' :'&amp;D':tpOut);
  tpOut=%ScanRpl('*TIME' :'&amp;T':tpOut);

  Return %Trim(tpOut);
End-Proc;


// AddHeader - Adds the meat of one header or footer entry.
// Move the entry from the worksheet array to the header DS before calling.
Dcl-Proc AddHeader;
  Dcl-Pi *n;
    hdr likeds(header);
  End-Pi;

  If hdr.color<>' ';
    writef('&amp;K'+Color2RBG(hdr.color));
  EndIf;

  If hdr.typeOffset='s';
    writef('&amp;Y');
  EndIf;

  If hdr.typeOffset='p';
    writef('&amp;X');
  EndIf;

  If hdr.StrikeThrough;
    writef('&amp;S');
  EndIf;

  If hdr.FontSize<>0;
    writef('&amp;'+%Char(hdr.FontSize));
  EndIf;

  If hdr.Underline='s';
    writef('&amp;U');
  EndIf;

  If hdr.Underline='d';
    writef('&amp;E');
  EndIf;

  If hdr.color<>' ';
    writef('&amp;K'+Color2RBG(hdr.color));
  EndIf;

  If hdr.Font<>' ' or
     hdr.Italic or
     hdr.Bold;
    writef('&amp;"');
    If hdr.Font<>' ';
      writef(%Trim(hdr.Font)+',');
    Else;
      writef('-,');
    EndIf;
    If hdr.Bold and
       hdr.Italic;
      writef('Bold Italic');
    ElseIf hdr.Bold;
      writef('Bold');
    ElseIf hdr.Italic;
      writef('Italic');
    Else;
      writef('Regular');
    EndIf;
    writef('"');
  EndIf;
  writef(OvrSpecial(hdr.text));

End-Proc;
