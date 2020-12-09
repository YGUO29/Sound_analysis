% Spectral Harmonicity Preference
clear all

% Spectrally Degraded Singing (Music+Speech):	
%% Modulation Cut 
S.Mod.Spec =    0.0006; % modulation low-pass filter cut-off (cyc/Hz)
	% 0.0006 cycles/Hz = 0.6 cycles/kHz = 1 cycle/1.67kHz
%% Sound Seed
S.Seed.FolderParent =   'D:\User_SONG Xindong\Downloads\2020-Science-Albouy&Zatorre-Fig1\';
% S.Seed.FolderSpec =     'FilterHP\';
S.Seed.OctRise =        0;

%% Fixed parameters for the current design
S.System.SR =           100000;
% Session, % Trial
    S.Session.CycleSeq =	'Prearranged';
    S.Session.SeedSeq =     randperm(200);
    S.Trial.Names =         {'SingSpecPref'};
    S.Seed.TotalTime =      4.2;
    S.Seed.PreStimTime =    0;  
    
%     S.Session.CycleNum =	100;
% %     S.Trial.ModSeqSpec =	[1 4 2 3];
%     S.Trial.ModSeqSpec =	[4 1 3 2];
    
    S.Session.CycleNum =	50;
    S.Trial.ModSeqSpec =	[6 8 1 3 5 7 2 4];
    
    S.Trial.SeedNum =       length(S.Trial.ModSeqSpec);
     
% Level:
    S.Level.SLorSPL =       'SPL';
    S.Level.TargetLevel =   60;  
   
% a(1,:) = [67 69 71 69 67 64 62 64 62 60];
% a(2,:) = [64 65+1 67 72 69 71 69 65+1 67 64];
% a(3,:) = [65+1 74 76 77+1 72+1 74 72+1 71 65+1 69];
% a(4,:) = [72+1 76 74 72+1 65+1 67+1 69 74 72+1 67+1];
% a(5,:) = [67+1 67+1 69 67+1 64 67+1 65+1 65+1 60+1 64];
% a(6,:) = [67+1 71 69+1 69+1 67+1 65+1 62+1 65+1 62+1 62+1];
% a(7,:) = [69 76 74 72 69 72 69 72 65 69];
% a(8,:) = [65 74 76-1 74 65 72 71-1 71-1 64-1 65];
% a(9,:) = [67 67 67 67 67 67 69-1 69-1 67 67];
% a(10,:) = [72 76-1 72 69-1 72 76-1 74-1 74-1 72 69-1];
    
%% Read all sounds from files, resample, and scale to STD
for i = 1:200
    if i<101;   S.Seed.TitleParts{i,1} = 'English';
    else;       S.Seed.TitleParts{i,1} = 'French';       end
                S.Seed.TitleParts{i,2} = mod(i-1, 10)+1;            % Speech#
                S.Seed.TitleParts{i,3} = mod(ceil(i/10)-1, 10)+1;   % Music#
    % file name
    S.Seed.TitleSeeds{i,1} = sprintf('%s_S%02d_M%02d',	S.Seed.TitleParts{i,1},...
                                 S.Seed.TitleParts{i,2},	S.Seed.TitleParts{i,3});

    % read the filtered (Orig)inal sound
   [S.Seed.SoundOrig{i}, S.Seed.FS] = audioread([ S.Seed.FolderParent,...
        S.Seed.TitleParts{i,1}, '\FilterHP\',...
        S.Seed.TitleSeeds{i,1}, '_Orig_butter4@220.wav']);
    S.Seed.SoundRS{i,1} = resample(S.Seed.SoundOrig{i}, S.System.SR, S.Seed.FS);
    S.Seed.SoundRS{i,1} = S.Seed.SoundRS{i,1}/std(S.Seed.SoundRS{i,1});

    % read the filtered (Spec)trally degraded sound
   [S.Seed.SoundSpec{i}, ~] = audioread([ S.Seed.FolderParent,...
        S.Seed.TitleParts{i,1}, '\FilterHP\',...
        S.Seed.TitleSeeds{i,1}, '_Spec_butter4@220.wav']);
    S.Seed.SoundRS{i,2} = resample(S.Seed.SoundSpec{i}, S.System.SR, S.Seed.FS);
    S.Seed.SoundRS{i,2} = S.Seed.SoundRS{i,2}/std(S.Seed.SoundRS{i,2}); 
