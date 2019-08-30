% VocComm4_Plot
clc;close all;clear all;

CompareCondition = [2,3,5];

phrase_interval = [];
transition_interval = [];
self_interval = [];
call_rate = [];

for ci = 1:length(CompareCondition)
    
    cond_data = load(['VocComm4_Condition' num2str(CompareCondition(ci))]);
    phrase_interval = [phrase_interval;cond_data.phrase_interval];
    transition_interval = [transition_interval;cond_data.transition_interval];
    self_interval = [self_interval;cond_data.self_interval];
    call_rate(:,ci) = cond_data.rate_call';
    phrase_rate(:,ci) = cond_data.rate_phrase';
    SubjectIDs = cond_data.SubjectIDs;
    CallTypeList = cond_data.CallTypeList;
    N_phrasetype(:,:,ci) = cond_data.N_phrasetype;
    dur_total(ci) = cond_data.dur_total(1);
    
    rate_phrasetype(:,:,ci) = N_phrasetype(:,:,ci)/dur_total(ci)*60;
end



% plot phrase interval distribution

figure(1)
xx = [0:0.02:3];
N_phrase_bin = histc(phrase_interval,xx);
% N_phrase_bin(end+1) = length(phrase_interval) - sum(N_phrase_bin);
bar([xx+(xx(2)-xx(1))/2],N_phrase_bin/sum(N_phrase_bin));
xlim([min(xx),max(xx)])
xlabel('Between-phrase Interval (s)');
ylabel('Proprotion');
title(['All Subjects, [', num2str(min(xx)),',', num2str(max(xx)),'] sec, N = ',num2str(sum(N_phrase_bin))]);

% self interval, with no other subjects in between
figure(2)
xx = [0:0.5:30];
N_self_bin = histc(self_interval,xx);
bar([xx+(xx(2)-xx(1))/2],N_self_bin/sum(N_self_bin));
xlim([min(xx),max(xx)])
xlabel('Call Interval of Single Subjects (s)');
ylabel('Proprotion');
title(['All Subjects, [', num2str(min(xx)),',', num2str(max(xx)),'] sec, N = ',num2str(sum(N_self_bin))]);

% transition interval
figure(3)
xx = [0:0.5:30];
N_trans_bin = histc(transition_interval,xx);
bar([xx+(xx(2)-xx(1))/2],N_trans_bin/sum(N_trans_bin));
xlim([min(xx),max(xx)])
xlabel('Subject Transition Interval (s)');
ylabel('Proprotion');
title(['All Subjects, [', num2str(min(xx)),',', num2str(max(xx)),'] sec, N = ',num2str(sum(N_trans_bin))]);


% call rate
figure(4) 
ha = axes;
bar(call_rate);
set(gca,'xticklabel',SubjectIDs)
ylabel('Call rate (#/min)')
title('Call rate')
legend('Condition 2','Condition 3','Condition 5')

% phrase rate
figure(5) 
ha = axes;
bar(phrase_rate);
set(gca,'xticklabel',SubjectIDs)
ylabel('Call rate (#/min)')
title('Phrase rate')
legend('Condition 2','Condition 3','Condition 5')

% phrase type rate
figure(6)
for k = 1:4
    ha = subplot(4,1,k)
    temp = squeeze(rate_phrasetype(k,:,:));
    bar(temp)
    set(gca,'xticklabel',CallTypeList);
    ylabel('Call rate (#/min)');
    ha.XAxis.TickLabelRotation = 45;
%     title('Phrase rate')
%     legend('Condition 2','Condition 3','Condition 5')
    if k < 4
        set(ha,'XTickLabel',[])
    end
end
