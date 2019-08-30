%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix      =   'voc';
subject     =   'M91C_M92C_M64A_M29A';
sessionNum  =   'S142';
parChannel  =   3;   
refChannel  =   1;
time        =   [646.9, 647.3];
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
band = param.vocBandP;
oneSig = oneCallSpe;
oneSig = abs(oneSig);
oneSig(1:band(1),:) = 0;
oneSig(band(2):end,:) = 0;
se = strel('square',3);
oneSig = imopen(oneSig,se);
oneSig = imopen(oneSig,se);
binSig = oneSig;
data = cell(2,3);
data{1,1} = social.vad.tools.normMeanVar(parCallSpe);
data{1,2} = social.vad.tools.normMeanVar(refCallSpe);
data{1,3} = social.vad.tools.normMeanVar(oneCallSpe);
data{2,1} = social.vad.tools.normMeanVar(binSig);
data{2,2} = social.vad.tools.normMeanVar(binSig .* parCallSpe);
data{2,3} = social.vad.tools.normMeanVar(binSig .* refCallSpe);

Title = cell(2,3);
Title{1,1} = '(A) par-spectra';
Title{1,2} = '(B) ref-spectra';
Title{1,3} = '(C) enhanced diff-spectra';
Title{2,1} = '(D) weight map';
Title{2,2} = '(E) weighted par-spectra';
Title{2,3} = '(F) weigthed ref-spectra';
%}
%% (1) Load Data & Define Parameters
LAYOUT                  =   [2,3];
load('+FP/bgnpds.mat');
T.mag                   =   1.5;  % for BL3200PT to display a 1:1 figure: 0.9558
T.AreaStdColor          =   0.8*[1 1 1];
T.LineMajorWidth        =   1.5;
T.TextFDLmean           =   'FDL mean';
T.TextFDLstd            =   '+/-SD';
T.TextPartFontSize      =   9;     
T.TextLabelFontSize     =   7.5; 


T.AxesWidthTotal        =   5.5;  % 9
T.AxesWidthTitle        =   0.9; % 1.1
T.AxesWidthRight1       =   0.35; % 0.85
T.AxesWidthRight2       =   0.1;
T.AxesWidth1            =   T.AxesWidthTotal-T.AxesWidthTitle-T.AxesWidthRight1;
T.AxesWidth2            =   T.AxesWidthTotal-T.AxesWidthTitle-T.AxesWidthRight2;
T.AxesWidthSepa         =   0.2;  %1

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
%         T.AxesXLim =            [   0,  256];
%         T.AxesYLim =            [   -70, 20];
        T.AxesXTickRotation =   30;
%         T.AxesXTick =           [0,50,100,150,200,250];
%         T.AxesXTickLabel =      {'0','5','10','15','20','25'};
%         T.AxesYTick =           [-70,-40,-10,20];
%         T.AxesYTickLabel =      {'-70','-40','-10','20'};
%         T.AxesXLabel1 =       	'Freq (kHz)';
% %         T.AxesXLabel2 =           'Reference frequency (Hz)';
%         T.AxesYLabel1 =         'Energy (dB)';
% %         T.AxesYLabel2 =           'Frequency difference limen (Hz)';

        T.AxesXLim =            [   1,  390];
        T.AxesYLim =            [   1,  257];
        T.AxesXTick =           [0, 200, 390];
        T.AxesXTickLabel =      {'0', '0.2', '0.4'};
        T.AxesYTick =           [0,50,100,150,200,250];
        T.AxesYTickLabel =      {'0','5','10','15','20','25'};
        T.AxesXLabel1 =         'time (s)';
        T.AxesYLabel1 =         'Freq (kHz)';
        
        T.LineNum1 =            1;
        T.LineColor{1} =        [   31  119 180 ]/256;
        T.LineColor{2} =        [   254 127 14  ]/256;
        T.LineColor{3} =        [   44  160 44  ]/256;
        T.LineColor{4} =        [   214 39  40  ]/256;
        T.LineLegend =          {'Before Median Filter','After Median Filter'};

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
%         T.H.Axes{rowNum,colNum}.YLim = T.AxesYLim;
        h = xlabel(T.AxesXLabel1);
        set(h, 	'FontSize',                 T.TextLabelFontSize);
        set(h,	'VerticalAlignment',        'Cap');
        % Tightness:  'Bottom' > 'Baseline' > 'Middle' > 'Cap' > 'Top'   	
        h = ylabel(T.AxesYLabel1);
        set(h, 	'FontSize',                 T.TextLabelFontSize);
        set(h,	'VerticalAlignment',        'Baseline');
        % Tightness:  'Bottom' < 'Baseline' < 'Middle' < 'Cap' < 'Top'
        imagesc(data{rowNum, colNum});
        caxis([-1,1])
        title(Title{rowNum, colNum});
%         plot(   gain_spec1,...
%                 'LineWidth',                T.LineMajorWidth,...
%                 'Color',                    T.LineColor{1}); 
%         plot(   gain_spec2,...
%                 'LineWidth',                T.LineMajorWidth,...
%                 'Color',                    T.LineColor{2});
%         legend(T.LineLegend,'Location','NorthEast');    
    end
end
hBar = colorbar;
get(hBar, 'Position') 
set(hBar, 'Position', [0.8973    0.3590    0.0184    0.3611])
        
        