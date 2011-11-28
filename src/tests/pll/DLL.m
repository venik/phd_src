% Delay Locked Loop for GPS
% (c) Alex Nikiforov nikiforov.alex@rf-lab.org
% License GPL v3

clear all; clc;
addpath('../../gnss/');

N = 16368;		% samples in 1 ms
fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;		% 4.092MHz
ca_rate = 1.023e6;
ca_frac = fd / ca_rate;
ca_hfrac = ca_frac / 2;	% half of the fraction for algo
PRN = 1;
early_late = zeros(3,1);

% prepare code
ca_base = ca_get(PRN, 0) ;
lo_ca = repmat(ca_base, 3, 1);		% [ca] = > [ca][ca][ca]
lo_early = lo_ca(N - ca_hfrac + 1 : 2*N - ca_hfrac);	% FIXME - check
lo_prompt = lo_ca(1:N);
lo_late = lo_ca(N + ca_hfrac + 1 : 2*N + ca_hfrac);

% FIXME - do it better (according do doppler freq increase or decrease code length)
% generate incoming signal
sig = ca_get(PRN, 0) ;
signal = repmat(sig, 3, 1);	% [ca] = > [ca][ca][ca]

% lets rock
early_late(1) = sum(lo_early .* signal(1:N));
early_late(2) = sum(lo_prompt .* signal(1:N));
early_late(3) = sum(lo_late .* signal(1:N));

[val, pos] = max(early_late);
if pos == 1
	fprintf('early, val = %d\n', val);
elseif pos == 2
	fprintf('prompt, val = %d\n', val);
else
	fprintf('late, val = %d\n', val);
endif


rmpath('../../gnss/');
