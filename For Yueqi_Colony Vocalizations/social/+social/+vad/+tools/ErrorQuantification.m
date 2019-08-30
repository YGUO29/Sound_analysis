display('Doing Error Quantification');
param = social.vad.tools.Param();

prefix      =   'voc';
subject     =   'M91C_M92C_M64A_M29A';
% subject     =   '9606';
% sessionNums = {'S189', 'S193', 'S194', 'S198', 'S200', 'S201', 'S203', 'S204', 'S205', 'S207', 'S208', 'S210', 'S211', 'S213'};
% sessionNums = {'S141', 'S142', 'S143', 'S145', 'S147', 'S151', 'S152', 'S154', 'S156', 'S161', 'S162', 'S164', 'S165', 'S169', 'S171', 'S173'};
% sessionNums = {'S141', 'S142', 'S143', 'S145', 'S147', 'S152', 'S156'};
% sessionNums = {'S189', 'S190', 'S193', 'S194'};
% sessionNums = {'c_S197','c_S221','c_S222'};
sessionNums = {'S142', 'S143'};
calls = cell(1,9);
len_sessionNums = length(sessionNums);
len_sessionNums = 2;

hitCount = 0;
GTCount = 0;
falsealarmCount = 0;
ADCount = 0;
for i = 1 : len_sessionNums
    sessionNum = sessionNums{i};
    sessionName = [prefix,'_',subject,'_',sessionNum];
    groundTruthFilename = fullfile(param.selectionTablePath,['SelectionTable_',sessionName,'.txt']);
    autoDetectionFilename = fullfile(param.selectionTablePathOut,['SelectionTable_',sessionName,'.txt']);
%     h_log = fopen(fullfile(param.detectionLogPath,[sessionName,'_',datestr(now,30),'.log']),'w');

%     parChannels = [1];
%     refChannels = [2];
%     boxChannels = [1];
    % condition 3,4,5
%     parChannels = [1,2,3,4];
%     refChannels = [2,3,4,1];
%     boxChannels = [1,2,3,4];
    % condition 6
%     parChannels = [1,2,3,3];
%     refChannels = [4,4,4,4];
%     boxChannels = [1,2,5,6];
%     parChannels = [1,2];
%     refChannels = [4,4];
%     boxChannels = [1,2];
    parChannels = [3,3];
    refChannels = [4,4];
    boxChannels = [5,6];
    % condition 7
%     parChannels = [1,1];
%     refChannels = [2,2];
%     boxChannels = [4,5];


    A = zeros(9,2);
    for ii = 1 : length(parChannels)
%     for i = 1 : 2
        parChannel = parChannels(ii);
        refChannel = refChannels(ii);
        boxChannel = boxChannels(ii);

        sampleProviderGT = social.vad.SampleProvider('', groundTruthFilename, '', parChannel, refChannel, boxChannel, param);
        sampleProviderAD = social.vad.SampleProvider('', autoDetectionFilename, '', parChannel, refChannel, boxChannel, param);
        callsGT = sampleProviderGT.extractSegs('call');
        callsAD = sampleProviderAD.extractSegs('call', 'energyPar', 1, 'energyDiff', 1, 'energyParWireless', 1, 'energyDiffWireless', 1, 'AHR', 1);
