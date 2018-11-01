function [ M, P, G ] = gradient( I )
%GRADIENT Calcula o gradiente de uma imagem e retorna a magnitude e a fase.
%   Os operadores de Sobel são convolucionados sobre a matriz que
%   representa a imagem.

% Filtros de Sobel
sobel_x = [-1 0 1; -2 0 2; -1 0 1];
sobel_y = [1 2 1; 0 0 0; -1 -2 -1];

% Convolução 2D dos filtros de Sobel
G = cat(3, conv2(I, sobel_x, 'same'), conv2(I, sobel_y, 'same'));

% Magnitude dos vetores
M = sqrt(sum(G.^2, 3));

% Fase dos vetores
P = atan2(G(:,:,2), G(:,:,1));

end

