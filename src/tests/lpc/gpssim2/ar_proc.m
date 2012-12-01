function freq = ar_proc(rxx)
Rxx = [rxx(1) rxx(2);conj(rxx(2)) rxx(1)] ;
b = pinv(Rxx)*rxx(2:end) ;
b = [1;-b] ;
poles = roots(b) ;
freq = angle(poles(1)) ;
fprintf('ar_proc: %3.1f, %4.0f\n', abs(poles(1)), freq*16368/2/pi) ;