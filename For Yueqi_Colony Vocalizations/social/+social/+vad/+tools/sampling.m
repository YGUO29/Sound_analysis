function [ B ] = sampling( A, m, n )
%SAMPLING Summary of this function goes here
%   Detailed explanation goes here
if iscell(A)
    B = cell(length(A),1);
    [M, N] = size(A{1});
    M1 = floor(M/m);
    N1 = floor(N/n);
    Ads = zeros(M1,N1);
    for k = 1 : length(A)
        B{k} = zeros(M1,N1);
        Ads = zeros(M1,N1);
        for i = 1 : m
            for j = 1 : n
                Ads = Ads + A{k}(i:m:m*(M1-1)+i,j:n:n*(N1-1)+j);
            end
        end
        B{k} = Ads/(m*n);
        B{k} = medfilt2(B{k},[3,3]);
    end
else
    [M, N] = size(A);
    M1 = floor(M/m);
    N1 = floor(N/n);
    Ads = zeros(M1,N1);
    for i = 1 : m
        for j = 1 : n
            Ads = Ads + A(i:m:m*(M1-1)+i,j:n:n*(N1-1)+j);
        end
    end
    B = Ads/(m*n);
%     B = medfilt2(B, [3,3]);
end

end
