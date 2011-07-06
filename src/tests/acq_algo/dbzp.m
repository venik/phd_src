%    Copyright (C) 2011 Alex Nikiforov  nikiforov.alex@rf-lab.org
%    	                      2011 Alexey Melnikov  melnikov.alexey@rf-lab.org
%
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
% DOUBLE BLOCK - Figure 3, part 300 and 301
% map the input data to new form (extended data) into M blocks
% for example we have N = 2 (samples in signal) M = 5
% we need M + 1 block of the start signal (in our example (M + 1) * N = 12)
% input:	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 (first block 1,2, second 3, 4, etc)
% output:	1, 2, 3, 4;
%		3, 4, 5, 6;
%		................
%		7, 8, 9, 10;
%		9, 10, 11, 12;
% ++++++++++++++++++++++++++++++++++++++++++++++++++
% ========= test vals ========= 
%M = 5;
%N = 2;
%sig =  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
% ========================== 
sig_double = zeros(M, 2 * N);
for k1=1:5
	sig_double( k1 , 1:N ) = sig((k1 - 1) * N + 1 : k1 * N);
	sig_double( k1, N + 1 : 2*N) = sig((k1 *  N) + 1 : (k1 + 1) * N);
end	% for k1=

% ========= test end ========= 
%sig_double
%return
% ========= test end ========= 

% ++++++++++++++++++++++++++++++++++++++++++++++++++
% ZERO PADDING
% map the local data to new form (extended data) into M blocks
% for example we have N = 2 (samples in signal) M = 5
% input:	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 (first block 1,2, second 3, 4, etc)
% output:	1, 2, 0, 0;
%		3, 4, 0, 0;
%		................
%		9, 10, 0, 0;
% ++++++++++++++++++++++++++++++++++++++++++++++++++
% ========= test vals ========= 
%M = 16;
%N = 1;
%lo_base = 1:N;
% ========================== 
lo_tmp = zeros(2 * length(lo_base), 1);

% make [lo_tmp] [zerooo] 
lo_tmp(1:N) = lo_base;

% FIXME - Seems that we dont need this, bcoz lo_sig process in DFT
% circullar correlation and in DBZP every time it's the same
% [lo_sig] ... [lo_sig] M-times
%lo_sig = repmat(lo_tmp, M, 1);
lo_sig = lo_tmp;

% ++++++++++++++++++++++++++++++++++++++++++++++++++
% Create M group with FFT results, each group have 2*N point
% but we interest in the first N, bcoz second N have partial correlation
% Fig 4. 401
% ++++++++++++++++++++++++++++++++++++++++++++++++++

DFT_ARRAY = zeros(M, length(lo_sig));
LO_SIG = fft(lo_sig);
for k1=1:M
	DFT_ARRAY(k1, 1:end) = fft(sig_double( k1 , 1:end )) * LO_SIG;
end	% for k1=

% ++++++++++++++++++++++++++++++++++++++++++++++++++
% Get M valie with index i and make DFT, check for peak > threshold
% i in range [1:N]
% Fig 4. 402
% ++++++++++++++++++++++++++++++++++++++++++++++++++
Ci = zeros(M, 1);
for k1=1:N
	C_i(1:M) = DFT_ARRAY(1:M, k1);
	c_i = ifft(C_i);
	c_i = c_i .* conj(c_i);

	% check for the threshold	
end	% for k1=



rmpath('../../gnss/');
