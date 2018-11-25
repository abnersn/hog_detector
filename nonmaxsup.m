function [ faces ] = nonmaxsup( detections, confidences, limiar, block_size )
%NONMAXSUP Summary of this function goes here
%   Detailed explanation goes here

% Ordena faces detectadas conforme o fator de confian�a.
[~, indexes] = sort(confidences, 'descend');
detections = detections(indexes, :);

% Vetor de flags que indicam quais detec��es foram v�lidas.
isvalid = ones(1, size(detections, 1));

for i = 1:size(detections, 1)
    if isvalid(i) == 0
        continue
    end
    face = detections(i, :);
    for j = 1:size(detections, 1)
        if i == j
            continue
        end
        % Calcula a raz�o entre a �rea de interse��o e a �rea de uni�o dos
        % dois blocos de detec��o.
        intersection = rectint(detections(j, :), face);
        union = 2 * prod(block_size) - intersection;
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

