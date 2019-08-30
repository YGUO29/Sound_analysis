function ManageBehChGUI(Session)
% Display the Manage Behavior Channel GUI

% GLOBAL PARAMETERS
BehChGUI.WinWid = 150;
BehChGUI.WinHgt = 30;
BehChGUI.Units = 'Characters';
BehChGUI.FontSize = 10;

BehChGUI.TxtWid = 20;
BehChGUI.TxtHgt = 1.1;
BehChGUI.EdtWid = BehChGUI.WinWid - BehChGUI.TxtWid - 5;
BehChGUI.EdtHgt = 1.4;
BehChGUI.BehChCommonProps = properties('social.interface.BehaviorChannel');


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
        if ~has_BehCh || isnumeric(Session.BehChannels)
            param = InitBehChParam(Session);
            var_str = 'Session.BehChannels = ';
            eval([var_str 'social.channel.' param.BehChType{1},'.empty;']);       % hard coded path, need to fix it later
            
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
        'Position'      , [30 10 BehChGUI.WinWid BehChGUI.WinHgt], ...
        'Tag'           , 'fig_ManageBehCh',...
        'Name'          , ['Manage Behavior Channels (' Session.SessionID ')'],...
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
        'Position'      , [3 (BehChGUI.WinHgt/2-2.5) BehChGUI.TxtWid BehChGUI.TxtHgt],...
        'String'        , 'Signals',...
        'Tag'           , 'txt_signal_list',...
        'HorizontalAlignment','Left',...
        'FontWeight'    , 'Bold',...
        'Callback'      , '');
    
    h_temp = uitable(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Units'         , BehChGUI.Units,...
        'Position'      , [3 1  BehChGUI.WinWid-7 BehChGUI.WinHgt/2-4],...
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
    
    % Behavior Channel Table
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'text',...
        'Position'      , [3 (BehChGUI.WinHgt-BehChGUI.TxtHgt-3.5) BehChGUI.TxtWid BehChGUI.TxtHgt],...
        'String'        , 'Behavior Channels',...
        'Tag'           , 'txt_behavior_channel_list',...
        'HorizontalAlignment','Left',...
        'FontWeight'    , 'Bold',...
        'Callback'      , '');
    
    table_column = BehChGUI.BehChCommonProps';
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
        'Position'      , [3 (BehChGUI.WinHgt/2+BehChGUI.TxtHgt-1)  BehChGUI.WinWid/2+10 BehChGUI.WinHgt/2-5],...
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
        'Position'      , [BehChGUI.WinWid/2+13 (BehChGUI.WinHgt/2+BehChGUI.WinHgt/4-2) 4 BehChGUI.WinHgt/4-3.5],...
        'String'        , '+',...
        'FontWeight'    , 'bold',...
        'Tag'           , 'btn_add_behavior_channel',...
        'Callback'      , {@AddBehChannel,Session,param});
    
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'pushbutton',...
        'Position'      , [BehChGUI.WinWid/2+13 (BehChGUI.WinHgt/2+BehChGUI.TxtHgt-0.5) 4 BehChGUI.WinHgt/4-3.5],...
        'String'        , '-',...
        'FontWeight'    , 'bold',...
        'Tag'           , 'btn_remove_behavior_channel',...
        'Callback'      , {@RemoveBehChannel,Session});
    
    % Behavior Channel Additional Properties
    h_temp = uicontrol(     ...
        'Parent'        , h_fig_ManageBehCh,...
        'Style'         , 'text',...
        'Position'      , [BehChGUI.WinWid/2+21 (BehChGUI.WinHgt-BehChGUI.TxtHgt-3.5) BehChGUI.WinWid/2-19 BehChGUI.TxtHgt],...
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
        'Position'      , [BehChGUI.WinWid/2+21 (BehChGUI.WinHgt/2+BehChGUI.TxtHgt-1)  BehChGUI.WinWid/2-25 BehChGUI.WinHgt/2-5],...
        'Tag'           , 'tbl_beh_ch_property',...
        'CellEditCallback', {@SaveBehChannels,Session});
    

end


