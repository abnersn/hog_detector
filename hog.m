%%% UNIVERSIDADE FEDERAL DO CEARÁ
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

function [ hist ] = hog( I, patch_size, bins, norm_kernel, filter )
%HOG Sintetiza as operações necessárias para cálculo dos descritores HOG.
%
%   Entradas:
%       I - Imagem para cálculo dos descritores.
%       patch_size - Tamanho do bloco de varredura.
%       bins - Quantidade de setores do histograma.
%       norm_kernel - Quantidade de blocos utilizados na normalização.
%       filter - Filtro a ser utilizado no cálculo dos gradientes.
%   
%   Saídas:
%       hist - Matrizes com os valores de cada bin do histograma.


%%% Cálculo do gradiente
[M, P] = gradient(I, filter);

%%% Cálculo dos histogramas
hist = histograms(M, P, patch_size, bins);

%%% Normalização dos histogramas
hist = normalize(hist, size(I), patch_size, norm_kernel);

end

