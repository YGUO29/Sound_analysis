classdef SampleProvider
    % SAMPLEPROVIDER is a tool to collects frame samples that are manually labeled as Noises or
    % Calls  from raw recording data.
    
    % Writen by Haowen Xu, 8/2016
    properties
        param
        fileName
        tableName
        nTableName
        NOISE_TYPE
        CALL_TYPE
        parChannel
        refChannel
        boxChannel
    end
    
    
    methods
        function self = SampleProvider(fileName, tableName, nTableName, parChannel, refChannel, boxChannel, param)
            self.fileName   =   fileName;
            self.tableName  =   tableName;
            self.nTableName =   nTableName;
            self.param      =   param;
            self.CALL_TYPE  =   param.CALL_TYPE;
            self.NOISE_TYPE =   param.NOISE_TYPE;
            self.parChannel =   parChannel;
            self.refChannel =   refChannel;
            self.boxChannel =   boxChannel;
        end
        
        function callType = callTypeRefine(self, callType)
            if (length(callType)>4)&&(strcmpi(callType(end-4:end),'tring'))
                callType = callType(1:end-7);
            end
            if strcmpi(callType, 'T-peep')
                callType = 'Trill';
            end
            callType = [upper(callType(1)), callType(2:end)];
        end
            
        function [boxes, counter] = extractCNNSpecBox(self)
            callIndex = 0; % init
            startCall = 0; % init
            stopCall =  0;  % init
            tableFileHandle =   fopen(self.tableName,'rt');
            signalType      =   self.CALL_TYPE;
            boxes           =   struct('beginTime', [],...
                                       'endTime', [],...
                                       'parChannel', [],...
                                       'refChannel', [],...
                                       'label', [],...
                                       'par', [],...
                                       'ref', []);
            itfh            =   0;
            minBoxLen       =   self.param.minBoxLen;
            maxBoxLen       =   self.param.maxBoxLen;
            halfBoxLenT     =   self.param.halfBoxLenT;
            Fs              =   self.param.Fs;
            counter         =   zeros(10,1);
            selTab          =   fgetl(tableFileHandle);  % jump over the first line
            boxCount        =   0;
            session         =   social.session.StandardSession(self.fileName);
            while ~feof(tableFileHandle)
                itfh            =   itfh + 1;
                selTab          =   fgetl(tableFileHandle);
                str             =   deblank(selTab);
                split           =   regexp(str, '\t', 'split');
                if length(split) >= 9
                    callType    =   split{9};
                else
                    callType    =   'None';
                end
                callType = self.callTypeRefine(callType);
                callIndex_previous = callIndex;
                callIndex       =   find(strcmpi([signalType{:}], callType));
                if isempty(callIndex)  % if the callType doesn't exist in signalType
                    callIndex = 0;
                    continue  % jump over this call
                end
                if str2double(split{3}) == self.boxChannel
                    startNoise          =   stopCall;
                    stopNoise           =   str2double(split{4});
                    startCall_old       =   startCall;
                    stopCall_old        =   stopCall;
                    startCall           =   stopNoise;
                    stopCall            =   str2double(split{5});
                    % combine twitter phases
                    if (callIndex_previous == callIndex) && (callIndex == 8) && (startCall - stopCall_old < 0.5)...
                            && (startCall - stopCall_old >0)
                        startCall = startCall_old;
                        counter(callIndex) = counter(callIndex - 1);
                    end  
                    
                    % get noise box
                    k                   =   rand(1) * 0.7 + 0.1;
                    startBox            =   startNoise + k * (stopNoise - startNoise);
                    stopBox             =   min(startBox + rand(1) * (maxBoxLen - minBoxLen) + minBoxLen, stopNoise);
                    startBox            =   max(startBox - halfBoxLenT, 0);
                    stopBox             =   stopBox + halfBoxLenT;
                    if startBox >= stopBox
                        continue
                    end
                    
                    if (stopBox < startCall) && (counter(10) <= self.param.maxNumSample)
                        sigPar          =   session.Signals(self.parChannel).get_signal([startBox, stopBox]);
                        sigRef          =   session.Signals(self.refChannel).get_signal([startBox, stopBox]);
                        [parCallSpe,~,~]=   social.vad.tools.spectra(sigPar{1}, self.param.specWinSize, self.param.specShift, Fs, 0);
                        [refCallSpe,~,~]=   social.vad.tools.spectra(sigRef{1}, self.param.specWinSize, self.param.specShift, Fs, 0);  
                        boxCount        =   boxCount + 1;
                        counter(10)     =   counter(10) + 1;
                        box.beginTime   =   startBox;
                        box.endTime     =   stopBox;
                        box.parChannel  =   self.parChannel;
                        box.refChannel  =   self.refChannel;
                        box.label       =   0;
                        box.par         =   parCallSpe;
                        box.ref         =   refCallSpe;
                        boxes(boxCount) =   box;
                    end
                    
                    % get call box
                    startBox            =   max(startCall - halfBoxLenT, 0);
                    stopBox             =   stopCall + halfBoxLenT;
                    if counter(callIndex) <= self.param.maxNumSample
