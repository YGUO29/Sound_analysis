% get other features from cochleagram
n = size(F.CochEnv_ds_log{1},1) * size(F.CochEnv_ds_log{1},2);
m = length(F.CochEnv_ds_log);
D = zeros(n, m);
for i = 1:m
    D(:,i) = reshape(F.CochEnv_ds_log{i}, n, 1);
end

%% PCA
[U, S, V] = svd(D,'econ');
%%
close all
figurex;
for i = 1:16
    subplot(2,8,i)
    pc = i;
    imagesc(reshape(U(:,pc), size(F.CochEnv_ds_log{1},1), size(F.CochEnv_ds_log{1},2)));
    axis square
    axis('xy')
end

