classdef AnalogSignal < social.interface.Signal & social.interface.Filer
    %AnalogSignal An analog signal object handles reading and writing 
    % one or more analog signals from file. 
    %   Detailed explanation goes here
    
    properties
        SampleRate
        TotalSamples
    end
    
    methods
        function samples=times2samples(self,times)
            % convert a nx1 or nx2 times array (in seconds) to a nx1 or nx2
            % samples array (in number of samples)
            samples=times.*self.SampleRate;
            
            % Floor 1st sample.
            samples(1,:)=floor(samples(1,:));
            % If there is a second sample, ceiling it.
            if size(samples,2)>1
                samples(2:end,:)=ceil(samples(2:end,:));
            end
            
            % Force any samples == 0 to be 1.
            samples(samples==0) = 1;
        end
        function times = samples2times(self,samples)
            % convert a nx1 or nx2 samples array (in number of samples) to a nx1 or nx2
            % times array (in seconds)
            times=(samples-1)./self.SampleRate;
        end
    end
end

