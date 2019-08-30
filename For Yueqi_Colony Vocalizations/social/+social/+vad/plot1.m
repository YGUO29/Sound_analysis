subplot(3,1,1);
[spec,x,y] = social.util.spectra(y_temp1, 500, 50, 50000, 'log', 'gausswin', 1);
set(gca,'xtick',[]);
subplot(3,1,2);
plot(p1(:,2));
title('Probability of each frame to be a call frame');
xlabel('frame number');
ylabel('probability');
xlim([0,7200]);
% set(gca,'xtick',[]);

subplot(3,1,3);
plot(label1);
title('Label of frames');
xlabel('frame number');
ylabel('label');
axis = gca;
axis.YTick = [0 1];
axis.YTickLabel = {'noise','call'};
axis.XLim = ([0,7200]);
% set(gca,'xtick',[]);

%%
figure,
subplot(3,1,1);
imagesc(spec_out.spec{1}(end:-1:1,:));
 set(gca,'xtick',[]);
 set(gca,'ytick',[]);
 ylabel('parabolic mic');
 xlabel('time');
 colorbar;
subplot(3,1,2);
imagesc(spec_out.spec{2}(end:-1:1,:));
 set(gca,'xtick',[]);
 set(gca,'ytick',[]);
 xlabel('time');
 ylabel('reference mic');
 colorbar;
subplot(3,1,3);
imagesc(spec_out.spec_diff(end:-1:1,:));
 set(gca,'xtick',[]);
 set(gca,'ytick',[]);
 ylabel('subtraction')
 xlabel('time');
 colorbar;
