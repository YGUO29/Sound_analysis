prefix = 'voc';
subject = 'M93A';
param = social.vad.tools.Param(subject);
sessionNum = 'c_S130';
sessionName = [prefix, '_', subject, '_', sessionNum];
filename = fullfile(param.soundFilePath, subject, [sessionName, '.hdr']);
session = social.session.StandardSession(filename);
sigPar = session.Signals(1);
sigRef = session.Signals(2);
sigOth = {};
session.Behaviors = social.behavior.('ColonyParRefChannel')(session, sessionName, sigPar, sigRef, sigOth, false, param);

autoDetectionFile = fullfile(param.selectionTablePathOut, ['SelectionTable_', sessionName, '.txt']);
groundTruthFile = fullfile(param.selectionTablePath, ['SelectionTable_', sessionName, '.txt']);
boxChannel = 1;
evaluator = social.vad.tools.Evaluator(autoDetectionFile, groundTruthFile, boxChannel);
[false_alarm_rate, calls] = evaluator.false_alarm_eval(session.Behaviors);
% save
p = param.dataFolder;
filename = fullfile(p, [sessionName, '.mat']);
session.Behaviors.Events = calls;
session.saveSession(p);
run('social.vad.tools.Calls_MAT2Table.m');