function power = GetPheePower(y,start_time,Fs)
    % calculate phee power
    bin_time = 0.001;        % 1ms bins, no smoothing
    bin_size = round(bin_time*Fs);
    
    power(:,1) = [start_time:bin_time:start_time+length(y)/Fs]';
    for i = 1:size(power,1)-1
        power(i,2) = sum(y((i-1)*bin_size+1:i*bin_size).^2)/bin_time;
    end
    i = size(power,1);
    power(i,2) = sum(y((i-1)*bin_size+1:length(y)).^2)/bin_time;



end