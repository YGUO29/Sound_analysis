% Directional Detecting with a parabolic mic and a reference mic
% This function work on a pair of channels only

function detectedCalls = call_detect_multiChannels( BehChannel )
    param                       =   BehChannel.param;
    suffix                      =   [param.subjectTrain,'_',num2str(param.version)];
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\HMM')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMtools')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMstats')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\netlab3.3')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'voicebox')));
    band                        =   param.vocBandP;
    Fs                          =   param.Fs;
    
    % calculate gains of each channel
    BehChannel.SigDetect.calculate_gain(param);
    BehChannel.SigRef.calculate_gain(param);
    parGain                     =   BehChannel.SigDetect.gain_spec;
    refGain                     =   BehChannel.SigRef.gain_spec;
    if strcmp(BehChannel.BehName, 'MultiRef')
        for iChn = 1 : length(BehChannel.SigOth)
            BehChannel.SigOth{iChn}.calculate_gain(param)
        end
    end
    
    if strcmp(BehChannel.BehName, 'Wireless')
        for iChn = 1 : length(BehChannel.SigWireless)
            BehChannel.SigWireless{iChn}.calculate_gain(param);
        end
    end
    
    
    if (Fs ~= BehChannel.SigDetect.SampleRate) error('wrong Fs');end    
    chunklen                    =   param.chunklen; % in sec
    chunksize                   =   chunklen * Fs;
    samplesize                  =   BehChannel.SigDetect.TotalSamples;
    chunkOverlap                =   param.chunkOverlap; % in sec
    Nfor                        =   ceil((samplesize - chunksize)/((chunklen-chunkOverlap)*Fs)) + 1;
