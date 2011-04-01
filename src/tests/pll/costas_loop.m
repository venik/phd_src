% POC Costas loop

clc; clear all;

N = 16368;			% samples in 1 ms
fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;		% 4.092MHz
delta  = 10;			
fs = fs + delta;
nco_freq = fs;		% NCO freq

% local signal
sig = cos(2 * pi * (fs/fd)*(0:N-1)).';

% 1 stage - downconvert
nco_sig = exp(2 * pi * (nco_freq/fd)*(0:N-1)).';
lo_I = sig .* real(nco_sig) ;
lo_Q = sig .* imag(nco_sig) ;

% 2 stage - filtering
% make filter
Fnyq = fs/2;		% nyquist freq (fs/2) Hz
Fc=100; 		% cut-off freq Hz
[b,a]=butter(2, Fc/Fnyq);
%[h,t] = impz(b, a);
%plot(t,h)
%return;

% stage 3

%for k=1:length(lo_rI)
	lo_fI = filter(b, a, lo_I);
	lo_fQ = filter(b, a, lo_Q);
	
	phi = atan(sum(lo_fQ) / sum(lo_fI))
%end






