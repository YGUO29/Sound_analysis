classdef EventTime < handle
    %EventTime is a data type for any timing property in an event
    %   Define time using this data type will allow TrialManager to
    %   identify possible time points that can be referenced as trial start.
    
    properties (Access = protected)
        t@double;
    end
    
    methods
        function obj = EventTime(varargin)
            if nargin == 1
                obj.t = varargin{1};
            else
                obj.t = NaN;
            end
        end
        
        function out = GetTime(obj)
            out = obj.t;
        end
        
        function SetTime(obj,value)
            obj.t = value;
        end
    end
    
end