function UpdateGUI(Session)

    ht = findobj('tag','edt_sessionfilepath');
    set(ht,'String',Session.Headers.File);
    
    % Update Signals
    tabledata = [];
    if ~isempty(Session.Signals)
        for i = 1:length(Session.Signals)
            tabledata{i,1} = Session.Signals(i).SessionID;
            tabledata{i,2} = Session.Signals(i).Name;
            tabledata{i,3} = Session.Signals(i).Channel;
            tabledata{i,4} = char(Session.Signals(i).Mic);
            tabledata{i,5} = Session.Signals(i).SampleRate;
            tabledata{i,6} = Session.Signals(i).File;
        end
        
        
    end
    
    ht = findobj('tag','tbl_signal');
    set(ht,'Data',tabledata);
    
    % Update Behavior Channels
    UpdateBehChTable(Session,0);
    

end

function UpdateBehChTable(Session,ind_sel)

    % update the common property table
    
    
    if ~isempty(Session.BehChannels)
        tabledata = [];
        ht = findobj('tag','tbl_behavior_channel');
        col_field = get(ht,'ColumnName');
        for i = 1:length(Session.BehChannels)
            BehCh_type = class(Session.BehChannels(i));
            ind = strfind(BehCh_type,'.');
            BehCh_type(1:ind(end)) = ''; 
            tabledata{i,1} = BehCh_type;
 
            for j = 2:length(col_field)
                eval(['tabledata{i,j} = Session.BehChannels(i).' col_field{j} ';']);
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
            props = properties(Session.BehChannels(ind_sel));
            additional_props = setdiff(props,col_field(2:end),'stable');
            row_field = additional_props;
            
            set(ht,'RowName',row_field)
            for i = 1:length(row_field)

                eval(['tabledata{i,1} = Session.BehChannels(ind_sel).' row_field{i} ';']);
            end
            set(ht,'Data',tabledata);
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
    
    param.SignalList = {'NaN'};
    for i = 1:param.N_signal
        param.SignalList = [param.SignalList num2str(i)];
    end

end


function AddBehChannel(obj,event,Session,param)
      
    var_str = 'Session.BehChannels(end+1) = ';
    eval([var_str 'social.channel.' param.BehChType{1} ';']);       % hard coded path, may need to fix it later
    UpdateBehChTable(Session,0);

end

function has_BehCh = hasBehChannel(Session)
    
    has_BehCh = isprop(Session,'BehChannels');
    
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
    if event.Indices(2) == 1
        if ~strcmp(event.NewData,event.PreviousData)
            eval(['Session.BehChannels(event.Indices(1)) = social.channel.' event.NewData ';']);
            UpdateBehChTable(Session,event.Indices(1));
        end
    end
    
    % then save data no matter what
    SaveBehChannels(obj,event,Session)
end


function SaveBehChannels(obj,event,Session)
    
    % grab all data in the table
    ht = findobj('tag','tbl_behavior_channel');
    tabledata = get(ht,'Data');
    
%     ind = event.Indices;
%     newData = event.NewData;
    col_field = get(ht,'ColumnName');
    ind_ch = get(ht,'UserData');
    ind_ch = ind_ch(1);
    
    for i = 1:size(tabledata,1)
        for j = 2:length(col_field)
            eval(['Session.BehChannels(i).' col_field{j} '= tabledata{i,j};']);
        end
    end
        
    ht = findobj('tag','tbl_beh_ch_property');
    tabledata = get(ht,'Data');
    
    for i = 1:size(tabledata,1)
        row_field = get(ht,'RowName');
        eval(['Session.BehChannels(ind_ch).' row_field{i} '= tabledata{i};']);
    
    end
end

function RemoveBehChannel(obj,event,Session)
    ht = findobj('tag','tbl_behavior_channel');    
    ind = get(ht,'UserData');
    ind_ch = ind(1);
    if ind_ch > 0
        Session.BehChannels(ind_ch) = [];

        UpdateBehChTable(Session,0);
    end

end

function CloseBehChWin(obj,event,BehChGUI)

    % save changes

    % kill window
    ht = findobj('tag','fig_ManageBehCh');
    delete(ht)

    set(0,'DefaultUicontrolFontSize', BehChGUI.defaultFontSize);

end