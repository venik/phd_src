% POC Costas loop
% (c) Alex Nikiforov nikiforov.alex@rf-lab.org
% License GPL v3

clc; clear all;

N = 16368;			% samples in 1 ms
fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;		% 4.092MHz
nco_freq = fs;		% NCO freq
delta  = 10;			

% local signal
sig = exp(2 * pi * ( (fs + delta)/fd)*(0:N-1)).';

% make filter
%Fnyq = fd/2;					% nyquist freq (fd/2) Hz
%Fc=100; 					% cut-off freq Hz
%[b,a]=butter(2, Fc/Fnyq);
%[h,t] = impz(b, a);
%plot(t,h)
%return;

% get from filter
a = [1; -1.99995; 0.99995];
b =  [3.6838e-10; 7.3676e-10; 3.6838e-10];

% vectors for loop
x_I = zeros(length(a), 1);
y_I = zeros(length(b), 1);
x_Q = zeros(length(a), 1);
y_Q = zeros(length(b), 1);

% Loop cycle
for k=3:10
	% stage 1 - downconvertion
	x_I(1)   = sig(k) .* 2 * cos(2 * pi * (nco_freq/fd) * k).' ;
	x_Q(1) = sig(k) .* 2 * sin(2 * pi * (nco_freq/fd) * k).';

	% stage 2 - LPF
	% y(n) = b1*x(n) + b2*x(n-1) + b3*x(n-2) - a2*y(n-1) - a3*y(n-2)
	y_I(1) = b(1)*x_I(1) + b(2)*x_I(2) + b(3)*x_I(2) - a(2)*y_I(2) - a(3)*y_I(3);
	y_Q(1) = b(1)*x_Q(1) + b(2)*x_Q(2) + b(3)*x_Q(2) - a(2)*y_Q(2) - a(3)*y_Q(3);

	% stage 3 - descriminator
	phi = atan(y_Q(1) / y_I(1));
	%phi = y_Q(1)* y_I(1);
	
	nco_freq = nco_freq + phi;
	
	% trace
	fprintf('y_I = %2.5f y_Q = %2.5f phi = %2.5f\n', y_I(1),  y_Q(1), phi);
	
	% correct x and y vectors
	x_I(3) = x_I(2);
	x_I(2) = x_I(1);
	y_I(3) = y_I(2);
	y_I(2) = y_I(1);

end

return




% stage 3

%for k=1:length(lo_rI)
	lo_fI = filter(b, a, lo_I);
	lo_fQ = filter(b, a, lo_Q);
	

%end






