classdef StandardSession < social.interface.Session
    %SessionLog - The StandardSessionLog stores all information related to 
    % a standard vocalization recording session, typically including a 
    % target and reference microphone. A StandardSessionLog may include
    % neurophysiology data recorded with nvr, DAQ_Record, MANTA, or MCS.
    %   
    % Written by Seth Koehler and Lingyun Zhao, 3/2015.
    
    properties %(Access = protected)
         Headers         % Must contain one or more SessionLogFile objects.
         Signals         % An array of signal objects, can include both raw and computed signals.
         Behaviors       % An array of behavior objects, enumerates exp defined behaviors based on one or more recorded signals
    end
    
    properties %(Access = protected)
         ID ='';             %
         Subjects='';        % An array of subject IDs, always in the form M*.
         Experimenter='';    % Experimenter's name
         Experiment='';      % Experiment name/type
         Environment='';     % Recording location
         SyncTime=[];        % Identifies the session time to which all events are referenced.
         Time='';            % Absolute time and date of beginning and end of session.
    end
    
    properties 
        %%
        % |MONOSPACED TEXT|    end
    end
    
    methods
        % Construct a SessionLog object.
        function self=StandardSession(filename)
            % Construct StandardSession object given relative path and
            % filename of a digivoc style *.hdr file written by mvx and
            % DAQ_record.
            if nargin==0
                return;
            end
            % Load first header
            self.Headers=social.session.SessionFile(filename);
            
            % Find related headers
            
            % Determine SessionID
            %TODO Figure out best way to format sessionIDs.  For now, use
            %M##S###.
            temp=strsplit(self.Headers.Header.animal,'_');
            if temp{1}(1)~='M'
                temp{1}=['M' temp{1}];
            end
%             self.SessionID=[temp{1} '_S' num2str(self.Headers.Header.session)];
            %For now, stick with the recorded filename.
            [p,f,e]=fileparts(self.Headers.File);
            self.ID=f;

            % Find related microphone signal files
            % Assume that they are stored in the first set of channels.
            ch_set=1;
            [p,f,e]=fileparts(self.Headers.File);
            filename=fullfile(p,[f '.wav']);
            for i=1:self.Headers.Header.nch(ch_set)
                temp_hdr=self.Headers.Header.ch{ch_set}{self.Headers.Header.chlist{ch_set}(i)};              
                % if animal name is not available for each channel, specify
                % by microphone number
                if isprop(temp_hdr,'animal')
                    self.Signals{i}=social.signal.StandardVocalSignal(self,filename,['mic_' temp_hdr.animal],i);
                else
                    self.Signals{i}=social.signal.StandardVocalSignal(self,filename,['mic_' num2str(i)],i);
                end
            end
            self.Signals=[self.Signals{:}];
            
            % initialize BehChannels
%             self.BehChannels = social.channel.RegularVocalChannel;
        end
        

    end
end

