% Calls_MAT2Table

% Here channel number is hard coded in the order of behavior channels


param = social.vad.tools.Param(subject);
computer_name = getenv('computername');
if strcmp(computer_name,'TELEMETRY-2')
    work_path = 'E:\LingyunZhao_Files\Dropbox\RemoteWork\';  
    output_path = 'E:\LingyunZhao_Files\Dropbox\RemoteWork\';  
elseif strcmp(computer_name,'ZLYPC')
    work_path = 'E:\Files\Dropbox\RemoteWork\';
    output_path = 'E:\Files\Dropbox\RemoteWork\';
elseif strcmp(computer_name,'ZLY-YOGA')
    work_path = 'C:\Users\Lingyun\Dropbox\RemoteWork\';
    output_path = 'C:\Users\Lingyun\Dropbox\RemoteWork\';
elseif strcmp(computer_name,'LEOXPS')
    work_path = param.dataFolder;
    output_path = param.selectionTablePathOut;
end

filename = ['Session_',prefix,'_',subject,'_',sessionNum];
StartIndex = 1;
filepath = fullfile(work_path,[filename,'.mat']);

load(filepath)
var_name = filename(9:end);
output_name = ['SelectionTable_' var_name,'.txt'];
output_file = fullfile(output_path,output_name);

fid = fopen(output_file,'w');
fprintf(fid,'%s\r\n','Selection	View	Channel	Begin Time (s)	End Time (s)	Low Freq (Hz)	High Freq (Hz)	Max Freq (Hz)	Call Type');

beh = eval([var_name '.Behaviors']);
k = StartIndex;

for i = 1:length(beh)
    for j = 1:length(beh(i).Events)
        
        if isempty(beh(i).Events(j).eventStartTime)
            ss = 1;
        end
        
        fprintf(fid,'%d\t%s\t%d\t%f\t%f\t%f\t%f\t%f\t%s\r\n', k,'Spectrogram 1',beh(i).SigDetect.Channel, beh(i).Events(j).eventStartTime,  beh(i).Events(j).eventStopTime, 4000,18000,8000,beh(i).Events(j).eventPhraseType);
        k = k + 1;
    end
end
fclose(fid);