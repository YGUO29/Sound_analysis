% Directional Detecting with a parabolic mic and a reference mic
% This function work on a pair of channels only


function detected_calls = call_detect_parabolic(BehChannel,DetectionParam)

% ch_parabolic = BehChannel.SigDetect;          % channel for parabolic mic
% ch_ref = BehChannel.SigRef;          % channel for shotgun mic as a reference
% ch_feature = BehChannel.SigFeature;

param.spec_th = BehChannel.SpecDiffThreshold;               % threshold in dB, the parabolic mic intensity should be this number higher than the traditional mic
% param.spec_th = 13;              % for 112Z, 60" distance
% param.spec_th = 5;                 % for 9606, S168,169, Ch1 has lower gain

start_time_debug = 1118;  % starting time in the file for debug only
debug_mode = 0;

param.mode = 'file';           % 'file' for offline analysis, 'realtime' for online analysis
param.task = 'detect';
% param.ch_parabolic = ch_parabolic;
% param.ch_ref = ch_ref;
% buffer_length = 0.02;    % buffer length

param.Fs = BehChannel.SigDetect.SampleRate;
Fs = param.Fs;

peak_th = 20;               % threshold that peak spectrogram should be larger than the median within certain frequency range
                            % tried to change from 20 to 10 07/12/2016
voc_dur_min = DetectionParam.MinVocDuration;      % in sec, minimum call duration
overlap = 0;
gap_check_th = DetectionParam.GapCheckThreshold;         % in sec, within this gap need to check if merge is needed
F0_sideband_check = 300;        % in Hz, high and low band around F0 to check energy
voc_band = [4000,min(20000,Fs/2)];        % valid call frequency band
param.compare_band = [4000, 15000];             % compare band for calculating the difference of the parabolic channel and reference channel
pwr_th_factor = 5;         % threshold factor between the narrow band and the wideband - narrowband power around F0
gap_min = DetectionParam.MinGapInterval;        % in sec, interval smaller than this will lead to call merging for sure

% for si = 1:length(session_list)
%     filename = [filename_prefix num2str(session_list(si)) '.wav'];
%     disp(['Processing ' filename]);
%     try
%         [y_temp, Fs, nbits] = wavread([filepath,filename],1);


        % param.t_start = t_start;
        % param.t_stop = t_stop;
        % param.Fs = Fs;

        if strcmp(param.mode,'file')
            chunklen = 5;        % in sec
        end
        chunksize = chunklen * Fs;
%         fullpath = [filepath filename];
%         [m, d] = wavfinfo(fullpath);
%         ind1 = strfind(d,':')+1;
%         ind2 = strfind(d,'samples')-1;
%         samplesize = str2double(d(ind1:ind2));

        samplesize = BehChannel.SigDetect.TotalSamples;

        Nfor = ceil((samplesize-chunksize)/((chunklen-overlap)*Fs))+1;
        t_start_chunk = cell(1,Nfor);
        t_stop_chunk = cell(1,Nfor);
        t_start = [];
        t_stop = [];
        social.util.parfor_progress(Nfor);
        Nstart_debug = ceil((start_time_debug*Fs+1-chunksize)/((chunklen-overlap)*Fs))+1;
        param_out = [];


        ppool = gcp('nocreate');
        if isempty(ppool)
            ppool=parpool('SpmdEnabled',false);
        elseif ppool.SpmdEnabled;
            delete(ppool);
            ppool=parpool('SpmdEnabled',false);
        end

%         parfor ci = 1:3
% for ci = Nstart_debug:Nfor
for ci = 1:Nfor
    social.util.parfor_progress;
    y_temp = [];
    N1 = (ci-1)*((chunklen-overlap)*Fs)+1;
            N2 = N1 + chunksize-1;
            if N2 > samplesize
                N2 = samplesize;
            end

