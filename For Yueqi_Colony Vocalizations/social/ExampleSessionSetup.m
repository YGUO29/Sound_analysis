% An example script for using social package objects for vocal analysis

session=social.session.StandardSession('C:\data\M28A\voc_M28A_Rack__S32.hdr');

social.analysis.call_detect(session);
Calls=social.analysis.generatePheeCalls(session.Events,'max_gap',1.5);

session.Events=[session.Events Calls];

session.plotEvents;