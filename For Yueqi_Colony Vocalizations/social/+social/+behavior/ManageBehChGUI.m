function ManageBehChGUI(Session)
% Display the Manage Behavior Channel GUI

% GLOBAL PARAMETERS
BehChGUI.WinWid = 180;
BehChGUI.WinHgt = 45;
BehChGUI.Units = 'Characters';
BehChGUI.FontSize = 10;

BehChGUI.TxtWid = 20;
BehChGUI.TxtHgt = 1.1;
BehChGUI.EdtWid = BehChGUI.WinWid - BehChGUI.TxtWid - 5;
BehChGUI.EdtHgt = 1.4;
BehChGUI.TabWid = 0.9*BehChGUI.WinWid;
BehChGUI.TabHgt = 0.26*BehChGUI.WinHgt;
BehChGUI.BehChCommonProps = properties('social.interface.Behavior');
BehChGUI.SessionObjectProps = {'Headers' 'Signals' 'Behaviors'};


% if not generated, generate the GUI

    h_temp = findobj('tag','fig_ManageBehCh');
    if ~isempty(h_temp)
        figure(h_temp);
    else
        CreateGUI(BehChGUI,Session);
        
    end
    if ~isempty(Session)
        
        % check if BehChannels property exists (to be compatible with older version)
        has_BehCh = hasBehChannel(Session);
        if ~has_BehCh || isnumeric(Session.Behaviors)
            param = InitBehChParam(Session);
            var_str = 'Session.Behaviors = ';
            eval([var_str 'social.behavior.' param.BehChType{1},'.empty;']);       % hard coded path, need to fix it later
            
        end
        UpdateGUI(Session);
    end
    
    
    

end

