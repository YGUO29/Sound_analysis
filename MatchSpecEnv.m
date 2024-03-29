% phase scramble sound 
% output: newdata is the scrambled sound, data is the original sound (power
% matched with the new sound)
function [newdata, data] = MatchSpecEnv(Sd, plotON)

data = Sd.wav;
fs = Sd.fs; 
pad_flag = 0;
if mod(length(data), 2)
    data = [data; 0];
    pad_flag = 1;
end

L = length(data);
T = 1/fs;
t = (0:L-1)*T;
data_fft = fft(data, L);
data_fftamp = abs( data_fft/L );
data_fftagl = angle(data_fft);
% data_ifft = real(ifft(data_fftamp.*exp(1i.*data_fftagl)));

% generate envelope by hilbert (do not use this for wide-band sound)
% env = abs(hilbert(data));
% generate envelope by low-pass filtering
data_rec = data;
data_rec(data<0) = -data(data<0);
d = designfilt('lowpassiir',...
                'FilterOrder', 3,...
                'PassbandFrequency', 80,... % this 160Hz was used in Shannon 2001
                'SampleRate', fs);
% fvtool(d)
env = filtfilt(d,data_rec); 

%% generate scrambled sound
angles = data_fftagl(2:L/2);
angles_new = angles(randperm(length(angles)));
data_fftagl_new = data_fftagl;
data_fftagl_new(2:L/2) = angles_new;
data_fftagl_new(L/2+2:end) = -flipud(angles_new); % the new angles are also symmetric

newdata = real(ifft(data_fftamp.*exp(1i.*data_fftagl_new))); % imagery part is ~16 orders less than real part
newdata =  newdata.*env;

newdata = newdata./max(abs(newdata));
% figure, plot(data_ifft_new)

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
    xlim([4e3, 10e3])
    subplot(2,3,3), plot(data_fftagl), title('original sound, phase')
    
    subplot(2,3,4), plot(t, newdata), title('PS sound, waveform')
    subplot(2,3,5), semilogx(f(2:end),newdata_fftamp(2:end)), title('PS sound, spectrum')
    xlim([4e3, 10e3])
    subplot(2,3,6), plot(newdata_fftagl), title('PS sound, phase')
end

if pad_flag % remove the zero padding
    newdata = newdata(1:end-1);
    data = data(1:end-1);
end
end