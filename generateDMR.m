%Generate DMR
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
S.f0            = 880;    % base frequency in Hz 
S.nCarriersOct  = 43;      % number of carrier freqq. per octave, Escabi and Schreiner used 230 carriers over 5.32 octaves (0.5 - 20kHz)
S.nOctaves      = 4;    % A4~A10 (440Hz~28kHz)
vCarrierFreq    = S.f0 * 2.^linspace(0, S.nOctaves, S.nCarriersOct * S.nOctaves+1)';
S.f1            = S.f0 * 2^2;
vLogFreq        = log2(vCarrierFreq./S.f1);

%  modulation rates
S.mod_type      = 'LogFm_LogTm';
S.fm_period     = 437; 
S.tm_period     = 23;
S.dur           = lcm(S.fm_period, S.tm_period); % least common multiplier
S.t             = 0: 1/S.fs :S.dur - 1/S.fs;

S.fm_cycles     = S.dur/S.fm_period;
S.tm_cycles     = S.dur/S.tm_period;
S.fm_range      = [1/8, 8];
S.tm_range      = [-32, 32].*2*pi;

% ====== log scan =====
fm1             = logspace(log10(S.fm_range(1)),log10(S.fm_range(2)),floor(S.fm_period.*S.fs./2)); % log scan, up and down
S.fm            = [fliplr(fm1), fm1]; 
S.fm            = repmat(S.fm, 1, S.fm_cycles);
S.tm            = logspace(log10(1/2), log10(S.tm_range(2)), floor(S.tm_period.*S.fs/2));
S.tm            = [-fliplr(S.tm),S.tm];
S.tm            = repmat(S.tm, 1, S.tm_cycles);

% S.tm            = interp1([1, S.tm_period*S.fs], S.tm_range, 1:S.tm_period*S.fs); % linear scan
% S.tm            = repmat(S.tm, 1, S.tm_cycles);
% ======================

% ====== sine scan =====
% S.fm            = (sin(2*pi*(1/S.fm_period)*S.t) + 1)./2; % sine scan
% S.fm            = S.fm_range(1) + S.fm.*(S.fm_range(2) - S.fm_range(1)); % normalize to proper range
% S.tm            = (sin(2*pi*(1/S.tm_period)*S.t) + 1)./2; % cycles per octave
% S.tm            = S.tm_range(1) + S.tm.*(S.tm_range(2) - S.tm_range(1)); % normalize to proper range
% ====== "exponential sine" scan ===
% this method emphasize the low modulation frequencies while maintaining
% continuity at the maxima points
% x1              = sin(2*pi*(1/S.fm_period)*S.t); % sine scan
% S.fm            = 2.^(3.*x1); % range = 1/8 - 8
% x1              = sin(2*pi*(1/S.tm_period)*S.t);
% S.tm            = (2.^(3.*x1+2)).*(2*pi);
% ======================

% S.fm            = repmat([1/8, 1/4, 1/2, 1, 2, 4, 8],round(S.fs*S.tm_period/2),1);
% S.fm            = reshape(S.fm,1,size(S.fm,1)*size(S.fm,2));
% S.tm            = 2.*ones(size(S.t)); 


% fun             = @(x) S.tm_range(1) + ((sin(2*pi*(1/S.tm_period)*x) + 1)./2).*(S.tm_range(2) - S.tm_range(1));
%% ===== generate DMR sound =====
vPhi = rand([1,size(vCarrierFreq,1)])*2*pi; % random phase for carrier signal
S.wav = zeros(size(S.t));

Omega   = S.fm;
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

figure,
subplot(3,1,1),plot(S.t, S.fm),title('frequency modulation rate (cycles/octave)')
subplot(3,1,2),plot(S.t, S.tm./(2*pi)),title('temporal modulation rate (cycles/second)')
subplot(3,1,3),plot(S.t, S.wav),title('Signal temporal trace')
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
filename = ['D:\=sounds=\DMR\2019-8-27\DRM_',num2str(S.dur),'sec_', num2str(S.fm_period),'fm_', num2str(S.tm_period),'tm_',S.mod_type,'_',num2str(S.nCarriersOct),'carriers_A5-A9_f1=A7'];
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