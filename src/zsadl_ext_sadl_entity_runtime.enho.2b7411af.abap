"Name: \TY:CL_SADL_ENTITY_RUNTIME\ME:_DELETE\SE:BEGIN\EI
ENHANCEMENT 0 ZSADL_EXT_SADL_ENTITY_RUNTIME.

 DO 1 TIMES.
   CHECK  mo_mdp         IS NOT INITIAL
      AND mo_sadl_entity IS NOT INITIAL
      AND me->mv_structure_name CP 'Z*'.

   mo_sadl_entity->get_annotations( IMPORTING et_entity_annotations = DATA(lt_zabap_annotation) ).
   ASSIGN lt_zabap_annotation[ name = zcl_sadl_annotation_ext=>id ] TO FIELD-SYMBOL(<ls_zabap_anno>).
   CHECK sy-subrc = 0.

   DATA(lo_sadl_exit) = zcl_sadl_annotation_ext=>create( <ls_zabap_anno>-value ).
   CHECK lo_sadl_exit IS NOT INITIAL
     AND lo_sadl_exit IS INSTANCE OF zif_sadl_delete_runtime.

   CAST zif_sadl_delete_runtime( lo_sadl_exit
               )->execute( EXPORTING iv_alternative_key_name = iv_alternative_key_name
                                     it_key_values           = it_key_values
                           IMPORTING et_failed               = et_failed ).
   RETURN.
 ENDDO.

ENDENHANCEMENT.
