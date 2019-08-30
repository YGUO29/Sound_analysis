[Naming Rules]
A session's name consists of three part: prefix, subject and session number, connected by underscore;
(for example, prefix = 'voc', subject = 'M91C_M92C_M64A_M29A', session number = 'S11', sessionName = 'voc_M91C_M92C_M64A_M29A_S11')
hdr file: sessionName + '.hdr'
wav file: sessionName + '.wav'
selection table file: 'SelectionTable_' + sessionName + '.txt'


[selection table]
Explanation of 'exception' column in selection table
	0: no exception
	1: strong signal in Par-Ref pair, weak signal in wireless mics
	2: weak signal in Par-Ref pari, strong signal in wireless mics

[install]
step1: Select training samples for SVM Frame Classifier
Copy '9606_BehaviorChannels.xlsx' to the folder where you store 9606 'wav' files and 'hdr' files. Copy 'M91C_M92C_M64A_M29A_BehaviorChannels.xlsx' to the folder where you store four-monkey 'wav' file and 'hdr' file. Sessions listed in these two files are manually labeled and will be used as training samples.

step2: Get codes
Copy 'Social' folder and 'HMM_GMM' folder to your computer.

step3: path configuration
Browse your Matlab Current Folder to the 'Social' folder.
open '+social\+vad\+tools\Param.m' and change the following parameters to your setting
"soundFilePath": 
	This path is where you store 'wav' files and 'hdr' files, such as 'D:\Vocalization\'. The 'Vocalization' folder should include two subfolders, 'M91C_M92C_M64A_M29A' and '9606'. Files are stored in these two subfolders.

"selectionTablePath":
	Replace the 'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\' part with the absolute path of your 'Social' folder. Do the same operation to 'selsctionTablePathOut', 'detectionLogPath' and 'dataFolder'.

"HMM_GMMFolder":
	Replace the 'C:\Users\xh071_000\OneDrive\study\summer research\matlabworkspace\' part with the absolute path of your 'HMM_GMM' folder.

[train]
Detection part: SVM Frame Classifier
If you use new recording setting, for example you change the sampling rate, you need to retrain the SVM Frame Classifier. 
Usually you do not need to change the manually labeled sessions 'voc_M91C_M92C_M64A_M29A_S10' and 'voc_m91C_M92C_M64A_M29A_S28'. They gives pretty good result for different recording conditions including 4M, 9606 and 93A. 
You can change the sampling rate 'Fs', interested frequency band 'vocBand', et. al. in '~\+social\vad\tools\Param.m'. If you do not want to overwrite the old classifier, you need to give the parameter 'Param.version' a new number. Then do 'run('social.vad.Training_Script.m')', the new classifier will be saved in the dataFolder and named as ['SVMModelPCA',subject,'_',num2str(version),'.mat']

Classification part: HMM Call-type Classifier
If you want to retrain the HMM Call-type Classifier, set new parameters in 'Param.m' and do 'run('social.vad.Training_Script_classify.m')'. Before running 'social.vad.Training_Script_classify.m', you have to set the variable 'subject'.

[run] Build sessions and run.
You can use 'Example_Session_Script.m' as an example. First you need to give the name of sessions by set 'prefix', 'subject', and 'sessionNum'. Then build behaviors with the following instructions

%   A session can have several behaviors, each behavior can be independently used to find calls. There are two types of behaviors. One is
%   'ColonyParRefChannel', the other is 'ColonyWirelessChannel'.  
%  
%   'ColonyParRefChannel' should be used when there is one parabolic mic, one reference mic, and zero to several other reference mics.
%       invocation: behavior = social.behavior.('ColonyParRefChannel')(session,sessionName,sigPar,sigRef,sigOth,false,param);
%           session: the object of session, StandardSession
%           sessionNum: the session name, String
%           sigPar: the object of parabolic mic signal, StandardVocalSignal Object
%           sigRef: the object of reference mic signal, StandardVocalSignal Object
%           sigOth: a cell of objects, each one is a other-reference mic signal, StandardVocalSignal Object
%           false: logical variable
%           param: parameter object, Param Object
%
%   'ColonyWirelessChannel' should be used when there is one parabolic mic, one reference mic, and two to several wireless mics.
%       invocation: behavior = social.behavior.('ColonyWirelessChannel')(session,sessionName,sigPar,sigRef,sigWireless,false,param);
%           session: the object of session, StandardSession
%           sessionNum: the session name, String
%           sigPar: the object of parabolic mic signal, StandardVocalSignal Object
%           sigRef: the object of reference mic signal, StandardVocalSignal Object
%           sigWireless: a cell of objects, each one is a wireless mic signal, StandardVocalSignal Object
%           false: logical variable
%           param: parameter object, Param Object

'Example_Session_Script.m' has already given some examples of how to build behaviors.

[step4]
run 'Example_Session_Script.m'£¬the output 'mat' file will be saved in 'dataFolder' and the selectionTable will be saved in 'selectionTablePathOut'.

[parameter explanation]
The program was divided into four phrases: frame classification, frame2call combination, call-wise filtering, call-wise classification. Sadly there are plenty of hyper-parameters in each of these phrases.

frame classification:
    frameLenT: length of frame (unit: second)
    frameShift: 1-frameShift equals to the overlap between frames
    numOfPCAFeature: the dimension of feature vector after PCA dimension reduction
    samplingWidth, samplingHeight: pooling size in data augmentation process. In general you do not need to change
    sigmoidT, sigmoidA: sigmoid function in data augmentation process. In general you do not need to change

frame2call combination:
    switch2NoiseThreshold: change the state from call to noise after this number of successive noise frames
    switch2CallThreshold: change the state from noise to call after this number of successive call frames
    expandBoundaryGapOut, callEnergyUB, callEnergyLB: these three params are used in boundary expanding process. Details of their means are describe in "Explanation_Boundary_Expanding.png"

call-wise filtering: (the most complicated and ugly part)
    use arbitrary constructed score function to evaluate calls. Calls whose score function is smaller than 1 will be screened out. Details about the score function and variables and parameters are describe in "Call_Filtering.png"

call-wise classification:
    frameLenT_HMM: length of frame used in HMM (unit second)
    frameShiftT_HMM: the shift of frame in each step (unit: %)
    iteration_HMM: the max number of epoches in training of HMM
    frontTruncLen_HMM: the first frontTruncLen_HMM of frames are used to discrimate between "phee" and "trillphee"

(Too much hyper-parameters in this model restrict its generalization capability)

[update 05-18-2017]
Implement parallel for loop mode. 
You can choose parfor mode by setting the parameter 'parforSwitch' in 'Param.m' to 1, otherwise the program will run in single thread mode.
You can choose the number of parallel workers by setting the 'numParWorkers' values in 'Param.m'.

