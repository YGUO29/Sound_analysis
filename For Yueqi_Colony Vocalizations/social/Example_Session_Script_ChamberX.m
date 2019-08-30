%% Example script to analyze vocal behavior recorded from a parabolic/reference pair of microphones.

% ---------train the frame-classification SVM model---------
% run('social.vad.Training_Script.m'); 
% 
% ---------train the class type classification HMM model---------
% run('social.vad.Training_Script_classify.m');

%----------build sessions-----------
%   A session can have several behaviors, each behavior can be independently used to find calls. There are two types of behaviors. One is
%   'ColonyParRefChannel', the other is 'ColonyWirelessChannel'.  
%  
%   'ColonyParRefChannel' should be used when there is one parabolic mic, one reference mic, and zero to several other reference mics.
%       invocation: behavior = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
%           session: the object of session, StandardSession
%           sessionNum: the session name, String
%           sigPar: the object of parabolic mic signal, StandardVocalSignal Object
%           sigRef: the object of reference mic signal, StandardVocalSignal Object
%           sigOth: a cell of objects, each one is a other-reference mic signal, StandardVocalSignal Object
%           false: logical variable
%           param: parameter object, Param Object
%
%   'ColonyWirelessChannel' should be used when there is one parabolic mic, one reference mic, and two to several wireless mics.
%       invocation: behavior = social.behavior.('ColonyWirelessChannel')(session,sessionName,sigPar,sigRef,sigWireless,false,param);
%           session: the object of session, StandardSession
%           sessionNum: the session name, String
%           sigPar: the object of parabolic mic signal, StandardVocalSignal Object
%           sigRef: the object of reference mic signal, StandardVocalSignal Object
%           sigWireless: a cell of objects, each one is a wireless mic signal, StandardVocalSignal Object
%           false: logical variable
%           param: parameter object, Param Object
% ----------------------------------

prefix      =   'voc';
% subject     =   'M91C_M92C_M64A_M29A';
% subject     =   '9606';
subject     =   '93A';
% sessionNums = {'S189', 'S193', 'S194', 'S198', 'S200', 'S201', 'S203', 'S204', 'S205', 'S207', 'S208', 'S210', 'S211', 'S213'};
sessionNums = {'S128','S129','S130','S131','S132'};
% ,  'S28', 'S29', 
% sessionNums = {'c_S176'};
% sessionNums = {'S189'};
len_sessionNums = length(sessionNums);
% len_sessionNums = 1;

if strcmp(subject,'9606')
    subject_fname = 'M9606';
else
    subject_fname = subject;
end
for i = 1  : len_sessionNums
    sessionNum = sessionNums{i};
    %----------load parameters---------
    param       =   social.vad.tools.Param(subject);
    %----------new a session----------
    f           =   [prefix,'_',subject,'_',sessionNum,'.hdr'];
    filename    =   fullfile(param.soundFilePath,f);
    session     =   social.session.StandardSession(filename);
    sessionName = [prefix,'_',subject,'_',sessionNum];
    
%     %-----------------------------------
%     % example: 9606, M93A
%     %-----------------------------------
%     sigPar = session.Signals(1);
%     sigRef = session.Signals(2);
%     sigOth = {};
%     temp = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
%     session.Behaviors = temp;



%     % -----------------------------------
%     % example: 4M, condition 3,4,5
%     % -----------------------------------
    behChnPar = [2];
    behChnRef = [1];
    behChnOth = [];
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
    

%     %-------------------
%     % example: 4M, condition 6 
%     %-------------------
%     % wireless
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
%     % par-ref
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
%     % par-ref 
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

    %-------------------
    % example: 4M, condition 7
    %-------------------
    
    % wireless
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
    
    % par-ref
%     sigPar = session.Signals(2);
%     sigRef = session.Signals(3);
%     sigOth{1} = session.Signals(1);
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

