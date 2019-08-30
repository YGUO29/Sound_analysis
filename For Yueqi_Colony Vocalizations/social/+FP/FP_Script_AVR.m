%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix      =   'voc';
subject     =   'M91C_M92C_M64A_M29A';
sessionNum  =   'S142';
parChannel  =   1;   
refChannel  =   2;
time        =   [218.4,219];
param       =   social.vad.tools.Param(subject);
sessionName =   [prefix,'_',subject,'_',sessionNum];
f           =   [sessionName,'.hdr'];
filename    =   fullfile(param.soundFilePath,subject,f);
session     =   social.session.StandardSession(filename);
Fs          =   param.Fs;

parSignal   =   session.Signals(parChannel);
refSignal   =   session.Signals(refChannel);
parSignal.calculate_gain(param);
refSignal.calculate_gain(param);
parGain     =   parSignal.gain_spec;
refGain     =   refSignal.gain_spec;
parCall     =   parSignal.get_signal(time);
refCall     =   refSignal.get_signal(time);
parCall     =   parCall{1};
refCall     =   refCall{1};

[parCallSpe, ~, ~]      =   social.vad.tools.spectra(   parCall,...
                                                        param.specWinSize,...
                                                        param.specShift,...
                                                        Fs,...
                                                        0 ...
                                                    );

[refCallSpe, ~, ~]      =   social.vad.tools.spectra(   refCall,...
                                                        param.specWinSize,...
                                                        param.specShift,...
                                                        Fs,...
                                                        0 ...
                                                    );
parCallSpeRaw           =   parCallSpe;
refCallSpeRaw           =   refCallSpe;
[parCallSpe, refCallSpe, oneCallSpe]      =   social.vad.tools.subtract_Spe( parCallSpe, refCallSpe, parGain, refGain, param ); 

oneCut = oneCallSpe / max(max(oneCallSpe(band(1):end,:)));
m = max(oneCut(band(1):end,:),[],1);
m = medfilt1(m,10);
aw = 3;
oneCut1 = medfilt2(oneCut,[aw,1]);
v = mean(abs(oneCut1 - oneCut),1);
v = medfilt1(v,10);
vm = m./v;
vm = medfilt1(vm,10);
data = cell(2,2);
data{1,1} = social.vad.tools.normMeanVar(oneCut);
data{1,2} = m;
data{2,1} = v;
data{2,2} = vm;

Title = cell(2,2);
Title{1,1} = '(A) enhanced diff-spectra';
Title{1,2} = '(B) A';
Title{2,1} = '(C) V';
Title{2,2} = '(D) A/V';
%}
%% (1) Load Data & Define Parameters
LAYOUT                  =   [2,2];
load('+FP/bgnpds.mat');
T.mag                   =   1.5;  % for BL3200PT to display a 1:1 figure: 0.9558
T.AreaStdColor          =   0.8*[1 1 1];
T.LineMajorWidth        =   1.5;
T.TextFDLmean           =   'FDL mean';
T.TextFDLstd            =   '+/-SD';
T.TextPartFontSize      =   9;     
T.TextLabelFontSize     =   7.5; 


T.AxesWidthTotal        =   9;  % 9
T.AxesWidthTitle        =   1.1; % 1.1
T.AxesWidthRight1       =   0.85; % 0.85
T.AxesWidthRight2       =   0.1;
T.AxesWidth1            =   T.AxesWidthTotal-T.AxesWidthTitle-T.AxesWidthRight1;
T.AxesWidth2            =   T.AxesWidthTotal-T.AxesWidthTitle-T.AxesWidthRight2;
T.AxesWidthSepa         =   1;  %1

T.AxesHeightTotal       =   6;    % 6
T.AxesHeightTitle1      =  	1.2;
T.AxesHeightTitle2      =   0.8;
T.AxesHeightAbove       =   0.4;   % 0.2
T.AxesHeight1           =   T.AxesHeightTotal-T.AxesHeightTitle1-T.AxesHeightAbove;
T.AxesHeight2           =   T.AxesHeightTotal-T.AxesHeightTitle2-T.AxesHeightAbove;
T.AxesHeightSepa        =   0.2;  %0.5

T.FigWidth              =   0;
T.FigHeight             =   LAYOUT(1) * T.AxesHeightTotal + (LAYOUT(1)-1) * T.AxesHeightSepa;
T.FigPosition           =   [   0.1     0.1     T.FigWidth  T.FigHeight];

%% (2) Figure
T.H.Fig = FP.figureStyled('Elsevier',...
            'Scaling',                  T.mag,...
            'Position',                 T.FigPosition,...
            'Column',                   2);

