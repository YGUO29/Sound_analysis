function [feature] = Tfeature_ana_new(type, data, visu)
% To analyze acoustic feature in each call type in Tony's data

% data: original data vector
% type: call type 'twit', 'phee', 'tril', or 'trph'
% visu: visualize option 'on', or 'off'

% Note that Tony's data does not have PC noise, so the pixel intensity 
% threshold was assigned to a number from statistics instead of a
% background PC noise intensity as we did in FEATURE_ANA function for Utah
% project.

% Modified note: change parameters T_colthr and pixelnum on 05/11/2015 CJ

%% Get T-F Contour
% Get spectrogram and reset frequency range
nFFT = 512;
overlap = 0.75;
SR = 50000;

% High-pass filter
filter_parms = [0 4000 SR/2]; % 3000
B = fir2(512, filter_parms./(SR/2), [0 1 1]);
data = filtfilt(B, 1, data);

% STFT spectrogram
win = window(@hamming, nFFT);
[Y, F, T] = specgram(data, nFFT, SR, win, nFFT*overlap);
newY = 20*log10(abs(Y));
if strcmp(visu, 'on')
    figure('Name', 'Original');   
    imagesc(T, F/1000, newY); axis xy; colormap(jet);
    xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
    ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
    set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
    title('High-Pass Filtered Spectrogram');
end

% Find maximum frequency index
if strcmp(type, 'twit')
    intensity_thr = -1;
    newY(newY < intensity_thr) = -100;
    newY(176:end, :) = -100;
    newY(1:31, :) = -100;
    newY(1:50, 1:40) = -100;
else
    newY(115:end, :) = -100;
    newY(1:31, :) = -100;
    newY2 = newY;
    sortY = sort(newY2);
    maxY2 = sortY(end, :);
    idx_maxY2 = arrayfun(@(x) find(newY2 == x, 1, 'first'), maxY2);
    newY2(idx_maxY2) = 100;
    newY2(newY2~=100) = 0;
    [xrow, xcol] = find(newY2 == 100);
    Txcol = T(xcol);
    if strcmp(visu, 'on')
        figure('Name', 'Maximum Contour');   
        % imagesc(T, F/1000, newY2); axis xy; colormap(flipud(gray));
        scatter(Txcol, F(xrow)/1000, 'k.');
        ylim([0 25]); xlim([0 Txcol(end)]); box on;
        xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
        ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
        set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
        title('Maximum Contour');
    end
end