%                         display(startBox)
%                         display(stopBox)
%                         display(startCall)
%                         display(stopCall)
                        sigPar          =   session.Signals(self.parChannel).get_signal([startBox, stopBox]);
                        sigRef          =   session.Signals(self.refChannel).get_signal([startBox, stopBox]);
                        [parCallSpe,~,~]=   social.vad.tools.spectra(sigPar{1}, self.param.specWinSize, self.param.specShift, Fs, 0);
                        [refCallSpe,~,~]=   social.vad.tools.spectra(sigRef{1}, self.param.specWinSize, self.param.specShift, Fs, 0);
                        boxCount        =   boxCount + 1;
                        counter(callIndex)  =   counter(callIndex) + 1;
                        box.beginTime	=   startBox;
                        box.endTime     =   stopBox;
                        box.parChannel	=   self.parChannel;
                        box.refChannel	=   self.refChannel;
                        box.label       =   callIndex;
                        box.par         =   parCallSpe;
                        box.ref         =   refCallSpe;
                        boxes(boxCount) =   box;
                    end
                end 
            end
            fclose(tableFileHandle);
        end
        
        function call = extractSegs(self, targetType, varargin)
        % input:
        %   required
        %       targetType: 'call' and 'noise' are optional
        %   optional name-value pairs
        %       parData: If the value is 1, the output structure will
        %       include the parabolic channel data of the call. If the
        %       value is 0(default), no parabolic channel data.
        %       refData: idem
        %       AHR: If the value is 1, output the AHR value of the call
            if strcmp(targetType, 'call')
                signalType = self.CALL_TYPE;
                tableFileHandle = fopen(self.tableName,'rt');
            elseif strcmp(targetType, 'noise')
                signalType = self.NOISE_TYPE;
                tableFileHandle = fopen(self.nTableName,'rt');
            else
                print('wrong targetType');
                return;
            end
            p = inputParser;
            p.addParameter('parData', 0);
            p.addParameter('refData', 0);
            p.addParameter('AHR', 0);
            p.addParameter('exception', 0);
            p.addParameter('energyDiff', 0);
            p.addParameter('energyPar', 0);
            p.addParameter('energyDiffWireless', 0);
            p.addParameter('energyParWireless', 0);
            p.parse(varargin{:});
            parDataMark = p.Results.parData;
            refDataMark = p.Results.refData;
            AHRMark = p.Results.AHR;
            exceptionMark = p.Results.exception;
            energyDiffMark = p.Results.energyDiff;
            energyParMark = p.Results.energyPar;
            energyDiffWirelessMark = p.Results.energyDiffWireless;
            energyParWirelessMark = p.Results.energyParWireless;
            
            call = cell(1,length(signalType)+1);
            itfh = 0;
            while ~feof(tableFileHandle)
                itfh = itfh + 1;
                selTab{itfh} = fgetl(tableFileHandle);                
            end
            fclose(tableFileHandle);
            
            splitTitle = regexp(deblank(selTab{1}), '\t', 'split');
            % check if AHR value exists in this selectionTable
            if AHRMark == 1
                AHR_exist = 0;
                for i_split = 1 : length(splitTitle)
                    if strcmp(splitTitle{i_split}, 'AHR')
                        AHR_exist = 1;
                        AHR_index = i_split;
                    end
                end
                if AHR_exist == 0
                    error('AHR wasn''t found in selectionTable');
                end     
            end
            
            % check if exception value exists in this selectionTable
            if exceptionMark == 1
                exception_exist = 0;
                for i_split = 1 : length(splitTitle)
                    if strcmp(splitTitle{i_split}, 'Exception')
                        exception_exist = 1;
                        exception_index = i_split;
                    end
                end
                if exception_exist == 0
                    error('Exception wasn''t found in selectionTable');
                end
            end
            
            % check if energy diff exists in the selectionTable
            if energyDiffMark == 1
                energyDiff_exist = 0;
                for i_split = 1 : length(splitTitle)
                    if strcmp(splitTitle{i_split}, 'Energy Diff')
                        energyDiff_exist = 1;
                        energyDiff_index = i_split;
                    end
                end
                if energyDiff_exist == 0
                    error('Energy Diff wasn''t found in selectionTable');
                end
            end
            
            % check if energy par exists in the selectionTable
            if energyParMark == 1
                energyPar_exist = 0;
                for i_split = 1 : length(splitTitle)
                    if strcmp(splitTitle{i_split}, 'Energy Par')
                        energyPar_exist = 1;
                        energyPar_index = i_split;
                    end
                end
                if energyPar_exist == 0
                    error('Energy Par wasn''t found in selectionTable');
                end
            end
            
            % check if energy diff wireless exists in the selectionTable
            if energyDiffWirelessMark == 1
                energyDiffWireless_exist = 0;
                for i_split = 1 : length(splitTitle)
                    if strcmp(splitTitle{i_split}, 'Energy Diff (wl)')
                        energyDiffWireless_exist = 1;
                        energyDiffWireless_index = i_split;
                    end
                end
                if energyDiffWireless_exist == 0
                    error('Energy Diff (wl) wasn''t found in selectionTable');
                end
            end
            
            % check if energy par wireless exists in the selectionTable
            if energyParWirelessMark == 1
                energyParWireless_exist = 0;
                for i_split = 1 : length(splitTitle)
                    if strcmp(splitTitle{i_split}, 'Energy Par (wl)')
                        energyParWireless_exist = 1;
                        energyParWireless_index = i_split;
                    end
                end
                if energyParWireless_exist == 0
                    error('Energy Par (wl) wasn''t found in selectionTable');
                end
            end            
            
            if (parDataMark ~= 0) || (refDataMark ~= 0)
                session = social.session.StandardSession(self.fileName);
            end
            cnum = zeros(length(signalType) + 1,1); %count the number of calls of each call type 
            for i = 1 : itfh-1
                str = selTab{i+1};
                str = deblank(str);       
                split = regexp(str, '\t', 'split');
                if (length(split)<9) 
                    callType = 'otherTypes';
                else
                    callType = split{9};
                end
                if (length(callType)>4)&&(strcmpi(callType(end-4:end),'tring'))
                    callType = callType(1:end-7);
                end
                callType = self.callTypeRefine(callType);
                callIndex = find(strcmpi([signalType{:}],callType));
                if str2double(split{3}) == self.boxChannel
                    if isempty(callIndex) 
                        callIndex = length(signalType) + 1;
                    end
                    cnum(callIndex) = cnum(callIndex) + 1;
                    beginTime = str2double(split{4});
                    endTime = str2double(split{5});
                    call{callIndex}(cnum(callIndex)).beginTime = beginTime;
                    call{callIndex}(cnum(callIndex)).endTime = endTime;
                    call{callIndex}(cnum(callIndex)).parChannel = self.parChannel;
                    call{callIndex}(cnum(callIndex)).refChannel = self.refChannel;
                    call{callIndex}(cnum(callIndex)).sessionNum = self.tableName(end-7:end-4);
                    if parDataMark == 1
                        call{callIndex}(cnum(callIndex)).parData = session.Signals(self.parChannel).get_signal([beginTime, endTime]);
                    end
                    if refDataMark == 1
                        call{callIndex}(cnum(callIndex)).refData = session.Signals(self.refChannel).get_signal([beginTime, endTime]);
                    end
                    if AHRMark == 1
                        call{callIndex}(cnum(callIndex)).AHR = str2double(split{AHR_index});
                    end
                    if exceptionMark == 1
                        call{callIndex}(cnum(callIndex)).exception = str2double(split{exception_index});
                    end
                    if energyDiffMark == 1
                        call{callIndex}(cnum(callIndex)).energyDiff = str2double(split{energyDiff_index});
                    end
                    if energyParMark == 1
                        call{callIndex}(cnum(callIndex)).energyPar = str2double(split{energyPar_index});
                    end
                    if energyDiffWirelessMark == 1
                        call{callIndex}(cnum(callIndex)).energyDiffWireless = str2double(split{energyDiffWireless_index});
                    end
                    if energyParWirelessMark == 1
                        call{callIndex}(cnum(callIndex)).energyParWireless = str2double(split{energyParWireless_index});
                    end
                end
            end    
        end
        
        function frame = seg2fram(self, seg)
            % this method is to split calls or noise segments into frames
            % Create a session object from the header file.
            session=social.session.StandardSession(self.fileName);
            
            numOfSignal = length(session.Signals);
            for iSignal = 1 : numOfSignal
                session.Signals(iSignal).calculate_gain();
                gain(:,iSignal) = session.Signals(iSignal).gain_spec;
            end
            
            frame = {};
            numOfSegType = length(seg);
            for iType = 1 : numOfSegType
                numOfSeg = length(seg{iType});
                frame{iType} = {};
                for iSeg = 1 : numOfSeg
                    parChannel  =   seg{iType}(iSeg).parChannel;
                    refChannel  =   seg{iType}(iSeg).refChannel;
                    beginTime   =   seg{iType}(iSeg).beginTime;
                    endTime     =   seg{iType}(iSeg).endTime;
                    if endTime>beginTime
                        % extract
                        parCall         =   session.Signals(parChannel).get_signal([beginTime, endTime]);
                        refCall         =   session.Signals(refChannel).get_signal([beginTime, endTime]);

                        % calculate spectrum
                        Fs              =   session.Signals(parChannel).SampleRate;
                        
                        % -----matlab spectra------
%                         tic
%                         [parCallSpe,~,~]=   social.util.spectra(parCall{1}, self.param.specWinSize, self.param.specShift, Fs, 'log', 'gausswin', 0);
%                         [refCallSpe,~,~]=   social.util.spectra(refCall{1}, self.param.specWinSize, self.param.specShift, Fs, 'log', 'gausswin', 0);
%                         toc
                        % -------c++ spectra-------
                        [parCallSpe,~,~]=   social.vad.tools.spectra(parCall{1}, self.param.specWinSize, self.param.specShift, Fs, 0);
                        [refCallSpe,~,~]=   social.vad.tools.spectra(refCall{1}, self.param.specWinSize, self.param.specShift, Fs, 0);
                        
                        [~, ~, oneCallSpe]...
                                        =   social.vad.tools.subtract_Spe(parCallSpe, refCallSpe, gain(:,parChannel), gain(:,refChannel), self.param);
                        frame{iType}    =   [frame{iType}; social.vad.tools.seg2frame(oneCallSpe, self.param.detFrameLenP, self.param.detFrameShiftP)];
                    end
                end
            end
            
        end
        

    end
end
