function [ data ] = combineFTData( varargin )
%combineFTData Combine multiple production/sensation field trip arrays.
%   Detailed explanation goes here
data.p.raw=varargin{1}.p.raw;
data.p.events=varargin{1}.p.events;

data.s.raw=varargin{1}.s.raw;
data.s.events=varargin{1}.s.events;

data.ID=varargin{1}.ID;


for i=2:length(varargin)
    data.p.raw.label = varargin{i}.p.raw.label;
    data.p.raw=ft_appenddata([],data.p.raw,varargin{i}.p.raw);
    data.p.events=[data.p.events varargin{i}.p.events];
    
    data.s.raw.label = varargin{i}.s.raw.label;
    data.s.raw=ft_appenddata([],data.s.raw,varargin{i}.s.raw);
    data.s.events=[data.s.events varargin{i}.s.events];
    data.ID=[data.ID varargin{i}.ID];
end



end

