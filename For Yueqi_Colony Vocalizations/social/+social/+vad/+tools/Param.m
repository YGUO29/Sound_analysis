 classdef Param
    properties (Constant)
% ====================================================================
%       There are two parts of parameters, one is user control parameters, the other is program build-in parameters. Generally users only need to
%       channge user control parameters.
% ====================================================================


% =========================== user control param =====================
        % ------global variables----------------
        % sampling rate
        Fs                      =   50000;  % you need to retrain the SVM Frame Classifier if you changed Fs
        % minimal call duration
        minCallDuration         =   0.03;   % sec
        % interested frequency band
        vocBand               	=   [4000, 18000];  % you need to retrain the SVM Frame Classifier if you changed vocBand
        % the length of recording to be processed at a time
        chunklen                =   60;    % sec
        % overlap between chunks
        chunkOverlap            =   0;
        % number of parallel workers
        numParWorkers           =   feature('numCores');
        parforSwitch            =   1;
        % ROC Parameter
        ROCParamParRef          =   0.8;
        ROCParamWireless        =   1.4;

        % ------frame-wise SVM classifier-----
        rebuildingVAD           =   0;  % 0: use the previous training data if exists
                                        % 1: rebuild the training data anyway
        retrainingVAD           =   0;  % 0: use the previous model if exists
                                        % 1: retrain the frame-wise SVM classifier anyway
        % Choose manually labeled sessions as training data
        %   The classifier will be saved in a file named as ['SVMModelPCA',subject,'_',num2str(version),'.mat']. 
        %   The file will be saved in the dataFolder set above
        %   The following settings can be used for 4M, 9606, 93A
        prefixTrain             =   'voc';
        subjectTrain            =   'M91C_M92C_M64A_M29A';
%         subjectTrain            =   '9606'
        sessionNumsTrain        =   {'S10','S28'};
        version                 =   1;
        
        % ------call-wise HMM classifier-------
        rebuildingHMM           =   0;  % 0: use the previous training data if exists
                                        % 1: rebuild the training data
        retrainingHMM           =   0;  % 0: use the previous model if exists
                                        % 1: retrain the call-wise HMM classifier anyway
                                        % 2: retrain the call-wise HMM classifier but use the previous model as a start point


% ============================== build-in param ==================
        % overall call-types
        CALL_TYPE               =   {{'Sd-peep'};{'Tsik'};{'P-peep'};{'Phee'};{'Trillphee'};{'Trill'};{'Tse'};{'Twitter'}};
        NOISE_TYPE              =   {{'Noise'}};
        
        % ------frame-wise SVM classifier built-in params--------
        % preprocessing configurations
        frameLenT               =   0.02;   % sec, used in training. You need to retrain the SVM Frame Classifier if changed
        frameShift              =   0.5;    % percent / 100
        detFrameLenT            =   0.02;   % sec, used in detecting, must be equal to 'frameLenT'
        detFrameShift           =   0.5;    % percent / 100, can be different with 'frameShift'
        numOfPCAFeature         =   100;    % You need to retrain the SVM Frame Classifier if changed
        % The following two parameters are used in Spectral Analysis
        % The function was written in C++, now it can only deal with a 'specWinSize' that is smaller than 1024 and is a power of two
        specShift               =   50;     % point 
    	specWinSize             =   512;    % point
        % The following four parameters are used in a Data Augmentation function: social.vad.tools.subtract_Spe()
        samplingWidth           =   1;      % You need to retrain the SVM Frame Classifier if changed
        samplingHeight          =   1;      % You need to retrain the SVM Frame Classifier if changed
        sigmoidT                =   800;    % You need to retrain the SVM Frame Classifier if changed
        sigmoidA                =   350;    % You need to retrain the SVM Frame Classifier if changed
        % SVM Cost, set a lower penalty coefficient on false-positive
        SVMCost                 =   [0, 0.5; 1, 0];  % [TN, FP; FN, TP]. You need to retrain the SVM Frame Classifier if changed
        
        % ------frame2call combination-------------
        switch2NoiseThreshold   =   3;
        switch2CallThreshold    =   1;
        expandBoundaryGapOut    =   5;
        callEnergyUB            =   20;
        callEnergyLB            =   10;  
        
        % ------call-wise HMM classifier---------
        frameLenT_HMM           =   0.005; % sec 
        frameShiftT_HMM         =   0.8; % percent / 100
        trainDataSize_HMM       =   0.8;
        iteration_HMM           =   20;
        frontTruncLen_HMM       =   50;        
     
        % ------ErrorQuantification-----------------
        timeResEQ               =   0.001; % sec
        overlapThresholdEQ      =   0.5;
        
        % ---------CNN parameters------------
        rebuildingCNN           =   0;
        retrainingCNN           =   1;
        halfBoxLenT             =   0.1;
