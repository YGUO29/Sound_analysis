% combine short sounds into longer trial (e.g. repeated 4 x 2s sounds for one
% intrinsic imaging trial)

% clear all
% where to get your sound
% soundpath = 'D:\SynologyDrive\=sounds=\Vocalization\LZ_AudFilt\PH\';
soundpath = 'D:\SynologyDrive\=sounds=\Natural sound\Natural_JM original\';

% if designing control trials, select a second folder containing control
% sounds (phase scrambled sounds etc.)
% soundpath2 = 'D:\SynologyDrive\=sounds=\Vocalization\LZ_ControlSounds\LZ_MatchSpec\PH\';
soundpath2 = 'D:\SynologyDrive\=sounds=\Natural sound\Natural_JM_ModelMatched_Sounds\';
% where to save your combined sound
savepath = 'D:\SynologyDrive\=sounds=\Natural sound\Exp_Natural_JM_ModelMatched\';

addpath(genpath(soundpath))
addpath(genpath(soundpath2))

list_ori = dir(fullfile(soundpath,'*.wav'));
[names_sound, idx] = natsortfiles({list_ori.name});
list_ori = list_ori(idx);

list2_ori = dir(fullfile(soundpath2,'*.wav'));
[names_sound2, idx] = natsortfiles({list2_ori.name});
list2_ori = list2_ori(idx);

ind_select = [1:9, 15, 150, 151, 152, 153, 155];
list = list_ori(ind_select);
list2 = list2_ori;
nCycle = length(list);

%% select natural sound categories
load('D:\SynologyDrive\=data=\F_halfcosine_marm_withcat.mat')
ind = cell(1, 11);
nInd = zeros(1, 11);
for i = 1:11
    ind{i} = find(F.C.category_assignments == i);
    nInd(i) = length(ind{i});
end
%%
% category_ind = [ind{1}; ind{2}; ind{9}; ind{10}];
% for i = 1:11
%     category_ind = ind{i};
%     list = list_ori(category_ind);
%     list2 = list2_ori(category_ind);
    seeds = [];

    if length(list)<20
        nReps = 4; % for vocalization: 36 sounds per type, each sound appear 4 times
        nCycle = length(list) * ceil(20/length(list));
        for s = 1:nReps
            for k = 1:ceil(20/length(list)); seeds(s,1+(k-1)*length(list):k*length(list)) = randperm(length(list)); end
        end
    else
        nReps = 4;
        nCycle = length(list);
        for s = 1:nReps
           seeds(s,:) = randperm(length(list));
        end
    end

%%
% repeat each sound to form 20s sound
prestim = 0;
blocksize = 2.25; % duration of sound + gap (for natural sound = 2+0.2s)
dur = blocksize * 8; % duration of a cycle, 8 sounds, 4 original + 4 controls
% poststim = dur - 2 - blocksize*4;
poststim = 0;
std_target = 0.01; % 0.1 for vocalizations, 0.01 for natural sounds 

for iCycle = 1:nCycle
    % generate sounds for each cycle
    newSd.fs = 44100;
    newSd.wav = zeros(floor(newSd.fs*dur),1);
    
    % read 3&4 control sounds
    current_point = 1;
    for iSound = 3:4
        [Sd(i).wav, Sd(i).fs] = audioread([soundpath2, list2(seeds(iSound, iCycle)).name]);
        Sd(i).wav = resample(Sd(i).wav, newSd.fs, Sd(i).fs);
        Sd(i).wav = Sd(i).wav.*(std_target./std(Sd(i).wav));
        newSd.wav(current_point:current_point+length(Sd(i).wav)-1) = Sd(i).wav;
        current_point = current_point+floor(blocksize*newSd.fs);
    end
   

    % read 1~4 original sounds
    for iSound = 1:4
        [Sd(i).wav, Sd(i).fs] = audioread([soundpath, list(seeds(iSound, iCycle)).name]);
        Sd(i).wav = resample(Sd(i).wav, newSd.fs, Sd(i).fs);
        Sd(i).wav = Sd(i).wav.*(std_target./std(Sd(i).wav));
        newSd.wav(current_point:current_point+length(Sd(i).wav)-1) = Sd(i).wav;
        current_point = current_point+floor(blocksize*newSd.fs);
    end
    % read 1&2 control sounds
    for iSound = 1:2
        [Sd(i).wav, Sd(i).fs] = audioread([soundpath2, list2(seeds(iSound, iCycle)).name]);
        Sd(i).wav = resample(Sd(i).wav, newSd.fs, Sd(i).fs);
        Sd(i).wav = Sd(i).wav.*(std_target./std(Sd(i).wav));
        newSd.wav(current_point:current_point+length(Sd(i).wav)-1) = Sd(i).wav;
        current_point = current_point+floor(blocksize*newSd.fs);
    end
%     figure, plot(newSd.wav)
    
%     if ~exist([savepath, F.C.category_labels{i}])
%         mkdir([savepath, F.C.category_labels{i}])
%     end
%     audiowrite([savepath,  F.C.category_labels{i}, '/Nat_MatchSpecEnv_80Hz_Cat=', ...
%         F.C.category_labels{i}, '_4sounds_block=2.2s_dur=17.6s_cycle', num2str(iCycle), '.wav'], newSd.wav, newSd.fs)

