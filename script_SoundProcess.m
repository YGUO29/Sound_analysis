% script_SoundProcess:
% add envolope ramping
% set proper duration
clear all
% soundpath = 'D:\=sounds=\Natural sound\Natural_JM original';
soundpath = 'D:\=sounds=\Vocalization\LZ_AudFilt\TR';
% soundpath = 'D:\=sounds=\Vocalization\Voc_jambalaya';
% savefilepath = 'D:\=sounds=\Vocalization\LZ_ControlSounds\LZ_MatchEnv\TR\';
addpath(genpath(soundpath))
list = dir(fullfile(soundpath,'*.wav'));
[names_sound, idx] = natsortfiles({list.name});
list = list(idx);

list_sub = cell(6,2);
list_sub(:,1) = {'M29A'; 'M64A'; 'M91C'; 'M92C'; 'M93A'; 'M9606'};
list_sub(:,2) = mat2cell([1:6]',ones(6,1));
%% go over all sounds
addpath('D:\=code=\Sound_analysis');
savefilepath = 'D:\=sounds=\Vocalization\LZ_ControlSounds\LZ_MatchEnv_lowpass_80Hz\TR';
proc_method = 'MatchEnv'; 
plot_method = 'spectrogram'; % spectrogram or cochleogram
% filter - high pass filter at 3kHz\
% pad - padding sounds to a certain duration
% MatchSpec - match spectrum (phase scramble)
% MatchEnv - match envelope (extract envelope and apply to pink noise)
% MatchCochEnv - match envelope of each cochleogram channel, fill in carrier with white noise
% MatchSpecEnv - match spectrum and envelope

procON = 1;
plotON = 0; 
saveON = 1;
% close(fwait)
fwait = waitbar(0,'Started getting calls ...');
S = struct;
% for i = 50
for i = 1:length(list)
    waitbar(i/length(list),fwait,['Getting calls from session ',num2str(i),'/',num2str(length(list))]);

    [Sd.wav, Sd.fs] = audioread(list(i).name);
    Sd.wav = resample(Sd.wav, 44100, Sd.fs);
    Sd.fs = 44100; 
    % get information
    S(i).soundname = list(i).name;
    S(i).dur = length(Sd.wav)./Sd.fs; % duration in seconds
    session_name_temp = strsplit(list(i).name(1:end-4),'_');
    S(i).sub = session_name_temp{2};
    S(i).subid = list_sub(find(strcmp(list_sub(:,1),S(i).sub)), 2);
    S(i).subid = cell2mat(S(i).subid);
    S(i).std = std(Sd.wav);
    S(i).fs = Sd.fs;
if procON
    if plotON
        f1 = figurex([532         592        1827         746]);
    end
    switch proc_method
        case 'filter'
        % =========== RAMP & filter ================

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
            newSd.wav(1:round(newSd.fs*0.1))...
                = newSd.wav(1:round(newSd.fs*0.1)).*linspace(0, 1, round(newSd.fs*0.1))';
            newSd.wav(end-round(newSd.fs*0.1)+1:end)...
                = newSd.wav(end-round(newSd.fs*0.1)+1:end).*linspace(1, 0, round(newSd.fs*0.1))';
        case 'pad'
            newSd = Sd;
            newSd.wav = zeros(ceil(max(dur_mat).*Sd.fs),1);
            newSd.wav(1:length(Sd.wav)) = Sd.wav;
            S(i).spectrogram = getSpectrogram(newSd,0,0.01);
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
    if plotON
        if strcmp(plot_method, 'spectrogram')
            figurex,
            % =========== plot figures, waveform and spectrogram ================
            subplot(1,2,1)
            plot(1/Sd.fs:1/Sd.fs:S(i).dur, Sd.wav);
            xlim([0, S(i).dur])
            subplot(1,2,2)
            getSpectrogram(Sd,1,0.01);
        elseif strcmp(plot_method, 'cochleogram')
            figure,
            % =========== plot figures, waveform and spectrogram ================
            subplot(1,2,1)
            plot(1/Sd.fs:1/Sd.fs:S(i).dur, Sd.wav);
            xlim([0, S(i).dur])
            subplot(1,2,2)
%             [~,~,~,~,~] = getCochleogram(Sd, 0.01, 'ERB', plotON);
            [Mat_env, Mat_env_ds, MatdB, cf, t_ds] = getCochleogram(Sd, 0.005, 'ERB', plotON);
        else
            disp('check plot_mothod')
        end
        soundsc(Sd.wav,Sd.fs)
        pause
        
    end
end    

if saveON
    % =========== save new audio ================
    newSd.wav = newSd.wav./max(abs(newSd.wav));
    audiowrite([savefilepath, '\', list(i).name], newSd.wav, newSd.fs)
end    
% close(fwait)

end

%% normalize sound level 
savefilepath = 'D:\=sounds=\Vocalization\LZ_AudFilt\Norm';
if ~exist(savefilepath, 'dir')
    mkdir(savefilepath)
end
power_min = min(cell2mat({S.std})) % min of power
fwait = waitbar(0,'Started getting calls ...');

for i = 1:length(list)
    waitbar(i/length(list),fwait,['Getting calls from session ',num2str(i),'/',num2str(length(list))]);
    [Sd.wav, Sd.fs] = audioread(list(i).name);
    newSd.wav = Sd.wav.*(power_min/S(i).std);
    newSd.fs = Sd.fs;
    S(i).std_norm =  std(newSd.wav);
    
    audiowrite([savefilepath, '\', list(i).name], newSd.wav, newSd.fs)
end
figure, 
subplot(2,1,1)
plot(cell2mat({S.std})); title('std before normalization')
subplot(2,1,2)
plot(cell2mat({S.std_norm})); title('std after normalization')


%% get statistics of original vocalizations
dur_mat = cell2mat({S(:).dur});
subid_mat = cell2mat({S(:).subid});

dur = cell(1,6);
nCall = ones(1,6);
for i = 1:6
    ind = find(subid_mat == i);
    dur{i} = dur_mat(ind);
%     dur{i} = dur{i}(dur{i}>=0.7);
    nCall(i) = length(dur{i});
end

figure,
for i = 1:6
subplot(2,3,i)
hist(dur{i},100)
title(list_sub{i,1})
end

%% plot clusters of vocalization based on MDS
X_mat = zeros(size(S(1).spectrogram.ftyydB));
X_mat = repmat(X_mat,1,1,length(S));

for i = 1:length(S)
%     X_mat_size(:,:,i) = size(S(i).spectrogram.ftyydB);
    X_mat(:,:,i) = S(i).spectrogram.ftyydB;
end
X = reshape(X_mat, [size(X_mat,1)*size(X_mat,2), size(X_mat,3)]);
D = pdist(X');
D = squareform(D);
%%
Y = mdscale(D,2);
figure, 
for i = 1:size(D,1)
    h = scatter(Y(i,1), Y(i,2)); hold on

    h = scatter3(Y(i,1), Y(i,2), Y(i, 3)); hold on
    if contains(S(i).soundname,'TR')
        h.MarkerEdgeColor = 'r';
    elseif contains(S(i).soundname,'TP')
        h.MarkerEdgeColor = 'm';
    elseif contains(S(i).soundname,'TW')
        h.MarkerEdgeColor = 'g';
    elseif contains(S(i).soundname,'MX')
        h.MarkerEdgeColor = 'k';
    else 
        h.MarkerEdgeColor = 'c';
    end
    
    switch S(i).subid
        case 1
            h.Marker = 'o';
        case 2  
            h.Marker = 's';
        case 3
            h.Marker = '+';
        case 4
            h.Marker = '.';
        case 5 
            h.Marker = '^';
        otherwise
            h.Marker = '*';
    end
end
%% ====== pick sounds =====
i_temp = zeros(1,length(list));
for i = 1:length(list)
session_name_temp = strsplit(list(i).name(1:end-4),'_');
i_temp(i) = strcmp(session_name_temp{1},'M29A');
end
find(i_temp)

%%
fwait = waitbar(0,'Started getting calls ...');
S = struct;
j = 1;
figure,
% for i = 213:213+5
for i = 1:length(list)
    waitbar(i/length(list),fwait,['Getting calls from session ',num2str(i),'/',num2str(length(list))]);

    [Sd.wav, Sd.fs] = audioread(list(i).name);
    if length(Sd.wav)./Sd.fs >= 0.7
        S(j).ind = i;
        S(j).dur = length(Sd.wav)./Sd.fs; % duration in seconds
        session_name_temp = strsplit(list(i).name(1:end-4),'_');
        S(j).sub = session_name_temp{1};
        S(j).subid = list_sub(find(strcmp(list_sub(:,1),S(j).sub)), 2);
        S(j).subid = cell2mat(S(j).subid);
  
        getSpectrogram(Sd,1,0.01)
        soundsc(Sd.wav, Sd.fs)
        title(S(j).sub)
        
        S(j).goodness = input('How is this call? ')
        if S(j).goodness==2
            soundsc(Sd.wav, Sd.fs)
            S(j).goodness = input('How is this call? ')
        end
        j = j+1;

    end
end
% length of S is after screening the duration

goodness = cell2mat({S(:).goodness});
subid = cell2mat({S(:).subid});
ind = cell2mat({S(:).ind});
ind_good = find(goodness);
subid_select = subid(ind_good);
ind_select = ind(ind_good);

%%
% save_ind = zeros(1,length(list));
ind_temp = 41:80;
%81:length(list);
% ind_temp = ind_select(find(subid_select == 6));
figure('DefaultAxesFontSize',18, 'DefaultLineLineWidth', 2,'color','w', 'Position', [1345 74 1449 789]);
% ind_temp = find(save_ind);
[p,n] = numSubplots(length(ind_temp));

for k = 1:length(ind_temp)
    i = ind_temp(k);
    [Sd.wav, Sd.fs] = audioread(list(i).name);
    subplot(p(1), p(2),k)
    getSpectrogram(Sd,1,0.01);
    axis square
    title([num2str(k), ', ', list(i).name])
    colorbar off
%     copyfile([soundpath, '\', list(i).name], ['D:\=sounds=\Vocalization\LZ_original\LZ_select\MX\', list(i).name])
end


%% temp script (compare cochleaogram before & after noise reduction)
soundname = 'PH_M92C_S88_call53.wav';
type = 'PH';
% unfiltered
path = ['D:\=sounds=\Vocalization\LZ_ControlSounds\LZ_MatRamp\', type];
[Sd.wav, Sd.fs] = audioread(fullfile(path, ['Ramp_', soundname]));
plotON = 1;

figure('position', [ 307         563        1881         420]),
subplot(1,3,2)
[Mat_env, Mat_env_ds1, MatdB, cf, t_ds] = getCochleogram(Sd, 0.001, 'ERB', plotON);
% filtered
path = ['D:\=sounds=\Vocalization\LZ_AudFilt\', type];
[Sd.wav, Sd.fs] = audioread(fullfile(path, soundname));
plotON = 1;
subplot(1,3,1)
[Mat_env, Mat_env_ds2, MatdB, cf, t_ds] = getCochleogram(Sd, 0.001, 'ERB', plotON);
%%
ind_line = 165;
subplot(1,3,3) 
plot( Mat_env_ds1(ind_line,:)./max(abs(Mat_env_ds2(ind_line,:))) );
hold on, 
plot( Mat_env_ds2(ind_line,:)./max(abs(Mat_env_ds1(ind_line,:))) );
legend({'unfiltered', 'filtered'})
title(['Cross-section at cf = ', num2str(cf(ind_line)./1000, '%.2f'), 'kHz'])
