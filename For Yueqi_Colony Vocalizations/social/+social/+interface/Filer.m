classdef Filer < handle
    % FileInterface - The FileInterface object stores the path and filename 
    % for a file containing some sort of relevant information such as 
    % header, signal, event, or other data.
    %
    % Written by Seth Koehler and Lingyun Zhao, 3/2015.
    
    properties %(Access = private)
        DataPath = {''};
        RelativePath
        Filename
        Extension
    end
   
    properties
        File
    end
    
    methods
        % Set the DataPath to the supplied path.
        function set.DataPath(self,value)
            % TODO: add error checking.
            self.DataPath={value};
        end
        function value=get.DataPath(self)
            value=self.DataPath{1};
        end
            
        
        % Supply a relative path and filename
        function set.File(self,value)
            [p f e]=fileparts(value);
            
            % TODO: Handle if the full path is supplied.
            self.RelativePath = p;
            self.Filename  = f;
            self.Extension = e;
        end
        function value = get.File(self)
            value = fullfile(self.DataPath,self.RelativePath,[self.Filename self.Extension]);
            value=value;
        end
    end
end