%         boxLenT                 =   0.256; % sec 0.1 + 0.056 + 0.1
        minBoxLen               =   0.02;
        maxBoxLen               =   0.2;
%         boxShiftT               =   0.03; % sec
        batchSize               =   128;
        numOfChannel            =   3;
        maxNumSample            =   50;
        
    end
    
    properties
        soundFilePath
        selectionTablePath
        selectionTablePathOut
        detectionLogPath
        dataFolder
        HMM_GMMFolder
        
        detFrameLenP
        detFrameShiftP
        secPerFrameInd
        secBaseline
        vocBandP
        boxHeight
        boxWidth
        scoreThresholdWireless              =   [0.8,0.2,0.1];
        AHRThresholdUB                      =   32
        AHRThresholdLB                      =   28
        broadBandThreshold                  =   15
        difEnergyThresholdUB                =   5
        difEnergyThresholdLB                =   3
        parEnergyThresholdUB                =   15;
        difEnergyThresholdWireless          =   3;
        parEnergyThresholdWireless          =   2.5;   
        HMMParamFileName = 'HMMParam_only4M.mat'                           % The call-wise HMM classifier will be saved in a file named by HMMParamFileName
        callTypeOrder = [1, 2, 3, 4, 5, 6, 7, 8]                           % callTypeOrder determines which call-types in CALL_TYPE are included in this classifier
    end
    
    methods
        function self = Param(varargin)
            self.detFrameLenP           =   floor(self.detFrameLenT * self.Fs / self.specShift / self.samplingWidth);
            self.detFrameShiftP         =   floor(self.detFrameLenP * self.detFrameShift);
            self.secPerFrameInd         =   self.specShift * self.detFrameShiftP * self.samplingWidth / self.Fs;
            self.secBaseline            =   self.secPerFrameInd / self.detFrameShift * (1 - self.detFrameShift);
            self.vocBandP               =   floor(self.vocBand/self.Fs*self.specWinSize);
%             self.boxHeight              =   floor(self.specWinSize / 2);
%             self.boxWidth               =   floor(self.boxLenT * self.Fs / self.specShift);
            % ------path configurations-------------
            computer_name = getenv('computername');
            if strcmp(computer_name,'LEOXPS')
                self.soundFilePath           =   'D:\Vocalization\';
                self.selectionTablePath      =   'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\Social\+social\+vad\+selectionTable\+groundTruth';
                self.selectionTablePathOut   =   'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\Social\+social\+vad\+selectionTable\+autoDetection';
                self.detectionLogPath        =   'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\Social\+social\+vad\+selectionTable\+log';
                self.dataFolder              =   'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\Social\+social\+vad\+data';
                self.HMM_GMMFolder           =   'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\HMM-GMM';        
            else      
%                 self.soundFilePath           =   '\\datacenterchx.bme.jhu.edu\Recording_Colony_Neural\';
                self.soundFilePath           =   '\\datacenterchx.bme.jhu.edu\Recording_ChamberX\M93A\Wav_files\';
