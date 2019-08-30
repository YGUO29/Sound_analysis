% M9606 Phrase timing distribution
clear;clc;close all

computer_name = getenv('computername');
if strcmp(computer_name,'TELEMETRY-2')
    work_path = 'E:\LingyunZhao_Files\Dropbox\RemoteWork\';    
elseif strcmp(computer_name,'ZLYPC')
    work_path = 'E:\Files\Dropbox\RemoteWork\';
elseif strcmp(computer_name,'ZLY-YOGA')
    work_path = 'C:\Users\Lingyun\Dropbox\RemoteWork\';
end

filepath = fullfile(work_path,'DataAnalysis\Colony\Done');
session_files = dir([filepath,'\Session_voc_M91C_M92C_M64A_M29A*.mat']);
file_list = {session_files.name};

Subject_ID = 'M64A';

calltypes.CallTypeList = {'Phee','Twitter','Trill','Trillphee','P-peep','Tse/Sd-peep','Other'};
calltypes.CallSubType = {{'Phee','Phee-cry','Phee-other'},...
               {'Twitter','Trill-twitter'},...
               {'Trill','Trill string','T-peep','T-peep string','T_peep'},...
               {'Trillphee'},...
               {'P-peep','P-peep string'},...
               {'Tse','Sd-peep','Tse string','Sd-peep string','Tsik','Tse/Sd-peep string'},...
               {'Other','Subharmonic','Other+cry','Peep','Peep string','Peep-string','Compound call','Dh-peep','Egg','Egg string','Sa-peep','Sa-peep string'}...
               };


param.calltypes = calltypes;
param.subject_ID = Subject_ID;
param.dur_range = [0,0.12];        % range of phrase length to plot IPI
PhraseTiming_Dist(filepath, file_list,param);
                     