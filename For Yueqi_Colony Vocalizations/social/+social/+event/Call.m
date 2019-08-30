classdef Call < social.interface.Event
    % Event interface defines methods and properties that events must have.
    % An event must have a start time, a stop time, and a sync time (all in
    % seconds relative to the event sync time). Events subclass
    % dynamicprops to allow addition or removal of properties.
    
    properties
        eventPhrases
        eventCallType = '';       % call type for single or compound calls, e.g. Phee or Mixed
        nPhrases            % number of phrases
        IPI_threshold       % threshold for inter-phrase interval used to determine compound calls
        
        % eventF0
        % eventPower
        % DECLARED IN social.signal.StandardVocalSignal
        %Header      % Returned from audioinfo
        %Channel     % Channel in referenced file.
        %Mic         % MicType object describing mic.
        %SampleRate  % DECLARED IN social.interface.AnalogSignal

    end
    
    methods
        function self = Call(phrases,param,varargin)
            % phrases is an array of Phrases
            session = phrases(1).Session;
            behavior = phrases(1).Behavior;
            start = min([phrases.eventStartTime]);
            stop = max([phrases.eventStopTime]);
            self=self@social.interface.Event(session,behavior,start,stop,varargin);
            
            
            self.eventPhrases=phrases;
            self.nPhrases = length(phrases);
            self.eventCallType = lower(self.eventPhrases(1).eventPhraseType);
            self.eventCallType(1) = upper(self.eventCallType(1));
            for i = 2:self.nPhrases
                % check to see if all phrases have the same PhraseType
                if ~strcmpi(self.eventPhrases(i).eventPhraseType,self.eventCallType)
                    self.eventCallType = 'Mixed';
                    break
                end
            end
            
            if strcmpi(param.Phrase2Call_Rule ,'Neural_zly')
                if self.nPhrases >= 3 
                    IsTwitter = 1;
                    for i = 2:self.nPhrases - 1
                        if ~strcmpi(phrases(i).eventPhraseType,'Twitter')
                            IsTwitter = 0;
                            break
                        end
                    end
                    if IsTwitter
                        self.eventCallType = 'Twitter';
                    end
                end
            end
            
            self.IPI_threshold = param.IPI_th;
            
            
            % To allow easy filtering of events in Heterogenous event
            % arrays, set the eventType property to a string corresponding
            % to the name of the class.
            self.eventClass='Call';
            self.get_features;
        end
        function sig=get_signal(self,varargin)
            
            times=[self.eventStartTime self.eventStopTime];
            if nargin > 1
                type = varargin{1};
                sig = self.Behavior.get_signal(times,type);
            else
                sig = self.Behavior.get_signal(times);
            end
            
        end
        
        function feature = get_features(self,varargin)
            % check session notes
            out = social.analysis.CheckSessionConfig(self.Behavior);
            denoise = out.VocalFeatureDenoise;
            
            
            p=inputParser;
            p.addOptional('Denoise',0);
            p.addOptional('Plot','off');
            p.parse(varargin{:})
            if ~ismember('Denoise',p.UsingDefaults)
                denoise=p.Results.Denoise;
            end
            plot_en=p.Results.Plot;

            if strcmpi(self.eventCallType,'Twitter')
                % calculate Twitter features
                social.analysis.ParamFeature;
                type='twit';
                
                % for now, don't read wav file for detailed features
%                 feature = social.analysis.calculate_vocal_features(self,type, denoise,plot_en);
                
            else
                % check each phrase, gather or calculate phrase features
                fcontour = [];
%                 ph_feature = [];
                
                for i = 1:length(self.eventPhrases)
                    if ~isfield(self.eventPhrases(i).eventParam,'Feature')
                        self.eventPhrases(i).get_features('Denoise',denoise);
                    end
                    
                    if isempty(self.eventPhrases(i).eventParam.Feature)
                        break
                    end
                    
                    if strcmpi(self.eventCallType,'Mixed')
                        ph_feature(i).fmax = self.eventPhrases(i).eventParam.Feature.fmax;
                        ph_feature(i).fmin = self.eventPhrases(i).eventParam.Feature.fmin;
                        ph_feature(i).fstart = self.eventPhrases(i).eventParam.Feature.fstart;
                        ph_feature(i).fend = self.eventPhrases(i).eventParam.Feature.fend;
                        ph_feature(i).contour = self.eventPhrases(i).eventParam.Feature.contour;
                    else
                        ph_feature(i) = self.eventPhrases(i).eventParam.Feature;
                    end
                    fcontour = [fcontour;ph_feature(i).contour.freq];
                end
                
                % calculate average across phrases here
                if exist('ph_feature')
                    feature.fmax = max([ph_feature.fmax]);
                    feature.fmin = min([ph_feature.fmin]);
                    feature.fc = (feature.fmax+feature.fmin)/2;         
                    feature.fmean = trimmean(fcontour,10);
                    feature.fstart = ph_feature(1).fstart;
                    feature.fend = ph_feature(end).fend;

                    % define bandwidth using a averaged fmax, fmin from
                    % top/bottom 5% of frequency data
                    f_top = quantile(fcontour,0.95);
                    f_bottom = quantile(fcontour,0.05);

                    feature.BW = mean(fcontour(fcontour>=f_top)) - mean(fcontour(fcontour<=f_bottom));

                    if ismember(lower(self.eventCallType), {'trill','trillphee'})
                        if isfield(ph_feature,'FMrate')
                            feature.FMdepth_max = max([ph_feature.FMdepth_max]);
                            feature.FMdepth_min = min([ph_feature.FMdepth_min]);
                            feature.FMdepth = mean([ph_feature.FMdepth]);
                            feature.FMrate = mean([ph_feature.FMrate]);

                        else
                            feature.FMdepth_max = NaN;
                            feature.FMdepth_min = NaN;
                            feature.FMdepth = NaN;
                            feature.FMrate = NaN;

                        end
                        feature.phase_start = ph_feature(1).contour.phase(1);
                    end
                    if strcmpi(self.eventCallType,'Trillphee')
                        feature.tTrans = mean([ph_feature.tTrans]);
                    end
                end

            end
            
            feature.nPhrases = self.nPhrases;
            feature.dur = self.eventStopTime - self.eventStartTime;
            for i = 1:self.nPhrases
                dur_p(i) = self.eventPhrases(i).eventStopTime - self.eventPhrases(i).eventStartTime;
                if i < self.nPhrases
                    IPI_p(i) = self.eventPhrases(i+1).eventStartTime - self.eventPhrases(i).eventStopTime;
                end
            end
            feature.dur_phrase = mean(dur_p);
            if self.nPhrases == 1
                feature.IPI = NaN;
            else
                feature.IPI = mean(IPI_p);
            end
            
            self.eventParam.Feature = feature;
        end


% TODO: Other things to consider.
% function SaveEvent(filename)
%             save(filename,self);
%         end
%         
%         function LoadEvent
%         end
%         
%         function ReturnEventID
%         end
%             
    end
end

