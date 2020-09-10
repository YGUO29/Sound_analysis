% resample in batch
[F.FileName, F.PathName, F.FilterIndex] = uigetfile(...
    'D:\SynologyDrive\=sounds=\Vocalization\LZ_selected_4reps\single rep\*.wav',...
    'Select ".wav" files to capsule',...
    'MultiSelect',              'On');
F.FSnew = 44100;
%%
for  i = 1: length(F.FileName)
    [F.wav, F.FS] = audioread([F.PathName F.FileName{i}]);
    F.wav = resample(F.wav,F.FSnew,F.FS);
    F.wav = F.wav./max(abs(F.wav));

    audiowrite(['D:\SynologyDrive\=sounds=\Vocalization\LZ_selected_4reps\single rep\',F.FileName{i},'_RS.wav'],...
    F.wav,	F.FSnew);
end