function out = CheckSessionConfig(beh)

% check session notes for whether to do denoise in get_features

sbj = beh.Subjects;
session = beh.Session.ID;
ind = strfind(session,'_S');
ses_num = str2num(session(ind+2:end));

param = SubjectVocalParam(sbj);

if ~isempty(find(param.Session_RecNoise == ses_num))
    out.VocalFeatureDenoise = 1;
else
    out.VocalFeatureDenoise = 0;
end