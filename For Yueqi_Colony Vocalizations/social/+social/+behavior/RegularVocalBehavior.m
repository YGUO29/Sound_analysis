classdef RegularVocalBehavior < social.interface.Behavior & social.interface.AnalogSignal
    % RegularVocalBehavior 
    % Single microphone channel behavior
    % RegularVocalBehavior(Session,SubjectID,SigDetect,SigFeature,IsProcessed)
    
    properties
        SigDetect =nan;
        SigFeature = nan;
        EnergyThreshold = 200;      % threshold for detection
        harmaParams = [];
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
        function self = RegularVocalBehavior(Session,SubjectID,SigDetect,SigFeature,IsProcessed)
%              self@social.interface.Behavior;
            if nargin >0
                self.Session=Session;
                self.Subjects = SubjectID;
                self.SigDetect = SigDetect;
                self.SigFeature= SigFeature;
                self.IsProcessed= IsProcessed;
                self.ID=['Voc_' self.Subjects];
%                 self.ID=[self.SigDetect.ID '-' self.Subjects];
                self.SampleRate = self.SigFeature.SampleRate;
                %                 self.MinVocDuration = min_dur;
                %                 self.GapCheckThreshold = gap_th;
                harmaParams.FBAND=[4000 10000];
                harmaParams.window  = 0.025; % seconds
                harmaParams.overlap = 0.015; % seconds
                harmaParams.Fstep = 200;
                harmaParams.NFFT = [harmaParams.FBAND(1).*2.^(0:0.01:2)];
                harmaParams.NFFT(harmaParams.NFFT>harmaParams.FBAND(2))=[];
                % Convert parameters to samples
                harmaParams.Nwindow=harmaParams.window.*self.SampleRate;
                harmaParams.Noverlap=harmaParams.overlap.*self.SampleRate;
                % NFFT=64;
                harmaParams.dBStop=15;
                harmaParams.cutoff=3;
                self.harmaParams=harmaParams;
            end
        end
        
        function detected_events = DetectEvents(self)
            fprintf(['Detecting events from ' self.ID ' for signal ' self.SigDetect.ID '.\n']);
%             DetectionParam.MinVocDuration = 0.05;
%             DetectionParam.GapCheckThreshold = 0.1;
%             DetectionParam.MinGapInterval = 0.05;
            signal=self.get_signal([]);
            signal=signal{1};
%             detected_events = social.processing.call_detect_single_channel(self,self.EnergyThreshold);
            [syllables,Fs,S,F,T,P]=social.analysis.harmaSyllableSeg(...
                signal,...
                self.SampleRate,...
                self.harmaParams.Nwindow,...
                self.harmaParams.Noverlap,...
                self.harmaParams.NFFT,...
                self.harmaParams.dBStop,...
                self.harmaParams.FBAND,...
                self.harmaParams.cutoff);
            %             self.Events = [self.Events detected_events];
            %             self.nEvents=length(self.Events);
            for i=1:length(syllables)
                detected_events(i)=social.event.Phrase(self.Session,self,min(syllables(i).times),max(syllables(i).times));
            end
            self.Events=self.Session.sort_events(detected_events);
            self.nEvents=length(self.Events);
            self.eventMinGap(0.3);

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

