
%%

param = social.vad.tools.Param();
titles = {'energyDiff','energyPar','energyDiffWireless','energyParWireless','AHR'};
call_dist = [];
noise_dist = [];
data = [];
label = [];

callsAll = calls{1};
for i = 2 : 8
callsAll = [callsAll, calls{i}];
end
for iType = 1 : length(calls)-1
    if isempty(calls{iType})
        continue;
    end
% iType = 6;
    data_temp = zeros(length(calls{1,iType}),5);
    data_temp(:,1) = [calls{1,iType}.energyDiff]';
    data_temp(:,2) = [calls{1,iType}.energyPar]';
    data_temp(:,3) = [calls{1,iType}.energyDiffWireless]';
    data_temp(:,4) = [calls{1,iType}.energyParWireless]';
    data_temp(:,5) = [calls{1,iType}.AHR]';
    label_temp = [calls{1,iType}.flag]';
    if (iType == 4)
        for ii = 1 : length(data_temp)
            if data_temp(ii,2) > 15
                data_temp(ii,1:4) = data_temp(ii,1:4) * 15 / data_temp(ii,2);
            end
        end
    end
    data = [data;data_temp];
    label = [label;label_temp];
end

result = [];
% for value1 = 0.5:0.1:1.5
kk_label = 0:0.1:10;
for kk = 0:0.1:10
%     param.scoreThresholdWireless(1) = value1;
%     param.scoreThresholdWireless(3) = value2;
%     param.scoreThresholdWireless(2) = 0.2;
%     param.scoreThresholdWireless(3) = 0.06;
%     kk = 1;
    for i = 1 : length(label)
        diff = data(i,1);
        diffWireless = data(i,3);
        parEnergyWireless = data(i,4);
        AHR = data(i,5);

        xx = diff-param.difEnergyThresholdLB;
        if xx < 0
            xx = xx * kk;
        end
        data(i,6) = log2(1+2^xx);
        
        xx = min(3,abs(diffWireless) - param.difEnergyThresholdWireless);
        if xx < 0
            xx = xx * kk;
        end        
        data(i,7) = log2(1+2^xx);
        
        xx = min(2.5,parEnergyWireless - param.parEnergyThresholdWireless);
        if xx < 0
            xx = xx * kk;
        end
        data(i,8) = log2(1+2^xx);
        
%         data(i,9) = 1/(1+exp(-(AHR-(param.AHRThresholdLB+param.AHRThresholdUB)/2)));
        data(i,9) = 1/(1+exp(-(AHR-param.AHRThresholdUB)));
        data(i,10) = prod(data(i,6:9),2);
        % wireless session
        if (data(i,10) >= param.scoreThresholdWireless(1))
            data(i,11) = 0;
        elseif (data(i,6) > param.scoreThresholdWireless(1)) &&...
                (data(i,7)*data(i,8) >= param.scoreThresholdWireless(3)) &&... 
                (data(i,9)>0.5)
            data(i,11) = 1;
        elseif (data(i,7)*data(i,8) > param.scoreThresholdWireless(1)) &&... 
                (data(i,6) >= param.scoreThresholdWireless(2)) &&...  
                (data(i,9)>0.5)
            data(i,11) = 2;
        else
            data(i,11) = -1;
        end
        if (data(i,4) - abs(data(i,3)) < 0) && (data(i,4) < 1.5)
            data(i,11) = -1;
        end
%         % par-ref session
%         data(i,10) = data(i,6) * data(i,9);
%         scoreThresholdParRef = kkk;
%         if data(i,10) >= scoreThresholdParRef
%             data(i,11) = 0;
%         else 
%             data(i,11) = -1;
%         end
    end
    data(label==1,12) = 0;
    data(label==0,12) = -1;
    
    falsealarmFeature = [];
    falsealarmCalls = [];
    hitFeature = [];
    hitCalls = [];
    missFeature = [];
    missCalls = [];
    misscount = 0;
    hitcount = 0;
    falsealarmcount = 0;
    falsealarmcount1 = 0;
    call_dist = [];
    noise_dist = [];

    
    for i = 1 : length(label)
        if (data(i,end) >= 0) && (data(i,end-1) >= 0)
            hitcount = hitcount + 1;
%             hitFeature = [hitFeature; data(i,:)];
%             hitCalls = [hitCalls; callsAll(i)];
        end
        if (data(i,end) < 0) && (data(i,end-1) == 0)
            falsealarmcount = falsealarmcount + 1;