end
%% Length tightening
% Seed (for tightening the length of the sounds, numbers were determined emperically
S.Seed.EnvTime =        0.02;           
S.Seed.AmpThres =       0.15;
S.Seed.GapEnd =         [0.05 0.20];
    % Ramp    
    S.Ramp.OnOff =          'on';
    S.Ramp.Option =         'linear'; % 'linear'
    S.Ramp.Time =           25;         % sine ramp up & down time  (ms)
    S.Ramp.SampleTotal =	round(S.Ramp.Time/1000*S.System.SR);
    S.Ramp.SampleSeq =      0:1:round(S.Ramp.SampleTotal-1);
    switch lower(S.Ramp.Option)
        case 'sine';    S.Ramp.Mask = 	sin( 2*pi*(1000/(4*S.Ramp.Time)) * ...
                                        S.Ramp.SampleSeq/S.System.SR );
        case 'linear';  S.Ramp.Mask = 	S.Ramp.SampleSeq/round(S.Ramp.SampleTotal-1);
    end
for i = 1:200
    for j = 1:2
        S.Seed.EnvRS{i,j} = envelope(S.Seed.SoundRS{i,j}, S.Seed.EnvTime*S.System.SR, 'rms');
        S.Seed.LengthRS(i,j) =	length(S.Seed.SoundRS{i,j});
        
        S.Seed.StartIdx(i,j) =      find(abs(S.Seed.EnvRS{i,j})>S.Seed.AmpThres, 1, 'first');
        S.Seed.Cut1Idx(i,j) =       max([1 S.Seed.StartIdx(i,j)-S.Seed.GapEnd(1)*S.System.SR]); 
        
        S.Seed.StopIdx(i,j) =       find(abs(S.Seed.EnvRS{i,j})>S.Seed.AmpThres, 1, 'last');
        S.Seed.StopLength(i,j) =    S.Seed.LengthRS(i,j) - S.Seed.StopIdx(i,j);
        S.Seed.Cut2Idx(i,j) =       min([S.Seed.LengthRS(i,j) S.Seed.StopIdx(i,j)+S.Seed.GapEnd(2)*S.System.SR]);
        
        S.Seed.LengthRStight(i,j) =  S.Seed.Cut2Idx(i,j) - S.Seed.Cut1Idx(i,j) +1;
%         subplot(2,1,j);
%         hold off;   plot(S.Seed.SoundRS{i,j})
%         hold on;    plot(S.Seed.EnvRS{i,j}, 'r', 'linewidth', 1);
%         set(gca,...
%             'XTick',        [S.Seed.Cut1Idx(i,j) S.Seed.StartIdx(i,j) S.Seed.StopIdx(i,j), S.Seed.Cut2Idx(i,j)],...
%             'XGrid',        'on',...
%             'XLIm',         [0 5*S.System.SR],...
%             'YTick',        [0 S.Seed.AmpThres],...
%             'YGrid',        'on',...
%             'YLim',         [-1 2]);
%         title(sprintf('Sound#%d: cut length %4.2f s', i, S.SeedLengthRStight(i,j)/S.System.SR));
    end   
    S.Seed.FCut1Idx(i) = min(S.Seed.Cut1Idx(i,:));
    S.Seed.FCut2Idx(i) = max(S.Seed.Cut2Idx(i,:));
    S.Seed.LengthRSfinal(i) = S.Seed.FCut2Idx(i) - S.Seed.FCut1Idx(i) +1;
    S.Seed.SoundRScut{i,1} = S.Seed.SoundRS{i,1}(S.Seed.FCut1Idx(i):S.Seed.FCut2Idx(i));
    S.Seed.SoundRScut{i,2} = S.Seed.SoundRS{i,2}(S.Seed.FCut1Idx(i):S.Seed.FCut2Idx(i));
    if S.Seed.FCut1Idx(i)~=1
        S.Seed.SoundRScut{i,1}(1:S.Ramp.SampleTotal) = S.Seed.SoundRScut{i,1}(1:S.Ramp.SampleTotal).*S.Ramp.Mask';
        S.Seed.SoundRScut{i,2}(1:S.Ramp.SampleTotal) = S.Seed.SoundRScut{i,2}(1:S.Ramp.SampleTotal).*S.Ramp.Mask';
    end
    if S.Seed.FCut2Idx(i)~= S.Seed.LengthRS(i,1)
        S.Seed.SoundRScut{i,1}(end-S.Ramp.SampleTotal+1:end) = S.Seed.SoundRScut{i,1}(end-S.Ramp.SampleTotal+1:end).*fliplr(S.Ramp.Mask)';
        S.Seed.SoundRScut{i,2}(end-S.Ramp.SampleTotal+1:end) = S.Seed.SoundRScut{i,2}(end-S.Ramp.SampleTotal+1:end).*fliplr(S.Ramp.Mask)';
    end
%     pause;
end
    
%% Fixed parameters for almost ALL stimuli designs
% S.System.SR =           100000;
S.System.NoAttSPL =     100;
S.Session.Artist =      ['Xindong @ ' datestr(now, 'yyyymmdd-HH')];
S.Session.SeedMat =     reshape(S.Session.SeedSeq, S.Session.CycleNum, []);
%% Calculations：
% Time & Sequence
    S.Seed.SampleBase =     round(S.System.SR* S.Seed.PreStimTime);
    S.Seed.SampleTotal =	round(S.System.SR* S.Seed.TotalTime);
    S.Seed.SampleSoundMax =	round(S.System.SR* (S.Seed.TotalTime-S.Seed.PreStimTime));
        % only French_S01_M05 & English_S05_M06 have raw durations > 4.8s, 
        % both confrimed w/ a prolonged silence at onset
    S.Seed.Sound =          zeros(1, S.Seed.SampleTotal);
    
	S.Trial.StimDuration =	S.Seed.TotalTime * length(S.Trial.ModSeqSpec);
    S.Trial.PreStimTime = 	0; 
    S.Trial.PostStimTime = 	0;
    S.Trial.Duration =      S.Trial.PreStimTime + S.Trial.StimDuration + S.Trial.PostStimTime;
    S.Trial.NumberTotal =	1;  % a single type of trial within each cycle
    S.Trial.SampleTotal =	round(S.Trial.Duration*S.System.SR);    
	S.Trial.SampleBase4Seeds([S.Trial.ModSeqSpec]) = ((1:S.Trial.SeedNum)-1)*S.Seed.SampleTotal;
    S.Trial.Sound =         zeros(1, S.Trial.SampleTotal);
    
    S.Session.Duration =	S.Trial.Duration * S.Session.CycleNum;
    S.Session.SampleTotal = round(S.Session.Duration*S.System.SR);
    S.Session.SampleBase4Trials =   S.Trial.SampleTotal*((1:S.Session.CycleNum)-1);
    S.SoundTotalT =         zeros(1,round(S.Session.Duration*S.System.SR)); 
    S.SoundTotalS =         zeros(1,round(S.Session.Duration*S.System.SR)); 
    S.SoundTotalInt16 =     int16(S.SoundTotalT*32767);
    
%% Sound Generation
% cycles (prearranged)
for i = 1:S.Session.CycleNum
    % Reset the Trial Sound
	S.Trial.Sound =	0 * S.Trial.Sound;
    for i2 = 1:size(S.Session.SeedMat, 2)
        k = S.Session.SeedMat(i, i2);
        for j = 1:2 % 1=Orig, 2=Spec (degraded)
            % slot number
            k2 = j+(i2-1)*2;
            % Reset the Seed Sound
            S.Seed.Sound =	0*S.Seed.Sound;
            S.Seed.Sound( S.Seed.SampleBase+(1:S.Seed.LengthRSfinal(k)) ) = ...
                S.Seed.SoundRScut{k,j};   
            S.Trial.Sound( S.Trial.SampleBase4Seeds(k2)+(1:S.Seed.SampleTotal) ) = ...
                S.Seed.Sound;                            
        end
    end
    % Write the Trial Sound to the Sound Total
    S.SoundTotalS( S.Session.SampleBase4Trials(i)+(1:S.Trial.SampleTotal)  ) = ...
        S.Trial.Sound;
end

%% Level
S.Level.AmpRawMax = max(abs(S.SoundTotalS));
S.SoundTotalS =  S.SoundTotalS/S.Level.AmpRawMax;
S.Level.StdFinal = std(S.SoundTotalS);
S.Level.Att2PT = 20*log10(sqrt(0.5)/S.Level.StdFinal);

    S.Trial.Atts = S.System.NoAttSPL - S.Level.Att2PT - S.Level.TargetLevel;

% % Play
% S.P = audioplayer(S.SoundTotal, 100e3, 16);
% S.P.play;
% while 1
%     pause(0.1)
%     if ~isplaying(S.P)
%         break;
%     end
% end

% figure
% plot(S.SoundTotal);  

%% SOUND WRITE    
switch S.Trial.SeedNum
    case 4;     S.TrialStructStr = 'SOOS';
    case 8;     S.TrialStructStr = 'SSOOOOSS';
    otherwise;  S.TrialStructStr = '';
end
    S.SesCycleNumTotal =    S.Session.CycleNum;     
    % Spec
    S.Session.Title = [...
        sprintf('PreA_%s_',         S.Trial.Names{1}),...
        sprintf('Tight_%dx',       S.Session.CycleNum),...
        sprintf('[SOOS]@(O=Orig,S=SpecFilt@%gCyc,kHz)',	S.Mod.Spec(1)*1000),...
        sprintf('+%gOct_',          S.Seed.OctRise),...
        sprintf('%2.0fdBSPL_',     S.Level.TargetLevel),...
        sprintf('att@%4.1f_',       S.Trial.Atts),...
        sprintf('%s',               datestr(now, 'yymmdd')),...
        ]; 
%         sprintf('[SSOOOOSS]@(Uu=unfilt,Ff=Filt@%g)Cyc,kHz)',	S.Mod.Spec(1)*1000),...
    S.SoundTotalInt16 =  int16(S.SoundTotalS*32767);
    S.Session.Comment = [' ',...
        'TrialNames: ',             cell2mat(S.Trial.Names),        '; ',...
        'TrialAttenuations: ',      num2str(S.Trial.Atts),          '; ',...
        'TrialNumberTotal: ',       num2str(S.Trial.NumberTotal),	'; ',...
        'TrialDurTotal(sec): ',   	num2str(S.Trial.Duration),      '; ',...
        'TrialDurPreStim(sec): ',	num2str(S.Trial.PreStimTime),	'; ',...
        'TrialDurStim(sec): ',    	num2str(S.Trial.StimDuration),	'; ',...
        'SesTrlOrder: ',            'Pre-arranged',                 '; ',...
        'SesCycleNumTotal: '        num2str(S.SesCycleNumTotal),	'; ',...
        'SesTrlOrderMat: '          num2str(ones(1, S.SesCycleNumTotal)), '; ',...
        'SesSeedOrder: '            num2str(S.Session.SeedSeq),     ';',...
        ''];
    audiowrite([ S.Session.Title,'.wav'],...
        S.SoundTotalInt16,	S.System.SR,...
        'BitsPerSample',	16,...
        'Title',            S.Session.Title,...
        'Artist',           S.Session.Artist,...
        'Comment',          S.Session.Comment);
    
    