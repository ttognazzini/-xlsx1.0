     H DATEDIT(*YMD) OPTION(*NODEBUGIO:*SRCSTMT:*NOSHOWCPY)
     H Dftactgrp(*No) ACTGRP(*NEW) BNDDIR('#$XLSX1.0/#$ZIP')
     H*
     H* Test the #$Zip service program
     D*
     D/include #$XLSX1.0/QRPGLESRC,#$ZIP_H
     D defaultPath     DS                  dtaara('#$XLSX/#$XLSXTEMP')
     D   path                  1    100
     D EOR             s              2a   inz( x'0D25' )
     D testWriteB      s            100a
     C*
     C* Get default path from data area
     C                   In        defaultPath
     C*
     C* Open a file
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip.zip')
     C*
     C* Add a file inside the zip archive
     C                   CallP     #$ZipFile('file.txt')
     C*
     C* Add some data to the file
     C                   CallP     #$ZipWrite('Some data in the file.')
     C*
     C* Add a file inside the zip archive in a folder
     C                   CallP     #$ZipFile('folder/file.txt')
     C*
     C* Add some data to the file
     C                   Do        20
     C                   CallP     #$ZipWrite('This data is in the file +
     C                                         in the folder.'+EOR)
     C                   EndDo
     C*
     C* Add some data using the #$ZipWriteB function, this function
     C* uses pointer so it can stream memory buffers directly
     C                   Eval      testWriteB='Data from #$ZipWriteB'+EOR
     C                   Do        20
     C                   CallP     #$ZipWriteB(%addr(testWriteB)
     C                                       : %len(%trim(testWriteB)) )
     C                   EndDo
     C*
     C* Add a test file with CAFÉ in it, this tests a problem with the ascii conversion
     C                   CallP     #$ZipFile('test.txt')
     C                   CallP     #$ZipWrite('CAFÉ12')
     C*
     C* Close the zipfile
     C                   CallP     #$zipClose()
     C*
     C* Re-Open the exsting zip file and append an extra file
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip.zip'
     C                                       : APPEND_ADDINZIP)
     C                   CallP     #$ZipFile('fileAppended.txt')
     C                   CallP     #$ZipWrite('This file was added later.')
     C                   CallP     #$zipClose()
     C*
     C* That should create the zip file, that is all that is needed,
     C* the rest of the code below here is to test error messages
     C*
     C* Try to use the create only option for the file we just
     C* created, it should send a message saying the file already exists
     C                   Monitor
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip.zip'
     C                                       : APPEND_CREATE)
     C                   On-Error
     C                   EndMon
     C*
     C* Try to use an invalid compression options, this should go through,
     C* it should just log an error and use a default
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip2.zip'
     C                                       : *omit : -5)
     C                   CallP     #$zipClose()
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip3.zip'
     C                                       : *omit : 11)
     C                   CallP     #$zipClose()
     C*
     C* Try to open a second zip file without closing the first one
     C* this should cause an error
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip2.zip')
     C                   Monitor
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip3.zip')
     C                   On-Error
     C                   EndMon
     C                   CallP     #$zipClose()
     C*
     C* Try to open a append to a file that doesnt exist
     C* this should cause an error
     C                   Monitor
     C                   CallP     #$zipOpen(%trim(Path)+'/#$Zip4.zip'
     C                                     : APPEND_ADDINZIP)
     C                   On-Error
     C                   EndMon
     C*
     C                   SetOn                                        LR
     C                   Return
     C*
