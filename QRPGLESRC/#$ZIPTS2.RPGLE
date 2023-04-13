     H DATEDIT(*YMD) OPTION(*NODEBUGIO:*SRCSTMT:*NOSHOWCPY)
     H Dftactgrp(*No) ACTGRP(*NEW) BNDDIR('#$XLSX1.0/#$ZIP')
     H*
     H* Test the #$Zip service program
     D*
     D/include #$XLSX1.0/QRPGLESRC,#$ZIP_H
     D defaultPath     DS                  dtaara('#$XLSXTEMP')
     D   path                  1    100
     C*
     C* Get default path from data area
     C                   IN        DEFAULTPATH
     C*
     C* Open a file
     C                   CallP     #$zipOpen(%trim(path)+ '/#$ZipTS2.zip')
     C*
     C* Add a file inside the zip archive
     C                   CallP     #$ZipFile('file.xml')
     C*
     C* Write CAFÉ, this tests a problem with the ascii conversion
     C                   CallP     #$ZipWrite('<test>É</test>')
     C*
     C* Close the zipfile
     C                   CallP     #$zipClose()
     C*
     C                   SetOn                                        LR
     C                   Return
     C*
