function [y, rms, fund, harm] = narrow_synth(callstruct, type, SR)
% NARROW_SYNTH
% To synthesize narrowband virtual vocalization and complex tone

% Notes:
% - VirtualCall V2.0 
% - reference from Dimattina and Wang. JN. 2006 
% - modified from xb_vv_rand by Yi Zhou 2006
% - based upon xb_vv_trillsynth by Chris Dimattina 2005
% - by Chia-Jung Chang 22-Jun-2013

% Modifications:
% - able to handle random backbones
% - able to handle higher-order harmonics
% - able to handle noise with SNR and BW
% - computing power is more efficient
% - correct several equation errors 
% - remove onset/offset 5 msec ramps (aleady added in VirtualCall GUI)

% Inputs:
% - SR 				- sampling rate
% - callstruct 	    - structure with narrowband call parameters
% - type            - call type (1: Tone, 2: Phee, 3: Trill, 4: Trillphee)

% Outputs:
% - y 				- entire signal data
% - rms             - RMS for the signal y
% - fund			- fundamental component of signal
% - harm			- harmonic component of signal

% Subfunction:
% - binone.m 

% Parameters: 
% - trillstruct.FM1_back    - FM1 backbone       (scaled to [0,1])  default 1
% - trillstruct.FM2_back    - FM2 backbone       (scaled to [0,1])  default 1
% - trillstruct.FM1_depth   - FM1 depth contour  (scaled to [0,1])  default 1
% - trillstruct.FM2_depth   - FM2 depth contour  (scaled to [0,1])  default 1
% - trillstruct.FM1_rate    - FM1 rate contour   (scaled to [0,1])  default 0
% - trillstruct.FM2_rate    - FM2 rate contour   (scaled to [0,1])  default 0
% - trillstruct.AM1_back    - AM1 backbone       ([0,1])            default 1
% - trillstruct.AM2_back    - AM2 backbone       ([0,1])            default 1
% - trillstruct.AM1_rate    - AM1 rate contour   (scaled to [0,1])  default 0
% - trillstruct.AM2_rate    - AM2 rate contour   (scaled to [0,1])  default 0
% - trillstruct.f2f1        - harmonic ratio                        default 2
% - trillstruct.initfmphase - initial FM phase    (radians)         default pi
% - trillstruct.am1fm1shift - AM1-FM1 phase shift (radians)	        default pi
% - trillstruct.am2fm1shift - AM2-FM1 phase shift (radians)         default pi
% - trillstruct.fm1mod      - backbone freq modulation depth        (Hz)
% - trillstruct.fm2mod      - backbone freq modulation depth        (Hz)
% - trillstruct.fm1_rate    - mean FM1 rate 					    (Hz)
% - trillstruct.fm2_rate    - mean FM2 rate 					    (Hz)
% - trillstruct.fm1_depth   - max FM1 depth 					    (Hz or oct)
% - trillstruct.fm2_depth   - max FM2 depth 					    (Hz or oct)
% - trillstruct.am1mod      - backbone amplitude modulation ratio   ([0,1])
% - trillstruct.am2mod      - backbone amplitude modulation ratio   ([0,1])
% - trillstruct.am1_depth   - mean AM1 depth 					  	([0,1])
% - trillstruct.am2_depth   - mean AM2 depth 					  	([0,1])
% - trillstruct.am1_rate    - mean AM1 rate 				      	(Hz)
% - trillstruct.am2_rate    - mean AM2 rate 					  	(Hz)
% - trillstruct.fc          - center frequency 					  	(Hz)
% - trillstruct.dur         - call duration 					  	(sec)
% - trillstruct.rAttn       - harmonic attenuation 				  	(dB)
% - trillstruct.snr         - Signal-to-Noise Ratio               	(dB)
% - trillstruct.bpbw        - noise bandwidth                     	(oct)
% - trillstruct.hbw         - harmonic bandwidth centered at fc   	(oct)             
% - trillstruct.trans       - time of transition    				([0,1])
% - trillstruct.seed        - psuedo random seed 
% - trillstruct.order       - harmonic order (fc/f0)
% - trillstruct.fmdepth_oct - FM depth unit  (1: oct, 0: Hz)
% - trillstruct.rev         - time reversed option [FM, AM] (default [0 0])

