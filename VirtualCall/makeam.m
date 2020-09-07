function A = makeam(len, tkn, t1bk, t1ak, a1bk, a1ak)
% MAKEAM
% To create a phrase amplitude envelope A

% Notes:
% - VirtualCall V2.0 
% - reference from Dimattina and Wang. JN. 2006 
% - based upon makeam by Chris Dimattina 2005
% - by Chia-Jung Chang 2013

% Modifications:
% - remove original low-pass filtering function 

% Inputs: 
% - len 	- length of contours in points 
% - tkn 	- fractional time of 'knee' point               ([0,1])
% - t1bk	- normalized time points before tkn, 25D vector ([0,1])
% - t1ak	- normalized time points after tkn, 10D vector  ([0,1])
% - a1bk	- AM1 contour points before tkn                 ([0,1])
% - a1ak	- AM1 contour points after tkn                  ([0,1])

% Outputs:
% - A       - amplitude envelope

% ==============================================================================   

% Set up time points and amplitude contour vector 
% Ref: (p. 1250) in Dimattina and Wang. JN. 2006
t1bk = t1bk*tkn;
t1ak = tkn + t1ak*(1-tkn);
t1 = [t1bk, t1ak];
a1 = [a1bk, a1ak];
t1 = [0, t1, 1];
a1 = [0, a1, 0];
x = (0:len-1)/(len-1);
A = zeros(1, len);

% Define amplitude contour
% Ref: (Eq. 23) in Dimattina and Wang. JN. 2006
for k = 1:length(t1)-1
    [~, i] = min(abs(x-t1(k)));
    [~, j] = min(abs(x-t1(k+1)));
    A(i:j) = a1(k) + ((a1(k+1)-a1(k))/(t1(k+1)-t1(k)))*(x(i:j)-x(i));
end


