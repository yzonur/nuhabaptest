*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZABAP003_T_SY_PM................................*
DATA:  BEGIN OF STATUS_ZABAP003_T_SY_PM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZABAP003_T_SY_PM              .
CONTROLS: TCTRL_ZABAP003_T_SY_PM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZABAP003_T_SY_PM              .
TABLES: ZABAP003_T_SY_PM               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
