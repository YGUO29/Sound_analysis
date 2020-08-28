function [ftx] = getSpectrogram(S,plotON,varargin)

% Short term Fourier analysis using a Hamming window:
if isempty(varargin)
    windowdur = 0.03; 
else
    windowdur = varargin{1};
end

if size(S.wav,1) == 1 % S.wav has to be a column vector
    S.wav = S.wav';
end

dBdynrange = 70; ftx.maxfreq = S.fs/2/1000;
% 30 ms window length
% dB dynamic range of the color axis 
% Maximum frequency in the plot (kHz)
lengthwindow = round(windowdur*S.fs); % Number of samples per window
lengthoverlap = round(lengthwindow/2); % Overlap the windows by 50% to smooth the plot 
nwind = floor((length(S.wav)-lengthwindow)/lengthoverlap); % Number of windows in the signal 
ftyy = zeros(floor(lengthwindow/2), nwind); % Storage

for jw=1:nwind
n1 = 1+(jw-1)*lengthoverlap; 
n2 = n1 + lengthwindow - 1; % The samples included in this window (the jwth) 
yyw = S.wav(n1:n2).*hamming(lengthwindow); % Isolate & window a segment
ftyyw = fft(yyw); % Fourier transform
ftyy(:,jw) = abs(ftyyw(1:floor(lengthwindow/2))); % Save |FFT| for 0 to pi 
end

% Plot the spectrogram
ftx.TimeAx = windowdur/2 + [0:1:nwind-1]*lengthoverlap/S.fs; % Times at the center of bins 
ftx.FreqAx = [0:1:floor(lengthwindow/2)-1]*S.fs/(1000*lengthwindow); % Frequency scale in kHz 

ftyymax = max(max(ftyy)); % Maximum value in the spectrogram
ftyymin = ftyymax/(10^(dBdynrange/20)); 
% SETS the dynamic range of the color plot and prevents log(0) errors below. 
ftx.ftyydB = 20*log10(max(ftyy, ftyymin)); % Convert to dB

if plotON
%     figure;
    imagesc(ftx.TimeAx, ftx.FreqAx, ftx.ftyydB); % Plot a 3D color plot
    axis('xy') % Put the origin at the lower left
    xlabel('Time, s.'); ylabel('Frequency, kHz'); colorbar % Make it pretty 
%     xlabel('Time, s.','fontsize',10); ylabel('Frequency, kHz','fontsize',10); colorbar % Make it pretty 
    av = axis; axis([av(1:2), 0 ftx.maxfreq]); % Limit the ordinate frequency
    %====== define labels and title =======
    set(gca,'ytick',[4,7,14,21])
%     title(['Spectrogram, ',strrep(S.SoundName, '_', '-')],'fontsize',10)
end

end

