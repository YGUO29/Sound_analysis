% generate dynamic moving ripple (randomly sampled SM and TM rates)
% Ref: 
% http://www.neural-code.com/index.php/tutorials/stimulus/sound/51-dynamic-moving-ripple
%% Initialization
f0     = 250; % base frequency (Hz)
N     = 128; % # components
fNr   = 0:1:N-1; % every frequency step
f     = f0 * 2.^(fNr/20); % frequency vector (Hz)
dur   = 10; % sound's duration (s)
Fs   = 100000; % sample frequency (Hz)
ns   = round(dur*Fs); % number of time samples
t     = (1:ns)/Fs; % time vector (s);
 
%% Sum carriers, in a for-loop
snd   = 0;
for i = 1:N
  phi     = 2*pi*rand(1); % random phase between 0-2pi
  carrier    = sin( 2*pi * f(i) * t + phi );
  snd      = snd+carrier;
end
snd   = snd/N;
%%
F0      = 250; % base frequency (Hz)
nFreq   = 128; % (octaves)
FreqNr  = 0:1:nFreq-1; % every frequency step
Freq    = F0 * 2.^(FreqNr/20); % frequency vector (Hz)
% ===== 
nTime = 128;

vel   = 4; % omgea (Hz)
dens   = 0; % Omega (cyc/oct)
mod   = 100; % Percentage (0-100%)
durrip   = 1000; %msec
Fs    = 100000; % sample frequency (Hz)
nRip    = round( (durrip/1000)*Fs ); % # Samples for Rippled Noise
time  = ((1:nRip)-1)/Fs; % Time (sec)
Oct     = FreqNr/20;                   % octaves above the ground frequency
oct    = repmat(Oct',1,nTime); % Octave

%% Create amplitude modulations completely dynamic in a loop
A = NaN(nTime,nFreq); % always initialize a matrix
for ii = 1:nTime
  for jj = 1:nFreq
    A(ii,jj)      = 1 + mod*sin(2*pi*vel*time(ii) + 2*pi*dens*oct(jj));
  end
end

% Modulate carrier, in a for-loop
snd = 0;
for ii = 1:nFreq
  carr      = A(:,ii)'.*sin(2*pi* Freq(ii) .* time + phi(ii));
  snd        = snd+carr;
end

figure
t = (1:length(snd))/Fs;
subplot(221)
plot(t,snd,'k-')
ylabel('Amplitude (au)');
ylabel('Time (ms)');
xlim([min(t) max(t)]);
axis square;
box off;
 
subplot(223)
nfft = 2^11;
window      = 2^7; % resolution
noverlap    = 2^5; % smoothing
spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
cax = caxis;
caxis([0.7*cax(1) 1.1*cax(2)])
ylim([min(Freq) max(Freq)])
set(gca,'YTick',(1:2:20)*1000,'YTickLabel',1:2:20);
axis square;
 
subplot(224)
pa_getpower(snd,Fs,'orientation','y'); % obtain from PandA
ylim([min(Freq) max(Freq)])
ax = axis;
xlim(0.6*ax([1 2]));
set(gca,'Yscale','linear','YTick',(1:2:20)*1000,'YTickLabel',1:2:20)
axis square;
box off;