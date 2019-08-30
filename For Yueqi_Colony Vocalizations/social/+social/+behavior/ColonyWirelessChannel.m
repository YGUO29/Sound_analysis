classdef ColonyWirelessChannel < social.interface.Behavior & social.interface.AnalogSignal
    %COLONYWIRELESSCHANNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SigDetect       =   nan;
        SigRef          =   nan;
        SigWireless     =   nan;
        param;
    end
    
    methods
        function self = ColonyWirelessChannel(Session, SubjectID, SigDetect, SigRef, SigWireless, IsProcessed, param)
            if nargin > 0
                self.Session        =   Session;
                self.Subjects       =   SubjectID;
                self.SigDetect      =   SigDetect;
                self.SigRef         =   SigRef;
                self.SigWireless    =   SigWireless;
                self.IsProcessed    =   IsProcessed;
                self.BehName        =   'Wireless';
                self.ID             =   ['Wireless_', self.Subjects];
                self.param          =   param;
            end
        end
        
        function detected_events = DetectEvents(self)
            fprintf(['Detecting events from ' self.ID '.\n']);
            detected_events = social.processing.call_detect_multiChannels(self);
            fprintf(['Found ' num2str(length(detected_events)) ' events.\n']);
            self.IsProcessed = 1;
        end
            
        function extracted_features = GetEventFeatures(self)
            extracted_features = [];
        end
        
        function signal = get_signal(self,times)
            signal=self.SigDetect.get_signal(times);
        end
    end
    
end

