interface ZIF_SADL_PREPARE_BATCH
  public .


  interfaces ZIF_SADL_EXIT .

  methods PREPARE
    importing
      !IV_NODE_NAME type STRING
      !IT_CHANGESET_REQUEST type /IWBEP/IF_MGW_APPL_TYPES=>TY_T_CHANGESET_REQUEST
    changing
      !CT_UPDATE type IF_SADL_BATCH=>TT_UPDATE
      !CT_CREATE type IF_SADL_BATCH=>TT_CREATE
      !CT_DELETE type IF_SADL_BATCH=>TT_DELETE
      !CT_ACTION type IF_SADL_BATCH=>TT_ACTION
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION
      CX_SADL_CONTRACT_VIOLATION
      CX_SADL_STATIC .
endinterface.