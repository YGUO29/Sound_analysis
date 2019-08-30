classdef ExpDEvent < hgsetget
    %ExpDEvent: Generic Experiment Event (Discrete)
    %   Can be any thing: call, jamming, stimulus, etc
    
    properties
        Name
        Type
        Time@social.EventTime
        ExtSource         % links, paths to external data files
        Props             % Properties
    end
    
    methods
        function obj = ExpDEvent()
            obj.Name = '';
            obj.Type = '';
            obj.Time = social.EventTime;
            obj.Props = [];
        end
        
        function dur = GetDuration(obj)
            dur = diff(GetTime(obj.Time));
        end
        
        function [Names,ind] = GetTimeVar(obj)
            % get names of all properties belonging to EventTime class
            Names = [];
            prefix = '';
            ind = [];
            [Names,ind] = ParseTimeVar(obj,Names,ind,prefix);
        end
            
        
    end
    
    methods(Static)
        
    end

    
    
    
end
    
function [Names,ind] = ParseTimeVar(data_struct,Names,ind,prefix)
% Method function in ExpDEvent class for recursion
    pnames = fieldnames(data_struct);
    for i = 1:length(pnames)
        if isa(data_struct,'ExpDEvent')
            prop = get(data_struct,pnames{i});
        else
            prop = getfield(data_struct,pnames{i});
        end
        if isa(prop,'social.EventTime')
            for j = 1:length(prop.GetTime)
                Names = [Names;{[prefix,pnames{i}]}];
                ind = [ind;j];
            end
        elseif isstruct(prop)
            prefix = [prefix,pnames{i},'.'];
            [Names,ind] = ParseTimeVar(prop,Names,ind,prefix);
        end
    end
end

