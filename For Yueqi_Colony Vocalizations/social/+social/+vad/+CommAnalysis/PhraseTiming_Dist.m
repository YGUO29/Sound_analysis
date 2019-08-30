function PhraseTiming_Dist(filepath, file_list,param)

% read in a cell array of session names

% *** It normalize differently from the initial analysis. In this version,
% N is the total phrase intervals, not the ones within the plot window.
% Proportion is calculated by dividing this N.

%  for Inter phrase interval
%  *** currently it does not care about whether there are other animal's calls
% in between phrases.

% Plot overall inter-phrase intervals distributions: 
%   (1) onset-onset; (2) offset-onset
% break down into call types, plot a matrix of same to same, same to other
% intervals
%   (1) onset-onset; (2) offset-onset

    calltypes = param.calltypes;
    subject_ID = param.subject_ID;
    dur_range = param.dur_range; % to select a subset of calls for plotting IPI


    bin_edges = [0:0.02:3];
    bin_edges_log = [-2:0.025:1];
    N_types = length(calltypes.CallTypeList);

    IPI_On2On = [];
    IPI_Off2On = [];
    IPI_Subset = [];
    Duration = [];
    IPI_type_On2On = cell(N_types);
    IPI_type_Off2On = cell(N_types);
    Duration_type = cell(N_types,1);
    
    
    for fi = 1:length(file_list)
        filepath_full = fullfile(filepath,file_list{fi});
        var_load = load(filepath_full);
        var_name = fieldnames(var_load);
        ses_data = var_load.(var_name{1});
        
%         for ai = 1:length(ses_data.Behaviors)
%             if strcmp(ses_data.Behaviors(ai).Subjects,subject_ID)
                
                phrases = ses_data.sort_events(ses_data.GetEvents('Subjects',subject_ID));
                
                for ci = 1:length(phrases)-1
                    phrase_cur = phrases(ci);
                    phrase_next = phrases(ci+1);
                    IPI_On2On = [IPI_On2On;phrase_next.eventStartTime - phrase_cur.eventStartTime]; 
                    IPI_Off2On = [IPI_Off2On;phrase_next.eventStartTime - phrase_cur.eventStopTime];
                       
                    if min(IPI_Off2On) < 0
                        aa = 1;
                    end
                    
                    dur = phrase_cur.eventStopTime - phrase_cur.eventStartTime;
                    Duration = [Duration;dur];
                    
                    if dur <= dur_range(2) & dur >= dur_range(1)
                        IPI_Subset = [IPI_Subset;phrase_next.eventStartTime - phrase_cur.eventStopTime];
                    end
                    
                    for ti = 1:N_types
                        ind1(ti) = sum(strcmp(phrase_cur.eventPhraseType,calltypes.CallSubType{ti}));
                        ind2(ti) = sum(strcmp(phrase_next.eventPhraseType,calltypes.CallSubType{ti}));
                    end
                    
                    ind1 = find(ind1>0);
                    ind2 = find(ind2>0);
                    
                    % format changed from the very intial matrix style
                    % each row is an initiator/current phrase
                    % each column is a responder/next phrase
                    if ~isempty(ind1) && ~isempty(ind2) 
                   
                        IPI_type_On2On{ind1,ind2} = [IPI_type_On2On{ind1,ind2};phrase_next.eventStartTime - phrase_cur.eventStartTime]; 
                        IPI_type_Off2On{ind1,ind2} = [IPI_type_Off2On{ind1,ind2};phrase_next.eventStartTime - phrase_cur.eventStopTime]; 
                    end
                    
                    if ~isempty(ind1)
                        Duration_type{ind1} = [Duration_type{ind1}; phrase_cur.eventStopTime - phrase_cur.eventStartTime];
                    end
                    
                end
                
                Duration = [Duration;phrase_next.eventStopTime - phrase_next.eventStartTime];
                if ~isempty(ind2)
                    Duration_type{ind2} = [Duration_type{ind2}; phrase_next.eventStopTime - phrase_next.eventStartTime];
                end
                
                
