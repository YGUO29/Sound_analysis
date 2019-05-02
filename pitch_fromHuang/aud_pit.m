
%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
paras = [16 16 -2 log2(saf/16000)];
cf = cochfil(1:129,paras(4)); 	% Center frequencies 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the auditory spectrogram
blog = wav2aud(x,paras)';

% Get pitch and saliency values
th = exp(mean(log(max(blog(:),1e-3)))); % noise floor
blog = log(max(blog,th)) - log(th);
[pit,sal,pitches,cs] = pitch(blog,cf(1:end-1),'pitlet_templates');
