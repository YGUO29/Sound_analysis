classdef Signal < social.interface.Social & matlab.mixin.Heterogeneous
    % SignalInterface is an abstract class for an object that supplies 
    % a signal from a single sensor for given time windows (supplied in seconds relative to the
    % Synchronization time).
    
    properties
        Session
        ID            % Unique identifier for the transducer/signal
        SyncTime = 0;   % Stored in seconds from onset of session.
    end
    
    methods (Abstract)
        % Output a cell array of signals for a given nx1 (Start) or nx2 (Start and Stop) times
        % array.
        signal=get_signal(self,times);
    end
    
    methods
        % Convert times (seconds) relative to SyncTime in a nx1 (start times) or nx2 (start and
        % stop times) array to times (seconds) relative to signal onset.
        function times=TimeSynchronizer(self,times)
            times=times+self.SyncTime;
            times(times<0)=0;
        end
    end
%     methods (Static, Sealed, Access = protected)
%         function self=getDefaultScalarElement()
%             self.SyncTime = 0;   % Stored in seconds from onset of session.
%             self.SessionID ='';
%             self.Name='Empty';
%         end
%     end
end

