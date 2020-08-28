% plot sound features
nVariation = 4; % original + envelope matched + spectrum matched + both matched
folder_sound = cell(1,nVariation);
folder_sound{1} = 'D:\=sounds=\Natural sound\Natural_JM original';
folder_sound{2} = 'D:\=sounds=\Natural sound\Natural_JM_MatchEnv';
folder_sound{3} = 'D:\=sounds=\Natural sound\Natural_JM_MatchSpec';
folder_sound{4} = 'D:\=sounds=\Natural sound\Natural_JM_MatchSpecEnv';
for i = 2:165
    % temp = zeros(7, 9, 165);
    opt.iSound = i;
    opt.plotON = 1;
    opt.savefigON = 1;
    opt.saveON = 0;
    % opt.save_filename = 'D:\=code=\Sound_analysis\F_yg_marm4';
    opt.windur = 0.0025;
    opt.cochmode = 'ERB'; % log or linear, or ERB scale
    opt.nRow = nVariation;
    opt.nCol = 5; % cochleogram, spectrum, temporal modulation, spectral modulation, averaged spectrotemporal modulation

    f = figurex;
    for iVariation = 1:nVariation
        opt.iRow = iVariation;
        F = getFeaturesSimple(folder_sound{iVariation}, opt);
    end

    if opt.savefigON
        figurepath = 'D:\=data=\Sound\Spectrotemporal modulation\figure_NatSoundFeatures_Controls\';
        if ~exist(figurepath)
            mkdir(figurepath);
        end
        saveas(f,[figurepath, 'features_',num2str(opt.iSound),'.png'])
    end
    close(f)
end