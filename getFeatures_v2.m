% folder_sound = 'D:\=sounds=\Natural sound\Natural JM with Voc\';
% opt.iSound = [];
% opt.plotON = 0;
% opt.saveON = 0;
% opt.save_filename = 'D:\=code=\Sound_analysis\F_test';
% opt.windur = 0.0025;
% opt.cochmode = 'ERB'; % log or linear, or ERB scale
function [F,P] = getFeatures_v2(varargin)
% this version saves more features: 
% frequency-dependent modulations: 
% time-dependent modulations



%           temp_mod_rates: [0 0.5000 1 2 4 8 16 32 64 128]
%                 spec_mod_rates: [0 0.2500 0.5000 1 2 4 8]
%            temp_mod_rates_full: [-128 -64 -32 -16 -8 -4 -2 -1 -0.5000 0 0 0.5000 1 2 4 8 16 32 64 128]
%                     mean_power: []
%                 CochEnv_ds_log: {[193×871 double]}
%                         cf_log: [1×193 double]
%                           t_ds: {[1×871 double]}
%                       coch_env: [193×1 double]
%                       temp_mod: [9×193 double]
%                       spec_mod: [7×193 double]
%                   spectemp_mod: [7×9 double]
%              spectemp_mod_full: [7×18 double]
%     spectemp_mod_weighted_full: [7×18 double]
%          spectemp_mod_weighted: [7×9 double]


if ischar(varargin{1}) % input a folder with sounds
    folder_sound = varargin{1};
    opt = varargin{2};
    
    % set sound list to be analyzed
    list = dir(fullfile(folder_sound,'*.wav'));    
    names_sound = natsortfiles({list.name})';
    if isempty(opt.iSound)
        iSound = 1:length(list);
    else
        iSound = opt.iSound;
    end
elseif isstruct(varargin{1}) % input a single sound
    Sd = varargin{1};
    opt = varargin{2};
    iSound = 1;
else
end
%% setup spectro-temporal modulation analysis
addpath(genpath('D:\SynologyDrive\=code=\McdermottLab\toolbox_spectrotemporal-synthesis-v2-master'))
% load('parameters_PLoSBio2018.mat', 'P');
load('D:\SynologyDrive\=data=\SpecTempParameters_Yueqi.mat', 'P');

F.temp_mod_rates = P.temp_mod_rates;
F.spec_mod_rates = P.spec_mod_rates;
F.temp_mod_rates_full = [-fliplr(P.temp_mod_rates), P.temp_mod_rates];
F.mean_power = []; 

for k = 1:length(iSound)
    if ischar(varargin{1}) 
        Sd.SoundName = names_sound{iSound(k)};
        F.sound_names{k} = names_sound{iSound(k)};
        
        filename = fullfile(folder_sound,Sd.SoundName);
        [Sd.wav,Sd.fs] = audioread(filename);
        P.audio_sr = Sd.fs; % watch out for fs!!!
        if isfield(opt,'dur')
            Sd.wav = Sd.wav(1:floor(Sd.fs * opt.dur));
        end
    end
    % ======= cochleogram, half cosine filter =======
    [CochEnv_ds_log, ~, P] = getCochleogram_halfcosine(Sd, P, 0);
    F.CochEnv_ds_log{k} = CochEnv_ds_log; % use cells because sounds may be different lengths 
%     F.CochEnv_ds_log(:,:,k) = CochEnv_ds_log;
    F.cf_log = P.f;
    F.t_ds{k} = P.t;
    % ======= cochleogram, gammatone filter =======
