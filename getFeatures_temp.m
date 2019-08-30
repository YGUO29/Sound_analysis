% Sound analysis temp
folder_sound = 'D:\=code=\McdermottLab\sound_natural\';
% folder_sound = 'D:\=sounds=\Voc_jambalaya\Natural with Voc\';
list = dir(fullfile(folder_sound,'*.wav'));
names_sound = natsortfiles({list.name})';

% select a sound to load, plot time trace

% Sd.SoundName ='stim52_car_alarm.wav';
Sd.SoundName = [];
if isempty(Sd.SoundName)
    iSound = I_inorder(1,4);
    Sd.SoundName = names_sound{iSound};
else
    [~,iSound] = ismember(Sd.SoundName,names_sound);  
end
filename = [folder_sound,Sd.SoundName];
[Sd.wav,Sd.fs] = audioread(filename);
% 
% for iSound = 50
%     Sd.SoundName = names_sound{iSound};
%     filename = [folder_sound,Sd.SoundName];
%     [Sd.wav,Sd.fs] = audioread(filename);
%     getFeatures_sam;
%     iSound
% end


% figure,
% n = length(S.wav);
% t = (0:(n-1))/fs;
% plot(t,x),xlabel('time (second)'),
% title(strrep(names_sound{iSound}, '_', '-'))

% ===== Spectrum analysis =====
% y = fft(x,n);
% f = fs*(0:n/2)/n;
% P = (abs(y).^2)/n;
% figure,plot(f,P(1:n/2+1))

%% ========= Spectrogram =========
% code modified based on Eric Young's code provided in SBE2
windur = 0.01; % window duration in units of second
plotON = 1;
[ftx] = getSpectrogram(Sd, plotON, windur);
% windur: if empty, default is 0.03s

%% ======== Cochleogram ========
global F
windur = 0.01;
mode = 'log'; % log or linear, or ERB scale
plotON = 1;
figure,subplot(2,1,1)
[F.CochEnv, F.CochEnv_ds, F.CochEnv_dB, F.cf, F.t_ds]  =  getCochleogram(Sd, windur, mode, plotON);
% ======= Frequency measures =====
plotON = 1;
subplot(2,1,2)
FreqPower = getFreqPower(F.CochEnv, F.cf, plotON);

% cochleogram moments
addpath(genpath('D:\=code=\McdermottLab\toolbox_spectrotemporal-synthesis-v2-master'))
M.coch_env = moment_measures(F.CochEnv,2);
% figure,plot(M.coch_env(:,1))
% spectral and temporal modulation

addpath(genpath('D:\=code=\McdermottLab\toolbox_spectrotemporal-synthesis-v2-master'))
load('parameters_PLoSBio2018.mat', 'P');
% resample if needed
P.audio_sr = 44100;
P.t = F.t_ds;
P.f = F.cf;
% P.logf_spacing = F.cf(2) - 

% computes the first four moments of the filter responses:
% (1) mean (2) variance (3) skew (4) kurtosis
tic
M = all_filter_moments_from_coch(F.CochEnv_ds', P, 1:size(F.CochEnv_ds',1));
toc

% pick out mean of cochlear, standard deviation of all other feats
F.coch_env = M.coch_env(:,1);
F.temp_mod = sqrt(M.temp_mod(:,:,2));
F.spec_mod = sqrt(M.spec_mod(:,:,2));
F.spectemp_mod = sqrt(M.spectemp_mod(:,:,:,2));

% split out negative and positive temporal rates
% corresponding to upward and downward modulated ripples
% for prediction negative and positive rates were averaged
dims = size(F.spectemp_mod);
F.spectemp_mod = reshape(F.spectemp_mod, [dims(1), dims(2)/2, 2, dims(3)]);
%% Plot results

% plot average envelopes (spectrum-like measure)
figure;
semilogx(P.f, F.coch_env);
% xlim([50, 10e3]);
xlabel('Frequency (Hz)');
set(gca, 'FontSize', 20);

% plot temporal modulation
figure;
imagesc(F.temp_mod');
temp_mod_rates_without_DC = P.temp_mod_rates(P.temp_mod_rates>0);
freqs_to_plot = [100 400 1600 6400];
fticks = interp1(P.f, length(P.f):-1:1, freqs_to_plot);
set(gca, 'YTick', fliplr(fticks), 'YTickLabel', fliplr(freqs_to_plot)/1000);
set(gca, 'XTick', [2,4,6,8], 'XTickLabel', round(temp_mod_rates_without_DC([2,4,6,8])))
set(gca, 'FontSize', 20);
ylabel('Audio frequency (kHz)');
xlabel('Rate (Hz)')
title('Temporal modulation');

% plot spectral modulation
figure;
imagesc(F.spec_mod');
freqs_to_plot = [100 400 1600 6400];
fticks = interp1(P.f, length(P.f):-1:1, freqs_to_plot);
set(gca, 'YTick', fliplr(fticks), 'YTickLabel', fliplr(freqs_to_plot)/1000);
set(gca, 'XTick', [2,4,6], 'XTickLabel', P.spec_mod_rates([2,4,6]))
set(gca, 'FontSize', 20);
ylabel('Audio frequency (kHz)');
xlabel('Scale (cyc/oct)');
title('Spectral modulation');

% plot spectrotemporal modulation
% for a given audio frequency
for audiofreq = [500 1000 2000 4000 8000 16000 22000]
figure;
% audiofreq = 4000;
[~,xi] = min(abs(P.f-audiofreq));
X = cat(2, fliplr(F.spectemp_mod(:,:,2,xi)), F.spectemp_mod(:,:,1,xi));
imagesc(flipud(X));
spec_mod_rates_flip = fliplr(P.spec_mod_rates);
temp_mod_rates_neg_pos = [-fliplr(temp_mod_rates_without_DC), temp_mod_rates_without_DC];
set(gca, 'YTick', [1, 3, 5], 'YTickLabel', spec_mod_rates_flip([1 3 5]));
set(gca, 'XTick', [3, 7, 12, 16], 'XTickLabel', temp_mod_rates_neg_pos([3, 7, 12, 16]))
set(gca, 'FontSize', 20);
ylabel('Spectral scale (cyc/oct)');
xlabel('Temporal rate (Hz)');
title('Spectrotemporal modulation (200 Hz)');
end