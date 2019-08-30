function [ bank ] = my_melbank()
%MY_MELBANK Summary of this function goes here
%   Detailed explanation goes here
    bank = zeros(24,126);
    f = [1,10,20,25,28,30,32,33,34,35,36,37,38,39,40,42,44,46,48,50,55,60,70,85,105,126];              
    for i = 1:24
        bank(i,:) = social.vad.tools.win_triangle(f(i),f(i+2),126,1);
    end


end

