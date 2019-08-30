function [ wieEnt, vm ] = wienerEntropy(oneCut)
%WIENERENTROPY Summary of this function goes here
%   Detailed explanation goes here
    oneCut = oneCut - min(min(oneCut))+1;
    m = mean(oneCut,1);
    vm = exp(mean(log(oneCut),1)) ./ m;
    wieEnt = mean(vm);
end

