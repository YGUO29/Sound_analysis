function TrialDef = TrialManager(elist,choice)
% TrialManager is currently sending output to NeuralBySession.m
% In future, this is going to be a method in the LogSource class.
%     elist: currently is an instance of the ExpDEvent class
%     TrialDef: definition of trials, 
%               a table of reference time and things to display
%                in each trial.
%       == FIELDS ==
%         - RefTime:    reference time point that each trial align to
%         - RefName:    name of the reference event
%         - RefInd:     Index of this in the event list
%         - XAxisObj:   cell array of objects on the x-axis, e.g. call
%                       duration
    
    VarNames = [];
    inds = [];
    for i = 1:length(elist)
        [out1,out2] = elist.GetTimeVar;
        VarNames = [VarNames;out1];
        inds = [inds;out2];
    end

    [VarNames IA] = unique(VarNames,'last');
    VarSize = inds(IA);
    
    
    % Choose one time var and get trial information/data
    
    disp('Choose one from the following:');
    ind_lookup = [];
    Var_loopup = [];
    for i = 1:length(VarNames)
        for j = 1:VarSize(i)
            ind_lookup = [ind_lookup;j];
            Var_loopup = [Var_loopup;VarNames(i)];
            str = sprintf('%5d. %-s(%d)',length(ind_lookup),VarNames{i},j);
            disp(str)

        end
    end
    if isempty(choice)
        ind = input('Choose one as a reference time (use index number):');
    else
        ind = choice;
        choice
    end
    Var = Var_loopup{ind};
    time_array = [];
    
    for i = 1:length(elist)
        % need to work on here: how to retrieve properties buried in
        % structures
        t = get(elist(i),Var);
        t = t.GetTime;
        t = t(ind_lookup(ind));
        RefTime(i) = t;
        RefName{i} = elist(i).Name;
        RefInd(i) = i;
        
        % hard coded for call duration right now
%         TrialDef(i).XAxisObj = elist(i).Time.GetTime;
        
% %         === if in future, group phrases to calls, use the code bolow ===

        if elist(i).Props.PhraseNumber == 1
            time_array = elist(i).Time.GetTime;
            for j = i+1:i+elist(i).Props.NPhrases - 1
                time_array = [time_array;elist(j).Time.GetTime];
            end
        end
        XAxisObj(i).Time = time_array;
        
        
        XAxisObj(i).Nphrases = elist(i).Props.NPhrases;
        XAxisObj(i).F0 = elist(i).Props.F0;
                
        
    end
    RefTime = RefTime';
    RefName = RefName';
    RefInd = RefInd';
    XAxisObj = XAxisObj';
    TrialDef = table(RefTime,RefName,RefInd,XAxisObj);



end

