% Demo for loading call data
%  --- Lingyun Zhao

% modified by Yueqi 2020/Feb
% this script get the calls around 2s (parameters set by time_cut)


% Please add the "social" folder and its subfolders to matlab path

% Change this to your .mat folder
addpath(genpath(cd))
% datapath = 'D:\=code=\Sound_analysis\For Yueqi_Colony Vocalizations\Call Information\M91C_M92C_M64A_M29A_For Feature Extraction (Good quality)';
datapath = 'D:\=code=\Sound_analysis\For Yueqi_Colony Vocalizations\Call Information\M93A';
% soundpath = 'D:\=sounds=\Vocalization\LZ_merge_good quality';
soundpath = 'D:\=sounds=\Vocalization\LZ_93A';

list = dir(fullfile(datapath,'*.mat'));

% session_name = 'voc_M91C_M92C_M64A_M29A_S95';

%% Load data
S = struct;
S.dur_real = [];
S.nSession = length(list);
S.ramp = 0.1; % 0.2s ramp up and down
S.pad = 0.1; % 0.1s padding before call start
S.range = [1.8, 2.2]; % select calls with duration within this range

%%
fwait = waitbar(0,'Started getting calls ...');
for i = 1:S.nSession
    waitbar(i/S.nSession,fwait,['Getting calls from session ',num2str(i),'/',num2str(S.nSession)]);

    load(list(i).name);
    session_name_temp = strsplit(list(i).name(1:end-4),'_');
    session_name = strjoin(session_name_temp(2:end),'_')
    % a "social" class variable named "voc_M91C_M92C_M64A_M29A_S80" will be in work space

    beh_data = eval([session_name '.Behaviors']);
    % the "Behaviors" field contains the information for each recording
    % channel/animal. Within each "Behaviors(ch)":
    % Subjects:     animal ID
    % Events:       an array of individual phrases
    % Choose recording channel
    
    for ch = 1:length(beh_data) % 1 or 4 channels
        % Print the subject ID
        AnimalID = beh_data(ch).Subjects;  
        phrases = beh_data(ch).Events; 
        if ~isempty(phrases)
            % Set up stored default parameters
            out = SubjectVocalParam(AnimalID);
            IPI_th = out.IPI_th;            % inter-phrase interval threshold, phrases with IPI smaller than this will be grouped as one call
            param_call.IPI_th = IPI_th;
            param_call.Phrase2Call_Rule = '';
            calls = beh_data(ch).GetCalls(param_call);          % This will call a class function in the "social" package to group phrases into calls
                                                        % calls is an array of Calls
            for iCall = 1:length(calls)
                % Get the sampling rate in case you need it later
                fs = beh_data(ch).SigDetect.SampleRate;
                % Read the wave file
                waveform1 = calls(iCall).get_signal;     % this calls a class function to retrieve the signals from the wav files
                S.dur_real = [S.dur_real, calls(iCall).eventStopTime - calls(iCall).eventStartTime];
                
                time_cut(1) = calls(iCall).eventStartTime - S.pad;
                time_cut(2) = calls(iCall).eventStopTime + S.pad;
                waveform2 = beh_data(ch).get_signal(time_cut);

%                 if S.dur_real(end)>=S.range(1) &&  S.dur_real(end)<=S.range(2)
                if S.dur_real(end)<=S.range(2)
                    y = waveform2{1}(1:end-1);
                    y = y - mean(y);
                    y = y./max(abs(y)); 
%                     figure, plot(1/fs:1/fs:length(y)/fs, y)
%                     y_new = y;
%                     y_new(1:S.ramp*fs) = y(1:S.ramp*fs).*linspace(0,1,S.ramp*fs)';
%                     y_new(end-S.ramp*fs+1:end) = y(end-S.ramp*fs+1:end).*linspace(1,0,S.ramp*fs)';                    
%                     soundsc(y,fs), soundsc(y_new,fs)
                    if ~exist([soundpath, '\', calls(iCall).eventCallType], 'dir')
                        mkdir([soundpath, '\', calls(iCall).eventCallType])
                    end
                    if ~isempty(y)
                    audiowrite([soundpath, '\', calls(iCall).eventCallType, '\', AnimalID, '_',...
                        session_name_temp{end}, '_call',num2str(iCall), '.wav'], y, fs);
                    end
                end
            end
        end

    end
end



%% Get all phrases
phrases = beh_data(ch).Events;      

phrases(1)
% Each phrase(i), or voc_M91C_M92C_M64A_M29A_S80.Behaviors(1).Events(i)
% stores parameters of its start/stop time, type of phrase, etc.
% Note that we store individual phrases rather than calls in this data
% structure.

% eventStartTime:       start time relative to recording session start
% eventStopTime:        stop time
% eventPhraseType:      call type for this phrase, e.g. "Phee", "Trill"
%                       for multi-phrase calls like twitter, each
%                       phrase/pulse is labeled as "Twitter"

%% Group phrases to calls

% Set up stored default parameters
out = SubjectVocalParam(AnimalID);
IPI_th = out.IPI_th;            % inter-phrase interval threshold, phrases with IPI smaller than this will be grouped as one call

param_call.IPI_th = IPI_th;
param_call.Phrase2Call_Rule = '';

calls = beh_data(ch).GetCalls(param_call);          % This will call a class function in the "social" package to group phrases into calls
                                                    % calls is an array of Calls
        
% You can also write other functions to define your own rule to group them.

calls(1)
% Within each "calls(i)", you can find parameters:
% eventPhrases:         an array of phrases (Phrase class instances) that this call is composed of
% eventCallType:        call type
% nPhrases:             number of phrases this call has
% IPI_threshold:        inter-phrase interval threshold used to group calls
% eventStartTime:       start time of this call
% eventStopTime:        stop time of this call


%% Get the recorded signal for a call
iCall = 3;
% Get the sampling rate in case you need it later
fs = beh_data(ch).SigDetect.SampleRate;

% Read the wave file
waveform1 = calls(iCall).get_signal;     % this calls a class function to retrieve the signals from the wav files

% Note: 
% (1) I'm not connected to the lab server so this does not work on my 
%     machine - but it should work once you log in to the server through 
%     windows file system. You can also read directly the wave file by 
%     "audioread" using the start/stop time.
% (2) This function is probably using the original wave file, not the
%     "balanced gain" one. But it shouldn't matter in this case - only some
%     gain difference. M93A and M9606 don't have this issue at all.
% (3) It cuts a call tightly to the start and stop time. If you like to
%     include more data before and after a call, try this:

pt = 0.5;       % pre/post call time to add
% time_cut(2) = calls(iCall).eventStopTime + pt;
time_cut(1) = calls(iCall).eventStartTime;
time_cut(2) = calls(iCall).eventStartTime + 2;
waveform2 = beh_data(ch).get_signal(time_cut);

calls(iCall).eventStopTime - calls(iCall).eventStartTime

y = waveform2{1}(1:end-1);
y = y./max(abs(y));
soundsc(y,fs)

%% load another sound file
% [y, fs] = audioread('V:\CageMerge\M91C_M92C_M64A_M29A\voc_M91C_M92C_M64A_M29A_S36.wav',...
%     floor(fs.*time_cut));
% y = y(:,4); 
audiowrite(['Voc_LZ_S95_Call', num2str(iCall), '_29A_trillphee.wav'], y, fs)
