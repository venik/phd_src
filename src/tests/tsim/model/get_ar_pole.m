function [poles, omega0, Hjw0] = get_ar_pole(b)
poles = roots([1;-b]) ;
omega0 = angle(poles(1)) ;
Hjw0 = 1.0/( -b(2)*exp(-2j*omega0) - b(1)*exp(-1j*omega0) + 1.0 ) ;