%             end
%         end
            
        

    end

    
    % Calculate distribution here
    IPI_Dist_On2On = histcounts(IPI_On2On,bin_edges)/length(IPI_On2On);
    IPI_Dist_Off2On = histcounts(IPI_Off2On,bin_edges)/length(IPI_Off2On);
    Duration_Dist = histcounts(Duration,bin_edges)/length(Duration);
    IPI_Subset_Dist = histcounts(IPI_Subset,bin_edges)/length(IPI_Subset);
    
    
    
    % Do log-x axis for offset-onset distribution
    IPI_Off2On_log = log10(IPI_Off2On);
    IPI_Dist_Off2On_log = histcounts(IPI_Off2On_log,bin_edges_log)/length(IPI_Off2On_log);

    % Fit bimodal Gaussian to offset-onset phrase interval
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    xx = bin_edges_log(1:end-1) + diff(bin_edges_log(1:2))/2;
    [fitresult, gof] = fit( xx', IPI_Dist_Off2On_log', 'gauss2', opts );
    
    % need to use mle to fit a mixture of two student's t distribution
    
%     y = tpdf((x-mu)/sigma,nu)
    
    % Plot distributions
    h = figure;
    subplot(3,1,1)
    bar(bin_edges(1:end-1)+diff(bin_edges(1:2))/2,IPI_Dist_On2On,'EdgeColor','None');
    xlim([min(bin_edges),min(max(bin_edges),max(IPI_On2On))])
    xlabel('Inter-phrase Interval (s)');
    ylabel('Proprotion');
    set(gca,'yscale','log');
    title(['Inter-phrase Interval (Onset to onset), ' 10  subject_ID ', N = ',num2str(length(IPI_On2On))],'FontWeight','Normal');

    subplot(3,1,2)
    bar(bin_edges(1:end-1)+diff(bin_edges(1:2))/2,IPI_Dist_Off2On,'EdgeColor','None');
    xlim([min(bin_edges),min(max(bin_edges),max(IPI_Off2On))])
    xlabel('Inter-phrase Interval (s)');
    ylabel('Proprotion');
    set(gca,'yscale','log');
    title(['Inter-phrase Interval (Offset to onset), ' 10 subject_ID ', N = ',num2str(length(IPI_Off2On))],'FontWeight','Normal');
    hold on;
    
    subplot(3,1,3)
    bar(bin_edges_log(1:end-1)+diff(bin_edges_log(1:2))/2,IPI_Dist_Off2On_log,'EdgeColor','None');
    xlim([min(bin_edges_log),min(max(bin_edges_log),max(IPI_Off2On_log))])
    
%     set(gca,'yscale','log');
    title(['Inter-phrase Interval (Offset to onset), ' 10 subject_ID ', N = ',num2str(length(IPI_Off2On_log))],'FontWeight','Normal');
    hold on;
    
    % plot fitted distribution
    plot(fitresult);
    xlabel('Inter-phrase Interval (s)');
    ylabel('Proprotion');
    set(gca,'xtick',[-2:1],'xticklabel',10.^[-2:1]);
    
    h = figure;
    subplot(2,1,1)
    bar(bin_edges(1:end-1)+diff(bin_edges(1:2))/2,Duration_Dist,'EdgeColor','None');
    xlim([min(bin_edges),min(max(bin_edges),max(Duration))])
    xlabel('Phrase Length (s)');
    ylabel('Proprotion');
%     set(gca,'yscale','log');
    title(['Phrase Length' 10  subject_ID ', [', num2str(min(bin_edges)),',', num2str(max(bin_edges)),'] sec, N = ',num2str(length(Duration))],'FontWeight','Normal');

    subplot(2,1,2)
    bar(bin_edges(1:end-1)+diff(bin_edges(1:2))/2,IPI_Subset_Dist,'EdgeColor','None');
    xlim([min(bin_edges),min(max(bin_edges),max(IPI_Subset))])
    xlabel('Inter-phrase Interval (s)');
    ylabel('Proprotion');
