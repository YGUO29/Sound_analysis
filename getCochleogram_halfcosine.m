function [Mat_env_ds, Mat_env, P] = getCochleogram_halfcosine(Sd, P, plotON)

% cochleogram filters
% addpath(genpath('D:\=code=\McdermottLab\toolbox_spectrotemporal-synthesis-v2-master'))
% load('parameters_PLoSBio2018.mat', 'P');
% load('SpecTempParameters_Yueqi.mat', 'P');
% P.lo_freq_hz = 20;
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
            make_erb_cos_filts_quadruple2(round(duration_sec*P.audio_sr), P.audio_sr, ...
            P.n_filts, P.lo_freq_hz, P.audio_sr/2, 'marmoset');
    end

    % remove filters below and above desired cutoffs
    xi = audio_low_cutoff > P.lo_freq_hz - 1e-3 ...
        & audio_low_cutoff < P.audio_sr/2 + 1e-3;
    audio_filts = audio_filts(:,xi);
    audio_low_cutoff = audio_low_cutoff(xi);

    % cochleogram of original sound
    [Mat_env_ds, Mat_env, P.f, P.t, R_orig] = ...
        wav2coch(Sd.wav, audio_filts, audio_low_cutoff, ...
        P.audio_sr, P.env_sr, P.compression_factor, P.logf_spacing);
    
    Mat_env_ds = Mat_env_ds';
    Mat_env = Mat_env';


if plotON
    imagesc(Mat_env_ds)
%     imagesc(MatdB)
    colorbar, axis('xy'), 
    dur = length(Sd.wav)/Sd.fs;
    t_ind = []; t_labels =cell(0);
    ts = dur.*[1/4,1/2,3/4];
    for k = 1:length(ts)
        [~,t_ind(k)] = min( abs(P.t-ts(k)) );
        t_labels{k} = num2str(ts(k), '%.1f');
    end
    set(gca,'xtick',t_ind)
    set(gca,'xticklabels',t_labels,'fontsize',20)
    xlabel('Time, s','fontsize',20);  
%     xtickformat('%.1f');
%     title(['Cochleagram, ',mode,', ',strrep(Sd.SoundName, '_', '-')],'fontsize',10)
    if isfield(Sd, 'SoundName')
        Sd.SoundNameSimple      = strsplit(Sd.SoundName,'_');
        Sd.SoundNameSimple      = Sd.SoundNameSimple(2:end);
        Sd.SoundNameSimple{end} = Sd.SoundNameSimple{end}(1:end-4);
        title(strjoin(Sd.SoundNameSimple,'-'),'fontsize',20)
    end
    
    % set y ticks
    freqs = floor([440*2.^([0:5])]./10).*10;
    y_ind = round(interp1(P.f, 1:length(P.f), freqs)); 
    set(gca,'ytick',y_ind)
    set(gca,'yticklabels',arrayfun(@num2str,freqs./1000,'UniformOutput',false),'fontsize',20)
    ylabel('Frequency, kHz','fontsize',20); colorbar 
          
end