%     Nfor = 11;
    load(fullfile(param.dataFolder,['SVMModelPCA',suffix,'.mat']));
    load(fullfile(param.dataFolder,['normPara',suffix,'.mat']));
    if param.parforSwitch == 1
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            poolobj = parpool('local',param.numParWorkers);
        end
        dataMin_parfor              =   dataMin;
        dataMax_parfor              =   dataMax;
        SVMModel_parfor             =   SVMModel;
        PCAWeight_parfor            =   PCAWeight;
        tStart                      =   [];
        tStop                       =   [];
        energyDiffArr               =   [];
        energyDiffWirelessArr       =   [];
        exceptionArr                =   [];
        energyParArr                =   [];
        energyParWirelessArr        =   [];
        AHRArr                      =   [];
        callTypeArr                 =   [];
        channelArr                  =   [];
        frame                       =   [];
        
        
        parfor ci = 1 : Nfor
            N1 = (ci - 1)*(chunklen-chunkOverlap)*Fs + 1;
            N2 = N1 + chunksize - 1;
            if N2 > samplesize
                N2 = samplesize;
            end
            parCall                 =   BehChannel.SigDetect.get_signal([N1/Fs N2/Fs]);
            refCall                 =   BehChannel.SigRef.get_signal([N1/Fs N2/Fs]);
            parCall                 =   parCall{1};
            refCall                 =   refCall{1};
            if strcmp(BehChannel.BehName, 'MultiRef')
                othCall             =   {};
                othCallSpeAll       =   {};
                for iChn = 1 : length(BehChannel.SigOth)
                    othCall{iChn}               =   BehChannel.SigOth{iChn}.get_signal([N1/Fs N2/Fs]);
                    othCall{iChn}               =   othCall{iChn};
                    [othCallSpeAll{iChn}, ~, ~] =   social.vad.tools.spectra(   othCall{iChn}{1},...
                                                                                param.specWinSize,...
                                                                                param.specShift,...
                                                                                Fs,...
                                                                                0 ...
                                                                             );
                end
            end
            
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
            parCallSpeRaw           =   parCallSpe;
            [parCallSpe, refCallSpe, oneCallSpe]      =   social.vad.tools.subtract_Spe( parCallSpe, refCallSpe, parGain, refGain, param );    
            frameLenP               =   param.detFrameLenP;
            shift                   =   param.detFrameShiftP;
            oneCallSpeHeight        =   size(oneCallSpe,1);
            segLen                  =   size(oneCallSpe,2);
            numOfFrame              =   floor((segLen-frameLenP)/shift);
            frame                   =   zeros(numOfFrame,oneCallSpeHeight * frameLenP); 
            for i = 1 : numOfFrame
                frame(i,:)          =   reshape(oneCallSpe(:,shift*(i-1)+1:shift*(i-1)+frameLenP),1,oneCallSpeHeight * frameLenP);
            end
            frame                   =   (frame - dataMin_parfor)/(dataMax_parfor - dataMin_parfor);
            [label, ~]              =   predict(SVMModel_parfor, frame * PCAWeight_parfor);

            % delay switch
            [indStartTemp, indStopTemp, eventCounter] = delaySwitch(label, param);
            % timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
            % timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
            % timeTemp        =   [timeStartTemp; timeStopTemp];

            % expand boundary
            [indStartTemp, indStopTemp] = expandBoundary(   indStartTemp, indStopTemp,...
                                                            parCallSpe, oneCallSpe, label, band, param);

            % sort events with start time
            [indStartTemp, order] = sort(indStartTemp);
            indStopTemp = indStopTemp(order);

            % merge calls
            [indStartTemp, indStopTemp, flag] = mergeCalls(indStartTemp, indStopTemp, param);
            indStartTemp(flag == 0) = [];
            indStopTemp(flag == 0) = [];
            timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
            timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
            timeTemp        =   [timeStartTemp; timeStopTemp];

            % deal with twitter
            % pass

            % call-wise filter
            %----------------begin------------------
            for iEvent = 1 : length(indStartTemp)
                if (timeStopTemp(iEvent) - timeStartTemp(iEvent) < param.minCallDuration)
                    continue;
                end
                TDStartP            =   round(timeStartTemp(iEvent)*param.Fs);
                TDStopP             =   round(timeStopTemp(iEvent)*param.Fs);
                [callType,~,~,~]    =   social.vad.tools.callTypeClassification(parCall(TDStartP:TDStopP),param);
                startP              =   (indStartTemp(iEvent)-1) * param.detFrameShiftP + 1;
                stopP               =   (indStopTemp(iEvent)-1) * param.detFrameShiftP + param.detFrameLenP;
                [AHR, ~]            =   social.vad.tools.AHR(oneCallSpe(:,startP:stopP), band);
                
                binSig              =   social.vad.tools.weightMatrix(oneCallSpe(:,startP:stopP), band);
                parEnergy           =   sum(parCallSpe(:,startP:stopP) .* binSig) ./ sum(binSig);
                refEnergy           =   sum(refCallSpe(:,startP:stopP) .* binSig) ./ sum(binSig);
                parEnergy           =   mean(parEnergy);
                refEnergy           =   mean(refEnergy);               
                diff                =   parEnergy - refEnergy;
                if strcmp(BehChannel.BehName, 'MultiRef')      
                    count_temp = 1;
                    for iChn = 1 : length(BehChannel.SigOth)
                        count_temp      =   count_temp + 1;
                        othCallSpe      =   othCallSpeAll{iChn}(:,startP:stopP);
                        othGain         =   BehChannel.SigOth{iChn}.gain_spec;
                        [parCallSpe1, refCallSpe1, diffCallSpe] = social.vad.tools.subtract_Spe( parCallSpeRaw(:,startP:stopP), othCallSpe, parGain, othGain, param );
                        binSig          =   social.vad.tools.weightMatrix(diffCallSpe, band);
                        parEnergy1      =   sum(parCallSpe1 .*binSig) ./ sum(binSig);
                        othEnergy       =   sum(refCallSpe1 .* binSig) ./ sum(binSig);
                        parEnergy1      =   mean(parEnergy1);
                        othEnergy       =   mean(othEnergy);
                        refEnergy       =   refEnergy + othEnergy;
                        parEnergy       =   parEnergy + parEnergy1;
                    end                
                    refEnergy       =   refEnergy / count_temp;
                    parEnergy       =   parEnergy / count_temp;
                    diff            =   parEnergy - refEnergy;
                end            

                if strcmp(BehChannel.BehName, 'MultiRef')
                    [score, exception, keep]=   parRefScore(diff, parEnergy, AHR, callType, timeStopTemp(iEvent) - timeStartTemp(iEvent), param);
                    scoreThresholdParRef    =   param.ROCParamParRef;
                    if (score < scoreThresholdParRef) || (keep == 0)
                        continue;
                    end
                    channel                 =   BehChannel.SigDetect.Channel;
                    diffWireless            =   nan;
                    parEnergyWireless       =   nan;
                else
                    if (AHR < param.AHRThresholdLB) && (~strcmpi(callType, 'Twitter'))
                        continue;
                    end



                    N1 = (startP - 1) * param.specShift + 1 + (ci - 1)*(chunklen-chunkOverlap)*Fs;
                    N2 = (stopP -1) * param.specShift + param.specWinSize + (ci - 1)*(chunklen-chunkOverlap)*Fs;   

                    numWireless = length(BehChannel.SigWireless);
                    wirelessCallArr = cell(1, numWireless);
                    wirelessCallSpe = cell(1, numWireless);
                    for iwl = 1 : numWireless
                        wirelessCall = BehChannel.SigWireless{iwl}.get_signal([N1/Fs, N2/Fs]);
                        wirelessCallArr{iwl} = wirelessCall{1};
                        [wirelessCallSpe{iwl}, ~, ~] = social.vad.tools.spectra(    wirelessCallArr{iwl},...
                                                                                    param.specWinSize,...
                                                                                    param.specShift,...
                                                                                    Fs,...
                                                                                    0 ...
                                                                                    );
                    end
                    diffMatrix = zeros(numWireless, numWireless);

                    for iwl1 = 1 : numWireless - 1
                        for iwl2 = iwl1 + 1 : numWireless                        
                            [wirelessCallSpe{iwl1}, wirelessCallSpe{iwl2}, diffCallSpe]...
                                                    =   social.vad.tools.subtract_Spe(  wirelessCallSpe{iwl1},...
                                                                                        wirelessCallSpe{iwl2},...
                                                                                        BehChannel.SigWireless{iwl1}.gain_spec,...
                                                                                        BehChannel.SigWireless{iwl2}.gain_spec,...
                                                                                        param...
                                                                                        );
                            lowBandEnergy1          =   mean(mean(wirelessCallSpe{iwl1}(1:band(1),:)));
                            lowBandEnergy2          =   mean(mean(wirelessCallSpe{iwl2}(1:band(1),:)));
                            l = min(size(wirelessCallSpe{iwl1},2), size(binSig,2));
                            w1                      =   sum(wirelessCallSpe{iwl1}(:,1:l) .* binSig(:,1:l)) ./ sum(binSig(:,1:l));
                            w2                      =   sum(wirelessCallSpe{iwl2}(:,1:l) .* binSig(:,1:l)) ./ sum(binSig(:,1:l));
                            wirelessEnergy1         =   mean(w1);
                            wirelessEnergy2         =   mean(w2);
                            if lowBandEnergy1 > 0
                                wirelessEnergy1 = wirelessEnergy1 - lowBandEnergy1;
                            end
                            if lowBandEnergy2 > 0
                                wirelessEnergy2 = wirelessEnergy2 - lowBandEnergy2;
                            end

                            diffWireless            =   wirelessEnergy1 - wirelessEnergy2;
                            diffMatrix(iwl1,iwl2)   =   diffWireless;
                            diffMatrix(iwl2,iwl1)   =   -diffWireless;
                        end
                    end

                    parEnergyWireless       =   max(wirelessEnergy1, wirelessEnergy2);
                    
                    [score, exception, keep] = wirelessScore(diff, diffWireless, parEnergy, parEnergyWireless, AHR, param.ROCParamWireless, callType, param);
                    
                    if keep == 0
                        continue;
                    end
                    
                    [~, indexTarget]        =   max(sum(diffMatrix, 2));
                    channel                 =   BehChannel.SigWireless{indexTarget}.Channel;
                    % if there are more than two wireless channels, the calculation will be more complicated
                    % this part hasn't been finished
                end            

                tStart                  =   [tStart;timeStartTemp(iEvent)+(ci - 1)*(chunklen-chunkOverlap)];
                tStop                   =   [tStop;timeStopTemp(iEvent)+(ci - 1)*(chunklen-chunkOverlap)];
                energyDiffArr           =   [energyDiffArr;diff];
                energyParArr            =   [energyParArr;parEnergy];
                energyDiffWirelessArr	=   [energyDiffWirelessArr;diffWireless];
                energyParWirelessArr    =   [energyParWirelessArr;parEnergyWireless];
                AHRArr                  =   [AHRArr; AHR];
                callTypeArr             =   [callTypeArr,{callType}];
                channelArr              =   [channelArr, channel];
                exceptionArr            =   [exceptionArr; exception];
            end             
        end        
    else
        tStart                      =   [];
        tStop                       =   [];
        energyDiffArr               =   [];
        energyDiffWirelessArr       =   [];
        exceptionArr                =   [];
        energyParArr                =   [];
        energyParWirelessArr        =   [];
        AHRArr                      =   [];
        callTypeArr                 =   [];
        channelArr                  =   [];
        frame                       =   [];
        load(fullfile(param.dataFolder,['SVMModelPCA',suffix,'.mat']));
        load(fullfile(param.dataFolder,['normPara',suffix,'.mat']));
        for ci = 1 : Nfor
            display([num2str(ci/Nfor*100),'% completed']);
            N1 = (ci - 1)*(chunklen-chunkOverlap)*Fs + 1;
            N2 = N1 + chunksize - 1;
            if N2 > samplesize
                N2 = samplesize;
            end
            parCall                 =   BehChannel.SigDetect.get_signal([N1/Fs N2/Fs]);
            refCall                 =   BehChannel.SigRef.get_signal([N1/Fs N2/Fs]);
            parCall                 =   parCall{1};
            refCall                 =   refCall{1};
            if strcmp(BehChannel.BehName, 'MultiRef')
                othCall             =   {};
                othCallSpeAll       =   {};
                for iChn = 1 : length(BehChannel.SigOth)
                    othCall{iChn}               =   BehChannel.SigOth{iChn}.get_signal([N1/Fs N2/Fs]);
                    othCall{iChn}               =   othCall{iChn};
                    [othCallSpeAll{iChn}, ~, ~] =   social.vad.tools.spectra(   othCall{iChn}{1},...
                                                                                param.specWinSize,...
                                                                                param.specShift,...
                                                                                Fs,...
                                                                                0 ...
                                                                             );
                end
            end
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
            parCallSpeRaw           =   parCallSpe;
            [parCallSpe, refCallSpe, oneCallSpe]      =   social.vad.tools.subtract_Spe( parCallSpe, refCallSpe, parGain, refGain, param );    
            frameLenP               =   param.detFrameLenP;
            shift                   =   param.detFrameShiftP;
            oneCallSpeHeight        =   size(oneCallSpe,1);
            segLen                  =   size(oneCallSpe,2);
            numOfFrame              =   floor((segLen-frameLenP)/shift);
            label                   =   zeros(numOfFrame,1);
            if isempty(frame) || (numOfFrame~=length(frame))
                frame = zeros(numOfFrame,oneCallSpeHeight * frameLenP); 
            end
            for i = 1 : numOfFrame
                frame(i,:) = reshape(oneCallSpe(:,shift*(i-1)+1:shift*(i-1)+frameLenP),1,oneCallSpeHeight * frameLenP);
            end
            frame                   =   (frame - dataMin)/(dataMax - dataMin);
            [label, ~]              =   predict(SVMModel, frame * PCAWeight);
            
            % delay switch
            [indStartTemp, indStopTemp, eventCounter] = delaySwitch(label, param);
            timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
            timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
            timeTemp        =   [timeStartTemp; timeStopTemp];
            
