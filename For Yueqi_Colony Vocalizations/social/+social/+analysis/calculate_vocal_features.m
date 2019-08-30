function feature = calculate_vocal_features(self,type, denoise,plot_en)
% this is a wrapper function before executing Tfeature_ana.m, used in
% Phrase and Call classes

social.analysis.ParamFeature;
param.Fs = self.Behavior.SigDetect.SampleRate;

% load more signal before and after the window for spectrogram calculation
winsize = 2*round(win_time*Fs/2);
new_start_time = self.eventStartTime - (winsize/2-1)/Fs;
new_stop_time = self.eventStopTime + (winsize/2)/Fs;
phrase_sig=self.Behavior.get_signal([new_start_time,new_stop_time]);

phrase_sig = phrase_sig{1};
% get reference signal
if denoise
    pre_time(1) = max(0,self.eventStartTime - precall_length);
    pre_time(2) = self.eventStartTime;
    pre_sig = self.Behavior.get_signal(pre_time);
    param.PreCallSignal = pre_sig{1};
end


if isprop(self.Behavior,'SigRef')
    ref_signal = self.Behavior.get_signal([new_start_time,new_stop_time],'SigRef');
    param.RefSignal = ref_signal{1};
end
param.Subject = self.Subjects;
feature=social.analysis.Tfeature_ana(type,phrase_sig,plot_en,param);