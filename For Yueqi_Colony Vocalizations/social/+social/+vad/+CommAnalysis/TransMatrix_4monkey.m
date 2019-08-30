% Calculate 4 monkey call transition probability

% clear;clc;close all

computer_name = getenv('computername');
if strcmp(computer_name,'TELEMETRY-2')
    work_path = 'E:\LingyunZhao_Files\Dropbox\RemoteWork\';    
elseif strcmp(computer_name,'ZLYPC')
    work_path = 'E:\Files\Dropbox\RemoteWork\';
elseif strcmp(computer_name,'ZLY-YOGA')
    work_path = 'C:\Users\Lingyun\Dropbox\RemoteWork\';
elseif strcmp(computer_name,'LEOXPS')
    work_path = 'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\Social';
end

if strcmp(computer_name,'LEOXPS')
    rec_path = 'D:\Vocalization\M91C_M92C_M64A_M29A\';
    log_table_file = 'D:\Vocalization\M91C_M92C_M64A_M29A.xlsx';
else
    rec_path = '\\datacenterchx.bme.jhu.edu\Recording_Colony_Vocalization\CageMerge\M91C_M92C_M64A_M29A\';
    log_table_file = '\DataAnalysis\Colony\M91C_M92C_M64A_M29A.xlsx';
end

SubjectIDs = {'M91C','M92C','M64A','M29A'};
% CallTypeList = {'Phee','Twitter','Trill','Trillphee','P-peep','Tse/Sd-peep','Other'};
% CallSubType = {{'Phee','Phee-cry','Phee-other'},...
%                {'Twitter','Trill-twitter'},...
%                {'Trill','Trill string','T-peep','T-peep string','T_peep'},...
%                {'Trillphee'},...
%                {'P-peep','P-peep string'},...
%                {'Tse','Sd-peep','Tse string','Sd-peep string','Tsik','Tse/Sd-peep string'},...
%                {'Other','Subharmonic','Other+cry','Peep','Peep string','Peep-string','Compound call','Dh-peep','Egg','Egg string','Sa-peep','Sa-peep string'}...
%                };
% CallTypeList = {'Phee','Twitter','Trill','Trillphee','Tse','Sd-peep','Other'};
CallTypeList = {'Phee','Twitter','Trill','Trillphee','Sd-peep'};
CallTypeMap = containers.Map({'Phee','Twitter','Trill','Trillphee','Tse','Sd-peep','P-peep','Tsik'},[1,2,3,4,5,5,1,5]);
CallSubType = {{'Phee','Phee-cry','Phee-other','P-peep','P-peep string'},...
               {'Twitter','Trill-twitter'},...
               {'Trill','Trill string','T-peep','T-peep string','T_peep'},...
               {'Trillphee'},...
               {'Sd-peep','Sd-peep string','Tse','Tse string','Tsik','Tse/Sd-peep string'},...
%                {'Other','Subharmonic','Other+cry','Peep','Peep string','Peep-string','Compound call','Dh-peep','Egg','Egg string','Sa-peep','Sa-peep string'}...
               };
win = 3;        % usually use 6 sec window
spon_win = [-10,-7];   % spontaneous window
gap_max = 0.5;      % max gap interval for phrases considered one call
% condition = 5;

param = social.vad.CommAnalysis.VocComm4_Config(condition);
file_list = param.file_list;
SubjectCh = param.SubjectCh;

% log_table = xlsread(fullfile(work_path,log_table_file));

% loop through the file list

N_phrase = zeros(1,4);
N_call = zeros(1,4);
N_phrasetype = zeros(4,length(CallTypeList));
N_calltype = zeros(4,length(CallTypeList));
dur_total = zeros(1,4);
phrase_interval = [];
transition_interval = [];
self_interval = [];         % onset to onset interval between two calls from the same subject
call_table = cell(1,length(file_list));
calltypes_table = cell(1,length(file_list));
% % get recording date and recording length
% info_file = [];
% for fi = 1 : length(file_list)
%     head_file = [file_list{fi}(16:end-4),'.hdr'];
%     h_head_file = fopen(fullfile(rec_path,head_file));
%     head_table{fi} = textscan(h_head_file,'%s %s','Delimiter','=');
%     [flag, ind] = ismember('Date ', head_table{fi}{1});
%     if flag == 1 
%         info_file(fi).date = head_table{fi}{2}{ind};
%     end
%     [flag, ind] = ismember('Total Recording Length ', head_table{fi}{1});
%     if flag == 1
%         info_file(fi).length = str2num(head_table{fi}{2}{ind}) / 3600;
%     else
%         display(1);
%     end
% end


