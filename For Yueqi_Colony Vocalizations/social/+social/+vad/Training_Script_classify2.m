param = social.vad.tools.Param();
dataFolder = param.dataFolder;

% extract calls
call_seg = [];
xlsxFilename = fullfile(param.soundFilePath,'M91C_M92C_M64A_M29A','M91C_M92C_M64A_M29A_BehaviorChannels.xlsx');
[BehChns] = xlsread(xlsxFilename);
subject = 'M91C_M92C_M64A_M29A';
calls = social.vad.my_call.empty;
numCalls = 0;
numBeh = length(BehChns);
% numBeh = 1;
for i = 1 : numBeh
    display(['extract:',num2str(i)]);
    name                =   ['voc_M91C_M92C_M64A_M29A_S',num2str(BehChns(i,1)),'.hdr'];
    fileName            =   fullfile(param.soundFilePath,subject,name);
    name                =   ['SelectionTable_voc_M91C_M92C_M64A_M29A_S',num2str(BehChns(i,1)),'.txt'];
    tableName           =   fullfile(param.selectionTablePath,name);
    nTableName          =   '';
    param.parChannel    =   BehChns(i,3);
    param.refChannel    =   BehChns(i,4);
    sampleProvider      =   social.vad.SampleProvider(fileName, tableName, nTableName, param);
    call_seg_temp       =   sampleProvider.extractSegs('call', 'parData', 1);
    session             =   social.session.StandardSession(fileName);

    for iType = 1 : length(param.CALL_TYPE)
        for iCall = 1 : length(call_seg_temp{iType})
            numCalls = numCalls + 1;
            calls(numCalls) = social.vad.my_call(   'session',      session,...
                                                    'startTime',    call_seg_temp{iType}(iCall).beginTime,...
                                                    'stopTime',     call_seg_temp{iType}(iCall).endTime,...
                                                    'channel',      call_seg_temp{iType}(iCall).parChannel,...
                                                    'sig',          call_seg_temp{iType}(iCall).parData{1},...
                                                    'callType',     param.CALL_TYPE{iType}{1}...
                                                    );
%             spec = calls(numCalls).get_spec();
            calls(numCalls).get_fundamental();
        end
    end
end

%
averageLen = zeros(length(param.CALL_TYPE),1);
maxLen = zeros(length(param.CALL_TYPE),1);
count = zeros(length(param.CALL_TYPE),1);
for iType = 1 : length(param.CALL_TYPE)
    currentCallType = param.CALL_TYPE{iType};
    for iCall = 1 : numCalls
        if strcmpi(calls(iCall).eventClass, currentCallType)
            count(iType) = count(iType) + 1;
            fund = calls(iCall).get_fundamental();
            averageLen(iType) = averageLen(iType) + length(fund);  
            if length(fund) > maxLen(iType)
                maxLen(iType) = length(fund);
            end
%             subplot(2,1,1);
%             plot(fund);
%             axis([0,inf,0,25000]);
%             spec = calls(iCall).get_spec();
%             subplot(2,1,2);
%             imagesc(spec(end:-1:1,:));
        end
    end
    averageLen(iType) = averageLen(iType) / count(iType);
end
averageLen = floor(averageLen);

%} 
M = 2;
Q = 6;
callType = param.callTypeOrder;
numType = length(callType);
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\HMM')));
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMtools')));
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMstats')));
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\netlab3.3')));
% training
if param.retrainingHMM == 2
    load(fullfile(param.dataFolder, param.HMMParamFileName));
elseif param.retrainingHMM == 1
    prior           =   cell(1,numType);
    transmat        =   cell(1,numType);
    mu              =   cell(1,numType);
    Sigma           =   cell(1,numType);
    mixmat          =   cell(1,numType);
    prior_front     =   cell(1,numType);
    transmat_front  =   cell(1,numType);
    mu_front        =   cell(1,numType);
    Sigma_front     =   cell(1,numType);
    mixmat_front    =   cell(1,numType);
end
%}

for i = 3 : numType
    iType = callType(i);
    currentCallType = param.CALL_TYPE{iType};
    data = {};
    count1 = 0;
    for iCall = 1 : numCalls
        if strcmpi(calls(iCall).eventClass, currentCallType)
            count1 = count1 + 1;
            fund = calls(iCall).get_fundamental();
            fund = permute(fund,[2,1]);
            data{count1} = fund;
        end
    end

    O = size(data{1},1);
    nex = length(data);
    if param.retrainingHMM == 2
        prior0 = prior{iType};
        transmat0 = transmat{iType};
        mu0 = mu{iType};
        Sigma0 = Sigma{iType};
        mixmat0 = mixmat{iType};
    else
        prior0 = normalise(rand(Q,1));
        transmat0 = mk_stochastic(rand(Q,Q));
        cov_type = 'diag';
        data_temp = [];
        for iCall = 1 : length(data)
            data_temp = [data_temp, data{iCall}];
        end
        [mu0, Sigma0] = mixgauss_init(Q*M, data_temp, cov_type);
        mu0 = reshape(mu0, [O Q M]);
        Sigma0 = reshape(Sigma0, [O O Q M]);
        mixmat0 = mk_stochastic(rand(Q,M));
    end
    [LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
        mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 60);
    prior{iType} = prior1;
    transmat{iType} = transmat1;
    mu{iType} = mu1;
    Sigma{iType} = Sigma1;
    mixmat{iType} = mixmat1;        
end
%}
save(fullfile(param.dataFolder, 'FF_HMMParameter.mat'),'Sigma','prior','transmat','mu','mixmat');
%%
matrix = zeros(numCalls,numCalls);
typeMap = containers.Map({'Phee','Trillphee','Trill','Twitter'},{1,2,3,4});
for iCall = 1 : numCalls
    if ~typeMap.isKey(calls(iCall).eventClass)
        calls(iCall).eventClass
        continue;
    end
    oneCall = calls(iCall).get_fundamental();
    for i = 1 : numType
        iType = callType(i);
        [loglik(iType), ~] = mhmm_logprob(oneCall', prior{iType}, transmat{iType}, mu{iType}, Sigma{iType}, mixmat{iType});
    end
    [~,claRes] = max(loglik);
    matrix(typeMap(calls(iCall).eventClass),claRes) = matrix(typeMap(calls(iCall).eventClass),claRes) + 1;
end
    
    
    