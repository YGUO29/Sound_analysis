prefix = 'voc';
subject = 'M91C_M92C_M64A_M29A';



            
% condition 7            
sessionNums = { 'S189','S193','S194','S198','S200',...
                'S201','S203','S204','S205','S207',...
                'S208','S210','S211','S213'};
len_sessionNums = length(sessionNums);
for i = 1  : len_sessionNums
    sessionNum = sessionNums{i};
    %----------load parameters---------
    param       =   social.vad.tools.Param(subject);
    %----------new a session----------
    f           =   [prefix,'_',subject,'_',sessionNum,'.hdr'];
    filename    =   fullfile(param.soundFilePath,subject,f);
    session     =   social.session.StandardSession(filename);
    sessionName = [prefix,'_',subject,'_',sessionNum];
    %-------------------
    % example: 4M, condition 7
    %-------------------
    % wireless
    sigPar = session.Signals(1);
    sigRef = session.Signals(2);
    sigWireless{1} = session.Signals(4);
    sigWireless{2} = session.Signals(5);
    temp = social.behavior.('ColonyWirelessChannel')(session,sessionName,sigPar,sigRef,sigWireless,false,param);
    if isempty(session.Behaviors)
        session.Behaviors = temp;
    else
        session.Behaviors(end+1) = temp;
    end
    % par-ref
    sigPar = session.Signals(2);
    sigRef = session.Signals(3);
    sigOth{1} = session.Signals(1);
    temp = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
    if isempty(session.Behaviors)
        session.Behaviors = temp;
    else
        session.Behaviors(end + 1) = temp;
    end
    % start detection
    tic
    session.DetectAllEvents; 
    toc
    session.saveSession(param.dataFolder);
    % mat file to selection table
    run('social.vad.tools.Calls_MAT2Table.m');
end
            
            