classdef MyCall < handle
    %MY_CALL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        session = nan;
        eventStartTime = 0;
        eventStopTime = 0;
        eventSyncTime = 0;
        channel = 0;
        sig = [];
        eventClass = '';
        Fs = 50000;
    end
    
    methods
        function self = MyCall(varargin)
            p = inputParser;
            p.addParameter('session',[]);
            p.addParameter('startTime',0);
            p.addParameter('stopTime',0);
            p.addParameter('syncTime',0);
            p.addParameter('channel',0);
            p.addParameter('callType','');
            p.addParameter('sig',[]);
            p.parse(varargin{:});
            self.session            =   p.Results.session;
            self.eventStartTime     =   p.Results.startTime;
            self.eventStopTime      =   p.Results.stopTime;
            self.eventSyncTime      =   p.Results.syncTime;
            self.channel            =   p.Results.channel;
            self.eventClass         =   p.Results.callType;
            self.sig                =   p.Results.sig;
%             self.Fs                 =   self.session.Signals(self.channel).SampleRate;
            
        end
        
        function sig = get_signal(self,varargin)
            if nargin > 1
                times = varargin{1};
            else
                times = [self.eventStartTime, self.eventStopTime];
            end
            if ~isempty(self.sig)
                startIndex  =   floor((times(1) - self.eventStartTime) * self.Fs) + 1;
                stopIndex   =   floor((times(2) - self.eventStartTime) * self.Fs) + 1;
                sig         =   self.sig(max(1,startIndex) : min(end,stopIndex));
            else
                sig         =   self.session.Signals(self.channel).get_signal(times);
                sig         =   sig{1};
                self.sig    =   sig;
            end
        end
        
        function spec = get_spec(self)
            times           =   [self.eventStartTime, self.eventStopTime];
            if isempty(self.sig)
                sig         =   self.session.Signals(self.channel).get_signal(times);
                self.sig    =   sig{1};
            end
            param           =   social.vad.tools.Param();
            [spec,~,~]      =   social.vad.tools.spectra(self.sig, param.specWinSize, param.specShift, param.Fs, 0);
        end
        
        function fundamental = get_fundamental(self, varargin)
            normalizationMethod = 'non';
            if nargin > 1
                normalizationMethod = varargin{1};
            end
            
            times           =   [self.eventStartTime, self.eventStopTime];
            if isempty(self.sig)
                sig         =   self.session.Signals(self.channel).get_signal(times);
                self.sig    =   sig{1};
            end
            param           =   social.vad.tools.Param();
            l               =   length(self.sig);
            frameLen        =   param.frameLenFF;
            frameShift      =   param.frameShiftFF;
            num             =   floor((l-frameLen)/frameShift)+1;
            sig_bp          =   self.bandPassFilter();
            fundamental     =   zeros(num,1);
            fundamental1    =   zeros(num,1);
            winWidth        =   (frameLen/20);
            for i = 1 : num
                x = sig_bp((i-1)*frameShift + 1 : (i-1)*frameShift+frameLen);
                x = x - mean(x);
                cf = xcorr(x);
                cf = cf(frameLen:end);
                dif_cf = diff(cf);
                sig1 = dif_cf(1:end-1);
                sig2 = dif_cf(2:end);
                k = sum(abs(sign(sig1) - sign(sig2)))/4;
                fundamental(i) = self.Fs / (frameLen / k);
                
                fft_cf = abs(fft(cf));
                fft_cf = fft_cf(1:floor(end/2));
                fft_cf = fft_cf/max(fft_cf);
                fft_cf = smooth(fft_cf,3);
                dif_fft_cf = diff(fft_cf);
                index = 1 : length(dif_fft_cf);
                I = index(dif_fft_cf<-0.05);
                I = min(I);
%                 [~,f] = max(fft_cf(I-winWidth:I+winWidth));
%                 f = f + I - winWidth - 1;
                f = I;
                fundamental1(i) = f/frameLen*param.Fs;
            end   
            fundamental = medfilt1(fundamental,3);
            fundamental1 = medfilt1(fundamental1,3);
          
            fundamental = fundamental1;
            if strcmp(normalizationMethod, 'highpass')
                fundamental = (fundamental - mean(fundamental));
            end
        end
        
        function sig_bp = bandPassFilter(self, varargin)
            if nargin > 1
                isSave = varargin{1};
            else
                isSave = 0; 
            end
            sig_bp = social.vad.tools.bandPassFilter4k_18k(self.sig, self.Fs);
            if isSave == 1
                self.sig = sig_bp;
            end
        end
        
    end
    
end