%             [y_temp temp1 nbits] = wavread([filepath,filename], [N1 N2]);
            
            y_temp1 = BehChannel.SigDetect.get_signal([N1/Fs N2/Fs]);
            y_temp2 = BehChannel.SigRef.get_signal([N1/Fs N2/Fs]);
            
            y_temp1=y_temp1{1}-mean(y_temp1{1});
            y_temp2=y_temp2{1}-mean(y_temp2{1});

            [spec_out,param_out] = social.processing.MicChIntensityDiff(y_temp1,y_temp2,param);
            
            spec = spec_out.spec;
            spec_diff = spec_out.spec_diff;
            spec_diff_sign = spec_out.spec_diff_sign;
            spec_diff_bin = spec_out.spec_diff_bin;
            shift_time = param_out.shift_time;
            winsize = param_out.winsize;
            
            
            % find out vocalization period

            ind1 = find(spec_diff_sign>0);
            if ~isempty(ind1)
                ind2 = diff(ind1);
                ind_start = ind1(find([10 ind2]>1));
                ind_stop = ind1(find([ind2 10]>1));

                % only select targets with long enough duration
                ind_t_duration = ind_stop - ind_start;
                ind_dur = find(ind_t_duration >= voc_dur_min/5/shift_time);

                ind_start = ind_start(ind_dur);
                ind_stop = ind_stop(ind_dur);
                
                % if bad frequency, remove it
                i = 1;
                while i <= length(ind_start)
                    [~, F0_ind_phrase] = max(spec_diff(:,ind_start(i):ind_stop(i)));
                    F0_ind_mean = round(mean(F0_ind_phrase));
                    
                    
                    
                    
                    if F0_ind_mean < voc_band(1)/Fs*winsize || F0_ind_mean > voc_band(2)/Fs*winsize 
                        ind_start(i) = [];
                        ind_stop(i) = [];
                        
                    else
                        i = i + 1;
                    end
                end
                
                % leave the refining process in the categorization process
                % check if the signal has tonal/harmonic structure
                ind_start_new = [];
                ind_stop_new = [];
                for jj = 1:length(ind_start)
%                     t_check = t_start_temp(jj) + (t_stop_temp(jj)-t_start_temp(jj))/2;
                    ind_check = round(ind_start(jj) + (ind_stop(jj)-ind_start(jj))/2);
        %             ind_bin = find(spec_diff_bin(:,ind_check) == 1);
        %             ind_bin2 = diff(ind_bin);
        %             ind_bin3 = find(ind_bin2>1);
        %             if isempty(ind_bin3)
        %                 ind_bin3 = length(ind_bin);
        %             end
        %             ind_F0 = mean(ind_bin(1:ind_bin3(1)));


                    ind_F0 = find(spec_diff(:,ind_check)==max(spec_diff(:,ind_check)));
        %             mean(spec_diff_bin(round(ind_F0*1.3):round(ind_F0*1.7),ind_check))
                    spec_check = spec{1}(max(1,round(ind_F0*0.2)):min(size(spec_diff,1),round(ind_F0*3)),ind_check);
                    if max(spec_check) > mean(quantile(spec_check,0.75)) + peak_th
                        ind_start_new = [ind_start_new ind_start(jj)];
                        ind_stop_new = [ind_stop_new ind_stop(jj)];
                    end


                end 
                ind_start = ind_start_new;
                ind_stop = ind_stop_new;

                
                % merge small pieces based on calls in the SigDetect
                % signal
                F0_ind_sideband_check = round(F0_sideband_check/Fs*winsize);
                i = 1;
                while i <= length(ind_start)-1
                    if ind_start(i+1) - ind_stop(i) < round(gap_check_th/shift_time)
                        % if average energy (bandpass filtered) in the gap is
                        % similar to within the i-th piece (the very end part of it), then merge the two
                        % pieces.
                        ind_start_check = max(ind_start(i),ind_stop(i)-10);
                        [~, F0_ind_phrase] = max(spec_diff(:,ind_start_check:ind_stop(i)));
                        F0_ind_mean = round(mean(F0_ind_phrase));
                        if F0_ind_mean-F0_ind_sideband_check > 1 && F0_ind_mean+F0_ind_sideband_check < size(spec{1},1)
                            energy_phrase = mean(mean(10.^(spec{1}(F0_ind_mean-F0_ind_sideband_check:F0_ind_mean+F0_ind_sideband_check,ind_start_check:ind_stop(i))/10)));
                            energy_gap = mean(mean(10.^(spec{1}(F0_ind_mean-F0_ind_sideband_check:F0_ind_mean+F0_ind_sideband_check,ind_stop(i):ind_start(i+1))/10)));
                            if abs(energy_gap-energy_phrase)/energy_phrase < 0.5 || ind_start(i+1)-ind_stop(i) < gap_min/shift_time
                                ind_start(i+1) = [];
                                ind_stop(i) = [];
                            else
                                i = i + 1;

                            end
                        else
                            i = i + 1;
                        end
                    else
                        i = i + 1;
                    end
                    
                end
                
                % throw out short pieces again
                ind_t_duration = ind_stop - ind_start;
                ind_dur = find(ind_t_duration >= voc_dur_min/shift_time);

                ind_start = ind_start(ind_dur);
                ind_stop = ind_stop(ind_dur);

                
