classdef (Abstract) BehaviorChannel < social.interface.Social & matlab.mixin.Heterogeneous & dynamicprops
    %BEHAVIORCHANNEL Abstract Class for each experiment behavior channel
    % A behavior channel is either a vocal, motor, position, etc channel
    % It specifies the corresponding Signals or Signal groups used to detect
    % the behavior.
    % It also defines methods used for detection or feature extraction
    
    properties
        SigDetect           % which Signal for detection
        SigRef              % which Signal for reference, if needed
        SigFeature          % which Signal for feature extraction, if needed
        IsProcessed           % a flag to mark whether this Channel has been processed (e.g. events detected)
    end
    
    methods (Abstract) 
        detected_events = DetectEvents(self);

    end
    
    methods (Abstract)
        extracted_features = GetEventFeatures(self);   
        % For example, getting F0 from regular mic will be different from
        % parabolic mic, and may require additional Signals
    end
    
    methods 
        
        function self = BehaviorChannel(SigDetect,SigRef,SigFeature,IsProcessed)
            if nargin == 0
                self.SigDetect = NaN;
                self.SigRef = NaN;
                self.SigFeature = NaN;
                self.IsProcessed = 0;
                
            else
            
                self.SigDetect = SigDetect;
                self.SigRef = SigRef;
                self.SigFeature = SigFeature;
                self.IsProcessed = IsProcessed;
                
            end
            
        end
        
        function str = Report(self)
            % Return a formatted report (nx1 cellstr) summarizing object information.
            str = '';
        end

        function tab = Tabulate(self)
            tab = [];
        end
        
    end
    
end

