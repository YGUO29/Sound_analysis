function [data Events]=loadRackSession2ft(session,prewin,postwin,behave_inds,varargin)
%% Load from session to field trip data structure
% This is the file format to generate.
% data.label   % cell-array containing strings, Nchan X 1
% data.fsample % sampling frequency in Hz, single number
% data.trial   % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is    Nchan X Nsamples 
% data.time    % cell-array containing a time axis for each trial (1 X Ntrial), each time axis is a 1 X Nsamples vector 
% data.trialinfo % this field is optional, but can be used to store trial-specific information, such as condition numbers, reaction times, correct responses etc. The dimensionality is N x M

%%
% Settings
% prewin = window(1); % in seconds
% postwin = 1.0; % in seconds

% Prepare to read data from file
header=session.Headers(ismember('.h5',{session.Headers.Extension}))
filename=header.File;
if isempty(filename)||~isfield(header.Header,'elec0001')
    fprintf('No neural data in this session.\n');
end
cfg.dataType='raw';
mcs     = McsHDF5.McsData(filename,cfg);
stream  = mcs.Recording{1}.(header.Header.elec0001{1}){header.Header.elec0001{2}};
adzero  = stream.Info.ADZero(1);
conv    = stream.Info.ConversionFactor(1);
exp     = 10^double(6+stream.Info.Exponent(1));

% Read events from session
Events=session.sort_events(session.GetEvents(behave_inds,varargin{:}));
NTrials=length(Events);

% Read data from mcs file into fieldtrip data structure
% cell-array containing strings, Nchan X 1
data.label=cellstr(num2str([1:header.Header.filt0002{3}]'));    
% sampling frequency in Hz, single number
data.fsample=stream.getSamplingRate;

% Convert window times to samples
Nprewin=prewin.*data.fsample;
Npostwin=postwin.*data.fsample;

% Downsample to 1000 hz
down_factor  = floor(data.fsample./1000);

for i=1:NTrials
    % find event onset sample
    eventsample=floor(Events(i).eventStartTime.*data.fsample);
    % compute list of samples to read
    samples=[eventsample-Nprewin:min(eventsample+Npostwin-1,size(stream.ChannelData,2))];
    
    % load raw data int32
    data.trial{1,i}=downsample(stream.ChannelData(:,samples)',down_factor)';    % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is    Nchan X Nsamples
    
    % convert to double
    data.trial{1,i}=double((data.trial{1,i}-adzero)*int32(conv));
    
    % convert from volts to microvolts
    data.trial{1,i}=data.trial{1,i}.*exp;

    % read out timestamps
    data.time{1,i}=double(stream.ChannelDataTimeStamps(:,samples)).*1e-6;      % cell-array containing a time axis for each trial (1 X Ntrial), each time axis is a 1 X Nsamples vector
    data.time{1,i}=downsample(data.time{1,i}-data.time{1,i}(1)-prewin,down_factor);
    
    
    % downsample samples
    samples=downsample(samples./down_factor,down_factor);
    
    % store first and last sample to
    data.sample(1:2,i)=floor(samples([1 end]));
    data.trl(1:3,i)=floor([eventsample-Nprewin eventsample+Npostwin-1 Nprewin]./down_factor)';

%     data.trialinfo={}; % this field is optional, but can be used to store trial-specific information, such as condition numbers, reaction times, correct responses etc. The dimensionality is N x M
end

data.fsample=data.fsample./down_factor;

% If these aren't deleted/cleared, then there's a memory leak.
delete(stream);
clear mcs
% delete(mcs);
%%

