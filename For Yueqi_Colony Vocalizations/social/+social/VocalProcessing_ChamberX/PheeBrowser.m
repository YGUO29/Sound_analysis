function varargout = PheeBrowser(varargin)
% PHEEBROWSER M-file for PheeBrowser.fig
%      PHEEBROWSER, by itself, creates a new PHEEBROWSER or raises the existing
%      singleton*.
%
%      H = PHEEBROWSER returns the handle to a new PHEEBROWSER or the handle to
%      the existing singleton*.
%
%      PHEEBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHEEBROWSER.M with the given input arguments.
%
%      PHEEBROWSER('Property','Value',...) creates a new PHEEBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PheeBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PheeBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PheeBrowser

% Last Modified by GUIDE v2.5 30-Oct-2014 15:39:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PheeBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @PheeBrowser_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PheeBrowser is made visible.
function PheeBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PheeBrowser (see VARARGIN)

% Choose default command line output for PheeBrowser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PheeBrowser wait for user response (see UIRESUME)
% uiwait(handles.fig_PheeBrowser);

clear global
hz = zoom;
set(hz,'ActionPostCallback',{@DisplayCallType,handles});
hz = pan;
set(hz,'ActionPostCallback',{@DisplayCallType,handles});

% --- Outputs from this function are returned to the command line.
function varargout = PheeBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edt_PheeTime_file_Callback(hObject, eventdata, handles)
% hObject    handle to edt_PheeTime_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_PheeTime_file as text
%        str2double(get(hObject,'String')) returns contents of edt_PheeTime_file as a double


% --- Executes during object creation, after setting all properties.
function edt_PheeTime_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_PheeTime_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_PheeTime_file.
function btn_PheeTime_file_Callback(hObject, eventdata, handles)
% hObject    handle to btn_PheeTime_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear global
global t_start t_stop phrase_count samplesize Fs filepath filename PlotF0 PheeCall is_noise noise_time noise_channel noise_time_LP noise_time_HP calltype param
[PTname PTpath] = uigetfile('C:\Documents and Settings\Lingyun\My Documents\Dropbox\RemoteWork\DataAnalysis\*.mat','Load PheeTime');
if PTname ~= 0
    set(handles.edt_PheeTime_file,'String',PTname);
    load([PTpath PTname]);
    if strcmp(PTname(1:8),'PheeInfo')
        PTname2 = strrep(PTname,'PheeInfo','PheeTime');
        load([PTpath PTname2]);
        PlotF0 = 1;
    else
        PlotF0 = 0;
    end
    if strcmp(PTname(1:9),'NoiseTime')
        is_noise = 1;
    else
        is_noise = 0;
    end
        
%     phrase_count = 1;
%     for i = 2:length(PheeCall)
%         phrase_count(i) = phrase_count(i-1) + PheeCall(i).Nphrases;
%     end
    
    
   
    wavefile = [filepath filename];
    
    if isempty(calltype)
        for jj = 1:length(t_start)
            calltype{jj} = cell(length(t_start{jj}),1);
            [calltype{jj}{1:length(t_start{jj})}] = deal('');
        end
    end
    DisplayPhee(handles,1);

    
end


function edt_phee_ind_Callback(hObject, eventdata, handles)
% hObject    handle to edt_phee_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_phee_ind as text
%        str2double(get(hObject,'String')) returns contents of edt_phee_ind as a double

ind = str2num(get(handles.edt_phee_ind,'String'));
DisplayPhee(handles,ind);


% --- Executes during object creation, after setting all properties.
function edt_phee_ind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_phee_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_prev.
function btn_prev_Callback(hObject, eventdata, handles)
% hObject    handle to btn_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind = str2num(get(handles.edt_phee_ind,'String'));
DisplayPhee(handles,ind-1);

% --- Executes on button press in btn_next.
function btn_next_Callback(hObject, eventdata, handles)
% hObject    handle to btn_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind = str2num(get(handles.edt_phee_ind,'String'));
DisplayPhee(handles,ind+1);

% --- Executes on button press in btn_update.
function btn_update_Callback(hObject, eventdata, handles)
% hObject    handle to btn_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateTimeVar(handles);
ind = str2num(get(handles.edt_phee_ind,'String'));
DisplayPhee(handles,ind);