%     set(gca,'yscale','log');
%     title(['Inter-phrase Interval (Offset to onset, phrase duration [',num2str(dur_range(1)),',',num2str(dur_range(2), ']sec)',10,  'Subjects ',subject_ID,', [', num2str(min(bin_edges)), ',' , num2str(max(bin_edges)), '] sec, N = ',num2str(length(Duration))], 'FontWeight','Normal');
    title(sprintf('Inter-phrase Interval (Offset to onset, phrase duration [%g,%g] sec)\r\n %s, N = %d',dur_range(1), dur_range(2), subject_ID, length(IPI_Subset)),'FontWeight','Normal')
    
    h = figure;
    for i = 1:N_types
        Duration_type_Dist = histcounts(Duration_type{i},bin_edges)/length(Duration_type{i});
        subplot(1,N_types,i)
        bar(bin_edges(1:end-1)+diff(bin_edges(1:2))/2,Duration_type_Dist,'EdgeColor','None');
        
        if isempty(Duration_type{i})
            xlim([min(bin_edges),max(bin_edges)])
        else
            xlim([min(bin_edges),min(max(bin_edges),max(Duration_type{i}))])
        end
        title([calltypes.CallTypeList{i} ],'FontWeight','Normal')
        xlabel('Phrase Length (s)');
        ylabel('Proprotion');
%         set(gca,'yscale','log');
        
        xx_range = get(gca,'XLim');
        yy_range = get(gca,'YLim');
        text(xx_range(2)*0.7,yy_range(2)*0.9,['N=',num2str(length(Duration_type{i}))])
    end
    
    
    for i = 1:N_types
        for j = 1:N_types

            % using log scale on x-axis
            IPI_type_On2On{i,j} = log10(IPI_type_On2On{i,j});
            IPI_type_Off2On{i,j} = log10(IPI_type_Off2On{i,j});
            IPI_Dist_type_On2On{i,j} = histcounts(IPI_type_On2On{i,j},bin_edges_log)/length(IPI_type_On2On{i,j});
            IPI_Dist_type_Off2On{i,j} = histcounts(IPI_type_Off2On{i,j},bin_edges_log)/length(IPI_type_Off2On{i,j});
        end
    end
    
    h1 = figure;
    
    for i = 1:N_types
        for j = 1:N_types
            subplot(N_types,N_types,(i-1)*N_types + j)
            bar(bin_edges_log(1:end-1)+diff(bin_edges_log(1:2))/2,IPI_Dist_type_On2On{i,j},'EdgeColor','None');
            
%             if isempty(IPI_type_On2On{i,j}) || max(IPI_type_On2On{i,j})==0
%                 xlim([min(bin_edges),max(bin_edges)])
%             else
%                 xlim([min(bin_edges),min(max(bin_edges),max(IPI_type_On2On{i,j}))])
%             end
            xlim([min(bin_edges_log),max(bin_edges_log)])
            ylim([0 max(max(IPI_Dist_type_On2On{i,j}*1.2),1e-40)]);
            set(gca,'xtick',[-2:1],'xticklabel',10.^[-2:1]);
            xx_range = get(gca,'XLim');
            yy_range = get(gca,'YLim');
            text(xx_range(2)-1.5,yy_range(2)*0.9,['N=',num2str(length(IPI_type_On2On{i,j}))])
            
            
            if i == 1
                title([10 calltypes.CallTypeList{j}],'FontWeight','Normal');
            end
            if j == 1
                ylabel([calltypes.CallTypeList{i} 10]);
            end
            if i == N_types && j == 1
                xlabel('IPI (s)');
                ylabel([calltypes.CallTypeList{i} 10 'Proportion'])
            end
            if i == 1 && j == round((N_types-1)/2)   
                title(['Inter-phrase Interval (Onset to onset), ' subject_ID 10 calltypes.CallTypeList{j}],'FontWeight','Normal');
            end
%             set(gca,'yscale','log');
            
        end
    end
    
    h2 = figure;        
    for i = 1:N_types
        for j = 1:N_types       
            
            subplot(N_types,N_types,(i-1)*N_types + j)
            bar(bin_edges_log(1:end-1)+diff(bin_edges_log(1:2))/2,IPI_Dist_type_Off2On{i,j},'EdgeColor','None');
%             if isempty(IPI_type_Off2On{i,j}) || max(IPI_type_Off2On{i,j})==0
%                 xlim([min(bin_edges),max(bin_edges)])
%             else
%                 xlim([min(bin_edges),min(max(bin_edges),max(IPI_type_Off2On{i,j}))])
%             end
            xlim([min(bin_edges_log),max(bin_edges_log)])
            ylim([0 max(max(IPI_Dist_type_Off2On{i,j}*1.2),1e-40)]);
            xx_range = get(gca,'XLim');
            yy_range = get(gca,'YLim');
            set(gca,'xtick',[-2:1],'xticklabel',10.^[-2:1]);
            text(xx_range(2)-1.5,yy_range(2)*0.9,['N=',num2str(length(IPI_type_Off2On{i,j}))])
            
            if i == 1
                title([10 calltypes.CallTypeList{j}],'FontWeight','Normal');
            end
            if j == 1
                ylabel([calltypes.CallTypeList{i} 10]);
            end
            if i == N_types && j == 1
                xlabel('IPI (s)');
                ylabel([calltypes.CallTypeList{i} 10 'Proportion'])
            end
            if i == 1 && j == round((N_types-1)/2)   
                title(['Inter-phrase Interval (Offset to onset), ' subject_ID 10 calltypes.CallTypeList{j}],'FontWeight','Normal');
            end
%             set(gca,'yscale','log');
        end
    end
    
    
end