"Name: \TY:CL_SADL_ABQI\ME:_ADD_CONDITION\SE:END\EI
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
     AND lo_sadl_exit IS INSTANCE OF zif_sadl_prepare_read_runtime.

   CAST zif_sadl_prepare_read_runtime( lo_sadl_exit
               )->change_condition( EXPORTING iv_node_name       = ls_zabap_load->sadl_entity-node_name
                                              iv_where           = zcl_sadl_filter=>get_sadl_where( ct_condition )
                                    CHANGING  ct_sadl_condition  = ct_condition ).

ENDENHANCEMENT.
