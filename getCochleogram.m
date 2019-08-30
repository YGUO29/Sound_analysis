function [Mat_env, Mat_env_ds, MatdB, cf, t_ds] = getCochleogram(Sd, windur, mode, plotON)
% Reference: Slaney 1993 (Patterson-Holdsworth auditory filter bank, 1992)
% Given a waveform and SR, plot ERB gammatonegram based on:
% Determine the Equivalent Rectangular Bandwidths of the Filter Bank (in Hz)
lengthwindow = round(Sd.fs*windur);
ERB_freq_Raw =  [  250     500     1000    7000    16000];
ERB_raw =       [  90.97   126.85  180.51  460.83  2282.71];

if strcmp(mode,'log') % frequency spacing is 1/24 octave
%     cf = logspace(log10(windur/2),log10(S.fs/2),length(FreqAx)); % log scale
%     cf = logspace(log10(1/windur),log10(Sd.fs/2),220); % log scale
    spacing = 1/24;
    cf = 2.^(log2(20) : spacing : log2(Sd.fs/2));
%     cf = 2.^(log2(100) : spacing : log2(21000));
    ERB = interp1(ERB_freq_Raw,	ERB_raw, cf,'pchip'); 
elseif strcmp(mode,'linear') % with 100Hz interval
    FreqAx = [0.2:1:floor(lengthwindow/2)-1]*Sd.fs/(1000*lengthwindow); % Frequency scale in kHz 
    cf = FreqAx.*1000; % linear scale
    ERB = interp1(ERB_freq_Raw,	ERB_raw, cf,'pchip'); 
elseif strcmp(mode,'ERB') % overlap by 0.2 ERB
    overlap = 0.2;
    cf_temp =   20; % first cf at min frequency resolution value
    cf =        cf_temp; % initialize first cf
    ERB_temp =  interp1(ERB_freq_Raw, ERB_raw, cf_temp,'pchip'); % initialize first ERB
    ERB =       ERB_temp;
    while cf_temp + overlap*ERB_temp < 21000 % or Sd.fs/2
        cf_temp     = cf_temp + overlap*ERB_temp; % determin how much overlap between channels
        cf          = [cf cf_temp];
        ERB_temp    = interp1(ERB_freq_Raw, ERB_raw, cf_temp,'pchip'); 
        ERB = [ERB ERB_temp];
    end
    
end

% convert to colume vector
if size(cf,1) == 1
    cf = cf';
end

if size(ERB,1) == 1
    ERB = ERB';
end

% ===== plot cf and ERB =====
% figure,semilogx(cf,ERB,'.','markersize',12)
% hold on, semilogx(ERB_freq_Raw, ERB_raw,'*','markersize',12)
% xticks([min(cf),ERB_freq_Raw])
% xlabel('Center Frequency (Hz)','fontsize',16)
% ylabel('ERB (Hz)','fontsize',16)
% title(['Frequency sampling on ',mode,' scale'],'fontsize',16)
%% Filter Banks Parameters
% algorithm copied from ???
% parameters: T, B, cf needed, 
% T     is the sampling inteval
% B     is a vector of bandwidths related to ERB
% cf    is a vector of CFs of filters

T = 1/Sd.fs;
B = 1.019*2*pi*ERB;

A0 = T *    ones(length(cf),1);
A2 = 0 *    ones(length(cf),1);
B0 = 1 *    ones(length(cf),1);
B1 = -2*cos(2*cf*pi*T)./exp(B*T);
B2 = exp(-2*B*T);

A11 = -(2*T*cos(2*cf*pi*T)./exp(B*T) + 2*sqrt(3+2^1.5)*T*sin(2*cf*pi*T)./exp(B*T))/2;
A12 = -(2*T*cos(2*cf*pi*T)./exp(B*T) - 2*sqrt(3+2^1.5)*T*sin(2*cf*pi*T)./exp(B*T))/2;
A13 = -(2*T*cos(2*cf*pi*T)./exp(B*T) + 2*sqrt(3-2^1.5)*T*sin(2*cf*pi*T)./exp(B*T))/2;
A14 = -(2*T*cos(2*cf*pi*T)./exp(B*T) - 2*sqrt(3-2^1.5)*T*sin(2*cf*pi*T)./exp(B*T))/2;

