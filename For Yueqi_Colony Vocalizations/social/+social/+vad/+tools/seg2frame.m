function [ frame ] = seg2frame( seg, frameLenP, shift )
% cut a spectrum into small frames, with a shift factor
% created by Haowen Xu
    frame = {};
    segLen = size(seg,2);
    numOfFrame = floor((segLen-frameLenP)/shift);
    for i = 1 : numOfFrame-1
        frame = [frame; seg(:,shift*(i-1)+1:shift*(i-1)+frameLenP)];
    end

end