% --- Executes on button press in btn_remove.
function btn_remove_Callback(hObject, eventdata, handles)
% hObject    handle to btn_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t_start t_stop totalnum is_noise noise_time noise_time_LP noise_time_HP
ind = str2num(get(handles.edt_phee_ind,'String'));
choice = questdlg('Delete current phee phrase?','Warning');
if strcmp(choice,'Yes')
    
    if is_noise == 0
        N_Ch1 = length(t_start{1});
        if ind > N_Ch1
            ch = 2;
            phrase_ind = ind - N_Ch1;
        else
            ch = 1;
            phrase_ind = ind;
        end
        t_start{ch}(phrase_ind) = [];
        t_stop{ch}(phrase_ind) = [];
    else
        if ~isempty(noise_time_LP) && ~isempty(noise_time_HP)
            ind_LP = find(noise_time_LP(:,1)==noise_time(ind,1));
            ind_HP = find(noise_time_HP(:,1)==noise_time(ind,1));
            if ~isempty(ind_LP)
                noise_time_LP(ind_LP,:) = [];
            end
            if ~isempty(ind_HP)
                noise_time_HP(ind_HP,:) = [];
            end
        end
        noise_time(ind,:) = [];
    end
    DisplayPhee(handles,ind);
end

function edt_start_Callback(hObject, eventdata, handles)
% hObject    handle to edt_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_start as text
%        str2double(get(hObject,'String')) returns contents of edt_start as a double


% --- Executes during object creation, after setting all properties.
function edt_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edt_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edt_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_stop as text
%        str2double(get(hObject,'String')) returns contents of edt_stop as a double


% --- Executes during object creation, after setting all properties.
function edt_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_save.
function btn_save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t_start t_stop samplesize Fs filepath filename is_noise noise_time noise_channel noise_time_LP noise_time_HP calltype param

if is_noise == 0
    uisave({'t_start','t_stop','filepath','filename','samplesize','Fs','calltype','param'});
else
    if ~isempty(noise_time_LP) || ~isempty(noise_time_HP)
        uisave({'noise_time','noise_time_LP','noise_time_HP','noise_channel','filepath','filename','samplesize','Fs'});
    else
        
        uisave({'noise_time','noise_channel','filepath','filename','samplesize','Fs'});
    end
end


function DisplayPhee(handles,ind)
% plot phee waveform and spectrogram
% ind is the index of phee

global t_start t_stop phrase_count filepath filename totalnum samplesize Fs PheeCall PlotF0 is_noise noise_time noise_channel axes_handle
bin_time = 0.001;        % 1ms bins, no smoothing
win_time = 0.005;        % window length (s)
pre_win = 0.5;           % window before start time (s)   
post_win = 0.5;          % window after stop time (s)
win_size = round(win_time*Fs/2)*2;

% by L.Zhao, 02/14/2014
strind = strfind(filename,'denoise');
if isempty(strind)
    denoise = 0;
else
    denoise = 1;
end

if denoise == 1     % use raw recording to find features
    strind = strfind(filename,'_denoise.wav');
    filename_display = [filename(1:strind-1) '.wav'];
else
    filename_display = filename;
end


wavefile = [filepath filename_display];

% =================================

if is_noise == 0
    
    totalnum = length(t_start{1})+length(t_start{2});
else
    totalnum = size(noise_time,1);
end
set(handles.txt_totalnum,'String',['/ ' num2str(totalnum)]);
if ind < 1 || ind > totalnum
    h_msg = msgbox('Call number out of range!','Error','Warn');
    uiwait(h_msg);
end
if ind < 1
    ind = 1;
end
if ind > totalnum
    ind = totalnum;
end
if totalnum == 0
    axes(handles.axes_wave)
    cla
    axes(handles.axes_spectro)
    cla
    return
end
    
if is_noise == 0
    N_Ch1 = length(t_start{1});
    if ~isempty (t_start{2})
        N_Ch2 = length(t_start{2});
    else
        N_Ch2 = 0;
    end
    if ind > N_Ch1
        ch = 2;
        phrase_ind = ind - N_Ch1;
    else
        ch = 1;
        phrase_ind = ind;
    end


    cur_start = t_start{ch}(phrase_ind);
    cur_stop = t_stop{ch}(phrase_ind);
else
    cur_start = noise_time(ind,1);
    cur_stop = noise_time(ind,2);
    ch = noise_channel;
end


