classdef StandardVocalSignal < social.interface.AnalogSignal
    % StandardVocalSignal is a wrapper for interacting with vocalization 
    % wav files recorded with DAQ_Record or mvx.  To construct and object,
    % call social.interface.StandardVocalSignal(file,name,ch).
    % 
    % TODO:
    %   
    %   Written by Seth Koehler
    properties
        Header      % Returned from audioinfo
        Channel     % Channel in referenced file.
        Mic         % MicType object describing mic.
        gain = 0;
        gain_spec = [];
        %SampleRate  % DECLARED IN social.interface.AnalogSignal
        %DECLARED
        %Session
        %ID            % Unique identifier for the transducer/signal
        %SyncTime = 0;   % Stored in seconds from onset of session.

    end 
    methods
        function self = StandardVocalSignal(session,file,name,ch)
            if nargin > 0 & ~isempty(file) & ~isempty(name) & ~isempty(ch)
            % Read in file names
            [p,f,e]=fileparts(file);
            self.File=file;
            self.ID=[name];
%             self.ID=[session.ID '-' name];
            self.Channel=ch;
            self.Session=session;
            
            % Read in audiofile info
            self.Header=audioinfo(self.File);
            self.SampleRate=self.Header.SampleRate;
            self.TotalSamples=self.Header.TotalSamples;
            
            % Assign channel numbers
            self.Channel = ch;
            
            % Default MicType to 
            self.Mic=MicType.Standard;
            end
        end
%         function 
        function [sig] = get_signal(self,times)
        % Output a cell array of signals for a given nx1 (Start) or nx2 (Start and Stop) times
        % array.  Times must be supplied in seconds relative to SyncTime.
            if isempty(times)
                samples=[1 self.Header.TotalSamples];
            else
                samples=self.times2samples(self.TimeSynchronizer(times));
            end
            
            % Error check, force any sample number > max sample number to
            % be equal to max sample number.
            samples(samples>self.Header.TotalSamples)=self.Header.TotalSamples;
            
            for i=1:size(samples,1)
                sig{i}=audioread(self.File,samples(i,:));
                sig{i}=sig{i}(:,self.Channel);
            end
        end
        
        function calculate_gain(self,param)
        % calculatet the gain of this signal
            band = param.vocBandP;
            sig = self.get_signal([0,50]);
            [spec, ~, ~] = social.vad.tools.spectra(sig{1}, param.specWinSize, param.specShift, param.Fs, 0);
            self.gain_spec = medfilt1(mean(spec,2),21);
            self.gain = mean(self.gain_spec(band(1):band(2)));
            
            
        end
       
        
        function sound(self,times)
            % TODO: play out requested times through the sound card.
            sig=self.get_signal(times);
            for i=1:length(sig)
                sound(sig{i},self.SampleRate);
                pause(0.5);
            end
        end
        function tab = Tabulate(self)
            5
        end
        function tab = Report(self)
        end
    end
%     methods (Static, Sealed, Access = protected)
%         function default_object = getDefaultScalarElement
%             default_object = StandardVocalSignal;
%         end
%     end
end