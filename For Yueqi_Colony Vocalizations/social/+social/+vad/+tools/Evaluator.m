classdef Evaluator
    %EVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        autoDetectionFile;
        groundTruthFile;
        boxChannel;
        param
        callsGT
        callsAD
        CALL_TYPE
        totalDetection = 0;
        totalDetection_by_type
        totalGroundTruth = 0;
        totalGroundTruth_by_type
        tp = 0;
        fp = 0;
        fn = 0;
        tn = 0;
        false_alarm_rate = 0; % fp / (fp + tn), but here actural is fp / (fp + tp) since we cannot define tn
        precision = 0; % tp / (tp + fp)
        recall = 0; % tp / (tp + fn)
        miss_rate = 0; % fn / (tp + fn)
        maxTime
    end
    
    methods
        function self = Evaluator(autoDetectionFile, groundTruthFile, boxChannel)
            self.autoDetectionFile = autoDetectionFile;
            self.groundTruthFile = groundTruthFile;
            self.param = social.vad.tools.Param();
            self.boxChannel = boxChannel;
            sampleProviderGT = social.vad.SampleProvider('', groundTruthFile, '', 1, 1, boxChannel, self.param);
            sampleProviderAD = social.vad.SampleProvider('', autoDetectionFile, '', 1, 1, boxChannel, self.param);
            self.callsGT = sampleProviderGT.extractSegs('call');
            self.callsAD = sampleProviderAD.extractSegs('call');
            self.CALL_TYPE = cat(1,self.param.CALL_TYPE, {{'otherTypes'}});
            
            % define the duration of this sessioin
            % ----begin----
            maxTime = 0;
            for iType = 1 : length(self.callsGT)
                for iCall = 1 : length(self.callsGT{iType})
                    if self.callsGT{iType}(iCall).endTime > maxTime
                        maxTime = self.callsGT{iType}(iCall).endTime;
                    end
                end
                for iCall = 1 : length(self.callsAD{iType})
                    if self.callsAD{iType}(iCall).endTime > maxTime
                        maxTime = self.callsAD{iType}(iCall).endTime;
                    end
                end
            end
            self.maxTime = maxTime;
            % -----end-----
            
            self.totalDetection_by_type = zeros(length(self.callsAD), 1);
            self.totalGroundTruth_by_type = zeros(length(self.callsGT), 1);
            for iType = 1 : length(self.callsAD)
                self.totalDetection_by_type(iType) = length(self.callsAD{iType});
                self.totalGroundTruth_by_type(iType) = length(self.callsGT{iType});
            end
            self.totalDetection = sum(self.totalDetection_by_type);
            self.totalGroundTruth = sum(self.totalGroundTruth_by_type);
            
            
        end
            
        function [false_alarm_rate, calls] = false_alarm_eval(self, BehChannel)
            calls = social.event.Phrase.empty;
            fac = 0; % false_alarm_count
            timeRes = self.param.timeResEQ;
            maxTime = self.maxTime;
            numOfInd = ceil(maxTime / timeRes);
            flag = zeros(numOfInd, 1);
            for iType = 1 : length(self.callsGT)
                for iCall = 1 : self.totalGroundTruth_by_type(iType)
                    startP = ceil(self.callsGT{iType}(iCall).beginTime / timeRes);
                    startP = max(1, startP);
                    stopP = ceil(self.callsGT{iType}(iCall).endTime / timeRes);
                    flag(startP : stopP) = iType;
                end
            end
            
                    
            for iType = 1 : length(self.callsAD)
                for iCall = 1 : length(self.callsAD{iType})
                    startP = ceil(self.callsAD{iType}(iCall).beginTime / timeRes);
                    startP = max(1, startP);
                    stopP = ceil(self.callsAD{iType}(iCall).endTime / timeRes);
                    if sum(flag(startP : stopP) ~= 0) / (stopP - startP + 1) < self.param.overlapThresholdEQ
                        fac = fac + 1;
                        calls(fac) = social.event.PhraseConfidence(...
                                            BehChannel.Session,...
                                            BehChannel,...
                                            self.callsAD{iType}(iCall).beginTime,...
                                            self.callsAD{iType}(iCall).endTime,...
                                            0,...
                                            'callType',             'Noise',...
                                            'energyDiff',           0,...
                                            'energyPar',            0,...
                                            'energyDiffWireless',   0,...
                                            'energyParWireless',    0,...
                                            'AHR',                  0,...
                                            'exception',            0,...
                                            'channel',              self.boxChannel...
                                            );
                    end
                end
            end
            false_alarm_rate = fac / self.totalDetection; % fp / (fp + tp)
        end
    end
end

