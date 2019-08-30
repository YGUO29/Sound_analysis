prefix      =   'voc';
subject     =   'M91C_M92C_M64A_M29A';
% subject     =   '9606';
sessionNums = {'S141', 'S142', 'S143', 'S145', 'S147', 'S152', 'S156'};
% sessionNums = {'S141', 'S142', 'S145', 'S147', 'S152', 'S156'};
% sessionNums = {'S189', 'S190', 'S193', 'S194'};
% sessionNums = {'c_S197'};
len_sessionNums = length(sessionNums);
% len_sessionNums = 3;
for i = 1  : len_sessionNums
    sessionNum = sessionNums{i};
    %----------load parameters---------
    param       =   social.vad.tools.Param(subject);
    param.scoreThresholdParRef = 0;
    param.scoreThresholdWireless = [0, 0, 0];
    %----------new a session----------
    f           =   [prefix,'_',subject,'_',sessionNum,'.hdr'];
    filename    =   fullfile(param.soundFilePath,subject,f);
    session     =   social.session.StandardSession(filename);
    sessionName = [prefix,'_',subject,'_',sessionNum];

    sigPar = session.Signals(1);
    sigRef = session.Signals(2);
    sigOth = {};
    temp = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
    session.Behaviors = temp;
    
    
%     sigPar = session.Signals(1);
%     sigRef = session.Signals(2);
%     sigWireless{1} = session.Signals(4);
%     sigWireless{2} = session.Signals(5);
%     temp = social.behavior.('ColonyWirelessChannel')(session,sessionName,sigPar,sigRef,sigWireless,false,param);
%     if isempty(session.Behaviors)
%         session.Behaviors = temp;
%     else
%         session.Behaviors(end+1) = temp;
%     end    
%     
    
% %     wireless
%     sigPar = session.Signals(3);
%     sigRef = session.Signals(1);
%     sigWireless{1} = session.Signals(5);
%     sigWireless{2} = session.Signals(6);
%     temp = social.behavior.('ColonyWirelessChannel')(session,sessionName,sigPar,sigRef,sigWireless,false,param);
%     if isempty(session.Behaviors)
%         session.Behaviors = temp;
%     else
%         session.Behaviors(end+1) = temp;
%     end
% %     par-ref
%     sigPar = session.Signals(1);
%     sigRef = session.Signals(4);
%     sigOth{1} = session.Signals(2);
%     sigOth{2} = session.Signals(3);
%     temp = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
%     if isempty(session.Behaviors)
%         session.Behaviors = temp;
%     else
%         session.Behaviors(end + 1) = temp;
%     end
% 
% %     par-ref 
%     sigPar = session.Signals(2);
%     sigRef = session.Signals(4);
%     sigOth{1} = session.Signals(1);
%     sigOth{2} = session.Signals(3);
%     temp = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
%     if isempty(session.Behaviors)
%         session.Behaviors = temp;
%     else
%         session.Behaviors(end + 1) = temp;
%     end

    % start detection
    tic
    session.DetectAllEvents; 
    toc
    session.saveSession(param.dataFolder);

    % mat file to selection table
    run('social.vad.tools.Calls_MAT2Table.m');

    % error quantification
    % run('social.vad.tools.ErrorQuantification.m');
end

