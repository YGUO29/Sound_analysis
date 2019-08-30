% Directional Detecting with a parabolic mic and a reference mic
% This function work on a pair of channels only

function detectedCalls = call_detect_parabolic_xhw( BehChannel,DetectionParam )
    param                       =   social.vad.tools.Param();
    suffix                      =   [param.subjectTrain,'_',num2str(param.version)];
    load(fullfile(param.dataFolder,['SVMModelPCA',suffix,'.mat']));
    load(fullfile(param.dataFolder,['normPara',suffix,'.mat']));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\HMM')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMtools')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMstats')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\netlab3.3')));
    addpath(genpath(fullfile(param.HMM_GMMFolder,'voicebox')));
    band = param.vocBandP;
    param.norm.dataMin          =   dataMin;
    param.norm.dataMax          =   dataMax;
    Fs                          =   param.Fs;    
    if (Fs ~= BehChannel.SigDetect.SampleRate) error('wrong Fs');end    
    chunklen                    =   param.chunklen; % in sec
    chunksize                   =   chunklen * Fs;
    samplesize                  =   BehChannel.SigDetect.TotalSamples;
    chunkOverlap                =   param.chunkOverlap; % in sec
    Nfor                        =   ceil((samplesize - chunksize)/((chunklen-chunkOverlap)*Fs)) + 1;
    tStart                      =   [];
    tStop                       =   [];
    energyDiffArr               =   [];
    exception                   =   [];
    energyParArr                =   [];
    AHRArr                      =   [];
    callTypeArr                 =   {};
    channelArr                  =   [];
    frame                       =   [];
    BehChannel.SigDetect.calculate_gain();
    BehChannel.SigRef.calculate_gain();
%     Nfor = 10;
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
        refCallSpeRaw           =   refCallSpe;
        parGain                 =   BehChannel.SigDetect.gain_spec;
        refGain                 =   BehChannel.SigRef.gain_spec;
        [parCallSpe, refCallSpe, oneCallSpe]...
                                =   social.vad.tools.subtract_Spe( parCallSpe, refCallSpe, parGain, refGain, param );    
        frameLenP = param.detFrameLenP;
        shift = param.detFrameShiftP;
        oneCallSpeHeight = size(oneCallSpe,1);
        segLen = size(oneCallSpe,2);
        numOfFrame = floor((segLen-frameLenP)/shift);
        label = zeros(numOfFrame,1);
        if isempty(frame) || (numOfFrame~=length(frame))
            frame = zeros(numOfFrame,oneCallSpeHeight * frameLenP); 
        end
        for i = 1 : numOfFrame
            frame(i,:) = reshape(oneCallSpe(:,shift*(i-1)+1:shift*(i-1)+frameLenP),1,oneCallSpeHeight * frameLenP);
        end
        frame                   =   (frame - param.norm.dataMin)/(param.norm.dataMax - param.norm.dataMin);
        [label, score]          =   predict(SVMModel, frame * PCAWeight);
        % delay switch
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
        if length(indStartTemp)>length(indStopTemp)
            indStopTemp(end+1) = length(label);
        end
        timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
        timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
        timeTemp        =   [timeStartTemp; timeStopTemp];
        % expand boundary
        %----------------begin------------------
        for iEvent = 1 : eventCounter
            p2f = param.detFrameShiftP;
            startP = (indStartTemp(iEvent)-1) * p2f + 1;
            stopP = (indStopTemp(iEvent)-1) * p2f + param.detFrameLenP;
            callEnergy = mean(max(parCallSpe(: , startP : stopP)));
            if callEnergy < param.callEnergyLB
                continue;
            end
            shrinkThreshold = min(max(callEnergy * param.expandBoundaryThresholdIn, param.noiseEnergyLB),param.noiseEnergyUB);
            expandThreshold = max(min(callEnergy * param.expandBoundaryThresholdOut, param.callEnergyUB),param.callEnergyLB);
            while (startP > p2f) && (mean(max(parCallSpe(:,startP - p2f : startP))) > expandThreshold)
                startP = startP - p2f;
            end
            while ((startP < size(parCallSpe,2)-p2f) && (mean(max(parCallSpe(:,startP + 1 : startP + p2f))) < shrinkThreshold))
                startP = startP + p2f;
            end
            while (stopP < size(parCallSpe,2)-p2f) && (mean(max(parCallSpe(:,stopP+1 : stopP + p2f))) > expandThreshold)
                stopP  = stopP + p2f;
            end

            indStartTemp(iEvent) = floor(startP / p2f) + 1;
            indStopTemp(iEvent) = min(floor((stopP - param.detFrameLenP) / p2f) + 1,length(label));
        end
        %-----------------end--------------------
        
        % sort events with start time
        [indStartTemp, order] = sort(indStartTemp);
        indStopTemp = indStopTemp(order);
       
        % merge calls
        %----------------begin-------------------
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
        %----------------end--------------------        
                
        % deal with twitter
        timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
        timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
        indStartTemp1   =   [];
        indStopTemp1    =   [];
        for iEvent = 1 : eventCounter
            if (flag(iEvent) == 1)
                TDStartP            =   round(timeStartTemp(iEvent)*param.Fs);
                TDStopP             =   round(timeStopTemp(iEvent)*param.Fs);
                [callType,~,~,~]    =   social.vad.tools.callTypeClassification(parCall(TDStartP:TDStopP));               
                if strcmp(callType, 'Twitter')
                    oneCut = oneCallSpe(:,(indStartTemp(iEvent)-1)*param.detFrameShiftP + 1 : (indStopTemp(iEvent)-1)*param.detFrameShiftP + param.detFrameLenP);
                    m = max(oneCut(band(1):band(2),:),[],1);
                    aw = 5;
                    oneCut1 = medfilt2(oneCut,[aw,1]);
                    v = mean(abs(oneCut1 - oneCut),1);
                    vm = m./v;
                    k = zeros(indStopTemp(iEvent) - indStartTemp(iEvent) + 1, 1);
                    l = k+1;
                    for i = 1 : length(k)
                        k(i) = mean(vm((i-1)*param.detFrameShiftP + 1 : (i-1)*param.detFrameShiftP + param.detFrameLenP));
                        if (k(i) < param.broadBandThresholdLB)
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
        end
        
        indStartTemp = indStartTemp1;
        indStopTemp = indStopTemp1;

        
        timeStartTemp   =   (indStartTemp) * param.secPerFrameInd;
        timeStopTemp    =   (indStopTemp) * param.secPerFrameInd + param.secBaseline;
        timeTemp        =   [timeStartTemp; timeStopTemp];
        for iEvent = 1 : length(timeStartTemp)
            startP = (indStartTemp(iEvent)-1) * param.detFrameShiftP + 1;
            stopP  = (indStopTemp(iEvent)-1) * param.detFrameShiftP + param.detFrameLenP;
            oneCut = oneCallSpe(:,startP:stopP);
            m = max(oneCut(band(1):band(2),:),[],1);
            aw = 3;
            oneCut1 = medfilt2(oneCut,[aw,1]);
            v = mean(abs(oneCut1 - oneCut),1);
            vm = m./v;
