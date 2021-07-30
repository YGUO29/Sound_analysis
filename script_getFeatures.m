% folder_sound = 'D:\SynologyDrive\=sounds=\Vocalization\LZ_selected_4reps\single rep';
% folder_sound = 'D:\=sounds=\Vocalization\LZ_AudFilt\Norm_165';
folder_sound = 'D:\SynologyDrive\=sounds=\Natural sound\Natural_JM_original\';
% temp = zeros(7, 9, 165);
opt.iSound = 1:165;
opt.plotON = 0;
opt.savefigON = 0;
opt.saveON = 0;
opt.save_filename = 'D:\SynologyDrive\=data=\F_halfcosine_marm_NatJM.mat';
% opt.save_figurepath = 'D:\SynologyDrive\=data=\Sound\Spectrotemporal modulation\figure_Voc2p_PheeTwitter_HalfCosine_marm_lowcut=100hz\';
opt.windur = 0.0025;
opt.cochmode = 'ERB'; % log or linear, or ERB scale
% opt.dur = min(dur_mat);
[F, P] = getFeatures_v2(folder_sound, opt);
% (getFeatures_v2 saves the 4d matrix of spectrotemporal modulation with
% frequencies)
%% temporary = plot features
% order: coch, spec, temp, orig
figurex([1440          42         774         862]);
[X,Y,Z] = meshgrid(1:F.nTemp, 1:F.nSpec, F.cf_log);
for i = 1:165
%     subplot(1,2,1)
    V = squeeze(F.spectemp_mod_withfreq(:,:,:,i));
    xslice = [];   
    yslice = [];
    zslice = 440.*[1 2 4 8 16 32 64];
    h = slice(X,Y,Z,V,xslice,yslice,zslice,'nearest');
    set(gca, 'Zscale', 'log')

    set(h,'EdgeColor','none',...
    'FaceColor','interp',...
    'FaceAlpha','interp')
    alpha('color')
    alphamap('rampdown')
    alphamap('increase',.1)
    colormap hsv

    xlabel('spectral modulation', 'Rotation', 15)
    ylabel('temporal modulation', 'Rotation', -13)
    zlabel('frequency (Hz)')
    view(-45, 9.2)
    grid on
%     subplot(1,2,2)
%     imagesc(flipud(F.spectemp_mod(:,:,i)))

    pause
