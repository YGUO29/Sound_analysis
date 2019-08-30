%% define some parameters and constants
param               =   social.vad.tools.Param();
rebuilding          =   param.rebuildingVAD;         % if rebuild train data
retraining          =   param.retrainingVAD;         % if retrain classifer
CALL_TYPE           =   param.CALL_TYPE;
NOISE_TYPE          =   param.NOISE_TYPE;
dataFolder          =   param.dataFolder;
numOfPCAFeature     =   param.numOfPCAFeature;
Fs                  =   param.Fs;
prefix              =   param.prefixTrain;
subject             =   param.subjectTrain;
version             =   param.version;
SVMName             =   [subject,'_',num2str(version)];

callFrameFileName   =   ['callFrame',SVMName,'.mat'];
noiseFrameFileName  =   ['noiseFrame',SVMName,'.mat'];

%% train
if (exist(fullfile(dataFolder,['SVMModelPCA',SVMName,'.mat']),'file') == 2)&&(retraining == 0)
    display('SVMModel has been saved before, load directly');
    load(fullfile(dataFolder,['SVMModelPCA',SVMName,'.mat']))
else
    display('start training');
    
    % prepare training data
    % -------------begin-----------------
    display('start prepare training data');

    if (exist('callFrame','var') == 1)&&(rebuilding == 0)
        display('callFrame and noiseFrame exist in workspace!');
    elseif (exist(fullfile(dataFolder,callFrameFileName),'file') == 2)&&(rebuilding == 0)
        display('callFrame and noiseFrame have been saved before, load directly');
        load(fullfile(dataFolder,callFrameFileName));
        load(fullfile(dataFolder,noiseFrameFileName));
    else
        display('start extract calls');
        callFrame   = {};
        noiseFrame  = {};
        xlsxFilename = fullfile(param.soundFilePath,subject,[subject,'_BehaviorChannels.xlsx']);
        [BehChns] = xlsread(xlsxFilename);
        Nf = length(BehChns);       
        for i = 1 : Nf
            sessionNum = ['S',num2str(BehChns(i,1))];
            if sum(ismember(param.sessionNumsTrain, sessionNum))
                name            =   [prefix,'_',subject,'_',sessionNum,'.hdr'];
                fileName        =   fullfile(param.soundFilePath,subject,name);
                name            =   ['SelectionTable_',prefix,'_',subject,'_',sessionNum,'.txt'];
                tableName       =   fullfile(param.selectionTablePath,name);
                name            =   ['SelectionTable_',prefix,'_',subject,'_',sessionNum,'_noise','.txt'];
                nTableName      =   fullfile(param.selectionTablePath,name);
                parChannel      =   BehChns(i,3);
                refChannel      =   BehChns(i,4);
                boxChannel      =   BehChns(i,5);
                sampleProvider  =   social.vad.SampleProvider(fileName, tableName, nTableName, parChannel, refChannel, boxChannel, param);

                call_seg        =   sampleProvider.extractSegs('call', 'parData', 1);
                noise_seg       =   sampleProvider.extractSegs('noise');
                callFrame_temp  =   sampleProvider.seg2fram(call_seg);
                noiseFrame_temp =   sampleProvider.seg2fram(noise_seg);
                if i == 1
                    callFrame = callFrame_temp;
                    noiseFrame = noiseFrame_temp;
                else
                    for icallType   =   1 : length(callFrame_temp)
                        callFrame{icallType}    =   [callFrame{icallType};     callFrame_temp{icallType}];
                    end
                    for inoiseType  =   1 : length(noiseFrame_temp)
                        noiseFrame{inoiseType}   =   [noiseFrame{inoiseType};     noiseFrame_temp{inoiseType}];
                    end
                end
            end
        end   
        for i = 1 : 9
            if length(callFrame{i}) > 5000
                ind = randperm(length(callFrame{i}));
                ind = ind(1:5000);
                callFrame{i} = callFrame{i}(ind);
            end
        end
        for i = 1 : 2
            if length(noiseFrame{i}) > 30000
                ind = randperm(length(noiseFrame{i}));
                ind = ind(1:20000);
                noiseFrame{i} = noiseFrame{i}(ind);
            end 
        end   
        save(fullfile(dataFolder,callFrameFileName),'callFrame');
        save(fullfile(dataFolder,noiseFrameFileName),'noiseFrame');
    end
    % ----------end--------------

    callFrame_temp = {};
    for i = 1 : 9
        callFrame_temp = cat(1,callFrame_temp,callFrame{i});
    end
    callFrame = callFrame_temp;
    
    noiseFrame_temp = {};
    for i = 1 : 2
        noiseFrame_temp = cat(1,noiseFrame_temp,noiseFrame{i});
    end
    noiseFrame = noiseFrame_temp;
    
    callFrame = callFrame(randperm(length(callFrame)));
    noiseFrame = noiseFrame(randperm(length(noiseFrame)));
    callFrame = callFrame(1:20000);
    noiseFrame = noiseFrame(1:20000);
    
    
    data = social.vad.DataStore();
    trainTestRatio = 0.7;
    data.prepareVAD(callFrame, noiseFrame, trainTestRatio);
    data.normalize('minmax');
    dataMin = data.dataMin;
    dataMax = data.dataMax;
    save(fullfile(dataFolder,['normPara',SVMName,'.mat']),'dataMin','dataMax');
    data.shuffle();
    
    % pca
    A = data.trainData;
    [P, D] = eig(A'*A);
    numOfFeature        =   size(D,1);
    PCAWeight           =   P(:,numOfFeature - numOfPCAFeature + 1:numOfFeature);

    PCAdata             =   social.vad.DataStore();
    PCAdata.trainData   =   data.trainData * PCAWeight;
    PCAdata.testData    =   data.testData * PCAWeight;
    PCAdata.trainLabels =   data.trainLabels;
    PCAdata.testLabels  =   data.testLabels;
    
%     % test pca
    x = PCAdata.testData;
    l = PCAdata.testLabels;
%     x = PCAdata.trainData;
%     l = PCAdata.trainLabels;
    figure,hold on
    for i = 1 : length(x)
        if l(i) == 1
            plot(x(i,99),x(i,100),'.b');
        else
            plot(x(i,99),x(i,100),'.r');
        end
    end

    % pca version
    SVMModel = fitcsvm( PCAdata.trainData,      PCAdata.trainLabels,...
                        'Standardize',          true,...
                        'KernelFunction',       'RBF',...
                        'KernelScale',          'auto',...
                        'Cost',                 param.SVMCost);
    [label, score] = predict(SVMModel, PCAdata.testData);
    errorrate1 = sum(label~=PCAdata.testLabels)/length(label)
    ScoreSVMModel = fitPosterior(SVMModel, PCAdata.trainData, PCAdata.trainLabels); 
    save(fullfile(dataFolder,['SVMModelPCA',SVMName,'.mat']),'SVMModel','PCAWeight');    
end
%}

