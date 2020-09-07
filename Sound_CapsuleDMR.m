% Generate Natural sounds capsule for intrinsic imaging
% (20s each trial, 2s pre-stimulus, 4 repetitions of each 2s sound with 0.2s interval in between)
clear all

bnum = 21;

[F.FileName, F.PathName, F.FilterIndex] = uigetfile(...
    'D:\=sounds=\*.wav',...
    'Select ".wav" files to capsule',...
    'MultiSelect',              'On');
if F.FilterIndex == 0
    clear F;
    return
end
if iscell(F.FileName) == 0  % single file selected
    F.FileName = {F.FileName};
end

disp([ F.FileName{1}]);
disp(['sound capsule is about to start on ' ...
    num2str(length(F.FileName)) ' files']);


%% Custom Parameters
% S.D.Level.att =             20;
% S.D.Trial.Duration =        5.0;
% S.D.Trial.PreStimTime =     1.0;
% S.D.Trial.Repeat =          1;
% S.D.Trial.SR =              44100;
% S.D.Trial.Resample =        1;
% S.D.Trial.ResampleLength =  2;
% 
% S.D.Session.NumTrlH =       15;
% S.D.Session.NumTrlV =       1;

S.D.Level.att =             30;
S.D.Trial.Duration =        437;
S.D.Trial.PreStimTime =     0;
S.D.Trial.Repeat =          1;
S.D.Trial.SR =              100000;
S.D.Trial.Resample =        1;
S.D.Trial.ResampleLength =  437; % do not use 19
S.D.Trial.CycNum =          23;
S.D.Trial.OrderMat =        mat2str(ones(1, S.D.Trial.CycNum));
S.D.Trial.OrderMat =        S.D.Trial.OrderMat(2:end-1);

S.D.Session.NumTrlH =       6;
S.D.Session.NumTrlV =       6;

%% Sound Generation
S.D.Trial.NumberTotal =     length(F.FileName);
S.D.System.SR =             100000;
S.D.System.NoAttSPL =       100;
S.D.Session.Artist =        ['Yueqi @ ' datestr(now, 'yyyymmdd-HH')];

S.T.Sound.Total =           zeros(1,0); 
S.T.Trial.Names =           {};               

