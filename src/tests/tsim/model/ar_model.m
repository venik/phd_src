function c = ar_model(rxx)
% Rxx =  [rxx(1) rxx(2); ...
%       conj(rxx(2)) rxx(1)] ;
%b = pinv(Rxx)*rxx(2:end) ;

% Compute parameters using 
% Frobenius matrix inversion
a = rxx(1) ;
b = rxx(2) ;
D = rxx(1) ;
ba = b/a ;
T = D - ba*conj(b) ;
t = 1.0/T ;
c = [1/a+conj(ba)*ba*t, -conj(ba)*t; -t*ba, t]*rxx(2:3) ;