function FreqPower_dB = getFreqPower(Mat_raw, cf, plotON)
% divide the frequency range into

FreqBounds  = 1000.*[0.1 0.2 0.4 0.8 1.6 3.2 6.4 12.8 max(cf)/1000];
BinInd      = discretize(cf,FreqBounds); 
FreqPower   = zeros(max(BinInd),1);

for i = 1:length(FreqPower)
%     FreqPower(i)    = mean(Mat_raw((BinInd == i),:),'all');
    temp            = mean(Mat_raw((BinInd == i),:),2);
    FreqPower(i)    = sum(temp); 
end

% Convert this mean envolope amplitude to what????
dBdynrange      = 70;
Matmax          = max(max(FreqPower));
Matmin          = Matmax/(10^(dBdynrange/20)); 
FreqPower_dB    = 20*log10( max(FreqPower, Matmin)./Matmin );
% FreqPower = FreqPower.^2;
% FreqPower = FreqPower - mean(FreqPower).*ones(size(FreqPower));
% FreqPower = log10(FreqPower);
if plotON
    semilogx(FreqBounds(1:end-1), FreqPower_dB,'linewidth',2,'Marker','*')
    xlabel('Frequency band lower boundary (Hz)','fontsize',16)
    ylabel('Mean Power','fontsize',16)
    xticks(FreqBounds)
end
end