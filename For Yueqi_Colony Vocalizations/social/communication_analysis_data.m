prefix = 'voc';
subject = 'M91C_M92C_M64A_M29A';


% condition 4 & 5
sessionNums = { 'S68', 'S70', 'S73', 'S76', 'S78',...
                'S80', 'S82', 'S84', 'S85', 'S86',...
                'S88', 'S90', 'S92', 'S95', 'S98',...
                'S100','S101','S106','S111','S115',...
                'S116','S119','S120','S123','S125',...
                'S126','S128','S129','S130','S131',...
                'S131','S132','S133','S134'};
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
    % -----------------------------------
    % example: 4M, condition 3,4,5
    % -----------------------------------
    behChnPar = [1,2,3,4];
    behChnRef = [2,3,4,1];
    behChnOth = [3,4,1,2;4,1,2,3];
    for iBeh = 1 : length(behChnPar)
        sigPar = session.Signals(behChnPar(iBeh));
        sigRef = session.Signals(behChnRef(iBeh));
        sigOth = {};
        for ic = 1 : size(behChnOth,1)
            sigOth{ic} = session.Signals(behChnOth(ic, iBeh));
        end
        temp = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
        if isempty(session.Behaviors)
            session.Behaviors = temp;
        else
            session.Behaviors(end+1) = temp;
        end
    end
    % start detection
    tic
    session.DetectAllEvents; 
    toc
    session.saveSession(param.dataFolder);
    % mat file to selection table
    run('social.vad.tools.Calls_MAT2Table.m');
end


% condition 6
sessionNums = { 'S141','S142','S143','S145','S147',...
                'S151','S152','S154','S156','S161',...
                'S162','S164','S165','S169','S171',...
                'S173','S176','S177','S178','S179',...
                'S181','S182','S183','S184'};
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
    % example: 4M, condition 6 
    %-------------------
    % wireless
    sigPar = session.Signals(3);
    sigRef = session.Signals(1);
    sigWireless{1} = session.Signals(5);
    sigWireless{2} = session.Signals(6);
    temp = social.behavior.('ColonyWirelessChannel')(session,sessionName,sigPar,sigRef,sigWireless,false,param);
    if isempty(session.Behaviors)
        session.Behaviors = temp;
    else
        session.Behaviors(end+1) = temp;
    end
    % par-ref
    sigPar = session.Signals(1);
    sigRef = session.Signals(2);
    sigOth = {};
    sigOth{1} = session.Signals(3);
    sigOth{2} = session.Signals(4);
    temp = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
    if isempty(session.Behaviors)
        session.Behaviors = temp;
    else
        session.Behaviors(end + 1) = temp;
    end
    % par-ref 
    sigPar = session.Signals(2);
    sigRef = session.Signals(1);
    sigOth = {};
    sigOth{1} = session.Signals(3);
    sigOth{2} = session.Signals(4);
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
            
            