%             % deal with twitter
%             [indStartTemp, indStopTemp] = dealWithTwitter(indStartTemp, indStopTemp, oneCallSpe, parCall, param, 'All');
%             timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
%             timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
%             timeTemp        =   [timeStartTemp; timeStopTemp];
            
            % expand boundary
            [indStartTemp, indStopTemp] = expandBoundary(   indStartTemp, indStopTemp,...
                                                                parCallSpe, oneCallSpe, label, band, param);
            timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
            timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
            timeTemp        =   [timeStartTemp; timeStopTemp];
            % sort events with start time
            [indStartTemp, order] = sort(indStartTemp);
            indStopTemp = indStopTemp(order);

            % merge calls
            [indStartTemp, indStopTemp, flag] = mergeCalls(   indStartTemp, indStopTemp, param);
            indStartTemp(flag == 0) = [];
            indStopTemp(flag == 0) = [];
            timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
            timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
            timeTemp        =   [timeStartTemp; timeStopTemp];
            
%             % deal with twitter 
%             [indStartTemp, indStopTemp] = dealWithTwitter(indStartTemp, indStopTemp, oneCallSpe, parCall, param, 'Twitter');
%             timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
%             timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
%             timeTemp        =   [timeStartTemp; timeStopTemp];
            
            % call-wise filter
            %----------------begin------------------
            for iEvent = 1 : length(indStartTemp)
                if (timeStopTemp(iEvent) - timeStartTemp(iEvent) < param.minCallDuration)
                    continue;
                end
                TDStartP            =   round(timeStartTemp(iEvent)*param.Fs);
                TDStopP             =   round(timeStopTemp(iEvent)*param.Fs);
                [callType,~,~,~]    =   social.vad.tools.callTypeClassification(parCall(TDStartP:TDStopP),param);

                startP              =   (indStartTemp(iEvent)-1) * param.detFrameShiftP + 1;
                stopP               =   (indStopTemp(iEvent)-1) * param.detFrameShiftP + param.detFrameLenP;
                [AHR, ~]            =   social.vad.tools.AHR(oneCallSpe(:,startP:stopP), band);
                
                binSig              =   social.vad.tools.weightMatrix(oneCallSpe(:,startP:stopP), band);
                parEnergy           =   sum(parCallSpe(:,startP:stopP) .* binSig) ./ sum(binSig);
                refEnergy           =   sum(refCallSpe(:,startP:stopP) .* binSig) ./ sum(binSig);
                parEnergy           =   mean(parEnergy);
                refEnergy           =   mean(refEnergy);               
                diff                =   parEnergy - refEnergy;

                % average energy difference with other reference channels
                if strcmp(BehChannel.BehName, 'MultiRef')     
                    count_temp = 1;
                    for iChn = 1 : length(BehChannel.SigOth)
                        count_temp              =   count_temp + 1;
                        othCallSpe              =   othCallSpeAll{iChn}(:,startP:stopP);
                        othGain                 =   BehChannel.SigOth{iChn}.gain_spec;
                        [parCallSpe1, refCallSpe1, diffCallSpe] = social.vad.tools.subtract_Spe( parCallSpeRaw(:,startP:stopP), othCallSpe, parGain, othGain, param );
                        binSig                  =   social.vad.tools.weightMatrix(diffCallSpe, band);
                        parEnergy1              =   sum(parCallSpe1 .*binSig) ./ sum(binSig);
                        othEnergy               =   sum(refCallSpe1 .* binSig) ./ sum(binSig);
                        parEnergy1              =   mean(parEnergy1);
                        othEnergy               =   mean(othEnergy);
                        refEnergy               =   refEnergy + othEnergy;
                        parEnergy               =   parEnergy + parEnergy1;
                    end                
                    refEnergy           =   refEnergy / count_temp;
                    parEnergy           =   parEnergy / count_temp;
                    diff                =   parEnergy - refEnergy;
                end                
         
                % filter
                if strcmp(BehChannel.BehName, 'MultiRef')
                    [score, exception, keep]=   parRefScore(diff, parEnergy, AHR, callType, timeStopTemp(iEvent) - timeStartTemp(iEvent), param);
                    scoreThresholdParRef    =   param.ROCParamParRef;
                    if (score < scoreThresholdParRef) || (keep == 0)
                        continue;
                    end
                    channel                 =   BehChannel.SigDetect.Channel;
                    diffWireless            =   nan;
                    parEnergyWireless       =   nan;
                else

                    if (AHR < param.AHRThresholdLB) && (~strcmpi(callType, 'Twitter'))
                        continue;
                    end

                    N1 = (startP - 1) * param.specShift + 1 + (ci - 1)*(chunklen-chunkOverlap)*Fs;
                    N2 = (stopP -1) * param.specShift + param.specWinSize + (ci - 1)*(chunklen-chunkOverlap)*Fs;   

                    numWireless = length(BehChannel.SigWireless);
                    wirelessCallArr = cell(1, numWireless);
                    wirelessCallSpe = cell(1, numWireless);
                    for iwl = 1 : numWireless
                        wirelessCall = BehChannel.SigWireless{iwl}.get_signal([N1/Fs, N2/Fs]);
                        wirelessCallArr{iwl} = wirelessCall{1};
                        [wirelessCallSpe{iwl}, ~, ~] = social.vad.tools.spectra(    wirelessCallArr{iwl},...
                                                                                    param.specWinSize,...
                                                                                    param.specShift,...
                                                                                    Fs,...
                                                                                    0 ...
                                                                                    );
                    end
                    diffMatrix = zeros(numWireless, numWireless);

                    for iwl1 = 1 : numWireless - 1
                        for iwl2 = iwl1 + 1 : numWireless                        
                            [wirelessCallSpe{iwl1}, wirelessCallSpe{iwl2}, diffCallSpe]...
                                                    =   social.vad.tools.subtract_Spe(  wirelessCallSpe{iwl1},...
                                                                                        wirelessCallSpe{iwl2},...
                                                                                        BehChannel.SigWireless{iwl1}.gain_spec,...
                                                                                        BehChannel.SigWireless{iwl2}.gain_spec,...
                                                                                        param...
                                                                                        );
                            lowBandEnergy1          =   mean(mean(wirelessCallSpe{iwl1}(1:band(1),:)));
                            lowBandEnergy2          =   mean(mean(wirelessCallSpe{iwl2}(1:band(1),:)));
                            l = min(size(wirelessCallSpe{iwl1},2), size(binSig,2));
                            w1                      =   sum(wirelessCallSpe{iwl1}(:,1:l) .* binSig(:,1:l)) ./ sum(binSig(:,1:l));
                            w2                      =   sum(wirelessCallSpe{iwl2}(:,1:l) .* binSig(:,1:l)) ./ sum(binSig(:,1:l));
                            wirelessEnergy1         =   mean(w1);
                            wirelessEnergy2         =   mean(w2);
                            if lowBandEnergy1 > 0
                                wirelessEnergy1 = wirelessEnergy1 - lowBandEnergy1;
                            end
                            if lowBandEnergy2 > 0
                                wirelessEnergy2 = wirelessEnergy2 - lowBandEnergy2;
                            end

                            diffWireless            =   wirelessEnergy1 - wirelessEnergy2;
                            diffMatrix(iwl1,iwl2)   =   diffWireless;
                            diffMatrix(iwl2,iwl1)   =   -diffWireless;
                        end
                    end

                    parEnergyWireless       =   max(wirelessEnergy1, wirelessEnergy2);
                    
                    [score, exception, keep] = wirelessScore(diff, diffWireless, parEnergy, parEnergyWireless, AHR, param.ROCParamWireless, callType, param);
                    
                    if keep == 0
                        continue;
                    end
                    
                    [~, indexTarget]        =   max(sum(diffMatrix, 2));
                    channel                 =   BehChannel.SigWireless{indexTarget}.Channel;
                    % if there are more than two wireless channels, the calculation will be more complicated
                    % this part hasn't been finished
                end            

                tStart                  =   [tStart;timeStartTemp(iEvent)+(ci - 1)*(chunklen-chunkOverlap)];
                tStop                   =   [tStop;timeStopTemp(iEvent)+(ci - 1)*(chunklen-chunkOverlap)];
                energyDiffArr           =   [energyDiffArr;diff];
                energyParArr            =   [energyParArr;parEnergy];
                energyDiffWirelessArr	=   [energyDiffWirelessArr;diffWireless];
                energyParWirelessArr    =   [energyParWirelessArr;parEnergyWireless];
                AHRArr                  =   [AHRArr; AHR];
                callTypeArr             =   [callTypeArr,{callType}];
                channelArr              =   [channelArr, channel];
                exceptionArr            =   [exceptionArr; exception];
            end      

        end
    end
    clear temp1;
    temp1=social.event.Phrase.empty;
    for i=1:length(tStart)
        temp1(i)=social.event.PhraseConfidence( BehChannel.Session,...
                                                BehChannel,...
                                                tStart(i),...
                                                tStop(i),...
                                                0,...
                                                'callType',             callTypeArr{i},...
                                                'energyDiff',           energyDiffArr(i),...
                                                'energyPar',            energyParArr(i),...
                                                'energyDiffWireless',   energyDiffWirelessArr(i),...
                                                'energyParWireless',    energyParWirelessArr(i),...
                                                'AHR',                  AHRArr(i),...
                                                'exception',            exceptionArr(i),...
                                                'channel',              channelArr(i));    
    end
    detectedCalls = temp1;
