classdef SessionFile < social.interface.HeaderFile
    % SessionFile - The SessionFile file interface object stores information 
    % related to accessing a mvx or DAQ_Record header file.  In particular, it
    % specifies how paths and filenames are stored, and can report information about 
    % recorded signals.
    %
    % Written by Seth Koehler and Lingyun Zhao, 3/2015.
    properties
        Header = [];
    end
    methods
        function self = SessionFile(relativepath)
            self.File=relativepath;
            self.Header.fname = self.File;
            
            self.Header=social.session.util.digvoc_header(self.Header,'load');
            
        end
        function tab=Tabulate(self);
            warning('off'); % Hide warnings about not filling in rows completely.
            tab=table;
            row=0;
            for i=1:length(self.Header.nch)
                for j=1:self.Header.nch(i)
                    % Step through each channel in the header and create a
                    % new row.
                    row=row+1;
                    tab.set(row,1)=i;
                    tab.ch(row,1)=self.Header.chlist{i}(j);
                    tab.exp{row,1}=self.Header.exp;
                    tab.animal{row,1}=self.Header.animal;
                    tab.environment{row,1}=self.Header.datasource;
                    tab.start{row,1}=self.Header.time;
                    tab.stop{row,1}=self.Header.stop;
                    tab.sr(row,1)=self.Header.sr(i);
                    temp=self.Header.ch{i}{tab.ch(row,1)};
                    tempnames=fieldnames(temp);
                    for k=1:length(tempnames)
                        tab.(tempnames{k}){row,1}=temp.(tempnames{k});
                    end
                    
                end
            end
            warning('on');
        end
        function str = Report(self);
            str{1}=['Experiment: ' self.Header.exp];
            str{2}=['Animal ID: ' self.Header.animal];
            str{3}=['File: ' self.File];
            str{4}=['Start: ' self.Header.time ' Stop: ' self.Header.stop];
            str{5}=['Number of channels: ' num2str(self.Header.nch)];
            str{6}=['Sampling rate: ' self.Header.sr ' kHz'];
            % Loop through all channels and format cellstr identifying
            % information re: channel
            strcount=7
            for i=1:length(self.Header.nch)
                for j=1:self.Header.nch(i)
                    str{strcount}=['Channel: ' num2str(self.Header.chlist{i}(j))]; %TODO
                    strcount=strcount+1;
                    temp=self.Header.ch{i}{self.Header.chlist{i}(j)};
%                     str{strcount}=
                end
            end
            str=reshape(str,numel(str),1);
        end
    end
end
