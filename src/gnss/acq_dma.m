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

function res = acq_dma(x, PRN, tau, trace_me)

%trace_me = 0;
%PRN = 31;

if (trace_me == 1)
	fprintf('[acq_dma]\n');
end

N = 16368;						% samples in 1 ms
%tau = 12000;

% FIXME 
%x = readdump_bin_2bsm('./data/flush.bin', 3*N);

x = x(1:3*N);						% get 1ms of data

ca_base = ca_get(PRN, trace_me);		% generate C/A code
ca_base = [ca_base; ca_base; ca_base];

% get new code

ca_new_code = x(1:N) .* conj(x(1+tau : N+tau));
CA_NEW_CODE = fft(ca_new_code);

ca_new_tmp = ca_base(1:N) .* ca_base(1+tau : N+tau);
CA_NEW_TMP = fft(ca_new_tmp);
	
acx = ifft(CA_NEW_TMP .* conj(CA_NEW_CODE));
	
acx = acx .* conj(acx);
%plot(acx);

[res(2), res(1)] = max(acx);
	
%fprintf('shift_ca = [%d] corr = %15.5f\n', k, res(k));
%	figure(1),
%		plot(ca_new_tmp);
%		pause;
%end

%[acx(2), acx(1)] = max(res);

%if (trace_me == 1)
%	fprintf('shift_ca = [%d] corr = %15.5f\n', acx(1), acx(2));
	%plot(res);
	%pause;
%end %if (trace_me == 1)

end;