%% (3) plot

T.H.Axes = cell(LAYOUT(1),LAYOUT(2));
for rowNum = 1 : LAYOUT(1)
    for colNum = 1 : LAYOUT(2)
      if (rowNum == 1) && (colNum == 1)
        T.AxesXTickRotation =   30;
        T.AxesXLim =            [   1,  590];
        T.AxesYLim =            [   1,  257];
        T.AxesXTick =           [0, 200, 400, 590];
        T.AxesXTickLabel =      {'0', '0.2', '0.4', '0.6'};
        T.AxesYTick =           [0,50,100,150,200,250];
        T.AxesYTickLabel =      {'0','5','10','15','20','25'};
        T.AxesXLabel1 =         'time (s)';
        T.AxesYLabel1 =         'Freq (kHz)';

        T.AxesCurWidthStart =   (colNum - 1) * (T.AxesWidthTotal+T.AxesWidthSepa) + T.AxesWidthTitle;
        T.AxesCurHeightStart =  T.FigHeight - rowNum * T.AxesHeightTotal - ...
                                (rowNum - 1) * T.AxesHeightSepa + T.AxesHeightTitle1;

        % plot                  
        T.H.Axes{rowNum,colNum} = axes(...
                'parent',               T.H.Fig,...
                'position',             [   T.AxesCurWidthStart,    T.AxesCurHeightStart,...
                                            T.AxesWidth1,           T.AxesHeight1],...
                'XTick',                T.AxesXTick,...
                'XTickLabel',           T.AxesXTickLabel,...
                'YTick',                T.AxesYTick,...
                'YTickLabel',           T.AxesYTickLabel,...
                'XLim',                 T.AxesXLim,...
                'YLim',                 T.AxesYLim,...
                'XTickLabelRotation',   T.AxesXTickRotation,...
                'YGrid',                'on');
        T.H.Axes{rowNum,colNum}.YTick = T.AxesYTick;
        T.H.Axes{rowNum,colNum}.YTickLabel = T.AxesYTickLabel;
        h = xlabel(T.AxesXLabel1);
        set(h, 	'FontSize',                 T.TextLabelFontSize);
        set(h,	'VerticalAlignment',        'Cap');
        % Tightness:  'Bottom' > 'Baseline' > 'Middle' > 'Cap' > 'Top'   	
        h = ylabel(T.AxesYLabel1);
        set(h, 	'FontSize',                 T.TextLabelFontSize);
        set(h,	'VerticalAlignment',        'Baseline');
        % Tightness:  'Bottom' < 'Baseline' < 'Middle' < 'Cap' < 'Top'
        imagesc(data{rowNum, colNum});
        hBar = colorbar;
        get(hBar, 'Position') 
        set(hBar, 'Position', [0.4547    0.6076    0.0372    0.3594])
        title(Title{rowNum, colNum});
      else
        T.AxesXTickRotation =   30;
        T.AxesXLim =            [   1,  590];
        T.AxesXTick =           [0, 200, 400, 590];
        T.AxesXTickLabel =      {'0', '0.2', '0.4', '0.6'};
        T.AxesXLabel1 =         'time (s)';
        T.AxesCurWidthStart =   (colNum - 1) * (T.AxesWidthTotal+T.AxesWidthSepa) + T.AxesWidthTitle;
        T.AxesCurHeightStart =  T.FigHeight - rowNum * T.AxesHeightTotal - ...
                                (rowNum - 1) * T.AxesHeightSepa + T.AxesHeightTitle1;
        T.H.Axes{rowNum,colNum} = axes(...
                'parent',               T.H.Fig,...
                'position',             [   T.AxesCurWidthStart,    T.AxesCurHeightStart,...
                                            T.AxesWidth1,           T.AxesHeight1],...
                'XTick',                T.AxesXTick,...
                'XTickLabel',           T.AxesXTickLabel,...
                'XLim',                 T.AxesXLim,...
                'XTickLabelRotation',   T.AxesXTickRotation,...
                'YGrid',                'on');

        h = xlabel(T.AxesXLabel1);
        set(h, 	'FontSize',                 T.TextLabelFontSize);
        set(h,	'VerticalAlignment',        'Cap');
        % Tightness:  'Bottom' > 'Baseline' > 'Middle' > 'Cap' > 'Top' 
        plot(   data{rowNum, colNum},...
                'LineWidth',                T.LineMajorWidth,...
                'Color',                    T.LineColor{1});             
        title(Title{rowNum, colNum});
      end
    end
end
        
        