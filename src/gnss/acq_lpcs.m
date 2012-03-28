% x - received signal x(n) = cos(w*(n+d))*CA(n+d)
% ca - ca code
% E - pole's energy
function res = acq_lpcs(x_in, PRN, iteration, trace_me)
	
fd = 16.368e6;
N = 16368;			% samples in 1 ms

signal = zeros(N,1);

% add signal coherent - increase SNR, after addition SNR = iteration
for k=1:iteration
	signal(1:N) = signal(1:N) .+ x_in((k-1)*N + 1: k*N);
end

ca = ca_get(PRN, trace_me);		% generate C/A code

x = signal(:)./ iteration ;
ca = ca(:) ;
Dx = x'*x/(length(x)-1) ;
xx = x.*conj([x(2:end);x(1)]) ;
cc = ca.*[ca(2:end);ca(1)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx1 = ifft(conj(XX).*CC)/(length(CC)-1) ;
xx = x.*conj([x(3:end);x(1:2)]) ;
cc = ca.*[ca(3:end);ca(1:2)] ;
XX = fft(xx) ;
CC = fft(cc) ;
rx2 = ifft(conj(XX).*CC)/(length(CC)-1) ;
E = zeros(size(rx1)) ;
freq = zeros(size(rx1)) ;
for k=1:N
    rxx = [Dx;rx1(k);rx2(k)] ;
    Rxx = [rxx(1) rxx(2);conj(rxx(2)) rxx(1)] ;
    b = pinv(Rxx)*rxx(2:end) ;
    b = [1;-b] ;
    poles = roots(b) ;
    freq(k) = angle(poles(1)) ;
    E(k) = poles(1)*conj(poles(1)) ;
end

[~,ca_phase] = max(E) ;
res(3) = freq(ca_phase)*fd/2/pi ;
res(1) = E(ca_phase) ;
res(2) = ca_phase-1 ;

if (trace_me == 1)
	fprintf('freq:%8.2f,  pwr:%5.2f, k:%4d\n', res(3), res(1), res(2)) ;
	%plot(acx);
	%pause;
end %if (trace_me == 1)


%plot(freq*fd/2/pi), grid on ;
%plot(E),grid on ;
%[~,ca_shift] = max(E) ;
%f = freq(ca_shift) ;
%fprintf('freq:%8.2f,  pwr:%5.2f, k:%4d\n', f*fs/2/pi, E(ca_shift), ca_shift-1 ) ;