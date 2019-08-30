classdef ColonyParabolicChannel < social.interface.BehaviorChannel
    %COLONYPARABOLICCHANNEL 
    % Parabolic Mic vs. Ref mic
    
    properties
        SubjectID
        SpecDiffThreshold      % threshold for detection: difference in spectrogram
%         MinVocDuration         % minimum phrase duration (in sec), calls longer than this will be detected
%         GapCheckThreshold
    end
    
    methods
        function self = ColonyParabolicChannel(SigDetect,SigRef,SigFeature,IsProcessed,SubjectID,SpecDiffThreshold)
            self@social.interface.BehaviorChannel;
            if nargin == 0
                self.SubjectID = '';
                self.SpecDiffThreshold = 5;
%                 self.MinVocDuration = 0.01;
%                 self.GapCheckThreshold = 0.1;
            else
                self.SigDetect = SigDetect;
                self.SigRef = SigRef;
                self.SigFeature= SigFeature;
                self.IsProcessed= IsProcessed;
                self.SubjectID = SubjectID;
                self.SpecDiffThreshold = SpecDiffThreshold;
%                 self.MinVocDuration = min_dur;
%                 self.GapCheckThreshold = gap_th;
            end
        end
        
        
        function detected_events = DetectEvents(self,Sessions)
            
            DetectionParam.MinVocDuration = 0.05;
            DetectionParam.GapCheckThreshold = 0.1;
            DetectionParam.MinGapInterval = 0.05;
            
            detected_events = social.processing.call_detect_parabolic(Sessions,self,DetectionParam);

            self.IsProcessed = 1;
            
        end
        
        function extracted_features = GetEventFeatures(self); 
            
            extracted_features = [];
        end
    end
    
end

