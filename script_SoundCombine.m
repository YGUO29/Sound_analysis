% script_SoundProcess:
% add envolope ramping
% set proper duration
clear all
soundpath = 'D:\=sounds=\Vocalization\Exp1_NoiseEffect_Cycle';
savepath = 'D:\=sounds=\Vocalization\Exp1_NoiseEffect_Cycle';
addpath(genpath(soundpath))
list = dir(fullfile(soundpath,'*.wav'));
list_sub = cell(6,2);
list_sub(:,1) = {'M29A'; 'M64A'; 'M91C'; 'M92C'; 'M93A'; 'M9606'};
list_sub(:,2) = mat2cell([1:6]',ones(6,1));

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
%%
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



