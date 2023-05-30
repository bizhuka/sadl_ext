interface ZIF_SADL_READ_RUNTIME
  public .


  interfaces ZIF_SADL_EXIT .

  methods EXECUTE
    importing
      !IV_NODE_NAME type STRING
      !IS_FILTER type ANY
      !IV_WHERE type STRING
      !IS_REQUESTED type IF_SADL_QUERY_ENGINE_TYPES=>TY_REQUESTED
    changing
      !CT_DATA_ROWS type STANDARD TABLE
      !CV_NUMBER_ALL_HITS type I .
endinterface.
