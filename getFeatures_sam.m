global F % Sound feature structure
folder_sound = 'D:\=code=\McdermottLab\sound_natural\';
% folder_sound = 'D:\=sounds=\Vocalization\TwitterStimuliForXindong\';
% folder_sound = 'D:\=sounds=\Natural sound\Natural JM with Voc';
list = dir(fullfile(folder_sound,'*.wav'));
names_sound = natsortfiles({list.name})';
% iSound = [132 77 125 83 128 121];
iSound = 50;


%% get features by Sam's code
plotON = 1;
addpath(genpath('D:\=code=\McdermottLab\toolbox_spectrotemporal-synthesis-v2-master'))
% load parameter structure
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

for k = 1:length(iSound)
    Sd.SoundName = names_sound{iSound(k)};
    filename = [folder_sound,Sd.SoundName];
    [Sd.wav,Sd.fs] = audioread(filename);


    % resample if needed
    P.audio_sr = 44100;
    if Sd.fs ~= P.audio_sr
        Sd.wav = resample(Sd.wav, P.audio_sr, Sd.fs);
    %     Sd.fs = P.audio_sr;
    end


    % cochleogram filters
    duration_sec = length(Sd.wav)/P.audio_sr;
    if P.overcomplete==0
        [audio_filts, audio_low_cutoff] = ...
            make_erb_cos_filters(duration_sec*P.audio_sr, P.audio_sr, ...
            P.n_filts, P.lo_freq_hz, P.audio_sr/2);

    elseif P.overcomplete==1
        [audio_filts, audio_low_cutoff] = ...
            make_erb_cos_filts_double2(duration_sec*P.audio_sr, P.audio_sr, ...
            P.n_filts, P.lo_freq_hz, P.audio_sr/2);

    elseif P.overcomplete==2
        [audio_filts, audio_low_cutoff] = ...
            make_erb_cos_filts_quadruple2(duration_sec*P.audio_sr, P.audio_sr, ...
            P.n_filts, P.lo_freq_hz, P.audio_sr/2, 'human');
    end

    % remove filters below and above desired cutoffs
    xi = audio_low_cutoff > P.lo_freq_hz - 1e-3 ...
        & audio_low_cutoff < P.audio_sr/2 + 1e-3;
    audio_filts = audio_filts(:,xi);
    audio_low_cutoff = audio_low_cutoff(xi);

    % cochleogram of original sound
    [coch, P.f, P.t, R_orig] = ...
        wav2coch(Sd.wav, audio_filts, audio_low_cutoff, ...
        P.audio_sr, P.env_sr, P.compression_factor, P.logf_spacing);

    % plot cochleogram
    if plotON
        f = figure; size_scr = get(0,'ScreenSize'); set(gcf,'position',[1 1 size_scr(3:4)])
        subplot(2,3,1)
        plot_cochleogram(coch, P.f, P.t);
        set(gca, 'FontSize', 20);
        title(['Cochleagram, ',strrep(Sd.SoundName, '_', '-')])
    end
    
    
    % ======= output variables =======
    F.CochEnv_ds(:,:,k) = coch;
    F.cf = P.f;
    F.t_ds = P.t;
    
% Stats of cochleogram and filtered cochleograms (stage 2)
% computes the first four moments of the filter responses:
% (1) mean (2) variance (3) skew (4) kurtosis
    M = all_filter_moments_from_coch(coch, P, 1:size(coch,1));

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
    
%     saveas(f,['features_',num2str(k),'_',Sd.SoundName,'.png'])
%     close(f)
    k
end       

F = getFeatureMatrix(F);
   
save('D:\=code=\Sound_analysis\F_sam_marm_full','F')
