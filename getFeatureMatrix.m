function F = getFeatureMatrix(F)
F.nStim         = size(F.coch_env,2);
F.nFreq         = 9;
F.nSpectemp     = size(F.spectemp_mod,1)*size(F.spectemp_mod,2); 
F.nSpectemp_full = size(F.spectemp_mod_full,1)*size(F.spectemp_mod_full,2); 
F.F_mat         = zeros( F.nFreq + F.nSpectemp, F.nStim);

% F_mat rows 1~9: frequency powers
F.FreqBounds  = 1000.*[0 0.1 0.2 0.4 0.8 1.6 3.2 6.4 12.8 max(F.cf)/1000];
BinInd      = discretize(F.cf,F.FreqBounds); 
for i = 1:max(BinInd)
    F.F_mat(i,:) = mean(F.coch_env(BinInd == i,:)); % F.coch_env size: 244 * #stim
end

% F_mat rows 10~10+7*9 = 10~73: combined spectrotemporal modulation power
F.F_mat(i+1:i+F.nSpectemp,:) = reshape(F.spectemp_mod, F.nSpectemp, F.nStim);
i = i+F.nSpectemp;

% F_mat rows 74~end: full spectrotemporal modulation power (including
% negative and positive temporal rates)
F.F_mat(i+1:i+F.nSpectemp_full,:) = reshape(F.spectemp_mod_full, F.nSpectemp_full, F.nStim);

end