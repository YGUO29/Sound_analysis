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
ind = [];
for i = 1:size(info,1)
    if contains(info(i,5),'Voc')
        ind = [ind, i];
    end
end
%%
dur = zeros(length(ind),1);
for i = 1:length(ind)
    wav = info{ind(i),2}{2};
    fs = info{ind(i),2}{1};
    dur(i) = length(wav)/fs;
end