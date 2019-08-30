function info = digvoc_header(info,flag)
%
% This function is used to both read and write the header file associated with
% each .wav data file.  It has both input and output as a cell array 'info'.
%
% Created: 1/9/02  by Steven Eliades

switch flag
    case 'load'

        info = dvrload(info);
    case 'save'
        info = dvrsave(info);
end

return


%List of variables in cell array info:
%   fname  (filename, from the outside)
%   enable (do not assign value here)
%   lock   (specify whether to lock params, default 1);
%   exp    (3 char experiment string:  voc, bby, dby)
%   animal (4 char animal ID, if multiple animals value is 'mult')
%   session (digit session number for a given animal/experiment)
%   nch    (number of data channels used)
%   srate  (array of sampling rates with nch entries, in KHz)
%   depth  (array of depths on each channel)
%   hole   (array of hole numbers on each channel)
%   hemi   (list of hemisphere for each channel L/R
%   anlist (list of animals for each channel, used when exp is not 'voc')
%   date   (Date of original recording)
%   time   (Start time of original recording)
%   stop   (Stop time of original recording)
%   reclng (Length of original recording (in sec)

%-------------------------------------------------------------------------------
function info = dvrload(info)
%
% This function will read the header file specified in cell array info.

[p,fname,ext] = fileparts(info.fname);
if isempty(p)
    file = [fname '.hdr'];
else
    file = [p '\' fname(1:end) '.hdr']; % Remove code that drops last character
end
hdrfid = fopen(file,'rt');

% Read hdr text into a struct
ihdr = 1;
while ~feof(hdrfid)
    hdrstr{ihdr} = fgetl(hdrfid);
    ihdr = ihdr+1;
end
fclose(hdrfid);

%Set default values
info.lock = 1;
info.enable = 0;

%Search for remaining parameters
info.exp = dvrfind(hdrstr,'Experiment',1);
info.animal = dvrfind(hdrstr,'Animal',1);
info.session = dvrfind(hdrstr,'Session',2);
info.datasource = dvrfind(hdrstr,'Data Source',1);
info.date = dvrfind(hdrstr,'Date',1);
info.time = dvrfind(hdrstr,'Start Time',1);
info.stop = dvrfind(hdrstr,'Stop Time',1);
info.reclng = dvrfind(hdrstr,'Total Recording Length',2);
info.inittime = dvrfind(hdrstr,'Start Offset Time',1);
info.comments = dvrfindComments(hdrstr,'Comments:',1);
[temp1 temp2] = dvrfindChanNum(hdrstr,'Channels','/');

% Handle the problem if there is only one subset of channels.
info.nch = [temp1 temp2];

status = dvrfind(hdrstr,'Status',1);
info.filestatus = strcmp(status,'Analysis');

%Find channel specific parameters
for j=1:length(info.nch)
    for ich=1:info.nch(j)
        if length(info.nch)==1; searchstr=''; else searchstr= [num2str(j) '/'] ;end
        out = dvrfindChannel(hdrstr, ['Channel ' searchstr],ich);
        
        %j =  out{1};
        if length(info.nch)==1; i = out{1}; else i = out{2}; end
        info.sr(j) = str2num(out{3});
        info.chlist{j}(ich)=i;
        switch lower(out{4})
            case 'animal'
                info.ch{j}{i}.dtypenum =1;
                info.ch{j}{i}.animal=out{5};
                info.ch{j}{i}.depth=str2num(out{7}); % number
                info.ch{j}{i}.hemi=out{9};  % string
                info.ch{j}{i}.dtype=out{11}; % stfring
            case 'hole'
                info.ch{j}{i}.dtypenum =2;
                info.ch{j}{i}.hole = str2num(out{5}); % number
                info.ch{j}{i}.depth=str2num(out{7}); % number
                info.ch{j}{i}.hemi=out{9};  % string
                info.ch{j}{i}.dtype=out{11}; % string
            case 'colony'
                info.ch{j}{i}.dtypenum =3;
                info.ch{j}{i}.animal=' ';
                info.ch{j}{i}.depth=str2num(out{6}); % number
                info.ch{j}{i}.hemi=out{8};  % string
                info.ch{j}{i}.dtype=out{10}; % string
            case 'synch'
                info.ch{j}{i}.dtypenum =4;
                info.ch{j}{i}.animal=' ';
                info.ch{j}{i}.depth=str2num(out{6}); % number
                info.ch{j}{i}.hemi=out{8};  % string
                info.ch{j}{i}.dtype=out{10}; % string
        end
    end
end
return

%----------------------------------------------------------------------------
function out = dvrfindComments(hdrstr,strtofind,ich)
% This function searches struct hdrstr to find string specified in strtofind
% and returns data formatted by flag.
% Find line with desired string
out{1}='';
str = '';
count=0;
for i=1:length(hdrstr)
    if findstr(hdrstr{i}, strtofind)
        for j=i+1:length(hdrstr)
            str = hdrstr{j};
            str = deblank(str);
            count=count+1;
            out{count}=str;
        end;
        break;
    end
end
a=5;



%----------------------------------------------------------------------------
function out = dvrfindChannel(hdrstr,strtofind,ich)
% This function searches struct hdrstr to find string specified in strtofind
% and returns data formatted by flag.
% Find line with desired string
str = '';
count=0;
for i=1:length(hdrstr)
    if findstr(hdrstr{i}, strtofind)
        str = hdrstr{i};
        str = deblank(str);
        count=count+1;
        if(count==ich)
            break;
        end
    end
end

if length(str)==0
    out = [];
    return
end

str1 = str(1:findstr(':',str)-1);
[t,r]=strtok(str1,'Channel');
[board,r]=strtok(t,'/');
[ch,r]=strtok(r,'/');
out{1} = str2num(board);
out{2} = str2num(ch);

str = str(findstr(':',str)+1:length(str));
ind = 1;
while ~isempty(str)
    [temp{ind}, str] = strtok(str);
    ind = ind+1;
end
for k=2:length(temp)
    out{1+k}=temp{k};
end

return


%----------------------------------------------------------------------------
function [ch1 ch2] = dvrfindChanNum(hdrstr,strtofind,token)
%
% This function searches struct hdrstr to find string specified in strtofind
% and returns data formatted by flag.

% Find line with desired string
str = '';
for i=1:length(hdrstr)
    if findstr(hdrstr{i}, strtofind)
        str = hdrstr{i};
        str = deblank(str);
        break;
    end
end

if length(str)==0
    out = [];
    return
end

str = str(findstr('=',str)+1:length(str));

[ch1, r] = strtok(str,token);
ch2 = strtok(r,token);
ch1=str2num(ch1);
ch2=str2num(ch2);

return


%----------------------------------------------------------------------------
function out = dvrfind(hdrstr,strtofind,flag)
%
% This function searches struct hdrstr to find string specified in strtofind
% and returns data formatted by flag.

% Find line with desired string
str = '';
for i=1:length(hdrstr)
    if findstr(hdrstr{i}, strtofind)
        str = hdrstr{i};
        str = deblank(str);
        break;
    end
end

if length(str)==0
    out = [];
    return
end


if flag ~= 3                        %Looking for single data type in a line
    str = str(findstr('=',str)+1:length(str));
    out = strtok(str);
    if flag == 2
        out = str2num(out);
    end
else                                %Looking for a long data line
    %GQ added 07-17-09
    str1 = str(1:findstr(':',str)-1);
    [t,r]=strtok(str1,'Channel');
    [board,r]=strtok(t,'/');
    [ch,r]=strtok(r,'/');
    out{1} = str2num(board);
    out{2} = str2num(ch);

    str = str(findstr(':',str)+1:length(str));
    ind = 1;
    while ~isempty(str)
        [temp{ind}, str] = strtok(str);
        ind = ind+1;
    end
    for k=2:length(temp)
        out{1+k}=temp{k};
    end
end

return

%-----------------------------------------------------------------------------
function info = dvrsave(info)
%
% This function writes the header file (ASCII) with data in info

% Establish header filename
[p,fname,ext] = fileparts(info.fname);
if isempty(p)
    file = [fname '.hdr'];
else
    file = [p '\' fname '.hdr'];
end
hdrfid = fopen(file,'wt');

fprintf(hdrfid,'%s Header File \n',fname);
fprintf(hdrfid,'Experiment = %s \n',info.exp);
fprintf(hdrfid,'Animal = %s \n',info.animal);
fprintf(hdrfid,'Session = %g \n',info.session);
fprintf(hdrfid,'Date = %s \n',info.date);
fprintf(hdrfid,'Start Time = %s \n',info.time);
fprintf(hdrfid,'Channels = %g \n',info.nch);

for i=1:info.nch
    switch info.exp
        case 'voc'
            str = ['Hole ' num2str(info.hole(i))];
        otherwise
            str = ['animal ' info.anlist{i}];
    end
    linestr = ['Channel %g : SRate(KHz) %g %s Depth %g Hemisphere %s \n'];
    fprintf(hdrfid,linestr,i,info.srate(i),str,info.depth(i),info.hemi(i));
end
fprintf(hdrfid,'Stop Time = %s \n',info.stop);
fprintf(hdrfid,'Total Recording Length = %g \n',info.reclng);

fclose(hdrfid);

return



