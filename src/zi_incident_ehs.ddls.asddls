@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EHS Incident Root View'
define root view entity ZI_INCIDENT_EHS
  as select from zinc_ehs_table
{
  key incident_id as IncidentId,
  incident_no as IncidentNo,
  category as Category,
  severity as Severity,
  description as Description,
  status as Status,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt
}
