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
%
% TODO:
% - Add ability to add individual phrases or combine phrases into calls.
% - 


% Edit the above text to modify the response to help PheeBrowser

% Last Modified by GUIDE v2.5 10-Aug-2015 14:05:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
fig_name = [mfilename('fullpath'),'.fig'];
gui_State = struct('gui_Name',       fig_name, ...
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

% % fn = fieldnames(handles);
% % keyfcn = get(handles.fig_PheeBrowser,'KeyPressFcn');
% % for i = 1:length(fn)
% %     pnames = fieldnames(handles.(fn{i}));
% %     if ismember('Style',pnames)
% %         if strcmp(get(handles.(fn{i}),'Style'),'pushbutton') | strcmp(get(handles.(fn{i}),'Style'),'togglebutton')
% %             set(handles.(fn{i}),'KeyPressFcn',keyfcn);
% %         end
% %     end
% % end

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
% clear global
global session pathname filename signals 
% global t_start t_stop phrase_count samplesize Fs filepath filename PlotF0 PheeCall is_noise noise_time noise_channel noise_time_LP noise_time_HP calltype param
% [PTname PTpath] = uigetfile('C:\Documents and Settings\Lingyun\My Documents\Dropbox\RemoteWork\DataAnalysis\*.mat','Load PheeTime');
[PTname PTpath]=uigetfile('C:\data\*.mat','Load session file ...');


if PTname ~= 0
    filename=PTname;
    pathname = PTpath;
    
    set(handles.edt_PheeTime_file,'String',PTname);
    session=load([PTpath PTname]);
    temp=fieldnames(session);
    session=session.(temp{1});
    
    % in future, need to do some filtering here
    % such as getting only Phrases, or only from a particular animal, etc.
    
%     if length(session.Signals)>2
%         [signals ok]=listdlg('ListString',{session.Signals.Name},...
%             'InitialValue',[1 2],...
%             'PromptString','Select two channels:'...
%             );
%         if length(signals)>2
%             signals = signals(1:2);
%         end
%     else
%         signals=[1 2];
%     end
    
    PlotF0 = 1;
    if strcmp(PTname(1:min(length(PTname),9)),'NoiseTime')
        is_noise = 1;
    else
        is_noise = 0;
    end
    
    DisplayPhee(handles,1);
    
    set(hObject,'Enable','off');
    drawnow
    set(hObject,'Enable','on');
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

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');

% --- Executes on button press in btn_next.
function btn_next_Callback(hObject, eventdata, handles)
% hObject    handle to btn_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind = str2num(get(handles.edt_phee_ind,'String'));
DisplayPhee(handles,ind+1);

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');

% --- Executes on button press in btn_update.
function btn_update_Callback(hObject, eventdata, handles)
% hObject    handle to btn_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateTimeVar(handles);
ind = str2num(get(handles.edt_phee_ind,'String'));
DisplayPhee(handles,ind);

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');

% --- Executes on button press in btn_remove.
function btn_remove_Callback(hObject, eventdata, handles)
% hObject    handle to btn_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%TODO UPDATE FOR session

global session 
ind = str2num(get(handles.edt_phee_ind,'String'));
choice = questdlg('Delete current phee phrase?','Warning');
i = ind;
if strcmp(choice,'Yes')
    % Figure which event in the full event list
    
    Event=session.GetEvents;
    Event=Event(i);

    
    ind_remove = find(session.Behaviors.Events==Event);
    pause(0.1)      % without this the next event will be deleted...
    session.Behaviors.Events(ind_remove)=[];
    Event=[];
end
pause(0.1)          % without this the next event will be deleted...
DisplayPhee(handles,i);

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');


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
global pathname filename
global session
% TODO:Debug
try
    [FN PN] = uiputfile([pathname filename]);
catch
    [FN PN] = uiputfile;
end
if FN~=0
    filename=FN;
    pathname=PN;
    saveSession(session,pathname);
end


function DisplayPhee(handles,ind)
% plot phee waveform and spectrogram
% ind is the index of phee

global session totalnum axes_handle

% =================================
% Figure out which events to use
% SignalNames={session.Signals(signals).Name};
% Events=session.GetEvents('Name',SignalNames);
Events = session.GetEvents;

totalnum=length(Events);
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

type=class(Events(ind).Behavior);

% Set display parameters based on SigDetect SampleRate
Fs=Events(ind).Behavior.SigDetect.SampleRate;
% bin_time = 0.004;        % 1ms bins, no smoothing
% win_time = 0.02;        % window length (s)
bin_time = 0.001;        % 1ms bins, no smoothing
win_time = 0.005;        % window length (s)
pre_win = 1.0;           % window before start time (s)   
post_win = 1.0;          % window after stop time (s)
win_size = round(win_time*Fs/2)*2;
bin_size = round(bin_time*Fs);

if totalnum == 0
    axes(handles.axes_wave)
    cla
    axes(handles.axes_spectro)
    cla
    return
end
linkaxes([handles.axes_wave handles.axes_spectro handles.axes_diff],'x');
linkaxes([handles.axes_wave handles.axes_spectro],'y');

% Find event start and stop times
cur_start=Events(ind).eventStartTime;
cur_stop=Events(ind).eventStopTime;

% Set start and stop time for display window
start_point = (cur_start-pre_win);
stop_point = (cur_stop+post_win);

% Read signal for duration of each channel into pheewave
pheewave=cell(2,1);
pheewave(1) = Events(ind).Behavior.SigDetect.get_signal([start_point stop_point]);
% pheewave{1}=pheewave{1};
if isprop(Events(ind).Behavior,'SigRef')
    pheewave(2) = Events(ind).Behavior.SigRef.get_signal([start_point stop_point]);
else
    pheewave{2} = zeros(size(pheewave{1}));
end

% refwave = pheewave(:,2); % Hardcode to show reference channel
% spec{1}=social.analysis.spectra(pheewave{1},win_size,bin_size,Fs,'log');
% spec{2}=social.analysis.spectra(pheewave{2},win_size,bin_size,Fs,'log');

% Compute difference spectrogram
if isprop(Events(ind).Behavior,'spec_th')
    param.spec_th = Events(ind).Behavior.SpecDiffThreshold; % threshold in dB, the parabolic mic intensity should be this number higher than the traditional mic
else
    param.spec_th = 10;
end
param.mode = 'file';           % 'file' for offline analysis, 'realtime' for online analysis
param.task = 'detect';
param.Fs = Events(ind).Behavior.SigDetect.SampleRate;
% spec{3}=spec{1}-spec{2};
% spec{3}(spec{3}<Events(ind).Behavior.SpecDiffThreshold)=0;
% spec{3}(spec{3}>=Events(ind).Behavior.SpecDiffThreshold)=1;
% param.mode = 'file'; param.task = 'detect'; param.Fs=Fs;
spec_out=social.processing.MicChIntensityDiff(pheewave{1},pheewave{2},param);
spec{1}=spec_out.spec{1};
if isprop(Events(ind).Behavior,'SigRef')
    spec{2}=spec_out.spec{2};
    spec{3}=spec_out.spec_diff;
else
    spec{2}=zeros(size(spec{1}));
    spec{3}=pheewave{1};
end


% TODO (fix maximum so that it's consistent across all events).
clim=[min(min(spec{1}(:)),min(spec{2}(:))) max(max(spec{1}(:)),max(spec{2}(:)))];

clim_diff=[0 20];%[min(spec{3}(:)) max(spec{3}(:))];%0 20];%Events(ind).Behavior.SpecDiffThreshold];
% Figure out max for normalization