end

function [indStartTemp, indStopTemp, eventCounter] = delaySwitch(label, param)
    NOISE               =   0;
    CALL                =   1;
    state               =   0;
    eventCounter        =   0;
    switch2NoiseCount   =   0;
    switch2CallCount    =   0;
    indStopTemp         =   [];
    indStartTemp        =   [];
    for i = 1 : length(label)
        if (state == CALL)
            if label(i) == NOISE
                switch2NoiseCount = switch2NoiseCount + 1;
                if switch2NoiseCount > param.switch2NoiseThreshold
                    state = NOISE;
                    switch2NoiseCount = 0;
                    switch2CallCount = 0;
                    indStopTemp(eventCounter) = i - param.switch2NoiseThreshold - 1;
                end
            else
                switch2NoiseCount = 0;
            end
        else
            if label(i) == CALL
                switch2CallCount = switch2CallCount + 1;
                if switch2CallCount > param.switch2CallThreshold
                    state = CALL;
                    switch2CallCount = 0;
                    switch2NoiseCount = 0;
                    eventCounter = eventCounter + 1;
                    indStartTemp(eventCounter) = i - param.switch2CallThreshold;
                end
            else
                switch2CallCount = 0;
            end
        end
    end
    if length(indStartTemp) > length(indStopTemp)
        indStopTemp(end+1) = length(label);
    end       
