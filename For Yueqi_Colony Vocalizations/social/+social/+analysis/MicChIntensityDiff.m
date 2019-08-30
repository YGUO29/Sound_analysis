function [out, param_out] = MicChIntensityDiff(y_sig,param_in)
% Compare the intensity difference of two recording channels

% persistent Fs frame_win shift_time winsize voc_detect_band voc_detect_band_ind spec_avg_win time_avg_win

    spec_th = param_in.spec_th;
% %     if isempty(frame_win)
        % define parameters only when first called

        if strcmp(param_in.mode,'file')
            Fs = param_in.Fs;

            frame_win = 0.01;
            if strcmp(param_in.task,'detect')
                shift_time = 0.002;       % shift step in spectrogram
                voc_detect_band = [4000 10000]; % in Hz, frequency range for call detection
            elseif strcmp(param_in.task,'classify')
                shift_time = 0.001;       % shift step in spectrogram
            elseif strcmp(param_in.task,'GetCallF0')    % get some parameters from the parent function
                shift_time = param_in.shift_time;
                frame_win = param_in.win_time;
                voc_detect_band = [1000 14000]; % in Hz, frequency range for call detection
            end
            
        else
            Fs = 50000;         % change it to auto detect later
            frame_win = 0.01;        % in sec
            shift_time = 0.001;
        end

        winsize = 2*round(frame_win*Fs/2);
        
        voc_detect_band_ind = voc_detect_band/Fs*winsize;
        spec_avg_win = hamming(round(500/(1/frame_win)));
    %     spec_avg_win = hamming(3);
        spec_avg_win = spec_avg_win/sum(spec_avg_win);
        if strcmp(param_in.task,'GetCallF0')
            time_avg_win = hamming(24);
        else
            time_avg_win = hamming(6);
        end
        time_avg_win = time_avg_win/sum(time_avg_win);
% %     end

%     spec = zeros(winsize/2+1,ceil((size(y_sig,1)-winsize)/(shift_time*Fs)));
    spec = cell(1,2);
    spec_smooth1 = spec;
    spec_smooth = spec;
%     for i = 1:2
%         spec_smooth1{i} = spec;
%         spec_smooth{i} = spec;
%     end
    for i = 1:2
        
        [spec{i},x,y] = spectra(y_sig(:,i),winsize,round(shift_time*Fs),Fs,'log','gausswin');
%         for j = 1:size(spec{i},2)
%             spec_smooth1{i}(:,j) = filtfilt(spec_avg_win,1,spec{i}(:,j));
%         end
% %         spec_smooth1{i} = spec{i};
%         for j = 1:size(spec{i},1)
%             spec_smooth{i}(j,:) = filtfilt(time_avg_win,1,spec_smooth1{i}(j,:));
%         end
    end
%     spec_diff = spec_smooth{1} - spec_smooth{2};
    spec_diff = spec{1} - spec{2};
    
    for j = 1:size(spec{i},2)
        spec_diff_smooth(:,j) = filtfilt(spec_avg_win,1,spec_diff(:,j));
    end
    for j = 1:size(spec{i},1)
        if size(spec_diff_smooth,2) > length(time_avg_win)*3    % needed for filtfilt
            spec_diff(j,:) = filtfilt(time_avg_win,1,spec_diff_smooth(j,:));
        else
            spec_diff(j,:) = spec_diff_smooth(j,:);
        end
    end
    spec_diff_bin = zeros(size(spec_diff));
    spec_diff_bin(spec_diff > spec_th) = 1;
    spec_diff_bin(spec_diff <= spec_th) = 0;
    spec_diff_sign = sum(spec_diff_bin(voc_detect_band_ind(1):voc_detect_band_ind(2),:),1);
    
    param_out = param_in;
    param_out.shift_time = shift_time;
    param_out.winsize = winsize;
    param_out.spec_th = spec_th;
    out.spec = spec;
    out.spec_diff = spec_diff;
    out.spec_diff_sign = spec_diff_sign;
    out.spec_diff_bin = spec_diff_bin;
    
    
end