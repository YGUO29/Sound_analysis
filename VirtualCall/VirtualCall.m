function varargout = VirtualCall(varargin)
% VIRTUALCALL MATLAB code for VirtualCall.fig
%      VIRTUALCALL, by itself, creates a new VIRTUALCALL or raises the existing
%      singleton*.
%
%      H = VIRTUALCALL returns the handle to a new VIRTUALCALL or the handle to
%      the existing singleton*.
%
%      VIRTUALCALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIRTUALCALL.M with the given input arguments.
%
%      VIRTUALCALL('Property','Value',...) creates a new VIRTUALCALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VirtualCall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VirtualCall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VirtualCall

% ===========================================================================
% Notes:
% - VirtualCall V2.0 
% - Last Modified by GUIDE v2.5 02-Mar-2020 15:16:30
% - based on Dimattina and Wang. JN. 2006
% - modified from GUI program by Yi Zhou 2006
% - by Chia-Jung Chang 2014

% ================== synthesize function ====================================
% ================== for TONE, TRILL, PHEE, TRILL_PHEE ======================

% function [y,rms,fund,harm] = narrow_synth(trillstruct,type,SR)
% - modified from xb_vv_rand by Yi Zhou 2006
% - based upon xb_vv_trillsynth by Chris Dimattina 2005
% - by Chia-Jung Chang 22-Jun-2013

% Inputs:
% - SR 				- sampling rate
% - trillstruct 	- structure with narrowband call parameters
% - type            - call type (1: Tone, 2: Phee, 3: Trill, 4: Trillphee)

% Outputs:
% - y 				- entire vocalization data
% - rms             - RMS for the signal y
% - fund			- fundamental component of vocalization
% - harm			- harmonic component of vocalization

% Parameters: 
% ------ (1) variable time-varying parm -------------------------------------
% ------  Not directly controlled by users ----------------------------------
%
% - trillstruct.FM1_back    - FM1 backbone       (scaled to [0,1])  default 1
% - trillstruct.FM2_back    - FM2 backbone       (scaled to [0,1])  default 1
% - trillstruct.FM1_depth   - FM1 depth contour  (scaled to [0,1])  default 1
% - trillstruct.FM2_depth   - FM2 depth contour  (scaled to [0,1])  default 1
% - trillstruct.FM1_rate    - FM1 rate contour   (scaled to [0,1])  default 0
% - trillstruct.FM2_rate    - FM2 rate contour   (scaled to [0,1])  default 0
%
% - trillstruct.AM1_back    - AM1 backbone       ([0,1])            default 1
% - trillstruct.AM2_back    - AM2 backbone       ([0,1])            default 1
% - trillstruct.AM1_rate    - AM1 rate contour   (scaled to [0,1])  default 0
% - trillstruct.AM2_rate    - AM2 rate contour   (scaled to [0,1])  default 0
%
% ------ (2) constant scalar parm -------------------------------------------
% ------  Unable to change in this program ----------------------------------
%
% - trillstruct.mnk         - structure source                  default 'ALL'
% - trillstruct.f2f1        - harmonic ratio                    default 2
% - trillstruct.initfmphase - initial FM phase    (radians)     default pi
% - trillstruct.am1fm1shift - AM1-FM1 phase shift (radians)	    default pi
% - trillstruct.am2fm1shift - AM2-FM1 phase shift (radians)     default pi
%
% ------ (3) variable scalar parm -------------------------------------------
% ------  Directly modified by users ----------------------------------------
%
% - trillstruct.fm1mod      - backbone frequency modulation depth (Hz)
% - trillstruct.fm2mod      - backbone frequency modulation depth (Hz)
% - trillstruct.fm1_rate    - mean FM1 rate 					  (Hz)
% - trillstruct.fm2_rate    - mean FM2 rate 					  (Hz)
% - trillstruct.fm1_depth   - max FM1 depth 					  (Hz or oct)
% - trillstruct.fm2_depth   - max FM2 depth 					  (Hz or oct)
%
% - trillstruct.am1mod      - backbone amplitude modulation ratio ([0,1])
% - trillstruct.am2mod      - backbone amplitude modulation ratio ([0,1])
% - trillstruct.am1_depth   - mean AM1 depth 					  ([0,1])
% - trillstruct.am2_depth   - mean AM2 depth 					  ([0,1])
% - trillstruct.am1_rate    - mean AM1 rate 				      (Hz)
% - trillstruct.am2_rate    - mean AM2 rate 					  (Hz)
%
% - trillstruct.fc          - center frequency 					  (Hz)
% - trillstruct.dur         - call duration 					  (sec)
% - trillstruct.rAttn       - harmonic attenuation 				  (dB)
% - trillstruct.snr         - Signal-to-Noise Ratio               (dB)
% - trillstruct.bpbw        - noise bandwidth                     (oct)
% - trillstruct.hbw         - harmonic bandwidth centered at fc   (oct)             
% - trillstruct.seed        - psuedo random seed 
% - trillstruct.trans       - time of transition    (1: trill, 0: phee)
% - trillstruct.order       - harmonic order        (fc/f0)
% - trillstruct.fmdepth_oct - FM depth unit         (1: oct, 0: Hz) 

% ================== synthesize function ====================================
% ================== for TWIT ===============================================

% function [y,rms,fund,harm] = twitter_synth(twitstruct,SR)
% based upon xb_vv_twitsynth by Chris Dimattina 2005
% by Chia-Jung Chang 22-Jun-2013

% Inputs:
% - SR 				- sampling rate
% - twitstruct   	- structure with twitter call parameters

% Outputs:
% - y 				- entire vocalization data
% - rms             - RMS for the signal y
% - fund			- fundamental component of vocalization
% - harm			- harmonic component of vocalization

% Parameters: 
% ------ (1) variable time-varying parm -------------------------------------
% ------  Not directly controlled by users ----------------------------------
%
% - twitstruct.dur          - call duration 					(sec)
% - twitstruct.tsw          - phrase sweep time vector          (sec) 
% - twitstruct.tkn          - time fraction of knee vector      ([0,1])
% - twitstruct.fkn          - freq fraction of knee vector 		([0,1])
% - twitstruct.bwv          - phrase bandwidth vector (fsp-fst) (Hz)
% - twitstruct.C_cell{:,1}  - starting frequency vector (fst)   (Hz)
% - twitstruct.C_cell{:,2}  - ending frequency vector   (fsp)   (Hz)
% - twitstruct.C_cell{:,3}  - same as twitstruct.fkn    (fkn)   ([0,1])
% - twitstruct.C_cell{:,4}  - same as twitstruct.tkn    (tkn)   ([0,1])
% - twitstruct.C_cell{:,5}  - same as twitstruct.tsw    (tsw)   (sec)
% - twitstruct.C_cell{:,9}  - freq contour before knee  (f1bk)  (Hz)
% - twitstruct.C_cell{:,10} - freq contour after knee   (f1ak)  (Hz)
%
% ------ (2) constant scalar parm -------------------------------------------
% ------  Unable to change in this program ----------------------------------
%
% - trillstruct.mnk         - structure source                  default 'ALL'
% - trillstruct.f2f1        - harmonic ratio                    default 2
% - twitstruct.C_cell{:,6}  - relative phrase amplitude vector  (ram) 
% - twitstruct.C_cell{:,7}  - before knee time 25D vector 		(t1bk)([0,1])   
% - twitstruct.C_cell{:,8}  - after knee time 10D vector  		(t1ak)([0,1])  
% - twitstruct.C_cell{:,11} - AM1 contour before knee  		    (a1bk)([0,1])   
% - twitstruct.C_cell{:,12} - AM1 contour after knee  		    (a1ak)([0,1])    
% - twitstruct.C_cell{:,13} - AM2 contour before knee  		    (a2bk)([0,1])   
% - twitstruct.C_cell{:,14} - AM2 contour after knee  		    (a2ak)([0,1])
% - twitstruct.C_cell{:,15} - same as twitstruct.C_cell{:,7}    (t1bk)([0,1])
% - twitstruct.C_cell{:,16} - same as twitstruct.C_cell{:,8}    (t1ak)([0,1]) 
%
% ------ (3) variable scalar parm -------------------------------------------
% ------  Directly modified by users ----------------------------------------
%
% - twitstruct.nphr         - phrase number 
% - twitstruct.fc           - center frequency 					(Hz)
% - twitstruct.bw           - mean mid-phrase bandwidth         (Hz)
% - twitstruct.IPI          - mean inter-phrase interval        (sec)
% - twitstruct.tphr         - mean phrase sweep time            (sec)  
% - twitstruct.tknee        - mean time fraction of knee        ([0,1])
% - twitstruct.fknee        - mean freq fraction of knee		([0,1])
% - twitstruct.rAttn        - harmonic attenuation 				(dB)
% - twitstruct.snr          - Signal-to-Noise Ratio             (dB)
% - twitstruct.bpbw         - noise bandwidth                   (oct)           
% - twitstruct.seed         - psuedo random seed 
% - twitstruct.opt.ord      - phrase order   (0: normal, 1: reversed)
% - twitstruct.opt.noam     - AM mod         (0: normal, 1: flat AM)
% - twitstruct.opt.chop     - phrase chop    (0: normal, 1: before knee only, 
%                                             2: after knee only)
% - twitstruct.cont         - multi-phrase source (1: count from beginning,
%                                                  2: replicate mid phrase)  
% - twitstruct.phr1         - one-phrase source   (1: 1st, 2: mid, 3: last) 

% ================== analysis_type & analysis_code =======================
% - 2301~2400 in chammber 2 and 3

% ========================================================================

%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VirtualCall_OpeningFcn, ...
                   'gui_OutputFcn',  @VirtualCall_OutputFcn, ...
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
%% End initialization code - DO NOT EDIT

% ====================== Set Up Default =================================
% To set up basic call structure and system parameters
function VirtualCall_OpeningFcn(hObject, ~, handles, varargin)

% Choose default command line output for VirtualCall
handles.output = hObject;

% Initialize variables
global Tone_struct Phee_struct Trill_struct TrillPhee_struct Twit_struct

% Load plain signals and call structures
load TONE 
Tone_struct = trillstruct;

load PHEE
Phee_struct = trillstruct;

load TRILL
Trill_struct = trillstruct;

load TRILL_PHEE
TrillPhee_struct = trillstruct;

load TWIT
Twit_struct = twitstruct;

% Set default basic information to Tone while opening this GUI
handles.callstruct = Tone_struct; 

handles.type = 1;             % 1: Complex Tone 
                              % 2: Phee; 3: Trill; 4: Trillphee; 5: Twitter

handles.SR = 97656.25;        % sampling rate (97.656 kHz for chamber 3 TDT) 
handles.attenuation = 50;     % attenuation default as 50 dB
handles.contourF = 4;         % mean of contour oscillation frequency
handles.contourFstd = 1;      % std of contour oscillation frequency
handles.amrate_scalar = 1;    % assume AM rate variable is scalar
handles.fmrate_scalar = 1;    % assume FM rate variable is scalar

load_parameters(hObject, handles);

% Update handles structure
guidata(hObject, handles);


