classdef ColonyParRefChannel < social.interface.Behavior & social.interface.AnalogSignal
    %COLONYWIRELESSCHANNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SigDetect       =   nan;
        SigRef          =   nan;
        SigOth          =   nan;
        param
    end
    
    methods
        function self = ColonyParRefChannel(Session, SubjectID, SigDetect, SigRef, SigOth, IsProcessed, param)
            if nargin > 0
                self.Session        =   Session;
                self.Subjects       =   SubjectID;
                self.SigDetect      =   SigDetect;
                self.SigRef         =   SigRef;
                self.SigOth         =   SigOth;
                self.IsProcessed    =   IsProcessed;
                self.BehName        =   'MultiRef';
                self.ID             =   ['MultiRef_', self.Subjects];
                self.param          =   param;
            end
        end
        
        function detected_events = DetectEvents(self)
            fprintf(['Detecting events from ' self.Session.ID ' for ' self.SigDetect.ID ' referenced to ' self.SigRef.ID '.\n']);
            detected_events = social.processing.call_detect_multiChannels(self);
            fprintf(['Found ' num2str(length(detected_events)) ' events.\n']);
            self.IsProcessed = 1;
        end
            
        function extracted_features = GetEventFeatures(self)
            extracted_features = [];
        end
        
        function signal = get_signal(self,times, varargin)
            if nargin > 2
                type = varargin{1};
                if strcmp(type,'SigFeature')
                    type = 'SigDetect';     % Haowen's class does not have a SigFeature;
                end
            else
                type = 'SigDetect';
            end
            sig_ch = getfield(self,type);
            signal=sig_ch.get_signal(times);
        end
        
        function call_array = GetCalls(self,param)
            % IPI_th: in sec, threshold for inter-phrase interval, or
            % maximum gap between phrases

            if isnumeric(param)    % this is to accommodate older code used in Neural analysis & SocialLogSource
                IPI_th = param;
                clear param
                param.IPI_th = IPI_th;
                param.Phrase2Call_Rule = 'Neural_zly';
            else
                IPI_th = param.IPI_th;
            end
          
            % Retrieve all phrases and sort them in time order
            call_array = [];
            phrases = self.GetEvents('Subjects',self.Subjects,'eventClass','Phrase');
%             self = self.
            ind = 1;
            for i = 2:length(phrases)
                if phrases(i).eventStartTime - phrases(i-1).eventStopTime < IPI_th
                    ind = [ind,i];
                else
                    call_this = social.event.Call(phrases(ind),param);
                    call_array = [call_array; call_this];
                    ind = i;
                end
            end
            % add the last call
            if ~isempty(phrases)
                call_this = social.event.Call(phrases(ind),param);
            else
                call_this = [];
            end
            call_array = [call_array; call_this];
        end
    end
    
end

