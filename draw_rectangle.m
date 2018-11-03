function [ I_disp ] = draw_rectangle( I, coords, size, color )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

I_disp = I;
h_range = coords(2):(coords(2) + size(2));
v_range = coords(1):(coords(1) + size(1));

I_disp(v_range, coords(2), 1) = color(1);
I_disp(v_range, coords(2), 2) = color(2);
I_disp(v_range, coords(2), 3) = color(3);

I_disp(v_range, coords(2) + size(2), 1) = color(1);
I_disp(v_range, coords(2) + size(2), 2) = color(2);
I_disp(v_range, coords(2) + size(2), 3) = color(3);

I_disp(coords(1), h_range, 1) = color(1);
I_disp(coords(1), h_range, 2) = color(2);
I_disp(coords(1), h_range, 3) = color(3);

I_disp(coords(1) + size(1), h_range, 1) = color(1);
I_disp(coords(1) + size(1), h_range, 2) = color(2);
I_disp(coords(1) + size(1), h_range, 3) = color(3);

end

