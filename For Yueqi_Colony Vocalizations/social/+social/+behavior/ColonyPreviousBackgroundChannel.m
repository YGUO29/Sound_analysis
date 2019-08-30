classdef ColonyPreviousBackgroundChannel < social.interface.Behavior & social.interface.AnalogSignal
    %COLONYPREVIOUSBACKGROUNDCHANNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        SigDetect = nan;
        TargetBehaviors = nan;
        SigFeature = nan;
        
        PrevWindowLength = 10;
%         MinVocDuration         % minimum phrase duration (in sec), calls longer than this will be detected
%         GapCheckThreshold
    end
    
    methods
        function self = ColonyPreviousBackgroundChannel(Session,SubjectID,SigDetect,TargetBehaviors,SigFeature,IsProcessed,PreTargetWindow)
%             self@social.interface.BehaviorChannel;
            if nargin == 0
                self.Subjects = 'ColonyMarmoset';
                self.PrevWindowLength = 10;
%                 self.MinVocDuration = 0.01;
%                 self.GapCheckThreshold = 0.1;
            else
                self.Session=Session;
                self.Subjects=SubjectID;
                self.SigDetect = SigDetect;
                self.TargetBehaviors = TargetBehaviors;
                self.SigFeature= SigFeature;
                self.IsProcessed= IsProcessed;
                self.PrevWindowLength = PreTargetWindow;
%                 self.MinVocDuration = min_dur;
%                 self.GapCheckThreshold = gap_th;
            end
        end
        
        
        function detected_events = DetectEvents(self)
            DetectionParam.MinVocDuration = 0.05;
            DetectionParam.MinGapInterval = 0.05;
            DetectionParam.Threshold = -70;     % in dB, normalized to 1 in the wave file
            detected_events = social.processing.call_detect_first_prev_background(self,DetectionParam);

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


