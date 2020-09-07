function b = binone(n)
% BINONE
% To crete an n-bin vector of evenly spaced points in the interval (0,1)

% Notes:
% - VirtualCall V2.0
% - reference from Dimattina and Wang. JN. 2006 
% - based upon binone by Chris Dimattina 2005
% - by Chia-Jung Chang 2013

% Input:
% - n     - bin number

% Output:
% - b     - vector of evenly spaced points

% ==============================================================================   

b = (0:(n-1))/(n-1);