function [ y ] = bandPassFilter4k_18k( x, Fs )
%BANDPASS4K_18K Summary of this function goes here
%   Detailed explanation goes here
f1 = 4000;
f3 = 18000;
fsl = 3000;
fsh = 20000;
rp = 0.1;
rs = 30;
wp1 = 2*pi*f1/Fs;
wp3 = 2*pi*f3/Fs;
wsl = 2*pi*fsl/Fs;
wsh = 2*pi*fsh/Fs;
wp = [wp1, wp3];
ws = [wsl, wsh];
[n,wn] = cheb1ord(ws/pi,wp/pi,rp,rs);
[bzl,azl] = cheby1(n,rp,wp/pi);
y = filter(bzl,azl,x);

end