% ====================== Load Parameters ================================
% To set up basic parameters for each call type in GUI
function load_parameters(~, handles) 
if handles.type < 5 % TONE, PHEE, TRILL, TRILL_PHEE
    % Basic
    set(handles.CF,'String', num2str(handles.callstruct.fc/1000, 4));        % kHz
    set(handles.Attn,'String', num2str(handles.attenuation));                % dB
    set(handles.Dur,'String', num2str(handles.callstruct.dur*1000, 4));      % msec

    % Harmonic
    set(handles.order,'String', num2str(handles.callstruct.order, 4));       % kHz
    set(handles.HBW,'String', num2str(handles.callstruct.hbw, 4));           % oct
    set(handles.rAttn,'String', num2str(handles.callstruct.rAttn, 4));       % dB

    % Noise
    set(handles.SNR,'String', num2str(handles.callstruct.snr));              % dB
    set(handles.BPBW,'String', num2str(handles.callstruct.bpbw, 4));         % oct
    set(handles.Seed,'String', num2str(handles.callstruct.seed));
    
    % FM
    set(handles.fm_mod,'String', num2str(handles.callstruct.fm1mod, 4));     % Hz
    set(handles.fm_rate,'String', num2str(handles.callstruct.fm1_rate, 4));  % Hz
    set(handles.fm_depth,'String', num2str(handles.callstruct.fm1_depth, 4));% Hz
    set(handles.tTrans,'String', num2str(handles.callstruct.trans, 4));      % 0~1   
    	
    % AM
    set(handles.am_mod,'String', num2str(handles.callstruct.am1mod, 4));     % 0~1
    set(handles.am_rate,'String', num2str(handles.callstruct.am1_rate, 4));  % Hz
    set(handles.am_depth,'String', num2str(handles.callstruct.am1_depth, 4));% 0~1
    	
    % RMS
    set(handles.rms, 'String', '');
    
    % Dur
    set(handles.durshow, 'String', '');
     
    % Visible
    obj_edit = findobj('Tag','NPhr','-or','Tag','IPI','-or','Tag','tPhr');
    obj_edit2 = findobj('Tag','order', '-or', 'Tag', 'HBW','-or','Tag','Dur');
    obj_edit3 = findobj('Tag','fm_mod','-or','Tag','am_mod','-or','Tag','am_rate', '-or', 'Tag', 'am_depth');
    obj_text = findobj('Tag','NPhr_text','-or','Tag','IPI_text','-or','Tag','tPhr_text');
    obj_text2 = findobj('Tag','order_text', '-or', 'Tag', 'bw_text','-or','Tag','Dur_text');
    obj_text3 = findobj('Tag','fm_mod_text','-or','Tag','am_mod_text','-or','Tag','am_rate_text', '-or', 'Tag', 'am_depth_text');
    obj_text4 = findobj('Tag','bwPhr_text', '-or', 'Tag', 'fKnee_text','-or', 'Tag', 'tKnee_text');
    obj_button = findobj('Tag','fm_const', '-or', 'Tag', 'fm_rand','-or', 'Tag', 'am_const','-or', 'Tag', 'am_rand');
    obj_button2 = findobj('Tag','revphr', '-or', 'Tag', 'amflat','-or', 'Tag', 'chopbk','-or', 'Tag', 'chopak');
    obj_check = findobj('Tag','rate_covary');
    set(obj_edit,'Visible','off');
    set(obj_text,'Visible','off');
    set(obj_text4,'Visible','off');
    set(obj_button2, 'Visible','off');
    set(obj_edit2,'Visible','on');
    set(obj_edit3,'Visible','on');
    set(obj_text2,'Visible','on');
    set(obj_text3,'Visible','on');
    set(obj_button,'Visible','on');
    set(obj_check,'Visible','on');
    
else % TWIT
    % Basic
    set(handles.CF,'String', num2str(handles.callstruct.fc/1000, 4));        % kHz
    set(handles.Attn,'String', num2str(handles.attenuation));                % dB
    set(handles.Dur,'String', num2str(handles.callstruct.dur*1000, 4));      % msec
    set(handles.IPI,'String', num2str(handles.callstruct.IPI*1000, 4));      % msec
    set(handles.tPhr,'String', num2str(handles.callstruct.tphr*1000, 4));    % msec   
    set(handles.NPhr,'String', num2str(handles.callstruct.nphr));

    % Harmonic
    set(handles.rAttn,'String', num2str(handles.callstruct.rAttn, 4));       % dB
    
    % Noise
    set(handles.SNR,'String', num2str(handles.callstruct.snr));              % dB
    set(handles.BPBW,'String', num2str(handles.callstruct.bpbw, 4));         % oct
    set(handles.Seed,'String', num2str(handles.callstruct.seed));
    
    % FM
    set(handles.tTrans,'String', num2str(handles.callstruct.tknee, 4));      % 0~1  
    set(handles.fm_depth,'String', num2str(handles.callstruct.fknee, 4));    % 0~1
    set(handles.fm_rate,'String', num2str(handles.callstruct.bw, 4));        % Hz
    
    % RMS
    set(handles.rms, 'String', '');
    
    % Dur
    set(handles.durshow, 'String', '');                                      % msec
    
    % Visible
    obj_edit = findobj('Tag','NPhr','-or','Tag','IPI','-or','Tag','tPhr');
    obj_edit2 = findobj('Tag','order', '-or', 'Tag', 'HBW','-or','Tag','Dur');
    obj_edit3 = findobj('Tag','fm_mod','-or','Tag','am_mod','-or','Tag','am_rate', '-or', 'Tag', 'am_depth');
    obj_text = findobj('Tag','NPhr_text','-or','Tag','IPI_text','-or','Tag','tPhr_text');
    obj_text2 = findobj('Tag','order_text', '-or', 'Tag', 'bw_text','-or','Tag','Dur_text');
    obj_text3 = findobj('Tag','fm_mod_text','-or','Tag','am_mod_text','-or','Tag','am_rate_text', '-or', 'Tag', 'am_depth_text');
    obj_text4 = findobj('Tag','bwPhr_text', '-or', 'Tag', 'fKnee_text','-or', 'Tag', 'tKnee_text');
    obj_button = findobj('Tag','fm_const', '-or', 'Tag', 'fm_rand','-or', 'Tag', 'am_const','-or', 'Tag', 'am_rand');
    obj_button2 = findobj('Tag','revphr', '-or', 'Tag', 'amflat','-or', 'Tag', 'chopbk','-or', 'Tag', 'chopak');
    obj_check = findobj('Tag','rate_covary');
    set(obj_edit,'Visible','on');
    set(obj_text,'Visible','on');
    set(obj_text4,'Visible','on');
    set(obj_button2, 'Visible','on');
    set(obj_edit2,'Visible','off');
    set(obj_edit3,'Visible','off');
    set(obj_text2,'Visible','off');
    set(obj_text3,'Visible','off');
    set(obj_button,'Visible','off');
    set(obj_check,'Visible','off');
    
end

% Turn off all selections except default 
off = findobj('Style','radiobutton','-or','Style','checkbox');
set(off,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
set(off,'Value',0);
set(handles.fm_const,'Value',1); 
set(handles.am_const,'Value',1);

% ====================== Set Up Output ==================================
% To get default command line output from handles structure
function varargout = VirtualCall_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


% ====================== CallType Menu ==================================
% To create different GUI appearnce for different call type selection
function CallType_Callback(hObject, ~, handles)

% Initialize variables
global Tone_struct Phee_struct Trill_struct TrillPhee_struct Twit_struct

% Visible set up for different call types
handles.type = get(hObject,'Value');
switch handles.type
    case 1 % Tone
        handles.callstruct = Tone_struct; 
        load_parameters(hObject, handles);
        set(handles.tKnee_text, 'Visible', 'off');
        set(handles.tTrans_text, 'Visible', 'off');
        set(handles.tTrans, 'Visible', 'off');
        set(handles.fm_mod_text, 'Visible', 'off');
        set(handles.fm_mod, 'Visible', 'off');
        set(handles.fm_depth_text, 'Visible', 'off');
        set(handles.fm_const, 'Visible', 'off');
        set(handles.fm_rand, 'Visible', 'off');
        set(handles.am_const, 'Visible', 'off');
        set(handles.am_rand, 'Visible', 'off');
        set(handles.am_mod_text, 'Visible', 'off');
        set(handles.am_mod, 'Visible', 'off');
        set(handles.tone_fm_depth_text, 'Visible', 'on');
        set(handles.scale_notice2, 'Visible', 'on');
		set(handles.fm_rate, 'Enable', 'on');
		set(handles.fm_depth, 'Enable', 'on');
		set(handles.am_rate, 'Enable', 'on');
		set(handles.am_depth, 'Enable', 'on');
                
    case 2 % Phee
        handles.callstruct = Phee_struct; 
        load_parameters(hObject, handles);
        set(handles.tKnee_text, 'Visible', 'off');
        set(handles.tTrans_text, 'Visible', 'off');
        set(handles.tTrans, 'Visible', 'off');
		set(handles.fm_depth_text, 'Visible', 'on');
        set(handles.tone_fm_depth_text, 'Visible', 'off');
        set(handles.scale_notice2, 'Visible', 'off');
		set(handles.fm_rate, 'Enable', 'off');
		set(handles.fm_depth, 'Enable', 'off');
		set(handles.am_rate, 'Enable', 'off');
		set(handles.am_depth, 'Enable', 'off');
    
    case 3 % Trill
        handles.callstruct = Trill_struct; 
        load_parameters(hObject, handles);
        set(handles.tKnee_text, 'Visible', 'off');
        set(handles.tTrans_text, 'Visible', 'off');
        set(handles.tTrans, 'Visible', 'off');
        set(handles.fm_depth_text, 'Visible', 'on');
        set(handles.tone_fm_depth_text, 'Visible', 'off');
        set(handles.scale_notice2, 'Visible', 'off');
		set(handles.fm_rate, 'Enable', 'on');
		set(handles.fm_depth, 'Enable', 'on');
		set(handles.am_rate, 'Enable', 'on');
		set(handles.am_depth, 'Enable', 'on');
    
    case 4 % Trillphee
        handles.callstruct = TrillPhee_struct; 
        load_parameters(hObject, handles);
        set(handles.tKnee_text, 'Visible', 'off');
        set(handles.tTrans_text, 'Visible', 'on');
        set(handles.tTrans, 'Visible', 'on');
        set(handles.fm_depth_text, 'Visible', 'on');
        set(handles.tone_fm_depth_text, 'Visible', 'off');
		set(handles.fm_rate, 'Enable', 'on');
		set(handles.fm_depth, 'Enable', 'on');
		set(handles.am_rate, 'Enable', 'on');
		set(handles.am_depth, 'Enable', 'on');
        
    case 5 % Twitter
        handles.callstruct = Twit_struct; 
        load_parameters(hObject, handles);
        set(handles.tKnee_text, 'Visible', 'on');
        set(handles.tTrans, 'Visible', 'on');
        set(handles.tTrans_text, 'Visible', 'off');
        set(handles.scale_notice2, 'Visible', 'off');
		set(handles.fm_rate, 'Enable', 'on');
		set(handles.fm_depth, 'Enable', 'on');
		set(handles.am_rate, 'Enable', 'on');
		set(handles.am_depth, 'Enable', 'on');
    
    otherwise
        return        
end

% Update handles structure
guidata(hObject, handles);

function CallType_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== CF Edit ========================================
% To set center frequency of vocalization (for all calls)
function CF_Callback(hObject, ~, handles)

% Get CF value given by user
str = get(hObject,'String');
[logscale, fstart, fend, pts] = logscale_check(str);

% Check whether str is given in log or linear scale
switch logscale
    case 0 % linear or scalar
        data = eval(str)*1000; % convert kHz to Hz
        if (min(data)<=0 || max(data)>=(handles.SR/2)) 
            disp('*** CF Out of Bounds ***'); beep;
            set(hObject,'String', num2str(handles.callstruct.fc/1000, 4));
        else
            handles.callstruct.fc = data;
            set(hObject,'String', str);
        end
        
    case 1 % octave
        if (fstart<=0 || fend>=(handles.SR/2)) 
            disp('*** CF Out of Bounds ***'); beep;
            set(hObject,'String', num2str(handles.callstruct.fc/1000, 4));
        else
            fspaced = octspace(fstart, fend, pts);
            handles.callstruct.fc = fspaced*1000; % convert kHz to Hz
            set(hObject,'String', str);
        end
        
    otherwise
        return
end

% Update handles structure
guidata(hObject, handles);

function CF_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== Attn Edit ======================================
% To set atteunation of vocalization (for all calls)
function Attn_Callback(hObject, ~, handles)

% Get Attn value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str);
        
if min(data) < 0
    disp('*** Attn Out of Bounds ***'); beep;
    set(hObject,'String', num2str(handles.attenuation));
else
    handles.attenuation = data;
    set(hObject,'String', str);
end

% Update handles structure
guidata(hObject, handles);

function Attn_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== Dur Edit =======================================
% To set duration of vocalization (for narrowband calls)
function Dur_Callback(hObject, ~, handles)

% Get Dur value given by user
str = get(hObject,'String');
[logscale, durstart, durend, pts] = logscale_check(str);