start_point = max(1,round((cur_start-pre_win)*Fs));
stop_point = min(round((cur_stop+post_win)*Fs),samplesize);
pheewave = wavread(wavefile,[start_point stop_point]);
disp_start = (start_point-1)/Fs;
disp_stop = (stop_point-1)/Fs;
pheewave = pheewave(:,ch);
% h_axes_wave = findobj('tag','axes_wave');
axes(handles.axes_wave)
cla
plot(cur_start-pre_win+[0:length(pheewave)-1]/Fs,pheewave);
hold on
maxaxis = max(abs(pheewave));
ylim([-1 1]*maxaxis);
xlim([disp_start disp_stop]);
plot([1 1]*cur_start,[-1 1]*maxaxis,'r')
plot([1 1]*cur_stop,[-1 1]*maxaxis,'r')

bin_size = round(bin_time*Fs);
spec = spectra(pheewave,win_size,bin_size,Fs,'log');
% h_axes_spectro = findobj('tag','axes_spectro');
axes(handles.axes_spectro)
cla
colormap(jet);
nseg = floor((length(pheewave) - win_size)/bin_size)+1;
y = [0:win_size/2]*Fs/win_size/1000;
x = [0:nseg-1]*bin_size/Fs + disp_start;
imagesc(x,y,spec);
axis xy;
xlabel('Time (s)');
ylabel('Freq (kHz)');
% title('Spectrogram');
hold on
axes_handle.spec_v1 = plot([1 1]*cur_start,[min(y),max(y)],'k');
axes_handle.spec_v2 = plot([1 1]*cur_stop,[min(y),max(y)],'k');
xlim([disp_start disp_stop]);
ylim([0 Fs/2/1000]);

set(handles.edt_phee_ind,'String',num2str(ind));
set(handles.edt_start,'String',num2str(cur_start));
set(handles.edt_stop,'String',num2str(cur_stop));

% plot F0 if possible
if PlotF0 == 1
    for i = 1:length(PheeCall)
        for j = 1:size(PheeCall(i).Time)
            if PheeCall(i).Time(j,1) == cur_start
                PCind = i;
                PCphrase = j;
            end
        end
    end
    axes(handles.axes_spectro)
    plot(PheeCall(PCind).F0{PCphrase}(:,1),PheeCall(PCind).F0{PCphrase}(:,2)/1000,'w','LineWidth',1)
end

DisplayCallType([],[],handles);



function edt_recording_Callback(hObject, eventdata, handles)
% hObject    handle to edt_recording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_recording as text
%        str2double(get(hObject,'String')) returns contents of edt_recording as a double


% --- Executes during object creation, after setting all properties.
function edt_recording_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_recording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in btn_zoomin.
function btn_zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to btn_zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom on


% --- Executes on button press in btn_zoomout.
function btn_zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to btn_zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off
zoom out


% --- Executes on button press in btn_datacursor.
function btn_datacursor_Callback(hObject, eventdata, handles)
% hObject    handle to btn_datacursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') == 1
    datacursormode on
    set(hObject,'Backgroundcolor','y');
else
    datacursormode off
    color = get(handles.btn_zoomout,'BackgroundColor');
    set(hObject,'Backgroundcolor',color);
end


% --- Executes on button press in btn_pan.
function btn_pan_Callback(hObject, eventdata, handles)
% hObject    handle to btn_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_pan

if get(hObject,'Value') == 1
    pan on
    set(hObject,'Backgroundcolor','g');
else
    pan off
    color = get(handles.btn_zoomout,'BackgroundColor');
    set(hObject,'Backgroundcolor',color);
end


% --- Executes on button press in btn_add.
function btn_add_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t_start t_stop
% inputstr = inputdlg({'Channel # to add to (1 or 2)','Start time (s)','Stop time (s)'},'Add a call phrase');

% using mouse click on the figure
% get current channel
ind = str2num(get(handles.edt_phee_ind,'String'));
N_Ch1 = length(t_start{1});
if ~isempty (t_start{2})
    N_Ch2 = length(t_start{2});
else
    N_Ch2 = 0;
end
if ind > N_Ch1
    ch = 2;
    phrase_ind = ind - N_Ch1;
else
    ch = 1;
    phrase_ind = ind;
end
   
[gx,gy] = ginput(2);
% if ~isempty(inputstr)
%     ch_add = str2num(inputstr{1});    
%     t_start_add = str2num(inputstr{2});
%     t_stop_add = str2num(inputstr{3});
if length(gx) == 2
    ch_add = ch;
    t_start_add = gx(1);
    t_stop_add = gx(2);
    
    if ch_add <= 2 && ch_add >= 1
        t_start{ch_add} = [t_start{ch_add};t_start_add];
        t_start{ch_add} = sort(t_start{ch_add});
        t_stop{ch_add} = [t_stop{ch_add};t_stop_add];
        t_stop{ch_add} = sort(t_stop{ch_add});
    end
    
    ind = str2num(get(handles.edt_phee_ind,'String'));
    DisplayPhee(handles,ind);
