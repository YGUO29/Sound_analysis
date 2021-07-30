% plot figures given F
% mode: cochleogram, temp, spec, spectemp
function plotF(F, mode, iSound)
    switch mode
        case 'cochleogram'
            imagesc(F.CochEnv_ds_log{iSound})
            axis('xy'), colorbar
            set(gca, 'FontSize', 20);
            freqs   = floor([440*2.^([0:5]), max(F.cf_log)]./10).*10; % the index of 10
            fticks  = floor(interp1(F.cf_log, 1:1:length(F.cf_log), freqs));
            set(gca,'ytick',fticks)
            set(gca,'yticklabels',arrayfun(@num2str,freqs./1000,'UniformOutput',false))
        
            ts      = [0.5,1,1.5];
            ticks  = floor(interp1(F.t_ds{iSound}, 1:1:length(F.t_ds{iSound}), ts));
            if isfield(F, 'sound_names')
                title(['Cochleagram_',F.sound_names{iSound}], 'interpreter', 'none');
            end
        case 'temp'
            imagesc(F.temp_mod(:,:,iSound)'), axis('xy'), colorbar
            temp_mod_rates_without_DC = F.temp_mod_rates(F.temp_mod_rates>0);
            freqs_to_plot = [400 800 1600 3200 6400];
            fticks = floor(interp1(F.cf_log, 1:1:length(F.cf_log), freqs_to_plot));
            set(gca, 'YTick', fticks, 'YTickLabel', (freqs_to_plot)/1000);
            set(gca, 'XTick', [2,4,6,8], 'XTickLabel', round(temp_mod_rates_without_DC([2,4,6,8])))
            set(gca, 'FontSize', 20);
            ylabel('Audio frequency (kHz)');
            xlabel('Rate (Hz)')
            if isfield(F, 'sound_names')
                title(['TempMod_',F.sound_names{iSound}], 'interpreter', 'none');
            end
        case 'spec'
            imagesc(F.spec_mod(:,:,iSound)'), axis('xy'), colorbar 
            freqs_to_plot = [400 800 1600 3200 6400];
            fticks = floor(interp1(F.cf_log, 1:1:length(F.cf_log), freqs_to_plot));
            set(gca, 'YTick', fticks, 'YTickLabel', (freqs_to_plot)/1000);
            set(gca, 'XTick', [2,4,6], 'XTickLabel', F.spec_mod_rates([2,4,6]))
            set(gca, 'FontSize', 20);
            ylabel('Audio frequency (kHz)');
            xlabel('Scale (cyc/oct)');
            if isfield(F, 'sound_names')
                title(['SpecMod_',F.sound_names{iSound}], 'interpreter', 'none');
            end
        case 'spectemp'
            imagesc(flipud(F.spectemp_mod_full(:,:,iSound))); colorbar
            spec_mod_rates_flip = fliplr(F.spec_mod_rates);
            temp_mod_rates_neg_pos = [-fliplr(F.temp_mod_rates(F.temp_mod_rates>0)), F.temp_mod_rates(F.temp_mod_rates>0)];
            set(gca, 'YTick', [1, 3, 5], 'YTickLabel', spec_mod_rates_flip([1 3 5]));
            set(gca, 'XTick', [3, 7, 12, 16], 'XTickLabel', temp_mod_rates_neg_pos([3, 7, 12, 16]))
            set(gca, 'FontSize', 20);
            ylabel('Spectral scale (cyc/oct)');
            xlabel('Temporal rate (Hz)');     
            if isfield(F, 'sound_names')
                title(['SpecTempMod_',F.sound_names{iSound}], 'interpreter', 'none');
            end
        otherwise
    end
    
end