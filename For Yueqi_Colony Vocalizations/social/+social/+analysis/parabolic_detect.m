% Directional Detecting with a parabolic mic and a reference mic
% This function work on a pair of channels only


function parabolic_detect(Session)
% filepath = '\\datacenterchx.bme.jhu.edu\Recording_Colony_Vocalization\Technical_Tests\';
filepath = '\\datacenterchx.bme.jhu.edu\Recording_Colony_Neural\M9606\';
% filepath = '\\datacenterchx\Recording_Colony_Neural\M28A\';

% filepath = '\\datacenterchx.bme.jhu.edu\Recording_Colony_Vocalization\Backpack Vocalization Tests\';
% filepath = '\\datacenterchx.bme.jhu.edu\Recording_Colony_Vocalization\M93A\';
% filename = 'voc_TestParabolic_S10';
% t_start = 22;        % start of analyze window, in sec
% t_stop = 24;
% ch_parabolic = 3;          % channel for parabolic mic
% ch_ref = 4;          % channel for shotgun mic as a reference

% filename_prefix = 'voc_28A_c_S';
% filename_prefix = 'voc_M112Z_S';
filename_prefix = 'voc_9606_c_S';
session_list = [168,169];

ch_parabolic = 1;          % channel for parabolic mic
ch_ref = 2;          % channel for shotgun mic as a reference


param.spec_th = 5;               % threshold in dB, the parabolic mic intensity should be this number higher than the traditional mic
% param.spec_th = 13;              % for 112Z, 60" distance
% param.spec_th = 5;                 % for 9606, S168,169, Ch1 has lower gain

start_time_debug = 1038;  % starting time in the file for debug only


param.mode = 'file';           % 'file' for offline analysis, 'realtime' for online analysis
param.task = 'detect';
param.ch_parabolic = ch_parabolic;
param.ch_ref = ch_ref;
% buffer_length = 0.02;    % buffer length



peak_th = 20;               % threshold that peak spectrogram should be larger than the median within certain frequency range
voc_dur_min = 0.01;      % in sec, minimum call duration
overlap = 0;



for si = 1:length(session_list)
    filename = [filename_prefix num2str(session_list(si)) '.wav'];
    disp(['Processing ' filename]);
    try
        [y_temp, Fs, nbits] = wavread([filepath,filename],1);

        param.Fs = Fs;

        % param.t_start = t_start;
        % param.t_stop = t_stop;
        % param.Fs = Fs;

        if strcmp(param.mode,'file')
            chunklen = 5;        % in sec
        end
        chunksize = chunklen * Fs;
        fullpath = [filepath filename];
        [m, d] = wavfinfo(fullpath);
        ind1 = strfind(d,':')+1;
        ind2 = strfind(d,'samples')-1;
        samplesize = str2double(d(ind1:ind2));

        Nfor = ceil((samplesize-chunksize)/((chunklen-overlap)*Fs))+1;
        t_start_chunk = cell(1,Nfor);
        t_stop_chunk = cell(1,Nfor);
        t_start = [];
        t_stop = [];
        parfor_progress(Nfor);
        Nstart_debug = ceil((start_time_debug*Fs+1-chunksize)/((chunklen-overlap)*Fs))+1;
        param_out = [];


        ppool = gcp;
        if isempty(ppool)
            parpool;
        end

        parfor ci = 1:Nfor
        % for ci = Nstart_debug:Nfor

            parfor_progress
            y_temp = [];
            N1 = (ci-1)*((chunklen-overlap)*Fs)+1;
            N2 = N1 + chunksize-1;
            if N2 > samplesize
                N2 = samplesize;
            end

            [y_temp temp1 nbits] = wavread([filepath,filename], [N1 N2]);

            y_mean = repmat(mean(y_temp),size(y_temp,1),1);
            y_temp = y_temp-y_mean;
            y_sig = y_temp(:,[ch_parabolic,ch_ref]);

            [spec_out,param_out] = MicChIntensityDiff(y_sig,param);

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

                t_start_temp = (ind_start-1)*shift_time + N1/Fs;
                t_stop_temp = (ind_stop-1)*shift_time + N1/Fs;

                % only select targets with long enough duration
                t_duration = t_stop_temp - t_start_temp;
                ind_dur = find(t_duration >= voc_dur_min);

                t_start_temp = t_start_temp(ind_dur);
                t_stop_temp = t_stop_temp(ind_dur);

                % leave the refining process in the categorization process
                % check if the signal has tonal/harmonic structure
                for jj = 1:length(t_start_temp)
                    t_check = t_start_temp(jj) + (t_stop_temp(jj)-t_start_temp(jj))/2;
                    ind_check = round((t_check - N1/Fs)/shift_time + 1);
        %             ind_bin = find(spec_diff_bin(:,ind_check) == 1);
        %             ind_bin2 = diff(ind_bin);
        %             ind_bin3 = find(ind_bin2>1);
        %             if isempty(ind_bin3)
        %                 ind_bin3 = length(ind_bin);
        %             end
        %             ind_F0 = mean(ind_bin(1:ind_bin3(1)));


                    ind_F0 = find(spec_diff(:,ind_check)==max(spec_diff(:,ind_check)));
        %             mean(spec_diff_bin(round(ind_F0*1.3):round(ind_F0*1.7),ind_check))
                    spec_check = spec{ch_parabolic}(max(1,round(ind_F0*0.2)):min(size(spec_diff,1),round(ind_F0*3)),ind_check);
                    if max(spec_check) > mean(quantile(spec_check,0.75)) + peak_th
                        t_start_chunk{ci} = [t_start_chunk{ci} t_start_temp(jj)];
                        t_stop_chunk{ci} = [t_stop_chunk{ci} t_stop_temp(jj)];
                    end


                end 



        % %         % Visualize results for debug
        % %         figure(200)
        % %         h1 = subplot(3,1,1);
        % %         cla
        % %         imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec{1});
        % %         axis xy
        % %         colorbar
        % % 
        % %         h2 = subplot(3,1,2);
        % %         cla
        % %         imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec_diff);
        % %         xx_range = get(gca,'XLim');
        % %         yy_range = get(gca,'YLim');
        % %         axis xy
        % %         colorbar
        % %         h3 = subplot(3,1,3);
        % %         cla
        % %         hold on
        % %         imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec_diff_bin);
        % %         axis([xx_range,yy_range]);
        % %         axis xy
        % %         colorbar
        % %         colormap gray
        % % 
        % %         for jj = 1:length(t_start_chunk{ci})
        % %             plot([1 1]*t_start_chunk{ci}(jj),[0 Fs/2],'r');
        % %             plot([1 1]*t_stop_chunk{ci}(jj),[0 Fs/2],'r');
        % %         end
        % %         linkaxes([h1 h2 h3],'xy')
        % %         figure(200)
        % %         delete(200)

            end
        end

        parfor_progress(0)


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
        [spec_out,param] = MicChIntensityDiff(zeros(10000,2),param);     % just to get param outside the parfor

        ind = strfind(filename,'.wav');
        savename = ['CallTime_' filename(1:ind-1)];
        savename = strrep(savename,'_denoise','');
        save(savename,'t_start','t_stop','filepath','filename','samplesize','Fs','param'); 
    catch err
        disp(err)
    
    end
end


    % matlabpool close
end