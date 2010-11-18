%    Delay and multiply approach
%    Copyright (C) 2010 Alex Nikiforov  nikiforov.alex@rf-lab.org
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

% more about method in
% Tsui "Fundamentals of Global Positioning System Receivers" 2nd edition
% chapter 7.10

function acx = acq_dma(x, PRN, fs, trace_me)

if (trace_me == 1)
	fprintf('[acq_dma]\n');
end

N = 16368;						% samples in 1 ms
fd= 16.368e6;						% 16.368 MHz

x = x(1:N);						% get 1ms of data

lo_sig = exp(j*2*pi * (fs/fd)*(0:N-1)).';
ca_base = ca_get(PRN, trace_me);		% generate C/A code
ca_base = [ca_base; ca_base];

lo_sig = lo_sig .* ca_base(1:length(lo_sig));

% get new code
ca_new_code = real(lo_sig .* conj(x));
res = zeros(N, 1);

for k=1:1:N-1
	ca_new_tmp = ca_base(k:N+k-1) .* ca_base(1:N);

	res(k) = sum(ca_new_tmp .* ca_new_code) ^ 2;
	
	%fprintf('shift_ca = [%d] corr = %15.5f\n', k, res(k));
%	figure(1),
%		plot(ca_new_tmp);
%		pause;
end

[acx(2), acx(1)] = max(res);

if (trace_me == 1)
	fprintf('shift_ca = [%d] corr = %15.5f\n', acx(1), acx(2));
	plot(res);
	pause;
end %if (trace_me == 1)

end
