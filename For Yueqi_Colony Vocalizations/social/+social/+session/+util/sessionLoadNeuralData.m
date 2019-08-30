function [ data ] = sessionTimeFreq(session,varargin)
%sessionLFP Analyze LFP of a single session.
%   Detailed explanation goes here

%% Parameters
prewin  = 0.5;
postwin = 1.0;

%% Read LFP data for all events
for i=1:length(session)
    if i==1
        [data.p.raw data.p.events] = social.session.util.loadRackSession2ft(session(i),prewin,postwin,1,varargin{:});%,varargin{:});
        [data.s.raw data.s.events] = social.session.util.loadRackSession2ft(session(i),prewin,postwin,2,varargin{:});%,varargin{:});
        data.ID = [session(i).ID];
    else
        [newp pevents]= social.session.util.loadRackSession2ft(session(i),prewin,postwin,1,varargin{:})
        [news sevents]= social.session.util.loadRackSession2ft(session(i),prewin,postwin,2,varargin{:})
        if isfield(newp,'trial')
            if isfield(data.p.raw,'trial')
                data.p.raw = ft_appenddata([],data.p.raw,newp);%,varargin{:});
            else
                data.p.raw = newp;%,varargin{:});
            end
        end
        if isfield(news,'trial')
            if isfield(data.s.raw,'trial')
                data.s.raw = ft_appenddata([],data.s.raw,news);%,varargin{:});
            else
                data.s.raw = news;%,varargin{:});
            end
        end
        data.s.events=[data.s.events sevents];
        data.p.events=[data.p.events pevents];
        data.ID = [data.ID ', ' session(i).ID];
    end
end

%% Remove obvious artifactual trials
removeArtifacts=false;
if removeArtifacts
    all.p=[data.p.raw.trial{:}];
    all.s=[data.s.raw.trial{:}];
    m.p=mean(all.p(:));
    m.s=mean(all.s(:));
    
    sd.p=std(all.p(:));
    sd.s=std(all.s(:));
    
    % remove trials and events for production
    for i=1:length(data.p.raw.trial)
        rem.p(i)=any(any(abs(data.p.raw.trial{i})>(abs(m.p)+10*sd.p)));
    end
    cfg.trials = ~rem.p;
    data.p.raw = ft_selectdata(cfg,data.p.raw);
    data.p.events=data.p.events(~rem.p);
    % remove trials and events for sensation
    for i=1:length(data.s.raw.trial)
        rem.s(i)=any(any(abs(data.s.raw.trial{i})>(abs(m.s)+10*sd.s)));
    end
    cfg.trials = ~rem.s;
    data.s.raw = ft_selectdata(cfg,data.s.raw);
    data.s.events=data.s.events(~rem.s);
end



