% temporary processing
% script_SoundProcess:
% add envolope ramping
% set proper duration
% clear all
soundpath = 'X:\=Sounds=\Natural_XINTRINSIC2';
addpath(genpath(soundpath))
list = dir(fullfile(soundpath,'*.wav'));

%
soundpath = 'D:\=code=\McdermottLab\sound_natural';
addpath(genpath(soundpath))
list_full = dir(fullfile(soundpath,'*.wav'));

%% go over all sounds
list1 = struct2cell(list);
list1 = list1(1,2:end);
list2 = struct2cell(list_full);
list2 = list2(1,:);

ind = zeros(1,length(list1));
for i = 1:length(list1)
    s1 = list1{i};
    ind(i) = find(strcmp(s1,list2));
end

%%
Sd.fs = 44100;
frequency = 110.*2.^(0:7);
t = 1/Sd.fs:1/Sd.fs:5;
profile = [];
for i = 1:length(frequency)
    Sd.wav = sin(2*pi*frequency(i).*t);
    [~, Mat_env_ds, MatdB, cf, t_ds] = getCochleogram(Sd, 0.0025, 'log', 0);
    profile(i,:) = mean(Mat_env_ds, 2);
end
figure, semilogx(cf, profile(1:end-1,:)')