%     audiowrite([savepath, '_MusicSpeech\', 'Nat_MatchSpecEnv_80Hz_Cat=', ...
%         'MusicSpeech_4sounds_block=2.2s_dur=17.6s_cycle', num2str(iCycle), '.wav'], newSd.wav, newSd.fs)
    audiowrite([savepath, 'Nat_ModelMatch_Full_', ...
        '4sounds_block=2.25s_dur=18s_cycle', num2str(iCycle), '.wav'], newSd.wav, newSd.fs)

end

% end
%%
for i = 1:length(Sd)
% for i = 4:6
    temp = repmat([Sd(i).wav; zeros(round(newSd.fs*Sd(i).gap), 1)], 4, 1);
    newSd.wav = [zeros(round(prestim*newSd.fs), 1); temp; zeros(round(poststim*newSd.fs), 1)];
    if length(newSd.wav) ~= dur * newSd.fs
        newSd.wav = newSd.wav(1: dur * newSd.fs);
    end
    newSd.wav = newSd.wav./max(abs(newSd.wav));
    audiowrite([savepath, list(i).name(1:end-4), '_4reps.wav'], newSd.wav, newSd.fs);
end

%% repeat each sound 4 times, each block 2.2s (sound dur + post-gap)
dur = 8.8;
prestim = 0;
blocksize = 2.2; % duration of sound + gap (for natural sound = 2+0.2s)
poststim = 0;
newSd.fs = 100000;
newSd.wav = zeros(floor(newSd.fs*dur),1);

for i = 1:length(list)
% for i = 4:6
    [Sd(i).wav, Sd(i).fs] = audioread(list(i).name);
    Sd(i).wav = resample(Sd(i).wav, newSd.fs, Sd(i).fs);
    Sd(i).fs = newSd.fs;
    Sd(i).dur = length(Sd(i).wav)./ Sd(i).fs;
    Sd(i).gap = blocksize - Sd(i).dur;
end


for i = 1:length(Sd)
% for i = 4:6
    temp = repmat([Sd(i).wav; zeros(round(newSd.fs*Sd(i).gap), 1)], 4, 1);
    newSd.wav = temp(1:floor(newSd.fs * dur));
%     newSd.wav = [zeros(round(prestim*newSd.fs), 1); temp; zeros(round(poststim*newSd.fs), 1)];
%     if length(newSd.wav) ~= dur * newSd.fs
%         newSd.wav = newSd.wav(1: dur * newSd.fs);
%     end
    newSd.wav = newSd.wav./max(abs(newSd.wav));
    audiowrite([savepath, list(i).name(1:end-4), '_4reps.wav'], newSd.wav, newSd.fs);
end



%%
% list_sub = cell(6,2);
% list_sub(:,1) = {'M29A'; 'M64A'; 'M91C'; 'M92C'; 'M93A'; 'M9606'};
% list_sub(:,2) = mat2cell([1:6]',ones(6,1));

type = 'TW';
% go over all sounds
dur = 20;
newSd.fs = 44100;
newSd.wav = zeros(newSd.fs*dur,1);
ind = [];
for i = 1:length(list)
    if contains(list(i).name, type)
        ind = [ind, i];
    end
end

for i = 1:2
    [Sd(i).wav, Sd(i).fs] = audioread(list(ind(i)).name);
    Sd(i).wav = resample(Sd(i).wav, newSd.fs, Sd(i).fs);
    Sd(i).fs = newSd.fs;
    Sd(i).dur = length(Sd(i).wav)./ Sd(i).fs;
end
%% with / without noise control
% without noise
temp_wav = Sd(1).wav;
gap = 0;
while length(temp_wav) + length(Sd(1).wav) + newSd.fs <= 10*newSd.fs
    gap = 0.4+0.6*rand(1);
    temp_wav = [temp_wav; zeros(ceil(gap*newSd.fs), 1); Sd(1).wav];
end
% figure, plot(temp_wav)
% newSd.wav(1:length(temp_wav)) = temp_wav;
newSd.wav(10*newSd.fs+1:10*newSd.fs+length(temp_wav)) = temp_wav;

% with noise
temp_wav = Sd(2).wav;
gap = 0;
while length(temp_wav) + length(Sd(2).wav) + newSd.fs <= 10*newSd.fs
    gap = 0.4+0.6*rand(1);
    temp_wav = [temp_wav; zeros(ceil(gap*newSd.fs), 1); Sd(2).wav];
end
newSd.wav(1:length(temp_wav)) = temp_wav;
% newSd.wav(10*newSd.fs+1:10*newSd.fs+length(temp_wav)) = temp_wav;

t = 1/newSd.fs:1/newSd.fs:dur;
figure, plot(t,newSd.wav)

getSpectrogram(newSd,1,0.01)

%% save
newSd.wav = newSd.wav./max(abs(newSd.wav));
audiowrite([savepath, '\', 'Combined\', 'Exp1_',type,'_Denoise(10)+Noisy(10)_20s.wav'], newSd.wav, newSd.fs)

