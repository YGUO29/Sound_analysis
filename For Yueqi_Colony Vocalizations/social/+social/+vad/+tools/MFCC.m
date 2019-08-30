function [ vector ] = MFCC( wave, Fs )
% return the MFCC of a wave, sampling at Fs Hz
% toolbox "voicebox" is needed
% created by Haowen Xu
    if iscell(wave)
        wave = cell2mat(wave')';
    end
    [N,lenOfSubframe] = size(wave);
    K = 12;
    height = 0.98;
    h = hamming(lenOfSubframe);
    bank = melbankm(24,lenOfSubframe,Fs,0,0.5,'t');
    for k=1:K          
        n=0:23;
        dctcoef(k,:)=cos((2*n+1)*k*pi/(2*24));
    end
    for i = 1 : N
        data = wave(i,:)';
        
        %highpass
        for j = 2 : lenOfSubframe
            data(j) = data(j) - height *data(j-1);
        end
        data(1) = data(2);
        
        data_h = data.*h;
        data_fft = fft(data_h);
        data_p = abs(data_fft).^2;
        data_rp = data_p(1:floor(lenOfSubframe/2)+1);
%         subplot(3,1,1);
%         plot(data);
%         subplot(3,1,2);
%         plot(data_p);
%         subplot(3,1,3);
%         plot(data_rp);
%         data_rp = data_rp.*(1:length(data_rp))'/length(data_rp);
        vector(i,:) = dctcoef*log(bank*data_rp);
    end
        
end

