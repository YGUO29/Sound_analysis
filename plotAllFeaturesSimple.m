% plot sound features
nVariation = 4; % original + envelope matched + spectrum matched + both matched
folder_sound = cell(1,nVariation);
folder_sound{1} = 'D:\=sounds=\Natural sound\Natural_JM original';
folder_sound{2} = 'D:\=sounds=\Natural sound\Natural_JM_MatchEnv';
folder_sound{3} = 'D:\=sounds=\Natural sound\Natural_JM_MatchSpec';
folder_sound{4} = 'D:\=sounds=\Natural sound\Natural_JM_MatchSpecEnv';

% temp = zeros(7, 9, 165);
opt.iSound = 1;
opt.plotON = 0;
opt.savefigON = 0;
opt.saveON = 0;
% opt.save_filename = 'D:\=code=\Sound_analysis\F_yg_marm4';
opt.windur = 0.0025;
opt.cochmode = 'ERB'; % log or linear, or ERB scale
figurex;
for iVariation = 1:nVariation
F = getFeatures(folder_sound{iVariation}, opt);
end