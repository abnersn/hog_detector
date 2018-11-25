%%% UNIVERSIDADE FEDERAL DO CEARÁ
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

function [ hist_norm ] = normalize( hist, image_size, patch_size, norm_kernel )
%NORMALIZE Realiza a normalização agrupada dos histogramas.
%   Normaliza os blocos de histogramas de forma agrupada, para evitar que
%   variações de magnitude locais afetem os descritores globais
%   significativamente.
%
%   Entradas:
%       hist - Matrizes com os valores de cada bin do histograma da imagem.
%       image_size - Tamanho da imagem.
%       patch_size - Tamanho do bloco de varredura.
%       norm_kernel - Quantidade de blocos utilizados na normalização.
%   
%   Saídas:
%       hist_norm - Matrizes com os histogramas normalizados.

hist_norm = zeros(size(hist));
for i=1:norm_kernel:(image_size(1)/patch_size)
    for j=1:norm_kernel:(image_size(2)/patch_size)
        x_range = i:(i + norm_kernel - 1);
        y_range = j:(j + norm_kernel - 1);
        norm_block = hist(x_range, y_range, :);
        if max(norm_block(:)) ~= 0
            norm_block = norm_block / max(norm_block(:));
            hist_norm(x_range, y_range, :) = norm_block;
        end
    end
end

end