for fi = 1:length(file_list)
    filepath = fullfile(work_path,'+social\+vad\+selectionTable\06-07_Lingyun',file_list{fi});
    
    fileID = fopen(filepath);
    ind = strfind(file_list{fi},'.txt');
    rec_file = file_list{fi}(16:ind-1);
    rec_file = [rec_file,'.wav'];

    data_table{fi} = textscan(fileID,'%d %s %d %f %f %f %f %f %s %f %f %f %f %f %d','Delimiter','\t','Headerlines',1);
    fclose(fileID);
    
    % for recording duration, it will look at the recording file total samples
    winfo = audioinfo(fullfile(rec_path,rec_file));
    rec_dur(fi) = winfo.Duration;
    
    
    
    % calculations across files within the same condition
    % 1. Overall call rate for each animal
    % 2. --
    % 3. call rate for each call types
    % 4. call modulation matrix for each pair (how to choose window, whether to include calls before the next initiator call)
    % 5. most frequent call transition (which call-type to which call-type) between each pair
    % 6. Call end to start interval distribution
    % 7. call transition interval (start-start) for all condition, all animals
    
    
    
    % call rate for each animal
    Ch_ID = data_table{fi}{3};
    start_time = data_table{fi}{4};
    stop_time = data_table{fi}{5};
    
    start_time_call_sbj = cell(1,length(SubjectIDs));
    stop_time_call_sbj = cell(1,length(SubjectIDs));
    
    for si = 1:length(SubjectIDs)
        ind_subject = find(Ch_ID == SubjectCh(si)); 
        N_phrase(si) = N_phrase(si) + length(ind_subject);      % how to group phrase into calls?
        dur_total(si) = dur_total(si) + rec_dur(fi);
        
        % find all phrase types from this subject
        calltypes = data_table{fi}{9}(ind_subject);
        
        for ci = 1:length(CallTypeList)
            
            for cj = 1:length(CallSubType{ci});
                N_phrasetype(si,ci) = N_phrasetype(si,ci) + sum(strcmp(calltypes,CallSubType{ci}{cj}));
                
            end
        end
        
        % find inter-phrase intervals
        start_time_sbj = start_time(ind_subject);
        stop_time_sbj = stop_time(ind_subject);
        
        phrase_interval = [phrase_interval;start_time_sbj(2:end)-stop_time_sbj(1:end-1)];
        
        % Combine phrases to calls
        pp = 1;
        start_time_call_sbj{si} = start_time_sbj;
        stop_time_call_sbj{si} = stop_time_sbj;
        
        while pp < length(start_time_call_sbj{si})
            if start_time_call_sbj{si}(pp+1)-stop_time_call_sbj{si}(pp) <= gap_max
                calltypes{pp} = [calltypes{pp},'+',calltypes{pp+1}];
                calltypes(pp+1) = [];
                start_time_call_sbj{si}(pp+1) = [];
                stop_time_call_sbj{si}(pp) = [];
            else
                pp = pp + 1;
            end
        end
        N_call(si) = N_call(si) + length(start_time_call_sbj{si});
        
        % decide call types from phrase string
        for ci = 1 : length(calltypes)
            s = calltypes{ci};
            s_split = regexp(s, '+', 'split');
            type_count = zeros(1,length(CallTypeList));
            for pi = 1 : length(s_split)
                if ~isKey(CallTypeMap, s_split)
                    display(1)
                end
                ind_phrase_type = CallTypeMap(s_split{pi});
                type_count(ind_phrase_type) = type_count(ind_phrase_type) + 1;
            end
            ind_call_type = find(type_count == max(type_count));
            ind_call_type = ind_call_type(1);
            calltypes{ci} = CallTypeList{ind_call_type};
        end

       for ci = 1:length(CallTypeList)
            
            for cj = 1:length(CallSubType{ci});
                N_calltype(si,ci) = N_calltype(si,ci) + sum(strcmp(calltypes,CallSubType{ci}{cj}));
                
            end
        end
        
        % form a call table again
        call_table{fi} = [call_table{fi}; [repmat(si,length(start_time_call_sbj{si}),1),start_time_call_sbj{si},stop_time_call_sbj{si}]];
        calltypes_table{fi} = [calltypes_table{fi};calltypes];
    end
    
    
    [call_table{fi},index] = sortrows(call_table{fi},2);
    calltypes_table{fi} = calltypes_table{fi}(index);
    % collect transition interval
    for ti = 1:size(call_table{fi},1)-1
        if call_table{fi}(ti,1) ~= call_table{fi}(ti+1,1)
            transition_interval = [transition_interval; call_table{fi}(ti+1,2)-call_table{fi}(ti,2)];
        else
            self_interval = [self_interval;call_table{fi}(ti+1,2)-call_table{fi}(ti,2)];
        end
    end
   
