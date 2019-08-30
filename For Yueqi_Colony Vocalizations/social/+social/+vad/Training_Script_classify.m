%% ----------------load parameters-------------
if exist('subject','var') == 1
    param   =   social.vad.tools.Param(subject);
else
    display('undefined subject');
end
rebuilding  =   param.rebuildingHMM;
retraining  =   param.retrainingHMM;
dataFolder  =   param.dataFolder;

%% HMM training

if (exist(fullfile(dataFolder, param.HMMParamFileName), 'file') == 2) && (retraining == 0)
    display('HMMModel has been saved before, load directly');
    load(fullfile(dataFolder, param.HMMParamFileName));
else
    % ----------------prepare data----------------
    % --------------- begin-----------------------
    if (exist('call_seg','var') == 1) && (rebuilding == 0)
        display('call_seg exists in workspace!');
    elseif (exist(fullfile(dataFolder, ['call_seg',param.HMMParamFileName(9:end)]), 'file') == 2) && (rebuilding == 0)
        display('call_seg has been saved before, load directly!');
        load(fullfile(dataFolder, ['call_seg',param.HMMParamFileName(9:end)]));
    else
        display('start extract call_seg');
        call_seg = [];
        
        if strcmp(param.HMMParamFileName(10:end-4), '9606_93A')
            % from 9606
            xlsxFilename = fullfile(param.soundFilePath,'9606','9606_BehaviorChannels.xlsx');
            [BehChns] = xlsread(xlsxFilename);
            subject = '9606';
            for i = 1 : length(BehChns)
                display(['extract:',num2str(i)]);
                name                =   ['voc_9606_c_S',num2str(BehChns(i,1)),'.hdr'];        
                fileName            =   fullfile(param.soundFilePath,subject,name);
                name                =   ['SelectionTable_voc_9606_c_S',num2str(BehChns(i,1)),'.txt'];
                tableName           =   fullfile(param.selectionTablePath,name);
                nTableName          =   '';
                parChannel          =   BehChns(i,3);
                refChannel          =   BehChns(i,4);
                boxChannel          =   BehChns(i,5);
                sampleProvider      =   social.vad.SampleProvider(fileName, tableName, nTableName, parChannel, refChannel, boxChannel, param);
                call_seg_temp       =   sampleProvider.extractSegs('call', 'parData', 1);
                if isempty(call_seg)
                    call_seg        =   call_seg_temp;
                else
                    for iType = 1 : length(call_seg) 
                        call_seg{iType} = [call_seg{iType},call_seg_temp{iType}];
                    end
                end
            end

            % from M93A
            xlsxFilename = fullfile(param.soundFilePath,'M93A','M93A_BehaviorChannels.xlsx');
            [BehChns] = xlsread(xlsxFilename);
            subject = 'M93A';
            for i = 1 : length(BehChns)
                display(['extract:',num2str(i)]);
                name                =   ['voc_M93A_c_S',num2str(BehChns(i,1)),'.hdr'];
                fileName            =   fullfile(param.soundFilePath,subject,name);
                name                =   ['SelectionTable_voc_M93A_c_S',num2str(BehChns(i,1)),'.txt'];
                tableName           =   fullfile(param.selectionTablePath,name);
                nTableName          =   '';
                parChannel          =   BehChns(i,3);
                refChannel          =   BehChns(i,4);
                boxChannel          =   BehChns(i,5);
                sampleProvider      =   social.vad.SampleProvider(fileName, tableName, nTableName, parChannel, refChannel, boxChannel, param);
                call_seg_temp       =   sampleProvider.extractSegs('call', 'parData', 1);
                if isempty(call_seg)
                    call_seg        =   call_seg_temp;
                else
                    for iType = 1 : length(call_seg)
                        call_seg{iType} = [call_seg{iType},call_seg_temp{iType}];      
                    end
                end
            end
        elseif strcmp(param.HMMParamFileName(10:end-4), 'only4M')
            % from four monkey
            xlsxFilename = fullfile(param.soundFilePath,'M91C_M92C_M64A_M29A','M91C_M92C_M64A_M29A_BehaviorChannels.xlsx');
            [BehChns] = xlsread(xlsxFilename);
            subject = 'M91C_M92C_M64A_M29A';
            for i = 1 : length(BehChns)
                display(['extract:',num2str(i)]);
                name                =   ['voc_M91C_M92C_M64A_M29A_S',num2str(BehChns(i,1)),'.hdr'];
                fileName            =   fullfile(param.soundFilePath,subject,name);
                name                =   ['SelectionTable_voc_M91C_M92C_M64A_M29A_S',num2str(BehChns(i,1)),'.txt'];
                tableName           =   fullfile(param.selectionTablePath,name);
                nTableName          =   '';
                parChannel          =   BehChns(i,3);
                refChannel          =   BehChns(i,4);
                boxChannel          =   BehChns(i,5);
                sampleProvider      =   social.vad.SampleProvider(fileName, tableName, nTableName, parChannel, refChannel, boxChannel, param);
                call_seg_temp       =   sampleProvider.extractSegs('call', 'parData', 1);
                if isempty(call_seg)
                    call_seg        =   call_seg_temp;
                else
                    for iType = 1 : length(call_seg)
                        call_seg{iType} = [call_seg{iType},call_seg_temp{iType}];      
                    end
                end
            end
        else
            display('unrecognized HMMParamFileName');
        end


        % shuffle
        resample = 2000;
        for i = 1 : length(call_seg)
            if isempty(call_seg{i})
                continue;
            end
            call_seg{i} = call_seg{i}(randperm(length(call_seg{i})));
            if length(call_seg{i}) > resample
                call_seg{i} = call_seg{i}(1:resample);
            end            
            while length(call_seg{i}) < resample 
                call_seg{i} = [call_seg{i}, call_seg{i}];
                if length(call_seg{i}) > resample
                    call_seg{i} = call_seg{i}(1:resample);
                end
            end
            call_seg{i} = call_seg{i}(randperm(length(call_seg{i})));
        end
        
        save(fullfile(param.dataFolder,['call_seg',param.HMMParamFileName(9:end)]),'call_seg');
    end    
    % ------------------end----------------------
    
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\HMM')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMtools')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMstats')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\netlab3.3')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'voicebox')));
    callType = param.callTypeOrder;
    numType = length(callType);
    % calculate mfcc
    for iType = 1 : numType
        callTypeNum = callType(iType);
        data = {};
        vector = {};
        Fs = param.Fs;
        for i = 1 : round(param.trainDataSize_HMM * length(call_seg{callTypeNum}))
            data{i} = call_seg{callTypeNum}(i).parData{1};
        end
        lenOfFrame = floor(param.Fs * param.frameLenT_HMM); 
        lenOfStep = floor(lenOfFrame * param.frameShiftT_HMM);
        N = length(data);
        h = hamming(lenOfFrame);
