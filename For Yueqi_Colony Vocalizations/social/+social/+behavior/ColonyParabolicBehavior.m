classdef ColonyParabolicChannel < social.interface.Behavior & social.interface.AnalogSignal
    %COLONYPARABOLICCHANNEL 
    % Parabolic Mic vs. Ref mic
    
    properties
        SigDetect =nan;
        SigRef = nan;
        SigFeature = nan;
        SpecDiffThreshold = 2;      % threshold for detection: difference in spectrogram
%         MinVocDuration         % minimum phrase duration (in sec), calls longer than this will be detected
%         GapCheckThreshold
        
        %From social.interface.behavior
        %Session
        %Name                % Unique identifier for the behavior
        %Subject             % An 1xN array of subject ids (M##, Environment)\
        %Events
        %SyncTime = 0;
        %IsProcessed = false;% a flag to mark whether this Channel has been processed (e.g. events detected)
    end
    
    methods
        function self = ColonyParabolicChannel(Session,SubjectID,SigDetect,SigRef,SigFeature,IsProcessed)
%              self@social.interface.Behavior;
            if nargin >0
                self.Session=Session;
                self.Subjects = SubjectID;
                self.SigDetect = SigDetect;
                self.SigRef = SigRef;
                self.SigFeature= SigFeature;
                self.IsProcessed= IsProcessed;
                self.SpecDiffThreshold = 2;
                self.ID=['Par_' self.Subjects];
%                 self.ID=[self.SigDetect.ID '-' self.Subjects];
                self.SampleRate = self.SigFeature.SampleRate;
%                 self.MinVocDuration = min_dur;
%                 self.GapCheckThreshold = gap_th;
            end
        end
        function detected_events = DetectEvents(self)
            fprintf(['Detecting events from ' self.ID ' for signal ' self.SigDetect.ID ' referenced to ' self.SigRef.ID '.\n']);
            DetectionParam.MinVocDuration = 0.05;
            DetectionParam.GapCheckThreshold = 0.1;
            DetectionParam.MinGapInterval = 0.05;
            
            detected_events = social.processing.call_detect_parabolic(self,DetectionParam);
            
            self.Events = [self.Events detected_events];
            self.nEvents=length(self.Events);
            
            fprintf(['Found ' num2str(length(detected_events)) ' events.\n'])

            self.IsProcessed = 1;
        end
      
        function extracted_features = GetEventFeatures(self); 
            
            extracted_features = [];
        end
        
        function signal = get_signal(self,times)
            signal=self.SigFeature.get_signal(times);
        end
    end
    
end

