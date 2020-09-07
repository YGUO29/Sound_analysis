function [y, rms, fund, harm] = twitter_synth(callstruct, SR)
% TWITTER_SYNTH
% To synthesize virtual twitter

% Notes: 
% - VirtualCall V2.0 
% - reference from Dimattina and Wang. JN. 2006 
% - based upon xb_vv_twitsynth by Chris Dimattina 2005
% - by Chia-Jung Chang 22-Jun-2013

% Modifications:
% - able to modify phrase number and bandwidth 
% - able to handle noise with SNR and BW
% - able to modulate the calls in multiple ways
% - each phrase has onset/offset ramps
% - corrected several equation errors 

% Inputs:
% - SR 				- sampling rate
% - twitstruct   	- structure with twitter call parameters

% Outputs:
% - y 				- entire vocalization data
% - rms             - RMS for the signal y
% - fund			- fundamental component of vocalization
% - harm			- harmonic component of vocalization

% Subfunctions:
% - makeam.m 
% - makefm.m

% Parameters: 
% - twitstruct.dur          - call duration 					(sec)
% - twitstruct.tsw          - phrase sweep time vector          (sec) 
% - twitstruct.tkn          - time fraction of knee vector      ([0,1])
% - twitstruct.fkn          - freq fraction of knee vector 		([0,1])
% - twitstruct.bwv          - phrase bandwidth vector (fsp-fst) (Hz)
% - twitstruct.C_cell{:,1}  - starting frequency vector (fst)   (Hz)
% - twitstruct.C_cell{:,2}  - ending frequency vector   (fsp)   (Hz)
% - twitstruct.C_cell{:,3}  - same as twitstruct.fkn    (fkn)   ([0,1])
% - twitstruct.C_cell{:,4}  - same as twitstruct.tkn    (tkn)   ([0,1])
% - twitstruct.C_cell{:,5}  - same as twitstruct.tsw    (tsw)   (sec)
% - twitstruct.C_cell{:,6}  - relative phrase amplitude (ram)   ([0,1]) 
% - twitstruct.C_cell{:,7}  - before knee time vector	(t1bk)  ([0,1])   
% - twitstruct.C_cell{:,8}  - after knee time vector    (t1ak)	([0,1])  
% - twitstruct.C_cell{:,9}  - freq contour before knee  (f1bk)  (Hz)
% - twitstruct.C_cell{:,10} - freq contour after knee   (f1ak)  (Hz)
% - twitstruct.C_cell{:,11} - AM1 contour before knee  	(a1bk)  ([0,1])   
% - twitstruct.C_cell{:,12} - AM1 contour after knee    (a1ak)	([0,1])    
% - twitstruct.C_cell{:,13} - AM2 contour before knee  	(a2bk)	([0,1])   
% - twitstruct.C_cell{:,14} - AM2 contour after knee  	(a2ak)	([0,1])
% - twitstruct.C_cell{:,15} - same as twitstruct.C_cell{:,7}    ([0,1])
% - twitstruct.C_cell{:,16} - same as twitstruct.C_cell{:,8}    ([0,1]) 
% - twitstruct.fc           - center frequency 					(Hz)
% - twitstruct.bw           - mean mid-phrase bandwidth         (Hz)
% - twitstruct.IPI          - mean inter-phrase interval        (sec)
% - twitstruct.tphr         - mean phrase sweep time            (sec)  
% - twitstruct.tknee        - mean time fraction of knee        ([0,1])
% - twitstruct.fknee        - mean freq fraction of knee		([0,1])
% - twitstruct.rAttn        - harmonic attenuation 				(dB)
% - twitstruct.snr          - Signal-to-Noise Ratio             (dB)
% - twitstruct.bpbw         - noise bandwidth                   (oct)           
% - twitstruct.f2f1         - harmonic ratio                  
% - twitstruct.nphr         - phrase number 
% - twitstruct.seed         - psuedo random seed 
% - twitstruct.opt.ord      - phrase order        (0: normal, 1: reversed)
% - twitstruct.opt.noam     - AM mod              (0: normal, 1: flat AM)
% - twitstruct.opt.chop     - phrase chop         (0: normal, 1: before knee, 
%                                                  2: after knee)
% - twitstruct.cont         - multi-phrase source (1: count from beginning,
%                                                  2: replicate mid phrase)  
% - twitstruct.phr1         - one-phrase source   (1: 1st, 2: mid, 3: last) 
% - twitstruct.rev          - time reversed option [FM, AM] (default [0 0])

