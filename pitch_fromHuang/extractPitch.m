function [blog,pit,sal,pitches,cs] = extractPitch(xt, fs, paras, preEmp)
% function for extracting pitch for an acoustic signal xt
% input
%   xt = input acoustic @fs
%   fs = sampling freq of xt, default = 8kHz
%   paras = parameters for wav2aud.m, default (see below)
%   preEmp = pre-emphasis flag, default = 0
% [Charley, Jun 2010]
% =============================================================

% Parameters %
if ~exist('fs','var') | fs == []; fs = 8000; end
if ~exist('paras','var') | paras == []
    paras = [16 16 -2 log2(fs/16000)];
end
cf = cochfil(1:129,paras(4)); 	% Center frequencies 
if ~exist('preEmp','var'); preEmp = 0; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pre-Emphasis
if preEmp 
    xt0 = xt;
    xt = filter([1 -0.97],1,xt);
end

% the auditory spectrogram
blog = wav2aud(xt,paras)';

% Get pitch and saliency values
th = exp(mean(log(max(blog(:),1e-3)))); % noise floor
blog = log(max(blog,th)) - log(th);
[pit,sal,pitches,cs] = pitch(blog,cf(1:end-1),'pitlet_templates');

return;