%         bank=melbankm(24,lenOfFrame,Fs,0,0.5,'t');
%         bank=full(bank);
%         bank=bank/max(bank(:));
        bank = social.vad.tools.my_melbank();
        for k=1:12
            n=0:23;
            dctcoef(k,:)=cos((2*n+1)*k*pi/(2*24));
        end
        height = 0.98;
        for i = 1:N
            lenOfData = length(data{i});
            numOfFrame = floor((lenOfData-lenOfFrame+lenOfStep)/lenOfStep);
            m = zeros(numOfFrame,12);
            aLine1 = data{i};
            aLine = awgn(aLine1,70,'measured');
            for j = 2 : lenOfData
                aLine(j) = aLine(j) - height*aLine(j-1);
            end
            for j = 1 : numOfFrame
                data_r = aLine((j-1)*lenOfStep+1:(j-1)*lenOfStep + lenOfFrame);
                data_h = data_r.*h;
                data_fft = fft(data_h);
                data_p = abs(data_fft).^2;
                mfcc = dctcoef*log(bank*data_p(1:ceil(lenOfFrame/2)+1));
                m(j,:) = mfcc;
            end
            [yy,zz] = size(m);
            dtm=zeros(yy,zz);
            for j=3:yy-2
                dtm(j,:)=-2*m(j-2,:)-m(j-1,:)+m(j+1,:)+2*m(j+2,:);
            end
            dtm=dtm/3;
            dtmm=zeros(yy,zz);
            for j=3:yy-2
                dtmm(j,:)=-2*dtm(j-2,:)-dtm(j-1,:)+dtm(j+1,:)+2*dtm(j+2,:);
            end
            dtmm=dtmm/3;
            vector{i} = [m';dtm'];
        end
        call_seg_mfcc{iType} = vector;
    end
    
    M = 4;
    Q = 8;
    left_right = 0 ;
    
    % training
    if (param.retrainingHMM == 2)
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
    
    for iType = 1 : length(param.callTypeOrder)
%     for iType = 1 : 1
        callTypeNum = callType(iType);
        data = call_seg_mfcc{iType};
        nex = length(data);
        O = size(data{1},1);
        if (param.retrainingHMM == 2) && (~isempty(prior{iType}))
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
            mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', param.iteration_HMM);
        prior{iType} = prior1;
        transmat{iType} = transmat1;
        mu{iType} = mu1;
        Sigma{iType} = Sigma1;
        mixmat{iType} = mixmat1;
        
        if (callType(iType) > 3) && (callType(iType) < 6)
%             data = permute(call_seg_mfcc{iType},[3,2,1]);
%             data = data(:,1:param.frontTruncLen_HMM,:);
%             [O,T,nex] = size(data);

            data = call_seg_mfcc{iType};
            nex = length(data);
            for iCall = 1 : nex
                data{iCall} = data{iCall}(:,1:min(size(data{iCall},2),param.frontTruncLen_HMM));
            end
            if (param.retrainingHMM == 2) && (~isempty(prior_front{iType}))
                prior0 = prior_front{iType};
                transmat0 = transmat_front{iType};
                mu0 = mu_front{iType};
                Sigma0 = Sigma_front{iType};
                mixmat0 = mixmat_front{iType};
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
                mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', param.iteration_HMM);
            prior_front{iType} = prior1;
            transmat_front{iType} = transmat1;
            mu_front{iType} = mu1;
            Sigma_front{iType} = Sigma1;
            mixmat_front{iType} = mixmat1;
        end
    end
    save(fullfile(param.dataFolder, param.HMMParamFileName),'Sigma','prior','transmat','mu','mixmat',...
                                                            'Sigma_front','prior_front','transmat_front','mu_front','mixmat_front');
end      

%% test
orders = param.callTypeOrder;
numType = length(orders);
for io = 1 : numType
    order = orders(io);
    n = length(call_seg{order});
    m = round(param.trainDataSize_HMM * n);
    label = zeros(n-m,1);
    for i = 1 : n-m
        [~, label(i), loglikunit(i,:), ~] = social.vad.tools.callTypeClassification(call_seg{order}(i+m).parData{1}, param);
    end
    count = zeros(1,numType);
    for i = 1 : n-m
        if label(i) ~= 0
            count(label(i)) = count(label(i)) + 1;
        end
    end
    matrix(io,:) = count / (n - m);
end
