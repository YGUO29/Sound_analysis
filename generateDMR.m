% Generate DMR (SM and TM rates are not random, defined by S.sm and S.tm)
%   The DMR spectrotemporal envelope is expressed as 
%
%      S(t,x) = M/2 * sin( 2 * pi(omega of t + Omega of x) + Phase phi of t)
%
%   M: the modulation depth of the envelope in decibels (30dB or 45dB) 
%   x: x = log2 (F/F0) where F0 is the basefreq (500 Hz) and F is the 
%   frequency of the tone. 
%   Phase phi of t: a function of time and controls the time-varying 
%   temporal modulation rate ( Phase Phi of t = Integral from 0 till t of 
%   Fm of t as a function of t where Fm is the time-varying temporal 
%   modulation rate).
%
%   Fm and omega of t are slowly time variying random signals 
%   (Fm of t<= 1.5 Hz and omega of t <=3 Hz)
%   Both parameters were designed with uniformly (flat) distributed
%   amplitudes in the intervals 0?4 cycles per octave for omiga
%   -350 to +350 Hz for Fm.

% stimulus overall parameters
S.fs            = 1e5; % sampling rate
% S.dur           = 2; % seconds
% S.t             = 0: 1/S.fs :S.dur;
S.M             = 45; % modulation depth of the envolope

% ===== frequency related parameters =====
% carrier frequencies
S.f0            = 440;    % base frequency in Hz 
S.nCarriersOct  = 43;      % number of carrier freqq. per octave, Escabi and Schreiner used 230 carriers over 5.32 octaves (0.5 - 20kHz)
S.nOctaves      = 6;    % A4~A10 (440Hz~28kHz)
vCarrierFreq    = S.f0 * 2.^linspace(0, S.nOctaves, S.nCarriersOct * S.nOctaves+1)';
S.f1            = S.f0 * 2^3;
vLogFreq        = log2(vCarrierFreq./S.f1);

%  modulation rates
S.sm_pattern    = 'CosLog';
S.tm_pattern    = 'CosLog';
S.sm_period     = 23; 
S.tm_period     = 19;
S.sm_range      = [1/8, 8];
S.tm_range      = [32, -32].*2*pi;

S.dur           = lcm(S.sm_period, S.tm_period); % least common multiplier
S.t             = 0: 1/S.fs :S.dur - 1/S.fs;

S.sm_cycles     = S.dur/S.sm_period;
S.tm_cycles     = S.dur/S.tm_period;


% ====== log scan =====
% sm1             = logspace(log10(S.sm_range(1)),log10(S.sm_range(2)),floor(S.sm_period.*S.fs./2)); % log scan, up and down
% S.sm            = [fliplr(sm1), sm1]; 
% S.sm            = repmat(S.sm, 1, S.sm_cycles);
% S.tm            = logspace(log10(S.tm_range(1)), log10(1/2), floor(S.tm_period.*S.fs/2));
% S.tm            = [S.tm, -fliplr(S.tm)];
% S.tm            = repmat(S.tm, 1, S.tm_cycles);

% S.tm            = interp1([1, S.tm_period*S.fs], S.tm_range, 1:S.tm_period*S.fs); % linear scan
% S.tm            = repmat(S.tm, 1, S.tm_cycles);
% ======================

% ====== sine scan =====
% S.sm            = (sin(2*pi*(1/S.sm_period)*S.t) + 1)./2; % sine scan
% S.sm            = S.sm_range(1) + S.sm.*(S.sm_range(2) - S.sm_range(1)); % normalize to proper range
% S.tm            = (sin(2*pi*(1/S.tm_period)*S.t) + 1)./2; % cycles per octave
% S.tm            = S.tm_range(1) + S.tm.*(S.tm_range(2) - S.tm_range(1)); % normalize to proper range
% ====== "exponential sine/cosine" scan ===
% this method emphasize the low modulation frequencies while maintaining
% continuity at the maxima points
x1              = cos(2*pi*(1/S.sm_period)*S.t); % sine scan
S.sm            = 2.^(3.*x1); % range = 1/8 - 8
x1              = cos(2*pi*(1/S.tm_period)*S.t);
S.tm            = (2.^(3.*x1+2)).*(2*pi); % range = 1/2 - 32
% ======================