end

if condition == 8
    N_phrase([2,4]) = N_phrase([2,4]) / 2;
    N_call([2,4]) = N_call([2,4]) / 2;
    N_calltype([2,4],:) = N_calltype([2,4],:) / 2;
end

if condition == 7
    N_phrase([2,4]) = N_phrase([2,4]) / 2;
    N_call([2,4]) = N_call([2,4]) / 2;
    N_calltype([2,4],:) = N_calltype([2,4],:) / 2;
end

rate_phrase = N_phrase./dur_total*60     % per minute
rate_call = N_call./dur_total*60         % per minute
ratio_phrasetype = N_phrasetype./repmat(N_phrase',1,size(N_phrasetype,2));
rate_calltype = N_calltype/dur_total(1)*60

%% trigger
%{
time_resp_trial = cell(4,4);

% reuse some variables
Ch_ID = [];
start_time = [];

% combine sessions in a dirty way...
for fi = 1:length(file_list)
    
    Ch_ID = [Ch_ID; call_table{fi}(:,1)];
    start_time = [start_time; call_table{fi}(:,2)+fi*1e5];
    
end
win = 15;
for i = 1 : 4
    ind = find(Ch_ID == i);
    for k = 1 : length(ind)
        ind_r = find(abs(start_time-start_time(ind(k))) <= win);
        for j = 1 : 4
            if j ~= i
                for kk = 1 : length(ind_r)
                    if Ch_ID(ind_r(kk)) == j
                        time_resp_trial{j,i} = [time_resp_trial{j,i};start_time(ind_r(kk))-start_time(ind(k))];
                    end
                end
            end
        end
    end
end
    
for i = 1 : 4
    for j = 1 : 4
        subplot(4,4,(i-1)*4+j);
        hold on        
        if i ~= j
            [f, t] = ksdensity(time_resp_trial{j,i},'bandwidth',0.5);
            N_resp = length(time_resp_trial{j,i});
            if (condition == 8) && ((j==2) || (j==4))
                N_resp = N_resp / 2;
            end
            if ((condition == 8)||(condition == 7)) && ((i==2)&&(j==4)||(i==4)&&(j==2))
                continue;
            end
            plot(t(abs(t)<=10),f(abs(t)<=10)*N_resp/length(find(Ch_ID == i)));        
            if (condition == 5)
                axis = gca;
                set(axis, 'YLim', [0,max(f(abs(t)<=10)*N_resp/length(find(Ch_ID == i)))+0.02]);
            end
        end
    end
end
%}



%% transition calculation
%{
    total_i = zeros(1,4);       % to save the total number of initiator calls
    N_resp = zeros(4,4);        % to save the total number of responder calls;
    N_base = zeros(4,4);        % to save the total number of baseline calls;
    N_resp_trial = cell(4,4);
    N_base_trial = cell(4,4);
% reuse some variables
Ch_ID = [];
start_time = [];
calltypes = {};
win = 3;
spon_win = [-10,-7];
% combine sessions in a dirty way...
for fi = 1:length(file_list)  
    Ch_ID = [Ch_ID; call_table{fi}(:,1)];
    start_time = [start_time; call_table{fi}(:,2)+fi*1e5];
    calltypes = [calltypes;calltypes_table{fi}];
end
    for i = 1:4  % initiator
        ind = find(Ch_ID == i);
        total_i(i) = length(ind);
        for k = 1:length(ind)
            % using all calls in the window
            ind_r = find(start_time(ind(k)+1:end)-start_time(ind(k)) <= win);
            for j = 1:4
                if j ~= i
                    if isempty(ind_r)
                        N_resp_trial{i,j} = [N_resp_trial{i,j};0];
                        continue;
                    end
                    N_resp(i,j) = N_resp(i,j) + length(find((Ch_ID(ind_r+ind(k)) == j) & (~CalltypeSwitch | (cell2mat(values(CallTypeMap,calltypes(ind_r+ind(k)))) == targetCalltype))))/win;         % it's actually call rate, not call number
                    N_resp_trial{i,j} = [N_resp_trial{i,j}; length(find((Ch_ID(ind_r+ind(k)) == j) & (~CalltypeSwitch | (cell2mat(values(CallTypeMap,calltypes(ind_r+ind(k)))) == targetCalltype))))/win];
                end
            end
            

            ind_b = find(start_time(1:ind(k)-1)-start_time(ind(k)) >= spon_win(1) & start_time(1:ind(k)-1)-start_time(ind(k)) <= spon_win(2));

            for jj = 1:4
                if jj ~= i
                    if isempty(ind_b) 
                        N_base_trial{i,jj} = [N_base_trial{i,jj};0];
                        continue;
                    end
                    N_base(i,jj) = N_base(i,jj) + length(find((Ch_ID(ind_b) == jj) & (~CalltypeSwitch | (cell2mat(values(CallTypeMap,calltypes(ind_b))) == targetCalltype)))) / diff(spon_win);
                    N_base_trial{i,jj} = [N_base_trial{i,jj}; length(find((Ch_ID(ind_b) == jj) & (~CalltypeSwitch | (cell2mat(values(CallTypeMap,calltypes(ind_b))) == targetCalltype))))/diff(spon_win)];
                end
            end
        end
        
        for j = 1 : 4
            if ((condition == 8)||(condition == 7)) && ((j == 2)||(j == 4))
                N_resp(i,j) = N_resp(i,j) / 2;
                N_base(i,j) = N_base(i,j) / 2;
            end
        end
        
        ratio_resp(i,:) = (N_resp(i,:)-N_base(i,:))./(N_resp(i,:)+N_base(i,:));    
%         ratio_resp(i,:) = (N_resp(i,:)/N_call(i) - rate_call/60)./(rate_call/60); 
        for j = 1:4
            if j ~= i
                [p_val(j,i),h] = signrank(N_resp_trial{i,j},N_base_trial{i,j});
            end
        end

    end

    ratio_resp
%     p_val
%}


%% Cross Correlation
%{
bin_size = 0.5;
xx = -win:bin_size:win;
N_xcorr_bin = cell(4,4);
hf = figure;
win = 10;

for i = 1:4   % initiator
    for j = 1:4
        if j == 3
            aa = 0;
        end
        intervals = [];
        for fi = 1:length(file_list)
            ind_init = find(call_table{fi}(:,1)==i);
            for ii = 1:length(ind_init)
                
                    if j ~= i
                        init_time = call_table{fi}(ind_init(ii),2);
                        ind_resp = find(call_table{fi}(:,1)==j);
                        intervals = [intervals;call_table{fi}(ind_resp,2)-init_time];
                    end
            end
        end
        
        N_xcorr_bin{i,j} = hist(intervals,xx);
        subplot(4,4,(i-1)*4+j)
        bar(xx(2:end-1),N_xcorr_bin{i,j}(2:end-1)/length(intervals))
        grid on
        xlim([min(xx),max(xx)])
        
        
        if i == 1
            title([ 10 SubjectIDs{j}],'FontWeight','Normal')
        end
        if j == 1
            ylabel([ 10 SubjectIDs{i}])
            
        end
        if i == 4
            xlabel('Time (s)')
        end
        if j == 1 & i == 1
            
            ylabel(['Initiator' 10 SubjectIDs{i}])
            title(['Responder' 10 SubjectIDs{j}],'FontWeight','Normal')
        end
    end
end
saveas(hf,['VocComm4_Xcorr_Condition_' num2str(condition)],'fig')   

% % %% Cross correlation for trill only
% % 
% % hf = figure;
% % for i = 1:4   % initiator
% %     for j = 1:4
% %         intervals = [];
% %         for fi = 1:length(file_list)
% %             trill_table = call_table{fi};
% %             ind_init = find(call_table{fi}(:,1)==i);
% %             for ii = 1:length(ind_init)
% %                 
% %                     if j ~= i
% %                         init_time = call_table{fi}(ind_init(ii),2);
% %                         ind_resp = find(call_table{fi}(:,1)==j);
% %                         intervals = [intervals;call_table{fi}(ind_resp,2)-init_time];
% %                     end
% %             end
% %         end
% %         
% %         N_xcorr_bin{i,j} = hist(intervals,xx);
% %         subplot(4,4,(j-1)*4+i)
% %         bar(xx(2:end-1),N_xcorr_bin{i,j}(2:end-1)/length(intervals))
% %         grid on
% %         xlim([min(xx),max(xx)])
% %         
% %         if j == 4 & i == 1
% %             xlabel('Time (s)')
% %             ylabel('Responder')
% %             title('Initiator')
% %         end
% %     end
% % end


    
save(['VocComm4_Condition' num2str(condition)],'SubjectIDs','CallTypeList','condition','rate_call','rate_phrase','N_phrasetype','ratio_phrasetype','dur_total','phrase_interval','transition_interval','self_interval','call_table','ratio_resp','p_val');
 
%}