%     [~, CochEnv_ds, CochEnv_dB, F.cf, F.t_ds]  =  getCochleogram_gamma(Sd, opt.windur, opt.cochmode,0);
%     % interpolate cochleogram to log scale on frequency 
%     spacing = 1/24;
%     logf = 2.^(log2(min(F.cf)) : spacing : log2(Sd.fs/2));    
%     f1 = F.cf; f2 = logf';
%     n_t = size(CochEnv_ds,2); % number of time point of the cochleogram
%     CochEnv_ds_log = nan(length(f2), n_t);
%     for i = 1:n_t
%         CochEnv_ds_log(:,i) = interp1(log2(f1),CochEnv_ds(:,i), log2(f2), 'pchip', 'extrap');
%     end
%     F.CochEnv_ds_log(:,:,k) = CochEnv_ds_log;
%     F.cf_log = f2;
    % ===================================================================

    % figure1, cochleargram, downsampled, log scale
    if opt.plotON 
        f = figure; 
        size_scr = get(0,'ScreenSize'); set(gcf,'position',[1 1 size_scr(3:4)])
       
        subplot(2,3,1)
        imagesc(CochEnv_ds_log),axis('xy'), colorbar
        set(gca, 'FontSize', 20);
            freqs   = floor([440*2.^([0:5]), max(F.cf_log)]./10).*10; % the index of 10
%             freqs   = floor([440*2.^([0:4])]./10).*10; % the index of 10

            fticks  = floor(interp1(F.cf_log, 1:1:length(F.cf_log), freqs));
            set(gca,'ytick',fticks)
            set(gca,'yticklabels',arrayfun(@num2str,freqs./1000,'UniformOutput',false))
        
            ts      = [0.5,1,1.5];
            ticks  = floor(interp1(F.t_ds{k}, 1:1:length(F.t_ds{k}), ts));
%             set(gca,'xtick',tticks)
%             set(gca,'xticklabels',arrayfun(@num2str,ts,'UniformOutput',false))
        title(['Cochleagram, ',strrep(Sd.SoundName, '_', '-')])
    end
%     F.CochEnv_ds(:,:,k) = CochEnv_ds_log;
%     F.cf = logf;
    
    % ===== compute modulation power =====
    % computes the first four moments of the filter responses:
    % (1) mean (2) variance (3) skew (4) kurtosis
    % resample if needed
%     P.audio_sr          = Sd.fs;
%     P.t                 = F.t_ds;
%     P.f                 = F.cf_log;
%     P.env_sr            = floor(1/opt.windur);
%     P.max_duration_sec  = 12;
%     P.temp_pad_sec      = 24;% used to be 2, Sam used 24
%     P.freq_pad_oct      = 24;% used to be 8, Sam used 24
%     M = all_filter_moments_from_coch(F.CochEnv_ds(:,:,k)', P, 1:size(F.CochEnv_ds(:,:,k)',1));
    M = all_filter_moments_from_coch(CochEnv_ds_log', P, 1:size(CochEnv_ds_log',1));
    
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
    F.spectemp_mod_withfreq(:,:,:,k) = squeeze(mean(spectemp_mod,3)); % SM x TM x Freqs
    % average spectrotemporal modulation power across all frequencies
    % (added by Yueqi July, 2019)
    spectemp_mod_avg = mean(spectemp_mod,4); % average across all frequencies
    F.spectemp_mod(:,:,k) = squeeze(mean(spectemp_mod_avg,3)); % collapse +/- temporal rates
    
    X = cat(2, fliplr(spectemp_mod_avg(:,:,2)), spectemp_mod_avg(:,:,1));
    F.spectemp_mod_full(:,:,k) = X; % keep +/- temporal rates
 
    % average spectrotemporal modulation power weighted by frequency power
    % (added by Yueqi April, 2020)
    %?????????????????????
    weights = F.coch_env(:,k)./sum(F.coch_env(:,k));
    spectemp_mod_weighted = spectemp_mod;
    for i = 1:size(spectemp_mod,4)
        spectemp_mod_weighted(:,:,:,i) = spectemp_mod(:,:,:,i).*weights(i);
    end
    spectemp_mod_weighted = mean(spectemp_mod_weighted, 4);
    Y = cat(2, fliplr(spectemp_mod_weighted(:,:,2)), spectemp_mod_weighted(:,:,1));
    F.spectemp_mod_weighted_full(:,:,k) = Y; % keep +/- temporal rates
    F.spectemp_mod_weighted(:,:,k) = squeeze(mean(spectemp_mod_weighted,3));
    
    % average spectrotemporal modulation power across all stimulus   
    % (added by Yueqi July, 2019)
