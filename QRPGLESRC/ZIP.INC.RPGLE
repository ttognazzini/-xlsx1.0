      *******************************************************************
      * these are the prototypes for the ZIP module
      *******************************************************************
     D*
     D* Constants
     D ZIP_OK          c                   0
     D ZIP_EOF         c                   0
     D ZIP_ERRNO       c                   0
     D ZIP_PARAMERROR  c                   -102
     D ZIP_BADZIPFILE  c                   -103
     D ZIP_INTERNALERROR...
     D                 C                   -104
     D*
     D MAX_WBITS       C                   15
     D MAX_MEM_BITS    C                   15
     D MAX_MEM_LEVEL   C                   8
     D DEF_MEM_LEVEL   C                   8
     D*
     D*******************************************************************
     D* Structures
     D*
     D* filestream, must be defined in one of the stdio's
     D* I pulled them from a debug session, not sure if they are correct
     D filestream      ds                  qualified template align
     D   next_in                       *
     D   avail_in                    10u 0 inz(0)
     D   total_in                    10u 0 inz(0)
     D   next_out                      *
     D   avail_out                   10u 0 inz(0)
     D   total_out                   10u 0 inz(0)
     D   msg                           *
     D   state                         *
     D   zalloc                        *
     D   zfree                         *
     D   opaque                        *
     D   data_type                   10i 0 inz(0)
     D   addler                      10i 0 inz(0)
     D   reserved                    10i 0 inz(0)
     D*
     D* curfile_info, used in zip_internal ds
     D curfile_info    ds                  qualified template align
     D   stream                            likeds(z_stream)
     D   stream_initialised...
     D                               10i 0
     D   pos_in_buffered_data...
     D                               10u 0
     D   pos_local_header...
     D                               10u 0
     D   central_header...
     D                                 *
     D   size_centralheader...
     D                               10u 0
     D   flag                        10u 0
     D   method                      10i 0
     D   raw                         10i 0
     D   buffered_data...
     D                                 n   dim(16384)
     D   dosDate                     10u 0
     D   crc32                       10u 0
     D   encrypt                     10i 0
     D   keys                        10u 0 dim(3)
     D   pcrc_32_tab                   *
     D   cryp_header_size...
     D                               10i 0
     D*
     D* zlib_filefunc_def ds used in zip_internal
     D zlib_filefunc_def...
     D                 ds                  qualified template align
     D   zopen_file                    *
     D   zread_file                    *
     D   zwrite_file                   *
     D   ztell_file                    *
     D   zseek_file                    *
     D   zclose_file                   *
     D   zerror_file                   *
     D   opaque                        *
     D*
     D* zip_internal ds, used to define zipFile
     D linkedlist_data...
     D                 ds                  qualified template align
     D   first_block                   *
     D   last_block                    *
     D*
     D* zip_internal ds, used to define zipFile
     D zip_internal    ds                  qualified template align
     D   z_filefunc                        likeds(zlib_filefunc_def)
     D   filestream                        likeds(filestream)
     D   central_dir                       likeds(linkedlist_data)
     D   in_opened_file_inzip...
     D                               10i 0
     D   ci                                likeds(curfile_info)
     D   beg_pos                     10u 0 inz(0)
     D   add_pos_when_writing_offset...
     D                               10u 0 inz(0)
     D   number_entry                10u 0 inz(0)
     D   globalcomment...
     D                                 *
     D*
     D* weird date structure, used in zip_fileinfo ds
     D tm_zip          ds                  qualified template align
     D   tm_sec                      10u 0 inz(0)                               seconds after min
     D   tm_min                      10u 0 inz(0)                               minutes after Hour
     D   tm_hour                     10u 0 inz(0)                               hours since midnight
     D   tm_mday                     10u 0 inz(0)                               day of the month
     D   tm_mon                      10u 0 inz(0)                               months since 1,0-11
     D   tm_year                     10u 0 inz(0)                               years - [1980..2044]
     D*
     D* file info structure
     D zip_fileinfo    ds                  qualified template align
     D   tmz_date                          likeds(tm_zip) inz(*likeds)
     D   dosDate                     10u 0 inz(0)
     D   internal_fa                 10u 0 inz(0)
     D   external_fa                 10u 0 inz(0)
     D*
     D*******************************************************************
     D* Create a zipfile.
     D*    pathname contain on Windows XP a filename like "c:\\zlib\\zlib113.zip" or on
     D*      an Unix computer "zlib/zlib113.zip".
     D*    if the file pathname exist and append==APPEND_STATUS_CREATEAFTER, the zip
     D*      will be created at the end of the file.
     D*        (useful if the file contain a self extractor code)
     D*    if the file pathname exist and append==APPEND_STATUS_ADDINZIP, we will
     D*      add files in existing zip (be sure you don't add file that doesn't exist)
     D*    If the zipfile cannot be opened, the return value is NULL.
     D*    Else, the return value is a zipFile Handle, usable with other function
     D*      of this zip package.
     D zipOpen         PR              *   extproc(*CWIDEN :'zipOpen')
     D    Pathname                     *   value options(*string)
     D    append                     10i 0 value
     D* Append statuses for zipOpen
     D APPEND_STATUS_CREATE...
     D                 C                   0
     D APPEND_STATUS_CREATEAFTER...
     D                 C                   1
     D APPEND_STATUS_ADDINZIP...
     D                 C                   2
     D*******************************************************************
     D zipOpen2        PR              *   extproc(*CWIDEN :'zipOpen2')
     D    pathname                     *   value options(*string)
     D    append                     10i 0 value
     D    globalcommentt...
     D                                 *   value options(*string)
     D    pzlib_filefunc_def...
     D                                 *   value options(*string)
     D*******************************************************************
     D* Open a file in the ZIP for writing.
     D* filename : the filename in zip (if NULL, '-' without quote will be used
     D* *zipfi contain supplemental information
     D* if extrafield_local!=NULL and size_extrafield_local>0, extrafield_local
     D*   contains the extrafield data the the local header
     D* if extrafield_global!=NULL and size_extrafield_global>0, extrafield_global
     D*   contains the extrafield data the the local header
     D* if comment != NULL, comment contain the comment string
     D* method contain the compression method (0 for store, Z_DEFLATED for deflate)
     D* level contain the level of compression (can be Z_DEFAULT_COMPRESSION)
     D zipOpenNewFileInZip...
     D                 PR            10i 0 extproc(*CWIDEN
     D                                            :'zipOpenNewFileInZip')
     D    ZipFile                          likeds(zip_internal)
     D    FileName                     *   value options(*string)
     D    Zip_File_Info...
     D                                 *   value options(*string)
     D    extrafield_local...
     D                                 *   value options(*string)
     D    size_extrafield_local...
     D                               10u 0 value
     D    extrafield_global...
     D                                 *   value options(*string)
     D    size_extrafield_global...
     D                               10u 0 value
     D    comment                      *   value options(*string)
     D    method                     10i 0 value
     D    level                      10i 0 value
     D*******************************************************************
     D* Same as zipOpenNewFileInZip, except if raw=1, we write raw file
     D zipOpenNewFileInZip2...
     D                 PR            10i 0 extproc(*CWIDEN
     D                                            :'zipOpenNewFileInZip2')
     D    ZipFile                          likeds(zip_internal)
     D    FileName                     *   value options(*string)
     D    Zip_File_Info...
     D                                 *   value options(*string)
     D    extrafield_local...
     D                                 *   value options(*string)
     D    size_extrafield_local...
     D                               10u 0 value
     D    extrafield_global...
     D                                 *   value options(*string)
     D    size_extrafield_global...
     D                               10u 0 value
     D    comment                      *   value options(*string)
     D    method                     10i 0 value
     D    level                      10i 0 value
     D    raw                        10i 0 value
     D*******************************************************************
     D* Same as zipOpenNewFileInZip2, except
     D*   windowBits,memLevel,,strategy : see parameter strategy in deflateInit2
     D*   password : crypting password (NULL for no crypting)
     D*   crcForCtypting : crc of file to compress (needed for crypting)
     D zipOpenNewFileInZip3...
     D                 PR            10i 0 extproc(*CWIDEN
     D                                            :'zipOpenNewFileInZip3')
     D    ZipFile                          likeds(zip_internal)
     D    FileName                     *   value options(*string)
     D    Zip_File_Info...
     D                                 *   value options(*string)
     D    extrafield_local...
     D                                 *   value options(*string)
     D    size_extrafield_local...
     D                               10u 0 value
     D    extrafield_global...
     D                                 *   value options(*string)
     D    size_extrafield_global...
     D                               10u 0 value
     D    comment                      *   value options(*string)
     D    method                     10i 0 value
     D    level                      10i 0 value
     D    raw                        10i 0 value
     D    windowBits                 10i 0 value
     D    memLevel                   10i 0 value
     D    strategy                   10i 0 value
     D    password                     *   value options(*string)
     D    crcForCtypting...
     D                               10u 0 value
     D*******************************************************************
     D* Write data in the zipfile
     D zipWriteInFileInZip...
     D                 PR            10i 0 extproc(*CWIDEN
     D                                            :'zipWriteInFileInZip')
     D    ZipFile                          likeds(zip_internal)
     D    buf                          *   value
     D    length                     10u 0 value
     D*******************************************************************
     D* Close the zipfile
     D zipClose        PR            10i 0 extproc(*CWIDEN :'zipClose')
     D    ZipFile                          likeds(zip_internal)
     D    Global_Comment...
     D                                 *   value options(*string)
     D*******************************************************************
     D* Close the current file in the zipfile
     D zipCloseFileInZip...
     D                 PR            10i 0 extproc(*CWIDEN :'zipCloseFileInZip')
     D    ZipFile                          likeds(zip_internal)
     D*******************************************************************
     D* Close the current file in the zipfile, for file opened with
     D*   parameter raw=1 in zipOpenNewFileInZip2
     D* uncompressed_size and crc32 are value for the uncompressed size
     D zipCloseFileInZipRaw...
     D                 PR            10i 0 extproc(*CWIDEN
     D                                            :'zipCloseFileInZipRaw')
     D    ZipFile                          likeds(zip_internal)
     D    Uncompressed_size...
     D                               10u 0
     D    crc32                      10u 0