% Check whether str is given in log or linear scale
switch logscale
    case 0 % linear or scalar
        data = eval(str)/1000; % convert msec to sec
        if min(data) < 0.01
            disp('*** Dur Out of Bounds ***'); beep;
            set(hObject,'String', num2str(handles.callstruct.dur*1000, 4));
        else
            handles.callstruct.dur = data;
            set(hObject,'String', str);
        end
        
    case 1 % octave
        if durstart < 0.01
            disp('*** Dur Out of Bounds ***'); beep;
            set(hObject,'String', num2str(handles.callstruct.dur*1000, 4));
        else
            durspaced = octspace(durstart, durend, pts);
            handles.callstruct.dur = durspaced/1000; % convert msec to sec
            set(hObject,'String', str);
        end
        
    otherwise
        return
end

% Update handles structure
guidata(hObject, handles)

function Dur_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== NPhr Edit =======================================
% To set number of phrases of vocalization (for twitter)
function NPhr_Callback(hObject, ~, handles)

% Get NPhr value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = floor(eval(str));  

if min(data) < 0
    disp('*** NPhr Out of Bounds ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.nphr));
else
    handles.callstruct.nphr = data;
    set(hObject,'String', str);    
end

% Update handles structure
guidata(hObject, handles);

function NPhr_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== IPI Edit =======================================
% To set inter-phrase interval of vocalization (for twitter)
function IPI_Callback(hObject, ~, handles)

% Get IPI value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str)/1000; % convert msec to sec

if min(data) < 0
    disp('*** IPI Out of Bounds ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.IPI*1000, 4));     
else
    handles.callstruct.IPI = data;
    set(hObject,'String', str);    
end

% Update handles structure
guidata(hObject, handles)

function IPI_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== tPhr Edit ======================================
% To set phrase sweep time of vocalization (for twitter)
function tPhr_Callback(hObject, ~, handles)

% Get tPhr value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str)/1000; % convert msec to sec

if min(data) <= 0
    disp('*** tPhr Out of Bounds ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.tphr*1000, 4));    
else
    handles.callstruct.tphr = data;
    set(hObject,'String', str);   
end

% Update handles structure
guidata(hObject, handles)

function tPhr_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== order Edit =====================================
% To set harmonic order of vocalization (ratio of fc to f0) (for all calls)
function order_Callback(hObject, ~, handles)

% Get order value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str); 

if (min(data)<1 || max(data)<0) 
    disp('*** f0 Out of Bounds ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.order));    
else
    handles.callstruct.order = data;
    set(hObject,'String', str);    
end

% Update handles structure
guidata(hObject, handles);

function order_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== HBW Edit ========================================
% To set harmonic bandwidth of vocalization (symmetrical and centered at fc) (for all calls)
function HBW_Callback(hObject, ~, handles)

% Get HBW value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str);

if min(data) <= 0
    disp('*** bw Out of Bounds ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.hbw));    
else
    handles.callstruct.hbw = data;
    set(hObject,'String', str);    
end

% Update handles structure
guidata(hObject, handles);

function HBW_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== rAttn Edit =====================================
% To set harmonic atteunation of vocalization (amplitude ratio of fn to f0) (for all calls)
function rAttn_Callback(hObject, ~, handles)

% Get rAttn value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str); 

if max(data) > 0
    disp('*** Harmonic level too loud ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.rAttn, 4));    
else
    handles.callstruct.rAttn = data;      
    handles.callstruct.A2A1 = 10.^(data./20); % convert dB to amp ratio
    set(hObject,'String', str);
end

guidata(hObject, handles)

function rAttn_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== SNR Edit =======================================
% To set SNR of background band-passed noise to vocalization  (for all calls)
function SNR_Callback(hObject, ~, handles)

% Get SNR value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str);

if min(data) < 0
    disp('*** Noise too loud ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.snr));
else
    handles.callstruct.snr = data;
    set(hObject,'String', str);
end

% Update handles structure
guidata(hObject, handles);

function SNR_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== BPBW Edit ======================================
% To set bandwidth of background band-passed noise (centered at fc) (for all calls)
function BPBW_Callback(hObject, ~, handles)

% Get BPBW value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str);

if min(data) < 0
    disp('*** BPBW Out of Bounds ***'); beep;
    set(hObject,'String', num2str(handles.callstruct.bpbw));
else
    handles.callstruct.bpbw = data;
    set(hObject,'String', str);
end

% Update handles structure
guidata(hObject, handles);

function BPBW_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== Seed Edit ======================================
% To set seed for pseduo random generator for noise, AM, FM contours (for all calls)
function Seed_Callback(hObject, ~, handles)

% Get Seed value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = floor(eval(str));

if min(data) <= 0
    disp('*** Seed has to be positive'); beep;
    set(hObject,'String', num2str(handles.callstruct.seed));
else
    handles.callstruct.seed = data;
    set(hObject,'String', str);
end

guidata(hObject, handles)

function Seed_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== fm_mod Edit ====================================
% To set slow sinusoidal FM rate of vocalization (for narrowband calls)
function fm_mod_Callback(hObject, ~, handles)

% Get fm_mod value given by user
str = get(hObject,'String');
[logscale, fmmodstart, fmmodend, pts] = logscale_check(str);

% Check whether str is given in log or linear scale
switch logscale
    case 0 % linear or scalar
        data = eval(str);
        if min(data) < 0
            disp('*** fm_mod Out of Bounds'); beep;
            set(hObject,'String', num2str(handles.callstruct.fm1mod, 4));    
        else
            handles.callstruct.fm1mod = data;
            handles.callstruct.fm2mod = 2*data;
            handles.callstruct.FM1_back_copy = handles.callstruct.FM1_back;
            handles.callstruct.FM2_back_copy = handles.callstruct.FM2_back;
            set(hObject,'String', str);
        end
        
    case 1 % octave
        if fmmodstart < 0
            disp('*** fm_mod Out of Bounds'); beep;
            set(hObject,'String', num2str(handles.callstruct.fm1mod, 4));
        else
            fmmodspaced = outspace(fmmodstart, fmmodend, pts);
            handles.callstruct.fm1mod = fmmodspaced;
            handles.callstruct.fm2mod = 2*fmmodspaced;
            handles.callstruct.FM1_back_copy = handles.callstruct.FM1_back;
            handles.callstruct.FM2_back_copy = handles.callstruct.FM2_back;
            set(hObject,'String', str);
        end
        
    otherwise
        return
end
% Update handles structure
guidata(hObject, handles);

function fm_mod_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== fm_rate Edit ===================================
% To set fast sinusoidal FM rate of vocalization (for narrowband calls)
% To set mean phrase bandwidth of vocalization (for twitter) 
function fm_rate_Callback(hObject, ~, handles)

% Get fm_rate value given by user (for narrowband calss)
% Get bw value given by user (for twitter)
str = get(hObject,'String');
[logscale, fmratestart, fmrateend, pts] = logscale_check(str);

% Condition for different call types
if handles.type < 5 % narrowband calls
    % Check whether str is given in log or linear scale
    switch logscale
        case 0 % linear or scalar
            data = eval(str);
            if min(data) < 0 
                disp('*** fm_rate Out of Bounds'); beep;
                set(hObject,'String', num2str(handles.callstruct.fm1_rate, 4));   
            else
                handles.callstruct.fm1_rate = data;
                handles.callstruct.fm2_rate = data;
                if length(data) > 1, handles.fmrate_scalar = 0;
                else handles.fmrate_scalar = 1; end
                set(hObject,'String', str);   
            end

        case 1 % octave
            if fmratestart < 0
                disp('*** fm_rate Out of Bounds'); beep;
                set(hObject,'String', num2str(handles.callstruct.fm1_rate, 4));
            else
                fmratespaced = octspace(fmratestart, fmrateend, pts);
                handles.callstruct.fm1_rate = fmratespaced;
                handles.callstruct.fm2_rate = fmratespaced;
                handles.fmrate_scalar = 0;
                set(hObject,'String', str);
            end

        otherwise
            return
    end
    
else % twitter
    data = eval(str);
    if min(data) < 0 
        disp('*** bwphr Out of Bounds'); beep;
        set(hObject,'String', num2str(handles.callstruct.bw, 4));   
    else
        handles.callstruct.bw = data;
        set(hObject,'String', str);    
    end
end

% Update handles structure
guidata(hObject, handles);

function fm_rate_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== fm_depth Edit ==================================
% To set fast sinusoidal FM depth of vocalization (for narrowband calls)
% To set knee frequency of vocalization (for twitter) 
function fm_depth_Callback(hObject, ~, handles)

% Get fm_depth value given by user (only scalar or linear scale for Trill/Phee/Trillphee)
% You can have linear or octave scale choice for fm_depth (only for Tone)
% Get fknee value given by user (for twitter)
str = get(hObject,'String');
[octscale, depth_oct] = octscale_check(str);

% Condition for different call types
if handles.type < 5 % narrowband calls
    % Check whether str is given in log or linear scale
    switch octscale
        case 0 % linear
            data = eval(str);
            if min(data) < 0
                disp('*** fm_depth Out of Bounds'); beep;
                set(hObject,'String', num2str(handles.callstruct.fm1_depth, 4));f
            else
                handles.callstruct.fm1_depth = data;
                handles.callstruct.fm2_depth = 2*data;
                handles.callstruct.fmdepth_oct = 0;
                set(hObject,'String', str);   
            end

        case 1 % octave
            data = depth_oct;
            if depth_oct < 0;
                disp('*** fm_depth Out of Bounds'); beep;
                set(hObject,'String', num2str(handles.callstruct.fm1_depth, 4));
            else
                handles.callstruct.fm1_depth = data;
                handles.callstruct.fm2_depth = 2*data;
                handles.callstruct.fmdepth_oct = 1;
                set(hObject,'String', str);   
            end
    end
    
else % twitter
    data = eval(str);
    if min(data) < 0 
        disp('*** fknee Out of Bounds'); beep;
        set(hObject,'String', num2str(handles.callstruct.fknee, 4));   
    else
        handles.callstruct.fknee = data;
        set(hObject,'String', str);    
    end
end

% Update handles structure
guidata(hObject, handles);

function fm_depth_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== tTrans Edit ====================================
% To set time of transition of vocalization (for narrowband calls)
% To set time of knee of vocalization (for twitter) 
function tTrans_Callback(hObject, ~, handles)

% Get tTrans value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str); 

% Condition for different call types
if handles.type < 5 % narrowband calls
    if (min(data)<0 || max(data)>1)
        disp('*** tTran Out of Bounds ***'); beep;
        set(hObject,'String', num2str(handles.callstruct.trans, 4));    
    else
        handles.callstruct.trans = data;
        set(hObject,'String', str);    
    end
    
else % twitter
    if (min(data)<0 || max(data)>1)
        disp('*** tknee Out of Bounds ***'); beep;
        set(hObject,'String', num2str(handles.callstruct.tknee, 4));    
    else
        handles.callstruct.tknee = data;
        set(hObject,'String', str);    
    end    
end
% Update handles structure
guidata(hObject, handles);

function tTrans_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== am_mod Edit ====================================
% To set slow sinusoidal AM rate of vocalization (for narrowband calls)
function am_mod_Callback(hObject, ~, handles)

% Get am_mod value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str);

if (min(data)<0 || max(data)>1)
    disp('*** am_mod Out of Bounds'); beep;
    set(hObject,'String', num2str(handles.callstruct.am1mod, 4));    
else
    handles.callstruct.am1mod = data;
    handles.callstruct.am2mod = data;
    handles.callstruct.AM1_back_copy = handles.callstruct.AM1_back;
    handles.callstruct.AM2_back_copy = handles.callstruct.AM2_back;
    set(hObject,'String', str);
end

% Update handles structure
guidata(hObject, handles);

function am_mod_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== am_rate Edit ===================================
% To set fast sinusoidal AM rate of vocalization (for narrowband calls)
function am_rate_Callback(hObject, ~, handles)

% Get am_rate value given by user
str = get(hObject,'String');
[logscale, amratestart, amrateend, pts] = logscale_check(str);

 % Check whether str is given in log or linear scale
