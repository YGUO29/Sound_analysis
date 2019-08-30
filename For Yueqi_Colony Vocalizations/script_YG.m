% Demo for loading call data
%  --- Lingyun Zhao

% Please add the "social" folder and its subfolders to matlab path

% Change this to your .mat folder
datapath = 'D:\=code=\Sound_analysis\For Yueqi_Colony Vocalizations\Call Information\M91C_M92C_M64A_M29A_For Feature Extraction (Good quality)';
session_name = 'voc_M91C_M92C_M64A_M29A_S95';

%% Load data
load(fullfile(datapath,['Session_' session_name]));
whos(session_name)

% a "social" class variable named "voc_M91C_M92C_M64A_M29A_S80" will be in work space


beh_data = eval([session_name '.Behaviors']);

% the "Behaviors" field contains the information for each recording
% channel/animal. Within each "Behaviors(ch)":
% Subjects:     animal ID
% Events:       an array of individual phrases


% Choose recording channel
ch = 4;    

% Print the subject ID
AnimalID = beh_data(ch).Subjects       

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
iCall = 18;
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