%
nseg = floor((length(pheewave{1}) - win_size)/bin_size)+1;
y = [0:win_size/2]*Fs/win_size/1000;
x = [0:nseg-1]*bin_size/Fs + start_point;

% Plot first channel to axes_wave
axes(handles.axes_wave)
cla('reset')
colormap(parula);
imagesc(x,y,spec{1},clim);
axis xy;
ylabel('Freq (kHz)');
title(['Behavior: ' Events(ind).Behavior.ID ' - Signal: ' Events(ind).Behavior.SigDetect.ID],'Interpreter','None');
colorbar;
hold on
axes_handle.spec_v1 = plot([1 1]*cur_start,[min(y),max(y)],'k');
axes_handle.spec_v2 = plot([1 1]*cur_stop,[min(y),max(y)],'k');
xlim([start_point stop_point]);
handles.axes_wave.YLim=[0 Fs/2/1000];
hold off;

% Plot second channel to axes_spectro
% h_axes_spectro = findobj('tag','axes_spectro');
axes(handles.axes_spectro)
cla('reset')
colormap(parula);
nseg = floor((length(pheewave{1}) - win_size)/bin_size)+1;
y = [0:win_size/2]*Fs/win_size/1000;
x = [0:nseg-1]*bin_size/Fs + start_point;
imagesc(x,y,spec{2},clim);
axis xy;
xlabel('Time (s)');
ylabel('Freq (kHz)');
title(['Behavior: ' Events(ind).Behavior.ID ' - Signal: ' ],'Interpreter','None'); %Events(ind).Behavior.SigRef.ID
colorbar;
hold on
axes_handle.spec2_v1 = plot([1 1]*cur_start,[min(y),max(y)],'k');
axes_handle.spec2_v2 = plot([1 1]*cur_stop,[min(y),max(y)],'k');
xlim([start_point stop_point]);
handles.axes_spectro.YLim=[0 Fs/2/1000];
hold off;