switch logscale
    case 0 % linear or scalar
        data = eval(str);
        if min(data) < 0 
            disp('*** am_rate Out of Bounds'); beep;
            set(hObject,'String', num2str(handles.callstruct.am1_rate, 4));   
        else                                
            handles.callstruct.am1_rate = data;
            handles.callstruct.am2_rate = data;
            if length(data) > 1, handles.amrate_scalar = 0; 
            else handles.amrate_scalar = 1; end
            set(hObject,'String', str);
        end
        
    case 1 % octave
        if amratestart < 0
            disp('*** am_rate Out of Bounds'); beep;
            set(hObject,'String', num2str(handles.callstruct.am1_rate, 4));
        else     
            amratespaced = octspace(amratestart, amrateend, pts);
            handles.callstruct.am1_rate = amratespaced;
            handles.callstruct.am2_rate = amratespaced;
            handles.amrate_scalar = 0;
            set(hObject,'String', str);
        end
        
    otherwise
        return
end

% Update handles structure
guidata(hObject, handles);

function am_rate_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== am_depth Edit ==================================
% To set fast sinusoidal AM depth of vocalization (for narrowband calls)
function am_depth_Callback(hObject, ~, handles)

% Get am_depth value given by user (only scalar or linear scale)
str = get(hObject,'String');
data = eval(str);

if (min(data)<0 || max(data)>1)
    disp('*** am_depth Out of Bounds'); beep;
    set(hObject,'String', num2str(handles.callstruct.am1_depth, 4));
else
    handles.callstruct.am1_depth = data;
    handles.callstruct.am2_depth = data;
    set(hObject,'String', str);   
end

% Update handles structure
guidata(hObject, handles);

function am_depth_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== rms Edit =======================================
% To show root-mean-square of overall signals (for all calls)
function rms_Callback(~, ~, ~)

function rms_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== durshow Edit =======================================
% To show duration of vocalization (for twitter)
function durshow_Callback(hObject, eventdata, handles)

function durshow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================== FM/AM Rate Covary Checkbox =====================
% Checkbox to set whether FM rate and AM rate co-vary
% Used only when one of the variables (FM rate or AM rate) is a vector
% Directly set the other scalar variable to the same vector  
function rate_covary_Callback(hObject, ~, handles)

    % Both scalar or both vector cannot use this covary function
    if (handles.fmrate_scalar==1 && handles.amrate_scalar==1)
        set(hObject,'Value',1);
        
    elseif (handles.fmrate_scalar==0 && handles.amrate_scalar==0)
        set(hObject,'Value',0);
    end

rate_covary = get(handles.rate_covary, 'Value');

% Co-vary FM and AM rate depends on which is vector
if (rate_covary==1 && handles.fmrate_scalar==1) % AM vector
    str = get(handles.am_rate,'String');
    set(handles.fm_rate,'String', str);
    handles.callstruct.fm1_rate = handles.callstruct.am1_rate;
    handles.callstruct.fm2_rate = handles.callstruct.am2_rate;
    
elseif (rate_covary==1 && handles.amrate_scalar==1) % FM vector
    str = get(handles.fm_rate,'String');
    set(handles.am_rate,'String', str);
    handles.callstruct.am1_rate = handles.callstruct.fm1_rate;
    handles.callstruct.am2_rate = handles.callstruct.fm2_rate;
end

guidata(hObject, handles)


% ====================== FM Const Radio Button ==========================
% Button to set FM contour same as default
% Cannot choose FM Const and FM Rand buttons simultaneously
function fm_const_Callback(hObject, ~, handles)

