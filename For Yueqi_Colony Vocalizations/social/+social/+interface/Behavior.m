classdef (Abstract) Behavior < social.interface.Social & dynamicprops
    %BEHAVIORCHANNEL Abstract Class for each experiment behavior.
    % A behavior channel is either a vocal, motor, position, etc channel
    % Concrete implmentations must specify the corresponding Signals or Signal groups used to detect
    % the behavior.
    % It also defines methods used for detection or feature extraction
    
    properties
        Subjects             % An 1xN array of subject ids (M##, Environment)\
        Events
        nEvents = 0;
        BehName = 'Parabolic';
        IsProcessed = false;% a flag to mark whether this Channel has been processed (e.g. events detected)
    end
    
    methods (Abstract) 
        detected_events = DetectEvents(self);

        extracted_features = GetEventFeatures(self);   
        % For example, getting F0 from regular mic will be different from
        % parabolic mic, and may require additional Signals
    end
    
    methods
        %%%%EVENTS
        % Return a list of events.
        function events = GetEvents(self,varargin)
        % Return an array of event objects, given a list of parameter/value
        % pairs. For example:
        %   session.GetEvents('eventClass','Call','callType','Phee');
        % Event filters will be applied in the order they are supplied,
        % allowing filters to pull out subsets of different event classes
        % (such as Calls and then call types as in the example above.
        % GetEvents relies on ismember, so it will work with any properties
        % for which ismember can be used.
        
        % Figure out what types of events to include in the event array.
            events=[];
            events=[self.Events];
            
            if isempty(varargin)
                events=self.Session.sort_events(events);
                return;
            end
            
            for i=1:length(varargin)./2
                prop_name{i}=varargin{i.*2-1};
                prop_val{i}=varargin{i.*2};
            end
            
            if ~isempty(events)
                for i=1:length(prop_name)
                    vals={events.(prop_name{i})}';
                    events=events(ismember(vals,prop_val{i}));
                end
            end
            events=self.Session.sort_events(events);
        end
        
        function eventMaxLength(self,maxDur)
            % Remove events that are too long
            tstart=[self.Events.eventStartTime];
            tstop=[self.Events.eventStopTime];
            dur=tstop-tstar;
            inds_TooLong = dur>maxDur;
            self.Events(dur>maxDur)= [];
            self.nEvents=length(self.Events);
        end
        
        function eventMinGap(self,minGap)
            % Merge events that are too close together
            self.Events=self.Session.sort_events(self.Events);
            k=1;
            while k<length(self.Events)
                gap=self.Events(k+1).eventStartTime-self.Events(k).eventStopTime;
                if gap<=minGap
                  self.Events(k).eventStopTime=self.Events(k+1).eventStopTime;
                  self.Events(k+1)=[];
                else
                    k=k+1;
                end
            end
            self.nEvents=length(self.Events);
        end
        function str = Report(self)
            % Return a formatted report (nx1 cellstr) summarizing object information.
            str = '';
        end
        
        function tab = Tabulate(self)
            warning('off');
            
            self.nEvents=length(self.Events);
            
            for i=1:length(self)
                % Convert object to struct
                tab{i}=struct(self(i));
                tab{i}=rmfield(tab{i},{'SigDetect','SigRef','SigFeature','Session','DataPath','RelativePath','Filename','Extension','File'});
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
            tab=cat(1,tab{:});
            warning('on');
        end
    end
end
    

