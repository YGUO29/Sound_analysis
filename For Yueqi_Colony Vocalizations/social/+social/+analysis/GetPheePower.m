function data = GetPheePower(y,Fs)
    % calculate phee power and return a data structure containing 1xn
    % arrays (n is the number of bins) in fields time and power.
    bin_time = 0.001;        % 1ms bins, no smoothing
    bin_size = round(bin_time*Fs);
    
    power(:,1) = [0:bin_time:length(y)/Fs]';
    for i = 1:size(power,1)-1
        power(i,2) = sum(y((i-1)*bin_size+1:i*bin_size).^2)/bin_time;
    end
    i = size(power,1);
    power(i,2) = sum(y((i-1)*bin_size+1:length(y)).^2)/bin_time;
    data.time = power(:,1)';
    data.power = power(:,2)';
end
