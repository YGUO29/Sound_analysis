% VocComm4_Config
% configure file for vocal communication between 4 monkeys

function out = VocComm4_Config(condition)

    param = social.vad.tools.Param();
    xlsxFilename = fullfile(param.soundFilePath,'M91C_M92C_M64A_M29A.xlsx');
    [~,~,xlsxsheet] = xlsread(xlsxFilename,'A4:K123');
    
    ind_file = find(cell2mat(xlsxsheet(:,3)) == condition);
    file_num = xlsxsheet(ind_file,4);
    file_list = cell(length(file_num),1);
    for i = 1 : length(file_num)
        file_list{i} = ['SelectionTable_voc_M91C_M92C_M64A_M29A_S',num2str(file_num{i}),'.txt'];
    end
    switch condition
        case 1
        
        case 2
            SubjectCh = [5,6,4,3];
        case 3
            SubjectCh = [1,3,2,4];
        case 4
            SubjectCh = [1,3,2,4];
        case 5
            SubjectCh = [1,3,2,4];
        case 6
            SubjectCh = [1,5,2,6];
        case 7
            SubjectCh = [1,3,2,3];
        case 8
            SubjectCh = [4,2,5,2];
    end
    
    
%     switch condition
%         case 1
%             
%         case 2
%             file_list = {'SelectionTable_voc_M91C_M92C_M64A_M29A_S10.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S11.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S14.txt'};
%             
%             SubjectCh = [5,6,4,3];     % according to the order M91C_M92C_M64A_M29A
%             
%         case 3
%             file_list = {'SelectionTable_voc_M91C_M92C_M64A_M29A_S28.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S30.txt'};
%                      
%             SubjectCh = [1,3,2,4];     % according to the order M91C_M92C_M64A_M29A
%         case 4
%             file_list = {'SelectionTable_voc_M91C_M92C_M64A_M29A_S68.txt'};
%             
%             SubjectCh = [1,3,2,4];     % according to the order M91C_M92C_M64A_M29A
%         case 5
%             file_list = {'SelectionTable_voc_M91C_M92C_M64A_M29A_S125.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S126.txt'};
%             SubjectCh = [1,3,2,4];     % according to the order M91C_M92C_M64A_M29A
%         case 7
%             file_list = {...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S189.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S190.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S193.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S194.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S198.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S200.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S201.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S203.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S204.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S205.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S207.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S208.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S210.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S211.txt',...
%                          'SelectionTable_voc_M91C_M92C_M64A_M29A_S213.txt'...
%                          };
%              SubjectCh = [4,2,5,2];
%     end
    
    out.file_list = file_list;
    out.SubjectCh = SubjectCh;
    

end