%% test the accuarcy of each call type
load(fullfile(dataFolder,['SVMModelPCA',SVMName,'.mat']))
load(fullfile(dataFolder,['normPara',SVMName,'.mat']));
for callType = 1:9
    if ~isempty(callFrame{callType})
        PCAdata                 =   social.vad.DataStore();
        PCAdata.prepareVAD(callFrame{callType}, {}, 0);
        PCAdata.dataMin         =   dataMin;
        PCAdata.dataMax         =   dataMax;
        PCAdata.normilizeMethod =   'minmax';
        PCAdata.testData        =   PCAdata.normalizeNewData(PCAdata.testData);
        PCAdata.testData        =   PCAdata.testData * PCAWeight;
        [label, score]          =   predict(SVMModel, PCAdata.testData);
        error(callType)         =   sum(label~=PCAdata.testLabels)/length(label);
    else 
        error(callType)         =   0;
    end
end
PCAdata                 =   social.vad.DataStore();
PCAdata.prepareVAD({}, noiseFrame{1}, 0);
PCAdata.dataMin         =   dataMin;
PCAdata.dataMax         =   dataMax;
PCAdata.normilizeMethod =   'minmax';
PCAdata.testData        =   PCAdata.normalizeNewData(PCAdata.testData);
PCAdata.testData        =   PCAdata.testData * PCAWeight;
[label, score]          =   predict(SVMModel, PCAdata.testData);
error_noise             =   sum(label~=PCAdata.testLabels)/length(label);
%}