% ==============================================================================   
%% ======= Number of points and Time vector ====================================

Npts = round(SR*callstruct.dur) + 1;        	% number of points in call
x = (0:(Npts-1))/(Npts-1);                  	% normalized time vector

if (type == 2) || (type == 4)                   % PHEE or TRILLPHEE 
	Npts_trill = round(Npts*callstruct.trans);  % number of points for trill
	xt = (0:(Npts_trill-1))/(Npts_trill-1);     % normalized time vector for trill
else 
	Npts_trill = Npts;
	xt = x;
end

%% ======= Harmonics parameters ================================================

cf = callstruct.fc;                             % center frequency
f0 = cf/callstruct.order;                       % fundamental frequency
A2A1 = callstruct.A2A1;                         % harmonic attenuation

bw_upp = callstruct.hbw/2;                      % bandwidth upper boundaries
bw_low = bw_upp;                                % bandwidth lower boundaries
harm_upp = floor(2^(bw_upp)*callstruct.order);  % order upper boundaries
harm_low = ceil(2^(-bw_low)*callstruct.order);  % order lower boundaries

% nHarm: number of harmonics
if (harm_low == 1), nHarm = harm_upp - harm_low;
else nHarm = harm_upp - harm_low + 1; 
end


%% ======= FM frequency contour ================================================

% FM1_back = beta_FM1(t): normalized function for shaping trajectory [0, 1]
FM1_back = callstruct.FM1_back;                 

% bfm1 = b_FM1(t): slowly modulated component of frequency contour
% fm1mod = M_FM1: slow frequency modulation depth 
% No slowly modulated component for complex tone 
% Use spline interpolation instead of polyfit to capture fast oscillators
% Ref: (Eq. 8) in Dimattina and Wang. JN. 2006
if min(FM1_back) == max(FM1_back)
    bfm1 = max(FM1_back)*ones(size(x));
	bfm1 = callstruct.fm1mod*(bfm1-0.5) + f0;
else                                          
    lbfm1 = length(FM1_back); 
    bfm1 = interp1(binone(lbfm1), FM1_back, x, 'spline', 'extrap'); 
	bfm1 = callstruct.fm1mod*(bfm1-0.5) + f0;
end

% FM1_depth = delta_FM1(t): normalized depth function in template call 
% fm1_depth = d_FM1_max(t): maximum fast modulation depth in trilling 
FM1_depth = callstruct.FM1_depth; 
fm1_depth = callstruct.fm1_depth;

% Dfm1 = delta_FM1(t): normalized depth function for trajectory [0, 1]
% dfm1 = d_FM1(t): fast sinusoidal modulation depth 
% Only for trilling part in the call (0 for time larger than dur*tTrans)
% Use spline interpolation instead of polyfit to capture fast oscillators
% Ref: (Eq. 11) in Dimattina and Wang. JN. 2006
if min(FM1_depth) == max(FM1_depth)
    Dfm1 = max(FM1_depth)*ones(size(xt));
	if (max(Dfm1) == 0), Dfm1 = 0; 		
	else Dfm1 = Dfm1/max(Dfm1);  
	end
	dfm1 = (fm1_depth)*Dfm1;
else
    ldfm1 = length(FM1_depth);
    Dfm1 = interp1(binone(ldfm1), FM1_depth, xt, 'spline', 'extrap'); 
	if (max(Dfm1) == 0), Dfm1 = 0; 		
	else Dfm1 = Dfm1/max(Dfm1);  
	end
	dfm1 = (fm1_depth)*Dfm1;	
end

