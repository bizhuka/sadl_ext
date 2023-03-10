interface ZIF_SADL_STREAM_RUNTIME
  public .


  interfaces ZIF_SADL_EXIT .

  methods GET_STREAM
    importing
      !IO_SRV_RUNTIME type ref to /IWBEP/IF_MGW_CONV_SRV_RUNTIME
      !IV_FILTER type STRING optional
      !IT_FILTER type /iwbep/t_mgw_select_option optional
      !IV_ENTITY_NAME type STRING optional
      !IV_ENTITY_SET_NAME type STRING optional
      !IV_SOURCE_NAME type STRING optional
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
    exporting
      !ER_STREAM type ref to DATA
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods CREATE_STREAM
    importing
      !IO_SRV_RUNTIME type ref to /IWBEP/IF_MGW_CONV_SRV_RUNTIME
      !IV_ENTITY_NAME type STRING optional
      !IV_ENTITY_SET_NAME type STRING optional
      !IV_SOURCE_NAME type STRING optional
      !IS_MEDIA_RESOURCE type /IWBEP/CL_MGW_ABS_DATA=>TY_S_MEDIA_RESOURCE
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH optional
      !IV_SLUG type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
    exporting
      !ER_ENTITY type ref to DATA
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
endinterface.
