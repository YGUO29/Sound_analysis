% This program reads recordings of vocalizations and does the following
% - recognize calls and mark their timing
% - assign caller label
% - extract the calls and save as individual files

% filepath = 'C:\data\raw_wav\';
% filename = 'voc_9606_S8.wav';   % file to analyze
close all;
clear
clc;


%  filepath = '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\M9001\';
filepath = '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\M9606\raw_wav\';
% filepath = '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\M9606\RavenVocalization\';
% filepath = '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\M93A\RavenVocalization\';
% filepath = '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\Hamlet\';
%  filepath = '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\M4526\';
%  filepath = '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\M108Z\';
%  filepath = 'C:\Documents and Settings\Lingyun\My Documents\Monkey Vocalization\';
%  filepath = 'C:\Documents and Settings\Lingyun\My Documents\M9001\';
% filepath = 'C:\Users\Lingyun\Documents\';

% filepath = 'F:\data\raw_wav\';
% filename = 'M9001_130912_S1_denoise.wav';
%  filename = 'M108Z_140124_S1.wav';
%  filename = 'voc_utah_S15.wav';
filename = 'voc_9606_S283.wav';
% filename = 'M9606_141004_S2.wav';
% filename = 'M93A_141013_S1.wav';
% filename = 'Phee_testsample5_S15.wav';   % file to analyze
use15dBpad = 0;     % for early recordings where 15dB pad is enable for channel #


channels = [1,2];               % which channels to analyze
firstlen = 30;                  % length to acquire threshold
th_factor = [500,500];
% th_factor = [1e4, 5e4];        % made into two channels 10/06/2014        
                                % 500 for quiet background, 5 for jamming, 
                                % changed from 200 to 1000, 11/15,2012
                                % was 200, changed to 1000 for Raven recorded 9606 vocalizations, 06/08/2013
                                
                                % use 200 for mvx, 5000 for Raven, 01/14/2014
                                
                               
                                
chunklen = 30;                  % time of data to load in every time
overlap = 2;                    % overlap time (s) between chunks
interphrase = 1;                % largerest inter phrase interval (s)

fullpath = [filepath filename];
indtemp = strfind(fullpath,'.wav');
neuralpath = [fullpath(1:indtemp-1),'n.wav'];

[m d] = wavfinfo(fullpath);
ind1 = strfind(d,':')+1;
ind2 = strfind(d,'samples')-1;
samplesize = str2double(d(ind1:ind2));

% first read the first 10 seconds to calculate baseline and threshold.
[y_temp Fs nbits] = wavread(fullpath, 1);
Fs_down = Fs/25*12;

firstlen = min(firstlen,samplesize/Fs);

% high pass filter
filter_b = fir1(20,4000/Fs_down*2,'high');
filter_sm = fir1(50,10/Fs_down*2);

wave_first = [];

if firstlen == samplesize/Fs
    stepsize = samplesize/Fs/10;
    N_first = 10;
else
    stepsize = 1;
    N_first = firstlen;
end

% put the "first" data in 10 chunks or N_first (second) chunks
for i = 1:N_first
    
    y_first = wavread(fullpath, round([(i-1)*stepsize*Fs+1,i*stepsize*Fs]));
    y_first = y_first(:,channels);
    y_mean = repmat(mean(y_first),size(y_first,1),1);
    y_first = y_first-y_mean;
    
    
    % downsample and filter
    y_first = resample(y_first,Fs_down,Fs);
    y_first = filtfilt(filter_b,1,y_first);
    
    % get smoothed energy
    y_first = y_first.^2;
    y_first = filtfilt(filter_sm,1,y_first);
    
    voc_th_seg(i,:) = median(abs(y_first));
%     voc_th_seg(i,:) = max(abs(y_first));
    wave_first = [wave_first;y_first];
end
voc_th = th_factor.*min(voc_th_seg);

figure;
subplot(2,1,1)
plot(wave_first(:,1),'b');
hold on
plot([1,length(wave_first)],[1 1]*voc_th(1),'r');

subplot(2,1,2)
plot(wave_first(:,2),'b');
hold on
plot([1,length(wave_first)],[1 1]*voc_th(2),'r');

% start analyzing original data by chunks
chunksize = chunklen * Fs;
N1 = 1;
chunk_count = 1;
if samplesize>chunksize
    N2 = chunksize;
else
    N2 = samplesize;
end

filt.highpass = filter_b;
filt.smooth = filter_sm;

t_start = cell(1,2);
t_stop = cell(1,2);
hw = waitbar(0);


% prepare for parfor
if matlabpool('size') < feature('numCores')
    if matlabpool('size') > 0
        matlabpool close
    end
    matlabpool
end
Nfor = ceil((samplesize-chunksize)/((chunklen-overlap)*Fs))+1;
% t_start = cell(2,Nfor);
% t_stop = cell(2,Nfor);
parfor_progress(Nfor);
parfor ci = 1:Nfor
% while N2 <= samplesize
    parfor_progress
    y_temp = [];
    N1 = (ci-1)*((chunklen-overlap)*Fs)+1;
    N2 = N1 + chunksize-1;
    if N2 > samplesize
        N2 = samplesize;
    end
