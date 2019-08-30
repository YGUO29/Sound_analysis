classdef PhraseConfidence < social.event.Phrase
    %PHRASECONFIDENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        energyDiff          =   0;
        energyPar           =   0;
        energyDiffWireless  =   0;
        energyParWireless   =   0;
        exception           =   0;
        AHR                 =   0;
        callType            =   '';
        channel             =   nan;
    end
    
    methods
        function self = PhraseConfidence(varargin)
            self = self@social.event.Phrase(varargin{1:5});
            p = inputParser;
            p.addParameter('callType', []);
            p.addParameter('energyDiff', []);
            p.addParameter('energyPar', []);
            p.addParameter('energyParWireless',[]);
            p.addParameter('energyDiffWireless',[]);
            p.addParameter('AHR', []);
            p.addParameter('exception', []);
            p.addParameter('channel', []);
            
            p.parse(varargin{6:end});
            self.energyDiff         =   p.Results.energyDiff;
            self.energyPar          =   p.Results.energyPar;
            self.energyDiffWireless =   p.Results.energyDiffWireless;
            self.energyParWireless  =   p.Results.energyParWireless;
            self.eventPhraseType    =   p.Results.callType;
            self.AHR                =   p.Results.AHR;
            self.exception          =   p.Results.exception;
            self.channel            =   p.Results.channel;
        end
    end
    
end

