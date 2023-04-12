     H NOMAIN OPTION(*SRCSTMT) BNDDIR('#$XLSX1.0/ZLIB')
     *****************************************************************
     *Create a zip file from RPGLE program                         *
     *****************************************************************
     *                                                             *
     *Only one Zip file can be in use at a time, this is because   *
     *the service program holds the keys to the open file so the   *
     *RPG developer does not have to mess with it.                 *
     *                                                             *
     *Exported function list                                       *
     *  #$ZipOpen  - Open/create a zip file                        *
     *  #$ZipFile  - Add file inside a zip file                    *
     *  #$ZipWrite - Write data into a file inside a zip file      *
     *  #$ZipWriteB - Same as write but for a buffer               *
     *  #$ZipClose - Close an open zip file                        *
     *                                                             *
     *Internal function list                                       *
     *  SndMsg     - Send Program Message                          *
     *                                                             *
     *Errors are sent using message file ZLIB/#$ZIPMSG             *
     *CLLE program #$ZIPMSG contains the code to generate the      *
     *message file.                                                *
     *                                                             *
     *****************************************************************
     *                                                             *
     *To create this program use the following commands, if you    *
     *installed the system using a different library change the    *
     *libraries as needed.                                         *
     *CRTRPGMOD  MODULE(#$XLSX1.0/#$ZIP)                           *
     *           SRCFILE(#$XLSX1.0/QRPGLESRC) DBGVIEW(*ALL)        *
     *CRTSRVPGM  SRVPGM(#$XLSX1.0/#$ZIP) MODULE(#$XLSX1.0/#$ZIP)   *
     *           TEXT('Create Zip Files') EXPORT(*SRCFILE)         *
     *                                                             *
     *****************************************************************
     D/INCLUDE #$XLSX1.0/QRPGLESRC,ZIP.INC
     D/INCLUDE #$XLSX1.0/QRPGLESRC,ZLIB.INC
     D/INCLUDE #$ZIP_H
     D/INCLUDE #$ICONV_H
     D*
     D* Fields used as globals for the service pack
     D   Status        s              1  0
     D* status - 0=not yet opened
     D*          1=archive opened
     D*          2=file in archive opened
     D   ZipFileName   s           1024a
     D   FileInFile    s           1024a
     D   zipFileInfo   ds                   likeds(zip_fileinfo) inz(*likeds)
     D   Comment       s            100a    varying
     D   zipFilePtr    s               *
     D   zipFile       ds                   likeds(zip_internal)
     D                                      based(zipFilePtr)
     D*
     D* iconv variables
     d source          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d target          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d toEBC           ds                  likeds(iconv_t)
     D p_input         s               *
     D p_output        s               *
     D inputleft       s             10u 0
     D outputleft      s             10u 0
     D*
     D* Access mode flags for access() and accessx()
     D*   F_OK = File Exists
     D*   R_OK = Read Access
     D*   W_OK = Write Access
     D*   X_OK = Execute or Search
     D F_OK            C                   0
     D R_OK            C                   4
     D W_OK            C                   2
     D X_OK            C                   1
     D*
     D* Determine file accessibility
     D* int access(const char *path, int amode)
     D access          PR            10I 0 ExtProc('access')
     D   Path                          *   Value Options(*string)
     D   amode                       10I 0 Value
     D*
     D* IFS APIs for open and close, used to make sure a file is not locked
     D  S_IRWXU        S             10i 0 inz(448)                             Read, Write, Execute
     D  S_IROTH        S             10i 0 inz(4)                               Read for other
     D  filedesc       s             10i 0
     D  asciicodepage  s             10u 0 inz(367)
     D  O_CODEPAGE     S             10i 0 inz(8388608)                         code page flag
     D  O_RDWR         S             10i 0 inz(4)
     D  open           pr            10i 0 extproc('open')
     D    filename                     *   Value options(*string)               null terminated str
     D    openflags                  10i 0 Value
     D    mode                       10u 0 Value options(*nopass)
     D    codepage                   10u 0 Value options(*nopass)
     D  close          pr            10i 0 extproc('close')
     D    filehandle                 10i 0 Value
     D*
     D* Globals
     D NULL            s              1a   inz( x'00' )
     D NULLPOINTER     s               *
     D NULLSTRING      s              2a   inz( x'0000' )
     D rc              s             20i 0

     C*****************************************************************
     C* #$ZipOpen - Open a Zip File Archive
     C*
     C* parameter 1 = zip file with path
     C* parameter 2 = append option, optional, use defined constants
     C* parameter 3 = compression level 0-9
     C*               0=No Compression, 9=Highest, 5=Default
     C*
     C*****************************************************************
     P#$zipOpen        B                   EXPORT
     D                 pi
     D   File                      1024a    const varying
     D   AppendOption                10i 0  const options(*nopass:*omit)
     D   Compression                 10i 0  const options(*nopass:*omit)
     D*
     D NF              s           1024a
     D AO              s             10i 0
     D CM              s             10i 0

        // If an append option was not passed use create_replace
        if %parms>=2 and %addr(AppendOption)<>*null;
           AO=AppendOption;
        else;
           AO=APPEND_CREATE_REPLACE;
        endif;

        // If a compression option is not passed, use 5
        if %parms>=3 and %addr(Compression)<>*null;
           CM=Compression;
        else;
           CM=5;
        endif;

        // make sure the compression option is valid
        if cm<0;
           SndMsg(1008:1:%trim(File):%char(cm):'0');
           cm=0;
        endif;
        if cm>9;
           SndMsg(1008:1:%trim(File):%char(cm):'5');
           cm=5;
        endif;

        // Make sure a file is not already opened
        if status<>0;
            SndMsg(1001:0:%trim(zipFileName));
        endif;

        // If the append option is add to zip, make sure the file exists
        if AO=APPEND_ADDINZIP and Access(%trimr(File): F_OK) < 0;
           SndMsg(1004:0:%trim(File));
        endif;

        // If the append option is create, make sure the file doesn't exist
        if AO=APPEND_CREATE and Access(File: F_OK) = 0;
           SndMsg(1005:0:%trim(File));
        endif;

        // If the append option is create_replace and the file exists, make
        // sure we have authority to access the file so it can be replaced
        // deleting a file requires write and execute authority
        if AO=APPEND_CREATE_REPLACE and Access(File: F_OK) = 0;
           if Access(%trimr(File): W_OK+X_OK) < 0;
              SndMsg(1006:0:%trim(File));
           endif;
        endif;

        // If the append option is create_replace and the file exists and
        // we have authority to it, it could still be locked, try opening
        // and closing it, if that doesn't work then it is locked
        if AO=APPEND_CREATE_REPLACE and Access(File: F_OK) = 0;
           fileDesc = open( %trimr( File )
              : O_RDWR : s_irwxu + s_iroth : asciiCodePage );
           if fileDesc<0;
              SndMsg(1007:0:%trim(File));
           endif;
           filedesc=close(fileDesc);
        endif;

        // if the append option is create_replace set it to create,
        // the zip service program will automatically override it
        // if it exists, the create replace option was only added
        // for validity checking in this program
        if AO=APPEND_CREATE_REPLACE;
           AO=APPEND_CREATE;
        endif;

        // setup iconv parameters on the first run
        if target.ccsid<>1208;
           source.CCSID = 0;
           target.CCSID =1208;
           toEBC = QtqIconvOpen( target: source );
           if (toEBC.return_value = -1);
               SndMsg(1001:0);
           endif;
        endif;

        // Convert file name to a null terminated string
        NF = File + NULL + NULL;

        // open zip file archive
        zipFilePtr = zipOpen( %addr(NF): AO);

        // send error if the file cannot be opened
        if zipFilePtr = NULLPOINTER;
           SndMsg(1002:0:%trim(File));
        endif;

        // change the status to open if it worked correctly
        status=1;
        zipFileName=File;
        FileInFile=' ';

        return;

     P                 E

     C*****************************************************************
     C* #$ZipFile - Open a File in a Zip File Archive
     C*
     C* parameter 1 = internal file with path if needed
     C*
     C*****************************************************************
     P#$ZipFile        B                   EXPORT
     D                 pi
     D   FileInZip                 1024a    const varying
     D*
     D ebcdicFile      s           1024a
     D asciiFile       s           1024a

        // if a file is already opened, close it and set the status back to 1
        if status=2;
            If zipCloseFileInZip( ZipFile )<>0;
                SndMsg(2001:0:%trim(FileInFile):%trim(FileInZip));
            EndIf;
            status=1;
        endif;

        // Make sure a zip file archive is already opened
        if status<>1;
            SndMsg(2002:0:%trim(ZipFileName));
        endif;

        // Convert file name in to asciidata using inconv
        ebcdicFile=FileInZip;
        p_input = %addr(ebcdicFile);
        inputleft = %len(%trim(ebcdicFile));
        p_output = %addr(asciiFile);
        outputleft =inputleft;
        iconv( toEBC : p_input : inputleft : p_output : outputleft );
        asciiFile = %trim(asciiFile) + NULL + NULL;

        If zipOpenNewFileInZip( zipFile : %addr( asciiFile )
                                : %addr( zipFileInfo ) : NULL : 0
                                : NULL : 0 : %addr(Comment)
                                : 8 : 5) <>0;
           SndMsg(2003:0:%trim(FileInFile):%trim(ZipFileName));
        EndIf;

        FileInFile=FileInZip;
        status=2;

        Return;
     P                 E

     C*****************************************************************
     C* #$ZipWrite - Write data to an open File in a Zip File Archive
     C*
     C* parameter 1 = internal file with path if needed
     C*
     C*****************************************************************
     P#$ZipWrite       B                   EXPORT
     D                 PI
     D   Data                     32766a   const
     D   psData        s          32766a

        psData=Data;
        #$ZipWriteB(%addr(psData):%len(%trimr(data)));

        Return;

     P                 E

     C*****************************************************************
     C* #$ZipWriteB - Write data to an open File from a buffer
     C*
     C* parameter 1 = pointer to data
     C* parameter 2 = lenght of data
     C*
     C*****************************************************************
     P#$ZipWriteB      B                   EXPORT
     D                 PI
     D   bufPtr                        *   const
     D   bufLen                      10u 0 value
     D   asciiPtr      S               *

        // Make sure a zip file archive is already opened
        if status<>2;
            SndMsg(3002:0:%trim(ZipFileName));
        endif;

        // Convert data in to asciidata using inconv
        p_input = bufPtr;
        inputleft = bufLen;
        asciiPtr = %alloc(bufLen*2);
        p_output = asciiPtr;
        outputleft = bufLen*2;
        rc=iconv( toEBC : p_input : inputleft : p_output : outputleft );

        // the output buffer is twice the size of the input buffer because
        // some characters require 2 bytes, for example É gets converted
        // to x'C389', however we only want to write out the actual size
        // of the converted data which will equal the intial size minus
        // the outputLeft, output left is the number of bytes that did not
        // get used of the output buffer

        // Stream ascii data into the open file in zip
        If zipWriteInFileInZip( zipFile : asciiPtr: (buflen*2)-outputleft )<>0;
           SndMsg(3001:0:%trim(FileInFile):%Trim(ZipFileName));
        EndIf;

        dealloc(n) asciiPtr;
        Return;
     P                 E

     C*****************************************************************
     C* #$ZipClose - Close an Open Zip File Archive
     C*
     C*****************************************************************
     P#$ZipClose       B                   EXPORT
     D #$ZIPClose      pi
     D*

        // if a file is already opened, close it and set the status back to 1
        if status=2;
           If zipCloseFileInZip( ZipFile )<>0;
               SndMsg(2001:0:%trim(ZipFileName):%trim(FileInFile));
           EndIf;
           status=1;
        endif;

        If zipClose( zipFile : %addr(NULLSTRING) )<>0;
           SndMsg(4001:0:ZipFileName);
        EndIf;

        status=0;
        Return;

     P                 E

     C*****************************************************************
     C* SndMsg - Send Message
     C*
     C* Parm 1 - message ID
     C* Parm 2 = Exception or inquiry 0 or 1
     C* Oprional Parms 3-10 = Message file replacement text
     C*
     C*****************************************************************
     PSndMsg           B
     D                 Pi
     D  MSG#                          4P 0 CONST
     D  inquiry                       1P 0 CONST options(*nopass:*omit)
     D  Replace1                   1024A   CONST VARYING options(*nopass)
     D  Replace2                   1024A   CONST VARYING options(*nopass)
     D  Replace3                   1024A   CONST VARYING options(*nopass)
     D  Replace4                   1024A   CONST VARYING options(*nopass)
     D  Replace5                   1024A   CONST VARYING options(*nopass)
     D  Replace6                   1024A   CONST VARYING options(*nopass)
     D  Replace7                   1024A   CONST VARYING options(*nopass)
     D  Replace8                   1024A   CONST VARYING options(*nopass)
     D*
     D myAPIErrorDS    DS
     D   dsECBytesP            1      4B 0 inz(256)                             Bytes Provided
     D   dsECBytesA            5      8B 0 inz(0)                               Bytes Available
     D   dsECMsgID             9     15    inz(*all' ')                         Exception Id
     D   dsECReserv           16     16    inz(*all' ')                         Reserved
     D   dsECMsgDta           17    256    inz(*all' ')                         Msg Data
     D*
     D* Message ID, File and Type
     D msgid           S              7A   Inz('ZIP0000')
     D msgf            DS            21
     D  MsgFile                      10A   Inz('#$ZIP')
     D  MsgLib                       10A   Inz('#$XLSX')
     D msgtype         S             10A   Inz('*ESCAPE')
     D*
     D* Multiple Replacement Values
     D Rpl1            S           1024a
     D Rpl2            S           1024a
     D Rpl3            S           1024a
     D Rpl4            S           1024a
     D Rpl5            S           1024a
     D Rpl6            S           1024a
     D Rpl7            S           1024a
     D Rpl8            S           1024a
     D*
     D RtnMsgKey       S              4A
     D*
     D* PROTOTYPE FOR IBM SEND MESSAGE API
     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D  szMsgID                       7A   Const
     D  szMsgFile                    20A   Const
     D  szMsgData                 10000A   Const OPTIONS(*varsize)
     D  nMsgDataLen                  10I 0 Const
     D  PSMSGTYPE                    10A   Const
     D  szCallStkEntry...
     D                               10A   Const
     D  nRelativeCallStkEntry...
     D                               10I 0 Const
     D  szRtnMsgKey                   4A
     D  apiErrorDS                         LikeDS(myAPIErrorDS)
     D                                     OPTIONS(*VARSIZE)

       // build message ID
          msgid='ZIP'+ %editc(MSG#:'X');

       // Get inquiry or escape message option
          IF %PARMS>=2 AND %ADDR(INQUIRY)<> *null;
             if inquiry=1;
                msgtype='*INFO';
             else;
                msgtype='*ESCAPE';
             endif;
          else;
             msgtype='*ESCAPE';
          endif;

       // Get text replacement values, all passed as *char 1024
          if %Parms>=3 and %addr(Replace1)<>*null;
             Rpl1=Replace1;
          endif;
          if %Parms>=4 and %addr(Replace2)<>*null;
             Rpl2=Replace2;
          endif;
          if %Parms>=5 and %addr(Replace3)<>*null;
             Rpl3=Replace3;
          endif;
          if %Parms>=6 and %addr(Replace4)<>*null;
             Rpl4=Replace4;
          endif;
          if %Parms>=7 and %addr(Replace5)<>*null;
             Rpl5=Replace5;
          endif;
          if %Parms>=8 and %addr(Replace6)<>*null;
             Rpl6=Replace6;
          endif;
          if %Parms>=9 and %addr(Replace7)<>*null;
             Rpl7=Replace7;
          endif;
          if %Parms>=10 and %addr(Replace8)<>*null;
             Rpl8=Replace8;
          endif;

       // Send message
          CallP(e)  QMHSNDPM(msgid: msgf
             : rpl1 + rpl2 + rpl3 + rpl4 + rpl5 + rpl6 + Rpl7 + Rpl8
             : 1024*8 : msgtype : '*' : 1 : RTNMSGKey : MYAPIERRORDS);

       Return;

     P                 E

