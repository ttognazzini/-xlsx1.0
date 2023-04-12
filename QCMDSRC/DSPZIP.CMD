             CMD        PROMPT('Display Zipped File') HLPID(*CMD) +
                          HLPPNLGRP(DSPZIP)

             /* REQUIRED PARAMETERS */

             PARM       KWD(ZIPFILE) TYPE(*PNAME) LEN(128) MIN(1) +
                          EXPR(*YES) CASE(*MIXED) PROMPT('ZIP file +
                          name')

