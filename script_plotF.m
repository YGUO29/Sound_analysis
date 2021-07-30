% plot sound features (different sounds/conditions plotted together)
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

%% plot sound features when F.mat is available (load features directly)
nVariation = 5; % original, MM_coch, MM_spec, MM_temp, MM_full
Fs = cell(1,nVariation);
load('D:\SynologyDrive\=data=\F_halfcosine_marm_NatJM.mat');
Fs{1} = F; 
load('D:\SynologyDrive\=data=\F_halfcosine_marm_NatMM_Coch.mat');
Fs{2} = F; 
load('D:\SynologyDrive\=data=\F_halfcosine_marm_NatMM_Spec.mat');
Fs{3} = F; 
load('D:\SynologyDrive\=data=\F_halfcosine_marm_NatMM_Temp.mat');
Fs{4} = F; 
load('D:\SynologyDrive\=data=\F_halfcosine_marm_NatMM_Full.mat');
Fs{5} = F; 
%%
for iSound = 152
    figurex([-99         405        3421         451]); % cochleogram
    for iVariation = 1:nVariation
        subplot(4, nVariation, iVariation)
        plotF(Fs{iVariation}, 'cochleogram', iSound)
        subplot(4, nVariation, iVariation+nVariation)
        plotF(Fs{iVariation}, 'spec', iSound)
        subplot(4, nVariation, iVariation+2*nVariation)
        plotF(Fs{iVariation}, 'temp', iSound)
        subplot(4, nVariation, iVariation+3*nVariation)
        plotF(Fs{iVariation}, 'spectemp', iSound)
    end
end