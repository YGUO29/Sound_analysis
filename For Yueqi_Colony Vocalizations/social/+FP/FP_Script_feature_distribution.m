%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('+FP\feature_distribution.mat');
data = data_dist;
Title = cell(3,2);
Title{1,1} = '(A) energyDiff';
Title{1,2} = '(B) energyPar';
Title{2,1} = '(C) energyDiffWireless';
Title{2,2} = '(D) energyParWireless';
Title{3,1} = '(E) AHR';
Title{3,2} = '';
%}
%% (1) Load Data & Define Parameters
LAYOUT                  =   [3,2];
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
        if (rowNum == 3) && (colNum == 2) 
            continue;
        end
        T.AxesXTickRotation =   30;

        T.AxesYLabel1 =         'PDF';
        
        T.LineNum1 =            2;
        T.LineColor{1} =        [   31  119 180 ]/256;
        T.LineColor{2} =        [   254 127 14  ]/256;
        T.LineColor{3} =        [   44  160 44  ]/256;
        T.LineColor{4} =        [   214 39  40  ]/256;
        T.LineLegend =          {'target call','non-target call'};

        T.AxesCurWidthStart =   (colNum - 1) * (T.AxesWidthTotal+T.AxesWidthSepa) + T.AxesWidthTitle;
        T.AxesCurHeightStart =  T.FigHeight - rowNum * T.AxesHeightTotal - ...
                                (rowNum - 1) * T.AxesHeightSepa + T.AxesHeightTitle1;

        % plot                  
        T.H.Axes{rowNum,colNum} = axes(...
                'parent',               T.H.Fig,...
                'position',             [   T.AxesCurWidthStart,    T.AxesCurHeightStart,...
                                            T.AxesWidth1,           T.AxesHeight1],...
                'YGrid',                'on');  	
        h = ylabel(T.AxesYLabel1);
        set(h, 	'FontSize',                 T.TextLabelFontSize);
        set(h,	'VerticalAlignment',        'Baseline');
        % Tightness:  'Bottom' < 'Baseline' < 'Middle' < 'Cap' < 'Top'         
        plot(   data{(rowNum-1)*2+colNum,1}(1,:),...
                data{(rowNum-1)*2+colNum,1}(2,:),...
                'LineWidth',                T.LineMajorWidth,...
                'Color',                    T.LineColor{1}); 
        plot(   data{(rowNum-1)*2+colNum,2}(1,:),...
                data{(rowNum-1)*2+colNum,2}(2,:),...
                'LineWidth',                T.LineMajorWidth,...
                'Color',                    T.LineColor{2});
        title(Title{rowNum,colNum});
        legend(T.LineLegend,'Location','NorthEast');    
    end
end
        
        