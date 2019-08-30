function detected_calls = call_detect_first_prev_background(Session,BehChannel,DetectionParam)
%CALL_DETECT_PREV_BACKGROUND Summary of this function goes here
%   Detailed explanation goes here

Signals = Session.Signals;
Events = Session.Events;
Fs = Session.Signals(1).SampleRate;

voc_band = [4000 16000];
win_sm = 0.05;                          % in sec, time win for smooth the signal energy
win_sm_size = 2*round(win_sm*Fs/2)+1;           % window size for smoothing
power_th = DetectionParam.Threshold;
win_time = 0.01;
shift_time = 0.001;
winsize = 2*round(win_time*Fs/2);
shift_size = round(shift_time * Fs);
voc_dur_min = DetectionParam.MinVocDuration;
gap_min = DetectionParam.MinGapInterval;


% find all target events
ind_str = strfind(BehChannel.TargetID,',');
ind_str = [1 ind_str+1 length(BehChannel.TargetID)+2];
N_target = length(ind_str)-1;
call_times_all = [];
for i = 1:N_target
    tID = BehChannel.TargetID(ind_str(i):ind_str(i+1)-2);
    target_events{i} = Session.GetEvents('eventClass','Phrase','SubjectID',tID);
    call_times{i} = [target_events{i}.get_times];       % this is probably a bad expression here, matlab spits outo the first output for all array member and then the second output
    call_times{i} = reshape(call_times{i},length(target_events{i}),2);
    call_times{i} = [call_times{i} ones(length(target_events{i}),1)*i];
    call_times_all = [call_times_all;call_times{i}];
end

call_start_times_sorted = sortrows(call_times_all,1);
call_stop_times_sorted = sortrows(call_times_all,2);

% band pass filter

b_bp = fir1(100,voc_band/(Fs/2),'bandpass');
b_sm = gausswin(win_sm_size);
b_sm = b_sm/sum(b_sm);

t_start = [];
t_stop = [];

ppool = gcp;
if isempty(ppool)
    parpool;
end
parfor_progress(size(call_times_all,1))

parfor ci = 1:size(call_times_all,1)
% for ci = 1:30
    parfor_progress
    % generate windows prior to target events
    
    
    % current target call
    t_start_call = call_times_all(ci,1);
    % find last previous call
    ind = find(call_stop_times_sorted(:,2)<t_start_call);
    if isempty(ind)
        prev_stop = 0;
    else
        
        ind = ind(end);
        prev_stop = call_stop_times_sorted(ind,2);
    end
    seg_start = max(prev_stop,t_start_call-BehChannel.PrevWindowLength);
    window = [seg_start,t_start_call];
    
    
    % detect background calls using one channel
    
    signal = Session.Signals(BehChannel.SigDetect).get_signal(window);
    signal = signal{1};
    % bandpass filter, smooth and get energy envelop
    signal_filtered = filtfilt(b_bp,1,signal);
    signal_power = signal_filtered.^2;
    signal_power_dB = 10*log10(signal_power/10);
    
    if length(signal_power) > win_sm_size*3
        signal_power_sm = filtfilt(b_sm,1,signal_power_dB);
    else
        continue
    end
    
    ind1 = find(signal_power_sm > power_th);
    ind1 = ind1';
    ind2 = diff(ind1);
    if ~isempty(ind2)

        ind_start = ind1(find([10 ind2]>1));
        ind_stop = ind1(find([ind2 10]>1));
        
        spec = spectra(signal,winsize,shift_size,Fs,'log');
        
%         % if bad frequency, remove it
%         
%         
%         i = 1;
%         while i <= length(ind_start)
%             [~, F0_ind_phrase] = max(spec(:,max(1,round(ind_start(i)/shift_size)):min(size(spec,2),round(ind_stop(i)/shift_size))));
%             F0_ind_mean = round(mean(F0_ind_phrase));
% 
% 
% 
% 
%             if F0_ind_mean < voc_band(1)/Fs*winsize || F0_ind_mean > voc_band(2)/Fs*winsize 
%                 ind_start(i) = [];
%                 ind_stop(i) = [];
% 
%             else
%                 i = i + 1;
%             end
%         end
        
        
        
        % remove gaps
        i = 1;
        while i <= length(ind_start) - 1 
            if ind_start(i+1)-ind_stop(i) <= gap_min*Fs
                ind_start(i+1) = [];
                ind_stop(i) = [];
            else
                i = i + 1;
            end
        end
        
        % throw out short pieces 
        ind_t_duration = ind_stop - ind_start;
        ind_dur = find(ind_t_duration >= voc_dur_min*Fs);

        ind_start = ind_start(ind_dur);
        ind_stop = ind_stop(ind_dur);
        
        
        
        
        
        % convert to time
        t_start_temp = (ind_start-1)/Fs + seg_start;
        t_stop_temp = (ind_stop-1)/Fs + seg_start;
        
        
        
% %         % for debug
% %         
% %         figure(200)
% %         subplot(2,1,1)
% %         plot(signal_power_sm)
% %         subplot(2,1,2)
% % 
% %         cla
% %         hold on;
% %         imagesc(prev_start+[0:size(spec,2)-1]*shift_time,[0:size(spec,1)-1]*Fs/winsize,spec);
% %         axis xy
% %         colorbar
% %         
% %         for i = 1:length(ind_start)
% %             plot([1 1]*t_start_temp(i),[0 Fs/2],'k');
% %             plot([1 1]*t_stop_temp(i),[0 Fs/2],'k');
% %         end
        
        
        
        if ~isempty(ind_start)
            t_start = [t_start t_start_temp(end)];      % take only the last one
            t_stop = [t_stop t_stop_temp(end)];
        end
        
        
    end
    
    
 
end
parfor_progress(0)

detected_calls = social.event.Phrase.empty;
for i = 1:length(t_start)
    detected_calls(i) = social.event.Phrase(Signals(BehChannel.SigFeature),t_start(i),t_stop(i),BehChannel); 

end

