function y = quantize_max2769_3bit(x)
% AGC
max_x = max(abs(x)) ;
x = x / max_x * 4 ;
% Quantizer
y = zeros(size(x)) ;
y_values = [-4,-3,-2,-1, 1,2,3,4] ;
for n=1:length(x)
    [~, k] = min(abs(y_values - x(n))) ;
    y(n) = y_values(k) ;
end