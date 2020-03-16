clear all,
global F % Sound feature structure
% folder_sound = 'D:\=code=\McdermottLab\sound_natural\';
% folder_sound = 'D:\=sounds=\Vocalization\LZ_AudFilt\PH\';
folder_sound = 'X:\=Sounds=\Natural_XINTRINSIC2';
% folder_sound = 'D:\=sounds=\Voc_jambalaya\Natural with Voc\';
list = dir(fullfile(folder_sound,'*.wav'));
names_sound = natsortfiles({list.name})';
% iSound = I_inorder(end-9:end,2);
iSound = 1:length(list);

%% 1) plot cochleograms and frequency power on ERB scale
% iSound = 1:3;
% iSound = I_inorder(1:6,4);
plotON = 1;


F.Feat.FreqPower = [];
[p,n] = numSubplots(length(iSound)); 
if plotON
    f1 = figure('color','w'); f2 = figure('color','w');
end
% for k = 1:length(iSound)
for k = 1:3

    Sd.SoundName = names_sound{iSound(k)};
    filename = [folder_sound,Sd.SoundName];
    [Sd.wav,Sd.fs] = audioread(filename);
    
    % ======= cochleogram =======
    windur = 0.0025; % window for downsamples cochleagram
    mode = 'log'; % log or linear, or ERB scale
    if plotON 
        figure(f1), subplot(p(1),p(2),k) 
    end
    [F.CochEnv, F.CochEnv_ds, F.CochEnv_dB, F.cf, F.t_ds]  =  getCochleogram(Sd, windur, mode, plotON);
    % ===== frequency power =====
    if plotON 
        figure(f2), 
%         subplot(p(1),p(2),k) 
        subplot(3,1,k)
    end
    F.Feat.FreqPower(k,:) = getFreqPower(F.CochEnv, F.cf, plotON);
    xticks([]); yticks([]);
    k
end
%% 2) compute spectral, temporal, spectro-temporal modulation
addpath(genpath('D:\=code=\McdermottLab\toolbox_spectrotemporal-synthesis-v2-master'))
load('parameters_PLoSBio2018.mat', 'P');
% resample if needed
% P.audio_sr          = 44100;
% P.t                 = F.t_ds;
% P.f                 = F.cf;
% P.env_sr            = floor(1/windur);
% P.max_duration_sec  = 2;
% P.temp_pad_sec      = 2;
% P.freq_pad_oct      = 8;
F.temp_mod_rates = P.temp_mod_rates;
F.spec_mod_rates = P.spec_mod_rates;
F.temp_mod_rates_full = [-fliplr(P.temp_mod_rates), P.temp_mod_rates];

MP = []; % mean spectro-temporal modulation power across all sounds 
% for k = 1:length(iSound)
%%
for k = 2:3

    Sd.SoundName = names_sound{iSound(k)};
    filename = [folder_sound,Sd.SoundName];
    [Sd.wav,Sd.fs] = audioread(filename);
    
    % ======= cochleogram =======
    windur = 0.0025;
    mode = 'log'; % log or linear, or ERB scale
    plotON = 1;
