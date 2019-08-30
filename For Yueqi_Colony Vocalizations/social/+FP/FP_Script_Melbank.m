%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\HMM')));
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMtools')));
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\KPMstats')));
addpath(genpath(fullfile(param.HMM_GMMFolder,'HMMall\netlab3.3')));
addpath(genpath(fullfile(param.HMM_GMMFolder,'voicebox')));
lenOfFrame = floor(param.Fs * param.frameLenT_HMM); 
Fs = param.Fs;
bank1=melbankm(24,lenOfFrame,Fs,0,0.5,'t');
bank1=full(bank1);
bank1=bank1/max(bank1(:));
bank2 = social.vad.tools.my_melbank();


data = cell(2,1);
data{1,1} = bank1';
% data{1,1} = bank2';
Title = cell(2,1);
Title{1,1} = 'original mel-triangle filter';
% Title{1,1} = 'modified mel-triangle filter';
%}
%% (1) Load Data & Define Parameters
LAYOUT                  =   [1,1];
T.mag                   =   1.5;  % for BL3200PT to display a 1:1 figure: 0.9558
T.AreaStdColor          =   0.8*[1 1 1];
T.LineMajorWidth        =   1.5;
T.TextFDLmean           =   'FDL mean';
T.TextFDLstd            =   '+/-SD';
T.TextPartFontSize      =   9;     
T.TextLabelFontSize     =   7.5; 


T.AxesWidthTotal        =   19;  % 9
T.AxesWidthTitle        =   1.1; % 1.1
T.AxesWidthRight1       =   0.85; % 0.85
T.AxesWidthRight2       =   0.1;
T.AxesWidth1            =   T.AxesWidthTotal-T.AxesWidthTitle-T.AxesWidthRight1;
T.AxesWidth2            =   T.AxesWidthTotal-T.AxesWidthTitle-T.AxesWidthRight2;
T.AxesWidthSepa         =   0.2;  %1

T.AxesHeightTotal       =   10;    % 6
T.AxesHeightTitle1      =  	1.2;
T.AxesHeightTitle2      =   0.8;
T.AxesHeightAbove       =   0.7;   % 0.2
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
        T.AxesXTickRotation =   30;
        T.AxesXLim =            [   1,  126];
        T.AxesXTick =           [0, 25, 50, 75,100,125];
        T.AxesXTickLabel =      {'0', '5', '10', '15', '20', '25'};
        T.AxesXLabel1 =         'Freq (kHz)';
        

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
                'XLim',                 T.AxesXLim,...
                'XTickLabelRotation',   T.AxesXTickRotation,...
                'YGrid',                'on');
        h = xlabel(T.AxesXLabel1);
        set(h, 	'FontSize',                 T.TextLabelFontSize);
        set(h,	'VerticalAlignment',        'Cap');
        % Tightness:  'Bottom' > 'Baseline' > 'Middle' > 'Cap' > 'Top'  
        plot(   data{1,1},... 
                'LineWidth',                T.LineMajorWidth,...
                'Color',                    T.LineColor{1}); 
        title(Title{rowNum, colNum});

    end
end

        
        