% FM1_rate: normalized rate function in template call 
% fm1_rate = f_FM1: mean fast modulation rate in trilling 
FM1_rate = callstruct.FM1_rate;
fm1_rate = callstruct.fm1_rate;

% f1rate = f_FM1(t): fast frequency sinusoidal modulation rate 
% Re-centered at f_FM1 and eliminate negative trill rates
% Ref: (p. 1248) in Dimattina and Wang. JN. 2006
if min(FM1_rate) == max(FM1_rate)
    f1rate = max(FM1_rate)*ones(size(xt));
	f1rate = fm1_rate + f1rate - mean(f1rate); 	
	f1rate(f1rate < 0) = 0;
else
    lf1rate = length(FM1_rate);
    f1rate = interp1(binone(lf1rate), FM1_rate, xt, 'spline', 'extrap'); 
	f1rate = fm1_rate + f1rate - mean(f1rate); 	
	f1rate(f1rate < 0) = 0;
end

% f1 = f1(t): fundamental frequency contour
% sfm1 = s_FM1(t): fastly modulated component of frequency contour
% initfmphase = theta_FM1: initial phase parameter
% f1_instphase = theta_FM1(t): time varying component  
% Ref: (Eq. 9) and (Eq. 10) in Dimattina and Wang. JN. 2006 
% Note that original Eq. 9 was wrong in the paper 
f1 = bfm1;                          
f1rate_rad = 2*pi*f1rate;
f1_instphase = cumsum(f1rate_rad*(1/SR));
f1_phase = f1_instphase + callstruct.initfmphase;
sfm1 = (dfm1/2).*cos(f1_phase);

% f1(t) = b_FM1(t) + s_FM1(t)
% Ref: (Eq. 7) in Dimattina and Wang. JN. 2006
if callstruct.fmdepth_oct == 0 % Hz scale 
    f1(1:Npts_trill) = f1(1:Npts_trill) + sfm1;
else % octave scale 
    f1(1:Npts_trill) = f1(1:Npts_trill).*(2.^(sfm1));
end


%% ======= AM amplitude contour ================================================

% AM1_back = normalized function for shaping trajectory [0, 1]
AM1_back = callstruct.AM1_back;

% bam1 = b_AM1(t): slowly modulated component of amplitude contour
% am1mod: slow amplitude modulation comopoment
if min(AM1_back) == max(AM1_back)
    bam1 = max(AM1_back)*ones(size(x));
else                                          
    lbam1 = length(AM1_back); 
    bam1 = interp1(binone(lbam1), AM1_back, x, 'spline', 'extrap');
    bam1 = bam1./max(bam1);
    bam1 = callstruct.am1mod*(bam1-1) + 1;
end

% AM1_rate: normalized rate function in template call 
% am1_rate = f_AM1: mean fast modulation rate in trilling 
AM1_rate = callstruct.AM1_rate;
am1_rate = callstruct.am1_rate;

% a1rate = f_AM1(t): fast amplitude sinusoidal modulation rate 
% Re-centered at f_AM1 and eliminate negative trill rates
% Ref: (p. 1248) in Dimattina and Wang. JN. 2006
if min(AM1_rate) == max(AM1_rate)
    a1rate = max(AM1_rate)*ones(size(xt));
	a1rate = am1_rate + a1rate - mean(a1rate); 
	a1rate(a1rate < 0) = 0;
else
    la1rate = length(AM1_rate);
    a1rate = interp1(binone(la1rate), AM1_rate, xt, 'spline', 'extrap'); 
	a1rate = am1_rate + a1rate - mean(a1rate); 
	a1rate(a1rate < 0) = 0;
end

% a1 = A1(t): fundamental envelope
% Set non-trilling portion equal to backbone trajectory  
a1 = zeros(1, Npts);
a1(Npts_trill+1:end) = bam1(Npts_trill+1:end); 

