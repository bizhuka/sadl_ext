interface ZIF_SADL_PREPARE_READ_RUNTIME
  public .


  interfaces ZIF_SADL_EXIT .

  methods CHANGE_CONDITION
    importing
      !IV_NODE_NAME type STRING
      !IV_WHERE type STRING
      !IS_FILTER type ANY
    changing
      !CT_SADL_CONDITION type IF_SADL_QUERY_TYPES=>TT_COMPLEX_CONDITION .
endinterface.