end

function [indStartTemp, indStopTemp] = expandBoundary(indStartTemp, indStopTemp, parCallSpe, oneCallSpe, label, band, param)
    oneCut = parCallSpe;
    [~, vm] = social.vad.tools.AHR(oneCallSpe, param.vocBandP);    
    frameShift = param.detFrameShiftP;
    frameLen = param.detFrameLenP;
    meanfilt = fspecial('average', [10, 1]);
    oneCut = filter2(meanfilt, oneCut);
    oneCut1 = max(oneCut(band(1):end, :), [], 1);
    eventCounter = length(indStartTemp);
    call_noise_flag = zeros(1,length(oneCut1));
    for iEvent = 1 : eventCounter
        startP = (indStartTemp(iEvent) - 1) * frameShift + 1;
        stopP = (indStopTemp(iEvent) - 1) * frameShift + frameLen;
        call_noise_flag(startP : stopP) = 1;
    end

    averageCallEnergy = sum(oneCut1 .* call_noise_flag) / sum(call_noise_flag);
    oneCut1 = oneCut1 / averageCallEnergy;

    for iEvent = 1 : eventCounter
        startP          =   (indStartTemp(iEvent)-1) * frameShift + 1;
        stopP           =   (indStopTemp(iEvent)-1) * frameShift + frameLen;       
        callEnergy      =   mean(oneCut1(startP : stopP));
        expandThreshold =   min(max(callEnergy - 0.3, 0.5), 1);
