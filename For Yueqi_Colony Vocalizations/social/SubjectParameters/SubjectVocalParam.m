function out = SubjectVocalParam(SubjectID)
% SubjectVocalParam

switch SubjectID
    case 'M9606'
        out.IPI_th              =   0.5;    % inter phrase interval threshold for combining phrases to calls
        out.Session_RecNoise    =   [1:176];     % session range with recording noise
        out.p_peep_max_dur      =   0.27;   % threshold for p-peep
        out.t_peep_max_dur      =   0.11;   % threshold for t-peep
        
    case 'M93A'
        out.IPI_th              =   0.87;    % inter phrase interval threshold for combining phrases to calls
        out.Session_RecNoise    =   [96:197];     % session range with recording noise
        out.p_peep_max_dur      =   0.33;   % threshold for p-peep
        out.t_peep_max_dur      =   0.11;   % threshold for t-peep
        
    case 'M91C'
        out.IPI_th              =   0.6;    % inter phrase interval threshold for combining phrases to calls
        out.Session_RecNoise    =   [];     % session range with recording noise
        out.p_peep_max_dur      =   0.38;   % threshold for p-peep
        out.t_peep_max_dur      =   0.15;   % threshold for t-peep
        
    case 'M64A'
        out.IPI_th              =   0.6;    % inter phrase interval threshold for combining phrases to calls
        out.Session_RecNoise    =   [];     % session range with recording noise
        out.p_peep_max_dur      =   0.21;   % threshold for p-peep
        out.t_peep_max_dur      =   0.15;   % threshold for t-peep
        
    case 'M92C'
        out.IPI_th              =   0.4;    % inter phrase interval threshold for combining phrases to calls
        out.Session_RecNoise    =   [];     % session range with recording noise
        out.p_peep_max_dur      =   0.30;   % threshold for p-peep
        out.t_peep_max_dur      =   0.15;   % threshold for t-peep
        
    case 'M29A'
        out.IPI_th              =   0.4;    % inter phrase interval threshold for combining phrases to calls
        out.Session_RecNoise    =   [];     % session range with recording noise
        out.p_peep_max_dur      =   0.38;   % threshold for p-peep
        out.t_peep_max_dur      =   0.15;   % threshold for t-peep
        
        
    otherwise
        out.IPI_th              =   0.5;
        out.Session_RecNoise    =   [];
end