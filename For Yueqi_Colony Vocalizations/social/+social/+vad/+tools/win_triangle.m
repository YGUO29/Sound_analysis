function [ win ] = win_triangle( start, stop, len, amp )
%TRIANGLE Summary of this function goes here
%   Detailed explanation goes here
    win = zeros(1,len);
    midLeft = floor((start + stop)/2);
    if midLeft < ceil(start+stop)/2
        midRight = midLeft + 1;
    else
        midRight = midLeft;
    end
    win(start:midLeft) = (0 : (midLeft-start))/(midLeft-start);
    win(midRight:stop) = ((stop-midRight) :-1: 0)/(stop-midRight);
    win = win * amp;
end

