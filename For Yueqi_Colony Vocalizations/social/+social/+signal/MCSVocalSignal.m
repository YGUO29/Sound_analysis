classdef MCSVocalSignal < social.interface.AnalogSignal
    % StandardVocalSignal is a wrapper for interacting with vocalization
    % audio recordings stored in MCS hd5 files.  To construct an object,
    % call social.interface.StandardVocalSignal(file,name,ch).
    %
    % session - leave empty for a signal not associated with a session
    % file -
    % name -
    % ch -
    % TODO:
    %
    %   Written by Seth Koehler
    properties
        Header      % Returned from audioinfo
        Channel     % Channel in referenced file.
        Mic         % MicType object describing mic.
        %SampleRate  % DECLARED IN social.interface.AnalogSignal
        %DECLARED
        %Session
        %ID            % Unique identifier for the transducer/signal
        %SyncTime = 0;   % Stored in seconds from onset of session.
    end
    properties (Transient=true)
        AnalogRecording
    end
    methods
        function self = MCSVocalSignal(session,file,name,ch)
            if nargin > 0 & ~isempty(file) & ~isempty(name) & ~isempty(ch)
                
                % Read in file names
                [p,f,e]=fileparts(file);
                self.File=file;
                self.Channel=ch;
                self.Session=session;
%                 if ~isempty(session)
%                     self.ID=[session.ID '-' name];
%                 else
                    self.ID=name;
%                 end
                
                % Assign channel numbers
                self.Channel = ch;
                % Default MicType to
                self.Mic=MicType.Standard;
                
                % Read in MCS HDF5 data file using the H5DataFile object from
                % the mcs/xbz package written by SDK.
                self.Header=social.session.MCRackSessionFile(file);
                
                %Figure out which of the mcs recordings contains the analog
                %channel data.
                data=McsHDF5.McsData(self.File);
                self.AnalogRecording=data.Recording{1}.AnalogStream{self.Header.Header.anlg0001{2}};
                
                % Extract the MCS recording for the selected channel
                cfg.channel = [self.Channel self.Channel];
                self.AnalogRecording=self.AnalogRecording.readPartialChannelData(cfg);
                
                % Find sample rate.  MCS stores sample rates as microseconds
                % per tick.
                self.SampleRate=self.AnalogRecording.getSamplingRate;
                self.TotalSamples=size(self.AnalogRecording.ChannelData,2);
%                             self.AnalogRecording=[];
            end
        end
        %         function
        function [sig] = get_signal(self,times)
            % Output a cell array of signals for a given nx1 (Start) or nx2 (Start and Stop) times
            % array.  Times must be supplied in seconds relative to SyncTime.
            % Each signal will be a 1 x nsamples array of signal values.
            
            % If object is new, and analogrecording object has not yet been
            % loaded, then load it.
            if isempty(self.AnalogRecording);
                %Figure out which of the mcs recordings contains the analog
                %channel data.
                data=McsHDF5.McsData(self.File);
                self.AnalogRecording=data.Recording{1}.AnalogStream{self.Header.Header.anlg0001{2}};
                
                % Extract the MCS recording for the selected channel
                cfg.channel = [self.Channel self.Channel];
                self.AnalogRecording=self.AnalogRecording.readPartialChannelData(cfg);
            end
            
            if isempty(times)
                samples=[1 self.TotalSamples];
            else
                samples=self.times2samples(self.TimeSynchronizer(times));
            end
            
            % Error check, force any sample number > max sample number to
            % be equal to max sample number.
            samples(samples>size(self.AnalogRecording.ChannelData,2))=size(self.AnalogRecording.ChannelData,2);
            
            sf=10^double(self.AnalogRecording.Info.Exponent);
            
            for i=1:size(samples,1)
                sig{i}=sf.*self.AnalogRecording.ChannelData(samples(i,1):samples(i,2))';
            end
            
%             self.AnalogRecording=[];
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