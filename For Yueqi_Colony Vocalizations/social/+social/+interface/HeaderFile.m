classdef HeaderFile < social.interface.Filer & social.interface.Social & matlab.mixin.Heterogeneous
    % FileInterface - The FileInterface object stores the path and filename 
    % for a file containing some sort of relevant information such as 
    % header, signal, event, or other data.
    %
    % Written by Seth Koehler and Lingyun Zhao, 3/2015.
    
    properties (Abstract = true)
        Header
    end
end