%             falsealarmFeature = [falsealarmFeature; data(i,:)];
%             falsealarmCalls = [falsealarmCalls; callsAll(i)];
        end
        if (data(i,end) < 0) && (data(i,end-1) >= 0)
            falsealarmcount1 = falsealarmcount1 + 1;
            falsealarmFeature = [falsealarmFeature; data(i,:)];
            falsealarmCalls = [falsealarmCalls; callsAll(i)];
        end        
        if (data(i,end) >= 0) && (data(i,end-1) < 0)
            misscount = misscount + 1;
            missFeature = [missFeature; data(i,:)];
            missCalls = [missCalls; callsAll(i)];
        end
        if (data(i,end) == -1)
            noise_dist = [noise_dist;data(i,:)];
        else
            call_dist = [call_dist;data(i,:)];
        end
    end
    target_num = sum(data(:,end) == 0);
    nontarget_num = length(data)-target_num;
    hitingrate = hitcount / sum(data(:,end)>=0);
    falsealarm = falsealarmcount / sum(data(:,end-1)==0);
    falsealarm1 = falsealarmcount1 / sum(data(:,end-1)>=0);
    result = [result; hitingrate, falsealarm, falsealarm1, param.scoreThresholdWireless(2), param.scoreThresholdWireless(3)];
% end
end


% result(:,1) = result(:,1) + 0.06;
% result(:,3) = result(:,2);

X = result(:,3);
Y = result(:,1);
% X = smooth(X,5);
% Y = result(:,1) - 0.1;
% Y = (Y.*(1-X) + X);

% plot(X,Y,'b');
% p = polyfit(X,Y,2);
% Y = polyval(p,X);
% plot(X,Y,'g');
Y = smooth(Y,5);
plot(X,Y,'g');
axis = gca;
set(axis, 'XLim', [0,1]);
set(axis, 'YLim', [0,1]);
xlabel('false alarm rate');
ylabel('hit rate');
% legend({'measured','fitted'},'Location','NorthEast');
% calculate AUC
AUC = 0;
for i = 2 : length(result)
    AUC = Y(i)*(X(i-1)-X(i)) + AUC;
end
AUC = Y(1) * (1-X(1))+AUC;
AUC

hold on
kk_index = [1, 6, 11, 15, 21, 26, 36, 61, 101];
plot(X(kk_index),Y(kk_index),'or');
for i = 1 : length(kk_index)
    text(X(kk_index(i))+0.003, Y(kk_index(i))-0.01, num2str(kk_label(kk_index(i))))
end

% call_dist(:,3) = abs(call_dist(:,3));
% noise_dist(:,3) = abs(noise_dist(:,3));
% data_dist = cell(5,2);
% for k = 1 : 5
%     figure
% %     [f, xi] = ksdensity(call_dist(:,k),'function','pdf','bandwidth',0.3);
%     [f, xi] = ksdensity(call_dist(:,k),'function','pdf');
%     data_dist{k,1} = [xi; f];
%     plot(xi, f,'r');
% %     [f, xi] = ksdensity(noise_dist(:,k),'function','pdf','bandwidth',0.3);
%     [f, xi] = ksdensity(noise_dist(:,k),'function','pdf');
%     data_dist{k,2} = [xi; f];
%     hold on, plot(xi, f,'b');
%     title(titles{k});
% end
% 
% figure,
% plot(call_dist(:,k),1,'*r');
% hold on,
% plot(noise_dist(:,k),2,'*b');

%%
%{
subplot(2,3,1);
imagesc(parCallSpe(end:-1:1,startP:stopP))
title('parabolic spectra');

subplot(2,3,2);
imagesc(refCallSpe(end:-1:1,startP:stopP))
title('reference spectra');

subplot(2,3,3);
imagesc(oneCallSpe(end:-1:1,startP:stopP))
title('enhanced diff-spectra');

subplot(2,3,4);
imagesc(oneSig(end:-1:1,:));
title('weight map');

subplot(2,3,5);
im = parCallSpe(end:-1:1,startP:stopP) .* oneSig(end:-1:1,:);
im = (im - min(min(im)))./(max(max(im)) - min(min(im)));
imagesc(im);
title('weighted parabolic spectra');

subplot(2,3,6);
im = refCallSpe(end:-1:1,startP:stopP) .* oneSig(end:-1:1,:);
im = (im - min(min(im)))./(max(max(im)) - min(min(im)));
imagesc(im);
title('weighted reference spectra');
%%

    for iType = 1 : length(param.CALL_TYPE)
        for iCall = 1 : length(call_seg_temp{iType})
            numCalls = numCalls + 1;
            calls(numCalls) = social.vad.my_call(   'session',      session,...
                                                    'startTime',    call_seg_temp{iType}(iCall).beginTime,...
                                                    'stopTime',     call_seg_temp{iType}(iCall).endTime,...
                                                    'channel',      call_seg_temp{iType}(iCall).parChannel,...
                                                    'sig',          call_seg_temp{iType}(iCall).parData{1},...
                                                    'callType',     param.CALL_TYPE{iType}{1}...
                                                    );
%             spec = calls(numCalls).get_spec();
            calls(numCalls).get_fundamental();
        end
    end
%%
subplot(4,1,1),imagesc(oneCut(end:-1:1,:));
% title([num2str(indStartTemp(iEvent)*0.006),'--',num2str(indStopTemp(iEvent)*0.006)]);
title('spectra');
subplot(4,1,2),plot(m);
title('amplitude');
subplot(4,1,3),plot(v);
title('variance');
subplot(4,1,4),plot(vm);
title('ratio');
%}