% Short term Fourier analysis using a Hamming window:
windowdur = 0.005; dBdynrange = 70; maxfreq = 7;
% 30 ms window length
% dB dynamic range of the color axis 
% Maximum frequency in the plot (kHz)
lengthwindow = round(windowdur*fs); % Number of samples per window
lengthoverlap = round(lengthwindow/2); % Overlap the windows by 50% to smooth the plot 
nwind = floor((length(yy)-lengthwindow)/lengthoverlap); % Number of windows in the signal 
ftyy = zeros(floor(lengthwindow/2), nwind); % Storage

for jw=1:nwind
n1 = 1+(jw-1)*lengthoverlap; n2 = n1 + lengthwindow - 1; % The samples included in this window (the jwth) 
yyw = yy(n1:n2).*hamming(lengthwindow); % Isolate & window a segment
ftyyw = fft(yyw); % Fourier transform
ftyy(:,jw) = abs(ftyyw(1:floor(lengthwindow/2))); % Save |FFT| for 0 to pi 
end

% Plot the spectrogram
timax = windowdur/2 + [0:1:nwind-1]*lengthoverlap/fs; % Times at the center of bins 
freqax = [0:1:floor(lengthwindow/2)-1]*fs/(1000*lengthwindow); % Frequency scale in kHz 
ftyymax = max(max(ftyy)); % Maximum value in the spectrogram
ftyymin = ftyymax/(10^(dBdynrange/20)); 
% SETS the dynamic range of the color plot and prevents log(0) errors below. 
ftyydB = 20*log10(max(ftyy, ftyymin)); % Convert to dB
figure(1); clf;
imagesc(timax, freqax, ftyydB); % Plot a 3D color plot
axis('xy') % Put the origin at the lower left
xlabel('Time, s.','fontsize',18); ylabel('Frequency, kHz','fontsize',18); colorbar % Make it pretty 
av = axis; axis([av(1:2), 0 maxfreq]); % Limit the ordinate frequency

%====== define labels and title =======
set(gca,'ytick',[4,7,14,21],'fontsize',14)
title('Consonant melody (Low F0)','fontsize',18)