% Plot difference channel to axes_diff
axes(handles.axes_diff)
cla('reset')
if size(spec{3},2)>1 % IF IS A SPECTROGRAM
    colormap(parula);
    imagesc(x,y,spec{3},clim_diff);
    axis xy;
    ylabel('Freq (kHz)');
    colorbar;
    hold on
    ylim([0 Fs/2/1000]);
else
    % high pass filter for downsampled signal
    hi_pass_cut = 4000;
    smooth_cut = 0.1;
    filter_b = fir1(20,hi_pass_cut/(Fs./2),'high');
    filter_sm = fir1(150,smooth_cut/(Fs./2));
    
    y_mean = mean(spec{3});
    spec{3} = spec{3}-y_mean;
    
    % downsample and filter
    spec{3} = filtfilt(filter_b,1,spec{3});
    
    % get smoothed energy
    spec{3} = spec{3}.^2;
    spec{3} = filtfilt(filter_sm,1,spec{3});
    
    x=[0:length(spec{3})-1]'./Fs+start_point;
    plot(x,10.*log10(spec{3}.^2),'k','LineWidth',1.2);
    handles.axes_diff.YLim=mean(10.*log10(spec{3}.^2))+std(10.*log10(spec{3}.^2))*[-1 +4];
end
hold on;
axes_handle.spec3_v1 = plot([1 1]*cur_start,handles.axes_diff.YLim,'k');
axes_handle.spec3_v2 = plot([1 1]*cur_stop,handles.axes_diff.YLim,'k');
xlim([start_point stop_point]);
title(['Behavior: ' Events(ind).Behavior.ID ' - Signal: ' Events(ind).Behavior.SigDetect.ID],'Interpreter','None');
xlabel('Time (s)');
ylabel('Energy');
% handles.axes_diff.Position(3)=handles.axes_wave.Position(3);
hold off;

set(handles.edt_phee_ind,'String',num2str(ind));
set(handles.edt_start,'String',num2str(cur_start));
set(handles.edt_stop,'String',num2str(cur_stop));

% plot F0 if possible
% if PlotF0 == 1
%     [~,ah_ind]=ismember(Events(ind).ID,SignalNames);
%     switch ah_ind
%         case 1
%             axes(handles.axes_wave)
%         case 2
%             axes(handles.axes_spectro)
%     end
    axes(handles.axes_wave)
    if isprop(Events(ind),'eventF0') && ~isempty(Events(ind).eventF0) && ~isnan(Events(ind).eventF0)
        plot(Events(ind).eventF0.time+cur_start,Events(ind).eventF0.f0/1000,'w','LineWidth',1);
    end
% end

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

if hObject.Value == 1
    zoom on
