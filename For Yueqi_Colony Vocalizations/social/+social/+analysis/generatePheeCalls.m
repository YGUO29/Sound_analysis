function calls = generatePheeCalls(phrases,varargin)
% Given a list of phee phrases, identify calls and create call events
% Optional 'parameter',value pairs including:
%       'gap_max', value for maximum gap time (s) between two phee prases
%       'nphrases', maximum number of phrases allowed
if isempty(phrases)
    calls=[];
    return;
end

p=inputParser;
addParameter(p,'max_gap',1.2);
addParameter(p,'nphrases',6);
p.parse(varargin{:})

gap_max=p.Results.max_gap;
Nphrases_max=p.Results.nphrases;

% Find unique sources
Names=unique({phrases.Name});
% Initialize calls array
calls={};

for sel_name=Names
    gaps=[]; ncalls=[]; t_start=[]; t_stop=[];
    
    % Pick out events for the corresponding name
    sel_phrases=findobj(phrases,'Name',sel_name{1});
    
    % Find t_start and t_stop.  Use all but the first t_start and the last
    % t_stop.
    t_start=[sel_phrases.eventStartTime];
    t_stop=[sel_phrases.eventStopTime];
    t_start=t_start(2:end);
    t_stop=t_stop(1:end-1);
    % calculate gaps  between phrases
    gaps=t_start-t_stop;
    
    % Identify the between call gaps larger than the threshold
    gaps=gaps>gap_max;
    
    % Count the number of calls = number of gaps + 1.
    ncalls=sum(gaps)+1;
    
    % Find the indices of the first phrase in each call
    firstphrase=[0 find(gaps)]+1;
    lastphrase=[[firstphrase(2:end)]-1 length(sel_phrases)];
    
    % create call event for each group of phrases
    for i=1:ncalls
        calls{end+1}=social.event.Call(sel_phrases(firstphrase(i):lastphrase(i)));
    end
end
calls=[calls{:}];
end


