%    FFT based acquisition
%    Copyright (C) 2010 - 2011 Alex Nikiforov  nikiforov.alex@rf-lab.org
%			 2010 - 2011 Alexey Melnikov melnikov.aleksey@rf-lab.org
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
% chapter 7

function res = acq_fft(x, PRN, FR, trace_me)
	
if (trace_me == 1)
	fprintf('[acq_fft] SVN:%02d\n', PRN);
end

fd= 16.368e6;		% 16.368 MHz
N = 16368;			% samples in 1 ms

%x = 1 * (x(1:N) + x(N+1:2*N));						% get 1ms of data
x = x(1:N);
X = fft(x);
ca_base = ca_get(PRN, trace_me);		% generate C/A code

result = zeros(length(FR), 2);			% [acx, ca_shift] array
thr_max = zeros(5, 1);

for k = 1:length(FR)
	lo_sig = exp(j*2*pi * (FR(k)/fd)*(0:N-1)).';
	CA = fft(lo_sig .* ca_base);
	%CA = fft(real(lo_sig) .* ca_base);
	
	%ca = ifft(conj(CA) .* X);
	ca = ifft(CA .* conj(X));		% equal to circular correlation
	ca = ca .* conj(ca);
	
	ca = sqrt(ca);
	
	if (trace_me == 1)
		fprintf('PRN:%d FR:%d \t acx=%d\t shift_ca=%05d\n', PRN, FR(k), result(k,1), result(k,2));
		corr_sss = [ abs(ca(N-50:N)) abs(ca(1:51))];
		
		plot(ca), \
			grid on, \
			title(sprintf('PRN=%d, F_0=%d Hz',PRN,FR(k)), 'Fontsize', 18),  \
			xlim([0,16368]);
			
		%pause;
		%print -deps 'corr_05_4092.eps'
		
		%figure(1), plot(abs(ca)), xlim([0,N]);
		%figure(2), subplot(1,1,1); plot(-51:50, corr_sss); grid on;
	end % if (trace_me == 1)
	
	% 2 max threshold algorithm
	thr_max = threshold_2max(ca, trace_me);
	result(k,1) = thr_max(1);
	result(k,2) = thr_max(2);
	% check for signal presence
	if thr_max(5) == 1
		break;
	end;	% if thr_max(5)

end % for k = 1:length(FR)

% get the max
res = zeros(4,1);
[res(1), res(3)] = max(result(1:length(FR),1));
res(2) = result(res(3),2);
res(3) = FR(res(3));
res(4) = thr_max(5);			% detect flag

if (trace_me == 1)
	fprintf('\n[acq_fft] PRN:02%d acx=%05d shift_ca=%05d exit....\n', PRN, res(1), res(2));
end %if (trace_me == 1)

end