function CreateGUI(BehChGUI,Session)

    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    param = InitBehChParam(Session);
    BehChGUI.defaultFontSize = get(0,'DefaultUicontrolFontSize');
    set(0,'DefaultUicontrolFontSize', BehChGUI.FontSize);
    
    h_fig_ManageBehCh = figure(     ...
        'DefaultUicontrolFontSize', BehChGUI.FontSize,...
        'Units'         , BehChGUI.Units);
        

    set(h_fig_ManageBehCh,      ...
        'Units'         , BehChGUI.Units    ,...
        'Position'      , [30 3 BehChGUI.WinWid BehChGUI.WinHgt], ...
        'Tag'           , 'fig_ManageBehCh',...
        'Name'          , ['Manage Behavior Channels (' Session.ID ')'],...
        'NumberTitle'   , 'off',...
        'Resize'        , 'off',...
        'Color'         , defaultBackground,...
        'MenuBar'       , 'none',...
        'CloseRequestFcn',{@CloseBehChWin,BehChGUI},...
        'DefaultUicontrolUnits', BehChGUI.Units);


    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'text',...
        'Position'      , [1 (BehChGUI.WinHgt-2) BehChGUI.TxtWid BehChGUI.TxtHgt],...
        'String'        , 'Session File',...
        'Tag'           , 'txt_sessionfilepath',...
        'Callback'      , '');
    
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'edit',...
        'Position'      , [BehChGUI.TxtWid+2 (BehChGUI.WinHgt-2.1) BehChGUI.EdtWid-10 BehChGUI.EdtHgt],...
        'String'        , '',...
        'BackGroundColor','w',...
        'Tag'           , 'edt_sessionfilepath',...
        'Callback'      , '');
    
    
    % Signal Table
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'text',...
        'Position'      , [45 1+BehChGUI.TabHgt BehChGUI.TxtWid BehChGUI.TxtHgt],...
        'String'        , 'Signals',...
        'Tag'           , 'txt_signal_list',...
        'HorizontalAlignment','Left',...
        'FontWeight'    , 'Bold',...
        'Callback'      , '');
    
    h_temp = uitable(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Units'         , BehChGUI.Units,...
        'Position'      , [45 1 BehChGUI.WinWid-47 BehChGUI.TabHgt],...
        'ColumnName'    , {'SessionID','Name','Channel','MicType','SampleRate','File'},...
        'ColumnWidth'   , {'auto','auto','auto','auto','auto','auto'},...
        'FontSize'      , BehChGUI.FontSize,...
        'CellSelectionCallback' ,@SignalTable_Select,...
        'Tag'           , 'tbl_signal');
    
    % Need to read table width in pixels and re-calculate column width
    
    set(h_temp,'Units','Pixels');
    t_pos = get(h_temp,'Position');
    t_wid = t_pos(3);
    set(h_temp,'Units',BehChGUI.Units);
    set(h_temp,'ColumnWidth',{t_wid*0.2,t_wid*0.1,t_wid*0.08,t_wid*0.1,t_wid*0.08,t_wid*0.4});
    
    % Behavior Channel Additional Properties Table
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'text',...
        'Position'      , [45 (2+2.*BehChGUI.TabHgt+BehChGUI.TxtHgt) BehChGUI.TxtWid BehChGUI.TxtHgt],...
        'String'        , 'Behavior Channel - Additional Properties',...
        'Tag'           , 'txt_behavior_channel_list',...
        'HorizontalAlignment','Left',...
        'FontWeight'    , 'Bold',...
        'Callback'      , '');
    
    h_temp = uitable(           ...
        'Parent'        , h_fig_ManageBehCh,   ... 
        'Units'         , BehChGUI.Units,...
        'FontSize'      , BehChGUI.FontSize,...
        'ColumnName'    , {'Value'},...
        'Columneditable', true,...
        'Position'      , [45 (2+BehChGUI.TabHgt+BehChGUI.TxtHgt)  BehChGUI.WinWid-47 BehChGUI.TabHgt],...
        'Tag'           , 'tbl_beh_ch_property',...
        'CellEditCallback', {@EditBehChannels,Session});

    
    % Behavior Channel Table
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'text',...
        'Position'      , [45 (3+3.*BehChGUI.TabHgt+2.*BehChGUI.TxtHgt)  BehChGUI.WinWid-47 BehChGUI.TxtHgt],...
        'String'        , 'Behavior Channels',...
        'Tag'           , 'txt_behavior_channel_list',...
        'HorizontalAlignment','Left',...
        'FontWeight'    , 'Bold',...
        'Callback'      , '');
    
    table_column = setdiff(BehChGUI.BehChCommonProps,{'Session' 'Events'})';
    wid_str = {'auto'};
    format_str = {param.BehChType};
    
    for i = 1:length(table_column)
        wid_str = [wid_str,'auto'];
        if strfind(table_column{i},'Sig')
            format_str = [format_str,{param.SignalList}];
        elseif strfind(table_column{i},'Is')
            format_str = [format_str,{'numeric'}];
        end
    end
    h_temp = uitable(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Units'         , BehChGUI.Units,...
        'Position'      , [45 (3+2.*BehChGUI.TabHgt+2.*BehChGUI.TxtHgt)  BehChGUI.WinWid-47 BehChGUI.TabHgt],...
        'ColumnName'    , ['Type',table_column],...        % need to automatically go with class properties
        'ColumnWidth'   , wid_str,...
        'ColumnFormat'  , format_str,...
        'Columneditable', [true,true,true,true,true],...
        'FontSize'      , BehChGUI.FontSize,...
        'CellSelectionCallback' ,{@BehChannelTable_Select,Session},...
        'CellEditCallback', {@EditBehChannels,Session},...
        'Tag'           , 'tbl_behavior_channel');
    
    % re-set column width
    set(h_temp,'Units','Pixels');
    t_pos = get(h_temp,'Position');
    t_wid = t_pos(3);
    set(h_temp,'Units',BehChGUI.Units);
    wid_str = {t_wid*0.35};
    for i = 1:length(table_column)
        wid_str = [wid_str,{t_wid*0.14}];
    end
    set(h_temp,'ColumnWidth',wid_str);
    
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'pushbutton',...
        'Position'      , [BehChGUI.WinWid-16 (3+2.5.*BehChGUI.TabHgt+2.*BehChGUI.TxtHgt) 10 BehChGUI.TabHgt/2-1],...
        'String'        , '+',...
        'FontWeight'    , 'bold',...
        'Tag'           , 'btn_add_behavior_channel',...
        'Callback'      , {@AddBehChannel,Session,param});
    
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'pushbutton',...
        'Position'      , [BehChGUI.WinWid-16 (3+2.*BehChGUI.TabHgt+2.*BehChGUI.TxtHgt) 10 BehChGUI.TabHgt/2-1],...
        'String'        , '-',...
        'FontWeight'    , 'bold',...
        'Tag'           , 'btn_remove_behavior_channel',...
        'Callback'      , {@RemoveBehChannel,Session});
    
    
    % SESSION TABLE
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'text',...
        'Position'      , [3 (3+3.*BehChGUI.TabHgt+2.*BehChGUI.TxtHgt) 30 BehChGUI.TxtHgt],...
        'String'        , 'Session Properties',...
        'Tag'           , 'txt_session',...
        'HorizontalAlignment','Left',...
        'FontWeight'    , 'Bold',...
        'Callback'      , '');
    
    h_temp = uitable(           ...
        'Parent'        , h_fig_ManageBehCh,   ... 
        'Units'         , BehChGUI.Units,...
        'FontSize'      , BehChGUI.FontSize,...
        'ColumnName'    , {'Value'},...
        'Columneditable', true,...
        'Position'      , [3  1 40 (3+3.*BehChGUI.TabHgt+1.*BehChGUI.TxtHgt)],...
        'Tag'           , 'tbl_session',...
        'CellEditCallback', {@EditSession,Session});


    
    

