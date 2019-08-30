function [t_start,t_stop] = findphee(wave, chunk_start_time, th, Fs, filt)
% This function will analyze the waveform and find out the start and
%   stop time of any phee calls. 
% wave: for one channel only; column vector
% start_time: the starting time (s) of this chunk, corresponding to the
%             first sampling point
% th: threshold

    param.Fs_down = Fs/2;       % changed 05/10/2013
    param.scanlen = 0.02;          % time period to determine sound frequency, in seconds
    param.spec_shiftlen = 0.0005;  % spectrogram shift length (s)
    param.min_phee_len = 0.3;      % minimum phee phrase duration
    param.th = th;
    param.start_time = chunk_start_time;
    param.pre_th_len = 0.2;         % time period before crossing threshold to search for phee start, change from 0.2
    param.min_interphrase_interval = 0.05;       % min time between phrases

    % high pass filter
    filter_b = filt.highpass;
    filter_sm = filt.smooth;
    
    % down sample and highpass filter
    wave = resample(wave,param.Fs_down,Fs);
    wave_unfiltered = wave;
    wave = filtfilt(filter_b,1,wave);
    
    % get smoothed energy
    wave_power = wave.^2;
    wave_power = filtfilt(filter_sm,1,wave_power);
    
% %     % plot for debug
% %     figure(20)
% %     hold on
% %     plot(wave_power)
% %     plot([1 length(wave_power)],[1 1]*param.th,'r')
    
    wave_rev = wave(length(wave):-1:1);
    wave_unfiltered_rev = wave_unfiltered(length(wave):-1:1);
    wave_power_rev = wave_power(length(wave_power):-1:1);
    
    % find Phee starting times
    param.reversed = 0;
    
    
    % for debug, L.Zhao, 12/23/2013
    figure(100)
    cla;
    hold on
    plot(chunk_start_time+[1:length(wave_power)]/param.Fs_down,wave_power');
    plot([chunk_start_time,chunk_start_time+length(wave_power)/param.Fs_down],[1 1]*th,'r');
    
    % find the threshold points before checking each one, merge adjacent
    % points, L.Zhao, 12/24/2013
    ind = find(abs(wave_power)>th);
    ind2 = diff(ind);
    
    if ~isempty(ind)
        % add energy filter and judge continuous passing threshold points
        ind2 = [10;ind2];
        checkpoints_start = ind(ind2>1);     % sample points at which the waveform passes threshold
    end
    
    
    
    ind = find(abs(wave_power)>th);
    ind_rev = ind(length(ind):-1:1);
    ind2 = -diff(ind_rev);
    if ~isempty(ind)
        ind2 = ind2(length(ind2):-1:1);         
        ind2 = [ind2;10];
        checkpoints_stop = ind(ind2>1);     % sample points at which the waveform passes threshold downward
    end
    
    if exist('checkpoints_start') && exist('checkpoints_stop')
        if checkpoints_start(1)>checkpoints_stop(1)
            checkpoints_stop(1) = [];
        end
        if checkpoints_start(end)>checkpoints_stop(end)
            checkpoints_start(end) = [];
        end
        ci = 2;
        while ci <= length(checkpoints_start)
            if abs(checkpoints_start(ci)-checkpoints_stop(ci-1)) < param.min_interphrase_interval * param.Fs_down
                checkpoints_start(ci) = [];
                checkpoints_stop(ci-1) = [];
            else
                ci = ci + 1;
            end
        end
    
%     ci = 1;
%     while ci <= length(checkpoints_start)
%         if abs(checkpoints_start(ci)-checkpoints_stop(ci)) < param.min_phee_len * param.Fs_down
%             checkpoints_start(ci) = [];
%             checkpoints_stop(ci) = [];
%         else
%             ci = ci + 1;
%         end
%     end
    
    
    
        t_start = FindPheeStart(wave,wave_unfiltered,wave_power,param,checkpoints_start);
    % find Phee stopping times
%     param.reversed = 1;
%     t_stop = FindPheeStart(wave_rev,wave_unfiltered_rev,wave_power_rev,param);
%     t_stop = chunk_start_time*2 + length(wave)/param.Fs_down - t_stop;
%     t_stop = sort(t_stop);
        t_stop = FindPheeStop(wave,wave_unfiltered,wave_power,param,t_start,checkpoints_stop);


%         t_start = checkpoints_start/param.Fs_down+param.start_time;
%         t_stop = checkpoints_stop/param.Fs_down+param.start_time;


    else
        t_start = [];
        t_stop = [];
    end
end


function out = InPheeBand(y,Fs_down)

    target_range = [5000 10000];   % frequency range (Hz) to look at, modified, 12/24/2013, L.Zhao
    ref_range = [1000 5000];      % frequency range (Hz) as the background
    ref_range2 = [10000 11000];
    scanpoints = length(y);

    y_fft = abs(fft(y));     % total length is scanpoints
    pheeband = mean(y_fft(round(target_range(1)/(Fs_down/2)*scanpoints/2):round(target_range(2)/(Fs_down/2)*scanpoints/2)));
    refband = mean(y_fft(round(ref_range(1)/(Fs_down/2)*scanpoints/2):round(ref_range(2)/(Fs_down/2)*scanpoints/2)));
    refband2 = mean(y_fft(round(ref_range2(1)/(Fs_down/2)*scanpoints/2):round(ref_range2(2)/(Fs_down/2)*scanpoints/2)));
    if pheeband > refband * 2 
        out = 1;
    else
        out = 0;
    end
end


function t_start = FindPheeStart(wave,wave_unfiltered,wave_power,param,checkpoints)

    Fs_down = param.Fs_down;
    scanlen = param.scanlen;
    spec_shiftlen = param.spec_shiftlen;
    min_phee_len = param.min_phee_len;
    th = param.th;
    start_time = param.start_time;
    pre_th_len = param.pre_th_len;
    start_range = [5000, 10000];        % frequency range to start phee calls
    win_time = 0.005;
    win_size = round(win_time*Fs_down/2)*2;
    
    spec_th1 = 100;
    if param.reversed == 1
        spec_th2 = 5000;
    else
        spec_th2 = 500;
    end

%     ind = find(abs(wave_power)>th);
%     ind2 = diff(ind);
    
        if ~isempty(checkpoints)
%     if ~isempty(ind)
        % add energy filter and judge continuous passing threshold points
%         ind2 = [10;ind2];
%         checkpoints = ind(ind2>1);     % sample points at which the waveform passes threshold
        
        scanned = zeros(size(checkpoints));     % to record whether the checkpoints have been scanned by spectrum
        scanpoints = round(scanlen*Fs_down);
        phee_ind = 1;
        t_start = [];
        
        for i = 1:length(checkpoints)
            if checkpoints(i)/Fs_down + start_time > 146 && checkpoints(i)/Fs_down + start_time  < 150
                aa = 1;
            end
            
            
            if scanned(i) == 0
                IsPhee = InPheeBand(wave_unfiltered(checkpoints(i):min(end,checkpoints(i)+scanpoints-1)),Fs_down);
                if checkpoints(i)+scanpoints+0.2*Fs_down < length(wave)
                    PostIsPhee = InPheeBand(wave_unfiltered(checkpoints(i)+round(0.2*Fs_down):checkpoints(i)+round(0.2*Fs_down)+scanpoints-1),Fs_down);
                else
                    PostIsPhee = 1;
                end
                
                if checkpoints(i)-scanpoints-0.1*Fs_down > 0
                    PreIsPhee = InPheeBand(wave_unfiltered(checkpoints(i)-scanpoints-round(0.01*Fs_down):checkpoints(i)-round(0.01*Fs_down)-1),Fs_down);
                else
                    PreIsPhee = 0;
                    PostIsPhee = 1;
                end
                
                


                if IsPhee && PostIsPhee % && ~PreIsPhee 
                    % Yes. Phee here, start to search the start time.
                    startcheck = max(1,checkpoints(i) - pre_th_len*Fs_down);
                    endcheck = checkpoints(i) + round(0.05*Fs_down);
                    endcheck = min(endcheck,length(wave));
                    save_flag = 0;
                    if checkpoints(i) == 1
                        start_point = 1;
                        save_flag = 1;
                    else
                        spec = spectra(wave(startcheck:endcheck),round(win_size),round(spec_shiftlen*Fs_down),Fs_down,'linear');
                        if i == 47
                            aa = 0;     % for debug breakpoint
                        end
                        timelabel = zeros(1,size(spec,2));
                        
                        for j = 1:size(spec,2)
                            background = median(spec(:,j));
                            [test pos] = max(spec(:,j));
    %                         quant = quantile(spec(:,j),0.8);
    %                         spec_sorted = sort(spec(:,j),'descend');
    %                         test = mean(spec_sorted(1:5));
                            if test > background * spec_th1 ...      % judge by some kind of sparseness
                                && test > max(max(spec)) /spec_th2 
%                                 || ((pos < (round(0.005*Fs_down/2)+1)/(Fs_down/2)*start_range(2)) ...
%                                 && (pos > (round(0.005*Fs_down/2)+1)/(Fs_down/2)*start_range(1)))
%                                 timelabel(j) = 1;
                                if spec(pos-round(400/(1/win_time)),j) < test/10   % phee side should be 10dB lower
                                    start_temp = (j-1)*round(spec_shiftlen*Fs_down);
                                    save_flag = 1;
                                    break;
                                end
                            end
                        end
%                         start_temp = (min(find(timelabel==1))-1)*spec_shiftlen*Fs_down;
                        if save_flag == 1
                            start_point = startcheck + start_temp;
                        end


                    end
                    if save_flag == 1
                        t_start(phee_ind) = (start_point-1)/Fs_down+start_time;

                        % mark the later period as "scanned" for the next
                        % min_phee_len period of checkpoints

                        ind_mark = find(checkpoints(i+1:end)/Fs_down+start_time<t_start(phee_ind)+min_phee_len);
                        scanned(i+ind_mark) = 1;

                        % search for end
                        % look at spectrogram after min_phee_len 

                        phee_ind = phee_ind+1;
                    end
                    
                end

                scanned(i) = 1;
                
                
            end
            
        end
    else
        t_start = [];
        
    end
    if ~isempty(t_start)
        t_start = t_start';
    end
end
           
function t_stop = FindPheeStop(wave,wave_unfiltered,wave_power,param,t_start,checkpoints)
    stop_range = [5000 11000];      % phee frequency band used to judge stop time
    Fs_down = param.Fs_down;
    scanlen = param.scanlen;
    spec_shiftlen = param.spec_shiftlen;
    min_phee_len = param.min_phee_len;
    th = param.th;
    start_time = param.start_time;
    pre_th_len = param.pre_th_len;
    min_interval = param.min_interphrase_interval;
    
    stop_post_len = 0.5;          % post threshold length to search phee stop
    
    spec_th1 = 50;
    spec_th2 = 50;
    win_time = 0.005;
    win_size = round(win_time*Fs_down/2)*2;
    
    if isempty(t_start)
        t_stop = [];
        return
    end
    t_start = t_start - start_time;
% % %     ind = find(abs(wave_power)>th);
% % %     ind_rev = ind(length(ind):-1:1);
% % %     ind2 = -diff(ind_rev);
% % %     ind2 = ind2(length(ind2):-1:1);         
% % %     ind2 = [ind2;10];
% % %     checkpoints = ind(ind2>1);     % sample points at which the waveform passes threshold downward

%     scanned = zeros(size(checkpoints));     % to record whether the checkpoints have been scanned by spectrum
%     scanpoints = round(scanlen*Fs_down);
    if start_time == 300
        aa = 1;
    end
    
%     % avoide small gap within a vocalization, L.Zhao 12/24/2013
%     si = 1;
%     while si <= length(t_start)
%         ind_small = find(abs(checkpoints/Fs_down-t_start(si)) < min_interval);
%         
%         
%         
%     end
    
    
    for i = 1:length(t_start)
        if i ~= length(t_start)
            ind_check = find(checkpoints/Fs_down > t_start(i) & checkpoints/Fs_down < t_start(i+1));
%             ind_check = ind_check(end:-1:1);        % search these threshold points backwards
        else
            ind_check = find(checkpoints/Fs_down > t_start(i));
        end
        
        endcheck = 0;
        save_flag = 0;
        for k = 1:length(ind_check)
            
            startcheck = max(1,checkpoints(ind_check(k)) - 0*Fs_down);
            endcheck = checkpoints(ind_check(k)) + stop_post_len*Fs_down;
            endcheck = min(endcheck,length(wave));
                
            checktime_now = checkpoints(ind_check(k))/Fs_down;      % for debug display
            
            if checkpoints(ind_check(k)) == length(wave)
                stop_temp = length(wave) - startcheck;
                save_flag = 1;
                break
            else
                spec = spectra(wave(startcheck:endcheck),round(win_size),round(spec_shiftlen*Fs_down),Fs_down,'linear');
    %             for j = size(spec,2):-1:1
                for j = 1:size(spec,2)
                    background = median(spec(:,j));
                    [test pos] = max(spec(:,j));
    %                 if pos > (round(0.005*Fs_down/2)+1)/(Fs_down/2)*stop_range(2) || ...
    %                         pos < (round(0.005*Fs_down/2)+1)/(Fs_down/2)*stop_range(1)
    %                     start_temp = (j-1)*round(spec_shiftlen*Fs_down);
    %                     break
    %                 end

    %                         quant = quantile(spec(:,j),0.8);
    %                         spec_sorted = sort(spec(:,j),'descend');
    %                         test = mean(spec_sorted(1:5));
                    if (test < background * spec_th1) || spec(pos-round(400/(1/win_time)),j) < test /10       % judge by some kind of sparseness
%                             || ((pos > (round(0.005*Fs_down/2)+1)/(Fs_down/2)*stop_range(2)) ...
%                             && (pos < (round(0.005*Fs_down/2)+1)/(Fs_down/2)*stop_range(1)))
    %                     && test > max(max(spec)) /spec_th2;
    %                                 timelabel(j) = 1;
                        stop_temp = (j-1)*round(spec_shiftlen*Fs_down);
                        if stop_temp+startcheck+round(0.1*Fs_down) < length(wave)
                            PostIsPhee = InPheeBand(wave_unfiltered(startcheck+stop_temp:startcheck+stop_temp+round(0.01*Fs_down)-1),Fs_down);  % by L.Zhao 12/24/2013
                        else
                            PostIsPhee = 0;
                        end
                        if ~PostIsPhee
                            save_flag = 1;
                            break;
                        end
                    
                    
%                         save_flag = 1;
%                         break;
                    end
                end
            
            
                if j < size(spec,2)
                    break
                end
            end
        end
        % if towards the chunk end can cannot find stop time, use the chunk
        % end time as stop time
        if save_flag == 0 && endcheck == length(wave)
            stop_temp = length(wave) - startcheck;
            save_flag = 1;
        end
        
        if save_flag == 1
            stop_point = stop_temp  + startcheck;
        else
            stop_point = NaN;
        end
        t_stop(i) = (stop_point-1)/Fs_down+start_time;
        
    end
    
    t_stop = t_stop';
    

end
        
        