% Generate envelope matched pink noise
% output: newdata is the matched noise, data is the original sound (power
% matched with the new sound)
function [newdata, data] = MatchEnv(Sd, plotON)

data = Sd.wav;
fs = Sd.fs; 
pad_flag = 0;
if mod(length(data), 2) % if signal is odd
    data = [data; 0];
    pad_flag = 1;
end

L = length(data);
T = 1/fs;
t = (0:L-1)*T;
data_fft = fft(data, L);
data_fftamp = abs( data_fft/L );
data_fftagl = angle(data_fft);
env = abs(hilbert(data));


%% ======= generate pink noise =========
% L = length(data);
% L = 2*fs;
% f = linspace(1,fs/2,L/2-1); 
% amp_half1 = 1./sqrt(f);
% amp_half2 = fliplr(amp_half1);
% amp = [0, amp_half1, 0, amp_half2];
% phase_half1 = (2.*rand(1,L/2-1) - 1).*pi;
% phase_half2 = -fliplr(phase_half1);
% phase = [pi, phase_half1, -pi, phase_half2];
% 
% % % ========= generate sound ==========
% noise = real(ifft(amp.*exp(1i.*phase)));
% noise = noise./max(abs(noise));
% Sd.wav = noise; Sd.fs = fs;
% figure, getSpectrogram(Sd,1)
% figure, plot(abs(fft(noise)))
% soundsc(noise,fs)
% newsound = noise'.*env;
%% generate pink noise with DSP toolbox
% cn = dsp.ColoredNoise(pow,samp,numChan,Name,Value)
cn = dsp.ColoredNoise(1,fs,1);
newdata = [];
for i = 1:ceil(L/fs)
    rng default
    newdata = [newdata; cn()];
end
newdata = newdata(1:L);
newdata = newdata./(max(abs(newdata)));
% Sd.wav = newdata; Sd.fs = fs;
% figure, getSpectrogram(Sd,1)
% figure, plot(abs(fft(newdata)))
newdata =  newdata.*env;
%% normalize & fourier analysis
std_norm = min(std(data), std(newdata)); %normalize power to the lower one
newdata = newdata.*(std_norm./std(newdata));
data = data.*(std_norm./std(data));
% fourier analysis of original sound
f                           = fs*(0:(L/2))/L;
data_fftamp                 = data_fftamp(1:L/2+1);
data_fftamp(2:end-1,:,:)    = 2*data_fftamp(2:end-1);
data_fftamp                 = data_fftamp./repmat(data_fftamp(1,:),[floor(L/2)+1,1]); % normalized to mean amplitude

% fourier analysis of new sound
newdata_fft = fft(newdata, L);
newdata_fftamp = abs( newdata_fft/L );
newdata_fftagl = angle(newdata_fft);
newdata_fftamp                 = newdata_fftamp(1:L/2+1,:);
newdata_fftamp(2:end-1,:,:)    = 2*newdata_fftamp(2:end-1,:);
newdata_fftamp                 = newdata_fftamp./repmat(newdata_fftamp(1,:),[floor(L/2)+1,1]); % normalized to mean amplitude

%% plot
if plotON
    figure,
    subplot(2,3,1), plot(t, data), title('original sound, waveform')
    subplot(2,3,2), semilogx(f(2:end),data_fftamp(2:end)), title('original sound, spectrum')
%     xlim([4e3, 10e3])
    subplot(2,3,3), plot(data_fftagl), title('original sound, phase')
    
    subplot(2,3,4), plot(t, newdata), title('PS sound, waveform')
    subplot(2,3,5), semilogx(f(2:end),newdata_fftamp(2:end)), title('PS sound, spectrum')
%     xlim([4e3, 10e3])
    subplot(2,3,6), plot(newdata_fftagl), title('PS sound, phase')
end

if pad_flag % remove the zero padding
    newdata = newdata(1:end-1);
    data = data(1:end-1);
end
end