end


function UpdateGUI(Session)
    ht = findobj('tag','edt_sessionfilepath');
    set(ht,'String',Session.Headers(1).File);
    
    % Update Signals
    tabledata = [];
    if ~isempty(Session.Signals)
        for i = 1:length(Session.Signals)
            tabledata{i,1} = Session.Signals(i).Session.ID;
            tabledata{i,2} = Session.Signals(i).ID;
            tabledata{i,3} = Session.Signals(i).Channel;
            tabledata{i,4} = char(Session.Signals(i).Mic);
            tabledata{i,5} = Session.Signals(i).SampleRate;
            tabledata{i,6} = Session.Signals(i).File;
        end
    end
    
    ht = findobj('tag','tbl_signal');
    set(ht,'Data',tabledata);
    
    % Update Behavior Channels
    UpdateSessionTable(Session);
    UpdateBehChTable(Session,0);
end

function UpdateSessionTable(Session)
    SessionObjectProps = {'Headers' 'Signals' 'Behaviors'};
    ht=findobj('tag','tbl_session')
    col_field=properties(Session);
    tabledata=cell(length(col_field),1);

    ht.ColumnName='Value';
    ht.RowName = col_field;
    ht.ColumnWidth={145};
    %Default all columns to editable
%     ht.ColumnEditable=true(1,length(col_field));
    
    for i=1:length(col_field)
        if ismember(col_field{i},SessionObjectProps)
            tabledata{i,1}=length(Session.(col_field{i}));
        else
            tabledata{i,1}=Session.(col_field{i});
        end
    end
    ht.Data=tabledata;
end

function UpdateBehChTable(Session,ind_sel)

    % update the common property table
    if ~isempty(Session.Behaviors)
        tabledata = [];
        ht = findobj('tag','tbl_behavior_channel');
        col_field = get(ht,'ColumnName');
        for i = 1:length(Session.Behaviors)
            BehCh_type = class(Session.Behaviors(i));
            ind = strfind(BehCh_type,'.');
            BehCh_type(1:ind(end)) = ''; 
            tabledata{i,1} = BehCh_type;
 
            for j = 2:length(col_field)
                tabledata{i,j} = Session.Behaviors(i).(col_field{j});
            end
        end
    

        ht = findobj('tag','tbl_behavior_channel');
        set(ht,'Data',tabledata);
        ind_old = get(ht,'UserData');
        if isempty(ind_old)
            set(ht,'UserData',[ind_sel 0]);
        end

    % update the additional property table
        tabledata = [];
        ht = findobj('tag','tbl_beh_ch_property');
        if ind_sel ~=0
            props = properties(Session.Behaviors(ind_sel));
            additional_props = setdiff(props,[col_field(2:end); {'Session'}; {'Events'}],'stable');
            col_field = additional_props;
            
            set(ht,'RowName',Session.Behaviors(ind_sel).ID)
            set(ht,'ColumnName',col_field)
            
            for i = 1:length(col_field)
                if length(col_field{i})>=3&&strcmp(col_field{i}(1:3),'Sig')
                    tabledata{1,i} = Session.Behaviors(ind_sel).(col_field{i}).ID;
                    columnformat{i}= {Session.Signals.ID};
                elseif ischar(Session.Behaviors(ind_sel).(col_field{i}));
                    tabledata{1,i} = Session.Behaviors(ind_sel).(col_field{i});
                    columnformat{i}='char';
                elseif isnumeric(Session.Behaviors(ind_sel).(col_field{i}));
                    tabledata{1,i} = Session.Behaviors(ind_sel).(col_field{i});
                    columnformat{i}='numeric';
                elseif islogical(Session.Behaviors(ind_sel).(col_field{i}));
                    tabledata{1,i} = Session.Behaviors(ind_sel).(col_field{i});
                    columnformat{i}='logical';
                end
            end
            set(ht,'Data',tabledata);
            ht.ColumnFormat=columnformat;
        else
            set(ht,'RowName','');
            set(ht,'Data',[]);
        end
        
    else
        ht = findobj('tag','tbl_behavior_channel');
        set(ht,'Data',[]);
        ht = findobj('tag','tbl_beh_ch_property');
        set(ht,'Data',[]);
        set(ht,'RowName','');
    end
end

