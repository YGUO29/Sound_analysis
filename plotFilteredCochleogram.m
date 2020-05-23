function plotFilteredCochleogram(coch_orig, ...
    P, output_directory, fname_without_extension)

%% 2DFT of original and synthetic cochleogram
coch_orig = F.CochEnv_ds_log(:,:,83);
FT_padded_coch_orig = fft2(pad_coch(coch_orig, P));
[nT,nF] = size(FT_padded_coch_orig);

spec_mod_to_plot = select_mod_rates(P.spec_mod_rates);
temp_mod_to_plot = select_mod_rates(P.temp_mod_rates);
filtcoch_orig_group = [];
for i = 1:length(spec_mod_to_plot)
    for j = 1:length(temp_mod_to_plot)
        
        % transfer function of spectrotemporal filter
        Hts = filt_spectemp_mod(...
            spec_mod_to_plot(i), temp_mod_to_plot(j), nF, nT, P);
                                
        % apply transfer function
        filtcoch_padded_orig = real(ifft2(FT_padded_coch_orig .* Hts));
        filtcoch_orig = remove_pad(filtcoch_padded_orig, P);
                        
        % select subplot
        n_row = length(spec_mod_to_plot);
        n_col = length(temp_mod_to_plot);
        subplot_index = sub2ind([n_col, n_row], j, i);
%         subplot(n_row, n_col, subplot_index);
        filtcoch_orig_group(:,:,subplot_index) = filtcoch_orig;
    end
end
figure;
set(gcf, 'Position', [0 0 1200 800]);
for i = 1:length(spec_mod_to_plot)
    for j = 1:length(temp_mod_to_plot)
                % transfer function of spectrotemporal filter
        Hts = filt_spectemp_mod(...
        spec_mod_to_plot(i), temp_mod_to_plot(j), nF, nT, P);
                                
        % apply transfer function
        filtcoch_padded_orig = real(ifft2(FT_padded_coch_orig .* Hts));
        filtcoch_orig = remove_pad(filtcoch_padded_orig, P);
                        
        % select subplot
        n_row = length(spec_mod_to_plot);
        n_col = length(temp_mod_to_plot);
        subplot_index = sub2ind([n_col, n_row], j, i);
        subplot(n_row, n_col, subplot_index);
        
        % plot
        imagesc(P.t, P.f, filtcoch_orig);
%         plot_cochleogram(filtcoch_orig, P.f, P.t);
        set(gca, 'FontSize', 6);, colorbar
        drawnow;
        clear X;

        % set color bound
        caxis([min(filtcoch_orig_group(:)), max(filtcoch_orig_group(:))]);
        colormap(cbrewer('div','RdBu',256));
        clear X;

        % title
        % if there is no spectral modulation just plot temporal rate
        if isnan(spec_mod_to_plot(i))
            title(sprintf([...
                'orig, \n' ...
                num2str(temp_mod_to_plot(j)) ' Hz']));
        else
            title(sprintf([...
                'orig , \n' ...
                num2str(spec_mod_to_plot(i)) ' cyc/oct, '...
                num2str(temp_mod_to_plot(j)) ' Hz']));
        end

    end
end

%% save
fig_fname = [output_directory '/' fname_without_extension '_filt_coch'];
set(gcf, 'PaperSize', [11 8]);
set(gcf, 'PaperPosition', [0.25 0.25 10.5 7.5]);
print([fig_fname '.pdf'],'-dpdf');
print([fig_fname '.png'],'-dpng','-r200');

function mod_rates = select_mod_rates(mod_rates)

mod_rates = mod_rates(mod_rates>0);
% n_mod_rates = length(mod_rates);
% mod_rates = mod_rates([1 round(n_mod_rates/2), end]);

