function str = disp_str(var)
% toString Output what is displayed to the command window when calling disp to a cell 
% array of strings.
func = @(var) evalc(['disp(var)']);
str=func(var);
str=strsplit(str,{'   '})';
str=strtrim(str);
str{1}=[];
end

