% folder_sound = 'D:\=sounds=\Natural sound\Natural JM with Voc\';
% folder_sound = 'D:\=sounds=\Vocalization\LZ_AudFilt\Norm_165';
folder_sound = 'D:\=sounds=\Natural sound\Natural_JM_MatchEnv';
% temp = zeros(7, 9, 165);
opt.iSound = 79;
opt.plotON = 1;
opt.savefigON = 0;
opt.saveON = 0;
opt.save_filename = 'D:\=code=\Sound_analysis\F_yg_marm4';
opt.windur = 0.0025;
opt.cochmode = 'ERB'; % log or linear, or ERB scale
F = getFeatures(folder_sound, opt);
% temp(:,:,i) = F.spectemp_mod;

%%
Sd.SoundName = 'PinkNoise_dsp.wav'; 
folder_sound = cd;
[Sd.wav,Sd.fs] = audioread(fullfile(folder_sound, Sd.SoundName));
opt.plotON = 1;
opt.savefigON = 0;
opt.saveON = 0;
opt.save_filename = 'D:\=code=\Sound_analysis\F_yg_marm4';
opt.windur = 0.0025;
opt.cochmode = 'ERB'; % log or linear, or ERB scale
F = getFeatures_singlefile(Sd, opt);
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
F.best_freq = sum(repmat(F.cf_log,1,165).*F.coch_env,1)./sum(F.coch_env,1);
profile_temp = squeeze(mean(F.spectemp_mod,1));
profile_spec = squeeze(mean(F.spectemp_mod,2));
% profile_temp = squeeze(mean(F.temp_mod,2));
% profile_spec = squeeze(mean(F.spec_mod,2));
F.best_temp = sum(repmat(F.temp_mod_rates(2:end)',1,165).*profile_temp,1)...
    ./sum(profile_temp,1);
F.best_spec = sum(repmat(F.spec_mod_rates',1,165).*profile_spec,1)...
    ./sum(profile_spec,1);


%
figurex;
subplot(1,3,1),
% plot(F.cf',F.coch_env);set(gca, 'XScale', 'log')
plot(F.cf_log,mean(F.coch_env,2));set(gca, 'XScale', 'log')
subplot(1,3,2),
% plot(F.temp_mod_rates(2:end), squeeze(mean(F.temp_mod,2)))
plot(F.temp_mod_rates(2:end), mean(squeeze(mean(F.temp_mod,2)),2))
set(gca, 'XScale', 'log')
subplot(1,3,3),
% plot(F.spec_mod_rates, squeeze(mean(F.spec_mod,2)))
plot(F.spec_mod_rates, mean(squeeze(mean(F.spec_mod,2)),2))
set(gca, 'XScale', 'log')

F.best_spec = sum(repmat(F.spec_mod_rates',1,165).*squeeze(mean(F.spec_mod,2)),1)...
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