%         while (startP > frameShift)...
%                 && (mean(oneCut1(startP - frameShift : startP)) > expandThreshold)...
%                 && (mean(vm(startP - frameShift : startP)) > 20)
%             startP = startP - frameShift;
%         end
%         while (stopP < length(oneCut1) - frameShift)...
%                 && (mean(oneCut1(stopP : stopP + frameShift)) > expandThreshold)...
%                 && (mean(vm(stopP : stopP + frameShift)) > 20)
%             stopP = stopP + frameShift;
%         end
        while (startP > frameShift)...
                && (mean(oneCut1(startP - frameShift : startP)) > expandThreshold)
            startP = startP - frameShift;
        end
        while (stopP < length(oneCut1) - frameShift)...
                && (mean(oneCut1(stopP : stopP + frameShift)) > expandThreshold)
            stopP = stopP + frameShift;
        end
        while (stopP > frameShift) && (stopP > startP + frameShift)...
                &&((mean(vm(stopP - frameShift : stopP)) < 30) || (mean(oneCut1(stopP - frameShift : stopP)) < expandThreshold))
            stopP = stopP - frameShift;
        end
        indStartTemp(iEvent) = floor(startP / frameShift) + 1;
        indStopTemp(iEvent) = min(floor((stopP - frameLen) / frameShift) + 1,length(label));
    end