%                 self.soundFilePath           =   '\\datacenterchx.bme.jhu.edu\Recording_Colony_Vocalization\CageMerge\';
                self.selectionTablePath      =   'E:\LingyunZhao_Files\Dropbox\RemoteWork\BehaviorAnalysisPackage\Haowen_Project\social\+social\+vad\+selectionTable\+groundTruth';
                self.selectionTablePathOut   =   'E:\LingyunZhao_Files\Dropbox\RemoteWork\BehaviorAnalysisPackage\Haowen_Project\social\+social\+vad\+selectionTable\+autoDetection';
                self.detectionLogPath        =   'E:\LingyunZhao_Files\Dropbox\RemoteWork\BehaviorAnalysisPackage\Haowen_Project\social\+social\+vad\+selectionTable\+log';
                self.dataFolder              =   'E:\LingyunZhao_Files\Dropbox\RemoteWork\BehaviorAnalysisPackage\Haowen_Project\social\+social\+vad\+data';
                self.HMM_GMMFolder           =   'E:\LingyunZhao_Files\Dropbox\RemoteWork\BehaviorAnalysisPackage\Haowen_Project\HMM-GMM';
            end 
            if nargin > 0
                subject = varargin{1};
                if strcmp(subject,'M91C_M92C_M64A_M29A')
                    % Original one for vocal communication
                    self.AHRThresholdUB                     =   36;
                    self.AHRThresholdLB                     =   28;
                    self.broadBandThreshold                 =   3;   
                    self.difEnergyThresholdUB               =   5;
                    self.difEnergyThresholdLB               =   3;
                    self.parEnergyThresholdUB               =   15;
                    self.difEnergyThresholdWireless         =   3;
                    self.parEnergyThresholdWireless         =   2.5;
                    self.HMMParamFileName                   =   'HMMParam_only4M.mat';
                    self.callTypeOrder                      =   [1, 2, 3, 4, 5, 6, 7, 8];
                    
% %                     % for Mike's DFA project, for feature extraction
% %                     self.AHRThresholdUB                     =   36;
% %                     self.AHRThresholdLB                     =   28;
% %                     self.broadBandThreshold                 =   5;   
% %                     self.difEnergyThresholdUB               =   12;
% %                     self.difEnergyThresholdLB               =   7;
% %                     self.parEnergyThresholdUB               =   15;
% %                     self.difEnergyThresholdWireless         =   3;
% %                     self.parEnergyThresholdWireless         =   2.5;
% %                     self.HMMParamFileName                   =   'HMMParam_only4M.mat';
% %                     self.callTypeOrder                      =   [1, 2, 3, 4, 5, 6, 7, 8];
                    
                elseif strcmp(subject,'9606')
                    self.AHRThresholdUB         =   36;
                    self.AHRThresholdLB         =   28;
                    self.broadBandThreshold     =   28;
                    self.difEnergyThresholdUB   =   9;
                    self.difEnergyThresholdLB   =   5;
                    self.HMMParamFileName       =   'HMMParam_9606_93A.mat';
                    self.callTypeOrder          =   [1, 4, 5, 6, 8];
                elseif strcmp(subject,'M93A')
%                     self.AHRThresholdUB         =   40;
%                     self.AHRThresholdLB         =   36;
%                     self.broadBandThreshold     =   28;
%                     self.difEnergyThresholdUB   =   9;  % was 9
%                     self.difEnergyThresholdLB   =   4;  % was 5, 4 is better
%                     self.HMMParamFileName       =   'HMMParam_9606_93A.mat';
%                     self.callTypeOrder          =   [1, 4, 5, 6, 8];
                    
                    % 08/25/2017 from Haowen
                    self.AHRThresholdUB         =   30;
                    self.AHRThresholdLB         =   20;
                    self.broadBandThreshold     =   30;
                    self.difEnergyThresholdUB   =   9;
                    self.difEnergyThresholdLB   =   4;
                    self.parEnergyThresholdUB   =   30;
                    self.HMMParamFileName       =   'HMMParam_9606_93A.mat';
                    self.callTypeOrder          =   [1, 4, 5, 6, 8];
                    
                else
                    % use M93A's values for now
                    self.AHRThresholdUB         =   30;
                    self.AHRThresholdLB         =   20;
                    self.broadBandThreshold     =   30;
                    self.difEnergyThresholdUB   =   9;
                    self.difEnergyThresholdLB   =   4;
                    self.parEnergyThresholdUB   =   30;
                    self.HMMParamFileName       =   'HMMParam_9606_93A.mat';
                    self.callTypeOrder          =   [1, 4, 5, 6, 8];
                end
            end
        end
    end
    
    
end

