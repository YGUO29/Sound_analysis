function [callType, label, loglikunit, labelb ] = callTypeClassification( sig, param )
%CALLTYPECLASSIFICATION Summary of this function goes here
%   input:
%         sig: the time domain signal of a call
%         param: parameter object
%   output:
%         callType
    order = param.callTypeOrder;
    numType = length(order);
%     [spec, ~, ~]      =   social.vad.tools.spectra(   sig,...
%                                                             param.specWinSize,...
%                                                             param.specShift,...
%                                                             param.Fs,...
%                                                             0 ...
%                                                         );
%     imagesc(spec);

    labelf = 0;
    labelb = 0;
    Fs = param.Fs;
    lenOfData = length(sig);
    lenOfFrame = floor(Fs * param.frameLenT_HMM);
    lenOfStep = floor(lenOfFrame * param.frameShiftT_HMM);
    numOfFrame = floor((lenOfData - lenOfFrame + lenOfStep)/lenOfStep);
    vector = zeros(1,numOfFrame,24);
    if isempty(vector)
        label = 0;
        callType = 'empty';
        loglikunit = 0;
        labelb = 0;
        return 
    end
    h = hamming(lenOfFrame);
    w = 1 + 6*sin(pi*(1:12)./12);
    w = w/max(w);

%     bank=melbankm(24,lenOfFrame,Fs,0,0.5,'t');
%     bank=full(bank);
%     bank=bank/max(bank(:));
    bank = social.vad.tools.my_melbank();
    for k=1:12
        n=0:23;
        dctcoef(k,:)=cos((2*n+1)*k*pi/(2*24));
    end
    height = 0.98;
    m = zeros(numOfFrame,12);

%     aLine = awgn(sig,70,'measured');
    aLine = sig;
    for j = 2 : lenOfData
        aLine(j) = aLine(j) - height*aLine(j-1);
    end
    for j = 1 : numOfFrame
        data_r = aLine((j-1)*lenOfStep+1:(j-1)*lenOfStep + lenOfFrame);
        data_h = data_r.*h;
        data_fft = fft(data_h);
        data_p = abs(data_fft).^2;
        mfcc = dctcoef*log(bank*data_p(1:ceil(lenOfFrame/2)+1));
        m(j,:) = mfcc;
    end
    [yy,zz] = size(m);
    dtm=zeros(yy,zz);
    for j=3:yy-2
        dtm(j,:)=-2*m(j-2,:)-m(j-1,:)+m(j+1,:)+2*m(j+2,:);
    end
    dtm=dtm/3;
    dtmm=zeros(yy,zz);
    for j=3:yy-2
        dtmm(j,:)=-2*dtm(j-2,:)-dtm(j-1,:)+dtm(j+1,:)+2*dtm(j+2,:);
    end
    dtmm=dtmm/3;
    vector(1,:,:) = [m,dtm];
    vector = permute(vector,[3,2,1]);
    
    load(fullfile(param.dataFolder,param.HMMParamFileName));
    for j = 1 : numType    
        [loglik(j), ~] = mhmm_logprob(vector(:,:,1), prior{j}, transmat{j}, mu{j},Sigma{j}, mixmat{j});
    end    
    [~,label] = max(loglik);
    
    loglikunit = loglik ./ numOfFrame;
    
    loglikf = -inf * ones(1,numType);
    if (order(label) == 4) || (order(label) == 5)
        for j = 1 : numType
            if (order(j) == 4) || (order(j) == 5)
                [loglikf(j), ~] = mhmm_logprob(vector(:,1:min(end,param.frontTruncLen_HMM),1), prior_front{j}, transmat_front{j}, mu_front{j}, Sigma_front{j}, mixmat_front{j});
            end
        end
        [~,labelf] = max(loglikf);
        label = labelf;
    end
    callType = param.CALL_TYPE{order(label)}{1};
end

