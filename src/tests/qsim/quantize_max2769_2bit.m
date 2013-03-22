function [y,scale_y] = quantize_max2769_2bit(x)
% AGC
max_x = max(abs(x)) ;
scale_y = 3/ max_x ;
x = x * scale_y ;
% Quantizer
y = zeros(size(x)) ;
y_values = [-3,-1,1,3] ;
for n=1:length(x)
    [~, k] = min(abs(y_values - x(n))) ;
    y(n) = y_values(k) ;
end