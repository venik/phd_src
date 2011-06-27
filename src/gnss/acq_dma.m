%    Delay and multiply approach
%    Copyright (C) 2010 Alex Nikiforov  nikiforov.alex@rf-lab.org
%    	                    2010 Alexey Melnikov  melnikov.alexey@rf-lab.org
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Reference
% Tsui "Fundamentals of Global Positioning System Receivers" 2nd edition
% chapter 7.10

function res = acq_dma(x, PRN, tau, iteration, trace_me)

% FIXME 
if 0
	%trace_me = 1;
	%PRN = 31;
	%tau = 1023;
	%iteration = 5;
	%x = readdump_bin_2bsm('./data/flush.bin', (iteration+1)*16368);
endif

if (trace_me == 1)
	fprintf('[acq_dma]\n');
end

N = 16368;						% samples in 1 ms
x = x(1:(iteration+1)*N);				% get iteration-ms of data

ca_base = ca_get(PRN, trace_me);		% generate C/A code
ca_base = [ca_base; ca_base; ca_base];
signal = zeros(N,1);

% add signal coherent - increase SNR, after addition SNR = iteration
for k=1:iteration
	signal(1:N) = signal(1:N) .+ x((k-1)*N + 1: k*N) .* conj(x((k-1)*N + 1 + tau: k*N + tau));
end

% get new code
ca_new_code = signal ./ iteration;
CA_NEW_CODE = fft(ca_new_code);

% generate local replica of the new code
ca_new_tmp = ca_base(1:N) .* ca_base(1+tau : N+tau);
CA_NEW_TMP = fft(ca_new_tmp);

% correlate
acx = ifft(CA_NEW_TMP .* conj(CA_NEW_CODE));
acx = acx .* conj(acx);

[res(2), res(1)] = max(acx);
	
if (trace_me == 1)
	fprintf('shift_ca = [%d] corr = %15.5f\n', res(1), res(2));
	plot(acx);
	pause;
end %if (trace_me == 1)

end;
