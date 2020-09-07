% sound modification
folder_sound    = 'D:\=code=\McdermottLab\sound_natural\';
folder_save     = 'D:\=code=\McdermottLab\sound_natural\modified';
% folder_sound = 'D:\=sounds=\Voc_jambalaya\Natural with Voc\';
list = dir(fullfile(folder_sound,'*.wav'));
names_sound = natsortfiles({list.name})';


NewSd.prestim   = 1;
NewSd.isi       = 0;
NewSd.rep       = 1;
NewSd.dur       = NewSd.rep*5;
% select a sound to load, modify it
for iSound = 1:length(names_sound)
% for iSound = 1:10
Sd.SoundName = names_sound{iSound};
filename = [folder_sound,Sd.SoundName];
[Sd.wav,Sd.fs] = audioread(filename);
% Max(iSound) = max(abs(Sd.wav));
% Std(iSound) = std(Sd.wav);
% resample
rs = Sd.fs;
% Sd.wav = resample(Sd.wav, rs, Sd.fs);
% Sd.fs = rs;


NewSd.fs    = Sd.fs;
NewSd.wav   = zeros(1, floor(NewSd.fs*NewSd.dur));
for j = 1:NewSd.rep
    start = NewSd.prestim*NewSd.fs+1 + (j-1)*(length(Sd.wav)+NewSd.isi*NewSd.fs);
    stop  = start + length(Sd.wav) - 1;
    NewSd.wav(start:stop) = Sd.wav;
end



% check sound
% t = 1/NewSd.fs:1/NewSd.fs:NewSd.dur;
% subplot(2,5,iSound),plot(t,NewSd.wav)

% save sound
% filename = [folder_save,'/',Sd.SoundName(1:end-4),...
%     '_rep=',num2str(NewSd.rep),'_isi=',num2str(NewSd.isi)];
% audiowrite([filename,'.wav'],NewSd.wav,NewSd.fs);

filename = [folder_save,'/',Sd.SoundName(1:end-4),...
    '_modified'];
audiowrite([filename,'.wav'],NewSd.wav,NewSd.fs);
end



