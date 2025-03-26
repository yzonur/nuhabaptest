*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZABAP003_T_RMAIL................................*
DATA:  BEGIN OF STATUS_ZABAP003_T_RMAIL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZABAP003_T_RMAIL              .
CONTROLS: TCTRL_ZABAP003_T_RMAIL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZABAP003_T_RMAIL              .
TABLES: ZABAP003_T_RMAIL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
