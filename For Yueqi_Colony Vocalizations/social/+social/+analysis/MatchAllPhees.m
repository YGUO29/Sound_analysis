function [ success ] = MatchAllPhees( pathname,MatchChannel )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
clear global
try
    load(pathname);
    if MatchChannel==1
        t_start{2}=t_start{1};
        t_stop{2}=t_stop{1};
        success=1;
    elseif MatchChannel==2
        t_start{1}=t_start{2};
        t_stop{1}=t_stop{2};
        success=1;
    else
        fprintf('Must input channel 1 or 2.\n');
        success=0;
    end
    save(pathname,'t_start','t_stop','filepath','filename','samplesize','Fs','channels');
catch
    success=0;
end
end