% Set trilling portion
% initfmphase = theta_FM1: initial FM phase 
% am1_depth = d_AM1(t): fast amplitude modulation depth 
% a1_instphase = theta_AM1(t): time varying component
% am1fm1shift = theta_AM1: AM1-FM1 phase shift                
bam1t = bam1(1:Npts_trill);
a1rate_rad = 2*pi*a1rate;
am1_depth = callstruct.am1_depth;
a1_instphase = cumsum(a1rate_rad*(1/SR));
a1_phase = a1_instphase + callstruct.am1fm1shift + callstruct.initfmphase + pi;
a1(1:Npts_trill) = bam1t - am1_depth*bam1t.*(0.5 + 0.5*cos(a1_phase));
a1 = a1/max(a1);


%% ======= Time Reversed Option ================================================

% Reverse f1
if callstruct.rev(1), f1 = fliplr(f1);	end

% Reverse a1 
if callstruct.rev(2), a1 = fliplr(a1); end


%% ======= Fundamental synthesis ===============================================

% Modulate oscillators around band center frequency and integrate
% Ref: (Eq. 5) in Dimattina and Wang. JN. 2006
f1 = f1/SR;    
f1 = cumsum(f1);

% Define cosine oscillators
% Ref: (Eq. 4) and (Eq. 6) in Dimattina and Wang. JN. 2006
w1 = cos(2*pi*f1 - pi/2);

% Define fundamental component 
% Ref: (Eq. 2) in Dimattina and Wang. JN. 2006
fund = w1.*a1;


%% ======= Harmonics synthesis =================================================

