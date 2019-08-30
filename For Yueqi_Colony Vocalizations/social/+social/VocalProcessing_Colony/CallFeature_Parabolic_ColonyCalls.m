% calculate phee features
clc;clear;close all;

loadname = 'CallTime_voc_9606_c_S175.mat';
load([loadname]);
import social.*
Ch_ID = {'M9606','Colony'};           % for CH1 and CH2, used for Marmovox recording, CH1 has to be the monkey recorded
gap_max = 1;              % max gap time  (s) between two call phrases

fullpath = [filepath filename];

%% Building a Event List

callnum = 1;
phrasenum = 1;

hw = waitbar(0,'Processing call features');

for i = 1:length(t_start{1})
    wait_frac = i/length(t_start{1});
    waitbar(wait_frac,hw,['Processing call features...', num2str(round(wait_frac*100)),'%']);
    
    DEventList(i) = ExpDEvent;
    DEventList(i).Name = 'Call';
    DEventList(i).Type = 'Vocalization';
    DEventList(i).Time.SetTime([t_start{1}(i) t_stop{1}(i)]);
    DEventList(i).Props.CallerID = Ch_ID{1};
    DEventList(i).Props.CallType = calltype{1}{i};
    
    
    if i > 1 
        if t_start{1}(i) - t_stop{1}(i-1) < gap_max  % multi-phrase in a call
                phrasenum = phrasenum + 1;
                
        else
            % asign Nphrases to previous phrases
            
            for j = 1:phrasenum
                DEventList(i-j).Props.NPhrases = phrasenum;
            end
            callnum = callnum + 1;
            phrasenum = 1;
            
        end
    end
    DEventList(i).Props.CallNumber = callnum;
    DEventList(i).Props.PhraseNumber = phrasenum;
    
    if i == length(t_start{1})
        for j = 1:phrasenum
            DEventList(i-j+1).Props.NPhrases = phrasenum;
        end
    end
    
    % Calculate F0 and energy
    y = wavread(fullpath, [max(1,round(t_start{1}(i)*Fs)),round(t_stop{1}(i)*Fs)]);
    y_extra = wavread(fullpath, [round(t_stop{1}(i)*Fs)+1,round(t_stop{1}(i)*Fs)+2000]);
    
    y = y-repmat(mean([y;y_extra]),size(y,1),1);
    y_extra = y_extra-repmat(mean([y;y_extra]),size(y_extra,1),1);
    
    y1 = y(:,param.ch_parabolic);
    y2 = y(:,param.ch_ref);
    y1_extra = y_extra(:,param.ch_parabolic);
    y2_extra = y_extra(:,param.ch_ref);
    
    % F0 is a two column matrix, the first column is time, the
    % second column is the F0 of phee, 1ms bins, no smoothing 
    [DEventList(i).Props.F0, DEventList(i).Props.F0_Energy] = GetCallF0_Parabolic([y1,y2],[y1_extra,y2_extra],t_start{1}(i),param);
    
end


delete(hw);


DEventList = DEventList';
savename = strrep([loadname],'CallTime_','CallInfo_');
save(savename,'DEventList');




