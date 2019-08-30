prefix = 'voc';
subject = 'M91C_M92C_M64A_M29A';


% condition 4 & 5
sessionNums = {'S176','S177','S178','S179',...
                'S181','S182','S183','S184'...
                };
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
    % example: 4M, condition 6 later part
    % -----------------------------------
    behChnPar = [1,2,3];
    behChnRef = [2,3,1];
    behChnOth = [3,1,2];
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

