clc; clear all;

addpath('../../gnss/');

PRN = 1 ;

# Constants PLL
zeta = 0.7;
LBW = 25;						% Hz
k = 0.25;
PDIcarr = 0.001;

% Coefficients
% Solve natural frequency
Wn = LBW*8*zeta / (4*zeta^2 + 1);

% solve for t1 & t2
tau1carr = k / (Wn * Wn);
tau2carr = 2.0 * zeta / Wn;

% Constants signal
N = 16368;			% samples in 1 ms
num_symbols = 60;	% 60ms
DampLength = N * num_symbols;	% Length of the signal
fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;		% 4.092MHz
nco_freq = fs;		% NCO freq
delta  = 20;			% in Hz
sigma = 0.01;		% FIXME - add a noise

% local signal
ca_base = ca_get(PRN, 0) ;
ca16 = repmat(ca_base, num_symbols, 1); 

sig_l = cos(2 * pi * ( (fs + delta)/fd)*(0:DampLength-1)).';
sig_l = sig_l .* ca16;

wn = (sigma/sqrt(2)) * (randn(DampLength, 1) + j * randn(DampLength, 1));

signal = sig_l + wn;

carrNco = 0;
oldCarrNco = 0;
carrError = 0;
oldCarrError = 0;
remCarrPhase  = 0.0;
carrFreq = fs;
carrFreqRes = zeros(num_symbols, 1);

for k=1:num_symbols
%for k=1:10
            % Get the argument to sin/cos functions
            trigarg = ( 2 * pi * carrFreq ./ fd) .* (0:N-1) + remCarrPhase;
            remCarrPhase = rem(trigarg(N), (2 * pi));
            
            % Finally compute the signal to mix the collected data to
            % bandband
            carrsig = exp(j .* trigarg.');
            %carrsig = exp(j * 2 * pi * ( (carrFreq)/fd)*(0:N-1)).';
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
	%fprintf('first\n');
	lo_sig = signal(1 + N*(k-1) : N + N*(k-1)) .* ca_base;
	lo_sig = lo_sig .* carrsig;
	
	real_Sig = sum(real(lo_sig));
           image_Sig = sum(imag(lo_sig));

	%carrError = atan(image_Sig/real_Sig) / (2 * pi);
	carrError = atan(real_Sig/image_Sig) / (2 * pi);
else 
	q_bb_Sig = real(signal(1 + N*(k-1) : N + N*(k-1)) .* carrsig);
           i_bb_Sig = imag(signal(1 + N*(k-1) : N + N*(k-1)) .* carrsig);
           qSig = sum(ca_base .* q_bb_Sig);
           iSig = sum(ca_base .* i_bb_Sig);
           
	% descriminator
	carrError = atan(qSig/iSig) / (2 * pi);
	%carrError = atan(iSig/qSig) / (2.0 * pi);
end
	
	  % Implement carrier loop filter and generate NCO command
            carrNco = oldCarrNco + (tau2carr/tau1carr) * (carrError - oldCarrError) + carrError * (PDIcarr/tau1carr);
            oldCarrNco   = carrNco;
            oldCarrError = carrError;

            % Modify carrier freq based on NCO command
            carrFreq = fs + carrNco;

            carrFreqRes(k) = carrNco;
end 	% for k = 

plot(carrFreqRes(1:k));