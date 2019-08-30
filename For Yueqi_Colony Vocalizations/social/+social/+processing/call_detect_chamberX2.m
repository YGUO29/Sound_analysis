function deteced_calls = call_detect_chamberX2(BehChannel)
% This program reads recordings of vocalizations and does the following
% - recognize calls and mark their timing
% - assign caller label
% - extract the calls and save as individual files
% - Modified by SDK to use parallel for loops.
% call_detect(Session[,'Channel',chlist).
%
% call_detect is based on phee_detect.m written by L.Zhao.

% Determine which signals to analyze
% TODO: make this more abstract, for now just use the first two signals
% p=inputParser;
% p.addParameter('channel',[1 2]);
% p.parse(varargin);
signal(1) = BehChannel.SigDetect;
signal(2) = BehChannel.SigRef;


% % Try to figure out channels from session
% names={Session.Signals.Name};
% ch=[strmatch('Computer',names)' strmatch('M',names)' strmatch('Colony',names)'];
% if numel(ch)==2
%     ch=ch([1 2]);
%     channels=reshape(ch,1,numel(ch));
% else
%     fprintf('Channels 1 and 2');
% end

use15dBpad = 0;     % for early recordings where 15dB pad is enable for channel #

mvxflag=true;

firstlen = 30;                  % length to acquire threshold
th_factor = 200;                 % 500 for quiet background, 5 for jamming, 
                                % changed from 200 to 1000, 11/15,2012
                                % was 200, changed to 1000 for Raven recorded 9606 vocalizations, 06/08/2013
                                
                                % use 200 for mvx, 5000 for Raven, 01/14/2014
                                
chunklen = 30;                  % time of data to load in every time
overlap = 2;                    % overlap time (s) between chunks
interphrase = 1;                % largerest inter phrase interval (s)

% fullpath = [filepath filename];
% indtemp = strfind(fullpath,'.wav');
% neuralpath = [fullpath(1:indtemp-1),'n.wav'];

fprintf(['Begin detecting phees from %s for signals ' num2str(signal(1).Channel) '.\n'],signal(1).SessionID)
% [info] = audioinfo(fullpath);
% ind1 = strfind(d,':')+1; 
% ind2 = strfind(d,'samples')-1;
samplesize = signal(1).Header.TotalSamples; % str2double(d(ind1:ind2));

% first read the first 10 seconds to calculate baseline and threshold.
% [y_temp Fs nbits] = wavread(fullpath, 1);
Fs=Session.signal(1).SampleRate;
nbits=Session.signal(1).Header.BitsPerSample;

Fs_down = Fs/25*12;

firstlen = min(firstlen,samplesize/Fs);

% high pass filter
filter_b = fir1(20,4000/Fs_down*2,'high');
filter_sm = fir1(50,10/Fs_down*2);

wave_first = [];

% N_Firts is the number of chunks to use for baseline
% stepsize is the length of each chunk in seconds
if firstlen == samplesize/Fs
    stepsize = samplesize/Fs/10;
    N_first = 10;
else
    stepsize = 1; % In seconds
    N_first = firstlen;
end

% put the "first" data in 10 chunks or N_first (second) chunks
fprintf('Connect the chunks.\n');
voc_th_seg=cell(N_first,1);
wave_first=cell(N_first,1);
parfor i = 1:N_first; % Step through N_first chunks
    temp1 = signal(1).get_signal([(i-1)*stepsize,i*stepsize]);
    temp2 = signal(2).get_signal([(i-1)*stepsize,i*stepsize]);
    y_first = [temp1{1} temp2{1}];
    y_mean = repmat(mean(y_first),size(y_first,1),1);
    y_first = y_first-y_mean;

    % downsample and filter
    y_first = resample(y_first,Fs_down,Fs);
    y_first = filtfilt(filter_b,1,y_first);
    
    % get smoothed energy
    y_first = y_first.^2;
    y_first = filtfilt(filter_sm,1,y_first);
    
    voc_th_seg{i} = median(abs(y_first));
%     voc_th_seg(i,:) = max(abs(y_first));
    wave_first{i} = y_first';
end

wave_first=[wave_first{:}]';
voc_th = th_factor*min(cell2mat(voc_th_seg));

% figure;
% subplot(2,1,1)
% plot(wave_first(:,channels(1)),'b');
% hold on
% plot([1,length(wave_first)],[1 1]*voc_th(channels(1)),'r');
% 
% subplot(2,1,2)
% plot(wave_first(:,channels(2)),'b');
% hold on
% plot([1,length(wave_first)],[1 1]*voc_th(channels(2)),'r');

%% start analyzing original data by chunks
fprintf('Analyzing data by chunks: \n')
chunksize = chunklen * Fs;
i=1;
N1(i,1) = 1;
chunk_count = 1;
if samplesize>chunksize
    N2(i,1) = chunksize;
else
    N2(i,1) = samplesize;
end

% Generate list of N1s and N2s
while N2(i,1) <= samplesize
    i=i+1;
    N1(i,1) = N2(i-1,1) + 1 - round(overlap*Fs);
    N2(i,1) = N1(i,1) + chunksize - 1;
    if N2(i,1) > samplesize
        N2(i,1) = samplesize;
    end
    if N1(i,1) > samplesize - round(overlap*Fs)
        break
    end
end
clear i;
T1=N1./Fs;
T2=N2./Fs;

%%
filt.highpass = filter_b;
filt.smooth = filter_sm;

t1_start = cell(length(N1),1);
t1_stop = cell(length(N1),1);
t2_start = cell(length(N1),1);
t2_stop = cell(length(N1),1);
hw = waitbar(0); w=0; calls=0;
tic
parfor i=1:length(N1)% N2 <= samplesize
%     tic
    fprintf([' ' num2str(i) ','])
    y1 = cell2mat(signal(1).get_signal([T1(i) T2(i)]));
    y2 = cell2mat(signal(2).get_signal([T1(i) T2(i)]));
    y1 = y1 - mean(y1);
    y2 = y2 - mean(y2);
%     if isempty(strfind(Session.Headers.File,'raw_wav'))||~mvxflag
        [t1_start{i} t1_stop{i}] = social.analysis.findphee(y1, (N1(i)-1)/Fs, voc_th(1), Fs, filt);
        [t2_start{i} t2_stop{i}] = social.analysis.findphee(y2, (N1(i)-1)/Fs, voc_th(2), Fs, filt);
%     else
%         [t1_start{i} t1_stop{i}] = social.analysis.findphee_mvx(y1, (N1(i)-1)/Fs, voc_th(channels(1)), Fs, filt);
%         [t2_start{i} t2_stop{i}] = social.analysis.findphee_mvx(y2, (N1(i)-1)/Fs, voc_th(channels(2)), Fs, filt);
%     end
%     if length(t_start{i,1})~=length(t_stop{i,1}) || length(t_start{i,2})~=length(t_stop{i,2})
%         disp('Start times and stop times are not matched! Adjust threshold.');
%     end
% toc
%     calls=calls+max(length(t1_start{i}), length(t1_start{i}));
%     waitbar(w/length(N1), hw,['Detecting Phees...' num2str(round(w/length(N1)*100)) '%; %d detected.'], calls=calls+max(length(t1_start{i}), length(t1_start{i})));
%     w=w+1;
end
toc
t_start{1}=vertcat(t1_start{:});
t_start{2}=vertcat(t2_start{:});
t_stop{1}=vertcat(t1_stop{:});
t_stop{2}=vertcat(t2_stop{:});
clear t1_start t2_start t1_stop t2_stop
delete(hw)
fprintf('.\n');

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
%% For feedack experiments, make sure ch1 and ch2 match
% Something strange Seth did.
% t_start{1}=union(t_start{1},t_start{2});
% t_stop{1}=union(t_stop{1},t_stop{2});
% t_stop{2}=t_stop{1};
% 
% t_start{1}(isnan(t_start{1})) = [];
% t_start{2}(isnan(t_start{2})) = [];
% t_stop{1}(isnan(t_stop{1})) = [];
% t_stop{2}(isnan(t_stop{2})) = [];

%% Create events


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
        
        y1 = signal(1).get_signal([t_start{ch_long}(i), t_stop{ch_long}(i)]);
        y1 = y1{1};
        y2 = signal(2).get_signal([t_start{3-ch_long}(ind), t_stop{3-ch_long}(ind)]);
        y2 = y2{1};
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

% Construct VocalPhrase events
clear temp1;
temp1={};
parfor i=1:length(t_start{1})
    temp1{i}=social.event.Phrase(signal(1),t_start{1}(i),t_stop{1}(i));    
end

clear temp2;
temp2={};
parfor i=1:length(t_start{2})
    temp2{i}=social.event.Phrase(signal(2),t_start{2}(i),t_stop{2}(i));
end

% Combine all VocalPhrase events together
% Session.Events=[temp1{:} temp2{:}];
detected_calls = temp1{:};

% % % Verify that all events have both a start and stop time.  If not, remove them
% % if ~isempty(Session.Events)
% %     toRemove=isnan([Session.Events.eventStartTime])|isnan([Session.Events.eventStopTime]);
% %     Session.Events(toRemove)=[];
% % end

% save
% ind = strfind(filename,'.wav');
% savename = ['PheeTime_' filename(1:ind-1)];
% savename = strrep(savename,'_denoise','');
% save(savename,'t_start','t_stop','filepath','filename','samplesize','Fs','channels');
% temp=load(savename);
% fprintf(['Finished detecting phees. Saved to ' savename '.\n']);
end