%     [F.CochEnv, F.CochEnv_ds, F.CochEnv_dB, F.cf, F.t_ds]  =  getCochleogram(Sd, windur, mode, plotON);
%     [~, CochEnv_ds, F.CochEnv_dB(:,:,k), F.cf, F.t_ds]  =  getCochleogram(Sd, windur, mode, plotON);
    [~, CochEnv_ds, CochEnv_dB, F.cf, F.t_ds]  =  getCochleogram(Sd, windur, mode, plotON);
    
    % ======= interpolate cochleogram to log scale on frequency ========
    spacing = 1/24;
    logf = 2.^(log2(20) : spacing : log2(Sd.fs/2));    
    f1 = F.cf; f2 = logf';
    n_t = size(CochEnv_ds,2); % number of time point of the cochleogram
    CochEnv_ds_log = nan(length(f2), n_t);
    for i = 1:n_t
        CochEnv_ds_log(:,i) = interp1(log2(f1),CochEnv_ds(:,i), log2(f2), 'pchip', 'extrap');
    end
    % ===================================================================
    
    
    plotON = 1;
    % figure1, cochleargram, log scale
    if plotON 
        figure; 
        size_scr = get(0,'ScreenSize'); set(gcf,'position',[1 1 size_scr(3:4)])
       
        subplot(2,3,1)
        imagesc(CochEnv_ds_log),axis('xy'), colorbar
        set(gca, 'FontSize', 20);
            freqs   = floor([440*2.^([0:5]), max(logf)]./10).*10; % the index of 10
            fticks  = floor(interp1(logf, 1:1:length(logf), freqs));
            set(gca,'ytick',fticks)
            set(gca,'yticklabels',arrayfun(@num2str,freqs./1000,'UniformOutput',false))
        
            ts      = [0.5,1,1.5];
            tticks  = floor(interp1(F.t_ds, 1:1:length(F.t_ds), ts));
            set(gca,'xtick',tticks)
            set(gca,'xticklabels',arrayfun(@num2str,ts,'UniformOutput',false))
        title(['Cochleagram, ',strrep(Sd.SoundName, '_', '-')])
    end
%     F.CochEnv_ds(:,:,k) = CochEnv_ds_log;
    F.cf = logf;
    
    % ===== compute modulation power =====
    % computes the first four moments of the filter responses:
    % (1) mean (2) variance (3) skew (4) kurtosis
%     M = all_filter_moments_from_coch(F.CochEnv_ds(:,:,k)', P, 1:size(F.CochEnv_ds(:,:,k)',1));
    M = all_filter_moments_from_coch(CochEnv_ds', P, 1:size(CochEnv_ds',1));
    
    % pick out mean of cochlear, standard deviation of all other feats
    F.coch_env(:,k) = M.coch_env(:,1);
    F.temp_mod(:,:,k) = sqrt(M.temp_mod(:,:,2));
    F.spec_mod(:,:,k) = sqrt(M.spec_mod(:,:,2));
    spectemp_mod = sqrt(M.spectemp_mod(:,:,:,2));
    
    % split out negative and positive temporal rates
    % corresponding to upward and downward modulated ripples
    % for prediction negative and positive rates were averaged
    dims = size(spectemp_mod);
    spectemp_mod = reshape(spectemp_mod, [dims(1), dims(2)/2, 2, dims(3)]);
    % average spectrotemporal modulation power across all frequencies
    % added by Yueqi July, 2019
    spectemp_mod_avg = mean(spectemp_mod,4);
    % X is for display purpose
    X = cat(2, fliplr(spectemp_mod_avg(:,:,2)), spectemp_mod_avg(:,:,1));
    % the feature used combines positive and negative temporal rates
    F.spectemp_mod(:,:,k) = squeeze(mean(spectemp_mod_avg,3));
    F.spectemp_mod_full(:,:,k) = X;
 
    % average spectrotemporal modulation power across all stimulus   
    % ======= added by Yueqi July, 2019 =======
