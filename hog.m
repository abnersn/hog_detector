%%% UNIVERSIDADE FEDERAL DO CEAR�
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

function [ hist ] = hog( I, patch_size, bins, norm_kernel, filter )
%HOG Sintetiza as opera��es necess�rias para c�lculo dos descritores HOG.
%
%   Entradas:
%       I - Imagem para c�lculo dos descritores.
%       patch_size - Tamanho do bloco de varredura.
%       bins - Quantidade de setores do histograma.
%       norm_kernel - Quantidade de blocos utilizados na normaliza��o.
%       filter - Filtro a ser utilizado no c�lculo dos gradientes.
%   
%   Sa�das:
%       hist - Matrizes com os valores de cada bin do histograma.


%%% C�lculo do gradiente
[M, P] = gradient(I, filter);

%%% C�lculo dos histogramas
hist = histograms(M, P, patch_size, bins);

%%% Normaliza��o dos histogramas
hist = normalize(hist, size(I), patch_size, norm_kernel);

end

