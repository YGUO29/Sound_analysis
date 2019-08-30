classdef Event < social.interface.Social & social.interface.Signal & dynamicprops
    % Event interface defines methods and properties that events must have.
    % An event must have a start time, a stop time, and a sync time (all in
    % seconds relative to the event sync time). Events subclass
    % dynamicprops to allow addition or removal of properties.
    
    properties
        Behavior
        Subjects
        eventStartTime % in seconds.
        eventStopTime  % in seconds.
        eventSyncTime = 0; % Default that start of file is the sync time.
        eventClass = 'Event';
        eventParam = [];
    end
    
    methods
        function self = Event(session,behavior,start,stop,varargin)
            % Construct an arbitrary event using
            % Event(start,stop[,sync,propstruct])
            if nargin > 0
                self.Session=session;
                self.Behavior=behavior;
                self.ID=[self.Behavior.ID '-' 'Event' num2str(length(behavior.Events)+1)];
                self.Subjects=self.Behavior.Subjects;
                self.eventStartTime = start;
                self.eventStopTime = stop;
                
                %             if nargin > 2
                %                 self.eventSyncTime = varargin{1};
                %             end
                
                % To allow easy filtering of events in Heterogenous event
                % arrays, set the eventType property to a string corresponding
                % to the name of the class.
                self.eventClass='Event';
            else
                self.eventClass='Empty';
            end
        end
        
        function times = get_times(self)
            % return an scalar or 1 x 2 array of start and stop time in
            % seconds.
            times = [self.eventStartTime self.eventStopTime];
        end
        
        function signal = get_signal(self,varargin)
            if nargin==1
                signal = self.Behavior.get_signal(self.get_times);
            elseif nargin>1
                signal = self.Behavior.get_signal(varargin{1});
            end
        end
        
        function updateSyncTime(self,synctime);
            if iscell(self.eventSyncTime)
                self.eventSyncTime=0;
            end
            self.eventStartTime=self.eventStartTime+self.eventSyncTime;
            self.eventStopTime=self.eventStopTime+self.eventSyncTime;
            self.eventSyncTime = synctime;
            self.SyncTime = synctime;
            self.eventStartTime=self.eventStartTime-self.eventSyncTime;
            self.eventStopTime=self.eventStopTime-self.eventSyncTime;
        end
            
        function addprops(self,varargin);
            % addprops('prop1name',prop1val,'prop2name',prop2val,...)
            % Adds the properties and values to the event object.
            varargin=reshape(varargin,(nargin-1)./2,2);
            for i=1:size(varargin,1);
                self.addprop(varargin{i,1})
                self.(varargin{i,1})=varargin{i,2};
            end
        end
        
        function str = Report(self)
        % Return a formatted report (nx1 cellstr) summarizing object information.
        end
        
        function tab = Tabulate(self)
        % Return a table summarizing object information.
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

