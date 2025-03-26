*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZABAP003_T_U_CON................................*
DATA:  BEGIN OF STATUS_ZABAP003_T_U_CON              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZABAP003_T_U_CON              .
CONTROLS: TCTRL_ZABAP003_T_U_CON
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZABAP003_T_U_CON              .
TABLES: ZABAP003_T_U_CON               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