%                 % if wide band call, remove it
%                 i = 1;
%                 while i <= length(ind_start)
%                     [~, F0_ind_phrase] = max(spec_diff(round(voc_band(1)/Fs*winsize):round(voc_band(2)/Fs*winsize),ind_start(i):ind_stop(i)));
%                     F0_ind_phrase = F0_ind_phrase - 1 + round(voc_band(1)/Fs*winsize);
%                     
%                     % calculate F0 energy
%                     ind1_narrow = max(round(voc_band(1)/Fs*winsize),round((F0_ind_phrase-F0_sideband_check/Fs*winsize)));
%                     ind2_narrow = min(round(voc_band(2)/Fs*winsize),round((F0_ind_phrase+F0_sideband_check/Fs*winsize)));
%                     ind1_wide = max(round(voc_band(1)/Fs*winsize),round((F0_ind_phrase-F0_sideband_check*2/Fs*winsize)));
%                     ind2_wide = min(round(voc_band(2)/Fs*winsize),round((F0_ind_phrase+F0_sideband_check*2/Fs*winsize)));
%                     ind1_low = round(voc_band(1)/2/Fs*winsize);     % lower frequency band
%                     ind2_low = round(voc_band(2)/2/Fs*winsize);
%                     pwr_narrow = [];
%                     pwr_wide = [];
%                     pwr_low = [];
%                     for j = 1:ind_stop(i)-ind_start(i)+1
%                         pwr_narrow(j) = sum(10.^(spec_diff(ind1_narrow(j):ind2_narrow(j),j-1+ind_start(i))/10));
%                         pwr_wide(j) = sum(10.^(spec_diff(ind1_wide:ind2_wide,j-1+ind_start(i))/10));
%                         pwr_low(j) = sum(10.^(spec_diff(ind1_low:ind2_low,j-1+ind_start(i))/10));
%                     end
%                     pwr_den_narrow = pwr_narrow./(ind2_narrow-ind1_narrow);
%                     pwr_den_flank = (pwr_wide - pwr_narrow)./(ind2_wide-ind2_narrow+ind1_narrow-ind1_wide);
%                     pwr_den_low = pwr_low./(ind2_low-ind1_low);
%                     pwr_den_ratio = sum(pwr_den_narrow)./sum(pwr_den_flank);
%                     pwr_den_ratio_low = sum(pwr_den_narrow)./sum(pwr_den_low);
%                     
%                     
%                     if pwr_den_ratio < pwr_th_factor && pwr_den_ratio_low < pwr_th_factor
%                         ind_start(i) = [];
%                         ind_stop(i) = [];
%                         
%                     else
%                         i = i + 1;
%                     end
%                 end


                % convert to time
                t_start_temp = (ind_start-1)*shift_time + N1/Fs;
                t_stop_temp = (ind_stop-1)*shift_time + N1/Fs;
                

                
                t_start_chunk{ci} = t_start_temp;
                t_stop_chunk{ci} = t_stop_temp;
                

                % Visualize results for debug
                
                if debug_mode == 1
                    figure(200)
                    h1 = subplot(3,1,1);
                    cla
                    imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec{1});
                    axis xy
                    colorbar
                    title('Parabolic Ch')

                    h2 = subplot(3,1,2);
                    cla
                    imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec_diff);
                    xx_range = get(gca,'XLim');
                    yy_range = get(gca,'YLim');
                    axis xy
                    colorbar
                    title('Diff')

                    h3 = subplot(3,1,3);
                    cla
                    hold on
                    imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec_diff_bin);
                    axis([xx_range,yy_range]);
                    axis xy
                    colorbar
                    colormap gray
                    title('Diff (bin)')
                    xlabel('Time (s)')

                    for jj = 1:length(t_start_chunk{ci})
                        plot([1 1]*t_start_chunk{ci}(jj),[0 Fs/2],'r');
                        plot([1 1]*t_stop_chunk{ci}(jj),[0 Fs/2],'r');
                    end 
                    linkaxes([h1 h2 h3],'xy')
                    figure(200)
                    delete(200)
                end

            end
        end

        social.util.parfor_progress(0);


        for ci = 1:Nfor
            t_start = [t_start;t_start_chunk{ci}'];
            t_stop = [t_stop;t_stop_chunk{ci}'];

        end

        %% combine the chunks


        [t_start IX] = sort(t_start);
        t_stop = t_stop(IX);
        % combine the same call seperated by the chunk border
        i = 2;
        while i <= length(t_start)
            if abs(t_start(i)-t_stop(i-1)) < 0.05
                t_start(i) = [];
                t_stop(i-1) = [];
            else
                i = i + 1;
            end
        end

        % combine the same call which appears twice
        i = 2;
        while i <= length(t_start)
            if abs(t_start(i)-t_start(i-1)) < 0.1 || abs(t_stop(i)-t_stop(i-1)) < 0.1
                if t_stop(i) - t_start(i) > t_stop(i-1)-t_start(i-1)
                    t_start(i-1) = [];
                    t_stop(i-1) = [];
                else
                    t_start(i) = [];
                    t_stop(i) = [];
                end
            else
                i = i + 1;
            end
        end

        % %% Reject calls that are too short
        % i = 1;
        % while i <= length(t_start)
        %     if abs(t_stop(i)-t_start(i)) < voc_dur_min
        %         t_start(i) = [];
        %         t_stop(i) = [];
        %     else
        %         i = i + 1;
        %     end
        % end

        %% Modify the data to cells
        t_start_c{1} = t_start;
        t_start = t_start_c;
        t_start{2} = [];
        t_stop_c{1} = t_stop;
        t_stop = t_stop_c;
        t_stop{2} = [];


        %% save
        [spec_out,param] = social.processing.MicChIntensityDiff(zeros(10000,1),zeros(10000,1),param);     % just to get param outside the parfor

%         ind = strfind(filename,'.wav');
%         savename = ['CallTime_' filename(1:ind-1)];
%         savename = strrep(savename,'_denoise','');
%         save(savename,'t_start','t_stop','filepath','filename','samplesize','Fs','param'); 


%     catch err
%         disp(err)
%     
%     end
% end

    % Construct VocalPhrase events
    clear temp1;
    temp1=social.event.Phrase.empty;
    for i=1:length(t_start{1})
        temp1(i)=social.event.Phrase(BehChannel.Session,BehChannel,t_start{1}(i),t_stop{1}(i));    
    end

   
    detected_calls = temp1;

    % matlabpool close
end