end


% --- Executes on button press in btn_starttime.
function btn_starttime_Callback(hObject, eventdata, handles)
% hObject    handle to btn_starttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_starttime
if get(handles.btn_starttime,'Value')==1
    axes(handles.axes_spectro);
    [x,y] = ginput(1);
    set(handles.edt_start,'String',num2str(x));
    set(handles.btn_starttime,'Value',0);
    btn_update_Callback(handles.btn_update, eventdata, handles);
end



% --- Executes on button press in btn_stoptime.
function btn_stoptime_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stoptime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_stoptime
if get(handles.btn_stoptime,'Value')==1
    axes(handles.axes_spectro);
    [x,y] = ginput(1);
    set(handles.edt_stop,'String',num2str(x));
    set(handles.btn_stoptime,'Value',0);
    btn_update_Callback(handles.btn_update, eventdata, handles);
end








% --- Executes on button press in btn_help.
function btn_help_Callback(hObject, eventdata, handles)
% hObject    handle to btn_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_help

help_str = {'Button and Key Instructions';
            '';
            '===== Button Functions =====';
            '<|>          Zoom In';
            '>|<          Zoom Out';
            '(~)          Pan';
            '[+]          Data Cursor';
            '';
            '======= Key Functions ======';
            '[ H ]           Help (Show Instructions)';
            '[ Del ]           Remove Current Call';
            '[ Backspace ]     Remove Current Call';
            '[ B ]           Modify Start Time';
            '[ E ]           Modify Stop Time';
            '[ ''-'' / ''='' ]         Start Time -/+';
            '[ ''['' / '']'' ]         Stop Time -/+'
            '<--             Update and Go to Previous';
            '[ D ]           Update and Go to Previous';
            '-->             Update and Go to Next';
            '[ F ]           Update and Go to Next';
            '[ A ]           Add a Call (Click start/stop)';
            '';
            '==== Call Type Assignment ====';
            '[ P ]        Phee';
            '[ W ]        Twitter';
            '[ T ]        Trill';
            '[ L ]        Trillphee';
            '[ O ]        Others';
            '[ N ]        Not Assigned';
            };
h_msg = msgbox(help_str,'Help');
% ah = get(h_msg, 'CurrentAxes' );
% ch = get(ah, 'Children' );
% set( ch, 'FontName', 'Arial','FontSize', 10);


