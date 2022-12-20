interface ZIF_SADL_DELETE_RUNTIME
  public .


  interfaces ZIF_SADL_EXIT .

  methods EXECUTE
    importing
      !IV_ALTERNATIVE_KEY_NAME type IF_SADL_ENTITY=>TY_KEY_NAME optional
      !IT_KEY_VALUES type INDEX TABLE
    exporting
      !ET_FAILED type IF_SADL_ENTITY_TRANSACTIONAL=>TT_TABIX
    raising
      CX_SADL_STATIC
      CX_SADL_CONTRACT_VIOLATION .
endinterface.