function param = InitBehChParam(Session)
    % Get parameters needed to build the Behavior Channel Table
    param.N_signal = length(Session.Signals);
    current_name = mfilename;
    current_fullpath = mfilename('fullpath');
    current_path = current_fullpath(1:end-length(current_name));
    fid = fopen([current_path 'BehaviorChannelTypeList.txt']);
    temp_list = textscan(fid,'%s');
    param.BehChType = temp_list{1}';
    fclose(fid);
    
    % Read signals
    param.SignalList = {'NaN' Session.Signals.ID};
end

function AddBehChannel(obj,event,Session,param)
    if length(Session.Signals)>1
        sig1=Session.Signals(1);
        sig2=Session.Signals(2);
    elseif ~isempty(Session.Signals)
        sig1=Session.Signals(1);
        sig2=sig1;
    else
        sig1=[];
        sig2=[];
    end
        
    temp = social.behavior.(param.BehChType{1})(Session,'Unknown',sig1,sig2,sig1,false);
        
    if isempty(Session.Behaviors)
        Session.Behaviors = temp;
    else
        Session.Behaviors(end+1) = temp;
    end
    UpdateBehChTable(Session,0);
end

function has_BehCh = hasBehChannel(Session)
    
    has_BehCh = isprop(Session,'Behaviors');
    
%     props = properties(Session);
%     has_BehCh = 0;
%     for i = 1:length(props)
%         if strcmp(props{i},'BehChannels')
%             has_BehCh = 1;
%             break
%         end
%     end
end

function SignalTable_Select(obj,event)
    set(obj,'UserData',event.Indices);
end

function BehChannelTable_Select(obj,event,Session)
    set(obj,'UserData',event.Indices);
    if ~isempty(event.Indices)
        UpdateBehChTable(Session,event.Indices(1));
    else
        UpdateBehChTable(Session,0);
    end
end

function EditBehChannels(obj,event,Session)
    % if change type, do something
    if strcmp(event.Source.Tag,'tbl_behavior_channel')
        ch_ind=event.Indices(1);
        if event.Indices(2) == 1
            if ~strcmp(event.NewData,event.PreviousData)
                Session.Behaviors(ch_ind) = social.behavior.(event.NewData);
                UpdateBehChTable(Session,ch_ind);
            end
        end
    elseif strcmp(event.Source.Tag,'tbl_beh_ch_property')
%         if strcmp(col_field{i}(1:3),'Sig')
        ht = findobj('tag','tbl_behavior_channel');
        ch_ind = ht.UserData(1);

    end
    % then save data no matter what
    SaveBehChannels(obj,ch_ind,event,Session)
end

function EditSession(obj,event,Session)
    SessionObjectProps = {'Headers' 'Signals' 'Behaviors'};
    row_ind=event.Indices(1);
    propname=obj.RowName{row_ind};
    if ismember(propname,SessionObjectProps)
        obj.Data{row_ind}=event.PreviousData;
    else
        % Data type of new must match data type of old, otherwise don't
        % update.
%         if strcmp(class(event.NewData),class(event.PreviousData))
            Session.(propname)=event.NewData;
%         else
%             Session.(propname)=event.PreviousData;
%         end
    end
end

function SaveBehChannels(obj,ind_ch,event,Session)
    % grab all data in the behavior channel table
    ht = findobj('tag','tbl_behavior_channel');
    tabledata = get(ht,'Data');
%     ind = event.Indices;
%     newData = event.NewData;
    col_field = get(ht,'ColumnName');
    
    for i = 1:size(tabledata,1)
        for j = 2:length(col_field)
            Session.Behaviors(i).(col_field{j})= tabledata{i,j};
        end
    end
    
    % grab all data in the behavior property
    ht = findobj('tag','tbl_beh_ch_property');
    tabledata = get(ht,'Data');
    col_field = get(ht,'ColumnName');

    for i = 1:size(tabledata,2)
        if length(col_field{i})>=3&&strcmp(col_field{i}(1:3),'Sig')
            Session.Behaviors(ind_ch).(col_field{i}) = Session.GetSignals('ID',tabledata{i});
        else
            Session.Behaviors(ind_ch).(col_field{i}) = tabledata{i};
        end
    end
end

function RemoveBehChannel(obj,event,Session)
    ht = findobj('tag','tbl_behavior_channel');    
    ind = get(ht,'UserData');
    ind_ch = ind(1);
    if ind_ch > 0
        Session.Behaviors(ind_ch) = [];

        UpdateBehChTable(Session,0);
    end
end

function CloseBehChWin(obj,event,BehChGUI)
    % save changes

    % kill window
    ht = findobj('tag','fig_ManageBehCh');
    delete(ht);

    set(0,'DefaultUicontrolFontSize', BehChGUI.defaultFontSize);

end