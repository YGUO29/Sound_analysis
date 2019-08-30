% analyze M9606_S15, Aug. 24, 2012


clc;clear;close all

sessions = [3 6 12 13 15 16 17 18];

pulse_period = 2;       % the pulse period set in the program, tolerance here is 10%
min_pulse_dur = 0.008;  % in seconds, minimum pulse duration, 
overlap = 2 * pulse_period;            % overlap between chunks
no_sync_pulse = 0;

chunk_len = 60;         % in seconds
th = 0.2;               % threshold for detecting sync pulses
th_high = 0.95;         % threshold for removing noise pulse

for ss = 1:length(sessions)
    spiketime_sync = [];
    session_num = num2str(sessions(ss));
    audiofile = ['D:\Data\M31W\voc_31W_S' session_num '.wav'];
    neurofile = ['D:\Data\M31W\voc_31W_S' session_num 'n.wav'];
    spikefile_prefix = ['D:\Data\M31W\Spikes\voc_31W_S' session_num '_'];
    
    savename = ['D:\Data\M31W\Spikes\voc_31W_S' session_num 'n_spk.mat'];


    % read sync pulses from both wave files
%   try
    [y, Fs_au, nbits] = wavread(audiofile,1);
    audio_sync_ch = size(y,2);
    [y, Fs_neu, nbits] = wavread(neurofile,1);
    ch_analyze = 1:size(y,2)-1;

    [m d] = wavfinfo(audiofile);
    ind1 = strfind(d,':')+1;
    ind2 = strfind(d,'samples')-1;
    samplesize_au = str2double(d(ind1:ind2));

    [m d] = wavfinfo(neurofile);
    ind1 = strfind(d,':')+1;
    ind2 = strfind(d,'samples')-1;
    samplesize_neu = str2double(d(ind1:ind2));

    N1 = 1;
    N2 = chunk_len * Fs_au;
    pulse_au = [];
    pulse_neu = [];

    % sync pulses in audio files
    while N2 <= samplesize_au && no_sync_pulse == 0
        y = wavread(audiofile, [N1 N2]);
        y = y(:,audio_sync_ch);
        % retrieve timing
        ind = find(y>th);
        
        if isempty(ind)
            no_sync_pulse = 1;
            break
        else
        
            ind2 = diff(ind);
            ind2 = [10;ind2];


            pulse_temp = ind(ind2>1);
            ind_temp = find(ind2>1);
            for i = 1:length(ind_temp)-1
                if ind_temp(i+1) - ind_temp(i) > round(min_pulse_dur*Fs_au)
                    % check for noise peaks
                    if max(y(pulse_temp(i):pulse_temp(i)+round(min_pulse_dur*Fs_au)))<th_high
                        pulse = (pulse_temp(i)+N1-1)/Fs_au;
                        pulse_au = [pulse_au;pulse];   
                        if abs(pulse-1620)<4
                            aa = 1;
                        end
                    end
                end
            end
            if length(ind2) - ind_temp(end) > round(min_pulse_dur*Fs_au)
                if max(y(pulse_temp(length(ind_temp)):pulse_temp(length(ind_temp))+round(min_pulse_dur*Fs_au)))<th_high
                    pulse = (pulse_temp(end)+N1-1)/Fs_au;
                    pulse_au = [pulse_au;pulse];   
                end
            end


            N1 = N2 + 1 - overlap * Fs_au;
            N2 = N2 + chunk_len * Fs_au;
            if N2 > samplesize_au
                N2 = samplesize_au;
            end
            if samplesize_au - N1 < chunk_len * Fs_au
                break
            end
        end
    end
    % remove false pulse due to chunk borders and remove noise
%     period_au = median(diff(pulse_au(1:10)));
%     i = 1;
%     while i < length(pulse_au)
%         if abs(pulse_au(i+1) - pulse_au(i)) < period_au * 0.8
%             pulse_au(i+1) = [];
%         else
%             i = i+1;
%         end
%     end