% ============================================================================== 
%% ======= Global and Phrase parameters ========================================

cf = callstruct.fc;                                % global center frequency
A2A1 = callstruct.A2A1;							   % global harmonic attenuation
C_cell = callstruct.C_cell;						   % phrase parameter structure 

bwgain = callstruct.bw/callstruct.bwv(5);          % gain to default (nphr = 9)
callstruct.bwv = callstruct.bwv*bwgain;            % updated phrase bandwidth
bwv = callstruct.bwv;							   % phrase bandwidth vector 

fkngain = callstruct.fknee/mean(callstruct.fkn);   % gain to default (nphr = 9)
callstruct.fkn = callstruct.fkn*fkngain;		   % update freq frac of 'knee'  
fkn = callstruct.fkn;                              % phrase fknee vector 

tkngain = callstruct.tknee/mean(callstruct.tkn);   % gain to default (nphr = 9)
callstruct.tkn = callstruct.tkn*tkngain;		   % update time frac of 'knee' 
tkn = callstruct.tkn; 							   % phrase tknee vector 

tswgain = callstruct.tphr/mean(callstruct.tsw);    % gain to default (nphr = 9)
callstruct.tsw = callstruct.tsw*tswgain;           % update phrase sweep time 
tsw = callstruct.tsw;                              % phrase sweep time vector 

for idx = 1:9
	C_cell(idx, 3) = {fkn(idx)};     			   % update fkn in C_cell
	C_cell(idx, 4) = {tkn(idx)}; 	  			   % update tkn in C_cell  
	C_cell(idx, 5) = {tsw(idx)};    			   % update tsw in C_cell 
end

	
%% ======= Reset phrase number =================================================

nphr = callstruct.nphr;	   						   % new phrase number
phr1 = callstruct.phr1;    						   % which section for one phrase
cont = callstruct.cont;    						   % how other phrases generated 

% Reset C_cell and bwv with repeated medium phrases (default nphr = 9)
if cont == 2
    switch nphr
        case 1 % only one phrse of twitter (unnatural)
            switch phr1
                case 1 % set phrase as the 1st phrase
					bwv = bwv(1);
                    C_cell = C_cell(1, :);
                case 2 % set phrase as the medium (5th phrase)
					bwv = bwv(5);
                    C_cell = C_cell(5, :);
                otherwise % set phrase as the last phrase
					bwv = bwv(end);
                    C_cell = C_cell(end, :);
            end
        case 2 % two phrases of twitter with 1st and last phrase (unnatural)
			bwv = [bwv(1) bwv(end)];
            C_cell = [C_cell(1, :); C_cell(end, :)];
        case 3
			bwv = [bwv(1) bwv(5) bwv(end)];
            C_cell = [C_cell(1, :); C_cell(5, :); C_cell(end, :)];
        case 4
			bwv = [bwv(1) bwv(4)  bwv(6) bwv(end)];
            C_cell = [C_cell(1, :); C_cell(4, :); C_cell(6, :); C_cell(end, :)];
        case 5
			bwv = [bwv(1) bwv(4:6) bwv(end)];
            C_cell = [C_cell(1, :); C_cell(4:6, :); C_cell(end, :)];
        case 6
			bwv = [bwv(1) bwv(3:4) bwv(6:7) bwv(end)];
            C_cell = [C_cell(1, :); C_cell(3:4, :); C_cell(6:7, :); C_cell(end, :)];
        case 7
			bwv = [bwv(1) bwv(3:7) bwv(end)];
            C_cell = [C_cell(1, :); C_cell(3:7, :); C_cell(end, :)];
        case 8
			bwv = [bwv(1:4) bwv(6:end)];
            C_cell = [C_cell(1:4, :);  C_cell(6:end, :)];
        otherwise % phrase number no less than 9 (the default) 
            delta_nphr = nphr - 9;
			rep_bwv = repmat(bwv(5), 1, delta_nphr);
			rep_phr = repmat(C_cell(5,:), delta_nphr, 1);
            bwv = [bwv(1:5) rep_bwv bwv(6:end)];
			C_cell = [C_cell(1:5, :); rep_phr; C_cell(6:end, :)];
    end
