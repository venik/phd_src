function y = quantize_max2769_2bit(x)
% AGC
max_x = max(abs(x)) ;
x = x / max_x * 5 ;
% Quantizer
y = zeros(size(x)) ;
y_values = [-3,-1,1,3] ;
for n=1:length(x)
    [~, k] = min(abs(y_values - x(n))) ;
    y(n) = y_values(k) ;
end