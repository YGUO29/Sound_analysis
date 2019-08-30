classdef Phrase < social.interface.Event
    % Event interface defines methods and properties that events must have.
    % An event must have a start time, a stop time, and a sync time (all in
    % seconds relative to the event sync time). Events subclass
    % dynamicprops to allow addition or removal of properties.
    %
    % Phrase(session,behavior,start,stop,sync) constructs a Phrase from the
    % given session and behavior objects with the given values for start
    % time, stop time, and sync time.
    
    properties
        eventF0=nan;
        eventPower=nan;
        eventPhraseType='';
        % DECLARED IN social.signal.StandardVocalSignal
        %Header      % Returned from audioinfo
        %Channel     % Channel in referenced file.
        %Mic         % MicType object describing mic.
        %SampleRate  % DECLARED IN social.interface.AnalogSignal

    end
    
    methods
        function self = Phrase(varargin)
                % Construct an analog event using
                % Event(source_signal,start,stop[,sync,propstruct])
                p=inputParser;
                p.addOptional('session',[]);
                p.addOptional('behavior',[]);
                p.addOptional('start',[]);
                p.addOptional('stop',[]);
                p.addOptional('sync',0);
                p.parse(varargin{:})
                session=p.Results.session;
                behavior=p.Results.behavior;
                start=p.Results.start; 
                stop=p.Results.stop;
                sync=p.Results.sync;
                
% %                 % If phrase is longer that 10 seconds, there's something wrong.
% %                 %  Throw it out by returning self=NaN;
% %                 if (stop-start)>10
% %                     stop=[];
% %                     start=[];
% %                 end
                
                self=self@social.interface.Event(session,behavior,start,stop,varargin);
                % Get phrase properties
                %             self.eventPower=self.get_f0;
                %             self.eventF0=self.get_power;
                
                % To allow easy filtering of events in Heterogenous event
                % arrays, set the eventType property to a string corresponding
                % to the name of the class.
                if nargin>0
                    self.eventClass='Phrase';
                else
                    self.eventClass='Empty';
                end
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
        function f0data=get_f0(self)
            try
                sig=cell2mat(self.get_signal);
                f0data=social.analysis.GetPheeF0(sig,self.Behavior.SigFeature.SampleRate);
            catch
                f0data.time=[];
                f0data.f0=[];
                f0data.energy=[];
            end
        end
        function powerdata=get_power(self)
            try
                sig=cell2mat(self.get_signal);
                powerdata=social.analysis.GetPheePower(sig,self.SampleRate);
            catch
                powerdata.time=[];
                powerdata.power=[];
            end
        end
        function feature=get_features(self,varargin)
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
                
            
            
            ph_type = lower(self.eventPhraseType);
            switch ph_type
                case 'twitter'
                    type='other';
%                     type='twit';
                case 'trill'
                    type='tril';
                case 'trillphee'
                    type='trph';
                case 'phee'
                    type='phee';
                otherwise
                    type = 'other';
                    
            end
            feature = social.analysis.calculate_vocal_features(self,type, denoise,plot_en);
            self.eventParam.Feature = feature;
        end
        
        
        
        function freq = get_freq_domi(self)
            win_sm_freq = 500;      % in Hz, smooth window size
            ignore_band = 2000;     % ignore below this frequency
            
            sig = self.get_signal('SigFeature');
            
            win = window('hann',length(sig{1}));
            fw = abs(fft(sig{1}.*win));
            
            % smooth it
            Fs = self.Behavior.SigDetect.SampleRate;
            
            win_sm_len = round(win_sm_freq/(Fs/length(sig{1})));
            
            win_sm = window(@gausswin,win_sm_len);
            fw = filtfilt(win_sm,1,fw);
            
            
            ind_ignore = round(ignore_band/(Fs/length(sig{1})));
            fw = fw(1:round(length(fw)/2));
            fw(1:ind_ignore) = 0;
            [~,ind] = max(fw);
            freq = (ind-1)*(Fs/length(sig{1}));
            
            
            self.eventParam.FreqDomi = freq;
            
        end
        
        function tab=Tabulate(self);
            warning('off');
            rem_fields={'Behavior','Session','PreviousInstance__'};
            for i=1:length(self)
                % Convert object to struct
                tab{i}=struct(self(i));
                tab{i}=rmfield(tab{i},rem_fields(ismember(rem_fields,fieldnames(tab{i}))));
                tab{i}.Behavior=self(i);
                
                % Standardize any empty values, convert character fields to
                % categorical.
                fields=fieldnames(tab{i});
                for j=1:length(fields)
                    switch class(tab{i}.(fields{j}))
                        case 'char'
                            tab{i}.(fields{j})=categorical(cellstr(tab{i}.(fields{j})));
                        case 'double'
                            if isempty(tab{i}.(fields{j}))
                                tab{i}.(fields{j})=nan;
                            end
                    end
                end
                tab{i}=struct2table(tab{i});
            end
            if length(self)>0
                tab=cat(1,tab{:});
            else
                tab=[];
            end
            warning('on');
        end
        
%         function value = get.eventF0(self)
%             value=self.get_f0;
%         end
%         function value = get.eventPower(self);
%             value=self.get_power;
%         end

        %%% Set eventStartTime and eventStopTime methods
%         function set.eventStartTime(self,value)
% %             if value~=self.eventStartTime
%                 self.eventStartTime=value;
%                 self.eventPower=self.get_f0;
%                 self.eventF0=self.get_power;
% %             end
%         end
%         function set.eventStopTime(self,value)
% %             if value~=self.eventStartTime
%                 self.eventStopTime=value;
%                 self.eventPower=self.get_f0;
%                 self.eventF0=self.get_power;
% %             end
%         end

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
%     methods(Sealed=true)
%         function varargout = findobj(self,varargin)
% %             if nargout == 0
% %                 builtin('findobj',varargin{:});
% %             else
%                 varargout{:} = builtin('findobj',self,varargin{:});
% %             end
%         end
%     end

end

