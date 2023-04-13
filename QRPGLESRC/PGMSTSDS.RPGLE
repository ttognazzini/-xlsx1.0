      *˜****************************************
      *˜* Sample Program Status Data Structure *
      *˜****************************************
      *‚                                                        Begin    Ending
      *‚Seq            Value                 Data        Data   Buffer   Buffer  Alternate
      *‚Num          Contained               Type       Length Position Position Location
      *‚--- ---------------------------- -------------  ------ -------- -------- ---------
      *š12  Program RPG Message          Character      4       171     174
      *š4   Program Source Statement     Character      8       21      28
      *š5   Program Routine              Character      8       29      36       *routine
      *š6   Program Number Of Parameters Zoned Decimal  3,0     37      39       *parms
      *š7   Program Message ID           Character      7       40      46
      *š8   Program MI Instruction Code  Character      4       47      50
      *š9   Program Work                 Character      30      51      80
      *š10  Program Library              Character      10      81      90
      *š11  Program Error Data           Character      80      91      170
      *š12  Program RPG Message          Character      4       171     174
      *š13  Program Job Name             Character      10      244     253
      *š14  Program User ID              Character      10      254     263
      *š15  Program Job Number           Zoned Decimal  6,0     264     269
      *š16  Program Job Date             Zoned Decimal  6       270     275
      *š17  Program Run Date             Zoned Decimal  6       276     281
      *š18  Program Run Time             Zoned Decimal  6       282     287
      *š
      *‚***************************************************************
      *‚Sample Program Status Data Structure in RPG IV Style Version 1
      *‚***************************************************************
     Dpsds            sds
     D pgmname                       10a                                        Program Name
     D pgmsts                         5s 0                                      Program Status
     D pgmprvsts                      5s 0                                      Program Prv Status
     D pgmsrcstmt                     8a                                        Program Source State
     D pgmroutine                     8a                                        Program Routine
     D pgmparms                       3s 0                                      Program # Of Parms
     D pgmmsgid                       7a                                        Program Message ID
     D pgmmi#                         4a                                        Program MI Ins Code
     D pgmwork                       30a                                        Program Work
     D pgmlib                        10a                                        Program Library
     D pgmerrdta                     80a                                        Program Error Data
     D pgmrpgmsg                      4a                                        Program RPG Message
     D pgmjob                        10a                                        Program Job Name
     D pgmuser                       10a                                        Program User ID
     D pgmjobnum                      5s 0                                      Program Job Number
     D pgmjobdate                     6s 0                                      Program Job Date
     D pgmrundate                     6s 0                                      Program Run Date
     D pgmruntime                     6s 0                                      Program Run Time
     D*
