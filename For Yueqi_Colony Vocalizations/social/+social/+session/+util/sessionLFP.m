function [ data ] = sessionLFP(data,varargin)
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
cfg.channel     = [1:3 5:32];
cfg.trials      = 'all';
% cfg.trl=data_production.trl;
cfg.reref       = 'no';
cfg.refchannel  = [1:3 5:32];
% cfg.refmethod   = 'median';
cfg.trials      = 'all';
cfg.lpfilter    = 'yes';
cfg.lpfreq      = 20; %Hz
cfg.hpfilter    = 'yes';
cfg.hpfreq      = 1.0; %Hz

cfg.demean      = 'yes';
cfg.baselinewindow = [-0.1 0.0];

data.p.prelfp=ft_preprocessing(cfg,data.p.raw);
data.s.prelfp=ft_preprocessing(cfg,data.s.raw);

%% Time lock (ERP average) analysis
cfg2=[];
cfg2.channel      = 'all';
cfg2.trials       = 'all';
% cfg2.removemean   = 'yes';
cfg2.keeptrials   = 'yes';
cfg2.vartrllength = 0;
data.p.TLlfp = ft_timelockanalysis(cfg2,data.p.prelfp);
data.s.TLlfp = ft_timelockanalysis(cfg2,data.s.prelfp);

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
cfg3=[];
cfg3.parameter = 'avg';
cfg3.layout=a.lay3;
cfg3.layout.width(:)=0.7;
cfg3.layout.height(:)=0.7;
cfg3.showlabels     = 'yes';
cfg3.showoutline    = 'yes';
cfg3.box            = 'off';
cfg3.axes           = 'yes';
cfg3.hlim           = [-0.1 0.3];
cfg3.vlim           = 'maxmin';
cfg3.channel        = 'all';
cfg3.showlabels     = 'yes';

cfg3.baseline = [-0.1 0];%'no'%[-0.1 0];%
cfg3.baselinetype = 'absolute';%'none';

%%
% figure(1);
% ft_multiplotER(cfg3,data.p.TLlfp);
% figure(2);
% ft_multiplotER(cfg3,data.s.TLlfp);

%% Plot differences
figure(3);
cfg_diff=[];
cfg_diff.operation  = 'subtract';
cfg_diff.parameter  = 'avg';
data.diff.TLlfp           = ft_math(cfg_diff,data.p.TLlfp,data.s.TLlfp);
ft_multiplotER(cfg3,data.p.TLlfp,data.s.TLlfp,data.diff.TLlfp);
title([data.ID ' - LFP - ReRef ' cfg.reref ', BL ' cfg3.baselinetype ' ' cfg_diff.operation],'Interpreter','none')
saveas(3,[data.path 'figures\' data.ID ' - LFP - ReRef ' cfg.reref ', BL ' cfg3.baselinetype],'png');
saveas(3,[data.path 'figures\' data.ID ' - LFP - ReRef ' cfg.reref ', BL ' cfg3.baselinetype],'epsc');
%,data_sensationTime);
end

