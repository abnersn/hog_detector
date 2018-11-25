%%% UNIVERSIDADE FEDERAL DO CEAR�
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

function [ faces ] = nonmaxsup( detections, confidences, limiar )
%NONMAXSUP Eliminar ret�ngulos de detec��o em excesso.
%   Utiliza a t�cnica de supress�o n�o-m�xima e a raz�o interse��o/uni�o
%   para determinar quais detec��es s�o apenas sobreposi��es decorrentes da
%   janela de varredura, que devem, portanto, ser suprimidas.
%
%   Entradas:
%       detections - Lista de ret�ngulos detectados.
%       confidences - N�vel de confian�a da detec��o de cada ret�ngulo.
%       limiar - N�vel de sobreposi��o m�ximo permitido.
%   
%   Sa�das:
%       faces - Ret�ngulos v�lidos detectados

% Ordena faces detectadas conforme o fator de confian�a.
[~, indexes] = sort(confidences, 'descend');
detections = detections(indexes, :);

% Vetor de flags que indicam quais detec��es foram v�lidas.
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
        % Calcula a raz�o entre a �rea de interse��o e a �rea de uni�o dos
        % dois blocos de detec��o.
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

