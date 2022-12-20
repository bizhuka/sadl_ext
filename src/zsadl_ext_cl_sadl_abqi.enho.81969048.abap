"Name: \TY:CL_SADL_ABQI\IN:IF_SADL_ABQI\ME:SELECT\SE:END\EI
ENHANCEMENT 0 ZSADL_EXT_CL_SADL_ABQI.

   CHECK mo_mdp IS NOT INITIAL
     AND mv_entity_id CP 'CDS_Z*'.

   TRY.
     DATA(ls_zabap_load) = mo_mdp->get_entity_load_by_id( mv_entity_id ).
   CATCH cx_sadl_contract_violation.
     CLEAR ls_zabap_load.
   ENDTRY.
   CHECK ls_zabap_load IS NOT INITIAL.

   ASSIGN ls_zabap_load->sadl_entity-cds_entity_annotations[ annoname = zcl_sadl_annotation_ext=>id ] TO FIELD-SYMBOL(<ls_zabap_anno>).
   CHECK sy-subrc = 0.

   DATA(lo_sadl_exit) = zcl_sadl_annotation_ext=>create( <ls_zabap_anno>-value ).
   CHECK lo_sadl_exit IS NOT INITIAL
     AND lo_sadl_exit IS INSTANCE OF zif_sadl_read_runtime.

   zcl_sadl_filter=>get_filter( EXPORTING it_sadl_conditions    = lt_complex_condition
                                          it_condition_provider = mt_condition_providers
                                IMPORTING ev_where              = DATA(lv_zabap_where)
                                          et_range              = DATA(lt_zabap_range) ).

   CAST zif_sadl_read_runtime( lo_sadl_exit
               )->execute( EXPORTING iv_node_name       = ls_zabap_load->sadl_entity-node_name
                                     it_range           = lt_zabap_range
                                     iv_where           = lv_zabap_where
                           CHANGING  ct_data_rows       = et_data_rows
                                     cv_number_all_hits = ev_number_all_hits ).
ENDENHANCEMENT.