end

% Update parameters according to new phrase number 
fst = cell2mat(C_cell(:, 1))';					   % phrase starting freq vector
fsp = cell2mat(C_cell(:, 2))';                     % phrase ending freq vector
fkn = cell2mat(C_cell(:, 3))';                     % freq frac of 'knee' vector
tkn = cell2mat(C_cell(:, 4))';                     % time frac of 'knee' vector
tsw = cell2mat(C_cell(:, 5))';                     % phrase sweep time vector

%% Update fst and fsp
fc_def = 0.5*(fst(ceil(nphr/2)) + fsp(ceil(nphr/2)));
fc_delta = callstruct.fc - fc_def;

for idx = 1:nphr
    fcphr = 0.5*(fsp(idx) + fst(idx)); 
    fst(idx) = fcphr - 0.5*bwv(idx);
    fsp(idx) = fcphr + 0.5*bwv(idx);
    fst(idx) = fst(idx) + fc_delta;    
    fsp(idx) = fsp(idx) + fc_delta;
	C_cell(idx, 1) = {fst(idx)};
	C_cell(idx, 2) = {fsp(idx)};
end


%% ======= Set IPI and Duration ================================================

IPI = callstruct.IPI*ones(1, nphr-1);
callstruct.dur = 0.5*tsw(1) + sum(IPI) + 0.5*tsw(nphr);
Npts = round(SR*callstruct.dur);
y = zeros(1, Npts);
fund = zeros(1, Npts);
harm = zeros(1, Npts);


%% ======= Phrase Frequency and Amplitude ======================================

% Reset relateive amplitude magnitude (rAM) 
mxram = 0;
for idx = 1:nphr 
    if (C_cell{idx, 6} > mxram), mxram = C_cell{idx, 6}; end
end

% Reset phrase order (callstruct.opt.ord = 1: reversed; 0: normal)
if (callstruct.opt.ord), ord = nphr:-1:1; 
else ord = 1:nphr; end