% Remove discontinuous contour points
switch type
    case 'twit' % ======= Twitter Calls ========================================
        % ---------- remove harmonic structure --------------- 
        [rowH, colH] = find(newY~=-100);
        [~, ia, ~] = unique(colH);
        startcolH = [1; ia(1:end-1) + 1];
        aa = rowH(startcolH);
        colH2 = colH(startcolH(aa<=63));
        pixelgap = floor(800/(F(2)-F(1)));
        idxH = [];
        for c = 1:length(colH2)
            rowidx = find(colH == colH2(c));
            targetrow = rowH(rowidx);
            idxover = find(targetrow >= 65, 1, 'first');
            targetrow = targetrow(targetrow >= 65);
            difrowH = diff(targetrow);
            idxposH = find(difrowH>pixelgap) + idxover;
            if isempty(idxH), idxH = rowidx(idxposH:end);
            else idxH = [idxH; rowidx(idxposH:end)]; end
        end
        idx_maxYH = sub2ind(size(newY), rowH(idxH), colH(idxH));
        newY(idx_maxYH) = -100;
        [~, xcol] = find(newY ~= -100);
        Txcol = T(xcol);
        if strcmp(visu, 'on')
            figure('Name', 'Harmonic Removal');   
            imagesc(T, F/1000, newY); axis xy; colormap(flipud(gray));
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12, 'FontWeight','bold', 'linewidth',2);
            title('Edge Detection and Harmonic Removal');
        end
        
        % ---------- find maximum frequency in each time bin --------------- 
        newY2 = newY;
        sortY = sort(newY2);
        maxY2 = sortY(end, :);
        idx_maxY2 = arrayfun(@(x) find(newY2 == x, 1, 'first'), maxY2);
        newY2(idx_maxY2) = 100;
        newY2(newY2~=100) = 0;
        newY2(1:31, :) = 0;
        [xrow2, xcol2] = find(newY2 == 100);
        Txcol2 = T(xcol2);
        if strcmp(visu, 'on')
            figure('Name', 'Maximum Contour');   
            scatter(Txcol2, F(xrow2)/1000, 'k.');
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Maximal T-F Trace');
        end

        % ---------- remove PC noise between phrases ---------------
        newY4 = newY;
        [row_idx2 col_idx2] = find(newY2 == 100);
        pot_noiseidx = row_idx2 >= 62 & row_idx2 <= 66;
        temp_rowidx2 = row_idx2;
        temp_rowidx2(pot_noiseidx) = 66;
        difrow = diff(temp_rowidx2);
        contzero = 6;
        binary_difrow = (abs(difrow') > 0);
        dsig = diff([1 binary_difrow 1]);
        startIndex = find(dsig < 0);
        endIndex = find(dsig > 0)-1;
        duration = endIndex - startIndex + 1;
        stringIndex = (duration >= contzero);
        startIndex = startIndex(stringIndex);
        endIndex = endIndex(stringIndex);
        
        
        if isempty(startIndex)
            newrow_idx2 = row_idx2; 
            newcol_idx2 = col_idx2;
        else
            newrow_idx2 = []; newcol_idx2 = [];
            if startIndex(1) == 1 && endIndex(end) == col_idx2(end)-1 % two-end PC noise
                for i = 1:length(startIndex)-1
                    newrow_idx2 = [newrow_idx2; row_idx2(endIndex(i)+2:startIndex(i+1)+1)];
                    newcol_idx2 = [newcol_idx2; col_idx2(endIndex(i)+2:startIndex(i+1)+1)];
                end
            elseif startIndex(1) == 1 && endIndex(end) ~= col_idx2(end)-1 % begin PC noise
                if length(startIndex) == 1
                    newrow_idx2 = [newrow_idx2; row_idx2(endIndex+2:end)];
                    newcol_idx2 = [newcol_idx2; col_idx2(endIndex+2:end)];
                else
                    for i = 1:length(startIndex)
                        if i == length(startIndex)
                            newrow_idx2 = [newrow_idx2; row_idx2(endIndex(i)+2:end)];
                            newcol_idx2 = [newcol_idx2; col_idx2(endIndex(i)+2:end)];
                        else
                            newrow_idx2 = [newrow_idx2; row_idx2(endIndex(i)+2:startIndex(i+1))];
                            newcol_idx2 = [newcol_idx2; col_idx2(endIndex(i)+2:startIndex(i+1))];
                        end
                    end
                end
            elseif startIndex(1) ~= 1 && endIndex(end) == col_idx2(end) % end PC noise
                for i = 1:length(startIndex)-1
                    if i == 1
                        newrow_idx2 = [newrow_idx2; row_idx2(1:startIndex(1))];
                        newcol_idx2 = [newcol_idx2; col_idx2(1:startIndex(1))];
                    else
                        newrow_idx2 = [newrow_idx2; row_idx2(endIndex(i)+2:startIndex(i+1))];
                        newcol_idx2 = [newcol_idx2; col_idx2(endIndex(i)+2:startIndex(i+1))];
                    end
                end
            else % both-end no PC noise
                if length(startIndex) == 1
                    newrow_idx2 = [newrow_idx2; row_idx2(1:startIndex)];
                    newcol_idx2 = [newcol_idx2; col_idx2(1:startIndex)];
                    newrow_idx2 = [newrow_idx2; row_idx2(endIndex+2:end)];
                    newcol_idx2 = [newcol_idx2; col_idx2(endIndex+2:end)];
                else
                    for i = 1:length(startIndex)
                        if i == 1
                            newrow_idx2 = [newrow_idx2; row_idx2(1:startIndex(i))];
                            newcol_idx2 = [newcol_idx2; col_idx2(1:startIndex(i))];
                        else
                            newrow_idx2 = [newrow_idx2; row_idx2(endIndex(i-1)+2:startIndex(i))];
                            newcol_idx2 = [newcol_idx2; col_idx2(endIndex(i-1)+2:startIndex(i))];
                        end
                        if i == length(startIndex)
                            newrow_idx2 = [newrow_idx2; row_idx2(endIndex(i)+2:end)];
                            newcol_idx2 = [newcol_idx2; col_idx2(endIndex(i)+2:end)];
                        end
                    end
                end
            end
        end
        idx_maxY4 = sub2ind(size(newY4), newrow_idx2, newcol_idx2);
        newY4(idx_maxY4) = 100;
        newY4(newY4~=100) = 0;
        [xrow3, xcol3] = find(newY4 == 100);
        Txcol3 = T(xcol3);
        if strcmp(visu, 'on')
            figure('Name', 'Remove Between-Phrase PC Noise');   
            scatter(Txcol3, F(xrow3)/1000, 'k.');
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Remove Between-Phrase PC Noise');
        end
        
        % ---------- find max peak location -> (7 pixel all zero) ---------
        newY5 = newY;
        [row_idx3 col_idx3] = find(newY4 == 100);
        Srow_idx3 = floor(smooth(smooth(row_idx3)));
        difrow2 = diff(Srow_idx3);
        negidx = find(difrow2 < 0);
        difneg = diff(negidx);
        T_colthr = 1;
        pixelnum = 3;
        itp = find(difneg > T_colthr);
        FBW = Srow_idx3(negidx(itp+1))- Srow_idx3(negidx(itp));
        FBWthr_b = 10;
        FBWthr_m = max(min(mean(FBW(FBW>0)), 20), 10);
        if FBWthr_m <= 10, FBWthr_e = 5;
        else FBWthr_e = 10; end
        bphrase_idx = find(FBW>=FBWthr_b, 1, 'first');
        ephrase_idx = find(FBW>=FBWthr_e, 1, 'last');
        mphrase_idx = find(FBW>=FBWthr_m);
        if mphrase_idx(1) == bphrase_idx
            mphrase_idx = mphrase_idx(2:end);
        end
        if mphrase_idx(end) == ephrase_idx
            mphrase_idx = mphrase_idx(1:end-1);
        end
        phraseidx = [bphrase_idx; mphrase_idx; ephrase_idx];
        negtrough = negidx(itp(phraseidx));
        if row_idx3(negtrough(1))<45 || row_idx3(negtrough(1)+1)<45 || row_idx3(negtrough(1)-1)<45, 
            negtrough = negtrough(2:end); 
        end
        trough_idx2back = (negtrough-1);
        if T(col_idx3(negidx(itp(1))))-T(col_idx3(1))<0.03 && Srow_idx3(negidx(itp(1)))<60, 
            trough_idx2back = [negidx(itp(1)); trough_idx2back];
        else
            trough_idx2back = [1; trough_idx2back];
        end
        if T(col_idx3(end))-T(col_idx3(negidx(end)))>0.02 && Srow_idx3(end)- Srow_idx3(negidx(end))>10, 
            trough_idx2back = [trough_idx2back; negidx(end)];
        end
                
        trough_idx2 = trough_idx2back;
        
        IPIthr = 0.08;
        for i = 1:length(trough_idx2)-1
            if i > length(trough_idx2)
                break
            end
            trough_idxtemp = trough_idx2(T(col_idx3(trough_idx2)) > (T(col_idx3(trough_idx2(i)))+IPIthr));
            trough_idx2 = [trough_idx2(1:i); trough_idxtemp]; % trough
        end
                
        starrow = []; starcol = []; domrow = []; domcol = []; knee = [];
        if ~isempty(col_idx3)
            for phr = 1:size(trough_idx2,1)
                if phr == size(trough_idx2,1), 
                    phr_wrap = Srow_idx3(trough_idx2(phr):end);
                else
                    phr_wrap = Srow_idx3(trough_idx2(phr):trough_idx2(phr+1)-1);
                end
                difphrwrap = diff(phr_wrap);

                if difphrwrap(1) < 0
                    peakidx = find(difphrwrap(5:end)<0, 1, 'first') + 4;
                    if isempty(peakidx), peakidx = length(difphrwrap); end
                else
                    peakidx = find(difphrwrap<0, 1, 'first'); 
                end

                if ~isempty(peakidx)
                    col = col_idx3(peakidx + trough_idx2(phr) - 1);
                    row = row_idx3(peakidx + trough_idx2(phr) - 1);
                    colminus = col-floor(pixelnum/2);
                    colplus = col+floor(pixelnum/2);
                    if colminus <= 0, colminus = 1; colplus = pixelnum; end
                    if colplus > size(newY5, 2), colplus = size(newY5, 2); end
                    A = newY5(row:end, colminus:colplus);
                    [findpeak ~] = findsubmat(A, -100*ones(5,pixelnum));
                    row_update = findpeak(1) + row - 1;
                    row = row_update;    
                    row_idx3(peakidx + trough_idx2(phr) - 1) = row;
                    starrow = [starrow row]; % peak
                    starcol = [starcol col];
                    trace = row_idx3(trough_idx2(phr):peakidx+trough_idx2(phr)-1);
                    diftrace = diff(trace);
                    negtrace = find(diftrace < 0, 1, 'last');
                    if isempty(negtrace), negtrace = 0; end
                    [~, kneeloc_trace] = max(diftrace(negtrace+1:end));
                    kneeloc = kneeloc_trace + trough_idx2(phr) + negtrace - 1;
                    if (kneeloc_trace + negtrace - 1) > 0 
                        if diftrace(kneeloc_trace + negtrace - 1) > pixelnum-1, kneeloc = kneeloc - 2; end
                    else
                        if diftrace(1) > pixelnum-1, kneeloc = kneeloc - 2; end
                    end
                    if (kneeloc_trace + negtrace - 2) > 0 
                        if diftrace(kneeloc_trace + negtrace - 2) == 0 || diftrace(kneeloc_trace + negtrace - 2) > 6, kneeloc = kneeloc-1; end
                    end
                    if (kneeloc_trace + negtrace - 2) > 0 
                        if diftrace(kneeloc_trace + negtrace - 2) == 0 || diftrace(kneeloc_trace + negtrace - 2) > 6, kneeloc = kneeloc-1; end
                    end
                    if (kneeloc_trace + negtrace - 1) > 0 
                        if diftrace(kneeloc_trace + negtrace - 1) > pixelnum-1, kneeloc = kneeloc - 2; end
                    end
                    knee = [knee kneeloc]; % knee
                    [~, domidx] = max(max(newY5(row_idx3(trough_idx2(phr):peakidx+trough_idx2(phr)-1), ...
                        col_idx3(trough_idx2(phr):peakidx+trough_idx2(phr)-1))));
                    domrow = [domrow row_idx3(domidx+trough_idx2(phr)-1)]; % dominance
                    domcol = [domcol col_idx3(domidx+trough_idx2(phr)-1)];
                    idx_maxY5 = sub2ind(size(newY5), row_idx3(trough_idx2(phr):peakidx+trough_idx2(phr)-1), ...
                    col_idx3(trough_idx2(phr):peakidx+trough_idx2(phr)-1));
                else
                    fprintf(['warning: phrase ' int2str(phr) ' is missing']); 
                    idx_maxY5 = sub2ind(size(newY5), row_idx3(trough_idx2(phr):length(phr_wrap)+trough_idx2(phr)-1), ...
                    col_idx3(trough_idx2(phr):length(phr_wrap)+trough_idx2(phr)-1));
                end
                if row_idx3(trough_idx2(phr)) - row_idx3(trough_idx2(phr)+1) > T_colthr
                    trough_idx2(phr) = trough_idx2(phr) + 1;
                end

                newY5(idx_maxY5) = 100;

            end
        end
        newY5(newY5~=100) = 0;
        [xrow4, xcol4] = find(newY5 == 100);
        Txcol4 = T(xcol4);
        if strcmp(visu, 'on')
            figure('Name', 'Wrap Phrases with Max Peak');   
            scatter(Txcol4, F(xrow4)/1000, 'k.'); 
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Wrap Phrases with Edge Detection');
        end
        
        % ---------- move outliers before knee point ---------
        F_colthr_1 = 10;
        F_colthr_2 = 2;
        newY6 = 20*log10(abs(Y));
        if ~isempty(knee(knee<=0))
            knee(knee<=0) = floor((starcol(knee<=0) + trough_idx2(knee<=0))/2);
        end
        supT = []; supF = [];
        if (size(trough_idx2,1) > length(knee)) && (size(trough_idx2,1) == length(starcol)) && (size(trough_idx2,1) == length(domcol))
            if length(starcol) - length(knee) == 1
                knee = [find(col_idx3 == domcol(1), 1, 'first') knee];
            elseif length(starcol) - length(knee) == 2
                knee = [find(col_idx3 == domcol(1), 1, 'first') find(col_idx3 == domcol(2), 1, 'first') knee];
            end
        elseif (size(trough_idx2,1) > length(knee)) && (size(trough_idx2,1) > length(starcol))
            trough_idx2 = trough_idx2(end-length(knee)+1:end);
        end
        Tknee = T(col_idx3(knee)); Tpeak = T(starcol);
        if ~isempty(trough_idx2)
            for phr = 1:size(trough_idx2,1)
            prephr_wrap = row_idx3(trough_idx2(phr):knee(phr));
                      
            for j = 1:length(prephr_wrap)-1
                range = [prephr_wrap(length(prephr_wrap)-j+1)-F_colthr_1 prephr_wrap(length(prephr_wrap)-j+1)+F_colthr_2];
                nextpt = newY6(:, col_idx3(trough_idx2(phr)+length(prephr_wrap)-j-1));
                maxval = max(nextpt(range(1):range(2)));
                row_idx3(trough_idx2(phr)+length(prephr_wrap)-j-1) = find(nextpt == maxval);
                prephr_wrap(length(prephr_wrap)-j) = find(nextpt == maxval);
            end
            
            idx_maxY6 = sub2ind(size(newY6), row_idx3(trough_idx2(phr):length(prephr_wrap)+trough_idx2(phr)-1), ...
                col_idx3(trough_idx2(phr):length(prephr_wrap)+trough_idx2(phr)-1));
            
            newY6(idx_maxY6) = 100;
            region = find(Txcol4 >= Tknee(phr) & Txcol4<= Tpeak(phr));
            supT = [supT; Txcol4(region)];
            supF = [supF; F(xrow4(region))];
            end
        end
        [xrow5, xcol5] = find(newY6 == 100);
        Txcol5 = T(xcol5);
        
        % ---------- plot main features (Peak Trough Knee Dom) ---------
        if strcmp(visu, 'on')
            figure('Name', 'Measure Feature');   
            scatter(Txcol5, F(xrow5)/1000, 'k.'); hold on;
            scatter(supT, supF/1000, 'k.'); hold on;
            scatter(T(starcol), F(starrow)/1000, 'b*'); hold on;
            scatter(T(col_idx3(trough_idx2)), F(row_idx3(trough_idx2))/1000, 36, [0,127/256,0], '*'); hold on;
            scatter(T(col_idx3(knee)), F(row_idx3(knee))/1000, 36, 'r'); hold on;
            scatter(T(domcol), F(domrow)/1000, 'm*'); hold on;
            h1 = scatter(T(starcol), F(starrow)/1000, 'b*');
            h2 = scatter(T(col_idx3(trough_idx2)), F(row_idx3(trough_idx2))/1000, 36, [0,127/256,0], '*'); 
            h3 = scatter(T(col_idx3(knee)), F(row_idx3(knee))/1000, 36, 'r');
            h4 = scatter(T(domcol), F(domrow)/1000, 'm*');
            legend([h1 h2 h3 h4], 'Peak', 'Trough', 'Knee', 'Dominant');
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Kalman Prediction');
        end
        
    otherwise % ======= Narrowband Calls ======================================== 
        % ---------- remove PC noise ---------- 
        newY3 = newY2;
        [row_idx col_idx] = find(newY2 == 100);
        contPC = 10;
        PCnoise1 = findstr(row_idx', 66*ones(1, contPC));
        PCnoise2 = findstr(row_idx', 67*ones(1, contPC));
        PCnoise3 = findstr(row_idx', 65*ones(1, contPC));
        PCnoise = [PCnoise1 PCnoise2 PCnoise3];
        if ~isempty(PCnoise), PCnoise = sort(PCnoise); end
        difpcnoise = diff(PCnoise);
        noiseidx = find(difpcnoise>1);
        noiseEdge = PCnoise(noiseidx) + contPC -1;
        if ~isempty(PCnoise)
            noiseStart = [PCnoise(1) PCnoise(noiseidx + 1)];
            noiseEnd = [noiseEdge PCnoise(end)+contPC-1];
            for npc = 1:length(noiseStart)
                idx_noise = sub2ind(size(newY3), row_idx(noiseStart(npc):noiseEnd(npc)), col_idx(noiseStart(npc):noiseEnd(npc)));
                newY3(idx_noise) = -100;
            end
        end
        
        if strcmp(type, 'tril')
            difrow = diff(row_idx);
            contzero = 6;
            binary_difrow = (abs(difrow') > 0);
            dsig = diff([1 binary_difrow 1]);
            startIndex = find(dsig < 0);
            endIndex = find(dsig > 0)-1;
            duration = endIndex - startIndex + 1;
            stringIndex = (duration >= contzero);
            startIndex = startIndex(stringIndex);
            endIndex = endIndex(stringIndex);
            if isempty(startIndex)
                newrow_idx2 = row_idx; 
                newcol_idx2 = col_idx;
            else
                newrow_idx2 = []; newcol_idx2 = [];
                if startIndex(1) == 1 && endIndex(end) == col_idx(end)-1 % two-end PC noise
                    for i = 1:length(startIndex)-1
                        newrow_idx2 = [newrow_idx2; row_idx(endIndex(i)+2:startIndex(i+1)+1)];
                        newcol_idx2 = [newcol_idx2; col_idx(endIndex(i)+2:startIndex(i+1)+1)];
                    end
                elseif startIndex(1) == 1 && endIndex(end) ~= col_idx(end)-1 % begin PC noise
                    if length(startIndex) == 1
                        newrow_idx2 = [newrow_idx2; row_idx(endIndex+2:end)];
                        newcol_idx2 = [newcol_idx2; col_idx(endIndex+2:end)];
                    else
                        for i = 1:length(startIndex)
                            if i == length(startIndex)
                                newrow_idx2 = [newrow_idx2; row_idx(endIndex(i)+2:end)];
                                newcol_idx2 = [newcol_idx2; col_idx(endIndex(i)+2:end)];
                            else
                                newrow_idx2 = [newrow_idx2; row_idx(endIndex(i)+2:startIndex(i+1))];
                                newcol_idx2 = [newcol_idx2; col_idx(endIndex(i)+2:startIndex(i+1))];
                            end
                        end
                    end
                elseif startIndex(1) ~= 1 && endIndex(end) == col_idx(end) % end PC noise
                    for i = 1:length(startIndex)-1
                        if i == 1
                            newrow_idx2 = [newrow_idx2; row_idx(1:startIndex(1))];
                            newcol_idx2 = [newcol_idx2; col_idx(1:startIndex(1))];
                        else
                            newrow_idx2 = [newrow_idx2; row_idx(endIndex(i)+2:startIndex(i+1))];
                            newcol_idx2 = [newcol_idx2; col_idx(endIndex(i)+2:startIndex(i+1))];
                        end
                    end
                end
            end
            newidx = sub2ind(size(newY3), newrow_idx2, newcol_idx2);
            newY3(newidx) = 100;
        end
        
        [xrow2, xcol2] = find(newY3 == 100);
        Txcol2 = T(xcol2);
        if strcmp(visu, 'on')
            figure('Name', 'Remove PC Noise');   
            scatter(Txcol2, F(xrow2)/1000, 'k.');
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Remove PC Noise');
        end
        
        % ---------- remove temporal discontinutity ---------- 
        newY4 = newY3;
        [row_idx2 col_idx2] = find(newY3 == 100);
        difcol2 = diff(col_idx2);
        discFidx = find(difcol2>1);
        regioni = 1;
        for edge = 1:length(discFidx)
            if length(discFidx) == 1
                sigregion1 = (1:discFidx);
                sigregion2 = (discFidx+1:length(col_idx2));
            else
                if edge == 1
                    sigregion1 = (1:discFidx(1));
                    sigregion2 = (discFidx(1)+1:discFidx(2));
                elseif edge == length(discFidx)
                    sigregion1 = (discFidx(edge-1)+1:discFidx(edge));
                    sigregion2 = (discFidx(edge)+1:length(col_idx2));
                else
                    sigregion1 = (discFidx(edge-1)+1:discFidx(edge));
                    sigregion2 = (discFidx(edge)+1:discFidx(edge+1));
                end
            end
            
            region{regioni} = sigregion1; regioni = regioni + 1;
            region{regioni} = sigregion2; regioni = regioni + 1;
        end
        
        if ~isempty(discFidx)
            [~, maxloc] = max(cellfun('length', region)); 
            ROS = region{maxloc};
            idx_maxY4 = sub2ind(size(newY4), row_idx2(ROS), col_idx2(ROS));
            newY4(idx_maxY4) = 200;
            newY4(newY4~=200) = 0;
            newY4(newY4==200) = 100;
        end
        [xrow3, xcol3] = find(newY4 == 100);
        Txcol3 = T(xcol3);
        if strcmp(visu, 'on')
            figure('Name', 'Remove Temporal Discontinuous Region');   
            scatter(Txcol3, F(xrow3)/1000, 'k.');
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Remove Temporal Discontinuous Region');
        end
        
        % ---------- remove frequency discontinutity ---------- 
        newY5 = newY;
        [row_idx3 col_idx3] = find(newY4 == 100);
        switch type
            case 'tril'
                Fthr = 1000;
            case 'phee'
                Fthr = 500;
            otherwise
                Fthr = 700;
        end
        F_colthr = floor(Fthr/F(2));
        difrow = diff(row_idx3);
        discidx = find(abs(difrow) >= F_colthr);
        discidx2 = discidx(discidx<length(row_idx3)/4);
        discidx3 = discidx(discidx>length(row_idx3)*3/4);

        if isempty(discidx2) % beginning
            startidx = 1;
        else
            if abs(row_idx3(1)-row_idx3(discidx2(end)+1)) < F_colthr
                startidx = 1;
            else
                startidx = discidx2(end)+1;
            end
        end

        if isempty(discidx3) % ending
            endidx = length(col_idx3);
        else
            if abs(row_idx3(end)-row_idx3(discidx3(1))) < F_colthr
                endidx = length(col_idx3);
            else
                endidx = discidx3(1)-1;
            end
        end

        idx_maxY5 = sub2ind(size(newY5), row_idx3(startidx:endidx), col_idx3(startidx:endidx));
        newY5(idx_maxY5) = 100;
        newY5(newY5~=100) = 0;
        [xrow4, xcol4] = find(newY5 == 100);
        Txcol4 = T(xcol4);
        if strcmp(visu, 'on')
            figure('Name', 'Remove Frequency Discontinuous Terminal');   
            scatter(Txcol4, F(xrow4)/1000, 'k.');
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Remove Frequency Discontinuous Terminal');
        end

        % ---------- smooth continuous points within the given range (narrowband calls) ---------- 
        newY6 = newY;
        [row_idx4 col_idx4] = find(newY5 == 100);
        Fthr = 500;
        F_colthr = floor(Fthr/F(2));
        for i = 1:length(row_idx4)-1
            range = [row_idx4(i)-F_colthr row_idx4(i)+F_colthr];
            nextpt = newY6(:, col_idx4(i+1));
            maxval = max(nextpt(range(1):range(2)));
            row_idx4(i+1) = find(nextpt == maxval);
        end

       if strcmp(type, 'phee') || strcmp(type,'trph')
           F_colthr2 = 3;
           cutidx = find(abs(diff(row_idx4))>=F_colthr2);
           cutidx2 = cutidx(cutidx >= length(row_idx4)*3/4);
           if isempty(cutidx2)
               idx_maxY6 = sub2ind(size(newY6), row_idx4, col_idx4);
           else
               idx_maxY6 = sub2ind(size(newY6), row_idx4(1:cutidx2(1)), col_idx4(1:cutidx2(1)));
           end
        else
           idx_maxY6 = sub2ind(size(newY6), row_idx4, col_idx4);
        end

        newY6(idx_maxY6) = 100;
        newY6(newY6~=100) = 0;
        [xrow5, xcol5] = find(newY6 == 100);
        Txcol5 = T(xcol5);
        if strcmp(visu, 'on')
            figure('Name', 'Smooth Continous Contour');   
            scatter(Txcol5, F(xrow5)/1000, 'k.');
            ylim([0 25]); xlim([0 Txcol(end)]); box on;
            xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
            ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
            set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
            title('Smooth Continous Contour');
        end
        
        % ---------- plot Phee main features (Max Min Dom) ---------
        if strcmp(type, 'phee')
            [~, maxDot] = max(xrow5);
            [~, minDot] = min(xrow5);
            [~, maxrow] = max(newY(xrow5(minDot):xrow5(maxDot), :));
            [~, domDot] = max(maxrow);
            if strcmp(visu, 'on')
                figure('Name', 'Measure Feature');   
                scatter(Txcol5, F(xrow5)/1000, 'k.'); hold on;
                scatter(T(xcol5(maxDot)), F(xrow5(maxDot))/1000, 'b*'); hold on;
                scatter(T(xcol5(minDot)), F(xrow5(minDot))/1000, 'r*'); hold on;
                scatter(T(xcol5(maxrow(domDot))), F(xrow5(maxrow(domDot)))/1000, 'm'); hold on;
                h1 = scatter(T(xcol5(maxDot)), F(xrow5(maxDot))/1000, 'b*');
                h2 = scatter(T(xcol5(minDot)), F(xrow5(minDot))/1000, 'r*');
                h3 = scatter(T(xcol5(maxrow(domDot))), F(xrow5(maxrow(domDot)))/1000, 'm');
                legend([h1 h2 h3], 'Max', 'Min', 'Dominant');
                ylim([0 25]); xlim([0 Txcol(end)]); box on;
                xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
                ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
                set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
                title('Measure Feature');
            end
        end
        
        % ---------- plot Tril main features (Max Min Peak Trough) ---------
        if strcmp(type, 'tril')
            
            [~, maxDot] = max(xrow5);
            [~, minDot] = min(xrow5);
            [~, maxrow] = max(newY(xrow5(minDot):xrow5(maxDot), :));
            [~, domDot] = max(maxrow);
            if ~isempty(xrow5)
                [peaksrow, peaksloc] = findpeaks(smooth(F(xrow5)));
                [troughsrow, troughsloc] = findpeaks(-smooth(F(xrow5)));
            else
                peaksloc = [];
                troughsloc = [];
            end
            
            if ~isempty(peaksloc)
                peak(1,:) = Txcol5(peaksloc);
                peak(2,:) = peaksrow/1000;
            else
                peak = [];
            end
           
            if ~isempty(troughsloc)
                trough(1,:) = Txcol5(troughsloc);
                trough(2,:) = -troughsrow/1000;
            else
                trough = [];
            end
            if strcmp(visu, 'on')
                figure('Name', 'Measure Feature');   
                scatter(Txcol5, F(xrow5)/1000, 'k.'); hold on;
                scatter(T(xcol5(maxDot)), F(xrow5(maxDot))/1000, 'm'); hold on;
                scatter(T(xcol5(minDot)), F(xrow5(minDot))/1000, 'r'); hold on;
                scatter(peak(1, :), peak(2,:), 'b*'); hold on;
                scatter(trough(1, :), trough(2,:), 36,  [0,127/256,0], '*'); hold on;
                h1 = scatter(T(xcol5(maxDot)), F(xrow5(maxDot))/1000, 'm');
                h2 = scatter(T(xcol5(minDot)), F(xrow5(minDot))/1000, 'r');
                h3 = scatter(peak(1, :), peak(2,:), 'b*');
                h4 = scatter(trough(1, :), trough(2,:), 36,  [0,127/256,0], '*');
                legend([h1 h2 h3 h4], 'Max', 'Min', 'Peak', 'Trough');
                ylim([3 10]); xlim([0 Txcol(end)]); box on;
                xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
                ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
                set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
                title('Measure Feature');
            end
        end
        
        % ---------- plot Trilphee main features (Peak Trough Trans) ---------
        if strcmp(type, 'trph')
            [~, maxDot] = max(xrow5);
            [~, minDot] = min(xrow5);
            [~, maxrow] = max(newY(xrow5(minDot):xrow5(maxDot), :));
            [~, domDot] = max(maxrow);
            ptransloc = []; ttransloc = [];
            [peaksrow, peaksloc] = findpeaks(smooth(F(xrow5)));
            if ~isempty(peaksloc)
                peak(1,:) = Txcol5(peaksloc);
                peak(2,:) = peaksrow/1000;
                for peakidx = 1:length(peaksloc)
                   psameidx(peakidx) = find(xrow5(peaksloc(peakidx)+1:end) ~= xrow5(peaksloc(peakidx)), 1, 'first');
                end
                ptransloc = find(psameidx>=10, 1, 'first');
                if isempty(ptransloc)
                    ptransloc = find(diff(peak(1,:))> 0.1, 1, 'first');
                end
            else
                peak = [];
            end
            [troughsrow, troughsloc] = findpeaks(-smooth(F(xrow5)));
            if ~isempty(troughsloc)
                trough(1,:) = Txcol5(troughsloc);
                trough(2,:) = -troughsrow/1000;
                for troughidx = 1:length(troughsloc)
                   tsameidx(troughidx) = find(xrow5(troughsloc(troughidx)+1:end) ~= xrow5(troughsloc(troughidx)), 1, 'first');
                end
                ttransloc = find(tsameidx>=10, 1, 'first');
                if isempty(ttransloc)
                    ttransloc = find(diff(trough(1,:))> 0.1, 1, 'first');
                end
            else
                trough = [];
            end
            
            if ~isempty(ptransloc) && ~isempty(ttransloc)
                if ptransloc < ttransloc
                    trans(1) = peak(1, ptransloc);
                    trans(2) = peak(2, ptransloc);
                elseif ptransloc > ttransloc
                    trans(1) = trough(1, ttransloc);
                    trans(2) = trough(2, ttransloc);
                else
                    if psameidx(ptransloc) >= tsameidx(ttransloc)
                        trans(1) = peak(1, ptransloc);
                        trans(2) = peak(2, ptransloc);
                    else
                        trans(1) = trough(1, ttransloc);
                        trans(2) = trough(2, ttransloc);
                    end
                end
            elseif ~isempty(ptransloc)
                trans(1) = peak(1, ptransloc);
                trans(2) = peak(2, ptransloc);
            elseif ~isempty(ttransloc)
                trans(1) = trough(1, ttransloc);
                trans(2) = trough(2, ttransloc);
            else
                trans = [];
            end
            
            if strcmp(visu, 'on')
                figure('Name', 'Measure Feature');   
                scatter(Txcol5, F(xrow5)/1000, 'k.'); hold on;
                scatter(T(xcol5(maxDot)), F(xrow5(maxDot))/1000, 'm'); hold on;
                scatter(T(xcol5(minDot)), F(xrow5(minDot))/1000, 'r'); hold on;
                scatter(trans(1), trans(2), 36, [0.6 0.2 0]); hold on;
                scatter(peak(1, :), peak(2,:), 'b*'); hold on;
                scatter(trough(1, :), trough(2,:), 36,  [0,127/256,0], '*'); hold on;
                h1 = scatter(T(xcol5(maxDot)), F(xrow5(maxDot))/1000, 'm');
                h2 = scatter(T(xcol5(minDot)), F(xrow5(minDot))/1000, 'r');
                h3 = scatter(trans(1), trans(2), 36, [0.6 0.2 0]);
                h4 = scatter(peak(1, :), peak(2,:), 'b*');
                h5 = scatter(trough(1, :), trough(2,:), 36,  [0,127/256,0], '*');
                legend([h1 h2 h3 h4 h5], 'Max', 'Min', 'Trans', 'Peak', 'Trough');
                ylim([6 13]); xlim([0 Txcol(end)]); box on;
                xlabel('Time (sec)','FontSize',12, 'FontWeight','bold', 'FontName','calibri'); 
                ylabel('Frequency (kHz)', 'FontSize',12, 'FontWeight','bold', 'FontName','calibri');
                set(gca,'FontSize',12,'FontWeight','bold','linewidth',2);
                title('Measure Feature');
            end
        end
        
    % =================================================================
end

%% Measure Feature
switch type
    case 'twit'
        if ~isempty(trough_idx2)
            feature.nphr = length(trough_idx2); 
            feature.IPI = trimmean(diff(T(domcol)), 20);
            feature.dur = T(starcol(end)) - T(col_idx3(trough_idx2(1)));
            feature.fmax_b = F(starrow(1))/1000;
            feature.fdom_b = F(domrow(1))/1000;
            feature.fmin_b = F(row_idx3(trough_idx2(1)))/1000;
            feature.fbw_b = feature.fmax_b - feature.fmin_b;
            feature.tphr_b = abs(T(starcol(1)) - T(col_idx3(trough_idx2(1))));
            feature.tknee_b = abs((T(col_idx3(knee(1))) - T(col_idx3(trough_idx2(1))))/feature.tphr_b);
            feature.fknee_b = abs((F(row_idx3(knee(1)))/1000 - feature.fmin_b)/feature.fbw_b);
            feature.fmax_m = mean(F(starrow(2:end-1))/1000);
            feature.fdom_m = mean(F(domrow(2:end-1))/1000);
            feature.fmin_m = trimmean(F(row_idx3(trough_idx2(2:end-1)))/1000, 20);
            feature.fbw_m = abs(trimmean(F(starrow(2:end-1))/1000 - F(row_idx3(trough_idx2(2:end-1)))/1000, 20));
            feature.tphr_m = abs(trimmean(T(starcol(2:end-1)) - T(col_idx3(trough_idx2(2:end-1))), 20));
            feature.tknee_m = abs(mean((T(col_idx3(knee(2:end-1))) - T(col_idx3(trough_idx2(2:end-1))))./...
                    (T(starcol(2:end-1)) - T(col_idx3(trough_idx2(2:end-1))))));
            feature.fknee_m = abs(mean((F(row_idx3(knee(2:end-1)))/1000 - F(row_idx3(trough_idx2(2:end-1)))/1000)./...
                    (F(starrow(2:end-1))/1000 - F(row_idx3(trough_idx2(2:end-1)))/1000)));
            feature.fmax_e = F(starrow(end))/1000;
            feature.fdom_e = F(domrow(end))/1000;
            feature.fmin_e = F(row_idx3(trough_idx2(end)))/1000;
            feature.fbw_e = feature.fmax_e - feature.fmin_e;
            feature.tphr_e = abs(T(starcol(end)) - T(col_idx3(trough_idx2(end))));
            feature.tknee_e = abs((T(col_idx3(knee(end))) - T(col_idx3(trough_idx2(end))))/feature.tphr_e);
            feature.fknee_e = abs((F(row_idx3(knee(end)))/1000 - feature.fmin_e)/feature.fbw_e);
            if feature.nphr <= 2, feature = []; end 
            if feature.IPI > 0.19, feature = []; end
            if feature.tphr_b > 0.1 || feature.tphr_b < 0.005, feature = []; end
            if feature.tphr_m > 0.2 || feature.tphr_m < 0.005, feature = []; end
            if feature.tphr_e > 0.065 || feature.tphr_e < 0.005, feature = []; end
            if feature.fmin_m > 10 || feature.fmin_e > 10, feature = []; end
            if feature.fmax_b < 5 || feature.fmax_m < 5, feature = []; end 
            if feature.fbw_b <= 0 || feature.fbw_m < 0.5 || feature.fbw_e <= 0, feature = []; end 
            if feature.tknee_m >= 1 || feature.tknee_m == 0, feature = []; end
            if feature.fknee_m >= 1 || feature.fknee_m == 0, feature = []; end
            if feature.tknee_b >= 1, feature = []; end
            if feature.tknee_e >= 1, feature = []; end
            if feature.fknee_b >= 1, feature = []; end
            if feature.fknee_e >= 1, feature = []; end
            if feature.tknee_b == Inf || isnan(feature.tknee_b), feature = []; end 
            if feature.tknee_m == Inf || isnan(feature.tknee_m), feature = []; end
            if feature.tknee_e == Inf || isnan(feature.tknee_e), feature = []; end
            if feature.fknee_b == Inf || isnan(feature.fknee_b), feature = []; end
            if feature.fknee_m == Inf || isnan(feature.fknee_m), feature = []; end
            if feature.fknee_e == Inf || isnan(feature.fknee_e), feature = []; end
        else
            feature = [];
        end
        
    case 'phee'
        if ~isempty(xcol5)
            feature.dur = T(xcol5(end)) - T(xcol5(1));
            feature.fmax = F(xrow5(maxDot))/1000;
            feature.fmin = F(xrow5(minDot))/1000;
            feature.fc = (feature.fmax + feature.fmin)/2;
            feature.fdom = F(xrow5(maxrow(domDot)))/1000;
            feature.fstart = F(xrow5(1))/1000;
            feature.fend = F(xrow5(end))/1000;
            feature.tfmax = T(xcol5(maxDot))- T(xcol5(1));
            feature.tfmin = T(xcol5(minDot))- T(xcol5(1));
            if feature.dur < 0.1, feature = []; end
            if feature.fmin < 4, feature = []; end
            if feature.fdom < 4, feature = []; end
            if feature.fmax >= 11, feature = []; end
        else
            feature = [];
        end
                
    case 'tril'
        if ~isempty(xcol5) && ~(xrow5(1) == 66 && isempty(xrow5(diff(xrow5)>0)))
            feature.dur = T(xcol5(end)) - T(xcol5(1));
            feature.fmax = F(xrow5(maxDot))/1000;
            feature.fmin = F(xrow5(minDot))/1000;
            feature.fc = (feature.fmax + feature.fmin)/2;
            feature.fdom = F(xrow5(maxrow(domDot)))/1000;
            feature.fstart = F(xrow5(1))/1000;
            feature.fend = F(xrow5(end))/1000;
            feature.tfmax = T(xcol5(maxDot))- T(xcol5(1));
            feature.tfmin = T(xcol5(minDot))- T(xcol5(1));
            if ~(isempty(peak) || isempty(trough))
                newpeak = peak(:, 1:min(size(peak, 2), size(trough, 2)));
                newtrough = trough(:, 1:min(size(peak, 2), size(trough, 2)));
                feature.FMdepth_max = max(abs(newpeak(2,:)-newtrough(2,:)));
                feature.FMdepth_min = min(abs(newpeak(2,:)-newtrough(2,:)));
                feature.FMdepth = trimmean(abs(newpeak(2,:)-newtrough(2,:)), 20);
                feature.FMrate = trimmean(1./abs(diff(newpeak(1,:))), 20);
                if isnan(feature.FMrate) || feature.FMrate > 60, feature = []; end
                if feature.FMdepth_min == 0, feature = []; end
            end
            if feature.dur > 1 || feature.dur < 0.05, feature = []; end
            if feature.fmin < 4, feature = []; end
            if feature.fdom < 4, feature = []; end
            if feature.fmax >= 10.5, feature = []; end
        else
            feature = [];
        end
          
        
    case 'trph'
        if ~isempty(xcol5)
            feature.dur = T(xcol5(end)) - T(xcol5(1));
            feature.fmax = F(xrow5(maxDot))/1000;
            feature.fmin = F(xrow5(minDot))/1000;
            feature.fc = (feature.fmax + feature.fmin)/2;
            feature.fdom = F(xrow5(maxrow(domDot)))/1000;
            feature.fstart = F(xrow5(1))/1000;
            feature.fend = F(xrow5(end))/1000;
            feature.tfmax = T(xcol5(maxDot))- T(xcol5(1));
            feature.tfmin = T(xcol5(minDot))- T(xcol5(1));
            if ~(isempty(peak) || isempty(trough) || isempty(trans))
                newpeak = peak(:, 1:min(length(peak), length(trough)));
                newtrough = trough(:, 1:min(length(peak), length(trough)));
                feature.FMdepth_max = max(abs(newpeak(2,:)-newtrough(2,:)));
                feature.FMdepth_min = min(abs(newpeak(2,:)-newtrough(2,:)));
                feature.FMdepth = trimmean(abs(newpeak(2,:)-newtrough(2,:)), 20);
                feature.FMrate = trimmean(1./abs(diff(newpeak(1,:))), 20);
                feature.tTrans = (trans(1)-T(xcol5(1)))/feature.dur;
                if isnan(feature.FMrate) || feature.FMrate > 70, feature = []; end
                if feature.tTrans >= 1 || feature.tTrans <= 0, feature = []; end
            else
                feature = [];
            end
            if feature.dur < 0.1, feature = []; end
            if feature.fmin < 4, feature = []; end
            if feature.fdom < 4, feature = []; end 
        else
            feature = [];
        end
        
end