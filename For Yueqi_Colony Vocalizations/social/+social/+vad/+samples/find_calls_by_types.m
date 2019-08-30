subject = 'M93A';
param = social.vad.tools.Param(subject);
dataFolder = param.dataFolder;
calls = [];
dataFile = fullfile(dataFolder, 'data_M93A.mat');
xlsxFilename = fullfile(param.soundFilePath, 'M93A', 'M93A_BehaviorChannels.xlsx');
[BehChns] = xlsread(xlsxFilename);
call_count = 0;
CALL_TYPE = cat(1, param.CALL_TYPE, {{'otherTypes'}});
CALL_TYPE = cat(1, CALL_TYPE, {{'Noise'}});
% for i = 1 : length(BehChns)
for i = 8 : 11
    display(['extract:', num2str(i)]);
    sessionName     =   ['voc_M93A_c_S', num2str(BehChns(i,1))];
    filename        =   fullfile(param.soundFilePath, subject, [sessionName, '.hdr']);
    tableName       =   fullfile(param.selectionTablePath, ['SelectionTable_', sessionName, '.txt']);
    nTableName      =   fullfile(param.selectionTablePath, ['SelectionTable_', sessionName, '_noise.txt']);
    parChannel      =   BehChns(i, 3);
    refChannel      =   BehChns(i, 4);
    boxChannel      =   BehChns(i, 5);
    sampleProvider 	= 	social.vad.SampleProvider(filename, tableName, nTableName, parChannel, refChannel, boxChannel, param);
    call_seg_temp 	=	sampleProvider.extractSegs('call', 'parData', 1);
    noise_seg_temp  =   sampleProvider.extractSegs('noise', 'parData', 1);
%     for iType = 1 : length(call_seg_temp)
%         display([CALL_TYPE{iType,1},': ',num2str(length(call_seg_temp{iType})), ' was detected']);
%     end
%     display([CALL_TYPE{end,1}, ': ', num2str(length(noise_seg_temp{1})), ' was detected']);
    if isempty(calls)
        calls           =   call_seg_temp;
        calls{end + 1}  =   noise_seg_temp{1};
    else
        for iType = 1 : length(calls) - 1
            calls{iType}= [calls{iType}, call_seg_temp{iType}];
        end
        calls{end}  = [calls{end}, noise_seg_temp{1}];
    end
end
for iType = 1 : length(calls)
    display([CALL_TYPE{iType,1},': ',num2str(length(calls{iType})), ' was detected']);
end

    
    
    