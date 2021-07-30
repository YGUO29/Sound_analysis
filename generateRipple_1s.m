%Generate static ripples
%   The Ripple spectrotemporal envelope is expressed as 
%   S(t,x) = M/2 * sin( 2 * pi(omega of t + Omega of x) + Phase phi of t)

% stimulus overall parameters
S.plotON        = 0;
S.fs            = 1e5; % sampling rate
S.dur           = 1; % seconds (6s for single trials, 2s for cycle based
S.t             = 1/S.fs: 1/S.fs :S.dur;
S.M             = 45; % modulation depth of the envolope

% ===== frequency related parameters =====
% carrier frequencies
S.f0            = 440;    % base frequency in Hz 
S.nCarriersOct  = 43;      % (43) number of carrier freqq. per octave, Escabi and Schreiner used 230 carriers over 5.32 octaves (0.5 - 20kHz)
S.nOctaves      = 6;    % A10
vCarrierFreq    = S.f0 * 2.^linspace(0, S.nOctaves, S.nCarriersOct * S.nOctaves+1)';
vLogFreq        = log2(vCarrierFreq./S.f0);

%  modulation rates
% S.fm            = [0, 1/8, 1/4, 1/2, 1, 2, 4, 8]; % # = 8
% S.tm            = [1/2, 1, 2, 4, 8, 16, 32, 64, 128]; % # = 9
S.fm            = 2.^[-3:0.5:3]; % # = 8
S.fm            = [0, S.fm];
S.tm            = 2.^[0:0.5:7]; % # = 9

% S.fm            = [0, 1/8, 1/4]; % toy
% S.tm            = [128]; % # toy
S.tm            = [fliplr(-S.tm), 0, S.tm]; % all frequencies % total # = 17
S.nFm           = length(S.fm);
S.nTm           = length(S.tm);

% ===== generate Ripple sound =====
vPhi            = rand([1,size(vCarrierFreq,1)])*2*pi; % random phase for carrier signal
S.wav           = zeros(size(S.t));
Env_db          = zeros(length(vCarrierFreq), length(S.t));
Env_lin         = Env_db;
% ===== ramp parameters =========
S.ramp_time     = 0.02;
S.ramp_env      = ones(size(S.t));
ind1             = 1:floor(S.ramp_time*S.fs); % upward ramping data points
S.ramp_env(ind1) = sin(2*pi/(4*S.ramp_time).*S.t(ind1));
ind2             = length(S.ramp_env)+1-floor(S.ramp_time*S.fs):length(S.ramp_env); % downward ramping data points
S.ramp_env(ind2) = sin(2*pi/(4*S.ramp_time).*S.t(ind1) + pi/2);

if S.plotON
    figure, size_scr = get(0,'ScreenSize'); set(gcf,'position',[1 1 size_scr(3:4)])
end

for m = 1:S.nFm
    Omega   = S.fm(m);
    
    for n = 1:S.nTm
        Phi     = S.tm(n);
        S.wav           = zeros(size(S.t)); % clear S.wav before writing each sound!

        for i = 1:length(vCarrierFreq)
            x       = vLogFreq(i);
            f       = vCarrierFreq(i);
            phi     = vPhi(i); % random phase
    %         phi     = 0;
            Env_db(i, :)    = (S.M/2)*sin(2*pi*Omega*x + 2*pi*Phi.*S.t); % units of dB, [-S.M/2, S.M/2]
            Env_lin(i,:)    = 10.^((Env_db(i,:) - S.M/2) ./ 20); % convert dB to amplitude, [10^((-S.M)/20), 1]
    %         Env_lin(i,:)     = 1 + S.M*sin(2*pi*Omega*x + 2*pi*Phi.*S.t);
            S.wav           = S.wav + Env_lin(i,:).*sin(2*pi*f.*S.t + phi);
        end
        S.wav = S.wav./max(abs(S.wav));
        S.wav = S.wav.*S.ramp_env;

        savepath = 'D:\SynologyDrive\=sounds=\Ripple\Sound_Ripple_1s_43carriers(A4-A10)_F0(A4)_FM(0~8)cycpoct_TM(-128~128)Hz\';
        if ~exist(savepath)
            mkdir(savepath)
        end

        filename = [savepath, ...
            'Ripple_',num2str(S.dur),'sec_', num2str(S.nCarriersOct),'carriers=A4-A10_f1=A4_SM',...
            num2str(Omega, '%4.2f'), '_TM',num2str(Phi, '%4.2f')];
        save([filename,'.mat'],'S');
        audiowrite([filename,'.wav'],S.wav,S.fs);

        if S.plotON
        subplot( S.nFm, S.nTm, sub2ind([S.nTm, S.nFm], n, m) ),
            imagesc(S.t, [], flipud(Env_db)), colormap(jet)
            xlabel('time(s)'), ylabel('octave number')
            title(['FM=', num2str(Omega), ', TM=',num2str(Phi)])
            set(gca, 'Xtick', [0:0.5:S.dur]), 
            set(gca, 'Ytick', 1:S.nCarriersOct:length(vLogFreq))
            set(gca, 'YtickLabel',arrayfun(@num2str,flipud(vLogFreq(1:S.nCarriersOct:length(vLogFreq))),'UniformOutput',false))
            drawnow
        end
    
    end
end

%% check the signal
[ind,~] = find(vLogFreq == -3:3);

figure, 
for i = 1:length(ind)
hold on, plot(S.t(1:nPoints-1),test_diff(ind(i),:).*S.fs)
end
legend(arrayfun(@num2str, vCarrierFreq(ind), 'UniformOutput', false))
xlabel('time(s)'),
ylabel('temporal modulation rates')
% MaxDifference = 

%%f
player = audioplayer(S.wav,S.fs);
play(player)
%%
filename = ['DRM_',num2str(S.dur),'sec_', num2str(S.fm_period),'fm_', num2str(S.tm_period),'tm_',S.mod_type,'_',num2str(S.nCarriersOct),'carriers_A4-A10_f1=A7'];
save(filename,'S');
audiowrite([filename,'.wav'],S.wav,S.fs);
%% plot spectrogram and cochleagram
S.wav = wav_origin(1:floor(S.fm_period*S.fs));
plotON = 1; 
figure,
[ftx] = getSpectrogram(S,plotON,0.02);
mode = 'log';
windur = 0.03; 
figure,
[Mat_env, Mat_env_ds, MatdB, cf, t_ds] = getCochleogram(S, windur, mode, plotON);