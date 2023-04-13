     H DATEDIT(*YMD) OPTION(*NODEBUGIO:*NOSHOWCPY:*SRCSTMT)
     H Dftactgrp(*No) ACTGRP(*NEW) BNDDIR('ZLIB')
      *****************************************************************
      *€Test creating a zip file from RPGLE program                   *
      *€                                                              *
      *€This test the ZIP service program that #$ZIP uses, you        *
      *€should not be using this service program or working on this   *
      *€program. Use the #$ZIP service program, the test program for  *
      *€it is #$ZIPTS.                                                *
      *****************************************************************
      *€This example tests adding folders and multiple files          *
      *****************************************************************
     D*
     D/INCLUDE ZIP.INC
     D/INCLUDE ZLIB.INC
     D*
     D nullPointer     s               *
     D null            s              1a   inz( x'00' )
     D nullString      s              2a   inz( x'0000' )
     D EOR             s              2a   inz( x'0D25' )
     D rc              s             10i 0
     D zipFilePath     s            512a    inz('/tog/ZipTest2.zip')
     D FileInZip       s            512a    inz('Test.txt')
     D DataInFile      s            512a    inz('Test some text')
     D FileInFolder    s            512a    inz('folder/Test.txt')
     D DataInFileInFolder...
     D                 s            512a    inz('This text is in the file in +
     D                                           the folder.')
     D fullname        s            512a
     D zipFileInfo     ds                   likeds(zip_fileinfo) inz(*likeds)
     D zipFileComment  s            100a    varying
     D zipFilePtr      s               *
     D zipFile         ds                   likeds(zip_internal)
     D                                      based(zipFilePtr)
     D*
     D* convert data to ascii
     D ASCII           c                   'QTCPASC   '
     D EBCDIC          c                   'QTCPEBC   '
     D Translate       PR                  ExtPgm('QDCXLATE')
     D   Length                       5P 0 const
     D   Data                     32766A   options(*varsize)
     D   Table                       10A   const
     D*
     C****************************************************
     C* quick sudo code for understanding
     C*
     C*  zipOpen( zipFileName: appendOption)                 open a zip file/archive
     C*
     C*  zipOpenNewFileInZip(zipFile: fileInZipName:...)     add a file into the zip file archive
     C*
     C*  zipWriteInFileInZip(zipFile: theData,theDataLenght) write data into file in zip file
     C*
     C*  zipCloseFileInZip( zipFile )                        close the file in the zip file archive
     C*
     C*  zipOpenNewFileInZip(zipFile: fileInFolder:...)      add a file in the folder
     C*
     C*  zipWriteInFileInZip(zipFile: theData,theDataLenght) write data into file in folder
     C*
     C*  zipCloseFileInZip( zipFile )                        close the file in folder
     C*
     C*  zipClose( zipFile : ...)                            close the zip file archive
     C*
     C****************************************************
     C*
     C* Initialize values, two nulls = end of field so nothing past it is used
     C                   eval      fullName = %trim( zipFilePath ) + null + null
     C*
     C* Open a file with the create option
     C                   eval      zipFilePtr = zipOpen( %addr( fullName )
     C                               : APPEND_STATUS_CREATE)
     C*
     C* Send error if the file cannot be opened
     C                   if        zipFilePtr = nullpointer
     C                   callp     #$sndmsg('Error opening ' + zipFilePath)
     C                   SETON                                        LR
     C                   RETURN
     C                   endif
     C*
     C* Add a file inside the zip archive
     C                   eval      fullName = %trim( FileInZip ) + null + null
     C                   callp     translate(%len(fullName)
     C                                     : fullName
     C                                     : ASCII)
     C                   eval      zipFileComment = null + null
     C                   If        zipOpenNewFileInZip( zipFile                 ZipFile           1
     C                                           : %addr( fullName )            FileName          2
     C                                           : %addr( zipFileInfo )         Zip_File_Info     3
     C                                           : null                         extrafield_Local  4
     C                                           : 0                            Size of ^         5
     C                                           : null                         extrafield_global 6
     C                                           : 0                            Size of ^         7
     C                                           : %addr( ZipFileComment )      comment           8
     C                                           : 0                            method            9
     C                                           : 5)                           level            10
     C                             <>0
     C                   CallP     #$sndmsg('Error opening file ' + FileInZip +
     C                                      ' in ' + zipFilePath)
     C                   SetOn                                        LR
     C                   Return
     C                   EndIf
     C*
     C* Add some data to the file, must be converted to ascii
     C                   callp     translate(%len(dataInFile)
     C                                     : dataInFile
     C                                     : ASCII)
     C                   If        zipWriteInFileInZip( zipFile
     C                                           : %addr( dataInFile )
     C                                           : %Len(%trim(dataInFile)) )<>0
     C                   CallP     #$sndmsg('Error adding data to ' + FileInZip)
     C                   SetOn                                        LR
     C                   Return
     C                   EndIf
     C*
     C* Close the current file in the zipfile
     C                   If        zipCloseFileInZip( zipFile )<>0
     C                   CallP     #$sndmsg('Error closing ' + FileInZip)
     C                   SetOn                                        LR
     C                   Return
     C                   EndIf
     C*
     C* Add a file inside the zip archive in a folder
     C                   eval      fullName = %trim( FileInFolder ) + null+null
     C                   callp     translate(%len(fullName)
     C                                     : fullName
     C                                     : ASCII)
     C                   eval      zipFileComment = null + null
     C                   If        zipOpenNewFileInZip( zipFile                 ZipFile           1
     C                                           : %addr( fullName )            FileName          2
     C                                           : %addr( zipFileInfo )         Zip_File_Info     3
     C                                           : null                         extrafield_Local  4
     C                                           : 0                            Size of ^         5
     C                                           : null                         extrafield_global 6
     C                                           : 0                            Size of ^         7
     C                                           : %addr( ZipFileComment )      comment           8
     C                                           : 8                            method            9
     C                                           : Z_DEFAULT_COMPRESSION)       level            10
     C                             <>0
     C                   CallP     #$sndmsg('Error opening file ' + FileInZip +
     C                                      ' in ' + zipFilePath)
     C                   SetOn                                        LR
     C                   Return
     C                   EndIf
     C*
     C* Add some data to the file, must be converted to ascii
     C                   eval      dataInFileInFolder=%Trim(DataInFileInFolder)
     C                                               + EOR
     C                   callp     translate(%len(%trim(dataInFileInFolder))
     C                                     : dataInFileInFolder
     C                                     : ASCII)
     C                   Do        20
     C                   If        zipWriteInFileInZip( zipFile
     C                                   : %addr( dataInFileInFolder )
     C                                   : %Len(%trim(dataInFileInFolder)) )<>0
     C                   CallP     #$sndmsg('Error adding data to ' + FileInZip)
     C                   SetOn                                        LR
     C                   Return
     C                   EndIf
     C                   EndDo
     C*
     C* Close the current file in the zipfile
     C                   If        zipCloseFileInZip( zipFile )<>0
     C                   CallP     #$sndmsg('Error closing ' + FileInZip)
     C                   SetOn                                        LR
     C                   Return
     C                   EndIf
     C*
     C* Close the zipfile
     C                   If        zipClose( zipFile : %addr(nullString) )<>0
     C                   CallP     #$sndmsg('Error closing ' + ZipFilePath)
     C                   SetOn                                        LR
     C                   Return
     C                   EndIf
     C*
     C                   SetOn                                        LR
     C                   Return
     C*
     C*****************************************************************
     C* #$SNDMSG - Send Message
     C*****************************************************************
     P#$SNDMSG         B                   EXPORT
     D                 PI
     D  MSG                        1024A   CONST VARYING
     D*
     D RtnMsgKey       S              4A
     D errDs           S             16A
     D*
     D* PROTOTYPE FOR IBM SEND MESSAGE API
     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D  szMsgID                       7A   Const
     D  szMsgFile                    20A   Const
     D  szMsgData                  6000A   Const OPTIONS(*varsize)
     D  nMsgDataLen                  10I 0 Const
     D  PSMSGTYPE                    10A   Const
     D  szCallStkEntry...
     D                               10A   Const
     D  nRelativeCallStkEntry...
     D                               10I 0 Const
     D  szRtnMsgKey                   4A
     D  apiErrorDS                   16a   OPTIONS(*VARSIZE)
     C*
     C                   CALLP(E)  QMHSNDPM('CPF9897'
     C                                    : 'QCPFMSG   *LIBL     '
     C                                    : %TRIM(MSG)
     C                                    : %LEN(%TRIM(MSG))
     C                                    : '*INFO     '
     C                                    : '*         '
     C                                    : 3
     C                                    : RTNMSGKEY
     C                                    : errDs)
     C*
     C                   RETURN
     C*
     P                 E
