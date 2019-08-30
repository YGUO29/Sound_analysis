classdef ColonyParabolicChannel < social.interface.Behavior & social.interface.AnalogSignal
    %COLONYPARABOLICCHANNEL 
    % Parabolic Mic vs. Ref mic
    % ColonyParabolicChannel(Session,SubjectID,SigDetect,SigRef,SigFeature,IsProcessed)

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
                self.Session            =   Session;
                self.Subjects           =   SubjectID;
                self.SigDetect          =   SigDetect;
                self.SigRef             =   SigRef;
                self.SigFeature         =   SigFeature;
                self.IsProcessed        =   IsProcessed;
                self.SpecDiffThreshold  =   2;  % default value
                self.BehName            =   'Parabolic';
                self.ID                 =   ['Par_' self.Subjects];
                self.SampleRate         =   self.SigFeature.SampleRate;
            end
        end

       % ---------original funtion---------        
        function detected_events = DetectEvents(self)
            fprintf(['Detecting events from ' self.ID ' for signal ' self.SigDetect.ID ' referenced to ' self.SigRef.ID '.\n']);
            DetectionParam.MinVocDuration = 0.05;   
            DetectionParam.GapCheckThreshold = 0.1;
            DetectionParam.MinGapInterval = 0.05;
            
            detected_events = social.processing.call_detect_parabolic(self,DetectionParam);
            
%             self.Events = [self.Events detected_events];
%             self.nEvents=length(self.Events);
            
            fprintf(['Found ' num2str(length(detected_events)) ' events.\n'])

            self.IsProcessed = 1;
        end
        
        
        function extracted_features = GetEventFeatures(self)
            extracted_features = [];
        end
        
        function signal = get_signal(self,times, varargin)
            if nargin > 2
                type = varargin{1};
            else
                type = 'SigFeature';
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