% Mutual exclude radiobutton choice
off = handles.fm_rand;
set(off,'Value',0);
set(off,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
set(hObject,'Value',1);

% Get original bkfm
handles.callstruct.FM1_back = handles.callstruct.FM1_back_copy;
handles.callstruct.FM2_back = handles.callstruct.FM2_back_copy;
handles.callstruct.FM1_back_copy = handles.callstruct.FM1_back;
handles.callstruct.FM2_back_copy = handles.callstruct.FM2_back;

guidata(hObject, handles)


% ====================== FM Rand Radio Button ===========================
% Button to set FM contour (BetaFM1 = FM1_back) to be r.v. ~ uniform [0, 1]
% bFM1 would be r.v. ~ uniform [fc - 0.5*fm1mod, fc + 0.5*fm1mod]
% Cannot choose FM Const and FM Rand buttons simultaneously
function fm_rand_Callback(hObject, ~, handles)

% mutual exclude radiobutton choice
off = [handles.fm_const, handles.am_rand];
set(off,'Value',0);
set(off,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
set(hObject,'Value',1); 

guidata(hObject, handles)


% ====================== AM Const Radio Button ==========================
% Button to set AM contour same as default
% Cannot choose AM Const and AM Rand buttons simultaneously
function am_const_Callback(hObject, ~, handles)

% Mutual exclude radiobutton choice
off = handles.am_rand;
set(off,'Value',0);
set(off,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
set(hObject,'Value',1);

% Get original bkam
handles.callstruct.AM1_back = handles.callstruct.AM1_back_copy;
handles.callstruct.AM2_back = handles.callstruct.AM2_back_copy;
handles.callstruct.AM1_back_copy = handles.callstruct.AM1_back;
handles.callstruct.AM2_back_copy = handles.callstruct.AM2_back;

guidata(hObject, handles)


% ====================== AM Rand Radio Button ===========================
% Button to set AM contour (bAM1 = AM1_back) to be r.v. ~ uniform [0, 1]
% Cannot choose AM Const and AM Rand buttons simultaneously
function am_rand_Callback(hObject, ~, handles)

% Mutual exclude radiobutton choice
off = [handles.am_const, handles.fm_rand];
set(off,'Value',0);
set(off,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
set(hObject,'Value',1); 

guidata(hObject, handles)
 

% ====================== Rev Time Radio Button =========================
% To reverse time for both frequency and amplitude together 
function revtime_Callback(hObject, eventdata, handles)

guidata(hObject, handles)


% ====================== Rev Phrase Radio Button ========================
% To reverse twitter phrase order 
function revphr_Callback(hObject, eventdata, handles)

guidata(hObject, handles)


% ====================== Chop Before Knee Radio Button ====================
% Button to chop twitter phrase to preserve before-knee part only 
% Cannot choose Chop Before Knee and Chop After Knee buttons simultaneously
function chopbk_Callback(hObject, eventdata, handles)

% Mutual exclude radiobutton choice
off = handles.chopak;
set(off,'Value',0);
set(off,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));

guidata(hObject, handles)


% ====================== Chop After Knee Radio Button ====================
% Button to chop twitter phrase to preserve after-knee part only 
% Cannot choose Chop Before Knee and Chop After Knee buttons simultaneously
function chopak_Callback(hObject, eventdata, handles)

% Mutual exclude radiobutton choice
off = handles.chopbk;
set(off,'Value',0);
set(off,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));

guidata(hObject, handles)


% ====================== AM Flat Radio Button ========================
% Button to set each AM twitter phrase flat without modulation
function amflat_Callback(hObject, eventdata, handles)

guidata(hObject, handles)


% ====================== Plot Button ====================================
% Button to show spectrograms of the synthesized calls on GUI 
function plot_button_Callback(hObject, ~, ~)

% Global parameters for xblaster 
global temp_callstruct

h = findobj('Tag','VirtualCall_figure');
handles = guidata(h);

% Generate stimuli
temp_callstruct = handles.callstruct;            % template structure
rate_covary = get(handles.rate_covary, 'Value'); % AM/FM rate covary check
modtype = ModType_check(handles);                % modulation type assign
SR = handles.SR;                                 % sampling rate 

% Onset and Offset ramp (5 msec each)
ramp = 5/1000; 
t_on = 0:1/SR:ramp;
t_off = 0:1/SR:ramp;
on_ramp = (1-cos((2*pi*t_on)./(2*ramp)))/2;
off_ramp = fliplr((1-cos((2*pi*t_off)./(2*ramp)))/2);

% Call type synthesis
if handles.type < 5 % TONE PHEE TRILL TRILL_PHEE
    
    % Get stimulus parameter length
    lcf = length(handles.callstruct.fc);
    lattn = length(handles.attenuation);
    ldur = length(handles.callstruct.dur);
    lorder = length(handles.callstruct.order);
    lbw = length(handles.callstruct.hbw);
    lrattn = length(handles.callstruct.rAttn);
    lsnr = length(handles.callstruct.snr);
    lbpbw = length(handles.callstruct.bpbw);
    lseed = length(handles.callstruct.seed);
    lfmmod = length(handles.callstruct.fm1mod);
    lfmrate = length(handles.callstruct.fm1_rate);
    lfmdepth = length(handles.callstruct.fm1_depth);   
    lttrans = length(handles.callstruct.trans);
    lammod = length(handles.callstruct.am1mod);
    lamdepth = length(handles.callstruct.am1_depth);   
    lamrate = length(handles.callstruct.am1_rate);   

    % Get stimulus parameter sequence
    cf = 1:lcf; 
    attn = 1:lattn; 
    dur = 1:ldur;
    order = 1:lorder; 
    bw = 1:lbw; 
    rattn = 1:lrattn;
    snr = 1:lsnr; 
    bpbw = 1:lbpbw; 
    seed = 1:lseed;
    fmmod = 1:lfmmod; 
    fmrate = 1:lfmrate;
    fmdepth = 1:lfmdepth;
    ttrans = 1:lttrans;
    ammod = 1:lammod;
    amrate = 1:lamrate;
    amdepth = 1:lamdepth;
    
    % --------------------- FM/AM rates don't co-vary -------------------
    if rate_covary == 0
        
        % Stimulus parameter variable
        [s16 s15 s14 s13 s12 s11 s10 s9 s8 s7 s6 s5 s4 s3 s2 s1] = ndgrid(...
                  amdepth, amrate, ammod, ttrans, fmdepth, fmrate, fmmod, ...
                  seed, bpbw, snr, rattn, bw, order, dur, attn, cf);

        [stim] = [s1(:) s2(:) s3(:) s4(:) s5(:) s6(:) s7(:) s8(:) s9(:) ...
                  s10(:) s11(:) s12(:) s13(:) s14(:) s15(:) s16(:)];

        stim = stim'; idx = 1;

        % Generate each varying stimulus
        for stim_num = 1:size(stim, 2)
            temp_callstruct.fc = handles.callstruct.fc(stim(idx));               idx = idx + 1;
            temp_callstruct.attn = handles.attenuation(stim(idx));               idx = idx + 1;
            temp_callstruct.dur = handles.callstruct.dur(stim(idx));             idx = idx + 1;
            temp_callstruct.order = handles.callstruct.order(stim(idx));         idx = idx + 1;
            temp_callstruct.hbw = handles.callstruct.hbw(stim(idx));             idx = idx + 1;
            temp_callstruct.rAttn = handles.callstruct.rAttn(stim(idx));         idx = idx + 1;     
            temp_callstruct.snr = handles.callstruct.snr(stim(idx));             idx = idx + 1;
            temp_callstruct.bpbw = handles.callstruct.bpbw(stim(idx));           idx = idx + 1;
            temp_callstruct.seed = handles.callstruct.seed(stim(idx));           idx = idx + 1;
            temp_callstruct.fm1mod = handles.callstruct.fm1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.fm1_rate = handles.callstruct.fm1_rate(stim(idx));   idx = idx + 1;
            temp_callstruct.fm1_depth = handles.callstruct.fm1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.trans = handles.callstruct.trans(stim(idx));         idx = idx + 1;
            temp_callstruct.am1mod = handles.callstruct.am1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.am1_rate = handles.callstruct.am1_rate(stim(idx));   idx = idx + 1;
            temp_callstruct.am1_depth = handles.callstruct.am1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.A2A1 = 10^(temp_callstruct.rAttn/20);
            temp_callstruct.f0 = temp_callstruct.fc/temp_callstruct.order;
            temp_callstruct.fm2mod = 2*temp_callstruct.fm1mod;
            temp_callstruct.fm2_rate = temp_callstruct.fm1_rate; 
            temp_callstruct.fm2_depth = 2*temp_callstruct.fm1_depth; 
            temp_callstruct.am2mod = 2*temp_callstruct.am1mod;
            temp_callstruct.am2_rate = temp_callstruct.am1_rate; 
            temp_callstruct.am2_depth = temp_callstruct.am1_depth; 

            % fm_mod random button selected
            if modtype(2) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.FM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.FM2_back = temp_callstruct.FM1_back;
            end

            % am_mod random button selected
            if modtype(4) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.AM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.AM2_back = temp_callstruct.AM1_back;
            end
            
            % Reverse time or not
            revtime = get(handles.revtime, 'Value');
            temp_callstruct.rev = [revtime revtime];
            
            % Synthesize
            [y, rms, ~, ~] = narrow_synth(temp_callstruct, handles.type, SR);
            rms_str = num2str(rms, 4);

            % Add onset and offset ramp
            t = (0:length(y)-1)/SR;
            former_t = 1:length(on_ramp);
            latter_t = (length(t)-length(off_ramp)+1):length(t);
            y(former_t) = y(former_t).*on_ramp;
            y(latter_t) = y(latter_t).*off_ramp;

            % Plot on axes and show rms on GUI
            showit(t, y, handles); set(handles.rms, 'String', rms_str); 
            handles.y = y; pause(0.2);

            % Header info shown on command window
            header0 = ['CallType: '  num2str(handles.type)]; 
            header1 = ['. ModType: ' modtype];
            header2 = ['. Freq: '    num2str(temp_callstruct.fc/1000, 4)    ' (kHz)'];
            header3 = ['. Attn: '    num2str(temp_callstruct.attn)           ' (dB)'];
            header4 = ['. Dur: '     num2str(temp_callstruct.dur*1000, 4)  ' (msec)'];
            header5 = ['. f0: '      num2str(temp_callstruct.f0/1000, 4)    ' (kHz)'];
            header6 = ['. hBW: '     num2str(temp_callstruct.hbw)           ' (oct)'];
            header7 = ['. rAttn: '   num2str(temp_callstruct.rAttn)          ' (dB)'];
            header8 = ['. SNR: '     num2str(temp_callstruct.snr)            ' (dB)'];
            header9 = ['. bpBW: '    num2str(temp_callstruct.bpbw)          ' (oct)'];
            header10 = ['. Seed: '   num2str(temp_callstruct.seed)           ' (--)'];
            header11 = ['. mFM1: '   num2str(temp_callstruct.fm1mod, 4)      ' (Hz)'];
            header12 = ['. fFM1: '   num2str(temp_callstruct.fm1_rate, 4)    ' (Hz)'];
            header13 = ['. dFM1: '   num2str(temp_callstruct.fm1_depth, 4)   ' (Hz)'];
            header14 = ['. tTrans: ' num2str(temp_callstruct.trans, 4)      ' (0~1)'];
            header15 = ['. mAM1: '   num2str(temp_callstruct.am1mod, 4)     ' (0~1)'];
            header16 = ['. fAM1: '   num2str(temp_callstruct.am1_rate, 4)    ' (Hz)'];
            header17 = ['. dAM1: '   num2str(temp_callstruct.am1_depth, 4)  ' (0~1)'];

            header_b = strcat(header0, header1, header2, header3, header4);
            header_h = strcat(header5, header6, header7);
            header_n = strcat(header8, header9, header10);
            header_fm = strcat(header11, header12, header13, header14);
            header_am = strcat(header15, header16, header17);

            header = strcat(header_b, header_h, header_n, header_fm, header_am);
            disp(header);

        end
        
    % --------------------- FM/AM rates co-vary -------------------------
    else
        
        % Stimulus parameter variable
        [s15 s14 s13 s12 s11 s10 s9 s8 s7 s6 s5 s4 s3 s2 s1] = ndgrid(...
                  amdepth, ammod, ttrans, fmdepth, fmrate, fmmod, ...
                  seed, bpbw, snr, rattn, bw, order, dur, attn, cf);

        [stim] = [s1(:) s2(:) s3(:) s4(:) s5(:) s6(:) s7(:) s8(:) s9(:) ...
                  s10(:) s11(:) s12(:) s13(:) s14(:) s15(:)];

        stim = stim'; idx = 1;

        % Generate each varying stimulus
        for stim_num = 1:size(stim, 2)
            temp_callstruct.fc = handles.callstruct.fc(stim(idx));               idx = idx + 1;
            temp_callstruct.attn = handles.attenuation(stim(idx));               idx = idx + 1;
            temp_callstruct.dur = handles.callstruct.dur(stim(idx));             idx = idx + 1;
            temp_callstruct.order = handles.callstruct.order(stim(idx));         idx = idx + 1;
            temp_callstruct.hbw = handles.callstruct.hbw(stim(idx));             idx = idx + 1;
            temp_callstruct.rAttn = handles.callstruct.rAttn(stim(idx));         idx = idx + 1;     
            temp_callstruct.snr = handles.callstruct.snr(stim(idx));             idx = idx + 1;
            temp_callstruct.bpbw = handles.callstruct.bpbw(stim(idx));           idx = idx + 1;
            temp_callstruct.seed = handles.callstruct.seed(stim(idx));           idx = idx + 1;
            temp_callstruct.fm1mod = handles.callstruct.fm1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.fm1_rate = handles.callstruct.fm1_rate(stim(idx));   idx = idx + 1;
            temp_callstruct.fm1_depth = handles.callstruct.fm1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.trans = handles.callstruct.trans(stim(idx));         idx = idx + 1;
            temp_callstruct.am1mod = handles.callstruct.am1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.am1_depth = handles.callstruct.am1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.A2A1 = 10^(temp_callstruct.rAttn/20);
            temp_callstruct.f0 = temp_callstruct.fc/temp_callstruct.order;
            temp_callstruct.fm2mod = 2*temp_callstruct.fm1mod;
            temp_callstruct.fm2_rate = temp_callstruct.fm1_rate; 
            temp_callstruct.fm2_depth = 2*temp_callstruct.fm1_depth; 
            temp_callstruct.am2mod = 2*temp_callstruct.am1mod;
            temp_callstruct.am1_rate = temp_callstruct.fm1_rate;
            temp_callstruct.am2_rate = temp_callstruct.am1_rate; 
            temp_callstruct.am2_depth = temp_callstruct.am1_depth; 

            % fm_mod random button selected
            if modtype(2) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.FM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.FM2_back = temp_callstruct.FM1_back;
            end

            % am_mod random button selected
            if modtype(4) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.AM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.AM2_back = temp_callstruct.AM1_back;
            end
            
            % Reverse time or not
            revtime = get(handles.revtime, 'Value');
            temp_callstruct.rev = [revtime revtime];

            % Synthesize
            [y, rms, ~, ~] = narrow_synth(temp_callstruct, handles.type, SR);
            rms_str = num2str(rms, 4);

            % Add onset and offset ramp
            t = (0:length(y)-1)/SR;
            former_t = 1:length(on_ramp);
            latter_t = (length(t)-length(off_ramp)+1):length(t);
            y(former_t) = y(former_t).*on_ramp;
            y(latter_t) = y(latter_t).*off_ramp;

            % Plot on axes and show rms on GUI
            showit(t, y, handles); set(handles.rms, 'String', rms_str); 
            handles.y = y; pause(0.2);

            % Header info shown on command window
            header0 = ['CallType: '  num2str(handles.type)]; 
            header1 = ['. ModType: ' modtype];
            header2 = ['. Freq: '    num2str(temp_callstruct.fc/1000, 4)    ' (kHz)'];
            header3 = ['. Attn: '    num2str(temp_callstruct.attn)           ' (dB)'];
            header4 = ['. Dur: '     num2str(temp_callstruct.dur*1000, 4)  ' (msec)'];
            header5 = ['. f0: '      num2str(temp_callstruct.f0/1000, 4)    ' (kHz)'];
            header6 = ['. hBW: '     num2str(temp_callstruct.hbw)           ' (oct)'];
            header7 = ['. rAttn: '   num2str(temp_callstruct.rAttn)          ' (dB)'];
            header8 = ['. SNR: '     num2str(temp_callstruct.snr)            ' (dB)'];
            header9 = ['. bpBW: '    num2str(temp_callstruct.bpbw)          ' (oct)'];
            header10 = ['. Seed: '   num2str(temp_callstruct.seed)           ' (--)'];
            header11 = ['. mFM1: '   num2str(temp_callstruct.fm1mod, 4)      ' (Hz)'];
            header12 = ['. fFM1: '   num2str(temp_callstruct.fm1_rate, 4)    ' (Hz)'];
            header13 = ['. dFM1: '   num2str(temp_callstruct.fm1_depth, 4)   ' (Hz)'];
            header14 = ['. tTrans: ' num2str(temp_callstruct.trans, 4)      ' (0~1)'];
            header15 = ['. mAM1: '   num2str(temp_callstruct.am1mod, 4)     ' (0~1)'];
            header16 = ['. fAM1: '   num2str(temp_callstruct.am1_rate, 4)    ' (Hz)'];
            header17 = ['. dAM1: '   num2str(temp_callstruct.am1_depth, 4)  ' (0~1)'];

            header_b = strcat(header0, header1, header2, header3, header4);
            header_h = strcat(header5, header6, header7);
            header_n = strcat(header8, header9, header10);
            header_fm = strcat(header11, header12, header13, header14);
            header_am = strcat(header15, header16, header17);

            header = strcat(header_b, header_h, header_n, header_fm, header_am);
            disp(header);

        end
        
    end
    
% ------------------------- TWIT ----------------------------------------     
else % TWIT
    % Get stimulus parameter length
    lcf = length(handles.callstruct.fc);
    lattn = length(handles.attenuation);
    lnphr = length(handles.callstruct.nphr);
    lIPI = length(handles.callstruct.IPI);
    ltphr = length(handles.callstruct.tphr);
    lrattn = length(handles.callstruct.rAttn);
    lsnr = length(handles.callstruct.snr);
    lbpbw = length(handles.callstruct.bpbw);
    lseed = length(handles.callstruct.seed);
    lbw = length(handles.callstruct.bw);
    lfknee = length(handles.callstruct.fknee);
    ltknee = length(handles.callstruct.tknee);
    
    % Get stimulus parameter sequence
    cf = 1:lcf; 
    attn = 1:lattn; 
    nphr = 1:lnphr;
    IPI = 1:lIPI;
    tphr = 1:ltphr;
    rattn = 1:lrattn;
    snr = 1:lsnr; 
    bpbw = 1:lbpbw; 
    seed = 1:lseed;
    bw = 1:lbw;
    fknee = 1:lfknee;
    tknee = 1:ltknee;
    
    % Stimulus parameter variable
    [s12 s11 s10 s9 s8 s7 s6 s5 s4 s3 s2 s1] = ndgrid(...
        tknee, fknee, bw, seed, bpbw, snr, rattn, tphr, IPI, nphr, attn, cf);
    [stim] = [s1(:) s2(:) s3(:) s4(:) s5(:) s6(:) s7(:) s8(:) s9(:) s10(:) s11(:) s12(:)];
    stim = stim'; idx = 1;
            
    % Modulation option
    revtime = get(handles.revtime, 'Value');
    revphr = get(handles.revphr, 'Value');
    amflat = get(handles.amflat, 'Value');
    chopbk = get(handles.chopbk, 'Value');
    chopak = get(handles.chopak, 'Value');
    temp_callstruct.rev = [revtime revtime];
    temp_callstruct.opt.ord = revphr;
    temp_callstruct.opt.noam = amflat;
    if (chopbk), temp_callstruct.opt.chop = 1; 
    elseif (chopak), temp_callstruct.opt.chop = 2;
    else temp_callstruct.opt.chop = 0; 
    end
    chop = temp_callstruct.opt.chop;
    
    % Generate each varying stimulus
    for stim_num = 1:size(stim, 2)
        temp_callstruct.fc = handles.callstruct.fc(stim(idx));               idx = idx + 1;
        temp_callstruct.attn = handles.attenuation(stim(idx));               idx = idx + 1;
        temp_callstruct.nphr = handles.callstruct.nphr(stim(idx));           idx = idx + 1;
        temp_callstruct.IPI = handles.callstruct.IPI(stim(idx));             idx = idx + 1;
        temp_callstruct.tphr = handles.callstruct.tphr(stim(idx));           idx = idx + 1;
        temp_callstruct.rAttn = handles.callstruct.rAttn(stim(idx));         idx = idx + 1;     
        temp_callstruct.snr = handles.callstruct.snr(stim(idx));             idx = idx + 1;
        temp_callstruct.bpbw = handles.callstruct.bpbw(stim(idx));           idx = idx + 1;
        temp_callstruct.seed = handles.callstruct.seed(stim(idx));           idx = idx + 1;
        temp_callstruct.bw = handles.callstruct.bw(stim(idx));          	 idx = idx + 1;
        temp_callstruct.fknee = handles.callstruct.fknee(stim(idx));         idx = idx + 1;
        temp_callstruct.tknee = handles.callstruct.tknee(stim(idx));         idx = idx + 1;
        
        % Synthesize
        [y, rms, ~, ~] = twitter_synth(temp_callstruct, SR);
        rms_str = num2str(rms, 4);

        % Add onset and offset ramp
        t = (0:length(y)-1)/SR;
        former_t = 1:length(on_ramp);
        latter_t = (length(t)-length(off_ramp)+1):length(t);
        y(former_t) = y(former_t).*on_ramp;
        y(latter_t) = y(latter_t).*off_ramp;
        
        % Plot on axes and show rms & dur on GUI
        showit(t, y, handles); set(handles.rms, 'String', rms_str); 
        set(handles.durshow, 'String', max(t)*1000);
        handles.y = y; pause(0.2);

        % Header info shown on command window
        header0 = ['CallType: '  num2str(handles.type)]; 
        header1 = ['. Freq: '    num2str(temp_callstruct.fc/1000, 4)    ' (kHz)'];
        header2 = ['. Attn: '    num2str(temp_callstruct.attn)           ' (dB)'];
        header3 = ['. nphr: '    num2str(temp_callstruct.nphr)           ' (--)'];
        header4 = ['. IPI: '     num2str(temp_callstruct.IPI)          ' (msec)'];
        header5 = ['. tphr: '    num2str(temp_callstruct.tphr)         ' (msec)'];
        header6 = ['. rAttn: '   num2str(temp_callstruct.rAttn)          ' (dB)'];
        header7 = ['. SNR: '     num2str(temp_callstruct.snr)            ' (dB)'];
        header8 = ['. bpBW: '    num2str(temp_callstruct.bpbw)          ' (oct)'];
        header9 = ['. Seed: '    num2str(temp_callstruct.seed)           ' (--)'];
        header10 = ['. bwPhr: '  num2str(temp_callstruct.bw)             ' (Hz)'];
        header11 = ['. fKnee: '  num2str(temp_callstruct.fknee)          ' (--)'];
        header12 = ['. tKnee: '  num2str(temp_callstruct.tknee)          ' (--)'];
        header13 = [' .Revphr:'  num2str(revphr)];
        header14 = [' .Amflat:'  num2str(amflat)];
        header15 = [' .Chop:'    num2str(chop)];
        
        header_b = strcat(header0, header1, header2, header3, header4, header5);
        header_h = strcat(header6);
        header_n = strcat(header7, header8, header9);
        header_fm = strcat(header10, header11, header12);
        header_mod = strcat(header13, header14, header15);
        header = strcat(header_b, header_h, header_n, header_fm, header_mod);
        disp(header);
        
    end
    
end

guidata(hObject, handles)

% ====================== RX6 Generation =================================
% To generate vocalization stimuli for TDT in RX6 
function gen_callstim

% Global parameters for xblaster 
global g_stimulus_matrix temp_callstruct g_stimulus_parameters

h = findobj('Tag','VirtualCall_figure');
handles = guidata(h);

% Generate stimuli
temp_callstruct = handles.callstruct;            % template structure
rate_covary = get(handles.rate_covary, 'Value'); % AM/FM rate covary check
modtype = ModType_check(handles);                % modulation type assign
SR = handles.SR;                                 % sampling rate
ch = 1;                                          % channel

% Onset and offset ramp (5 msec each)
ramp = 5/1000; 
t_on = 0:1/SR:ramp;
on_ramp = (1-cos((2*pi*t_on)./(2*ramp)))/2;
t_off = 0:1/SR:ramp;
off_ramp = fliplr((1-cos((2*pi*t_off)./(2*ramp)))/2);

% Call type synthesis
if handles.type < 5 % TONE PHEE TRILL TRILL_PHEE
    
    % Get stimulus parameter length
    lcf = length(handles.callstruct.fc);
    lattn = length(handles.attenuation);
    ldur = length(handles.callstruct.dur);
    lorder = length(handles.callstruct.order);
    lbw = length(handles.callstruct.hbw);
    lrattn = length(handles.callstruct.rAttn);
    lsnr = length(handles.callstruct.snr);
    lbpbw = length(handles.callstruct.bpbw);
    lseed = length(handles.callstruct.seed);
    lfmmod = length(handles.callstruct.fm1mod);
    lfmrate = length(handles.callstruct.fm1_rate);
    lfmdepth = length(handles.callstruct.fm1_depth);   
    lttrans = length(handles.callstruct.trans);
    lammod = length(handles.callstruct.am1mod);
    lamdepth = length(handles.callstruct.am1_depth);   
    lamrate = length(handles.callstruct.am1_rate);   

    % Get stimulus parameter sequence
    cf = 1:lcf; 
    attn = 1:lattn; 
    dur = 1:ldur;
    order = 1:lorder; 
    bw = 1:lbw; 
    rattn = 1:lrattn;
    snr = 1:lsnr; 
    bpbw = 1:lbpbw; 
    seed = 1:lseed;
    fmmod = 1:lfmmod; 
    fmrate = 1:lfmrate;
    fmdepth = 1:lfmdepth;
    ttrans = 1:lttrans;
    ammod = 1:lammod;
    amrate = 1:lamrate;
    amdepth = 1:lamdepth;
    
    % --------------------- FM/AM rates don't co-vary -------------------
    if rate_covary == 0
        
        % Stimulus parameter variable
        [s16 s15 s14 s13 s12 s11 s10 s9 s8 s7 s6 s5 s4 s3 s2 s1] = ndgrid(...
                  amdepth, amrate, ammod, ttrans, fmdepth, fmrate, fmmod, ...
                  seed, bpbw, snr, rattn, bw, order, dur, attn, cf);

        [stim] = [s1(:) s2(:) s3(:) s4(:) s5(:) s6(:) s7(:) s8(:) s9(:) ...
                  s10(:) s11(:) s12(:) s13(:) s14(:) s15(:) s16(:)];

        stim = stim'; idx = 1;

        % Generate each stimulus
        for stim_num = 1:size(stim, 2)
            temp_callstruct.fc = handles.callstruct.fc(stim(idx));               idx = idx + 1;
            temp_callstruct.attn = handles.attenuation(stim(idx));               idx = idx + 1;
            temp_callstruct.dur = handles.callstruct.dur(stim(idx));             idx = idx + 1;
            temp_callstruct.order = handles.callstruct.order(stim(idx));         idx = idx + 1;
            temp_callstruct.hbw = handles.callstruct.hbw(stim(idx));             idx = idx + 1;
            temp_callstruct.rAttn = handles.callstruct.rAttn(stim(idx));         idx = idx + 1;     
            temp_callstruct.snr = handles.callstruct.snr(stim(idx));             idx = idx + 1;
            temp_callstruct.bpbw = handles.callstruct.bpbw(stim(idx));           idx = idx + 1;
            temp_callstruct.seed = handles.callstruct.seed(stim(idx));           idx = idx + 1;
            temp_callstruct.fm1mod = handles.callstruct.fm1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.fm1_rate = handles.callstruct.fm1_rate(stim(idx));   idx = idx + 1;
            temp_callstruct.fm1_depth = handles.callstruct.fm1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.trans = handles.callstruct.trans(stim(idx));         idx = idx + 1;
            temp_callstruct.am1mod = handles.callstruct.am1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.am1_rate = handles.callstruct.am1_rate(stim(idx));   idx = idx + 1;
            temp_callstruct.am1_depth = handles.callstruct.am1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.A2A1 = 10^(temp_callstruct.rAttn/20);
            temp_callstruct.f0 = temp_callstruct.fc/temp_callstruct.order;
            temp_callstruct.fm2mod = 2*temp_callstruct.fm1mod;
            temp_callstruct.fm2_rate = temp_callstruct.fm1_rate; 
            temp_callstruct.fm2_depth = 2*temp_callstruct.fm1_depth; 
            temp_callstruct.am2mod = 2*temp_callstruct.am1mod;
            temp_callstruct.am2_rate = temp_callstruct.am1_rate; 
            temp_callstruct.am2_depth = temp_callstruct.am1_depth; 

            % fm_mod random button selected
            if modtype(2) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.FM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.FM2_back = temp_callstruct.FM1_back;
            end

            % am_mod random button selected
            if modtype(4) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.AM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.AM2_back = temp_callstruct.AM1_back;
            end
            
            % Reverse time or not
            revtime = get(handles.revtime, 'Value');
            temp_callstruct.rev =[revtime revtime];
            
            % Synthesize
            [y, ~, ~, ~] = narrow_synth(temp_callstruct, handles.type, SR);

            % Add onset and offset ramp
            t = (0:length(y)-1)/SR;
            former_t = 1:length(on_ramp);
            latter_t = (length(t)-length(off_ramp)+1):length(t);
            y(former_t) = y(former_t).*on_ramp;
            y(latter_t) = y(latter_t).*off_ramp;

            % Header info shown on command window
            header0 = ['CallType: '  num2str(handles.type)]; 
            header1 = ['. ModType: ' modtype];
            header2 = ['. Freq: '    num2str(temp_callstruct.fc/1000, 4)    ' (kHz)'];
            header3 = ['. Attn: '    num2str(temp_callstruct.attn)           ' (dB)'];
            header4 = ['. Dur: '     num2str(temp_callstruct.dur*1000, 4)  ' (msec)'];
            header5 = ['. f0: '      num2str(temp_callstruct.f0/1000, 4)    ' (kHz)'];
            header6 = ['. hBW: '     num2str(temp_callstruct.hbw)           ' (oct)'];
            header7 = ['. rAttn: '   num2str(temp_callstruct.rAttn)          ' (dB)'];
            header8 = ['. SNR: '     num2str(temp_callstruct.snr)            ' (dB)'];
            header9 = ['. bpBW: '    num2str(temp_callstruct.bpbw)          ' (oct)'];
            header10 = ['. Seed: '   num2str(temp_callstruct.seed)           ' (--)'];
            header11 = ['. mFM1: '   num2str(temp_callstruct.fm1mod, 4)      ' (Hz)'];
            header12 = ['. fFM1: '   num2str(temp_callstruct.fm1_rate, 4)    ' (Hz)'];
            header13 = ['. dFM1: '   num2str(temp_callstruct.fm1_depth, 4)   ' (Hz)'];
            header14 = ['. tTrans: ' num2str(temp_callstruct.trans, 4)      ' (0~1)'];
            header15 = ['. mAM1: '   num2str(temp_callstruct.am1mod, 4)     ' (0~1)'];
            header16 = ['. fAM1: '   num2str(temp_callstruct.am1_rate, 4)    ' (Hz)'];
            header17 = ['. dAM1: '   num2str(temp_callstruct.am1_depth, 4)  ' (0~1)'];

            header_b = strcat(header0, header1, header2, header3, header4);
            header_h = strcat(header5, header6, header7);
            header_n = strcat(header8, header9, header10);
            header_fm = strcat(header11, header12, header13, header14);
            header_am = strcat(header15, header16, header17);

            header = strcat(header_b, header_h, header_n, header_fm, header_am);
            disp(header);

            % Xblaster adjusting overall level
            xb_att = temp_callstruct.attn;  
            xb_y = y./max(y)*9.999;

            % g_stimulus_matrix
            g_stimulus_matrix{ch}{stim_num, 1} = stim_num;   % stimulus number
            g_stimulus_matrix{ch}{stim_num, 2} = {SR, xb_y}; % sample rate/data
            g_stimulus_matrix{ch}{stim_num, 3} = xb_att;     % attenuation
            g_stimulus_matrix{ch}{stim_num, 4} = 5;          % rise/fall time
            g_stimulus_matrix{ch}{stim_num, 5} = header;     % header info
            g_stimulus_matrix{ch}{stim_num, 6} = SR/2;       % low-pass curoff

        end
        
    % --------------------- FM/AM rates co-vary -------------------------
    else
        
        % Stimulus parameter variable
        [s15 s14 s13 s12 s11 s10 s9 s8 s7 s6 s5 s4 s3 s2 s1] = ndgrid(...
                  amdepth, ammod, ttrans, fmdepth, fmrate, fmmod, ...
                  seed, bpbw, snr, rattn, bw, order, dur, attn, cf);

        [stim] = [s1(:) s2(:) s3(:) s4(:) s5(:) s6(:) s7(:) s8(:) s9(:) ...
                  s10(:) s11(:) s12(:) s13(:) s14(:) s15(:)];

        stim = stim'; idx = 1;

        % Generate each stimulus
        for stim_num = 1:size(stim, 2)
            temp_callstruct.fc = handles.callstruct.fc(stim(idx));               idx = idx + 1;
            temp_callstruct.attn = handles.attenuation(stim(idx));               idx = idx + 1;
            temp_callstruct.dur = handles.callstruct.dur(stim(idx));             idx = idx + 1;
            temp_callstruct.order = handles.callstruct.order(stim(idx));         idx = idx + 1;
            temp_callstruct.hbw = handles.callstruct.hbw(stim(idx));             idx = idx + 1;
            temp_callstruct.rAttn = handles.callstruct.rAttn(stim(idx));         idx = idx + 1;     
            temp_callstruct.snr = handles.callstruct.snr(stim(idx));             idx = idx + 1;
            temp_callstruct.bpbw = handles.callstruct.bpbw(stim(idx));           idx = idx + 1;
            temp_callstruct.seed = handles.callstruct.seed(stim(idx));           idx = idx + 1;
            temp_callstruct.fm1mod = handles.callstruct.fm1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.fm1_rate = handles.callstruct.fm1_rate(stim(idx));   idx = idx + 1;
            temp_callstruct.fm1_depth = handles.callstruct.fm1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.trans = handles.callstruct.trans(stim(idx));         idx = idx + 1;
            temp_callstruct.am1mod = handles.callstruct.am1mod(stim(idx));       idx = idx + 1;
            temp_callstruct.am1_depth = handles.callstruct.am1_depth(stim(idx)); idx = idx + 1;
            temp_callstruct.A2A1 = 10^(temp_callstruct.rAttn/20);
            temp_callstruct.f0 = temp_callstruct.fc/temp_callstruct.order;
            temp_callstruct.fm2mod = 2*temp_callstruct.fm1mod;
            temp_callstruct.fm2_rate = temp_callstruct.fm1_rate; 
            temp_callstruct.fm2_depth = 2*temp_callstruct.fm1_depth; 
            temp_callstruct.am2mod = 2*temp_callstruct.am1mod;
            temp_callstruct.am1_rate = temp_callstruct.fm1_rate;
            temp_callstruct.am2_rate = temp_callstruct.am1_rate; 
            temp_callstruct.am2_depth = temp_callstruct.am1_depth; 

            % fm_mod random button selected
            if modtype(2) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.FM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.FM2_back = temp_callstruct.FM1_back;
            end

            % am_mod random button selected
            if modtype(4) == '1'
                temp_dur = temp_callstruct.dur;
                temp_noise = temp_callstruct.seed; 
                temp_callstruct.AM1_back = random_back(handles, temp_dur, temp_noise); 
                temp_callstruct.AM2_back = temp_callstruct.AM1_back;
            end
            
            % Reverse time or not
            revtime = get(handles.revtime, 'Value');
            temp_callstruct.rev = [revtime revtime];
            
            % Synthesize
            [y, ~, ~, ~] = narrow_synth(temp_callstruct, handles.type, SR);
            
            % Add onset and offset ramp
            t = (0:length(y)-1)/SR;
            former_t = 1:length(on_ramp);
            latter_t = (length(t)-length(off_ramp)+1):length(t);
            y(former_t) = y(former_t).*on_ramp;
            y(latter_t) = y(latter_t).*off_ramp;

            % Header info shown on command window
            header0 = ['CallType: '  num2str(handles.type)]; 
            header1 = ['. ModType: ' modtype];
            header2 = ['. Freq: '    num2str(temp_callstruct.fc/1000, 4)    ' (kHz)'];
            header3 = ['. Attn: '    num2str(temp_callstruct.attn)           ' (dB)'];
            header4 = ['. Dur: '     num2str(temp_callstruct.dur*1000, 4)  ' (msec)'];
            header5 = ['. f0: '      num2str(temp_callstruct.f0/1000, 4)    ' (kHz)'];
            header6 = ['. hBW: '     num2str(temp_callstruct.hbw)           ' (oct)'];
            header7 = ['. rAttn: '   num2str(temp_callstruct.rAttn)          ' (dB)'];
            header8 = ['. SNR: '     num2str(temp_callstruct.snr)            ' (dB)'];
            header9 = ['. bpBW: '    num2str(temp_callstruct.bpbw)          ' (oct)'];
            header10 = ['. Seed: '   num2str(temp_callstruct.seed)           ' (--)'];
            header11 = ['. mFM1: '   num2str(temp_callstruct.fm1mod, 4)      ' (Hz)'];
            header12 = ['. fFM1: '   num2str(temp_callstruct.fm1_rate, 4)    ' (Hz)'];
            header13 = ['. dFM1: '   num2str(temp_callstruct.fm1_depth, 4)   ' (Hz)'];
            header14 = ['. tTrans: ' num2str(temp_callstruct.trans, 4)      ' (0~1)'];
            header15 = ['. mAM1: '   num2str(temp_callstruct.am1mod, 4)     ' (0~1)'];
            header16 = ['. fAM1: '   num2str(temp_callstruct.am1_rate, 4)    ' (Hz)'];
            header17 = ['. dAM1: '   num2str(temp_callstruct.am1_depth, 4)  ' (0~1)'];

            header_b = strcat(header0, header1, header2, header3, header4);
            header_h = strcat(header5, header6, header7);
            header_n = strcat(header8, header9, header10);
            header_fm = strcat(header11, header12, header13, header14);
            header_am = strcat(header15, header16, header17);

            header = strcat(header_b, header_h, header_n, header_fm, header_am);
            disp(header);

            % Xblaster adjusting overall level
            xb_att = temp_callstruct.attn;  
            xb_y = y./max(y)*9.999;

            % g_stimulus_matrix
            g_stimulus_matrix{ch}{stim_num, 1} = stim_num;   % stimulus number
            g_stimulus_matrix{ch}{stim_num, 2} = {SR, xb_y}; % sample rate/data
            g_stimulus_matrix{ch}{stim_num, 3} = xb_att;     % attenuation
            g_stimulus_matrix{ch}{stim_num, 4} = 5;          % rise/fall time
            g_stimulus_matrix{ch}{stim_num, 5} = header;     % header info
            g_stimulus_matrix{ch}{stim_num, 6} = SR/2;       % low-pass curoff

        end
        
    end
    
% ------------------------- TWIT ----------------------------------------     
else % TWIT
    % Get stimulus parameter length
    lcf = length(handles.callstruct.fc);
    lattn = length(handles.attenuation);
    lnphr = length(handles.callstruct.nphr);
    lIPI = length(handles.callstruct.IPI);
    ltphr = length(handles.callstruct.tphr);
    lrattn = length(handles.callstruct.rAttn);
    lsnr = length(handles.callstruct.snr);
    lbpbw = length(handles.callstruct.bpbw);
    lseed = length(handles.callstruct.seed);
    lbw = length(handles.callstruct.bw);
    lfknee = length(handles.callstruct.fknee);
    ltknee = length(handles.callstruct.tknee);
    
    % Get stimulus parameter sequence
    cf = 1:lcf; 
    attn = 1:lattn; 
    nphr = 1:lnphr;
    IPI = 1:lIPI;
    tphr = 1:ltphr;
    rattn = 1:lrattn;
    snr = 1:lsnr; 
    bpbw = 1:lbpbw; 
    seed = 1:lseed;
    bw = 1:lbw;
    fknee = 1:lfknee;
    tknee = 1:ltknee;
    
    % Stimulus parameter variable
    [s12 s11 s10 s9 s8 s7 s6 s5 s4 s3 s2 s1] = ndgrid(...
        tknee, fknee, bw, seed, bpbw, snr, rattn, tphr, IPI, nphr, attn, cf);
    [stim] = [s1(:) s2(:) s3(:) s4(:) s5(:) s6(:) s7(:) s8(:) s9(:) s10(:) s11(:) s12(:)];
    stim = stim'; idx = 1;
            
    % Modulation option
    revtime = get(handles.revtime, 'Value');         % reversed time
    revphr = get(handles.revphr, 'Value');         % reversed phrase order
    amflat = get(handles.amflat, 'Value');         % AM flat 
    chopbk = get(handles.chopbk, 'Value');         % preserved before-knee only 
    chopak = get(handles.chopak, 'Value');         % preserved after-knee only
    temp_callstruct.rev = [revtime revtime];
    temp_callstruct.opt.ord = revphr;              
    temp_callstruct.opt.noam = amflat;
    if (chopbk), temp_callstruct.opt.chop = 1; 
    elseif (chopak), temp_callstruct.opt.chop = 2;
    else temp_callstruct.opt.chop = 0; 
    end
    chop = temp_callstruct.opt.chop;
    
    % Generate each stimulus
    for stim_num = 1:size(stim, 2)
        temp_callstruct.fc = handles.callstruct.fc(stim(idx));               idx = idx + 1;
        temp_callstruct.attn = handles.attenuation(stim(idx));               idx = idx + 1;
        temp_callstruct.nphr = handles.callstruct.nphr(stim(idx));           idx = idx + 1;
        temp_callstruct.IPI = handles.callstruct.IPI(stim(idx));             idx = idx + 1;
        temp_callstruct.tphr = handles.callstruct.tphr(stim(idx));           idx = idx + 1;
        temp_callstruct.rAttn = handles.callstruct.rAttn(stim(idx));         idx = idx + 1;     
        temp_callstruct.snr = handles.callstruct.snr(stim(idx));             idx = idx + 1;
        temp_callstruct.bpbw = handles.callstruct.bpbw(stim(idx));           idx = idx + 1;
        temp_callstruct.seed = handles.callstruct.seed(stim(idx));           idx = idx + 1;
        temp_callstruct.bw = handles.callstruct.bw(stim(idx));               idx = idx + 1;
        temp_callstruct.fknee = handles.callstruct.fknee(stim(idx));         idx = idx + 1;
        temp_callstruct.tknee = handles.callstruct.tknee(stim(idx));         idx = idx + 1;
        
        % Synthesize
        [y, ~, ~, ~] = twitter_synth(temp_callstruct, SR);
        
        % Add onset and offset ramp
        t = (0:length(y)-1)/SR;
        former_t = 1:length(on_ramp);
        latter_t = (length(t)-length(off_ramp)+1):length(t);
        y(former_t) = y(former_t).*on_ramp;
        y(latter_t) = y(latter_t).*off_ramp;

        % Header info shown on command window
        header0 = ['CallType: '  num2str(handles.type)];
        header1 = ['. Freq: '    num2str(temp_callstruct.fc/1000, 4)    ' (kHz)'];
        header2 = ['. Attn: '    num2str(temp_callstruct.attn)           ' (dB)'];
        header3 = ['. nphr: '    num2str(temp_callstruct.nphr)    		 ' (--)'];
        header4 = ['. IPI: '     num2str(temp_callstruct.IPI)          ' (msec)'];
        header5 = ['. tphr: '    num2str(temp_callstruct.tphr)         ' (msec)'];
        header6 = ['. rAttn: '   num2str(temp_callstruct.rAttn)          ' (dB)'];
        header7 = ['. SNR: '     num2str(temp_callstruct.snr)            ' (dB)'];
        header8 = ['. bpBW: '    num2str(temp_callstruct.bpbw)          ' (oct)'];
        header9 = ['. Seed: '    num2str(temp_callstruct.seed)           ' (--)'];
        header10 = ['. bwPhr: '  num2str(temp_callstruct.bw)             ' (Hz)'];
        header11 = ['. fKnee: '  num2str(temp_callstruct.fknee)          ' (--)'];
        header12 = ['. tKnee: '  num2str(temp_callstruct.tknee)          ' (--)'];
        header13 = [' .Revphr:'  num2str(revphr)];
        header14 = [' .Amflat:'  num2str(amflat)];
        header15 = [' .Chop:'    num2str(chop)];
        
        header_b = strcat(header0, header1, header2, header3, header4, header5);
        header_h = strcat(header6);
        header_n = strcat(header7, header8, header9);
        header_fm = strcat(header10, header11, header12);
        header_mod = strcat(header13, header14, header15);
        header = strcat(header_b, header_h, header_n, header_fm, header_mod);
        disp(header);

        % Xblaster adjusting overall level
        xb_att = temp_callstruct.attn;  
        xb_y = y./max(y)*9.999;

        % g_stimulus_matrix
        g_stimulus_matrix{ch}{stim_num, 1} = stim_num;   % stimulus number
        g_stimulus_matrix{ch}{stim_num, 2} = {SR, xb_y}; % sample rate/data
        g_stimulus_matrix{ch}{stim_num, 3} = xb_att;     % attenuation
        g_stimulus_matrix{ch}{stim_num, 4} = 5;          % rise/fall time
        g_stimulus_matrix{ch}{stim_num, 5} = header;     % header info
        g_stimulus_matrix{ch}{stim_num, 6} = SR/2;       % low-pass curoff
        
    end
    
end

% Set analysis type 
switch handles.type
    case 1 % Complex Tone
        if (lcf>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==100)...
            &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'puretone_cf';
            
        elseif (lattn>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==100)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'puretone_attn';
            
        elseif (ldur>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==100)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'puretone_dur';
            
        elseif (lcf>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==0)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'noise_cf';
            
        elseif (lattn>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==0)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'noise_attn';       

        elseif (ldur>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==0)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'noise_dur';  
            
        elseif (lbpbw>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==0)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'noise_bw';
            
        elseif (lseed>1)&&(handles.callstruct.rAttn==-100)&&(handles.callstruct.snr==0)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'noise_seed';

        elseif (lcf>1)&&(handles.callstruct.rAttn>-100)&&(handles.callstruct.snr==-100)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'harmonic_cf';   

        elseif (lattn>1)&&(handles.callstruct.rAttn>-100)&&(handles.callstruct.snr==-100)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'harmonic_attn'; 
            
        elseif (ldur>1)&&(handles.callstruct.rAttn>-100)&&(handles.callstruct.snr==-100)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'harmonic_dur';       
            
        elseif (lrattn>1)&&(handles.callstruct.snr==-100)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'harmonic_rattn'; 
            
        elseif (lorder>1)&&(handles.callstruct.rAttn>-100)&&(handles.callstruct.snr==-100)...
                &&(handles.callstruct.fm1_rate==0)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'harmonic_order'; 
        
        elseif (lfmrate>1)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'sFM_rate';
            
        elseif (lfmdepth>1)&&(handles.callstruct.am1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'sFM_depth';              
            
        elseif (lamrate>1)&&(handles.callstruct.fm1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'sAM_rate';
            
        elseif (lamdepth>1)&&(handles.callstruct.fm1_rate==0)
            g_stimulus_parameters.xblaster.analysis_type = 'sAM_depth';
            
        elseif (lfmrate>1)&&(rate_covary==1)
            g_stimulus_parameters.xblaster.analysis_type = 'sFMAM_rate';            
            
        else
            g_stimulus_parameters.xblaster.analysis_type = 'complextone';
        end
        
    case 2 % Phee
        if (lcf>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_cf';
        elseif (lattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_attn';
        elseif (ldur>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_dur';
        elseif (lfmmod>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_FMmod';
        elseif (lfmrate>1)&&(rate_covary==0)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_FMrate';
        elseif (lfmdepth>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_FMdepth';
        elseif (lammod>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_AMmod';
        elseif (lamrate>1)&&(rate_covary==0)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_AMrate';
        elseif (lamdepth>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_AMdepth';
        elseif (lfmrate>1)&&(rate_covary==1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_FMAMrate';
        elseif (lrattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_Hrattn';
        elseif (lorder>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_Horder';
		elseif (lbw>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_Hbw';
        elseif (lsnr>1)
            g_stimulus_parameters.xblaster.analysis_type = 'phee_SNR';
        else
            g_stimulus_parameters.xblaster.analysis_type = 'phee';
        end
        
    case 3 % Trill
        if (lcf>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_cf';
        elseif (lattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_attn';
        elseif (ldur>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_dur';
        elseif (lfmmod>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_FMmod';
        elseif (lfmrate>1)&&(rate_covary==0)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_FMrate';
        elseif (lfmdepth>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_FMdepth';
        elseif (lammod>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_AMmod';
        elseif (lamrate>1)&&(rate_covary==0)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_AMrate';
        elseif (lamdepth>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_AMdepth';
        elseif (lfmrate>1)&&(rate_covary==1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_FMAMrate';
        elseif (lrattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_Hrattn';
        elseif (lorder>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_Horder';
		elseif (lbw>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_Hbw';
        elseif (lsnr>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trill_SNR';
        else
            g_stimulus_parameters.xblaster.analysis_type = 'trill';
        end
        
    case 4 % Trillphee
        if (lcf>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_cf';
        elseif (lattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_attn';
        elseif (ldur>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_dur';
        elseif (lfmmod>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_FMmod';
        elseif (lfmrate>1)&&(rate_covary==0)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_FMrate';
        elseif (lfmdepth>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_FMdepth';
        elseif (lammod>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_AMmod';
        elseif (lamrate>1)&&(rate_covary==0)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_AMrate';
        elseif (lamdepth>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_AMdepth';
        elseif (lfmrate>1)&&(rate_covary==1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_FMAMrate';
        elseif (lttrans>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_tTrans';
        elseif (lrattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_Hrattn';
        elseif (lorder>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_Horder';
		elseif (lbw>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_Hbw';
        elseif (lsnr>1)
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee_SNR';
        else
            g_stimulus_parameters.xblaster.analysis_type = 'trillphee';
        end
        
    case 5 % Twitter
        if (lcf>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_cf';
        elseif (lattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_attn';
		elseif (lnphr>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_nphr';
		elseif (lIPI>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_IPI';	
		elseif (ltphr>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_tphr';
		elseif (lbw>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_bwphr';	
		elseif (lfknee>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_fknee';	
		elseif (ltknee>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_tknee';
		elseif (lrattn>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_Hrattn';
		elseif (lsnr>1)
            g_stimulus_parameters.xblaster.analysis_type = 'twitter_SNR';
		else
			g_stimulus_parameters.xblaster.analysis_type = 'twitter';
		end
		
end


% ====================== Sound Button ===================================
% Button to play the sound of the stimulus
function sound_Callback(~, ~, handles)
soundsc(handles.y, handles.SR);

function sound_CreateFcn(hObject, ~, ~)
A = imread('speaker.png','BackgroundColor', [0.94,0.94,0.94]); 
B = imresize(A, 0.04); 
set(hObject,'CData', B); 


% ====================== Logscale Check =================================
% To check whether the input string is in log scale or not
% To convert a string with slash (octave) to vectors of numbers
% 1: log scale, 0: linear scale or scalar
function [logscale, stim_start, stim_end, pts] = logscale_check(str)

logscale = 0; stim_start = 0; stim_end = 0; pts = 0;

colon_ind = strfind(str, ':');
splash_ind = strfind(str, '/');
log_ind = strfind(upper(str), 'L');

if ~isempty(colon_ind) && ~isempty(splash_ind) && ~isempty(log_ind)
    stim_start =  str2double(str(1:colon_ind-1));
    stim_end = str2double(str(colon_ind+1:splash_ind-1));
    pts = str2double(str(splash_ind+1:log_ind-1));
    logscale = 1;
end


% ====================== Octave Check ===================================
% To check whether the input string is in octave unit or Hz unit 
% 1: octave, 0: Hz
function [octscale, depth_oct] = octscale_check(str)

octscale = 0; depth_oct = 0;

oct_ind = strfind(upper(str), 'L');

if ~isempty(oct_ind)
    depth_oct =  str2double(str(1:oct_ind-1));
    octscale = 1;
end


% ====================== Get Octave Space ===============================
% To calculate octave spaced stimuli range with pts points
function data = octspace(stim_start, stim_end, pts)

octave = ceil(log2(stim_end/stim_start));
num = (pts-1)/octave;
space = 1/num;
log2stim = log2(stim_start):space:(log2(stim_start) + octave);
data = 2.^(log2stim);


% ====================== Random Back Countour ===========================
% To get randomized sinusoidal contour when FM/AM Rand button is pressed
function rand_contour = random_back(handles, temp_dur, seed)

duration = temp_dur; 
Nrand = length(handles.callstruct.FM1_back);  
SR_coarse = (Nrand-1)/duration; 
t_coarse = 0:1/SR_coarse:duration;

cutoff_f = handles.contourF;  % mean of contour oscillation frequency
std_f = handles.contourFstd;  % std of contour oscillation frequency  

% f is scaled to [contourF-contourFstd, contourF+contourFstd]
% randn('Seed', seed)
s = RandStream('mcg16807','Seed', seed);    
RandStream.setGlobalStream(s);
f = cutoff_f + std_f*randn(size(t_coarse)); 

% phi is scaled to [0, -pi]
% rand('Seed', seed)
s = RandStream('mcg16807','Seed', seed);    
RandStream.setGlobalStream(s)
phi = -pi*rand(1,1);                       

% rand_contour is sinusoidal oscillation contour scaled to [0, 1]
rand_contour = 0.5*(1 + cos(2*pi*f.*t_coarse + phi));    


% ====================== Modification Type Check ========================
% To return a vector of modification type for FM/AM const/rand
% [fm_const, fm_rand, am_const, am_rand]
function modtype = ModType_check(handles)

mod_fm_const = get(handles.fm_const, 'Value');
mod_fm_rand = get(handles.fm_rand, 'Value');
mod_am_const = get(handles.am_const, 'Value');
mod_am_rand = get(handles.am_rand, 'Value');

if (mod_fm_const==0 && mod_fm_rand==0)
    disp('Choose FM Mod type.'); beep; 
elseif (mod_am_const==0 && mod_am_rand==0)
    disp('Choose AM Mod type.'); beep;
end

str_mfc = num2str(mod_fm_const);
str_mfr = num2str(mod_fm_rand);
str_mac = num2str(mod_am_const);
str_mar = num2str(mod_am_rand);
modtype = [str_mfc str_mfr str_mac str_mar];


% ====================== Show Spectrogram ===============================
% To show spectrograms on axes
function showit(t, y, handles)

% Define sampling rate
SR = handles.SR;

% Amplitude-Time plot
plot(handles.time_axes, t, y);
axis(handles.time_axes, [0 max(t) -1 1]);

% Freq-Time plot
nFFT = 512;
win = window(@hamming,nFFT);
[Y,F,T] = specgram(y, nFFT, SR, win, nFFT*0.75);
imagesc(T, F, 20*log10(abs(Y)), 'Parent', handles.freq_axes);
axis xy; axis([0 max(T) 0 40000]);
xlabel('t (sec)'); ylabel('f (Hz)');
colormap(jet);


% --- Executes when VirtualCall_figure is resized.
function VirtualCall_figure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to VirtualCall_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function logo_Callback(hObject, eventdata, handles)

function logo_CreateFcn(hObject, eventdata, handles)
% logo designed by Chia-Jung Chang
C = imread('virtualcall.png','BackgroundColor', [0.94,0.94,0.94]); 
D = imresize(C, 0.2); 
set(hObject,'CData', D); 


% --- Executes on button press in Save_button.
function Save_button_Callback(hObject, eventdata, handles)
% hObject    handle to Save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Calltypes = {'Complex', 'Phee', 'Trill', 'Trillphee', 'Twitter'};
filename = [Calltypes{handles.type}, '_default.wav'];
handles.y = handles.y./max(abs(handles.y));
audiowrite(filename, handles.y, round(handles.SR))