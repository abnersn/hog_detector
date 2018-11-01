function [ hist ] = histograms( M, P, patch_size, bins )
%HISTOGRAMS Summary of this function goes here
%   Detailed explanation goes here

% Índices dos bins do histograma ao qual o pixel será associado.
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

