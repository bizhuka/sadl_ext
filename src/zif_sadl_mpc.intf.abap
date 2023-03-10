interface ZIF_SADL_MPC
  public .


  interfaces ZIF_SADL_EXIT .

  methods DEFINE
    importing
      !IO_MODEL type ref to /IWBEP/IF_MGW_ODATA_MODEL
      !IV_ENTITY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
endinterface.
