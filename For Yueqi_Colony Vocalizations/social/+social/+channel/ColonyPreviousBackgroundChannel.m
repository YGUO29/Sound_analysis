classdef ColonyPreviousBackgroundChannel < social.interface.BehaviorChannel
    %COLONYPREVIOUSBACKGROUNDCHANNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        SubjectID
        TargetID                % subject ID for target animals, separated by comma
        PrevWindowLength
%         MinVocDuration         % minimum phrase duration (in sec), calls longer than this will be detected
%         GapCheckThreshold
    end
    
    methods
        function self = ColonyPreviousBackgroundChannel(SigDetect,SigRef,SigFeature,IsProcessed,SubjectID,TargetID,pre_win)
            self@social.interface.BehaviorChannel;
            if nargin == 0
                self.SubjectID = 'ColonyMarmoset';
                self.TargetID = '';
                self.PrevWindowLength = 10;
%                 self.MinVocDuration = 0.01;
%                 self.GapCheckThreshold = 0.1;
            else
                self.SigDetect = SigDetect;
                self.SigRef = SigRef;
                self.SigFeature= SigFeature;
                self.IsProcessed= IsProcessed;
                self.SubjectID = SubjectID;
                self.TargetID = TargetID;
                self.PrevWindowLength = pre_win;
%                 self.MinVocDuration = min_dur;
%                 self.GapCheckThreshold = gap_th;
            end
        end
        
        
        function detected_events = DetectEvents(self,Session)
            
            DetectionParam.MinVocDuration = 0.05;
            DetectionParam.MinGapInterval = 0.05;
            DetectionParam.Threshold = -90;     % in dB, normalized to 1 in the wave file
            detected_events = social.processing.call_detect_first_prev_background(Session,self,DetectionParam);

            self.IsProcessed = 1;
            
        end
        
        function extracted_features = GetEventFeatures(self) 
            
            extracted_features = [];
        end
    end
    
end


