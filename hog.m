function [ hist ] = hog( I, patch_size, bins, norm_kernel )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%% Cálculo do gradiente
[M, P] = gradient(I);

%%% Cálculo dos histogramas
hist = histograms(M, P, patch_size, bins);

%%% Normalização dos histogramas
hist = normalize(hist, size(I), patch_size, norm_kernel);

end