S.D.SoundT.Total =          zeros(1, S.D.System.SR* S.D.Trial.Duration);
S.D.SoundT.Pre =            zeros(1, S.D.System.SR* S.D.Trial.PreStimTime);
S.D.SoundT.StartSNum =      round(S.D.System.SR* S.D.Trial.PreStimTime + 1);
S.T.Sound.Total =           zeros(1, S.D.System.SR*length(F.FileName)*S.D.Trial.Duration);
S.T.Sound.Totaluint16 =     int16(S.T.Sound.Total'*32767);

for  i = 1: length(F.FileName)
    
    
    S.T.NumH =              mod(i-1, S.D.Session.NumTrlH) +1;
    S.T.NumV =              floor( (i-1)/S.D.Session.NumTrlH )+1;
    F.info =                audioinfo([F.PathName F.FileName{i}]);
    [F.wav, F.FS] =         audioread([F.PathName F.FileName{i}]);
    if S.D.Trial.Resample
%     F.wavRS =               resample(F.wav, S.D.System.SR, S.D.Trial.SR);
        F.wavRS =               resample(F.wav, S.D.System.SR, F.FS);
    else
        F.wavRS = F.wav;
    end

%     disp(F.info);

    S.D.SoundT.StimDur =    F.info.TotalSamples /S.D.System.SR;
%     S.D.SoundT.StimSampTotal =	F.info.TotalSamples;
%     S.T.Trial.Names{i} =	[num2str(S.T.NumH), '=', num2str(S.T.NumV)];
%     [~,S.T.Trial.Names{i},~] = fileparts(F.info.Filename);
%     S.T.Trial.Names{i} =    S.T.Trial.Names{i}(20:end);
    S.T.Trial.Names{i} = 'S23s&T19s';
    % Flank zeros
    S.D.SoundT.CurWave =    S.D.SoundT.Total;
    S.D.SoundT.CurWave(S.D.SoundT.StartSNum+( 0:round(S.D.System.SR*S.D.Trial.ResampleLength-1) )) =...
        F.wavRS( 1:round(S.D.System.SR*S.D.Trial.ResampleLength) )';
    
    S.D.SoundT.CurWave =    int16(S.D.SoundT.CurWave'*32767);
    S.T.Sound.Totaluint16((i-1)*(S.D.System.SR*S.D.Trial.Duration)+1 : (i*S.D.System.SR*S.D.Trial.Duration)) = S.D.SoundT.CurWave;
    
end

S.T.Trial.NamesAll = '';
for i = 1:length(S.T.Trial.Names)
    S.T.Trial.NamesAll = [...
        S.T.Trial.NamesAll, ...
        S.T.Trial.Names{i}, ...
        ' '];
end
% ===== for natural sound names =====
% for i = 1:length(S.T.Trial.Names)
%     Name_parts = strsplit(S.T.Trial.Names{i},'_');
%     Name_number = ['00',Name_parts{1}(5:end)];
%     Name_number = Name_number(end-2:end);
%     Name_part1 = Name_parts{2}(1:3); Name_part1(1) = upper(Name_part1(1));
%     if ~strcmp('re',Name_parts{3}(1:2)) && length(Name_parts{3}) >= 3
%         Name_part2 = Name_parts{3}(1:3); Name_part2(1) = upper(Name_part2(1));
%     else
%         Name_part2 = [];
%     end
%     Name_temp = [Name_number,'_',Name_part1,Name_part2];
%     S.T.Trial.NamesAll = [...
%         S.T.Trial.NamesAll, ...
%         Name_temp, ...
%         ' '];
% end
S.T.Trial.Att = S.D.Level.att*(ones(1, S.D.Trial.NumberTotal));

figure;
plot(S.T.Sound.Totaluint16);
drawnow

% S.D.Session.Title = ['Sound_', ...
%     'RS_Natural_4Reps_'...    
%     sprintf('%d',   S.D.Trial.NumberTotal),     'sounds_(',...
%     sprintf('%2.1f',S.D.Trial.PreStimTime),     'pre_in_',...
%     sprintf('%2.1f',S.D.Trial.Duration),        ')s_',...
%     num2str(S.T.Trial.Att(1)),                  'dBatt'];

S.D.Session.Title = [F.FileName{1}(1:end-4), '_'...
    num2str(S.T.Trial.Att(1)),                  'dBatt'];
%     sprintf('%2.1f',S.D.Trial.PreStimTime),     'pre_in_',...
%     sprintf('%2.1f',S.D.Trial.Duration),        ')s_',...
    
    

S.D.Session.Comment = [' ',...
    'TrialNames: ',             S.T.Trial.NamesAll,                 '; ',...
    'TrialAttenuations: ',      num2str(S.T.Trial.Att),             '; ',...
    'TrialNumberTotal: ',       num2str(S.D.Trial.NumberTotal),     '; ',...
    'TrialDurTotal(sec): ',   	num2str(S.D.Trial.Duration),        '; ',...
    'TrialDurPreStim(sec): ',	num2str(S.D.Trial.PreStimTime),     '; ',...
    'TrialDurStim(sec): ',    	num2str(S.D.Trial.Duration),  '; ',... % was S.D.Trial.ResampleLength
    'SesTrlOrder: ',            'Pre-arranged',                     '; ',...
    'SesCycleNumTotal: ',       num2str(S.D.Trial.CycNum),          '; ',...
    'SesTrlOrderMat: ',           S.D.Trial.OrderMat,         ';',...
    ''];
audiowrite([ S.D.Session.Title,'.wav'],...
    S.T.Sound.Totaluint16,	S.D.System.SR,...
    'BitsPerSample',        16,...
    'Title',                S.D.Session.Title,...
    'Artist',               S.D.Session.Artist,...
    'Comment',              S.D.Session.Comment);

%     sprintf('%2.1f',S.D.System.SR/F.info.SampleRate),'xSpeed_',...

%%
path = 'D:\=sounds=\DMR\2019-9-20_ChangeTMDirections\Capsule\';
name = 'DMR_437s_(SM@23s(CosLog0.125~8.000cycPoct)_TM@19s(Log-32.0~32.0Hz)_43x6carriers@A4~A10&f1=A7_30dBatt.wav';
filename = [path,name];
info = audioinfo(filename);
[y, fs] = audioread(filename,'native');
audiowrite([path,'PreA_',name],...
    y,	fs,...
    'BitsPerSample',        16,...
    'Title',                info.Title,...
    'Artist',               info.Artist,...
    'Comment',              newComment);