% --- Executes on key press with focus on fig_PheeBrowser and none of its controls.
function fig_PheeBrowser_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig_PheeBrowser (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

global calltype is_noise t_start
time_step = 0.005;       % in sec for changing time by key
ind = str2num(get(handles.edt_phee_ind,'String'));

if is_noise == 0
    N_Ch1 = length(t_start{1});
    if ind > N_Ch1
        ch = 2;
        phrase_ind = ind - N_Ch1;
    else
        ch = 1;
        phrase_ind = ind;
    end
    
end
disp_text = 0;
% eventdata.Key
switch eventdata.Key
    case 'p'    % Phee
        typename = 'Phee';
        disp_text = 1;
    case 'w'    % Twitter
        typename = 'Twitter';
        disp_text = 1;
    case 't'    % Trill
        typename = 'Trill';
        disp_text = 1;
    case 'l'    % Trillphee
        typename = 'Trillphee';
        disp_text = 1;
    case 'o'    % Others, to be defined in the input box
        typename = inputdlg('Specify a call type','',1,{'Others'});
        if ~isempty(typename)
            typename = typename{1};
        else
            typename = '';
        end
        disp_text = 1;
    case 'n'    % Not assigned
        typename = [];
        disp_text = 1;
    case 'h'
        btn_help_Callback(handles.btn_help, eventdata, handles);
    case {'delete','backspace'}
        btn_remove_Callback(handles.btn_remove, eventdata, handles);
    case {'leftarrow','d'}
            
            btn_prev_Callback(handles.btn_prev, eventdata, handles);
        
    
    case {'rightarrow','f'}
        
        btn_next_Callback(handles.btn_next, eventdata, handles);
    
    case 'b'
        set(handles.btn_starttime,'Value',1);
        btn_starttime_Callback(handles.btn_starttime, eventdata, handles);
    case 'e'
        set(handles.btn_stoptime,'Value',1);
        btn_stoptime_Callback(handles.btn_stoptime, eventdata, handles);
    case 'a'
        btn_add_Callback(handles.btn_add, eventdata, handles);
    case 'hyphen'
        start_time = str2num(get(handles.edt_start,'String'));
        start_time = start_time - time_step;
        set(handles.edt_start,'String',num2str(start_time));
        UpdateTimeMarker(handles)
    case 'equal'
        start_time = str2num(get(handles.edt_start,'String'));
        start_time = start_time + time_step;
        set(handles.edt_start,'String',num2str(start_time));
        UpdateTimeMarker(handles)
    case 'leftbracket'
        stop_time = str2num(get(handles.edt_stop,'String'));
        stop_time = stop_time - time_step;
        set(handles.edt_stop,'String',num2str(stop_time));
        UpdateTimeMarker(handles)
    case 'rightbracket'
        stop_time = str2num(get(handles.edt_stop,'String'));
        stop_time = stop_time + time_step;
        set(handles.edt_stop,'String',num2str(stop_time));
        UpdateTimeMarker(handles)
        
        
        
end
if disp_text == 1 && ~isempty(calltype)
    calltype{ch}{phrase_ind} = typename;
    DisplayCallType([],[],handles);
end

function DisplayCallType(obj,event,handles)
global calltype is_noise t_start
ind = str2num(get(handles.edt_phee_ind,'String'));

if is_noise == 0
    N_Ch1 = length(t_start{1});
    if ind > N_Ch1
        ch = 2;
        phrase_ind = ind - N_Ch1;
    else
        ch = 1;
        phrase_ind = ind;
    end
    
end

axes(handles.axes_spectro)
xx_range = get(gca,'XLim');
yy_range = get(gca,'YLim');

xx_text = (xx_range(2)-xx_range(1))*0.05+xx_range(1);
yy_text = (yy_range(2)-yy_range(1))*0.9+yy_range(1);

if ~isempty(calltype)
    h_temp = findobj('Tag','txtdisp_calltype');
    if isempty(h_temp)
        h_type = text(xx_text,yy_text,...
                        calltype{ch}{phrase_ind},'FontSize',16,'FontName','Arial','FontWeight','Bold','Tag','txtdisp_calltype');
    else
        set(h_temp,'String',calltype{ch}{phrase_ind},'Position',[xx_text,yy_text]);
    end
end





% --- Executes on key press with focus on fig_PheeBrowser or any of its controls.
function fig_PheeBrowser_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig_PheeBrowser (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

aa = 1;






% --- Executes on key release with focus on fig_PheeBrowser and none of its controls.
function fig_PheeBrowser_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to fig_PheeBrowser (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
% switch eventdata.Key
%     case {'hyphen','equal','leftbracket','rightbracket'}
%         btn_update_Callback(hObject, eventdata, handles);
%         
% end
UpdateTimeVar(handles)

function UpdateTimeMarker(handles)
    global axes_handle
    start_time = str2num(get(handles.edt_start,'String'));
    stop_time = str2num(get(handles.edt_stop,'String'));
    set(axes_handle.spec_v1,'XData',[1 1]*start_time);
    set(axes_handle.spec_v2,'XData',[1 1]*stop_time);


function UpdateTimeVar(handles)
    global t_start t_stop totalnum is_noise noise_time noise_time_LP noise_time_HP
    new_start = str2num(get(handles.edt_start,'String'));
    new_stop = str2num(get(handles.edt_stop,'String'));
    ind = str2num(get(handles.edt_phee_ind,'String'));
    if is_noise == 0
        N_Ch1 = length(t_start{1});
        if ind > N_Ch1
            ch = 2;
            phrase_ind = ind - N_Ch1;
        else
            ch = 1;
            phrase_ind = ind;
        end
        t_start{ch}(phrase_ind) = new_start;
        t_stop{ch}(phrase_ind) = new_stop;
    else
        if ~isempty(noise_time_LP) && ~isempty(noise_time_HP)
            ind_LP = find(noise_time_LP(:,1)==noise_time(ind,1));
            ind_HP = find(noise_time_HP(:,1)==noise_time(ind,1));
            if ~isempty(ind_LP)
                noise_time_LP(ind_LP,:) = [new_start new_stop];
            end
            if ~isempty(ind_HP)
                noise_time_HP(ind_HP,:) = [new_start new_stop];
            end
        end
        noise_time(ind,:) = [new_start new_stop];
    end
