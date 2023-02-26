"Name: \TY:CL_SADL_GW_GENERIC_DPC\ME:PREPROCESS_BATCH\SE:END\EI
ENHANCEMENT 0 ZSADL_EXT_GW_GENERIC_DPC.

   CHECK mo_mdp      IS NOT INITIAL
     AND mo_sadl_api IS NOT INITIAL
     AND mr_service_document_name IS NOT INITIAL
     AND mr_service_document_name->* CP 'Z*_CDS'.
   DATA(lv_zabap_len)    = strlen( mr_service_document_name->* ) - 4.
   DATA(lv_zabap_prefix) = |CDS_{ mr_service_document_name->*(lv_zabap_len) }|.

   DATA lt_zabap_entities TYPE SORTED TABLE OF sadl_entity_id WITH UNIQUE KEY table_line.
   LOOP AT et_create ASSIGNING FIELD-SYMBOL(<ls_create>).
     INSERT <ls_create>-entity_id INTO TABLE lt_zabap_entities.
   ENDLOOP.
   LOOP AT et_update ASSIGNING FIELD-SYMBOL(<ls_update>).
     INSERT <ls_update>-entity_id INTO TABLE lt_zabap_entities.
   ENDLOOP.
   LOOP AT et_delete ASSIGNING FIELD-SYMBOL(<ls_delete>).
     INSERT <ls_delete>-entity_id INTO TABLE lt_zabap_entities.
   ENDLOOP.
   LOOP AT et_action ASSIGNING FIELD-SYMBOL(<ls_action>).
     INSERT <ls_action>-entity_id INTO TABLE lt_zabap_entities.
   ENDLOOP.

   LOOP AT lt_zabap_entities ASSIGNING FIELD-SYMBOL(<lv_zabap_entity>).
     TRY.
         DATA(ls_zabap_load) = mo_mdp->get_entity_load_by_id( |{ lv_zabap_prefix }~{ <lv_zabap_entity> }| ).
       CATCH cx_sadl_contract_violation.
         CLEAR ls_zabap_load.
     ENDTRY.
     CHECK ls_zabap_load IS NOT INITIAL.

     ASSIGN ls_zabap_load->sadl_entity-cds_entity_annotations[ annoname = zcl_sadl_annotation_ext=>id ] TO FIELD-SYMBOL(<ls_zabap_anno>).
     CHECK sy-subrc = 0.

     DATA(lo_sadl_exit) = zcl_sadl_annotation_ext=>create( <ls_zabap_anno>-value ).
     CHECK lo_sadl_exit IS NOT INITIAL
       AND lo_sadl_exit IS INSTANCE OF zif_sadl_prepare_batch.

     CAST zif_sadl_prepare_batch( lo_sadl_exit
                  )->prepare( EXPORTING iv_node_name         = ls_zabap_load->sadl_entity-node_name
                                        it_changeset_request = it_changeset_request
                              CHANGING  ct_update            = et_update
                                        ct_create            = et_create
                                        ct_delete            = et_delete
                                        ct_action            = et_action ).
   ENDLOOP.
ENDENHANCEMENT.
