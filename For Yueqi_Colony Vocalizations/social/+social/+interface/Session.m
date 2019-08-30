classdef Session < social.interface.Social & dynamicprops
    %SessionLog - The StandardSessionLog stores all information related to 
    % a standard vocalization recording session, typically including a 
    % target and reference microphone. A StandardSessionLog may include
    % neurophysiology data recorded with nvr, DAQ_Record, MANTA, or MCS.
    %   
    % Written by Seth Koehler and Lingyun Zhao, 3/2015.
    
    properties (Abstract = true)%(Access = protected)
        Headers         % Must contain one or more SessionLogFile objects.
        Signals         % An array of signal objects, can include both raw and computed signals.
        Behaviors       % An array of behavior objects, enumerates exp defined behaviors based on one or more recorded signals
    end
    
    properties (Abstract = true)%(Access = protected)
        ID              %
        Subjects        % An array of subject IDs, always in the form M*.
        Experimenter    % Experimenter's name
        Experiment      % Experiment name/type
        Environment     % Recording location
        SyncTime        % Identifies the session time to which all events are referenced.
        Time            % Absolute time and date of beginning and end of session.
    end
    
    properties 
        DataPath = '\'; % Think a
    end
    
    methods
        %%%%SIGNALS
        % Return an array of signal objects
        function signals = GetSignals(self,varargin)
            if isempty(varargin)
                signals=self.Signals;
                return;
            end
            for i=1:length(varargin)./2
                prop_name{i}=varargin{i.*2-1};
                prop_val{i}=varargin{i.*2};
            end
            signals=self.Signals;
            for i=1:length(prop_name)
                vals={signals.(prop_name{i})}';
                signals=signals(ismember(vals,prop_val{i}));
            end
        end

        %%%%SOCIAL PACKAGE
        % Return a table structure containing the requested information.
        function tab=Tabulate(self)
            remfields={'Headers','Signals','Behaviors','PreviousInstance__'}
            warning('off');
            for i=1:length(self)
                % Convert object to struct
                tab{i}=struct(self(i));
                tab{i}=rmfield(tab{i},remfields(ismember(remfields,fieldnames(tab{i}))));
                tab{i}.Session=self(i);
                
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
            tab=cat(1,tab{:});
            warning('on');
        end
        
        % Return a formatted report summarizing session information.
        function str=Report(self)
            % Report returns a nx1 cell string array summarizing the data
            % included in the session.
            str{1} = ['Session: ' self.SessionID];
            %
        end
        
        %%%%SYNCHRONIZATION
        function success=updateSyncTime(self,synctime)
            try
                self.SyncTime=synctime;
                for i=1:length(self.Signals)
                    self.Signals(i).SyncTime=synctime;
                end
                for i=1:length(self.Events)
                    self.Events(i).updateSyncTime(synctime);
                end
                success=true;
            catch
                success=false;
            end
        end
        
        %%%%EVENTS
        % Return a list of events.
        function events = GetEvents(self,varargin)
        % Return an array of event objects, given a list of parameter/value
        % pairs. For example:
        %   session.GetEvents([behave_inds,]'eventClass','Call','callType','Phee');
        % Event filters will be applied in the order they are supplied,
        % allowing filters to pull out subsets of different event classes
        % (such as Calls and then call types as in the example above.
        % GetEvents relies on ismember, so it will work with any properties
        % for which ismember can be used.
        
        % Figure out what types of events to include in the event array.
            events=[];
            if mod(nargin,2)==0 
                % if even number of arguments, then first varargin is
                % behavior indices.
                behave_inds=varargin{1};
                varargin(1)=[];
            else
                behave_inds=1:length(self.Behaviors);
            end
            for i=behave_inds
                events=[events self.Behaviors(i).GetEvents(varargin{:})];
            end
            
            events=self.sort_events(events);
        end
        % Plot all or a subset of events in a timeline plot.
        function plotEvents(self,varargin)
            % Function to plot events.  Supply Parameter,Value pairs to
            % control plotting. Uses social.utils.timeline.m for plotting.
            % 'ah' - supply axis handle
            events=self.GetEvents
            if isempty(events)
                return;
            end
            
            p=inputParser;
            addParameter(p,'fig',figure)
            p.parse(varargin{:});
            fh=p.Results.fig;
            
            %Prepare axis
%             ah.NextPlot='replace';
            clf(fh);
            names=unique({events.ID});
            subset={'Calls','Phrases'};
            for i=1:length(names)
                    sel_phrases=self.Events(ismember({events.ID},names{i}));
                    sel_phrases=sel_phrases(ismember({sel_phrases.eventClass},'Phrase'));
                    sel_calls=self.Events(ismember({events.ID},names{i}));
                    sel_calls=sel_calls(ismember({sel_calls.eventClass},'Call'));
                    tags{i.*2-1}=[names{i} '-Calls'];
                    t_start{i.*2-1}=[sel_calls.eventStartTime];
                    t_stop{i.*2-1}=[sel_calls.eventStopTime];
                    tags{i.*2}=[names{i} '-Phrases'];
                    t_start{i.*2}=[sel_phrases.eventStartTime];
                    t_stop{i.*2}=[sel_phrases.eventStopTime];
            end
            figure(fh);
            social.util.timeline(tags,t_start,t_stop);
            ah=gca;
            ah.XLim=[0 self.Events(1).Header.Duration];
        end
        % Helper function.  Sorts events by time or other properties.
        function events=sort_events(self,events,varargin)
            % sort_events([property,direction]) sorts events by the
            % supplied property name (as a string) and direction ('ascend'
            % or 'descend'.  If direction is not supplied, 'ascend' is
            % defult'.  If property is not supplied, then 'eventStartTime'
            % is default.
            a=struct;
            p=inputParser;
            addOptional(p,'property','eventStartTime',@checkproperty)
            addOptional(p,'direction','ascend',@checkdirection)
            parse(p,varargin{:})
            property=p.Results.property;
            direction=p.Results.direction;
            
            % Extract property values
            if isempty(events)
                return;
            elseif iscell(events(1).(property))
                val={events.(property)}; val=reshape(val,numel(val),1);
                % sort by direction
                [a.b,a.i]=sort(val);
            else
                val=[events.(property)]; val=reshape(val,numel(val),1);
                % sort by direction
                [a.b,a.i]=sort(val,1,direction);
            end
            
            % Reorder events by indices list
            events=events(a.i);
            
            function output=checkproperty(input)
                prop_names=properties(events);
                if ~any(ismember(input{2},prop_names))
                    error('Property must be an event property.')
                else
                    output=true;
                end
            end
            function output=checkdirection(input)
                if ~isstr(input{2})
                    error('Direction must be a string.');
                else
                    input{2}=lower(input{2});
                    if ~any(ismember({'ascend','descend'},input{2}))
                        error('Direction must either ascend or descend.');
                    else
                        output=true;
                    end
                end
            end
                
            
        end
        %%%%SESSION
        function success=saveSession(self,varargin)
            try
                
                if nargin>1
                    p=varargin{1};
                else
                    [p]=fileparts(self.Headers(1).File);
                end
                filename=fullfile(p,['Session_' self.ID '.mat']);
%                 while exist(filename,'file')==2
%                     i=i+1;
%                     filename=fullfile(p,[f '-ver' sprintf('%03d',i) '.mat']);
%                 end
                eval([self.ID '=self;'])
                save(filename,self.ID);
                success=true;
            catch
                success=false;
            end
        end
        
        function GUI(self)
            % make a GUI here: add, browser, edit, delete, etc
            social.behavior.ManageBehChGUI(self)
        end
        
        function DetectEvents(self,ind_beh_ch)
            % for detecting behavioral events in one BehaviorChannel
            % indexed by ind_beh_ch
           
            self.Behaviors(ind_beh_ch).Events = self.Behaviors(ind_beh_ch).DetectEvents;
            self.Behaviors(ind_beh_ch).nEvents = length(self.Behaviors(ind_beh_ch).Events);
            
       end
        function DetectAllEvents(self)
            for i = 1:length(self.Behaviors)
                if ~self.Behaviors(i).IsProcessed
                    fprintf('Detecting events ...\n');
                    self.DetectEvents(i);
                else
                    fprintf('No events to detect ...\n');
                end
            end
        end
        
    end
end

