     D #$ZIPOpen       pr
     D   File                      1024a    const varying
     D   AppendOption                10i 0  const options(*nopass:*omit)
     D   Compression                 10i 0  const options(*nopass:*omit)
     D*
     D* Append statuses for #$ZipOpen
     D APPEND_CREATE...
     D                 C                   0
     D APPEND_CREATEAFTER...
     D                 C                   1
     D APPEND_ADDINZIP...
     D                 C                   2
     D APPEND_CREATE_REPLACE...
     D                 C                   3
     D*
     D #$ZIPFile       pr
     D   FileInZip                 1024a    const varying
     D*
     D #$ZIPWrite      pr
     D   Data                     32766a    const
     D*
     D #$ZIPWriteB     pr
     D   bufptr                        *   const
     D   buflen                      10u 0 value
     D*
     D #$ZIPClose      pr
