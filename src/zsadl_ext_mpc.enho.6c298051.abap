"Name: \TY:CL_SADL_GTK_GENERIC_MPC\ME:DEFINE\SE:END\EI
ENHANCEMENT 0 ZSADL_EXT_MPC.

    TRY.
        DATA(zz_lo_mp) = get_sadl_mp( ).
        CHECK zz_lo_mp IS NOT INITIAL.

        DATA(zz_lv_uuid) = zz_lo_mp->if_bsa_sadl_mp~get_uuid( ).
        CHECK zz_lv_uuid CP 'CDS_Z*'.

        DATA(zz_lo_mdp) = cl_sadl_metadata_provider=>get( zz_lo_mp ).

        zz_lo_mdp->get_entity_ids( IMPORTING et_ids = DATA(zz_lt_ids) ).
        LOOP AT zz_lt_ids ASSIGNING FIELD-SYMBOL(<zz_ls_ids>).
          SPLIT <zz_ls_ids> AT '~' INTO zz_lv_uuid
                                        DATA(zz_lv_entity).
          DATA(zz_ls_load) = zz_lo_mdp->get_entity_load( zz_lv_entity ).
          CHECK zz_ls_load IS NOT INITIAL.

          ASSIGN zz_ls_load->sadl_entity-cds_entity_annotations[ annoname = zcl_sadl_annotation_ext=>id ] TO FIELD-SYMBOL(<zz_ls_anno>).
          CHECK sy-subrc = 0.

          DATA(zz_lo_sadl_exit) = zcl_sadl_annotation_ext=>create( <zz_ls_anno>-value ).
          CHECK zz_lo_sadl_exit IS NOT INITIAL
            AND zz_lo_sadl_exit IS INSTANCE OF zif_sadl_mpc.

          CAST zif_sadl_mpc( zz_lo_sadl_exit )->define( io_model  = model
                                                        iv_entity = CONV #( zz_lv_entity && 'Type' ) ).
        ENDLOOP.
      CATCH cx_sadl_static.
        RETURN.
    ENDTRY.


ENDENHANCEMENT.
