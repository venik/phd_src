% Reference:
% United States patent Lin et al. US 6.567.042 B2

clear all; clc;

addpath('../../gnss/');

% constants
PRN = 19 ;
fs = 4.092e6;
fd = 16.368e6;
N = 16368;

% DBZP constants
M = 4;

sig = signal_generate(PRN,
		0, 	% freq delta
		1,	% C/A phase
		0.001,	% sigma
		(M+2) * N);	% dump size

% generate local data
ca_base = ca_get(PRN, 0) ;
carr_base = exp(j * 2*pi * fs/fd * (0 : N-1));
lo_base = ca_base .* carr_base.' ;

% ++++++++++++++++++++++++++++++++++++++++++++++++++
% double block - Figure 3, part 300 and 301
% ++++++++++++++++++++++++++++++++++++++++++++++++++
% ========= test vals ========= 
%M = 16;
%sig = 1:M+1;
%N = 1;
% ========================== 
sig_double = zeros(M * N * 2, 1);
k2 = 1;
for k1=1:N:M
	%sig_double((k-1) * N + 1: k * N) = sig((n-1) * N + 1: n * N);
	%sig_double( (k*N) + 1 : k*(N+1)) = 1;
	sig_double(k2) = sig(k1);
	sig_double(k2 + 1) = sig(k1 + 1);
	
	k2 = k2 + 2*N;
end	% for k1=1:N:M

% ++++++++++++++++++++++++++++++++++++++++++++++++++
% zero padding
% ++++++++++++++++++++++++++++++++++++++++++++++++++
lo_tmp = zeros(2 * length(lo_base), 1);

% make [lo_tmp] [zerooo] 
lo_tmp(1:N) = lo_base;

% [lo_sig] ... [lo_sig] M-times
lo_sig = repmat(lo_tmp, M, 1);


rmpath('../../gnss/');
