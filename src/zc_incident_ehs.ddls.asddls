@EndUserText.label: 'Incident Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_INCIDENT_EHS
  provider contract transactional_query
  as projection on ZI_INCIDENT_EHS
{
  -- This creates the "Incident Details" section block on the Object Page
  @UI.facet: [ { id:              'Incident',
                 purpose:         #STANDARD,
                 type:            #IDENTIFICATION_REFERENCE,
                 label:           'Incident Details',
                 position:        10 } ]

  -- Hide the backend UUID from the user
  @UI.hidden: true
  key IncidentId,

  @UI.lineItem:       [{ position: 10 }]
  @UI.identification: [{ position: 10 }]
  @EndUserText.label: 'Incident Number'
  IncidentNo,

  @UI.lineItem:       [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  @EndUserText.label: 'Category'
  Category,

  @UI.lineItem:       [{ position: 30 }]
  @UI.identification: [{ position: 30 }]
  @EndUserText.label: 'Severity'
  Severity,

  @UI.lineItem:       [{ position: 40 }]
  @UI.identification: [{ position: 40 }]
  @EndUserText.label: 'Description'
  Description,

  @UI.lineItem:       [{ position: 50 }]
  @UI.identification: [{ position: 50 }]
  @EndUserText.label: 'Status'
  Status,

  -- Hide the admin fields from the creation screen
  @UI.hidden: true
  CreatedBy,

  @UI.hidden: true
  CreatedAt
}