%             subplot(4,1,1),imagesc(oneCut);colorbar;
%             title([num2str(indStartTemp(iEvent)*0.006),'--',num2str(indStopTemp(iEvent)*0.006)]);
%             subplot(4,1,2),plot(m);
%             subplot(4,1,3),plot(v);
%             subplot(4,1,4),plot(vm);
            AHR = mean(vm);
%             title(num2str(AHR));
            if AHR < (param.broadBandThresholdUB)
                continue;
            end
            parSig = zeros(size(parCallSpeRaw(:,startP:stopP)));
            parSig(parCallSpeRaw(:,startP:stopP)>param.sigThreshold) = 1;
            parSig(1:band(1),:) = 0;
            parSig(band(2):end,:) = 0;        
            parEnergy           =   sum(sum(parCallSpeRaw(:,startP:stopP) .* parSig))/sum(sum(parSig(band(1):band(2),:)));
            refEnergy           =   sum(sum(refCallSpeRaw(:,startP:stopP) .* parSig))/sum(sum(parSig(band(1):band(2),:)));
            diff1                =   parEnergy - refEnergy;
            
%             parEnergy          =   mean(mean(parCallSpeRaw(band(1):band(2),startP:stopP)));
%             refEnergy          =   mean(mean(refCallSpeRaw(band(1):band(2),startP:stopP)));
%             diff               =   parEnergy - refEnergy;

            diff = diff1;
% --------------------------
            if (timeStopTemp(iEvent) - timeStartTemp(iEvent) > param.minCallDuration)&&...
               (diff > param.difEnergyThresholdUB)&&...
               (parEnergy > param.parEnergyThreshold)
                exception       =   [exception;0];
            elseif...
                (diff <= param.difEnergyThresholdUB)&&(diff > param.difEnergyThresholdLB)&&...
                (timeStopTemp(iEvent) - timeStartTemp(iEvent) > param.minCallDuration)&&...
               (parEnergy > param.parEnergyThreshold)
                exception       =   [exception;1];
            elseif...
                (diff > param.difEnergyThresholdUB)&&...
                (timeStopTemp(iEvent) - timeStartTemp(iEvent) <= param.minCallDuration)&&...
               (parEnergy > param.parEnergyThreshold)
                exception       =   [exception;2];
            else
                continue;
            end              
            TDStartP            =   round(timeStartTemp(iEvent)*param.Fs);
            TDStopP             =   round(timeStopTemp(iEvent)*param.Fs);
            [callType,~,~,~]    =   social.vad.tools.callTypeClassification(parCall(TDStartP:TDStopP));
            
            tStart              =   [tStart;timeStartTemp(iEvent)+(ci - 1)*(chunklen-chunkOverlap)];
            tStop               =   [tStop;timeStopTemp(iEvent)+(ci - 1)*(chunklen-chunkOverlap)];
            energyDiffArr       =   [energyDiffArr;diff];
            energyParArr        =   [energyParArr;parEnergy]; 
            AHRArr              =   [AHRArr; AHR];
            callTypeArr         =   [callTypeArr,callType];
            channelArr          =   [channelArr, BehChannel.SigDetect.Channel];
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
                                                'AHR',                  AHRArr(i),...
                                                'exception',            exception(i),...
                                                'channel',             channelArr(i));    
    end
    detectedCalls = temp1;
end

