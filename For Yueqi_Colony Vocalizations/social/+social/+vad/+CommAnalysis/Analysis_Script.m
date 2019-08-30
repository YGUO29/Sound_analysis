num_condition = 4;
num_monkey = 4;
over_call_rate = zeros(4,4);
bytype_call_rate = cell(1,4);
ind_condition = [5,6,7,8];
for i_con = 1 : length(ind_condition)
    condition = ind_condition(i_con);
    run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
    over_call_rate(:,i_con) = rate_call;
    for it = 1 : length(CallTypeList)
        bytype_call_rate{it}(:,i_con) = rate_calltype(:,it);
    end
end
hf = figure;
bar(over_call_rate);
set(gca,'XTickLabel',{'M91C(female)','M92C(male)','M64A(female)','M29A(male)'})
ylabel('call rate (/min)');
legend({'before male merge','after male merge','before female merge','after female merge'},'Location','NorthWest')
saveas(hf,['C:\Users\xh071_000\OneDrive\study\marmoset\','overall_call_rate'],'fig'); 
saveas(hf,['C:\Users\xh071_000\OneDrive\study\marmoset\','overall_call_rate'],'png'); 

for it = 1 : length(CallTypeList)
    hf = figure;
    bar(bytype_call_rate{it});
    set(gca,'XTickLabel',{'M91C(female)','M92C(male)','M64A(female)','M29A(male)'})
    ylabel('call rate (/min)');
    legend({'before male merge','after male merge','before female merge','after female merge'},'Location','NorthWest');
    if it == 1
        legend({'before male merge','after male merge','before female merge','after female merge'},'Location','North');
    end
    if it == 4
        set(gca,'YLim',[0,0.32]);
    end
    title(CallTypeList{it});
    saveas(hf,['C:\Users\xh071_000\OneDrive\study\marmoset\',CallTypeList{it},'_call_rate'],'fig'); 
    saveas(hf,['C:\Users\xh071_000\OneDrive\study\marmoset\',CallTypeList{it},'_call_rate'],'png'); 
end

%%
num_condition = 4;
num_monkey = 4;
over_call_rate = zeros(4,4);
bytype_call_rate = cell(1,4);
ind_condition = [5,6,7,8];
hf = figure;
for i_con = 1 : length(ind_condition)
    condition = ind_condition(i_con);
    run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
end
saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\PSTH','fig');
saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\PSTH','png');

%%
% set: win = 3; spon_win = [-10,-7];
resp = cell(1,4);
CalltypeSwitch = 0;
targetCalltype = 3;
% hf = figure;
hf = gcf;
condition = 5;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{2}(:,1) = ratio_resp(:,2);
resp{4}(:,1) = ratio_resp(:,4);
condition = 6;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{2}(:,2) = ratio_resp(:,2);
resp{4}(:,2) = ratio_resp(:,4);

subplot(1,2,1)
bar(resp{2});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.7,0.2])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before male merge','after male merge'},'Location','SouthEast')
title('(A)M92C');

subplot(1,2,2);
bar(resp{4});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.3,0.2])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before male merge','after male merge'},'Location','SouthEast')
title('(B)M29A');

saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Male_Merge_3s','fig');
saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Male_Merge_3s','png');
%%
condition = 7;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{1}(:,1) = ratio_resp(:,1);
resp{3}(:,1) = ratio_resp(:,3);
condition = 8;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{1}(:,2) = ratio_resp(:,1);
resp{3}(:,2) = ratio_resp(:,3);

subplot(1,2,1)
bar(resp{1});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.2,0.3])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before female merge','after female merge'},'Location','NorthWest')
title('(C)M91C');

subplot(1,2,2);
bar(resp{3});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.3,0.2])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before female merge','after female merge'},'Location','NorthEast')
title('(D)M64A');

saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Female_Merge_3s_Trill','fig');
saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Female_Merge_3s_Trill','png');

%%
% set: win = 6; spon_win = [-12,-6];
resp = cell(1,4);
hf = gcf;
condition = 5;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{2}(:,1) = ratio_resp(:,2);
resp{4}(:,1) = ratio_resp(:,4);
condition = 6;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{2}(:,2) = ratio_resp(:,2);
resp{4}(:,2) = ratio_resp(:,4);

subplot(1,2,1)
bar(resp{2});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.2,0.2])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before male merge','after male merge'},'Location','NorthEast')
title('(A)M92C');

subplot(1,2,2);
bar(resp{4});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.2,0.2])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before male merge','after male merge'},'Location','NorthEast')
title('(B)M29A');

saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Male_Merge_6s','fig');
saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Male_Merge_6s','png');
%%
condition = 7;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{1}(:,1) = ratio_resp(:,1);
resp{3}(:,1) = ratio_resp(:,3);
condition = 8;
run('social.vad.CommAnalysis.TransMatrix_4monkey.m');
resp{1}(:,2) = ratio_resp(:,1);
resp{3}(:,2) = ratio_resp(:,3);

subplot(1,2,1)
bar(resp{1});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.2,0.2])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before female merge','after female merge'},'Location','NorthEast')
title('(C)M91C');

subplot(1,2,2);
bar(resp{3});
set(gca,'XTickLabel',{'M91C','M92C','M64A','M29A'})
set(gca,'YLim',[-0.2,0.2])
set(gca,'YTickLabelRotation',90);
ylabel('CMI');
legend({'before female merge','after female merge'},'Location','NorthEast')
title('(D)M64A');

saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Female_Merge_6s','fig');
saveas(hf,'C:\Users\xh071_000\OneDrive\study\marmoset\Female_Merge_6s','png');