interface ZIF_SADL_READ_RUNTIME
  public .


  interfaces ZIF_SADL_EXIT .

  methods EXECUTE
    importing
      !IV_NODE_NAME type STRING optional
      !IT_RANGE type IF_SADL_COND_PROVIDER_GRPD_RNG=>TT_GROUPED_RANGE optional
      !IV_WHERE type STRING optional
      !IS_REQUESTED type IF_SADL_QUERY_ENGINE_TYPES=>TY_REQUESTED optional
    changing
      !CT_DATA_ROWS type STANDARD TABLE
      !CV_NUMBER_ALL_HITS type I optional .
endinterface.
