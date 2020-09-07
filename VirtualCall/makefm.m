function F = makefm(len, tkn, fkn, t1bk, t1ak, f1bk, f1ak, fst, fsp)
% MAKEFM
% To make the FM contour for twitter phrases

% Notes:
% - VirtualCall V2.0 
% - reference from Dimattina and Wang. JN. 2006 
% - based upon makefm by Chris Dimattina 2005
% - by Chia-Jung Chang 2013

% Modifications:
% - remove original low-pass filtering function

% Inputs: 
% - len 	- length of contours in points 
% - tkn 	- fractional time of 'knee' point               ([0,1])
% - fkn 	- fractional freq of 'knee' point               ([0,1])
% - t1bk	- normalized time points before tkn, 25D vector ([0,1])
% - t1ak	- normalized time points after tkn, 10D vector  ([0,1])
% - f1bk 	- normalized freq contour before knee           ([0,1])
% - f1ak 	- normalized freq contour after knee            ([0,1])
% - fst 	- starting frequency vector    					(Hz)
% - fsp 	- ending frequency vector    					(Hz)

% Outputs:
% - F       - FM countour

% ==============================================================================   

% Set up time points and frequency contour vector 
% Ref: (p. 1250) and (p. 1251) in Dimattina and Wang. JN. 2006
t1bk = t1bk*tkn;
t1ak = tkn + t1ak*(1-tkn);
t1 = [t1bk, t1ak];
fkn = fst + (fsp-fst)*fkn;
f1bk = fst + (fkn-fst)*f1bk;
f1ak = fkn + (fsp-fkn)*f1ak;
f1 = [f1bk, f1ak];

% Enforce strictly increasing requirement
d = diff(f1); 
k = find(d<0);
t1(k+1) = NaN;
f1(k+1) = NaN;
t1 = t1(find(1-isnan(t1)));
f1 = f1(find(1-isnan(f1)));

% Insert first and last points at t=0 and t=1
% Extrapolate first and last freq points 
dfst = (f1(2)-f1(1))/(t1(2)-t1(1));
dfsp = (f1(end)-f1(end-1))/(t1(end)-t1(end-1));     
f1st = f1(1) - dfst*t1(1);
f1sp = f1(end) + dfsp*(1-t1(end));
t1 = [0, t1, 1];
f1 = [f1st, f1, f1sp];
x = (0:len-1)/(len-1);
F = zeros(1, len);

% Define frequency contour
% Ref: (Eq. 25) in Dimattina and Wang. JN. 2006
for k = 1:length(t1)-1
    [~, i] = min(abs(x-t1(k)));
    [~, j] = min(abs(x-t1(k+1)));
    F(i:j) = f1(k)+ ((f1(k+1)-f1(k))/(t1(k+1)-t1(k)))*(x(i:j)-x(i));
end