else
    zoom off
end

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');

% pause(1)
% zoom off
% hz = zoom;
% hz.Enable = 'off';

function PostZoomIn(obj,event,hz)
%     zoom off
%     hz.Enable = 'off';


% --- Executes on button press in btn_zoomout.
function btn_zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to btn_zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom off
zoom out
handles.btn_zoomin.Value = 1-hObject.Value;

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');


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

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');

% --- Executes on button press in btn_pan.
function btn_pan_Callback(hObject, eventdata, handles)
% hObject    handle to btn_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btn_pan
%TODO UPDATE FOR session

if get(hObject,'Value') == 1
    pan on
    set(hObject,'Backgroundcolor','g');
else
    pan off
    color = get(handles.btn_zoomout,'BackgroundColor');
    set(hObject,'Backgroundcolor',color);
end

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');

% --- Executes on button press in btn_add.
function btn_add_Callback(hObject, eventdata, handles)
% hObject    handle to btn_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t_start t_stop
global session
%TODO UPDATE FOR session

% inputstr = inputdlg({'Channel # to add to (1 or 2)','Start time (s)','Stop time (s)'},'Add a call phrase');

% using mouse click on the figure
% get current channel
ind = str2num(get(handles.edt_phee_ind,'String'));
   
[gx,gy] = ginput(2);
ah=gca;
Name=ah.Title.String;
% if ~isempty(inputstr)
%     ch_add = str2num(inputstr{1});    
%     t_start_add = str2num(inputstr{2});
%     t_stop_add = str2num(inputstr{3});
if length(gx) == 2
    t_start_add = gx(1);
    t_stop_add = gx(2);
    [ind_beh_ch, ok] = listdlg('PromptString','Add to which Behavior Channel?',...
        'ListString',{session.Behaviors.ID},...
        'SelectionMode','single');
    if ok
        %     signal=session.GetSignals('Name',Name);
        newEvent=social.event.Phrase(session,session.Behaviors(ind_beh_ch),t_start_add,t_stop_add);
        
        session.Behaviors(ind_beh_ch).Events(end+1)=newEvent;
        
        Events=session.GetEvents;

        i=find(Events==newEvent);
    end
    DisplayPhee(handles,i);
end

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');


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

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');


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

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');






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
            '[ Z ]        Toggle Zoom On/Off';
            };
h_msg = msgbox(help_str,'Help');
% ah = get(h_msg, 'CurrentAxes' );
% ch = get(ah, 'Children' );
% set( ch, 'FontName', 'Arial','FontSize', 10);

set(hObject,'Enable','off');
drawnow
set(hObject,'Enable','on');

