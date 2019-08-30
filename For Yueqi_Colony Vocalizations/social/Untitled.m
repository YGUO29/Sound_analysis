param = social.vad.tools.Param();
rebuilding = param.rebuildingHMM;
retraining = param.retrainingHMM;
dataFolder = param.dataFolder;

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
    param.parChannel    =   BehChns(i,3);
    param.refChannel    =   BehChns(i,4);
    sampleProvider      =   social.vad.SampleProvider(fileName, tableName, nTableName, param);
    call_seg_temp       =   sampleProvider.extractSegs('call', 'parData', 1, 'refData', 1);
    
    for j = 1 : length(call_seg_temp)
        for k = 1 : length(call_seg_temp{j})
            parCall = call_seg_temp{j}(k).parData{1};
            refCall = call_seg_temp{j}(k).refData{1};
            [parCallSpe, ~, ~]      =   social.vad.tools.spectra(   parCall,...
                                                                    param.specWinSize,...
                                                                    param.specShift,...
                                                                    Fs,...
                                                                    0 ...
                                                                );

            [refCallSpe, ~, ~]      =   social.vad.tools.spectra(   refCall,...
                                                                    param.specWinSize,...
                                                                    param.specShift,...
                                                                    Fs,...
                                                                    0 ...
                                                                );    
    if isempty(call_seg)
        call_seg        =   call_seg_temp;
    else
        for iType = 1 : length(call_seg)
            call_seg{iType} = [call_seg{iType},call_seg_temp{iType}];      
        end
    end
end