%     waitbar(ci/Nfor, hw,['Detecting Phees...' num2str(round(ci/Nfor*100)) '%']);
    
    [y_temp temp1 nbits] = wavread(fullpath, [N1 N2]);
    y_mean = repmat(mean(y_temp),size(y_temp,1),1);
    y_temp = y_temp-y_mean;
    
    
    if isempty(strfind(filepath,'raw_wav'))
        [t1_start{ci} t1_stop{ci}] = findphee(y_temp(:,1), (N1-1)/Fs, voc_th(1), Fs, filt);
        [t2_start{ci} t2_stop{ci}] = findphee(y_temp(:,2), (N1-1)/Fs, voc_th(2), Fs, filt);
    else
        [t1_start{ci} t1_stop{ci}] = findphee_mvx(y_temp(:,1), (N1-1)/Fs, voc_th(1), Fs, filt);
        [t2_start{ci} t2_stop{ci}] = findphee_mvx(y_temp(:,2), (N1-1)/Fs, voc_th(2), Fs, filt);
    end
end
delete(hw)
parfor_progress(0)

for ci = 1:Nfor
    t_start{1} = [t_start{1};t1_start{ci}];
    t_start{2} = [t_start{2};t2_start{ci}];
    t_stop{1} = [t_stop{1};t1_stop{ci}];
    t_stop{2} = [t_stop{2};t2_stop{ci}];
end

%% combine the chunks
for k = 1:2
    
    [t_start{k} IX] = sort(t_start{k});
    t_stop{k} = t_stop{k}(IX);
    i = 2;
    while i <= length(t_start{k})
        if abs(t_start{k}(i)-t_stop{k}(i-1)) < 0.01
            t_start{k}(i) = [];
            t_stop{k}(i-1) = [];
        else
            i = i + 1;
        end
    end
    
    i = 2;
    while i <= length(t_start{k})
        if abs(t_start{k}(i)-t_start{k}(i-1)) < 0.1 || abs(t_stop{k}(i)-t_stop{k}(i-1)) < 0.1
            if t_stop{k}(i) - t_start{k}(i) > t_stop{k}(i-1)-t_start{k}(i-1)
                t_start{k}(i-1) = [];
                t_stop{k}(i-1) = [];
            else
                t_start{k}(i) = [];
                t_stop{k}(i) = [];
            end
        else
            i = i + 1;
        end
    end
    
    
end

% Remove invalid calls
for i = 1:2
    j = 1;
    while j <= length(t_start{i})
        if isnan(t_start{i}(j)) || isnan(t_stop{i}(j))
            t_start{i}(j) = [];
            t_stop{i}(j) = [];
        else
            j = j+1;
        end
    end
end
            

%% assign callers to the calls
current = 0;        % current time
if length(t_start{1}) > length(t_start{2})
    ch_long = 1;
else
    ch_long = 2;
end
stop_tag = 0;
for i = 1:length(t_start{ch_long})
    ind = find(abs(t_start{ch_long}(i) - t_start{3-ch_long})<0.2);
    if isempty(ind)
        ind = find(abs(t_stop{ch_long}(i) - t_stop{3-ch_long})<0.2);
        stop_tag = 1;
    end
    aa = t_start{ch_long}(i);        % for debug only
    if length(ind) > 1
        if stop_tag == 1
            time_diff = abs(t_stop{ch_long}(i) - t_stop{3-ch_long}(ind));
        else
            time_diff = abs(t_start{ch_long}(i) - t_start{3-ch_long}(ind));
        end
        ind_min = find(time_diff == min(time_diff));
        ind = ind(ind_min);
    end
    if ~isempty(ind)
        % calculate energy and assign caller
        
        y1 = wavread(fullpath, [max(1,round(t_start{ch_long}(i)*Fs)),round(t_stop{ch_long}(i)*Fs)]);
        y1 = y1(:,ch_long);
        y2 = wavread(fullpath, [max(1,round(t_start{3-ch_long}(ind)*Fs)),round(t_stop{3-ch_long}(ind)*Fs)]);
        y2 = y2(:,3-ch_long);
        y1_power = sum(y1.^2)/(t_stop{ch_long}(i)-t_start{ch_long}(i));
        y2_power = sum(y2.^2)/(t_stop{3-ch_long}(ind)-t_start{3-ch_long}(ind));

        if use15dBpad == 2
            if ch_long == 1
                y2 = y2/30;
            else
                y1 = y1/30;
            end
        elseif use15dBpad == 1
            if ch_long == 1
                y1 = y1/30;
            else
                y2 = y2/30;
            end
        end
        if y1_power > y2_power
            t_start{3-ch_long}(ind) = NaN;    % remove the non-caller timing
            t_stop{3-ch_long}(ind) = NaN;
        else
            t_start{ch_long}(i) = NaN;    % remove the non-caller timing
            t_stop{ch_long}(i) = NaN;
        end
        
        
    end
    
end

t_start{1}(isnan(t_start{1})) = [];
t_start{2}(isnan(t_start{2})) = [];
t_stop{1}(isnan(t_stop{1})) = [];
t_stop{2}(isnan(t_stop{2})) = [];



% save
ind = strfind(filename,'.wav');
savename = ['PheeTime_' filename(1:ind-1)];
savename = strrep(savename,'_denoise','');
save(savename,'t_start','t_stop','filepath','filename','samplesize','Fs');

