function [pole, omega0, Hjw0] = get_ar_pole(b)
%poles = roots([1;-b]) ;
D = b(1)^2+4*b(2) ;
pole = (b(1) + sqrt(D))/2 ;
omega0 = angle(pole) ;
Hjw0 = 1.0/( -b(2)*exp(-2j*omega0) - b(1)*exp(-1j*omega0) + 1.0 ) ;