end

function [indStartTemp, indStopTemp, flag] = mergeCalls(indStartTemp, indStopTemp, param)
    eventCounter = length(indStartTemp);
    flag = ones(1,eventCounter);
    head = 1;
    tail = 1;
    while tail <= eventCounter
        if head >= tail
            if tail >= eventCounter
                break;
            else
                tail = tail + 1;
            end
            continue;
        end
        if (indStartTemp(tail)-1) * param.secPerFrameInd <= (indStopTemp(head)-1) * param.secPerFrameInd + param.secBaseline + 0.02
            indStopTemp(head) = max(indStopTemp(tail),indStopTemp(head));
            indStartTemp(head) = min(indStartTemp(tail),indStartTemp(head));
            flag(tail) = 0;
            tail = tail + 1;
        else
            head = head + 1;
        end
    end
end

function [indStartTemp, indStopTemp] = dealWithTwitter(indStartTemp, indStopTemp, oneCallSpe, parCall, param, callTypeToDo)
    indStartTemp1   =   [];
    indStopTemp1    =   [];
    timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
    timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
    for iEvent = 1 : length(indStartTemp)
        TDStartP            =   round(timeStartTemp(iEvent)*param.Fs);
        TDStopP             =   round(timeStopTemp(iEvent)*param.Fs);
        TDStopP             =   min(TDStopP, TDStartP + 0.08 * param.Fs);
        [callType,~,~,~]    =   social.vad.tools.callTypeClassification(parCall(TDStartP:TDStopP),param);               
        if strcmp(callType, callTypeToDo) || strcmp(callTypeToDo, 'All')
            startP          =   (indStartTemp(iEvent)-1)*param.detFrameShiftP + 1;
            stopP           =   (indStopTemp(iEvent)-1)*param.detFrameShiftP + param.detFrameLenP;
            [AHR, vm]       =   social.vad.tools.AHR(oneCallSpe(:,startP:stopP), param.vocBandP);