% Create higher-order harmonic contour (both frequency and amplitude)
for h_idx = 1:nHarm    
    
    h_parm = (h_idx+1)/2;
    
	% ------------------------- FM ---------------------------------------------
	
    % FM2_back = beta_FM1(t): normalized function for shaping trajectory [0, 1]
	% bfm2 = b_FM2(t): slowly modulated component of frequency contour
	% fm2mod = M_FM2: slow frequency modulation depth 
	% No slowly modulated component for complex tone 
	% Use spline interpolation instead of polyfit to capture fast oscillators
	% Ref: (Eq. 8) in Dimattina and Wang. JN. 2006
    FM2_back = callstruct.FM2_back;
	if min(FM2_back) == max(FM2_back)
        bfm2 = max(FM2_back)*ones(size(x));
		bfm2 = callstruct.f2f1*f0*h_parm + callstruct.fm2mod*h_parm*(bfm2-0.5);
    else                                          
        lbfm2 = length(FM2_back); 
        bfm2 = interp1(binone(lbfm2), FM2_back, x, 'spline', 'extrap');
		bfm2 = callstruct.f2f1*f0*h_parm + callstruct.fm2mod*h_parm*(bfm2-0.5);
    end
	
	% FM2_depth = delta_FM2(t): normalized depth function in template call
	% fm2_depth = d_FM2_max(t): maximum fast modulation depth in trilling 	
    FM2_depth = callstruct.FM2_depth;
	fm2_depth = callstruct.fm2_depth*h_parm;
	
	% Dfm2 = delta_FM2(t): normalized depth function for trajectory [0, 1]
	% dfm2 = d_FM2(t): fast sinusoidal modulation depth 
	% Only for trilling part in the call (0 for time larger than dur*tTrans)
	% Use spline interpolation instead of polyfit to capture fast oscillators
	% Ref: (Eq. 11) in Dimattina and Wang. JN. 2006
    if min(FM2_depth) == max(FM2_depth)
        Dfm2 = max(FM2_depth)*ones(size(xt));
		if(max(Dfm2) == 0), Dfm2 = 0; 		
		else Dfm2 = Dfm2/max(Dfm2); 
		end
		dfm2 = (fm2_depth)*Dfm2;		
    else
        ldfm2 = length(FM2_depth);
        Dfm2 = interp1(binone(ldfm2), FM2_depth, xt, 'spline', 'extrap');
		if(max(Dfm2) == 0), Dfm2 = 0; 		
		else Dfm2 = Dfm2/max(Dfm2); 
		end
		dfm2 = (fm2_depth)*Dfm2;
    end

	% FM2_rate: normalized rate function in template call 
	% fm2_rate = f_FM1: mean fast modulation rate in trilling 
    FM2_rate = callstruct.FM2_rate;
	fm2_rate = callstruct.fm2_rate;
	
	% f2rate = f_FM2(t): fast frequency sinusoidal modulation rate 
	% Re-centered at f_FM2 and eliminate negative trill rates
	% Ref: (p. 1248) in Dimattina and Wang. JN. 2006
    if min(FM2_rate) == max(FM2_rate)
        f2rate = max(FM2_rate)*ones(size(xt));
		f2rate = f2rate - mean(f2rate) + fm2_rate;
		f2rate(f2rate < 0) = 0;		
    else
        lf2rate = length(FM2_rate);
        f2rate = interp1(binone(lf2rate), FM2_rate, xt, 'spline', 'extrap'); 
		f2rate = f2rate - mean(f2rate) + fm2_rate; 	
		f2rate(f2rate < 0) = 0;
    end

	% f2 = f2(t): harmonic frequency contour
	% sfm2 = s_FM2(t): fastly modulated component of frequency contour
	% initfmphase = theta_FM1: initial phase parameter
	% f2_instphase = theta_FM2(t): time varying component  
	% Ref: (Eq. 9) and (Eq. 10) in Dimattina and Wang. JN. 2006 
	% Note that original Eq. 9 was wrong in the paper 	
    f2 = bfm2;       
    f2rate_rad = 2*pi*f2rate;
    f2_instphase = cumsum(f2rate_rad*(1/SR));
    f2_phase = f2_instphase + callstruct.initfmphase;
	sfm2 = (dfm2/2).*cos(f2_phase);
	
    % f2(t) = b_FM2(t) + s_FM2(t)
	% Ref: (Eq. 7) in Dimattina and Wang. JN. 2006
    if callstruct.fmdepth_oct == 0 
        f2(1:Npts_trill) = f2(1:Npts_trill) + sfm2;
    else                       
        f2(1:Npts_trill) = f2(1:Npts_trill).*(2.^(sfm2));
    end
    
	% ------------------------- AM ---------------------------------------------
	
	% AM2_back = normalized function for shaping trajectory [0, 1]
    AM2_back = callstruct.AM2_back;
	
	% bam2 = b_AM2(t): slowly modulated component of amplitude contour
	% am2mod = d_AM2(t): fast amplitude modulation depth 
    if min(AM2_back) == max(AM2_back)
        bam2 = max(AM2_back)*ones(size(x));
    else                                          
        lbam2 = length(AM2_back); 
        bam2 = interp1(binone(lbam2), AM2_back, x, 'spline', 'extrap');
        bam2 = bam2./max(bam2);
        bam2 = callstruct.am2mod*(bam2-1) + 1;
    end

	% AM2_rate: normalized rate function in template call 
	% am2_rate = f_AM2: mean fast modulation rate in trilling 
    AM2_rate = callstruct.AM2_rate;
	am2_rate = callstruct.am2_rate;
	
	% a2rate = f_AM2(t): fast amplitude sinusoidal modulation rate 
	% Re-centered at f_AM2 and eliminate negative trill rates
	% Ref: (p. 1248) in Dimattina and Wang. JN. 2006
    if min(AM2_rate) == max(AM2_rate)
        a2rate = max(AM2_rate)*ones(size(xt));
		a2rate = a2rate - mean(a2rate) + am2_rate; 
		a2rate(a2rate < 0) = 0;
    else
        la2rate = length(AM2_rate);
        a2rate = interp1(binone(la2rate), AM2_rate, xt, 'spline', 'extrap'); 
		a2rate = a2rate - mean(a2rate) + am2_rate; 
		a2rate(a2rate < 0) = 0;
    end

    % a2 = A2(t): fundamental envelope
	% Set non-trilling portion equal to backbone trajectory  
    a2 = zeros(1, Npts);
    a2(Npts_trill+1:end) = bam1(Npts_trill+1:end);                
	
	% Set trilling portion
	% initfmphase = theta_FM1: initial FM phase 
	% a2_instphase = theta_AM2(t): time varying component
	% am2fm1shift = theta_AM2: AM2-FM1 phase shift
	bam2t = bam2(1:Npts_trill);	
    a2rate_rad = 2*pi*a2rate;
    am2_depth = callstruct.am2_depth;
    a2_instphase = cumsum(a2rate_rad*(1/SR));
    a2_phase = a2_instphase + callstruct.am2fm1shift + callstruct.initfmphase + pi;
    a2(1:Npts_trill) = bam2t - am2_depth*bam2t.*(0.5 + 0.5*cos(a2_phase));
    a2 = a2/max(a2);
	
	% ------------------------- Time Reversed Option ---------------------------

	% Reverse f1
	if callstruct.rev(1), f2 = fliplr(f2); end

	% Reverse a1 
	if callstruct.rev(2), a2 = fliplr(a2); end
	
    % ------------------------- Combined ---------------------------------------
	
    % Modulate oscillators around band center frequency and integrate	  
    f2 = f2/SR;	   
    f2 = cumsum(f2);
    
	% Define cosine oscillators               
    w2 = cos(2*pi*f2 - pi/2);    	
    
	% Define harmonic component 						
    harm{h_idx} = w2.*a2;		

