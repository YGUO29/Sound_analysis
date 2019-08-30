classdef RegularVocalChannel < social.interface.BehaviorChannel
    % This is for vocalizations/acoustics recorded by regular microphones
    %   
    
    properties
        SubjectID           % Subject ID for recordings in this channel
    end
    
    methods
        function self = RegularVocalChannel(SigDetect,SigRef,SigFeature,IsProcessed,SubjectID)
            self@social.interface.BehaviorChannel;
            if nargin == 0
                self.SubjectID = '';
            else
                self.SubjectID = SubjectID;
            end

            
        end
        
        
        function detected_events = DetectEvents(self)
            detected_events = social.processing.call_detect_single_channel(self);
            self.IsProcessed = 1;
        end
        
        function extracted_features = GetEventFeatures(self)
            extracted_features = GetCallF0(self);
        end
        
        
        
    end
    
end

