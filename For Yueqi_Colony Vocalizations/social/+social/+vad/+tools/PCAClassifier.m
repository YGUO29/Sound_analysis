dataFolder = 'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\Social\+social\+vad\+data';
callFile = 'callFrame1.mat';
noiseFile = 'noiseFrame1.mat';
load(fullfile(dataFolder,callFile));
load(fullfile(dataFolder,noiseFile));
data = social.vad.tools.prepareVAD(dataFolder, callFile, noiseFile);
data.normalize('minmax');
data.shuffle();
A = data.trainData;
[P, D] = eig(A'*A);
numOfFeature        =   size(D,1);
numOfPCAFeature     =   5;
PCAWeight           =   P(:,numOfFeature - numOfPCAFeature + 1:numOfFeature);

PCAdata             =   social.vad.DataStore();
PCAdata.trainData   =   data.trainData * PCAWeight;
PCAdata.testData    =   data.testData * PCAWeight;
PCAdata.trainLabels =   data.trainLabels;
PCAdata.testLabels  =   data.testLabels;

SVMModel = fitcsvm(data.trainData,data.trainLabels,'Standardize',true,...
        'KernelFunction','RBF','KernelScale','auto');
[label, score] = predict(SVMModel, data.testData);
errorrate = sum(label~=data.testLabels)/length(label)
ScoreSVMModel = fitPosterior(SVMModel, data.trainData, data.trainLabels);
[label, p] = predict(ScoreSVMModel, data.testData);
save(fullfile(dataFolder,'SVMModelPCA.mat'),'SVMModel','ScoreSVMModel');
%%
p = 'D:\Vocalization\M9606';
f = 'voc_9606_c_S282.hdr';
fileName = fullfile(p,f);
session=social.session.StandardSession(fileName);
winSize = 500;
shift   = 50;
frame = {};
channel = 2;
refChannel = 3;
beginTime = 20;
endTime = 30;
parCall = session.Signals(channel).get_signal([beginTime, endTime]);
refCall = session.Signals(refChannel).get_signal([beginTime, endTime]);
Fs      = session.Signals(channel).SampleRate;
[parCallSpe, param_out] = social.util.spectra(parCall{1}, winSize, shift, Fs, 'log', 'gausswin', 0);
[refCallSpe, param_out] = social.util.spectra(refCall{1}, winSize, shift, Fs, 'log', 'gausswin', 0);
oneCallSpe = parCallSpe - refCallSpe;

frameLenP = 100;
frame = social.vad.tools.seg2frame(oneCallSpe, frameLenP, 0.2);

% frame = cell(1,fix((size(oneCallSpe,2)-99)/20));
% for i = 1 : fix((size(oneCallSpe,2)-99)/20)
%     frame{i} = oneCallSpe(:,(i-1)*20+1:(i-1)*20+100);
% end
frame = social.vad.tools.sampling(frame,3,3);
[M,N] = size(frame{i});
L = M * N;
for i = 1 : length(frame)
    frame{i} = reshape(frame{i}, 1, L);
end
trainData = cell2mat(frame);
trainDatan = (trainData - data.dataMin)/(data.dataMax - data.dataMin);
% PCAtrainData = trainDatan * PCAWeight(:,4:5);

[label, score] = predict(SVMModel, trainDatan);
% plot(PCAtrainData(:,1),PCAtrainData(:,2),'.');
%%
x = data.testData * PCAWeight(:,4:5);
hold on
for i = 1 : length(x)
    if data.testLabels(i) == 1
        plot(x(i,1),x(i,2),'.b');
    else
        plot(x(i,1),x(i,2),'.r');
    end
end
plot(PCAtrainData(:,1),PCAtrainData(:,2),'.y');