%     F.spectemp_mod_avg = mean(F.spectemp_mod,4);
%     if k == 1 
%         F.mean_power = F.spectemp_mod(:,:,k);
%     else
%         F.mean_power = F.mean_power.*(k-1)./k + F.spectemp_mod(:,:,k)./k;
%     end
    % ======= ========================== =======
    if opt.plotON   
        % spectral profile
        subplot(2,3,2)
        semilogy(F.coch_env(:,k), F.cf_log, 'LineWidth',3), 
        xlim([min(F.coch_env(:,k)), max(F.coch_env(:,k))])
        ylim([min(F.cf_log), max(F.cf_log)])
        set(gca, 'FontSize', 20);
        xlabel('Mean amplitude')
        ylabel('Cochlear channels (Hz)')
        title('Cochleagram envolope');
        
        % plot temporal modulation
        subplot(2,3,3)
        imagesc(F.temp_mod(:,:,k)'), axis('xy'), colorbar
        temp_mod_rates_without_DC = P.temp_mod_rates(P.temp_mod_rates>0);
        freqs_to_plot = [400 800 1600 3200 6400];
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
        freqs_to_plot = [400 800 1600 3200 6400];
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
        
        % plot spectrotemporal modulation for averaged frequency
        subplot(2,3,6)
        imagesc(flipud(Y)); colorbar
        spec_mod_rates_flip = fliplr(P.spec_mod_rates);
        temp_mod_rates_neg_pos = [-fliplr(temp_mod_rates_without_DC), temp_mod_rates_without_DC];
        set(gca, 'YTick', [1, 3, 5], 'YTickLabel', spec_mod_rates_flip([1 3 5]));
        set(gca, 'XTick', [3, 7, 12, 16], 'XTickLabel', temp_mod_rates_neg_pos([3, 7, 12, 16]))
        set(gca, 'FontSize', 20);
        ylabel('Spectral scale (cyc/oct)');
        xlabel('Temporal rate (Hz)');
        title('Spectrotemporal modulation (weighted average)');
         % plot spectrotemporal modulation for a given audio frequency
         
         
%         subplot(2,3,6)
%         [~,xi] = max(abs(F.coch_env(:,k)));
%         audiofreq = F.cf(xi);
%         X = cat(2, fliplr(spectemp_mod(:,:,2,xi)), spectemp_mod(:,:,1,xi));
%         imagesc(flipud(X)); colorbar
%         spec_mod_rates_flip = fliplr(P.spec_mod_rates);
%         temp_mod_rates_neg_pos = [-fliplr(temp_mod_rates_without_DC), temp_mod_rates_without_DC];
%         set(gca, 'YTick', [1, 3, 5], 'YTickLabel', spec_mod_rates_flip([1 3 5]));
%         set(gca, 'XTick', [3, 7, 12, 16], 'XTickLabel', temp_mod_rates_neg_pos([3, 7, 12, 16]))
%         set(gca, 'FontSize', 20);
%         ylabel('Spectral scale (cyc/oct)');
%         xlabel('Temporal rate (Hz)');
%         title(['Spectrotemporal modulation ( cf = ',num2str(audiofreq),' Hz)']);
    end
    
    if opt.savefigON
        if ~exist(opt.save_figurepath, 'dir')
            mkdir(opt.save_figurepath)
        end
%     saveas(f,[opt.save_figurepath, 'features_',num2str(k),'_',Sd.SoundName,'.png'])
        saveas(f,[opt.save_figurepath, '_',Sd.SoundName,'.png'])
    close(f)
    end
    k
end

try
F = getFeatureMatrix(F);
catch
end

if opt.saveON
    
    save(opt.save_filename, 'F')
end
end