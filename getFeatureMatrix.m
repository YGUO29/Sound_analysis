function F = getFeatureMatrix(F, C)
% F.nStim         = size(F.coch_env,2);
% F.nSpec         = size(F.spec_mod,1);
% F.nTemp         = size(F.temp_mod,1);
% F.nSpectemp     = size(F.spectemp_mod,1)*size(F.spectemp_mod,2); 
% % F.nSpectemp_full = size(F.spectemp_mod_full,1)*size(F.spectemp_mod_full,2); 
% 
% F.FreqBounds  = 1000.*[0.1 0.2 0.4 0.8 1.6 3.2 6.4 12.8 max(F.cf_log)/1000];
% BinInd      = discretize(F.cf_log,F.FreqBounds); 
% F.nFreq     = max(BinInd);
% 
% F.F_mat         = zeros( F.nFreq + F.nSpectemp, F.nStim);
% F.table        = table;
% % F_mat rows 1~9: frequency powers (8)
% % F.FreqBounds  = 1000.*[0 0.1 0.2 0.4 0.8 1.6 3.2 6.4 12.8 max(F.cf_log)/1000];
% for i = 1:F.nFreq
%     F.F_mat(i,:) = mean(F.coch_env(BinInd == i,:)); % F.coch_env size: 244 * #stim
% end
% F.table.freq = F.F_mat(1:F.nFreq, :)';
% 
% % F_mar rows 9~17 : temporal rates (9)
% F.F_mat(i+1:i+F.nTemp, :) = squeeze(mean(F.temp_mod, 2));
% F.table.temp = F.F_mat(i+1:i+F.nTemp, :)';
% i = i+F.nTemp;
% 
% % F_mar rows 18~24: spectral rates (7)
% F.F_mat(i+1:i+F.nSpec, :) = squeeze(mean(F.spec_mod, 2));
% F.table.spec = F.F_mat(i+1:i+F.nSpec, :)';
% i = i+F.nSpec;
% 
% % F_mat rows 25~25+7*9 = 25~87: combined spectrotemporal modulation power
% F.F_mat(i+1:i+F.nSpectemp,:) = reshape(F.spectemp_mod, F.nSpectemp, F.nStim);
% F.table.spectemp_mean = F.F_mat(i+1:i+F.nSpectemp,:)';
% i = i+F.nSpectemp;
% 
% % F_mat rows 88~88+7*9 = 88~150: combined spectrotemporal modulation power
% F.F_mat(i+1:i+F.nSpectemp,:) = reshape(F.spectemp_mod_weighted, F.nSpectemp, F.nStim);
% F.table.spectemp_weighted = F.F_mat(i+1:i+F.nSpectemp,:)';
% 
% if exist('C')
%     F.table.cat_number = C.category_assignments;
% end
% % F_mat rows 74~end: full spectrotemporal modulation power (including
% % negative and positive temporal rates)
% % F.F_mat(i+1:i+F.nSpectemp_full,:) = reshape(F.spectemp_mod_full, F.nSpectemp_full, F.nStim);
%% get other parameters and organize features into a table
%%
F.nStim         = size(F.coch_env, 2);
F.nSpec         = size(F.spec_mod, 1);
F.nTemp         = size(F.temp_mod, 1);
F.nSpectemp     = size(F.spectemp_mod,1)*size(F.spectemp_mod,2); 
% F.nSpectemp_full = size(F.spectemp_mod_full,1)*size(F.spectemp_mod_full,2); 

F.FreqBounds  = 1000.*[0.1.*2.^(0:0.5:7) max(F.cf_log)/1000];
% F.FreqBounds  = 1000.*[0.1 0.2 0.4 0.8 1.6 3.2 6.4 max(F.cf_log)/1000];

BinInd      = discretize(F.cf_log,F.FreqBounds); 
F.nFreq     = max(BinInd);

F.F_mat     = zeros(F.nFreq + F.nTemp + F.nSpec + 2*F.nSpectemp, F.nStim);
F.table     = table;

% F_mat rows 1~9: frequency powers (8)
for i = 1:F.nFreq
    F.F_mat(i,:) = mean(F.coch_env(BinInd == i,:)); % F.coch_env size: 244 * #stim
end
F.table.freq = F.F_mat(1:F.nFreq, :)';

% F_mar rows 9~17 : temporal rates (9)
F.F_mat(i+1:i+F.nTemp, :) = squeeze(mean(F.temp_mod, 2));
F.table.temp = F.F_mat(i+1:i+F.nTemp, :)';
i = i+F.nTemp;

% F_mar rows 18~24: spectral rates (7)
F.F_mat(i+1:i+F.nSpec, :) = squeeze(mean(F.spec_mod, 2));
F.table.spec = F.F_mat(i+1:i+F.nSpec, :)';
i = i+F.nSpec;

% F_mat rows 25~25+7*9 = 25~87: combined spectrotemporal modulation power
F.F_mat(i+1:i+F.nSpectemp,:) = reshape(F.spectemp_mod, F.nSpectemp, F.nStim);
F.table.spectemp_mean = F.F_mat(i+1:i+F.nSpectemp,:)';
i = i+F.nSpectemp;

% F_mat rows 88~88+7*9 = 88~150: combined spectrotemporal modulation power
F.F_mat(i+1:i+F.nSpectemp,:) = reshape(F.spectemp_mod_weighted, F.nSpectemp, F.nStim);
F.table.spectemp_weighted = F.F_mat(i+1:i+F.nSpectemp,:)';

if exist('C')
    F.table.cat_number = C.category_assignments;
    F.C = C;
end
% F_mat rows 74~end: full spectrotemporal modulation power (including
% negative and positive temporal rates)
% F.F_mat(i+1:i+F.nSpectemp_full,:) = reshape(F.spectemp_mod_full, F.nSpectemp_full, F.nStim);

end