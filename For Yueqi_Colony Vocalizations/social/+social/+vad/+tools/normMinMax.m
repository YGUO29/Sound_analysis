function [ data ] = normMinMax( data, normMin, normMax )
%NORMMINMAX Summary of this function goes here
%   Detailed explanation goes here
    dataMin = min(min(data));
    dataMax = max(max(data));
    data = (data - dataMin) / (dataMax - dataMin);
    data = data * (normMax - normMin) + normMin;
end