% Overall twitter is sum of nphr phrases
% FM and AM covary in this GUI panel  
% Ref: (Eq. 19) in Dimattina and Wang. JN. 2006
for idx = 1:nphr
    % ------------------------- Basic ------------------------------------------

    ram = C_cell{ord(idx), 6}/mxram;
    tkni = tkn(ord(idx)); 
    tknam = tkni; 
    fkni = fkn(ord(idx));
    tswi = tsw(ord(idx));
    fsti = fst(ord(idx));
    fspi = fsp(ord(idx));
    t1bk = C_cell{ord(idx), 7};
    t1ak = C_cell{ord(idx), 8};
    f1bk = C_cell{ord(idx), 9};   
    f1ak = C_cell{ord(idx), 10}; 
    a1bk = C_cell{ord(idx), 11};
    a1ak = C_cell{ord(idx), 12};
    a2bk = C_cell{ord(idx), 13};
    a2ak = C_cell{ord(idx), 14};
	t1bkam = C_cell{ord(idx), 15};
    t1akam = C_cell{ord(idx), 16};  
    
	% ------------------------- Contour ----------------------------------------
	
	% Normalize f1bk and f1ak
    f1bk = (f1bk - min(f1bk))/(max(f1bk) - min(f1bk));
    f1ak = (f1ak - min(f1ak))/(max(f1ak) - min(f1ak));
    
	% Chopping contour by silencing AM 
	if (callstruct.opt.chop == 1)
        a1ak = zeros(1, length(a1ak));
        a2ak = zeros(1, length(a2ak));
    elseif (callstruct.opt.chop == 2)
        a1bk = zeros(1, length(a1bk));
        a2bk = zeros(1, length(a2bk));
    end
	
	% ------------------------- AM/FM ------------------------------------------
	
	% Calculate len_phr (length of phrase contours in points) 
	if (idx == 1), ipiterm = 0;
    else ipiterm = sum(IPI(1:idx-1)); end
	
	ind_start = floor(SR*(0.5*tsw(1) + ipiterm - 0.5*tswi));
    ind_stop = floor(SR*(0.5*tswi(1) + ipiterm + 0.5*tswi));
    
	if (ind_start < 1), ind_start = 1; end
    if (ind_stop > Npts), ind_stop = Npts; end
    
	len_phr = ind_stop - ind_start + 1;
	
    % Make AM envelopes
    if (callstruct.opt.noam)
        a1 = ones(1,len_phr);
        a2 = ones(1,len_phr);
    else
        a1 = makeam(len_phr, tknam, t1bkam, t1akam, a1bk, a1ak); 
        a2 = makeam(len_phr, tknam, t1bkam, t1akam, a2bk, a2ak); 
    end
    a1 = ram*(a1/max(abs(a1)));
    a2 = ram*(a2/max(abs(a2)));
    
    % Add amplitude onsets and offsets ramp for each phrase 
    onset = floor(SR/1000);
	offset = floor(SR/1000);
    a1(1:onset+1) = a1(onset+1)*((0:onset)/(onset));
    a1(end-offset:end) = a1(end - offset)*((offset:-1:0)/(offset));
    a2(1:onset+1) = a2(onset+1)*((0:onset)/(onset));
    a2(end-offset:end) = a2(end - offset)*((offset:-1:0)/(offset));
    
    % Make FM sweeps
    f1 = makefm(len_phr, tkni, fkni, t1bk, t1ak, f1bk, f1ak, fsti, fspi);
    f2 = callstruct.f2f1*f1;
    a2(find(f2 > (SR/2))) = 0;
	
	% ------------------------- Time Reversed Option ---------------------------
	
	% Reverse FM
	if callstruct.rev(1),
		f1 = fliplr(f1); 
		f2 = fliplr(f2); 
	end

	% Reverse AM 
	if callstruct.rev(2),
		a1 = fliplr(a1); 	
		a2 = fliplr(a2); 
	end
	
    % ------------------------- Combined ---------------------------------------
	
	% Modulate oscillators around band center frequency and integrate	 
	% Ref: (Eq. 5) in Dimattina and Wang. JN. 2006
	f1 = f1/SR;    
	f2 = f2/SR;	  
	f1 = cumsum(f1);	 
	f2 = cumsum(f2);
	
	% Define cosine oscillators
	% Ref: (Eq. 4) and (Eq. 6) in Dimattina and Wang. JN. 2006 	
	w1 = cos(2*pi*f1-pi/2);              
	w2 = cos(2*pi*f2-pi/2);
    
	% Define fundamental component 
	% Ref: (Eq. 2) in Dimattina and Wang. JN. 2006
    phr_fund = w1.*a1;
    phr_harm = w2.*a2;
	y(ind_start:ind_stop) = (phr_fund + A2A1*phr_harm)/(1 + A2A1);
	fund(ind_start:ind_stop) = phr_fund;
    harm(ind_start:ind_stop) = phr_harm;

end

% Normalize signal y 
y = y/max(abs(y)); 

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
if bw == 0, noise = 0; end
if callstruct.snr == 0, y = 0; end

% Add noise to signal
y = y + noise;
