function [F0, F0_Energy] = GetCallF0_Parabolic(y,y_extra,start_time,param)
    % calculate phee F0
    Fs = param.Fs;
    bin_time = 0.001;        % 1ms bins, no smoothing
    win_time = 0.01;         % ms window, frequency resolution 1/win_time Hz          
    phee_cutoff = [5000 10000];
    call_len_th = 0.1;       % two strategies to calculate F0 for calls longer or shorter than this number
    bin_size = round(bin_time*Fs);
    win_size = win_time * Fs;
    win_size = round(win_size/2)*2;     % make sure it's even
    small_freq_win = 3000;          % Hz around the old F0 to check new F0
    small_freq_win_ind = round(small_freq_win/(Fs/win_size)/2)*2;
    
    energyband = 1000;        % in Hz, checkband is centered at F0
    oneside_size = round(energyband/2*win_time);     % index coverage for one side band
    
    
    param_in.spec_th = param.spec_th;
    param_in.shift_time = bin_time;
    param_in.win_time = win_time;
    param_in.Fs = Fs;
    param_in.mode = 'file';
    param_in.task = 'GetCallF0';
    
    y_sig = [y;y_extra(1:win_size-1,:)];        % make sure the end of phee is included in spectrogram
    
    % process two channels
    [out, param_out] = MicChIntensityDiff(y_sig,param_in);
    
    spec = out.spec_diff;
    F0(:,1) = start_time+[0:size(spec,2)-1]'*bin_size/Fs;       % was *bin_time, by L.Zhao, 10/05/12
    start_ind = round((win_size/2)/(Fs/2)*phee_cutoff(1))+1;
    end_ind = round((win_size/2)/(Fs/2)*phee_cutoff(2))+1;
    tag = 0;
    
    % added by L.Zhao, 05/31/2013 =========================================
    F0_Energy(:,1) = start_time+[0:size(spec,2)-1]'*bin_size/Fs;
    % =====================================================================
    
    if size(y,2)/Fs > call_len_th
        for i = round(0.1/bin_time):size(spec,2)
            if tag == 0
                [B f_ind(i)] = max(spec(start_ind:end_ind,i));
                f_ind(i) = f_ind(i)-1+start_ind;
                tag = 1;
            else
                [B f_ind(i)] = max(spec(max(1,f_ind(i-1)-small_freq_win_ind/2):min(f_ind(i-1)+small_freq_win_ind/2,size(spec,1)),i));
                f_ind(i) = f_ind(i)-1+max(1,f_ind(i-1)-small_freq_win_ind/2);
            end

            energy(i) = sum(spec(max(1,f_ind(i)-oneside_size):min(f_ind(i)+oneside_size,size(spec,1)),i));   % added by L.Zhao, 05/31/2013
        end


        for i = round(0.1/bin_time)-1:-1:1
            [B f_ind(i)] = max(spec(max(1,f_ind(i+1)-small_freq_win_ind/2):min(f_ind(i+1)+small_freq_win_ind/2,size(spec,1)),i));    
            f_ind(i) = f_ind(i)-1+max(1,f_ind(i+1)-small_freq_win_ind/2);

            energy(i) = sum(spec(max(1,f_ind(i)-oneside_size):min(f_ind(i)+oneside_size,size(spec,1)),i));   % added by L.Zhao, 05/31/2013
        end

   
    else
        [B f_ind_temp] = max(spec(start_ind:end_ind,1:5));
        f_ind_ref = median(f_ind_temp)-1+start_ind;
        for i = 1:size(spec,2)
            if i == 1
                f_ind_last = f_ind_ref;
            else
                f_ind_last = f_ind(i-1);
            end
            [B f_ind(i)] = max(spec(max(1,f_ind_last-small_freq_win_ind/2):min(f_ind_last+small_freq_win_ind/2,size(spec,1)),i));
            f_ind(i) = f_ind(i)-1+max(1,f_ind_last-small_freq_win_ind/2);
            
            energy(i) = sum(spec(max(1,f_ind(i)-oneside_size):min(f_ind(i)+oneside_size,size(spec,1)),i));  
        end
    end
    
 %     [B f_ind] = max(spec(start_ind:end_ind,:));
    F0(:,2) = (f_ind-1)*Fs/win_size;
    F0_Energy(:,2) = energy';
    
%     figure(300);delete(gca);imagesc(spec);axis xy;hold on;plot(f_ind,'w');
    
end