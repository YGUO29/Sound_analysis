classdef RackSession < social.interface.Session
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
    
    methods
        % Construct a SessionLog object.
        function self=RackSession(filenames)
            % Construct StandardSession object given relative path and
            % filenames of related *.hdr files from mvx/DAQ_Record and 
            % *.h5 hdf4 container files exported from an *.mcd file.
            
            if nargin==0
                return;
            elseif isempty(filenames)
                [filenames pathname]=uigetfile({'*.h5;*.hdr'},'Select one or more header files:','C:\data\','MultiSelect','on');
                if isa(filenames,'double')
                    return;
                end
                for i=1:length(filenames)
                    filenames{i}=[pathname filenames{i}];
                end
            elseif ischar(filenames)
                filenames={filenames};
            end
            
            % Load headers
            for i=1:length(filenames)
                [p,~,e]=fileparts(filenames{i});
                switch e
                    case '.h5'
                        temp(i)=social.session.MCRackSessionFile([filenames{i}]);
                        self.Subjects=temp(i).Header.Subject;
                    case '.hdr'
                        temp(i)=social.session.SessionFile([filenames{i}]);
                end
            end
            
            self.Headers=temp;
            clear temp;
            
            % Determine SessionID
            % TODO Figure out best way to format sessionIDs.  For now, use
            % M##S###.
            % self.SessionID=[temp{1} '_S' num2str(self.Headers.Header.session)];
            % For now, stick with the recorded filename.
            for i=1:length(self.Headers)
                ind.mvx(i)=(isfield(self.Headers(i).Header,'fname'));
                ind.h5(i)=isfield(self.Headers(i).Header,'FileType')&&strcmp(self.Headers(i).Header.FileType,'h5');
            end
            % ind are logical arrays for headers identifying whether a
            % header is mvx or h5.
            if any(ind.h5)
                [~,f,~]=fileparts(self.Headers((ind.h5)).File);
            elseif any(ind.mvx)
                [~,f,~]=fileparts(self.Headers((ind.mvx)).File);
            else
                f=[];
            end
            self.ID=f;
            ind.mvx=find(ind.mvx);
            ind.h5=find(ind.h5);


            % Find related microphone signal files from mvx/DAQ_Record
            % header  Assume that they are stored in the first set of channels.
            ch_set=1;
            for k= 1:length(ind.mvx)
                [p,f,e]=fileparts(self.Headers(ind.mvx(k)).File);
                filename=fullfile(p,[f '.wav']);
                self.Signals=[];
                % Loop over each channel and create a signal
                for i=1:self.Headers(ind.mvx).Header.nch(ch_set)
                    temp_hdr=self.Headers(ind.mvx(k)).Header.ch{ch_set}{self.Headers(ind.mvx(k)).Header.chlist{ch_set}(i)};
                    % if animal name is not available for each channel, specify
                    % by microphone number
                    if isprop(temp_hdr,'animal')
                        temp{i}=social.signal.StandardVocalSignal(self,filename,['mic_' temp_hdr.animal],i);
                    else
                        temp{i}=social.signal.StandardVocalSignal(self,filename,['mic_' num2str(i)],i);
                    end
                end
            self.Signals=[self.Signals temp{:}]; clear temp;
            end
            
            % Find microphone signals from h5 header files and add to
            % signal array.
            for k=1:length(ind.h5)
                for i=1:self.Headers(ind.h5(k)).Header.anlg0001{3}
                    temp{i}=social.signal.MCSVocalSignal(self,self.Headers(ind.h5(k)).File,['mcs_mic_' num2str(i)],i);
                end
                self.Signals=[self.Signals temp{:}]; clear temp;
            end
            
            % initialize BehChannels
%             self.BehChannels = social.channel.RegularVocalChannel;
        end
        function Export2Wav(self,normchannels)
            header=self.Headers(ismember('.h5',{self.Headers.Extension}))
            [p,n,e]=fileparts(header.File);
            newdir=[p filesep n filesep];
            mkdir(newdir);
            targetStrm=header.Header.filt0004{2}
            scalefactor=4.522374267285146e+02;
            mcs.utils.HDF5_Wav(header.File,[newdir n '.wav'],[1:32],targetStrm,scalefactor)
        end
    end
end

