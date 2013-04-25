function b = ar_model(rxx)
Rxx =  [rxx(1) rxx(2); ...
       conj(rxx(2)) rxx(1)] ;
b = pinv(Rxx)*rxx(2:end) ;