end


%% ======= Synthesis ===========================================================

% Combine harmonic array
harm = harm';
h_array = cell2mat(harm);

% Synthesize signal y
if harm_low == 1
    y = (fund + (A2A1)*sum(h_array, 1))/(1 + A2A1*nHarm);
    y = y/max(abs(y)); 
else
    y = (A2A1)*sum(h_array(harm_low-1:end, :), 1)/(1 + A2A1*nHarm);
    y_0dB = abs(sum(h_array(harm_low-1:end, :), 1)/(1 + nHarm));
    max_y = max(y_0dB);
    y = y/max_y; 
end


%% ======= Background Noise ====================================================

rms = norm(y)/sqrt(length(y));                  % calculate root-mean-square
bw = callstruct.bpbw;                           % noise bandwidth boundaries 
start = cf*2^(-bw/2);                           % lower cut-off frequency 
stop = cf*2^(bw/2);                             % upper cut-off frequency 

% Generate noise for masking
n = RandStream('mcg16807','Seed', callstruct.seed);  
RandStream.setGlobalStream(n);
noise_raw = randn(1, length(y));

% FIR filter
if (stop>49400 && start>=200) % high-pass
    a = 1; n = 200; m = [0 0 1 1];
    b = fir2(n, [0 start*.99 start (SR/2)]/(SR/2), m);
    noise = filtfilt(b, a, noise_raw);
    
elseif (stop<=49400 && start<200) % low-pass
    a = 1; n = 200; m = [1 1 0 0];
    b = fir2(n, [0 stop stop*1.01 (SR/2)]/(SR/2), m);
    noise = filtfilt(b, a, noise_raw);

elseif (stop>49400 && start<200) % wide-band
    noise = noise_raw;

else % band-pass
    a = 1; n = 200; m = [0 0 1 1 0 0];
    b = fir2(n, [0 start*.99 start stop stop*1.01 SR/2]/(SR/2), m);
    noise = filtfilt(b, a, noise_raw);
end        

% SNR = 20*log10(rms(signal)/rms(noise))
rms_noise = norm(noise)/sqrt(length(noise));
rms_desired = rms*10^(-callstruct.snr/20);

% Normalize noise to desired rms
noise = noise*rms_desired/rms_noise;

% Check for pure tone or pure noise
if (bw == 0), noise = 0; end
if (callstruct.snr == 0), y = 0; end 

% Add noise to signal
y = y + noise;
