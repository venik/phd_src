clc, clear all ;
prn1 = 13 ;
prn2 = 1 ;
varx1 = 1 ;
varx2 = 2 ;
fs1 = 3850 ;
fs2 = 3850 ;
fd = 16368 ;
N = 1023 ; % chips
max_delay1 = 0 ; % chips
max_delay2 = 0 ; % chips

pts1 = [] ;
pts2 = [] ;
pts3 = [] ;

for fs1=0000:200:8000
c1 = get_ca_code16(N+max_delay1,prn1) ;
c2 = get_ca_code16(N+max_delay2,prn2) ;
sig1 = cos(2*pi*fs1/fd*(0:(N+max_delay1)*16-1)) .* c1';
sig2 = cos(2*pi*fs2/fd*(0:(N+max_delay2)*16-1)) .* c2';

%sig = sig1(1:N) .* sig2(1:N) ;
%CN = fft(sig) ;
%cn = ifft(CN .* conj(CN)) ;
%cn = cn .* conj(cn) ;

x = sig1 .* sig2 ;
x = x' ;
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
    title('rx1x2')
    hold off;