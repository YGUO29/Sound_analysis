function [varargout] = VirtualCall_savefile(calltype,g_stimulus_matrix)

A = g_stimulus_matrix{1, 1};
B = A(:,2);

calltype = 'Ph2TrphFMD';
% name = {'p025','p075','p125','p175','p225','p275','p325','p375','p425','p475'...
%     ,'p525','p575','p625','p675','p725','p775','p825','p875','p925','p975','p1025','p1075'...
%     ,'p1125','p1175','p1225','p1275','p1325','p1375'};
%name = {'000','n05','n10','n15','n20','n25','n30','n35','n40','n45','n50'};

for i=1:size(B,1)
    data = B{i, 1}{1,2};
    data = data/12;
    %save(['Twitter' num2str(i)], 'data');
    
    audiowrite([calltype num2str(name(i)) '.wav'],data,97656)
    %audiowrite([calltype name{i} '.wav'],data,97656)
    
    clear data;
end