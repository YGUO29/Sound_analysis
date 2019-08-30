function [ data ] = normMeanVar( data )
%NORMMEANVAR Summary of this function goes here
%   Detailed explanation goes here
    Mean = mode(data(:));
    Var = var(data(:));
    data = (data-Mean)/Var;
    dataMax = max(max(abs(data)));
    data = data/dataMax;
end

