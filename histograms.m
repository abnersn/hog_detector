%%% UNIVERSIDADE FEDERAL DO CEAR�
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

function [ hist ] = histograms( M, P, patch_size, bins )
%HISTOGRAMS Calcula histogramas dos vetores gradiente.
%   Percorre a imagem em blocos e calcula histogramas para as dire��es dos
%   gradientes de cada pixel.
%
%   Entradas:
%       M - Magnitude dos vetores gradiente.
%       P - �ngulos dos vetores gradiente em rela��o ao semi-eixo +x.
%       patch_size - Tamanho do bloco de varredura.
%       bins - Quantidade de setores do histograma.
%   
%   Sa�das:
%       hist - Matrizes com os valores de cada bin do histograma.

indexes = floor((P/pi + 1) / 2 * bins) + 1;
indexes = indexes - (indexes == (bins + 1));

hist = zeros([size(M)/patch_size bins]);
i_h = 1; j_h = 1;
for i=1:patch_size:size(M, 1)
    for j=1:patch_size:size(M, 2)
        x_range = j:(j + patch_size - 1);
        y_range = i:(i + patch_size - 1);
        for k = x_range
            for w = y_range
                index = indexes(w, k);
                hist(i_h, j_h, index) = hist(i_h, j_h, index) + M(index);
            end
        end
        j_h = j_h + 1;
    end
    i_h = i_h + 1;
    j_h = 1;
end

end

