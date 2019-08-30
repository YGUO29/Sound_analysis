function [ data ] = sessionTimeFreq(data)
%sessionLFP Analyze LFP of a single session.
%   Detailed explanation goes here

%% Setup plotting cfg file

a=load('C:\data\M28A Rack Colony\Scripts\M28A_ElectrodeLayout.mat');
cfg=[];
cfg.layout=a.lay3;

% Fix labels
data.p.raw.label = cfg.layout.label;
data.s.raw.label = cfg.layout.label;

% Identify artifact

% Define offset
% cfg             = [];
% cfg.offset      = 1000;
% data            = ft_redefinetrial(cfg,data);

%% Preproccess LFP data
cfg.channel     = [1:3 5:32];%[1:3 5:13 15:27 29:31];
cfg.trials      = 'all';
% cfg.trl=data.p.raw.trl;
cfg.reref       = 'no';
cfg.refchannel  = [1:3 5:32];
% cfg.refmethod   = 'median';
cfg.trials      = 'all';
cfg.lpfilter    = 'yes';
cfg.lpfreq      = 250; %Hz
cfg.demean      = 'yes';
cfg.baselinewindow = [-0.1 0];

data.p.Fpre=ft_preprocessing(cfg,data.p.raw);
data.s.Fpre=ft_preprocessing(cfg,data.s.raw);

%%


%% Time Frequency High Gamma
cfg2=[];
cfg2.channel        = 'all';
cfg2.trials         = 'all';
% cfg2.output         = 'pow';
cfg2.method         = 'mtmconvol';
cfg2.taper          = 'hanning';
cfg2.foi            = [75:5:150];
cfg2.t_ftimwin      = ones(length(cfg2.foi),1).*0.25;
cfg2.toi            = -0.5:0.025:1.0; 
data.p.fr = ft_freqanalysis(cfg2, data.p.Fpre);
data.s.fr = ft_freqanalysis(cfg2, data.s.Fpre);



%% Statistics
% cfg_stat=[];
% cfg_stat.channel    = 'all';
% cfg_stat.latency    = [0.05 0.15];
% cfg_stat.method     = 'analytic';
% cfg_stat.statistic  = 'indepsamplesT';
% cfg_stat.alpha      = 0.05;
% cfg_stat.tail       = 0;
% cfg_stat.design     = [zeros(1,data_productionTime.dof(1)) ones(1,data_sensationTime.dof(1))]
% cfg_stat.ivar       =1;
% data_stats   = ft_timelockstatistics(cfg_stat,data_productionTime,data_sensationTime);

%% Plotting parameters
% cfg3=[];
% cfg3.parameter = 'powspctrm';
% cfg3.layout=a.lay3;
% cfg3.layout.width(:)=0.85;
% cfg3.layout.height(:)=0.85;
% cfg3.avgovertime    = 'no';
% % cfg3.showlabels     = 'yes';
% % cfg3.showoutline    = 'yes';
% % cfg3.box            = 'off';
% cfg3.baseline       = [-.1 0];%[-.5 0];%'no'
% 
% cfg3.axes           = 'yes';
% cfg3.hlim           = [-0.1 0.3]% 'maxmin';
% cfg3.xlim = cfg3.hlim
% % cfg3.vlim           = 'maxabs';
% cfg3.zlim           = 'maxmin';%[min([data.p.fr.powspctrm(:); data.s.fr.powspctrm(:)]) max([data.p.fr.powspctrm(:) data.s.fr.powspctrm(:)])];
% cfg3.channel        = 'all';
% cfg3.showlabels = 'yes';

%%
cfg_diff=[];
cfg_diff.operation  = 'subtract';
cfg_diff.parameter  = 'powspctrm';
data.diff.fr           = ft_math(cfg_diff,data.p.fr,data.s.fr);

cfg3=[];
cfg3.channel        = 'all';
cfg3.parameter = 'powspctrm';
cfg3.layout=a.lay3;
cfg3.layout.width(:)=0.85;
cfg3.layout.height(:)=0.85;
cfg3.avgovertime    = 'no';
cfg3.showlabels     = 'yes';
cfg3.axes           = 'yes';
% cfg3.showoutline    = 'yes';
% cfg3.box            = 'off';
cfg3.baseline       = [-.1 0];%[-.5 0];%'no'
cfg3.hlim           =  [-0.1 0.3]; %'maxmin'; % 
% cfg3.xlim = cfg3.hlim
% cfg3.vlim           = 'maxabs';
cfg3.zlim           = 'maxmin';%[min([data.p.fr.powspctrm(:); data.s.fr.powspctrm(:)]) max([data.p.fr.powspctrm(:) data.s.fr.powspctrm(:)])];
cfg3.showlabels     = 'yes';
% cfg3.vlim           = 'maxabs';
cfg3.baselinetype   = 'absolute';
cfg3.avgoverfreq    = 'yes';
cfg3.avgoverchan    = 'no';

fh(1) = figure(11); 
ft_multiplotTFR(cfg3,data.p.fr);
fh(2) = figure(12);
ft_multiplotTFR(cfg3,data.s.fr);
% % fh(2) = figure(13);
% ft_multiplotTFR(cfg3,data.diff.fr);

% ft_multiplotER(cfg3,data_productionTime,data_sensationTime);

%% Plot differences
fh(3)=figure(16);
cfg3=[];
cfg3.channel        = 'all';
cfg3.parameter = 'powspctrm';
cfg3.layout=a.lay3;
cfg3.layout.width(:)=0.85;
cfg3.layout.height(:)=0.85;
cfg3.avgovertime    = 'no';
cfg3.avgoverfreq    = 'yes';
cfg3.showlabels     = 'no';
cfg3.axes           = 'yes';
% cfg3.showoutline    = 'yes';
% cfg3.box            = 'off';
cfg3.hlim           = [-0.1 0.3]% 'maxmin';
cfg3.xlim = cfg3.hlim
cfg3.zlim           = 'maxmin';%[min([data.p.fr.powspctrm(:); data.s.fr.powspctrm(:)]) max([data.p.fr.powspctrm(:) data.s.fr.powspctrm(:)])];
% cfg3.vlim           = 'maxabs';
cfg3.baseline       = [-0.1 0];
cfg3.baselinetype   = 'absolute';
ft_multiplotER(cfg3,data.p.fr,data.s.fr,data.diff.fr);

% for i=1:length(fh)
%     fh(i).Color=[1 1 1];
% end

saveas(fh(3),[data.path 'figures\' data.ID ' - High Gamma - ReRef ' cfg.reref ', BL ' cfg3.baselinetype],'png');
saveas(fh(3),[data.path 'figures\' data.ID ' - High Gamma - ReRef ' cfg.reref ', BL ' cfg3.baselinetype],'epsc');

%,data_sensationTime);
end

