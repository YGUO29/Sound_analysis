classdef curveForFP < handle
    % The object of this class contains the data which is ready to be
    % plotted in one axis
    properties(Access = public)
        flag;
    end
    properties(Access = private)
        title;
        numOfCurve;
        dataY;
        dataX;
        legend;
        lenOfData;
        XTick;
        XTickLabel;
        YTick;
        YTickLabel;
        XLabel;
        YLabel;
        lenOfXTick;
        lenOfYTick;
    end
    
    methods
        % ----------------------------
        % initialize
        function self = curveForFP(numOfCurve)
            self.numOfCurve = numOfCurve;
            for i = 1 : numOfCurve
                self.dataY{i} = [];
                self.lenOfData(i) = 0;
                self.legend{i} = '';
            end
            self.XTick = [];
            self.XTickLabel = {};
            self.YTick = [];
            self.YTickLabel = {};
            self.lenOfXTick = 0;
            self.lenOfYTick = 0;
            self.XLabel = '';
            self.YLabel = '';
        end
        
        
        
        function setData(self, dataY, dataX)
            if nargin < 3
                % if data is an array, convert it to a cell
                if (~iscell(dataY))
                    dataY = mat2cell(dataY,ones(1,size(dataY,1)),size(dataY,2));
                end

                M = length(dataY);
                if (M ~= self.numOfCurve)
                    disp('error: wrong num of curves in data');
                    return
                end
                for i = 1 : M
                    self.dataY{i} = dataY{i};
                    self.dataX{i} = 1:length(dataY{i});
                    self.lenOfData(i) = length(dataY{i});
                end
            else
                if (~iscell(dataY))
                    dataY = mat2cell(dataY,ones(1,size(dataY,1)),size(dataY,2));
                end
                if (~iscell(dataX))
                    dataX = mat2cell(dataX,ones(1,size(dataX,1)),size(dataX,2));
                end
                M = length(dataY);
                if (M ~= self.numOfCurve)
                    disp('error: wrong num of curves in data');
                    return
                end
                for i = 1 : M
                    self.dataY{i} = dataY{i};
                    self.dataX{i} = dataX{i};
                    self.lenOfData(i) = length(dataY{i});
                    if length(dataY{i}) ~= length(dataX{i})
                        disp(['error: size dismatch in dataset', num2str(i)]);
                        return
                    end
                end
            end
        end        
        
        function setLegend(self, legend)
            M = length(legend);
            if (M ~= self.numOfCurve)
                disp('error: wrong num of legends');
                return
            end
            self.legend = legend;
        end
        
        function setXTick(self, XTick, XTickLabel)
            self.XTick = XTick;
            self.XTickLabel = XTickLabel;
        end
        
        function setYTick(self, YTick, YTickLabel)
            self.YTick = YTick;
            self.YTickLabel = YTickLabel;
        end
        
        function setXLabel(self, XLabel)
            self.XLabel = XLabel;
        end
        
        function setYLabel(self, YLabel)
            self.YLabel = YLabel;
        end
        
        function setTitle(self, title)
            self.title = title;
        end
        
         % ---------------------------------
        
        function legend = getLegend(self,i)
            if nargin > 1
                legend = self.legend{i};
            else
                legend = self.legend;
            end
        end
        
        function XTick = getXTick(self)
            XTick = self.XTick;
        end
        
        function YTick = getYTick(self)
            YTick = self.YTick;
        end
                
        function XTickLabel = getXTickLabel(self)
            XTickLabel = self.XTickLabel;
        end
        
        function YTickLabel = getYTickLabel(self)
            YTickLabel = self.YTickLabel;
        end
        
        function XLabel = getXLabel(self)
            XLabel = self.XLabel;
        end
        
        function YLabel = getYLabel(self)
            YLabel = self.YLabel;
        end
        
        function numOfCurve = getNumOfCurve(self)
            numOfCurve = self.numOfCurve;
        end
        
        function title = getTitle(self)
            title = self.title;
        end
        
        function XMin = getXMin(self)
            XMin = min(self.dataX{1});
            for i = 2 : self.numOfCurve
                XMin_temp = min(self.dataX{i});
                if XMin_temp < XMin
                    XMin = XMin_temp;
                end
            end
        end
        
        function XMax = getXMax(self)
            XMax = max(self.dataX{1});
            for i = 2 : self.numOfCurve
                XMax_temp = max(self.dataX{i});
                if XMax_temp > XMax
                    XMax = XMax_temp;
                end
            end
        end
        
        function YMin = getYMin(self)
            YMin = min(self.dataY{1});
            for i = 2 : self.numOfCurve
                YMin_temp = min(self.dataY{i});
                if YMin_temp < YMin
                    YMin = YMin_temp;
                end
            end
        end
         
        function YMax = getYMax(self)
            YMax = max(self.dataY{1});
            for i = 2 : self.numOfCurve
                YMax_temp = max(self.dataY{i});
                if YMax_temp > YMax
                    YMax = YMax_temp;
                end
            end
        end
        
        function x = getDataX(self,i)
            x = self.dataX{i};
        end
        
        function y = getDataY(self,i)
            y = self.dataY{i};
        end
        
    end
    
end