%     period_au = pulse_period;
%     interval_au = diff(pulse_au);
    
    % remove repeated pulses in between chunks
    if no_sync_pulse == 0
        i = 2;
        pulse_au = sort(pulse_au);
        while i <= length(pulse_au)
            if abs(pulse_au(i)-pulse_au(i-1)) < 0.05
                pulse_au(i) = [];
            else
                i = i + 1;

            end
        end


        % sync pulses in neuro files

        N1 = 1;
        N2 = chunk_len * Fs_neu;
        while N2 <= samplesize_neu
            y = wavread(neurofile, [N1 N2]);
            y = y(:,17);
            % retrieve timing
            ind = find(y>th);

            ind2 = diff(ind);
            ind2 = [10;ind2];

            pulse_temp = ind(ind2>1);
            ind_temp = find(ind2>1);
            for i = 1:length(ind_temp)-1
                if ind_temp(i+1) - ind_temp(i) > round(min_pulse_dur*Fs_neu)
                % check for noise peaks
                    if max(y(pulse_temp(i):pulse_temp(i)+round(min_pulse_dur*Fs_neu)))<th_high
                        pulse = (pulse_temp(i)+N1-1)/Fs_neu;
                        if abs(pulse-1105)<2
                            aa = 1;
                        end
                        pulse_neu = [pulse_neu;pulse];   
                    end
                end
            end
            if length(ind2) - ind_temp(end) > round(min_pulse_dur*Fs_neu)
                if max(y(pulse_temp(length(ind_temp)):pulse_temp(length(ind_temp))+round(min_pulse_dur*Fs_neu)))<th_high
                    pulse = (pulse_temp(end)+N1-1)/Fs_neu;
                    pulse_neu = [pulse_neu;pulse];
                end
            end

            N1 = N2 + 1 - overlap * Fs_au;
            N2 = N2 + chunk_len * Fs_neu;
            if N2 > samplesize_neu
                N2 = samplesize_neu;
            end
            if samplesize_neu - N1 < chunk_len * Fs_neu
                break
            end
        end

        % remove false pulse due to chunk borders and remove noise
    %     period_neu = median(diff(pulse_neu(1:50)));
    %     i = 1;
    %     while i < length(pulse_neu)
    %         if abs(pulse_neu(i+1) - pulse_neu(i)) < period_neu * 0.8
    %             pulse_neu(i+1) = [];
    %         else
    %             i = i+1;
    %         end
    %     end

        % remove repeated pulses in between chunks
        i = 2;
        pulse_neu = sort(pulse_neu);
        while i <= length(pulse_neu)
            if abs(pulse_neu(i)-pulse_neu(i-1)) < 0.05
                pulse_neu(i) = [];
            else
                i = i + 1;
            end
        end

        %% Check both pulse trains to see if there is omitted pulses in only one channel


        pulse_end = min(max(pulse_au),max(pulse_neu))+pulse_period/2;
        pulse_diff{1} = diff(pulse_au(pulse_au<=pulse_end));
        pulse_diff{2} = diff(pulse_neu(pulse_neu<=pulse_end));

        i = 1;
        for j = 1:2 
            inds_bad{j} = find(pulse_diff{j} > pulse_period*1.1 | pulse_diff{j} < pulse_period*0.9);   
        end

        if ~isempty(inds_bad{1}) && ~isempty(inds_bad{2})
            if inds_bad{1}(1) < inds_bad{2}(1)
                ind_bad = inds_bad{1};
            else
                ind_bad = inds_bad{2};
            end


            while i <= length(ind_bad)
                if abs(pulse_diff{1}(ind_bad(i)) - pulse_diff{2}(ind_bad(i)))>pulse_period/2
                    if pulse_diff{1}(ind_bad(i))<pulse_diff{2}(ind_bad(i))
                        pulse_au(ind_bad(i)) = [];

                    else
                        pulse_neu(ind_bad(i)) = [];

                    end
                    pulse_diff{1} = diff(pulse_au(pulse_au<=pulse_end));
                    pulse_diff{2} = diff(pulse_neu(pulse_neu<=pulse_end));

                    % update ind_bad
                    for j = 1:2 
                        inds_bad{j} = find(pulse_diff{j} > pulse_period*1.1 | pulse_diff{j} < pulse_period*0.9);   
                    end

                    if inds_bad{1}(1) < inds_bad{2}(1)
                        ind_bad = inds_bad{1};
                    else
                        ind_bad = inds_bad{2};
                    end


                end
                i = i + 1;
            end
        end


    end
    
    %% read spike data
    for k= 1:length(ch_analyze)
        spk = [];
        spkname = [spikefile_prefix num2str(ch_analyze(k)) '.spk'];

        fid = fopen(spkname);

        if fid ~= -1
            filestr = textscan(fid,'%s','endOfLine','\n');
            filestr = filestr{1};
            for i = 1:length(filestr)
                str = filestr{i};
                if ~isempty(strfind(str,'(second)'))
                    break
                end
            end
            for j = i+1:length(filestr)
                spk(j-i) = str2double(filestr{j});
            end
            
            fclose(fid);
        
            
        end
        spiketime{k} = spk;
    end

    %% change spike timing to synchronize with audio timing
    if no_sync_pulse == 0
        pulse_neu = [0;pulse_neu];
        pulse_au = [0;pulse_au];
        for k = 1:length(ch_analyze)
            if isempty(spiketime{k})
                spiketime_sync{k} = [];
            end
            for j = 1:length(spiketime{k})
                spk = spiketime{k}(j);
                ind_neu = find(pulse_neu > spk);

                if ~isempty(ind_neu) 
                    ind_neu = ind_neu(1) - 1;
                    ind_au = ind_neu;
                    if ind_neu <= length(pulse_au)-1
                        spiketime_sync{k}(j) = pulse_au(ind_au)+(spk-pulse_neu(ind_neu))/(pulse_neu(ind_neu+1)-pulse_neu(ind_neu))*(pulse_au(ind_au+1)-pulse_au(ind_au));   
                    else
                        ind_neu = min(length(pulse_au),length(pulse_neu));
                        ind_au = ind_neu;
                        spiketime_sync{k}(j) = pulse_au(ind_au)+spk-pulse_neu(ind_neu);
                    end
                else     % if spike time is larger than the last pulse time
                    ind_neu = min(length(pulse_au),length(pulse_neu));
                    ind_au = ind_neu;
                    spiketime_sync{k}(j) = pulse_au(ind_au)+spk-pulse_neu(ind_neu);
                end
                time_mark_au = pulse_au(ind_au);
                time_mark_neu = pulse_neu(ind_neu);
                if abs(time_mark_neu-time_mark_au)>1
                    disp(['S' session_num 'Error timing at index: ' ind_au]);
                end
            end

        end
    else
        spiketime_sync = spiketime;
    end
    save(savename,'spiketime_sync');
    disp(['S' session_num ' Done.']);
%   catch err
%       continue
%   end
    
end



