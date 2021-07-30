%% batch process sounds in a folder
% pre-process for ESC-50 dataset: select subset of sounds from 2000 sounds
%% choose folder 
% addpath(genpath(cd))
% clear all
% soundpath = uigetdir('D:\SynologyDrive\=sounds=\', 'select folder to process');

% where to get your sounds
soundpath = 'D:\SynologyDrive\=sounds=\Natural sound\Natural_Speech_CSS10\';
% meta_data = readtable('D:\SynologyDrive\=sounds=\Natural sound\Natural_ESC-50\meta\esc50.csv');
% ======== get information of the sounds ===========
addpath(genpath(soundpath))
% get the info list, and sort the names in natural order (same as order in
% the folder)
list = dir(fullfile(soundpath,'*.wav'));
% list = dir(fullfile(soundpath,'*.m4a'));
[names_sound, idx] = natsortfiles({list.name});
list = list(idx);

%% ======= go over all sounds ===================
fs = 44100;
resampleON = 0;
procON = 1;
proc_method = 'ramp';
plotON = 0; 
saveON = 1;
if saveON
    savefilepath = uigetdir('D:\SynologyDrive\=sounds=\', 'select folder to save');
%     savefilepath = 'D:\SynologyDrive\=sounds=\Vocalization\temp_for capsule\';
end
% close(fwait)
fwait = waitbar(0,'Started getting calls ...');
S = struct;

% for i = 1:155
for i = 1:length(list)
    waitbar(i/length(list),fwait,['Getting sounds from session ',num2str(i),'/',num2str(length(list))]);
    % resample
%     [Sd.wav, Sd.fs] = audioread([soundpath, S_new(i).soundname]);
    [Sd.wav, Sd.fs] = audioread([soundpath, list(i).name]);
    if resampleON
        Sd.wav = resample(Sd.wav, fs, Sd.fs);
        Sd.fs = fs; 
    end
    newSd = Sd;
    
    
    % maximize waveform to [-1 1]
    Sd.wav = Sd.wav./max(abs(Sd.wav));

    % get information
    S(i).soundname = list(i).name; 
%     S(i).soundname = S_new(i).soundname;
    S(i).dur = length(Sd.wav)./Sd.fs; % duration in seconds
    S(i).fs = Sd.fs;
    S(i).std = std(Sd.wav);
    
%     ind_sound = find(strcmp(meta_data.filename, S_new(i).soundname));
%     S(i).tag = meta_data.target(ind_sound)+1;
%     S(i).category = meta_data.category(ind_sound);

%     if plotON
%         subplot(3,5,i)
%         [~] = getSpectrogram(Sd, plotON, 0.01);
%     end

if procON
%     if plotON
%         f1 = figurex([532         592        1827         746]);
%     end
    switch proc_method
        
        case 'filter' % RAMP and highpass filter (for denoising)
        %     d = designfilt('bandpassiir',...
        %         'FilterOrder', 4,...
        %         'PassbandFrequency1', 3e3,...
        %         'PassbandFrequency2', 2.1e4,...
        %         'SampleRate', 5e4);
            d = designfilt('highpassiir',...
                'FilterOrder', 3,...
                'PassbandFrequency', 3e3,...
                'SampleRate', 5e4);
        %     fvtool(d)
        %     newSd.wav = filtfilt(d,Sd.wav); 
            newSd.wav = Sd.wav;
            newSd.fs = Sd.fs;
            ramp_time = 0.1; % second
            % add ramp at beginning (linear 0.1s)
            newSd.wav(1:round(newSd.fs*ramp_time))...
                = newSd.wav(1:round(newSd.fs*ramp_time)).*linspace(0, 1, round(newSd.fs*ramp_time))';
            % add ramp at the end (linear 0.1s)
            newSd.wav(end-round(newSd.fs*ramp_time)+1:end)...
                = newSd.wav(end-round(newSd.fs*ramp_time)+1:end).*linspace(1, 0, round(newSd.fs*ramp_time))';
        case 'pad'
            newSd = Sd;
            newSd.wav = zeros(ceil(max(dur_mat).*Sd.fs),1);
            newSd.wav(1:length(Sd.wav)) = Sd.wav;
            S(i).spectrogram = getSpectrogram(newSd,0,0.01);
        case 'ramp'
            ramp_time = 0.1; % second
            newSd = Sd;
            newSd.wav = Sd.wav(1:floor(2*Sd.fs)); % take 2s only
            
             % add ramp at beginning (linear 0.1s)
            newSd.wav(1:round(newSd.fs*ramp_time))...
                = newSd.wav(1:round(newSd.fs*ramp_time)).*linspace(0, 1, round(newSd.fs*ramp_time))';
            % add ramp at the end (linear 0.1s)
            newSd.wav(end-round(newSd.fs*ramp_time)+1:end)...
                = newSd.wav(end-round(newSd.fs*ramp_time)+1:end).*linspace(1, 0, round(newSd.fs*ramp_time))';
        case 'Reverse'
            newSd = Sd;
            newSd.wav = Sd.wav(end:-1:1);
        case 'MatchSpec'
            newSd = Sd;
            [newSd.wav, Sd.wav] = MatchSpec(Sd, plotON);
%             soundsc(Sd.wav,Sd.fs)
%             pause
%             soundsc(newSd.wav,newSd.fs)
%             pause
        case 'MatchEnv'
            newSd = Sd;
            [newSd.wav, Sd.wav] = MatchEnv(Sd, plotON);
        case 'MatchCochEnv'
            newSd = Sd;
            [newSd.wav, Sd.wav] = MatchCochEnv(Sd, plotON);
        case 'MatchSpecEnv'
            newSd = Sd;
            [newSd.wav, Sd.wav] = MatchSpecEnv(Sd, plotON);
        otherwise
    end

    if plotON

        if strcmp(plot_method, 'spectrogram')
            f1 = figurex([532         592        1827         746]);

            % =========== plot figures, waveform and spectrogram ================
            subplot(2,3,1) % original waveform
            plot(1/Sd.fs:1/Sd.fs:S(i).dur, Sd.wav);
            title('Original sound')
            xlim([0, S(i).dur])
            
            subplot(2,3,3) % original spectrogram
            getSpectrogram(Sd,1,0.01);
            title('Spectrogram')
            
            subplot(2,3,4) % new waveform
            plot(1/newSd.fs:1/newSd.fs:S(i).dur, newSd.wav);
            xlim([0, S(i).dur])
            title(['Modified sound, ',proc_method])
            
            subplot(2,3,6) % new spectrogram
            getSpectrogram(newSd,1,0.01);
            title('Spectrogram')
            

        elseif strcmp(plot_method, 'cochleogram')
            figurex;
            % =========== plot figures, waveform and spectrogram ================
            subplot(2,3,1) % original waveform
            plot(1/Sd.fs:1/Sd.fs:S(i).dur, Sd.wav);
            xlim([0, S(i).dur])
            
            subplot(2,3,2) % original spectrogram
            [~,~,~] = getCochleogram_halfcosine(Sd, P, plotON);
            
            subplot(2,3,4) % new waveform
            plot(1/newSd.fs:1/newSd.fs:S(i).dur, newSd.wav);
            xlim([0, S(i).dur])
            
            subplot(2,3,5) % new spectrogram
            [~,~,~] = getCochleogram_halfcosine(newSd, P, plotON);
           
        else
            disp('check plot_mothod')
        end
        
%         soundsc(Sd.wav,Sd.fs)
%         pause
%         soundsc(newSd.wav,newSd.fs)
        
    end
else % if no processing required
%     if plotON
%         if strcmp(plot_method, 'spectrogram')
%             figurex,
%             % =========== plot figures, waveform and spectrogram ================
%             subplot(1,2,1)
%             plot(1/Sd.fs:1/Sd.fs:S(i).dur, Sd.wav);
%             xlim([0, S(i).dur])
%             subplot(1,2,2)
%             getSpectrogram(Sd,1,0.01);
%         elseif strcmp(plot_method, 'cochleogram')
%             figure,
%             % =========== plot figures, waveform and spectrogram ================
%             subplot(1,2,1)
%             plot(1/Sd.fs:1/Sd.fs:S(i).dur, Sd.wav);
%             xlim([0, S(i).dur])
%             subplot(1,2,2)
% %             [~,~,~,~,~] = getCochleogram(Sd, 0.01, 'ERB', plotON);
%             [Mat_env, Mat_env_ds, MatdB, cf, t_ds] = getCochleogram(Sd, 0.005, 'ERB', plotON);
%         else
%             disp('check plot_mothod')
%         end
% %         soundsc(Sd.wav,Sd.fs)
% %         pause
%     end
end    

if saveON
    % =========== save new audio ================
%     newSd.wav = Sd.wav(:,1);
%     newSd.wav = newSd.wav./max(abs(newSd.wav));
%     audiowrite([savefilepath, '\', list(i).name], newSd.wav, newSd.fs)
%     name_parts = strsplit(list(i).name, '_');
%     audiowrite([savefilepath, '\', proc_method, '_', strjoin(name_parts(2:end),'_')], newSd.wav, newSd.fs)
    audiowrite([savefilepath, '\', 'Speech_', list(i).name], newSd.wav, newSd.fs)


end    
% close(fwait)

end
% for non-vocalizations: get statistics
dur_mat = cell2mat({S(:).dur});
std_mat = cell2mat({S(:).std});
tag_mat = cell2mat({S(:).tag});