gain = abs((-2*exp(4*i*cf*pi*T)*T + ...
                 2*exp(-(B*T) + 2*i*cf*pi*T).*T.* ...
                         (cos(2*cf*pi*T) - sqrt(3 - 2^(3/2))* ...
                          sin(2*cf*pi*T))) .* ...
           (-2*exp(4*i*cf*pi*T)*T + ...
             2*exp(-(B*T) + 2*i*cf*pi*T).*T.* ...
              (cos(2*cf*pi*T) + sqrt(3 - 2^(3/2)) * ...
               sin(2*cf*pi*T))).* ...
           (-2*exp(4*i*cf*pi*T)*T + ...
             2*exp(-(B*T) + 2*i*cf*pi*T).*T.* ...
              (cos(2*cf*pi*T) - ...
               sqrt(3 + 2^(3/2))*sin(2*cf*pi*T))) .* ...
           (-2*exp(4*i*cf*pi*T)*T + 2*exp(-(B*T) + 2*i*cf*pi*T).*T.* ...
           (cos(2*cf*pi*T) + sqrt(3 + 2^(3/2))*sin(2*cf*pi*T))) ./ ...
          (-2 ./ exp(2*B*T) - 2*exp(4*i*cf*pi*T) +  ...
           2*(1 + exp(4*i*cf*pi*T))./exp(B*T)).^4);

%% Determine filtering 
% filterring on waveform
Mat_raw = single( zeros( size(gain,1), length(Sd.wav) ) );
for chan = 1: size(gain,1)
%     chan
	y1=filter([A0(chan)/gain(chan) A11(chan)/gain(chan) ...
		   A2(chan)/gain(chan)], ...
				[B0(chan) B1(chan) B2(chan)], Sd.wav);
	y2=filter([A0(chan) A12(chan) A2(chan)], ...
				[B0(chan) B1(chan) B2(chan)], y1);
	y3=filter([A0(chan) A13(chan) A2(chan)], ...
				[B0(chan) B1(chan) B2(chan)], y2);
	y4=filter([A0(chan) A14(chan) A2(chan)], ...
				[B0(chan) B1(chan) B2(chan)], y3);
    Mat_raw(chan, :) = y4;
end
    % Mat is a matrix of (filter# * waveform sample#)

%% extract envelope
% for j = 1:size(Mat_raw,1)
%     c = max(Mat_raw(j,:),0);
%     c = filter([1],[1 -.99],c);
%     Mat_raw(j,:)= c;
% end

Mat_env = abs(hilbert(Mat_raw'));
Mat_env = Mat_env';

%% downsample
% bin on temporal axis
t           = 0:T:length(Sd.wav)/Sd.fs-T;
t_ds        = 0:windur:length(Sd.wav)/Sd.fs-windur; % downsampled time series
tsin        = timeseries(Mat_env',t);
tsout       = resample(tsin,t_ds);
Mat_env_ds  = tsout.Data';

% binwidth =      floor(Sd.fs*windur); % number of samples
% nSeg =          floor(size(Mat_env,2)/binwidth);
% Mat_env_ds =    zeros(size(Mat_env,1),nSeg);
% for k = 1:nSeg
%     Mat_env_ds(:,k) = mean(Mat_env(:, (k-1)*binwidth+1 : k*binwidth),2);
%     t_ds(k)         = t((k-1)*binwidth+1);
% end

%% plot cochleagram, convert amplitude to log scale
% dBdynrange =    70;
% Matmax =        max(max(Mat_raw_env));
% Matmin =        Matmax/(10^(dBdynrange/20)); 
% MatdB =         20*log10(max(Mat_raw_env, Matmin)./Matmin);


dBdynrange      = 70;
Matmax          = max(max(Mat_env_ds));
Matmin          = Matmax/(10^(dBdynrange/20)); 
MatdB           = 20*log10(max(Mat_env_ds, Matmin)./Matmin);

Mat_env_ds      = abs(Mat_env_ds.^0.3);


if plotON
    imagesc(Mat_env_ds)
%     imagesc(MatdB)
    colorbar, axis('xy'), 
    t_ind = []; ts = [0.5,1,1.5];
    for k = 1:length(ts)
        [~,t_ind(k)] = min( abs(t_ds-ts(k)) );
    end
    set(gca,'xtick',t_ind)
    set(gca,'xticklabels',arrayfun(@num2str,ts,'UniformOutput',false),'fontsize',10)
    xlabel('Time, s','fontsize',10);  
    title(['Cochleagram, ',mode,', ',strrep(Sd.SoundName, '_', '-')],'fontsize',10)
    switch mode
    % label some frequencies for linear mode
        case 'linear'
        freqs = [4000, 7000, 14000, 21000];
          
    % label some frequencies for log mode  
        case 'log'
        freqs = floor([440*2.^([0:5]), max(cf)]./10).*10; % the index of 10
  
    % label some frequencies for ERB mode
        case 'ERB'
        freqs = floor([440*2.^([1:5]), max(cf)]./10).*10; % the index of 10
        
        otherwise
            disp('mode: linear, log or ERB')
            
    end
    y_ind = []; 
    for k = 1:length(freqs)
        [~,y_ind(k)] = min( abs(cf-freqs(k)) );
    end
    set(gca,'ytick',y_ind)
    set(gca,'yticklabels',arrayfun(@num2str,freqs./1000,'UniformOutput',false),'fontsize',10)
    ylabel('Frequency, kHz','fontsize',10); colorbar 
          
end



