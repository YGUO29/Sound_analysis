
clear all
clc
%%
work_style = 'append';
% work_style = 'create_new';
param               =   social.vad.tools.Param();
rebuilding          =   param.rebuildingCNN;
retraining          =   param.retrainingCNN;
CALL_TYPE           =   param.CALL_TYPE;
dataFolder          =   param.dataFolder;
fs                  =   param.Fs;

% get the suffix of the training data file
subject             =   param.subjectTrain;
subject             =   '9606';
% subject             =   'M91C_M92C_M64A_M29A';
% subject             =   'M93A';
version             =   param.version;
suffix              =   [subject,'_',num2str(version)];
specBoxFileName     =   ['specBox',suffix,'.mat'];
%% -----------make hdf5 file

% filename            =   fullfile(param.dataFolder,'deepMonkey224_M93A_train_new.hdf5');
filename            =   fullfile(param.dataFolder, 'deepMonkey224_M93A_test_new.hdf5');
if (exist(filename, 'file') == 2) && strcmp(work_style, 'create_new')
    delete(filename)
end
datasetbox          =   '/monkeyData';
height              =   224;
width               =   224;
batchSize           =   param.batchSize;
numOfChannel        =   param.numOfChannel;

sizeData            =   [height, width, numOfChannel, Inf];
Datatype            =   'double';
ChunkSize           =   [height, width, numOfChannel, batchSize];

if strcmp(work_style, 'create_new')
    h5create(           filename,...
                        datasetbox,...
                        sizeData,...
                        'Datatype',             Datatype,...
                        'ChunkSize',            ChunkSize);
end


datasetlabel        =   '/monkeyLabel';
sizeData            =   Inf;
Datatype            =   'int8';
ChunkSize           = 	batchSize;

if strcmp(work_style, 'create_new')
    h5create(           filename,...
                        datasetlabel,...
                        sizeData,...
                        'Datatype',             Datatype,...
                        'ChunkSize',            ChunkSize);
end
%% -----------prepare spectra Box--------------
p                   =   fullfile(param.soundFilePath,subject);
pt                  =   param.selectionTablePath;
xlsxFilename        =   fullfile(p,[subject, '_BehaviorChannels.xlsx']);
[BehChns]           =   xlsread(xlsxFilename);
Nf                  =   length(BehChns);
Nf                  =   ceil(Nf * 0.8);
if (exist('specBox','var') == 1) && (rebuilding == 0)
    display('spectra Box has already exist in workspace!');
elseif (exist(fullfile(dataFolder,specBoxFileName),'file') == 2) && (rebuilding == 0)
    display('spectra box has been saved before, load directly');
    load(fullfile(dataFolder, specBoxFileName));
else
    display('start extract spectra boxes');
    specBox = {};
    counters = zeros(10,1);
%     for i = 1 : Nf
    for i = Nf + 1 : length(BehChns)
        display(i);
        if strcmp(subject, 'M91C_M92C_M64A_M29A')
            f       =   ['voc_',subject,'_S',num2str(BehChns(i,1)),'.hdr'];
            ft      =   ['SelectionTable_voc_',subject,'_S',num2str(BehChns(i,1)),'.txt'];
            
        elseif strcmp(subject, '9606')
            f       =   ['voc_',subject,'_c_S',num2str(BehChns(i,1)),'.hdr'];
            ft      =   ['SelectionTable_voc_',subject,'_c_S',num2str(BehChns(i,1)),'.txt'];
        elseif strcmp(subject, 'M93A')
            f       =   ['voc_',subject,'_c_S',num2str(BehChns(i,1)),'.hdr'];
            ft      =   ['SelectionTable_voc_',subject,'_c_S',num2str(BehChns(i,1)),'.txt'];
        else
            display('wrong subject name');
        end
        fileName    =   fullfile(p,f);
        tableName   =   fullfile(pt,ft);
        nTableName  =   '';
        sampleProvider   = social.vad.SampleProvider(fileName, tableName, nTableName, BehChns(i,3), BehChns(i,4), BehChns(i,5), param);
        [boxes, counter] =   sampleProvider.extractCNNSpecBox();
        if length(boxes) <= 1
            continue
        end
        display('counter: ')
        display(counter')
        counters = counters + counter;
        boxes       =   boxes(randperm(length(boxes)));
        hdf5Info    =   h5info(filename);
        startSample =   hdf5Info.Datasets(1).Dataspace.Size(4) + 1;
        count       =   [height, width, 1, length(boxes)];
        parData     =   zeros(height, width, 1, length(boxes));
        refData     =   zeros(height, width, 1, length(boxes));
        subData     =   zeros(height, width, 1, length(boxes));
        for j = 1 : length(boxes)
            parData(:,:,:,j) = imresize(social.vad.CNN.minmax(boxes(j).par, 0, 1), [height, width]);
            refData(:,:,:,j) = imresize(social.vad.CNN.minmax(boxes(j).ref, 0, 1), [height, width]);
            subData(:,:,:,j) = social.vad.CNN.minmax(parData(:,:,:,j) - refData(:,:,:,j), 0, 1);
            if boxes(j).label == 8
                imagesc(boxes(j).par)
            end
        end
        % write channel one
        start = [1,1,1,startSample];
        h5write(filename, datasetbox, parData, start, count);
        % write channel two
        start = [1,1,2,startSample];
        h5write(filename, datasetbox, refData, start, count);
        % write channel three
        start = [1,1,3,startSample];
        h5write(filename, datasetbox, subData, start, count);
        % write label
        h5write(filename, datasetlabel, [boxes.label], startSample, length(boxes));     
    end
    counters
end
%}

