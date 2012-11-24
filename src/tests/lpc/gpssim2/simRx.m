clc, clear all ;
N = 1023 ; % chips
max_delay = 0 ; % chips
fs = [4500,4200] ;
fd = 16368 ;
delay2 = 150 ;
E1 = 0.6 ;
E2 = 0.4 ;
x1 = sqrt(E1)*cos(2*pi*fs(1)/fd*(0:N*16-1))' ;
x2 = sqrt(E2)*circshift(cos(2*pi*fs(2)/fd*(0:N*16-1))', delay2) ;
c1 = get_ca_code16(N,1) ;
c2 = circshift(get_ca_code16(N,5), delay2) ;
xc1 = x1.*c1 ;
xc2 = x2.*c2 ;
y = xc1 + xc2 ;
%y = xc1 ;
r0 = y'*y ;

r1 = sum(y.*circshift(y,1).*circshift(c1,0).*circshift(c1,1)) ;
r2 = sum(y.*circshift(y,2).*circshift(c1,0).*circshift(c1,2)) ;
%ar_proc([r0 r1 r2]');

er01 = x1'*x1 ;
er02 = x2'*x2 ;
er03 = 2*sum(x1.*c1.*x2.*c2) ;

er11 = x1'*circshift(x1,1) ;
er12 = sum(x1.*circshift(x2,1).*circshift(c1,1).*circshift(c2,1)) ;
er13 = sum(x2.*c2.*circshift(x1,1).*c1) ;
er14 = sum(x2.*c2.*circshift(x2,1).*circshift(c2,1).*c1.*circshift(c1,1)) ;

er21 = sum(x1.*circshift(x1,2)) ;
er22 = sum(x1.*circshift(x2,2).*circshift(c1,2).*circshift(c2,2)) ;
er23 = sum(x2.*c2.*circshift(x1,2).*c1) ;
er24 = sum(x2.*c2.*circshift(x2,2).*circshift(c2,2).*c1.*circshift(c1,2)) ;

er1 = sum(x1.*circshift(x1,1) + x1.*circshift(x2,1).*circshift(c1,1).*circshift(c2,1) + ...
     x2.*c2.*circshift(x1,1).*c1 + ...
     x2.*c2.*circshift(x2,1).*circshift(c2,1).*c1.*circshift(c1,1)) ;
er2 = sum(x1.*circshift(x1,2) + x1.*circshift(x2,2).*circshift(c1,2).*circshift(c2,2) + ...
     x2.*c2.*circshift(x1,2).*c1 + ...
     x2.*c2.*circshift(x2,2).*circshift(c2,2).*c1.*circshift(c1,2)) ;
 
ar_proc([er01 er11 er21]') ;
ar_proc([r0*E1/(E1+E2) r1 r2*E1/(E1+E2)]') ;
 
%[r0,0,er01,er02,er03,0,er01+er02+er03; r1,er1,er11,er12,er13,er14, er11+er12+er13+er14;r2,er2,er21,er22,er23,er24,er21+er22+er23+er24]

hold off, plot([er01 er11 er21],'-^','LineWidth',2), grid on
hold on, plot([r0 r1 r2],'-^','LineWidth',2,'Color',[0.7, 0, 0]), grid on
hold on, plot([r0*E1/(E1+E2) r1 r2*E1/(E1+E2)],'-^','LineWidth',2,'Color',[0, 0.7, 0]), grid on
legend('Ideal r_x','Measured r_x','Corrected r_x') ;