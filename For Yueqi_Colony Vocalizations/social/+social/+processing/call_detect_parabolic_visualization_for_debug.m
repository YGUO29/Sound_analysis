% Visualize results for debug
                figure(200)
                h1 = subplot(3,1,1);
                cla
                imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec{1});
                axis xy
                colorbar
        
                h2 = subplot(3,1,2);
                cla
                imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec_diff);
                xx_range = get(gca,'XLim');
                yy_range = get(gca,'YLim');
                axis xy
                colorbar
                h3 = subplot(3,1,3);
                cla
                hold on
                imagesc(N1/Fs+[0:size(spec_diff,2)-1]*shift_time,[0:size(spec_diff,1)-1]*Fs/winsize,spec_diff_bin);
                axis([xx_range,yy_range]);
                axis xy
                colorbar
                colormap gray
        
                for jj = 1:length(t_start_chunk{ci})
                    plot([1 1]*t_start_chunk{ci}(jj),[0 Fs/2],'r');
                    plot([1 1]*t_stop_chunk{ci}(jj),[0 Fs/2],'r');
                end
                linkaxes([h1 h2 h3],'xy')
                figure(200)
                delete(200)