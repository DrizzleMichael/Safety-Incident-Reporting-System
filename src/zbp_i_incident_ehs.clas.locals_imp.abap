" ======================================================================
" 1. THE BUFFER DEFINITION (This must be at the very top!)
" ======================================================================
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_create TYPE TABLE OF zinc_ehs_table,
                mt_update TYPE TABLE OF zinc_ehs_table,
                mt_delete TYPE TABLE OF zinc_ehs_table.
ENDCLASS.

" ======================================================================
" 2. THE HANDLER CLASS (Interaction Phase)
" ======================================================================
CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Incident.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Incident.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Incident.

    METHODS read FOR READ
      IMPORTING keys FOR READ Incident RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Incident.
ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_authorizations.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( IncidentId = ls_key-IncidentId
                      %update    = if_abap_behv=>auth-allowed
                      %delete    = if_abap_behv=>auth-allowed ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    DATA: ls_incident TYPE zinc_ehs_table.
    LOOP AT entities INTO DATA(ls_entity).
      ls_incident-client = sy-mandt.
      TRY.
          ls_incident-incident_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.
      ls_incident-incident_no = 'EHS-001'.
      ls_incident-category = ls_entity-Category.
      ls_incident-severity = ls_entity-Severity.
      ls_incident-description = ls_entity-Description.
      ls_incident-status = 'N'.
      ls_incident-created_by = sy-uname.
      GET TIME STAMP FIELD ls_incident-created_at.

      APPEND ls_incident TO lcl_buffer=>mt_create.

      INSERT VALUE #( %cid       = ls_entity-%cid
                      IncidentId = ls_incident-incident_id ) INTO TABLE mapped-incident.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA ls_update TYPE zinc_ehs_table.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zinc_ehs_table WHERE incident_id = @ls_entity-IncidentId INTO @ls_update.
      IF sy-subrc = 0.
        ls_update-category    = ls_entity-Category.
        ls_update-severity    = ls_entity-Severity.
        ls_update-description = ls_entity-Description.
        APPEND ls_update TO lcl_buffer=>mt_update.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      " This was failing because lcl_buffer wasn't defined at the top!
      APPEND VALUE #( incident_id = ls_key-IncidentId ) TO lcl_buffer=>mt_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zinc_ehs_table FOR ALL ENTRIES IN @keys
      WHERE incident_id = @keys-IncidentId
      INTO TABLE @DATA(lt_incidents).

    LOOP AT lt_incidents INTO DATA(ls_incident).
      INSERT VALUE #( IncidentId  = ls_incident-incident_id
                      IncidentNo  = ls_incident-incident_no
                      Category    = ls_incident-category
                      Severity    = ls_incident-severity
                      Description = ls_incident-description
                      Status      = ls_incident-status
                      CreatedBy   = ls_incident-created_by
                      CreatedAt   = ls_incident-created_at ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    " Mandatory dummy method for RAP
  ENDMETHOD.

ENDCLASS.

" ======================================================================
" 3. THE SAVER CLASS (Save Phase)
" ======================================================================
CLASS lsc_Incident DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_Incident IMPLEMENTATION.
  METHOD save.
    IF lcl_buffer=>mt_create IS NOT INITIAL.
      INSERT zinc_ehs_table FROM TABLE @lcl_buffer=>mt_create.
    ENDIF.
    IF lcl_buffer=>mt_update IS NOT INITIAL.
      UPDATE zinc_ehs_table FROM TABLE @lcl_buffer=>mt_update.
    ENDIF.
    IF lcl_buffer=>mt_delete IS NOT INITIAL.
      DELETE zinc_ehs_table FROM TABLE @lcl_buffer=>mt_delete.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lcl_buffer=>mt_create, lcl_buffer=>mt_update, lcl_buffer=>mt_delete.
  ENDMETHOD.
ENDCLASS.