%             [wieEnt, vm1]   =   social.vad.tools.wienerEntropy(oneCallSpe(:,startP:stopP));
%             subplot(2,1,1)
%             imagesc(oneCallSpe(:,startP:stopP))
%             title([num2str(timeStartTemp(iEvent)),'-',num2str(timeStopTemp(iEvent))]);
%             subplot(2,1,2)
%             plot(vm)
            k = zeros(indStopTemp(iEvent) - indStartTemp(iEvent) + 1, 1);
            l = k+1;
            for i = 1 : length(k)
                k(i) = mean(vm((i-1)*param.detFrameShiftP + 1 : (i-1)*param.detFrameShiftP + param.detFrameLenP));
                if (k(i) < param.broadBandThreshold)
                    l(i) = 0;
                end
            end
            left = 1;
            right = 1;
            now = l(1);
            for i = 2 : length(l)
                if (now == 0)
                    left = i;
                    right = i;
                    now = l(i);
                elseif (now == 1) && (l(i) == 0)
                    indStartTemp1 = [indStartTemp1, indStartTemp(iEvent)-1+left];
                    indStopTemp1 = [indStopTemp1, indStartTemp(iEvent)-1+right];
                    left = i;
                    right = i;
                    now = 0;
                else
                    right = i;
                    now = 1;
                end
            end
            if now == 1
                right = length(l);
                indStartTemp1 = [indStartTemp1, indStartTemp(iEvent)-1+left];
                indStopTemp1 = [indStopTemp1, indStartTemp(iEvent)-1+right];  
            end
        else
            indStartTemp1 = [indStartTemp1, indStartTemp(iEvent)];
            indStopTemp1 = [indStopTemp1, indStopTemp(iEvent)];
        end
    end      
    indStartTemp    =   indStartTemp1;
    indStopTemp     =   indStopTemp1;
end

function [score, exception, keep] = parRefScore(diff, parEnergy, AHR, callType, duration, param)
    keep = 1;
    if (AHR < param.AHRThresholdLB) && (~strcmpi(callType, 'Twitter'))
        keep = 0;
    end

    if (duration < param.minCallDuration)
        keep = 0;
    end

    if ((strcmpi(callType, 'Phee')) || (strcmpi(callType, 'Trill'))) && (parEnergy > param.parEnergyThresholdUB)
        rate = param.parEnergyThresholdUB / parEnergy;
        diff = diff * rate;
        parEnergy = parEnergy * rate;
    end        

    xx = diff - param.difEnergyThresholdLB;
    kk = 10;
    if xx < 0
        xx = xx * kk;
    end
    score = log2(1+2^xx) * 1/(1+exp(-AHR+param.AHRThresholdUB));
    
    exception = 0;
end

function [score, exception, keep] = wirelessScore(diff, diffWireless, parEnergy, parEnergyWireless, AHR, kk, callType, param)
    keep = 1;
    feature = zeros(4,1);
                    
    if ((strcmpi(callType, 'Phee')) || (strcmpi(callType, 'Trill'))) && (parEnergy > param.parEnergyThresholdUB)
        rate = param.parEnergyThresholdUB / parEnergy;
        diff = diff * rate;
        diffWireless = diffWireless * rate;
        parEnergyWireless = parEnergyWireless * rate;
    end

    if (parEnergyWireless - abs(diffWireless) < 0) && (parEnergyWireless < (param.parEnergyThresholdWireless / 2))
        keep = 0;
    end
  
    
    xx = min(diff,param.difEnergyThresholdUB)-param.difEnergyThresholdLB;
    if xx < 0
        xx = xx * kk;
    end
    feature(1) = log2(1+2^xx);

    xx = min(param.difEnergyThresholdWireless, abs(diffWireless) - param.difEnergyThresholdWireless);
    if xx < 0
        xx = xx * kk;
    end
    feature(2) = log2(1+2^xx);

    xx = min(param.parEnergyThresholdWireless, parEnergyWireless - param.parEnergyThresholdWireless);
    if xx < 0
        xx = xx * kk;
    end
    feature(3) = log2(1+2^xx);

    feature(4) = 1/(1+exp(-AHR+(param.AHRThresholdLB+param.AHRThresholdUB)/2));
    score = prod(feature);
    
    exception = 0;
    
    if (score >= param.scoreThresholdWireless(1))
        exception = 0;
    elseif (feature(1) > param.scoreThresholdWireless(1)) &&...
            (feature(2)*feature(3) >= param.scoreThresholdWireless(3)) &&...
            (feature(4)>0.5)
        exception = 1;
    elseif (feature(2)*feature(3) > param.scoreThresholdWireless(1)) &&... 
            (feature(1) >= param.scoreThresholdWireless(2)) &&...
            (feature(4)>0.5)
        exception = 2;
    else
        keep = 0;
    end
end