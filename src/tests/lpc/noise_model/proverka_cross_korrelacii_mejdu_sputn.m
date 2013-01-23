clc, clear all ;
prn1 = 17 ;
prn2 = 1 ;
varx1 = 1 ;
varx2 = 2 ;
fs1 = 3850 ;
fd = 16368 ;
N = 1023 ; % chips
max_delay = 20 ; % chips

pts1 = [] ;
pts2 = [] ;
pts3 = [] ;

for fs1=0000:200:8000
c = cos(2*pi*fs1/fd*(0:(N+max_delay)*16-1)) ; c = c(:) ;
code1 = get_ca_code16(N+max_delay,prn1) ;
code2 = get_ca_code16(N+max_delay,prn2) ;

x = c(1:N).*code1(1:N).*code2(100+1:100+N) ;

rxx = [x'*x, x'*circshift(x,1), x'*circshift(x,2)] ;
pts1 = [pts1,rxx(1)] ;
pts2 = [pts2,rxx(2)] ;
pts3 = [pts3,rxx(3)] ;
end

%hold on, plot(rxx,'b-.^','LineWidth',2), grid on ;
hold on, 
    grid on,
    plot(pts1, 'gx-'),
    plot(pts2, 'ro-'),
    plot(pts3, 'b*-'),
    legend('rxx0', 'rxx1', 'rxx2'),
    title('rx1')
    hold off;