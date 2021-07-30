% misc/temp code for sound features
%% check auditory filter shape
Sd.fs = 44100;
t = 1/Sd.fs:1/Sd.fs:1;
freqs = 110.*(2.^[0:0.5:7]);
cmap = hsv(length(freqs+1));
opt.windur = 0.0025;
opt.cochmode = 'log';
clear bm_pattern temp_pattern
for i = 1:length(freqs)
    Sd.wav = sin(2.*pi.*freqs(i).*t);
    [CochEnv_ds_log, ~, P] = getCochleogram_halfcosine(Sd, P, 0); cf =P.f;
%     [~, CochEnv_ds_log, CochEnv_dB, cf, t_ds]  =  getCochleogram_gamma(Sd, opt.windur, opt.cochmode,0);

    bm_pattern(:,i) = mean(CochEnv_ds_log, 2); 
    channel_ind = interp1(P.f, 1:length(P.f), freqs(i));
    temp_pattern(:,i) = CochEnv_ds_log(round(channel_ind), :)';
end

figurex([ 1440         918        1181         420]);
% h = plot(cf./1e3, bm_pattern_hc);
h = semilogx(cf/1e3, bm_pattern);
xlabel('auditory filter center frequency (kHz)')
ylabel('excitation amplitude')
legend({'110Hz', '220Hz', '440Hz', '880Hz', '1760Hz', '3520Hz', '7040Hz', '14080Hz'}, 'location', 'eastoutside')
for i = 1:length(freqs)
set(h(i), 'Color', cmap(i,:))
end
xticks([freqs./1e3])
xlim([freqs(1) freqs(end)]./1e3)

% figurex;
% plot(P.t, temp_pattern)
% xlabel('time(s)')
% ylabel('excitation amplitude')

%% make category_regressor file
nCat = 5; nSound = length(C.category_assignment);
C.category_labels = unique(F.tag);
% for i = 1:length(F.sound_names)
C.category_assignment = [ones(42, 1); 2.*ones(42, 1); 3.*ones(21, 1); 4.*ones(42, 1); 5.*ones(21, 1)];
C.continuous_scores = zeros(nSound, nCat);
C.category_regressors = C.continuous_scores;
for i = 1:nSound
    C.continuous_scores(i,C.category_assignment(i)) = 1;
    C.category_regressors(i,C.category_assignment(i)) = 1;
end
% C.colors = 

