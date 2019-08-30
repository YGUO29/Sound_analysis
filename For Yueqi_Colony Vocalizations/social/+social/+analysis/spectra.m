function [spec,x,y] = spectra(sig,winsize,shift,Fs,ord,varargin)
% calculate the spectrogram (power spectrum, not amplitude)
% [spec,x,y] = spectra(sig,winsize,shift,Fs,ord,varargin)
% winsize defines window length
% shift defines timebins
% varargin{1}: window type
% varargin{2}: do_plot? 1 for yes; 0 for no
nseg = floor((length(sig) - winsize)/shift)+1;
A = zeros(winsize/2+1,nseg);
do_plot = 0;
if nargin >= 6
    win_name = varargin{1};
    if nargin == 7
        do_plot = varargin{2};
    end
else
%     win_name = 'hamming';
    win_name = 'hann';          % changed to hanning window 10/04/2014
end
h_win = str2func(win_name);

for i = 1:nseg
	n1 = (i-1)*shift+1;
	n2 = n1+(winsize-1);
	xx = sig(n1:n2);
	xx = xx.*window(h_win,winsize);
	y = fft(xx);
	y = y(1:winsize/2+1);
    y = y.*conj(y);
    if strcmp(ord,'log')
        y = 10*log10(y);
    end
    
    A(:,i)=y;

end

% L1 = (A>base);
% L0 = (A<base);
% B = A.*L1+base*L0;
spec = A;
% B = A;
% C = min(A,15);


y = [0:winsize/2]*Fs/winsize/1000;
x = [0:nseg-1]*shift/Fs;

if do_plot
    figure(33)
    colormap(jet);
    imagesc(x,y,A);
    axis xy;
    xlabel('Time (s)');
    ylabel('Freq (kHz)');
    title('Spectrogram');
    colorbar;
end
