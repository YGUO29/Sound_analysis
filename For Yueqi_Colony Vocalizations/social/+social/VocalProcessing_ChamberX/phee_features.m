% calculate phee features
clc;clear;close all;

% loadname = 'PheeTime_M108Z_140124_S1.mat';
  loadname = 'PheeTime_voc_9606_S283.mat';
% loadname = 'PheeTime_M9001_130910_S1.mat';
% loadname = 'PheeTime_M9606_141010_S1-2.mat';
%loadname = 'PheeTime_M4526_M7Z_130705_S2.mat';
load(loadname);
% Ch_ID = {'C36R','M9001'};
%Ch_ID = {'C30O','M4526'};
% Ch_ID = {'M4526','M7Z'};
%  Ch_ID = {'C36R','M108Z'};
% denoise = 0;        % 1 if using denoised audio file; 0 if not

 Ch_ID = {'C36R','M9606'};           % for CH1 and CH2, used for Marmovox recording
% Ch_ID = {'M9606','C36R'};           % for CH1 and CH2, used for Raven recording
% Ch_ID = {'M9606','Colony'};           % for CH1 and CH2, used for Raven recording
gap_max = 1.2;              % max gap time  (s) between two phee phrases
Nphrases_max = 10;           % maximum 4 phrases

fullpath = [filepath filename];

% if denoise == 1
%     strind = strfind(fullpath,'.wav');
%     fullpath = [fullpath(1:strind-1) '_denoise.wav'];
% end

strind = strfind(filename,'denoise');
if isempty(strind)
    denoise = 0;
else
    denoise = 1;
end

if denoise == 1     % use raw recording to find features
    strind = strfind(fullpath,'_denoise.wav');
    fullpath = [fullpath(1:strind-1) '.wav'];
end

% determine phrases
call_start = cell(1,2);
call_stop = cell(1,2);

for j = 1:2
    call_num = 1;
    phrase_num = 1;
    if ~isempty(t_start{j})
        call_start{j} = zeros(length(t_start{j}),Nphrases_max);     
        call_stop{j} = zeros(length(t_stop{j}),Nphrases_max);     
        call_start{j}(1,1) = t_start{j}(1);
        call_stop{j}(1,1) = t_stop{j}(1);
        for i = 2:length(t_start{j})
            if t_start{j}(i) - t_stop{j}(i-1) < gap_max  % multi-phrase in a call
                phrase_num = phrase_num + 1;

            else
                call_num = call_num + 1;
                phrase_num = 1;
            end
            call_start{j}(call_num,phrase_num) = t_start{j}(i);
            call_stop{j}(call_num,phrase_num) = t_stop{j}(i);
        end
        call_sum = sum(call_start{j},2);
        ind = find(call_sum==0);
        call_start{j}(ind,:) = [];
        call_stop{j}(ind,:) = [];
    else
        call_start{j} = [];
        call_stop{j} = [];
    end
    
end

call_start_mix1 = [call_start{1},ones(size(call_start{1},1),1)];
call_start_mix2 = [call_start{2},ones(size(call_start{2},1),1)*2];
call_stop_mix1 = [call_stop{1},ones(size(call_stop{1},1),1)];
call_stop_mix2 = [call_stop{2},ones(size(call_stop{2},1),1)*2];
call_start_mix = [call_start_mix1;call_start_mix2];
call_stop_mix = [call_stop_mix1;call_stop_mix2];



% sort timing
[B IX] = sort(call_start_mix(:,1));
call_start_mix = call_start_mix(IX,:);
call_stop_mix = call_stop_mix(IX,:);



% PheeCall is a structure to store call information
% disp('Calculating call features...');
hw = waitbar(0,'Processing call features');
for i = 1:size(call_start_mix,1)
    wait_frac = i/size(call_start_mix,1);
    waitbar(wait_frac,hw,['Processing call features...', num2str(round(wait_frac*100)),'%']);
    PheeCall(i).CallerID = Ch_ID{call_start_mix(i,Nphrases_max+1)};
    Nphrases = length(find(call_start_mix(i,1:Nphrases_max)~=0));
    PheeCall(i).Nphrases = Nphrases;
    PheeCall(i).Time = [call_start_mix(i,1:Nphrases);call_stop_mix(i,1:Nphrases)]';
    for j = 1:Nphrases
        y = wavread(fullpath, [max(1,round(call_start_mix(i,j)*Fs)),round(call_stop_mix(i,j)*Fs)]);
        y = y(:,call_start_mix(i,Nphrases_max+1));
        
        
        y_extra = wavread(fullpath, [round(call_stop_mix(i,j)*Fs)+1,round(call_stop_mix(i,j)*Fs)+2000]);
        y_extra = y_extra(:,call_start_mix(i,Nphrases_max+1));
        y = y-mean([y;y_extra]);
        y_extra = y_extra-mean([y;y_extra]);
        % Power is a two column matrix, the first column is time, the
        % second column is the power of the phee, 1ms bins, no smoothing
        PheeCall(i).Power{j} = GetPheePower(y,call_start_mix(i,j),Fs);
        % F0 is a two column matrix, the first column is time, the
        % second column is the F0 of phee, 1ms bins, no smoothing 
        [PheeCall(i).F0{j}, PheeCall(i).F0_Energy{j}] = GetPheeF0(y,y_extra,call_start_mix(i,j),Fs);
        
% %         % get rid of the start and stop NaNs to align the call correctly
% %         for tag1 = 1:size(PheeCall(i).F0{j},1)
% %             if ~isnan(PheeCall(i).F0{j}(tag1,2))
% %                 break
% %             end
% %         end
% %         for tag2 = size(PheeCall(i).F0{j},1):-1:1
% %             if ~isnan(PheeCall(i).F0{j}(tag2,2))
% %                 break
% %             end
% %         end
% %         PheeCall(i).F0{j} = PheeCall(i).F0{j}(tag1:tag2,1:2);
% %         PheeCall(i).Power{j} = PheeCall(i).Power{j}(tag1:tag2,1:2);
% %         PheeCall(i).Time(j,:) = PheeCall(i).F0{j}([1,size(PheeCall(i).F0{j},1)],1)';
% %         
% % %         figure(30)
% % %         cla
% % %         plot(PheeCall(i).F0{j}(:,1),PheeCall(i).F0{j}(:,2));
% % %         hold on
% % %         plot([PheeCall(i).F0{j}(1,1),PheeCall(i).F0{j}(end,1)],[PheeCall(i).F0{j}(1,2) PheeCall(i).F0{j}(end,2)],'r.')
% %         
% %         % correct the lookup table!
% %         call_start_mix(i,j) = PheeCall(i).Time(j,1);
% %         call_stop_mix(i,j) = PheeCall(i).Time(j,2);
    end
    
end
delete(hw);

% Data structure for lookup table
% .________________________________________________________________________________.
% | Phrase 1 Time | Phrase 2 Time | Phrase 3 Time | Phrase 4 Time | Caller Channel |
% |________________________________________________________________________________|
PheeLookup.Start = call_start_mix;
PheeLookup.Stop = call_stop_mix;

savename = strrep(loadname,'PheeTime_','PheeInfo_');
savename = strrep(savename,'_denoise','');
save(savename,'PheeCall','PheeLookup');




