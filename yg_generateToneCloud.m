% generate tone cloud according to marmosets' audiogram
function y = generateToneCloud(duration, baseFreq,Octave)

% init
fs = 100000; % sampling rate = 100k
interval = 0.08; 
nTones = Octave*24;

% ===== octave scale (log2)
exponent = linspace(0,Octave,nTones);
freqList = baseFreq.*(2.^exponent);

% ===== log scale (log10)
% a = log(freqRange(1))/log(2);
% b = log(freqRange(2))/log(2);
% freqList = logspace(a,b,nFreq);
% ===== init sound matrix
y = zeros(length(freqList),interval*fs*(nTones-1) + fs*duration);

% random order
randOrder = randperm(nTones);
t = 0:1/fs:duration;
t = t(1:end-1);
env = [linspace(0,1,0.01*fs),ones(1,(duration-0.02).*fs),linspace(1,0,0.01*fs)]; % ramp up and down 10ms
for i = 1:nTones;
    temp = sin(2*pi*freqList(randOrder(i)).*t);
    temp = temp.*env;
    y(i,interval*fs*(i-1)+1:interval*fs*(i-1)+fs*duration) = temp;
end

y = sum(y);
end