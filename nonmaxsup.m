%%% UNIVERSIDADE FEDERAL DO CEARÁ
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

function [ faces ] = nonmaxsup( detections, confidences, limiar )
%NONMAXSUP Eliminar retângulos de detecção em excesso.
%   Utiliza a técnica de supressão não-máxima e a razão interseção/união
%   para determinar quais detecções são apenas sobreposições decorrentes da
%   janela de varredura, que devem, portanto, ser suprimidas.
%
%   Entradas:
%       detections - Lista de retângulos detectados.
%       confidences - Nível de confiança da detecção de cada retângulo.
%       limiar - Nível de sobreposição máximo permitido.
%   
%   Saídas:
%       faces - Retângulos válidos detectados

% Ordena faces detectadas conforme o fator de confiança.
[~, indexes] = sort(confidences, 'descend');
detections = detections(indexes, :);

% Vetor de flags que indicam quais detecções foram válidas.
isvalid = ones(1, size(detections, 1));

block_size = prod(detections(1, 3:4));
for i = 1:size(detections, 1)
    if isvalid(i) == 0
        continue
    end
    face = detections(i, :);
    for j = 1:size(detections, 1)
        if i == j
            continue
        end
        % Calcula a razão entre a área de interseção e a área de união dos
        % dois blocos de detecção.
        intersection = rectint(detections(j, :), face);
        union = 2 * block_size - intersection;
        IoU = intersection / union;
        if IoU > limiar
            isvalid(j) = 0;
        end
    end
end

faces = zeros(sum(isvalid), 4);
j = 1;
for i = 1:size(detections, 1)
    if isvalid(i) == 1
        faces(j, :) = detections(i, :);
        j = j + 1;
    end
end

end

