% Generate trial based sound capsule
clear all

bnum = 21;

[F.FileName, F.PathName, F.FilterIndex] = uigetfile(...
    'D:\SynologyDrive\=sounds=\*.wav',...
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

% for natural sounds: already attenuated 36.5dB
% for vocalizations: already attenuated 25.39dB compare to pure tone




S.D.Trial.Duration =        5;
S.D.Trial.PreStimTime =     1;
S.D.Trial.Repeat =          1;
S.D.Trial.SR =              100000;
S.D.Trial.Resample =        1;
S.D.Trial.ResampleLength =  zeros(1,length(F.FileName)); % varying with sounds, 

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
    S.T.Sound.Std(i) =      std(F.wav);
    
    % for sounds with different length, reset resamplelength
    S.D.Trial.ResampleLength(i) = length(F.wav)./F.FS;
    
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
    [~,S.T.Trial.Names{i},~] = fileparts(F.info.Filename);
%     S.T.Trial.Names{i} =    S.T.Trial.Names{i}(20:end);
%     S.T.Trial.Names{i} = 'S23s&T19s';
    % Flank zeros
    S.D.SoundT.CurWave =    S.D.SoundT.Total;
    S.D.SoundT.CurWave(S.D.SoundT.StartSNum+( 0:round(S.D.System.SR*S.D.Trial.ResampleLength(i)-1) )) =...
        F.wavRS( 1:round(S.D.System.SR*S.D.Trial.ResampleLength(i)) )';
    
    S.D.SoundT.CurWave =    int16(S.D.SoundT.CurWave'*32767);
    S.T.Sound.Totaluint16((i-1)*(S.D.System.SR*S.D.Trial.Duration)+1 : (i*S.D.System.SR*S.D.Trial.Duration)) = S.D.SoundT.CurWave;
    
end

% ==== attenuation ====
S.D.Level.InherentLevel =     100 + (20*log10(mean(S.T.Sound.Std)) - 10*log10(0.5)); 
S.D.Level.TargetAtt =       100 - 63.5; 
S.D.Level.att =             S.D.Level.TargetAtt - (100 - S.D.Level.InherentLevel); 
S.T.Trial.Att = S.D.Level.att*(ones(1, S.D.Trial.NumberTotal));

% ==== trial names ==== 
S.T.Trial.NamesAll = '';

% for i = 1:length(S.T.Trial.Names)
%     S.T.Trial.NamesAll = [...
%         S.T.Trial.NamesAll, ...
%         S.T.Trial.Names{i}, ...
%         ' '];
% end

% ===== for ripples =====
% for i = 1:length(S.T.Trial.Names)
%     Name_parts = strsplit(S.T.Trial.Names{i},'_');
%     Name_temp = ['S', Name_parts{5}(3:end-3),'_T',Name_parts{6}(3:end-3)];
%     S.T.Trial.NamesAll = [...
%         S.T.Trial.NamesAll, ...
%         Name_temp, ...
%         ' '];
% end

% ===== for natural sound names =====
% for i = 1:length(S.T.Trial.Names)
%     Name_parts = strsplit(S.T.Trial.Names{i},'_');
%     Name_number = ['00',Name_parts{1}(5:end)];
%     Name_number = Name_number(end-2:end);
%     Name_part1 = Name_parts{2}(1:2); Name_part1(1) = upper(Name_part1(1));
% %     if ~strcmp('re',Name_parts{3}(1:2)) && length(Name_parts{3}) >= 3
% %     if length(Name_parts)>2 && length(Name_parts{3}) >= 3
% %         Name_part2 = Name_parts{3}(1:3); Name_part2(1) = upper(Name_part2(1));
% %     else
% %         Name_part2 = [];
% %     end
%     
%     if mod(i,4) == 1
%         Name_part3 = 'orig';
%     else
%         Name_part3 = Name_parts{end-1};
%     end
%     
%     Name_temp = [Name_number,'_',Name_part1,'_',Name_part3];
%     S.T.Trial.NamesAll = [...
%         S.T.Trial.NamesAll, ...
%         Name_temp, ...
%         ' '];
% end
% ===== for vocalization and control sounds =====
for i = 1:length(S.T.Trial.Names)
    Name_parts = strsplit(S.T.Trial.Names{i},'_');
    Name_part1 = [Name_parts{end}(1:3)];
    Name_part2 = Name_parts{1}; 
    Name_temp = [Name_part1, '_', Name_part2];
    S.T.Trial.NamesAll = [...
        S.T.Trial.NamesAll, ...
        Name_temp, ...
        ' '];
end


figure;
plot(S.T.Sound.Totaluint16);
drawnow
% for vocalizations
% S.D.Session.Title = ['D:\SynologyDrive\=sounds=\Ripple\capsule\Sound_', ...
%     'RS_Voc_TP_Orig_MatchSpec_',...    
%     sprintf('%d',   S.D.Trial.NumberTotal),     'sounds_(',...
%     sprintf('%2.1f',S.D.Trial.PreStimTime),     'pre_in_',...
%     sprintf('%2.1f',S.D.Trial.Duration),        ')s_',...
%     num2str(S.D.Level.InherentLevel, '%2.1f'),  'dBSPL_',...
%     num2str(S.D.Level.TargetAtt),                  'TargetAtt'];
%     num2str(S.T.Trial.Att(1)),                  'dBatt'];

% for ripples
% 
S.D.Session.Title = ['D:\SynologyDrive\=sounds=\Vocalization\capsule\Sound_RS_', ...
    'Voc_AllMajor_Orig+ModelMatched(full)_',...    
    sprintf('%d',   S.D.Trial.NumberTotal),     'sounds_(',...
    sprintf('%2.1f',S.D.Trial.PreStimTime),     'pre_in_',...
    sprintf('%2.1f',S.D.Trial.Duration),        ')s_',...
    num2str(S.D.Level.InherentLevel, '%2.1f'),  'dBSPL_',...
    num2str(S.D.Level.TargetAtt, '%2.0f'),      'TargetAtt'];
%     num2str(S.T.Trial.Att(1)),                  'dBatt'];

% S.D.Session.Title = [F.FileName{1}(1:end-4), '_'...
%     num2str(S.T.Trial.Att(1)),                  'dBatt'];
% %     sprintf('%2.1f',S.D.Trial.PreStimTime),     'pre_in_',...
% %     sprintf('%2.1f',S.D.Trial.Duration),        ')s_',...
    

S.D.Session.Comment = [' ',...
    'TrialNames: ',             S.T.Trial.NamesAll,       '; ',...
    'TrialAttenuations: ',      num2str(S.T.Trial.Att),             '; ',...
    'TrialNumberTotal: ',       num2str(S.D.Trial.NumberTotal),      '; ',...
    'TrialDurTotal(sec): ',   	num2str(S.D.Trial.Duration),         '; ',...
    'TrialDurPreStim(sec): ',	num2str(S.D.Trial.PreStimTime),      '; ',...
    'TrialDurStim(sec): ',    	num2str(S.D.Trial.ResampleLength),     '; ',...
    ''];
audiowrite([ S.D.Session.Title,'.wav'],...
    S.T.Sound.Totaluint16,	S.D.System.SR,...
    'BitsPerSample',        16,...
    'Title',                S.D.Session.Title,...
    'Artist',               S.D.Session.Artist,...
    'Comment',              S.D.Session.Comment);

%     sprintf('%2.1f',S.D.System.SR/F.info.SampleRate),'xSpeed_',...