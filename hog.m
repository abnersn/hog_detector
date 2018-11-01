function [ hist ] = hog( I, patch_size, bins, norm_kernel )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%% C�lculo do gradiente
[M, P] = gradient(I);

%%% C�lculo dos histogramas
hist = histograms(M, P, patch_size, bins);

%%% Normaliza��o dos histogramas
hist = normalize(hist, size(I), patch_size, norm_kernel);

end

