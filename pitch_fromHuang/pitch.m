function [pit,sal,pitches,c] = pitch(S,f,fname,npeak)
% [pit,sal,pitches,c] = pitch(S,f,fname);
%
% pitch: compute pitch from auditory spectrogram 
%
% INPUTS
% S: auditory spectrogram
% f: freqencies corresponding to the rows of S
% fname: file name where pitch templates are kept
%
% OUTPUTS
% pit: pitch estimate
% sal: saliency of pitch estimate
% pitches: matrix of correlation peaks and values
% c: cross-correlation functions

if ~exist('npeak','var'), npeak = 1; end

[m,n] = size(S);
% m = # channels; n = # time samples
c = zeros(m,n); % template crosscorrelation result
ver = version;

eval(['load ' fname]) % Loads the harmonic templates (ts)
 
% dim1: xcorr leng; dim2: time samples
temp = zeros(2*max(size(ts,1),m)-1,n);

for j = 1:n, % for each time
 if str2num(ver(1)) >= 6,
  temp(:,j) = flipud(xcorr(ts,S(:,j)));  % compute cross correlation
 else
  temp(:,j) = xcorr(ts,S(:,j));
 end
end
% recenter to pitch coordinates
c = temp((size(ts,1)-pad)+1:(size(ts,1)-pad)+m,:);

%npeak = 1;  % # of simultaneous pitches to look for
th = 0.5;   % A threshold factor
pitches = zeros(m,n);

for tx = 1:n,

 slice = c(:,tx);

 % Relative threshold -- masking effect
 slice = max(slice-th*max(slice,[],1),0);
 
 % Peaks are then selected within each channel
 [ch,peak] = pickpeaks(slice,npeak);
 
 % Sharpening and normalization
 if sum(slice,1)
    salmap = peak.^2./sum(slice,1);
 else
    salmap = peak.^2;
 end

 % Here the npeak highest peaks are selected
 pitches(ch(find(ch)),tx) = salmap(find(ch));

end

% This is the highest peak - the dominant pitch
[a,b] = max(pitches,[],3);
[sal,pit] = max(a,[],1);

pit = f(min(pit+1,length(f))); % hack... this should be taken care of by ts
pit = pit(:);
sal = sal(:);

