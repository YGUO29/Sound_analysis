classdef Session < social.interface.Social
    %SessionLog - The SessionLog stores all information related to a given
    %recording session, including session, monkey, experimenter, experiment
    %type, signals, and synchronization.
    %   
    % Written by Seth Koehler and Lingyun Zhao, 3/2015.
    
    properties (Abstract = true)%, Access=protected)
        Headers         % Must contain one or more SessionLogFile objects.
        Signals         % An array of signal objects, can include both raw and computed signals.
        Behaviors
        Events          % An array of event objects, can include both discrete and continuous events.
        SyncTime        % Identifies the session time (in seconds) to which all events are referenced.
                    % Absolute time and date of beginning and end of session.
    end
    
    properties (Abstract = true)
        ID       %
        Subjects              % An array of subject IDs, always in the form M*.
        Experimenter    % Experimenter's name
        Experiment      % Experiment name/type
        Environment     % Recording location
        Time
    end
    
    methods (Abstract = true)
        EventArray = GetEvents(self,ID,Signal)
        % Return an array of events given a cell array of IDs and a cell
        % array of signals
        
        SignalArray = GetSignals(self,ID)
        % Return an array of signal objects given a cell array of IDs
    end
    methods
        
        function disp(self)
            str=self.Report;
            for i=1:length(str)
                disp(char(str))
            end
        end
    end
end

