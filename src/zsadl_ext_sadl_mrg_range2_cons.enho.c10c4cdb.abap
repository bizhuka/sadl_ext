"Name: \TY:CL_SADL_COND_PROV_NAVIGATION\ME:CONSTRUCTOR\SE:END\EI
ENHANCEMENT 0 ZSADL_EXT_SADL_MRG_RANGE2_CONS.

    CHECK ir_target_entity_load IS NOT INITIAL
      AND ir_target_entity_load->entity_id CS '~Z'.

    " Get keys
*    zz_mt_range = VALUE #( FOR <zz_ls_key> IN is_navigate-source_keys (
*      column_name = <zz_ls_key>-name
*      field_path  = <zz_ls_key>-name
*      t_selopt    = VALUE #( ( sign = 'I' option = 'EQ' low = <zz_ls_key>-value ) ) ) ).

    get_key_map( EXPORTING ir_source_entity_load    = ir_source_entity_load
                           iv_association           = is_navigate-association
                           it_provided_src_elements = VALUE #( FOR <zz_src_key> IN is_navigate-source_keys ( <zz_src_key>-name ) )
                           ir_target_entity_load    = ir_target_entity_load
                 IMPORTING et_key_map               = DATA(zz_lt_key_map) ).

    LOOP AT zz_lt_key_map ASSIGNING FIELD-SYMBOL(<zz_ls_key_map>).
      ASSIGN is_navigate-source_keys[ name = <zz_ls_key_map>-source_alias ] TO FIELD-SYMBOL(<ls_zz_src_key>).
      CHECK sy-subrc = 0.

      INSERT VALUE #( column_name = <ls_zz_src_key>-name
                      field_path  = <ls_zz_src_key>-name
                      t_selopt    = VALUE #( ( sign = 'I' option = 'EQ' low = <ls_zz_src_key>-value ) ) ) INTO TABLE zz_mt_range[].
    ENDLOOP.

**********************************************************************
    " Add constants in CDS joins
    LOOP AT ir_target_entity_load->db_view_metadata-joins ASSIGNING FIELD-SYMBOL(<zz_ls_join>).
      CHECK <zz_ls_join>-target_alias CP |*_{ is_navigate-association }_*|.    " { <zz_ls_join>-source_alias }

      LOOP AT <zz_ls_join>-condition ASSIGNING FIELD-SYMBOL(<zz_ls_value>) WHERE type = 'simpleValue'.
        ASSIGN <zz_ls_join>-condition[ sy-tabix + 1 ] TO FIELD-SYMBOL(<zz_ls_field>).
        CHECK sy-subrc = 0 AND <zz_ls_field>-type = 'sourceAttribute'.

        INSERT VALUE #( column_name = <zz_ls_field>-attribute
                        field_path  = <zz_ls_field>-attribute
                        t_selopt    = VALUE #( ( sign = 'I' option = 'EQ' low = <zz_ls_value>-value ) ) ) INTO TABLE zz_mt_range[].
      ENDLOOP.
    ENDLOOP.
ENDENHANCEMENT.
