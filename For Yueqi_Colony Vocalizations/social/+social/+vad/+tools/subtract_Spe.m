function [ parCallSpe, refCallSpe, oneCallSpe ] = subtract_Spe( parCallSpe, refCallSpe, parGain, refGain, param )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % gain modulation                            
    lenSpe          =   size(parCallSpe,2);
    parCallSpe      =   parCallSpe - repmat(parGain,1,lenSpe);
    refCallSpe      =   refCallSpe - repmat(refGain,1,lenSpe);

    % sampling
    if (param.samplingHeight ~= 1) || (param.samplingWidth ~= 1)

        parCallSpe      =   social.vad.tools.sampling(parCallSpe,param.samplingHeight,param.samplingWidth);
        refCallSpe      =   social.vad.tools.sampling(refCallSpe,param.samplingHeight,param.samplingWidth);
    end
    % nonlinear weighting
    parCallSpe2     =   parCallSpe;
    parCallSpe2(parCallSpe2<0) = 0;
    parCallSpe2     =   parCallSpe2.^2;
    refCallSpe2     =   refCallSpe;
    refCallSpe2(refCallSpe2<0) = 0;
    refCallSpe2     =   refCallSpe2.^2;
    oneCallSpe      =   (parCallSpe2 - refCallSpe2);
    A = param.sigmoidA;
    T = param.sigmoidT;
    oneCallSpe      =   2*A*(1./(1+exp(-oneCallSpe/T))-0.5);    
    
%     subplot(4,1,1);imagesc(parCallSpe),colorbar;
%     subplot(4,1,2);imagesc(refCallSpe),colorbar;
%     subplot(4,1,3);imagesc(oneCallSpe),colorbar;
%     subplot(4,1,4);imagesc(oneCallSpe),colorbar;

end

