% Parameters for call feature calculation

win_time                =   0.01;    % in sec, fft window time
shift_time              =   0.002;   % in sec, shift step in spectrogram
Fs                      =   50000;   % in Hz, sample rate          
f_hp                    =   4000;    % in Hz, high pass cut-off frequency for spectrogram
fir_size                =   128;     % N points, size of fir filter
F0_cap                  =   10000;   % in Hz, if the min F0 of call is higher than this, divide by 2
Fthr                    =   1000;    % in Hz, frequency range used in smoothing contour
dur_max                 =   10;       % in sec, phrases longer than this will not be processed

% for denoise part
noise_pk_prop           =   0.25;    % threshold, proportion of noise peak in the entire ref signal to be identified as recording noise
precall_length          =   0.5;     % in sec, reference window length (before phrase start)
subtract_mode           =   'Image';    % subtract noise in image form (dB scale)
% subtract_mode           =   'Signal';   % subtract noise in signal space

if strcmpi(subtract_mode,'Signal')
    noise_power_quantile    =   0.8;
elseif strcmpi(subtract_mode,'Image')
    noise_power_quantile    =   0.7;
end

% For subtracting spectrogram in parabolic mic
param_sub.enable        =   0;          % turn on this function
param_sub.Fs            =   Fs;
param_sub.spec_th       =   2;
param_sub.mode          =   'file';
param_sub.task          =   'GetCallF0';
param_sub.win_time      =   win_time;
param_sub.shift_time    =   shift_time;

