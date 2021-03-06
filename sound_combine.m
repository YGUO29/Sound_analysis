% combine short sounds into longer trial (e.g. repeated 4 x 2s sounds for one
% intrinsic imaging trial)

clear all
% where to get your sound
soundpath = 'D:\SynologyDrive\=sounds=\Vocalization\LZ_selected_4reps\single rep';

% if designing control trials, select a second folder containing control
% sounds (phase scrambled sounds etc.)
soundpath2 = '';
% where to save your combined sound
savepath = 'D:\SynologyDrive\=sounds=\Vocalization\LZ_selected_4reps\';
addpath(genpath(soundpath))
list = dir(fullfile(soundpath,'*.wav'));

%% repeat each sound to form 20s sound
dur = 20;
prestim = 2;
blocksize = 2.2; % duration of sound + gap (for natural sound = 2+0.2s)
poststim = dur - 2 - blocksize*4;
newSd.fs = 44100;
newSd.wav = zeros(newSd.fs*dur,1);

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