%     F.spectemp_mod_avg = mean(F.spectemp_mod,4);
    if k == 1 
        MP = F.spectemp_mod(:,:,k);
    else
        MP = MP.*(k-1)./k + F.spectemp_mod(:,:,k)./k;
    end
    % ======= ========================== =======
    if plotON   
        % figure2, spectral profile
        subplot(2,3,2)
        %         semilogx(F.cf,F.coch_env(:,k)), 
        semilogy(F.coch_env(:,k), F.cf, 'LineWidth',3), 
        xlim([min(F.coch_env(:,k)), max(F.coch_env(:,k))])
        ylim([min(F.cf), max(F.cf)])
        set(gca, 'FontSize', 20);
        xlabel('Mean amplitude')
        ylabel('Cochlear channels (Hz)')
        title('Cochleagram envolope');
        
        % plot temporal modulation
        subplot(2,3,3)
        imagesc(F.temp_mod(:,:,k)'), axis('xy'), colorbar
        temp_mod_rates_without_DC = P.temp_mod_rates(P.temp_mod_rates>0);
        freqs_to_plot = [100 400 800 1600 3200 6400];
        fticks = floor(interp1(P.f, 1:1:length(P.f), freqs_to_plot));
        set(gca, 'YTick', fticks, 'YTickLabel', (freqs_to_plot)/1000);
        set(gca, 'XTick', [2,4,6,8], 'XTickLabel', round(temp_mod_rates_without_DC([2,4,6,8])))
        set(gca, 'FontSize', 20);
        ylabel('Audio frequency (kHz)');
        xlabel('Rate (Hz)')
        title('Temporal modulation');

        % plot spectral modulation
        subplot(2,3,4)
        imagesc(F.spec_mod(:,:,k)'), axis('xy'), colorbar
        freqs_to_plot = [100 400 800 1600 3200 6400];
        fticks = floor(interp1(P.f, 1:1:length(P.f), freqs_to_plot));
        set(gca, 'YTick', fticks, 'YTickLabel', (freqs_to_plot)/1000);
        set(gca, 'XTick', [2,4,6], 'XTickLabel', P.spec_mod_rates([2,4,6]))
        set(gca, 'FontSize', 20);
        ylabel('Audio frequency (kHz)');
        xlabel('Scale (cyc/oct)');
        title('Spectral modulation');
         
        % plot spectrotemporal modulation for averaged frequency
        subplot(2,3,5)
        imagesc(flipud(X)); colorbar
        spec_mod_rates_flip = fliplr(P.spec_mod_rates);
        temp_mod_rates_neg_pos = [-fliplr(temp_mod_rates_without_DC), temp_mod_rates_without_DC];
        set(gca, 'YTick', [1, 3, 5], 'YTickLabel', spec_mod_rates_flip([1 3 5]));
        set(gca, 'XTick', [3, 7, 12, 16], 'XTickLabel', temp_mod_rates_neg_pos([3, 7, 12, 16]))
        set(gca, 'FontSize', 20);
        ylabel('Spectral scale (cyc/oct)');
        xlabel('Temporal rate (Hz)');
        title('Spectrotemporal modulation (averaged across cf)');
        
         % plot spectrotemporal modulation for a given audio frequency
        subplot(2,3,6)
%         audiofreq = 7000;
%         [~,xi] = min(abs(P.f-audiofreq));
        [~,xi] = max(abs(F.coch_env(:,k)));
        audiofreq = F.cf(xi);
        X = cat(2, fliplr(spectemp_mod(:,:,2,xi)), spectemp_mod(:,:,1,xi));
        imagesc(flipud(X)); colorbar
        spec_mod_rates_flip = fliplr(P.spec_mod_rates);
        temp_mod_rates_neg_pos = [-fliplr(temp_mod_rates_without_DC), temp_mod_rates_without_DC];
        set(gca, 'YTick', [1, 3, 5], 'YTickLabel', spec_mod_rates_flip([1 3 5]));
        set(gca, 'XTick', [3, 7, 12, 16], 'XTickLabel', temp_mod_rates_neg_pos([3, 7, 12, 16]))
        set(gca, 'FontSize', 20);
        ylabel('Spectral scale (cyc/oct)');
        xlabel('Temporal rate (Hz)');
        title(['Spectrotemporal modulation ( cf = ',num2str(audiofreq),' Hz)']);
    end
%     saveas(f,['D:\=code=\Sound_analysis\figure_NatSoundFeatures_YG_marm\features_',num2str(k),'_',Sd.SoundName,'.png'])
%     close(f)
    k
end

F = getFeatureMatrix(F);
% save F_yg_marm F

%% temp
k = 158; 
figure,imagesc(flipud(F.spectemp_mod(:,:,k)))
set(gca, 'YTick', [2,4,6], 'YTickLabel', F.spec_mod_rates([end-1 end-3 end-5]));
set(gca, 'XTick', [1 3 5 7], 'XTickLabel', F.temp_mod_rates([1 3 5 7]));
set(gca, 'fontsize', 30)


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
