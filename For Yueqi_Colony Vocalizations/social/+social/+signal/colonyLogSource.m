classdef colonyLogSource < xbz.log.source.LogSource & ...
        xbz.component.Component
    %Initial draft of log source for vocal colony and general vocal interaction experiments. Requires 
    %three log files: the header file created by mvx, the Phee_Info file created
    %by phee_detect, PheeBrowser, and phee_feature, and the voc_MID_S##n_spk.mat
    %file created by sync_spike_timing.m. 
    
    properties
        Path % Path e.g. D:\Data\MID\
        FileName % Header file name including relative path \path\voc_31W\voc_31W_s#.hdr
        Header
        SpikeFileName
        SpikeData
        PheeData
        Properties
    end
    
    methods
        %%%%%%%%%%%%%% colonyLogSource Methods
        function self = colonyLogSource(file)
            %LOGSOURCE constructor
            % figure out filename
            [self.Path, name, ext] = fileparts(file);
            self.Path = [self.Path '\'];
            self.FileName = [name];
            
            % read header file
            self.Header = self.get_header_data([self.Path self.FileName '.hdr']);
            
            % Read spike data
            self.SpikeFileName=[self.FileName 'n_spk.mat'];
            self.SpikeData=load([self.Path self.SpikeFileName]);
            self.SpikeData=self.SpikeData.spiketime_sync;
            
            % Read phee data
            self.PheeData=load([self.Path 'PheeInfo_' self.FileName '.mat']);
            %
            self.Properties = self.build_properties();
            %             self.TimeWindowSupplier = self.build_time_window_supplier();
        end
    
        
        function id = get_available_data_id (self)
            %Returns a n*1 vector of ID values (e.g., trial numbers)
            %   vector of trial numbers (1:nTrials)'
            % at some point, this needs to handle the difference between
            % phrases and calls.
            n = size(self.PheeData.Phrases,1);
            id = (1:n)';
        end
        function log = get_data_log (self) %#ok<*MANU>
            %Returns a structure with the entire log as a structure so 
            %logbrowser can display it
            log = struct();
        end
        function tag_struct = get_tags (self)
            %Should return a scalar structure. 
            %Used for exporting to Evernote
            tag_struct = struct();
        end
        function s = get_summary_struct (self)
            %Returns a struct
            s = struct();
        end
        function src = find_adjacent_source (self, mode)
            %mode can be 'next', 'previous'
            %returns filename
            src = '';
        end
        function install_property_auto_selector_functions (self, as) 
            %as is a xbz.log.property.PropertyAutoSelector
        end
        function props = find_varying_properties (self, props, id)
            %PROPS = self.find_varying_properties()
            %PROPS = self.find_varying_properties(TRIALPROPS, TRIAL_ID)
            %PROPS = self.find_varying_properties(RUNPROPS, RUN_ID)
            if nargin<2
                props = self.get_properties();
            end
            if nargin<3
                id = self.get_available_data_id();
            end
            props = props.find_varying(id);
        end
        
        %%%%%%%%%%%%%% SPIKEDATASUPPLIER methods
        %Returns the number of available spike channels
        function n = get_num_spike_channels (self)
            n=length(self.Header.SpikeChannels);
        end
        
        %For scalar channel #, and n*1 vector of IDs, should return a
        %n*1 cell array, where each cell is a column vector of spike
        %times, in ms.
        function spike_data = get_spike_data (self, channel, id)
            % Initialize ts cell array
            ts=cell(length(id),1);
            
            % Figure out which channel to read timestamps from
            [Lia, Locb]=ismember(channel,self.Header.SpikeChannels)
            
            % Read timestamps
            ts_raw=self.SpikeData{Locb};
            ts_raw=reshape(ts_raw,numel(ts_raw),1);
            for j=id'
                ts{j}=1000.*(ts_raw-self.PheeData.Phrases.Time(j));
            end
            spike_data=ts;
        end
        
        function beh_event_data = get_beh_event_data(self, channel, id, beh_event)
            % these are hard coded for now to pull out the call duration
            phrase_table = self.PheeData.Phrases;
            
            
        end
        
        % Returns header information
        function hdr = get_header_data(self,filename)
            fid = fopen(filename);
            i = 0;
            temp = cell(1, 100); %Hazard a guess as to size
            str = 'a';
            while str~=-1
                i = i + 1;
                str = fgetl(fid);
                temp{i} = str;
            end
            temp = temp(2:i-1); %Discard function header & closer
            
            % parse hdr cell array
            for j=1:6
                str=regexp(temp{j},' = ','split');
                str{1}(isspace(str{1}))='';
                str2num(str{2});
                if ~isempty(str2num(str{2}))
                    hdr.(str{1})=deblank(str{2});
                else
                    hdr.(str{1})=num2str(deblank(str{2}));
                end
            end
            % Read number of audio and spike channels
            a=sscanf(temp{7}, '%*s %*s %d %*s %d');
            hdr.AudioChannels=nan(1,a(1));
            hdr.SpikeChannels=nan(1,a(2));
            
            % Read channel numbers for audio and neural channels.
            for j=1:length(hdr.AudioChannels)
                hdr.AudioChannels(1,j)=sscanf(temp{7+j}, '%*s %*d/%d');
            end
            for j=1:length(hdr.SpikeChannels)
                hdr.SpikeChannels(1,j)=sscanf(temp{7+length(hdr.AudioChannels)+j}, '%*s %*d/%d');
            end
        end
        
        %%%%%%%%%%%%%% TIMEWINDOWSUPPLIER methods
        %Returns a two element vector of available time ranges
        function time_window = get_available_data_time_window (self, id)
            time_window = [-3000 5000];
        end
        
        %Returns a two element vector, or a string representation thereof
        function tw = get_default_analysis_time_window (self)
            tw = [0 1500];
        end
        
        %Returns a two element vector, or a string representation thereof.
        %Used for e.g. spontaneous rates
        function tw = get_default_baseline_time_window (self)
            tw = [-500 0];
        end
        
        function formatter = get_time_axis_formatter (self) %#ok<MANU>
            %should return a xbz.plots.util.TimeAxisFormatter
            formatter = chX.MultiStimTimeAxisFormatter(self);
        end
        function tw_out = parse_time_window_str (self, id, tw_in)   %#ok<INUSD,STOUT>
            %ID is a cell array of vectors of IDs
            %TW_IN is a length(ID)*1 cell array
            %TW_IN{i} is a length(ID{i}) cell array of strings
            %Each cell represents a 1*2 numeric time window vector,
            %but may include strings like e.g. 'stim_onset'
            
            %For now, ignore tw_in.  Return phee_time offset and onset for
            %each phrase.
            time_arr = self.PheeData.Phrases.Time-repmat(self.PheeData.Phrases.Time(:,1),1,2);
            for j=1:length(id)
                tw_out{j} = [min(time_arr(id{j},1)) max(time_arr(id{j},2))];
            end
            
            
%             error('xbz:log:badtimewindow',...
%                 'Log source doesn''t support dynamic time windows');
        end
        
        %%%%%%%%%%%%%% PROPERTYSUPPLIER methods
        
        %%%%%%%%%%%%%% ANALOGATASUPPLIER methods
        %Set stubs to return that no analog data is available.
        %Returns the number of available analog channels
        function n = get_num_analog_channels (self)
            n=0;
        end
        
        %Returns the sampling rate for the supplied channel
        function sr = get_analog_channel_sampling_rate (self, channel)
            sr = 20000;
        end
        
        %For ID vector of length n, should return a n*1 cell array, each
        %cell a column vector of analog data. Second output argument t0 is
        %a n*1 vector of times of the first sample for each analog data
        %vector. This will be all zeros in the standard case, but may be
        %non-zero when aligning data to something other than the
        %startpoint.
        function [analog_data, t0] = get_analog_data (self, channel, id, timewindow)
            analog_data = cell(length(id),1);
            t0 = zeros(length(id),1);
        end
        
        function props = get_properties (self)
            props = self.Properties;
        end
        
    end
    
    methods (Access = protected)
        function props = build_properties(self);
            nProps=size(self.PheeData.Phrases,2)
            prop_names=self.PheeData.Phrases.Properties.VariableNames;
            props = cell(1, nProps);
            for i = 1:nProps
                props{i} = xbz.log.property.IndexedProperty(...
                    'Vocal', prop_names{i}, 'trial', '',self.PheeData.Phrases.(prop_names{i}));
            end
            set(props{1}, 'AutoSelectMode', 'defaultonly'); %Stimnumber
            
            props = cat(1, props{:});
        end
    end
    methods (Static)
        function [tf, file] = is_source(x)
            %Return true if input file can be read by this logsource class
            %Prefer inspecting the file alone, in case reading the actual
            %file is slow. If can't tell from the filename alone, return
            %true, and throw an error in the constructor if it can't be
            %read
            %Check if input argument X is a valid xblaster log source file
            tf = false; file = '';
            if ischar(x) && exist(x, 'file') ...
                    && xbz.util.file.compare_file_extension(x, '.hdr')
                tf = true;
                file = x;
            end
            
            %If x is something other than a file, return a filepath
            %Can be used for path redirection
        end
        function ext = get_source_file_extensions (self)
            %Method should return the file extension of the filetpyes
            %supported by the logsource, or cell array thereof
            %ext = '.m';
            %ext = {'.m', '.mat'};
            ext = {'.hdr'};
        end
        function str = summary_struct_to_cellstr (info)
            str = {};
        end
    end
    
end