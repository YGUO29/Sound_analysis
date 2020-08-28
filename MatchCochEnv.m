% Generate envelope matched pink noise
% output: newdata is the matched noise, data is the original sound (power
% matched with the new sound)
function [newdata, data] = MatchCochEnv(Sd, plotON)

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
%% cochleogram sum - filter white noise first, then multiply
load('SpecTempParameters_Yueqi.mat')
% figurex;
[coch_sound_ds, coch_sound, P] = getCochleogram_halfcosine(Sd, P, 0); % #channels * #timepoints
% generate new carrier (white noise went through cochlea channels)
Sd_noise.wav = 2.*(rand(length(data),1) - 1/2);
Sd_noise.fs = fs;
[coch_noise_ds, coch_noise, P] = getCochleogram_halfcosine(Sd_noise, P, 0); % #channels * #timepoints

tt = 1/P.env_sr: 1/1/P.env_sr : length(data)/Sd.fs;
CochNoise = zeros(length(t),size(coch_sound_ds,1));
for i = 1:length(P.f)
    env = coch_sound_ds(i,:).^(1/P.compression_factor);
%     env = Mat_env_ds(i,:);
    if length(tt) ~= length(env)
        tt = [0, tt];
    end
    tsin = timeseries(env, tt);
    tsout = resample(tsin, t);
    env = squeeze(tsout.Data);
    carrier = coch_noise(i,:);
%     carrier = sin((2*pi*P.f(i)).*t);
    CochNoise(:,i) = env.*carrier';
end
CochNoise(isnan(CochNoise)) = 0;

% test plot
% figure, plot(coch_sound(100,:)./max(coch_sound(100,:))), pause, 
% hold on,  plot(coch_noise(100,:)./max(coch_noise(100, :))), pause
% hold on, plot(CochNoise(:,100)./max(CochNoise(:,100)))

%% plot envelope and signal together
% figurex([1440         918        1864         420]); hold on
% plot(t, data,'k');
% plot(t, env, 'b'); % hilbert
% plot(t, env2, 'r'); % sum cochleogram
% plot(t, env3, 'm'); % envelope rms
% plot(t, env4, 'c'); % envelope peak
% plot(t, env5, 'g'); % rec+lowfilt
% legend({'Raw signal', 'Hilbert envelope', 'Cochleogram envelope', 'RMS, window 30ms', 'Peak, window 30ms'})
% 
% figurex([1440         918        1864         420]); hold on
% plot(t, data./max(data),'k');
% plot(t, env./max(env), 'b');
% plot(t, env2./max(env2), 'r');
% plot(t, env3./max(env3), 'm');
% plot(t, env4./max(env4), 'c');
% plot(t, env5./max(env5), 'g'); % rec+lowfilt
% legend({'Raw signal', 'Hilbert envelope', 'Cochleogram envelope', 'RMS, window 30ms', 'Peak, window 30ms'})

%% generate pink noise with DSP toolbox
% cn = dsp.ColoredNoise(pow,samp,numChan,Name,Value)
% cn = dsp.ColoredNoise(1,fs,1);
% newdata = [];
% for i = 1:ceil(L/fs)
%     rng default
%     newdata = [newdata; cn()];
% end
newdata = sum(CochNoise,2);
newdata = newdata(1:L);
newdata = newdata./(max(abs(newdata)));
% Sd.wav = newdata; Sd.fs = fs;
% figure, getSpectrogram(Sd,1)
% figure, plot(abs(fft(newdata)))
% newdata =  newdata.*env5;
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
%     figure,
%     subplot(2,3,1), plot(t, data), title('original sound, waveform')
    subplot(2,3,2), semilogx(f(2:end),data_fftamp(2:end)), title('Spectrum')
%     xlim([4e3, 10e3])
%     subplot(2,3,3), plot(data_fftagl), title('original sound, phase')
    
%     subplot(2,3,4), plot(t, newdata), title('PS sound, waveform')
    subplot(2,3,5), semilogx(f(2:end),newdata_fftamp(2:end)), title('Spectrum')
%     xlim([4e3, 10e3])
%     subplot(2,3,6), plot(newdata_fftagl), title('PS sound, phase')
end

if pad_flag % remove the zero padding
    newdata = newdata(1:end-1);
    data = data(1:end-1);
end
end