% --- Executes on key press with focus on fig_PheeBrowser and none of its controls.
function fig_PheeBrowser_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig_PheeBrowser (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

%TODO UPDATE FOR session
global session 
time_step = 0.005;       % in sec for changing time by key

ind = str2num(get(handles.edt_phee_ind,'String'));

Events=session.GetEvents;
Event=Events(ind);

isCall=strcmp(Event.eventClass,'Call');
isPhrase=strcmp(Event.eventClass,'Phrase');

disp_text = 0;
% eventdata.Key
switch eventdata.Key
    case 'p'    % Phee
        if isCall|isPhrase; Event.(['event' Event.eventClass 'Type']) = 'Phee'; end
        disp_text = 1;
    case 'w'    % Twitter
        if isCall|isPhrase; Event.(['event' Event.eventClass 'Type']) = 'Twitter'; end
        disp_text = 1;
    case 't'    % Trill
        if isCall|isPhrase; Event.(['event' Event.eventClass 'Type']) = 'Trill'; end
        disp_text = 1;
    case 'l'    % Trillphee
        if isCall|isPhrase; Event.(['event' Event.eventClass 'Type']) = 'Trillphee'; end
        disp_text = 1;
    case 'o'    % Others, to be defined in the input box
        if isCall|isPhrase
            CallTypes={'Tsik',...
                'P-peep',...
                'T-peep',...
                'Sa-peep',...
                'Sd-peep',...
                'Dh-peep',...
                'Egg',...
                'Ock',...
                'Other'}
                
            typename = listdlg('PromptString','Specify a call type','ListString',CallTypes,'SelectionMode','single');
            if ~isempty(typename)
                if typename<length(CallTypes)
                    Event.(['event' Event.eventClass 'Type']) = CallTypes{typename};
                else
                    typename=inputdlg('Secify a call type');
                    Event.(['event' Event.eventClass 'Type']) = typename{1};
                end
            else
                Event.(['event' Event.eventClass 'Type']) = '';
            end
        end
        disp_text = 1;
    case 'n'    % Not assigned
        if isCall|isPhrase; Event.(['event' Event.eventClass 'Type']) = []; end
        
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
    case 'z'
        zoom_status = get(handles.btn_zoomin,'Value');
        set(handles.btn_zoomin,'Value',1-zoom_status);
        btn_zoomin_Callback(handles.btn_zoomin, eventdata, handles);
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
if disp_text == 1
    DisplayCallType([],[],handles);
end

function DisplayCallType(ind,ah_ind,handles)
global calltype is_noise t_start
global session signals

% SignalNames={session.Signals(signals).Name};
% Events=session.GetEvents('Name',SignalNames);
Events = session.GetEvents;
ind = str2num(get(handles.edt_phee_ind,'String'));

% [~,ah_ind]=ismember(Events(ind).Name,SignalNames);
% if ah_ind==2
%     ah_addtext=handles.axes_spectro;
%     ah_cleartext=handles.axes_wave;
% else
%     ah_addtext=handles.axes_wave;
%     ah_cleartext=handles.axes_spectro;
% end
ah_addtext=handles.axes_wave;
ah_cleartext=handles.axes_spectro;

% Clear string from the previous axes.
axes(ah_cleartext);
h_temp=findobj('Tag','txtdisp_calltype');
if ~isempty(h_temp)
    set(h_temp,'String','');
end

%Begin adding text for current call
axes(ah_addtext);
% Get position element for text to add.
xx_range = get(gca,'XLim');
yy_range = get(gca,'YLim');
xx_text = (xx_range(2)-xx_range(1))*0.05+xx_range(1);
yy_text = (yy_range(2)-yy_range(1))*0.8+yy_range(1);

% Generate eventClass and eventCallType strings
txt_str{1,1}=Events(ind).eventClass;
txt_str{2,1}='';
if strcmp(Events(ind).eventClass,'Call')
    txt_str{2,1}=Events(ind).eventCallType;
elseif strcmp(Events(ind).eventClass,'Phrase');
    txt_str{2,1}=Events(ind).eventPhraseType;
end

% add text
h_temp = findobj('Tag','txtdisp_calltype');
if isempty(h_temp)
    h_type = text(xx_text,yy_text,...
        txt_str,'FontSize',16,'FontName','Arial','FontWeight','Bold','Tag','txtdisp_calltype');
else
    set(h_temp,'String',txt_str,'Position',[xx_text,yy_text]);
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
    set(axes_handle.spec2_v1,'XData',[1 1]*start_time);
    set(axes_handle.spec2_v2,'XData',[1 1]*stop_time);
    set(axes_handle.spec3_v1,'XData',[1 1]*start_time);
    set(axes_handle.spec3_v2,'XData',[1 1]*stop_time);



function UpdateTimeVar(handles)
    global session
    
    Events=session.GetEvents;
%     AllEvents=session.Events;
%     for i=1:length(AllEvents)
%         if AllEvents(i)==newEvent;
%             break;
%         end
%     end

    new_start = str2num(get(handles.edt_start,'String'));
    new_stop = str2num(get(handles.edt_stop,'String'));
    ind = str2num(get(handles.edt_phee_ind,'String'));
    if ind > 0 && ind <= length(Events)
        Events(ind).eventStartTime=new_start;
        Events(ind).eventStopTime=new_stop;
    end


% --- Executes on selection change in channel_list.
function channel_list_Callback(hObject, eventdata, handles)
% hObject    handle to channel_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_list


% --- Executes during object creation, after setting all properties.
function channel_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