% S.sm            = repmat([1/8, 1/4, 1/2, 1, 2, 4, 8],round(S.fs*S.tm_period/2),1);
% S.sm            = reshape(S.sm,1,size(S.sm,1)*size(S.sm,2));
% S.tm            = 2.*ones(size(S.t)); 


% fun             = @(x) S.tm_range(1) + ((sin(2*pi*(1/S.tm_period)*x) + 1)./2).*(S.tm_range(2) - S.tm_range(1));
%% ===== generate DMR sound =====
vPhi = rand([1,size(vCarrierFreq,1)])*2*pi; % random phase for carrier signal
S.wav = zeros(size(S.t));

Omega   = S.sm;
Phi     = cumsum(S.tm)./S.fs;
% plot some traces to verify the actural sound features
nPoints     = 3*S.fs*19;
test_env    = zeros(length(vCarrierFreq),nPoints);
test_phase  = test_env;
test_diff   = test_phase(:,1:end-1);
for i = 1:length(vCarrierFreq)
    x       = vLogFreq(i);
    f       = vCarrierFreq(i);
    phi     = vPhi(i);
%     Phi     = integral(fun, 0, S.tm(i)); 
    Env_db      = (S.M/2)*sin(2*pi*Omega*x + Phi);
    test_env(i,:)   = Env_db(1:nPoints);
    test            = (2*pi*Omega*x + Phi)./(2*pi);
    test_phase(i,:) = test(1:nPoints);
    test_diff(i,:)  = diff(test_phase(i,:));
    Env_lin = 10.^((Env_db - S.M/2) ./ 20);
    S.wav = S.wav + Env_lin.*sin(2*pi*f*S.t + phi);
end
S.wav = S.wav./max(abs(S.wav));

%%
figure('DefaultAxesFontSize',18, 'DefaultLineLineWidth', 2,'color','w','Position',[1440 200 900 900]);
subplot(3,1,1),plot(S.t, S.sm),title('spectral modulation rate (cycles/octave)'), yticks(S.sm_range), yticklabels({'1/8', '8'}), xlim([S.t(1), S.t(end)])
subplot(3,1,2),plot(S.t, S.tm./(2*pi)),title('temporal modulation rate (cycles/second)'), yticks([min(S.tm./(2*pi)), max(S.tm./(2*pi))]), yticklabels({'1/2', '32'}), xlim([S.t(1), S.t(end)])
subplot(3,1,3),imagesc([5*S.fs:17*S.fs]./S.fs, vCarrierFreq/1000, flipud(test_env(:,5*S.fs:17*S.fs))), 
xlabel('Time(s)'), ylabel ('Frequency (kHz)'), yticklabels({'25' '20' '15' '10' '5'}); title('Example spectrogram')

figure,
subplot(3,1,3),plot(S.t, S.wav),title('Signal temporal trace')

figure,
loglog(S.tm, S.sm)
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

%%
filename = ['D:\=sounds=\DMR\2019-9-20\DMR_',num2str(S.dur),'s_(SM@', num2str(S.sm_period),'s(',S.sm_pattern,num2str(S.sm_range(1),'%.3f'),'~',num2str(S.sm_range(2),'%.3f'),'cycPoct)_'...
    'TM@', num2str(S.tm_period),'s(',S.tm_pattern,num2str(S.tm_range(1)./(2*pi),'%.1f'),'~',num2str(S.tm_range(2)./(2*pi),'%.1f'),'Hz)_',...
    num2str(S.nCarriersOct),'x',num2str(S.nOctaves),'carriers@A4~A10&f1=A7'];
save(filename,'S');
audiowrite([filename,'.wav'],S.wav,S.fs);
%% plot spectrogram and cochleagram
S.wav = wav_origin(1:floor(S.sm_period*S.fs));
plotON = 1; 
figure,
[ftx] = getSpectrogram(S,plotON,0.02);
mode = 'log';
windur = 0.03; 
figure,
[Mat_env, Mat_env_ds, MatdB, cf, t_ds] = getCochleogram(S, windur, mode, plotON);