end
%% plot average coch_env for each category
cochenv_cat = cell(1, length(F.C.category_labels)); % group cochlea envelopes by sound category
cochenv_weight = zeros(1, F.nStim); % weighted average of spectrums
cochenv_mean = zeros(size(F.coch_env, 1), length(F.C.category_labels));
for i = 1:F.nStim
    cochenv_cat{F.C.category_assignments(i)} = [cochenv_cat{F.C.category_assignments(i)}, F.coch_env(:, i)];
    cochenv_weight(i) = sum(F.cf_log'.*F.coch_env(:,i))./sum(F.coch_env(:,i));
end

for i = 1:length(F.C.category_labels)
    cochenv_mean(:,i) = mean(cochenv_cat{i}, 2);
end
    
figurex; 
plot(cochenv_mean)
legend(F.C.category_labels)
% sort weighted spectrum from high to low
[~, ind] = sort(cochenv_weight, 'descend');
% newlist = list(ind);

% plot 15 voc and 15 natural sounds with highest weighted mean of sectrum
figurex;
plot(rescale(cochenv_mean(:, end))), hold on
plot( rescale(mean( F.coch_env(:, ind(16:30)), 2)))
legend({'15 voc', '15 nat w/ highest center of mass'})
%% =====================
% load a single sound directly
Sd.SoundName = 'PinkNoise_dsp.wav'; 
folder_sound = cd;
[Sd.wav,Sd.fs] = audioread(fullfile(folder_sound, Sd.SoundName));
F = getFeatures(Sd, opt);
% temp(:,:,i) = F.spectemp_mod;

%% plot the spectrotemporal modulation for sounds
k = 39; 
figure,imagesc(flipud(F.spectemp_mod(:,:,k)))
set(gca, 'YTick', [2,4,6], 'YTickLabel', F.spec_mod_rates([end-1 end-3 end-5]));
set(gca, 'XTick', [1 3 5 7], 'XTickLabel', F.temp_mod_rates([1 3 5 7]));
set(gca, 'fontsize', 30)

%% explore correlation between features
% max 
[~, ind] = max(F.coch_env);
F.max_freq = F.cf_log(ind);
[~, ind] = max(squeeze(mean(F.temp_mod, 2)));
F.max_tempmod = F.temp_mod_rates(ind);
[~, ind] = max(squeeze(mean(F.spec_mod, 2)));
F.max_specmod = F.spec_mod_rates(ind);

% weighted sum
F.best_freq = sum(repmat(F.cf_log',1,length(F.CochEnv_ds_log)).*F.coch_env,1)./sum(F.coch_env,1);
profile_temp = squeeze(mean(F.spectemp_mod,1));
profile_spec = squeeze(mean(F.spectemp_mod,2));
% profile_temp = squeeze(mean(F.temp_mod,2));
% profile_spec = squeeze(mean(F.spec_mod,2));
F.best_temp = sum(repmat(F.temp_mod_rates(2:end)',1,length(F.CochEnv_ds_log)).*profile_temp,1)...
    ./sum(profile_temp,1);
F.best_spec = sum(repmat(F.spec_mod_rates',1,length(F.CochEnv_ds_log)).*profile_spec,1)...
    ./sum(profile_spec,1);


% mean cochleogram envelope & temporal modulation & spectral modulation
figurex;
subplot(1,3,1),
% plot(F.cf',F.coch_env);set(gca, 'XScale', 'log')
plot(F.cf_log,mean(F.coch_env,2));set(gca, 'XScale', 'log')
title('mean cochleogram envelope')
subplot(1,3,2),
% plot(F.temp_mod_rates(2:end), squeeze(mean(F.temp_mod,2)))
plot(F.temp_mod_rates(2:end), mean(squeeze(mean(F.temp_mod,2)),2))
title('mean temporal modulation')
set(gca, 'XScale', 'log')
subplot(1,3,3),
% plot(F.spec_mod_rates, squeeze(mean(F.spec_mod,2)))
plot(F.spec_mod_rates, mean(squeeze(mean(F.spec_mod,2)),2))
title('mean spectral modulation')
set(gca, 'XScale', 'log')

F.best_spec = sum(repmat(F.spec_mod_rates',1,length(F.CochEnv_ds_log)).*squeeze(mean(F.spec_mod,2)),1)...
    ./sum(squeeze(mean(F.spec_mod,2)),1);

figurex;
subplot(1,3,1),
scatter(F.best_freq, F.best_temp), set(gca, 'YScale', 'log')
title(['correlation = ', num2str(corr(F.best_freq', F.best_temp'))])
xlabel('Frequency (Hz)'); ylabel('Temp. Mod. (Hz)');
subplot(1,3,2), 
scatter(F.best_freq, F.best_spec), set(gca, 'YScale', 'log')
title(['correlation = ', num2str(corr(F.best_freq', F.best_spec'))])
xlabel('Frequency (Hz)'); ylabel('Spec. Mod. (cyc/oct)');
subplot(1,3,3),
scatter(F.best_temp, F.best_spec), set(gca, 'YScale', 'log','XScale','log')
title(['correlation = ', num2str(corr(F.best_temp', F.best_spec'))])
ylabel('Spec. Mod. (cyc/oct)'); xlabel('Temp. Mod. (Hz)');


[x,y] = ginput();
for i = 1:length(x)
    [~,idx(i)] = min(dist([F.best_temp; F.best_spec]', [x(i); y(i)]));
end

Y_freq = F.F_mat(1 : F.nFreq,:)';
Y_temp = F.F_mat(F.nFreq+1 : F.nFreq+F.nTemp,:)';
Y_spec = F.F_mat(F.nFreq+F.nTemp+1 : F.nFreq+F.nTemp+F.nSpec,:)';
Y_mod = F.F_mat(F.nFreq+F.nTemp+F.nSpec+1 : F.nFreq+F.nTemp+F.nSpec+F.nSpectemp,:)';
Y = [Y_freq, Y_temp, Y_spec];
figure, imagesc(corrcoef(Y)), axis image, colorbar

%% histogram of the feature distribution
Feature = F.Feat.FreqPower;
figure,
[p,n] = numSubplots(size(Feature, 2)); 
for k = 1:size(Feature, 2)
    subplot(p(1),p(2),k)
    hist(Feature(:,k),20)
end

% ============= Regression ===============
for iComp = 1:K
    figure,
    for iFreq = 1:8
        xx = F.Feat.FreqPower(:,iFreq);
        yy = R(:,iComp);
        subplot(2,4,iFreq)
        scatter(xx,yy),title(['frequency band ',num2str(iFreq),', component ',num2str(iComp)])
        [p,rsq,yfit] = RSquared(xx,yy);
        results(2*(iComp-1)+1,iFreq) = rsq;
        results(2*iComp,iFreq) = p(1);
    end
end
