classdef Social < handle
    % SocialInterface - A Social package interface must be able to generate
    % a report about itself, tabluate itself, and display information about 
    % itself to the command window.
    %   
    % Written by Seth Koehler and Lingyun Zhao, 3/2015.
    
    methods (Abstract)
        str = Report(self)
        % Return a formatted report (nx1 cellstr) summarizing object information.
        
        tab = Tabulate(self)
        % Return a table summarizing object information.
    end
    methods
%         function disp(self)
%             str=self.Report;
%             for i=1:length(str)
%                 disp(char(str))
%             end
%         end
    end
end