%         callsAD = sampleProviderAD.extractSegs('call');
        maxTime = 0;
        CALL_TYPE = cat(1,param.CALL_TYPE,{{'otherTypes'}});
        log_file = cell(1,length(callsGT));
        for iType = 1 : length(callsGT)
            log_file{iType}.callType = CALL_TYPE{iType}{1};
            log_file{iType}.numOfCallsGT = length(callsGT{iType});
            GTCount = GTCount + length(callsGT{iType});
            log_file{iType}.numOfCallsAD = length(callsAD{iType});
            ADCount = ADCount + length(callsAD{iType});
            log_file{iType}.numOfCallsOL_GT = 0;
            log_file{iType}.numOfCallsOL_AD = 0;
            for iCall = 1 : length(callsGT{iType})
                if callsGT{iType}(iCall).endTime > maxTime
                    maxTime = callsGT{iType}(iCall).endTime;
                end
            end
            for iCall = 1 : length(callsAD{iType})
                if callsAD{iType}(iCall).endTime > maxTime
                    maxTime = callsAD{iType}(iCall).endTime;
                end
            end
        end

        timeRes = param.timeResEQ;
        numOfInd = ceil(maxTime/timeRes);
        flag = zeros(numOfInd,1);
        flag1 = zeros(numOfInd,1);
        totalCallNumAD = 0;
        totalCallNumGT = 0;
        classificationMatrix = zeros(length(callsAD));
        for iType = 1 : length(callsAD)
            totalCallNumAD = totalCallNumAD + length(callsAD{iType});
            for iCall = 1 : length(callsAD{iType})
                startP = ceil(callsAD{iType}(iCall).beginTime/timeRes);
                startP = max(1,startP);
                stopP  = ceil(callsAD{iType}(iCall).endTime/timeRes);
                flag(startP:stopP) = iType;
            end
        end

        for iType = 1 : length(callsGT)
            totalCallNumGT = totalCallNumGT + length(callsGT{iType});
            for iCall = 1 : length(callsGT{iType})
                startP = ceil(callsGT{iType}(iCall).beginTime/timeRes);
                startP = max(1,startP);
                stopP = ceil(callsGT{iType}(iCall).endTime/timeRes);
                flag1(startP:stopP) = iType;
            end
        end

        % hitting
        for iType = 1 : length(callsGT)
            for iCall = 1 : length(callsGT{iType})
                startP = ceil(callsGT{iType}(iCall).beginTime/timeRes);
                startP = max(1,startP);
                stopP = ceil(callsGT{iType}(iCall).endTime/timeRes);
                if sum(flag(startP:stopP)~=0)/(stopP-startP+1) > param.overlapThresholdEQ
                    GT_Type = iType;
                    result = tabulate(flag(startP:stopP));
                    [~, AD_Type] = max(result(:,2));
                    AD_Type = (result(AD_Type,1));
                    if AD_Type == 0
                        continue;
                    end
                    classificationMatrix(GT_Type, AD_Type) = classificationMatrix(GT_Type, AD_Type) + 1;
                    log_file{iType}.numOfCallsOL_GT = log_file{iType}.numOfCallsOL_GT + 1;
                    hitCount = hitCount + 1;
                end
            end
        end

        for iType = 1 : length(callsGT)
            A(iType,1) = log_file{iType}.numOfCallsOL_GT + A(iType,1);
            A(iType,2) = A(iType,2) + log_file{iType}.numOfCallsGT;
        end

        % false alarm
        for iType = 1 : length(callsAD)
            for iCall = 1 : length(callsAD{iType})
                startP = ceil(callsAD{iType}(iCall).beginTime/timeRes);
                startP = max(1,startP);
                stopP = ceil(callsAD{iType}(iCall).endTime/timeRes);
                if sum(flag1(startP:stopP)~=0)/(stopP-startP+1) > param.overlapThresholdEQ
                    log_file{iType}.numOfCallsOL_AD = log_file{iType}.numOfCallsOL_AD + 1;
                    callsAD{iType}(iCall).flag = 1;
                else
                    callsAD{iType}(iCall).flag = 0;
                    falsealarmCount = falsealarmCount + 1;
                end
            end
        end
        for iType = 1 : length(callsAD)
            if isempty(calls{iType})
                calls{iType} = callsAD{iType};
            else
                calls{iType} = [calls{iType}, callsAD{iType}];
            end
        end
    %     % calculate the distribution of AHR of different callTypes
%         dist = cell(10,1);
%         for ii = 1 : 10
%             dist{ii} = [];
%         end
%         for iType = 1 : length(callsAD)
%             for iCall = 1 : length(callsAD{iType})
%                 startP = ceil(callsAD{iType}(iCall).beginTime/timeRes);
%                 startP = max(1, startP);
%                 stopP = ceil(callsAD{iType}(iCall).endTime / timeRes);
%                 result = tabulate(flag1(startP:stopP));
%                 [~, GT_Type] = max(result(:,2));
%                 GT_Type = (result(GT_Type,1));
%                 if GT_Type == 0
%                     GT_Type = 10;
%                 end
%                 dist{GT_Type} = [dist{GT_Type}, callsAD{iType}(iCall).exception];
%             end
%         end
%         call_dist = [];
%         for iType = 1 : length(callsAD)
%             call_dist = [call_dist, dist{iType}];
%         end
%         noise_dist = dist{10};
%         close all
%     %     hold on
%     %     for ii = 1 : length(call_dist)
%     %         plot(call_dist(ii),0,'*r');
%     %     end
%     %     for ii = 1 : length(noise_dist)
%     %         plot(noise_dist(ii),0,'.b');
%     %     end
%         [f, xi] = ksdensity(call_dist);
%         plot(xi, f*length(call_dist),'r');
%         [f, xi] = ksdensity(noise_dist);
%         hold on, plot(xi, f*length(noise_dist),'b');

      
%         % output to log file
%         fprintf(h_log,'behavior %i\n',i);
%         fprintf(h_log,'    parabolic mic: #%i, reference mic: #%i\n',parChannels(i),refChannels(i));
%         fprintf(h_log,'    Total_call_numbers in Ground Truth: %i\n',totalCallNumGT);
%         fprintf(h_log,'    Total_call_numbers in program detection: %i\n',totalCallNumAD);

        % output to command window
        display(['behavior ',num2str(ii)]);
        display(['parabolic mic: #',num2str(parChannels(ii)),'; reference mic: #',num2str(refChannels(ii))]);
        display(['    Total_call_numbers in Ground Truth: ',num2str(totalCallNumGT),'\n']);
        display(['    Total_call_numbers in program detection: ',num2str(totalCallNumAD), '\n']);
% 
        for iType = 1 : length(callsGT)
%             fprintf(h_log,['    ',log{iType}.callType,': ',num2str(log{iType}.numOfCallsOL_GT),' of ',num2str(log{iType}.numOfCallsGT),' was detected\n']);
            display(['    ',log_file{iType}.callType,': ',num2str(log_file{iType}.numOfCallsOL_GT),' of ',num2str(log_file{iType}.numOfCallsGT),' was detected']);
        end
% 
%         fprintf(h_log, 'classificationMatrix: \n');
%         for j = 1 : length(classificationMatrix)
%             for k = 1 : length(classificationMatrix)
%                 fprintf(h_log, '\t%i', classificationMatrix(j,k));
%             end
%             fprintf(h_log,'\n');
%         end
%         fprintf(h_log,'\n');
        classificationMatrix
    end
%     fclose(h_log);
end
hitting = hitCount / GTCount
falsealarm = falsealarmCount / ADCount