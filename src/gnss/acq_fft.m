%    FFT based acquisition
%    Copyright (C) Alex Nikiforov  nikiforov.pub[dog]gmail.com
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

function acq_fft(PRN, FR, trace_me)
	
	PRN = 19;
	FR = 4.092e6-10e3 : 1e3 : 4.092e6+10e3;
	trace_me = 1;

if (trace_me == 1)
	fprintf('[acq_fft] SVN:%02d\n', PRN);
end

	fd= 16.368e6;		% 16.368 MHz
	N = 16368;			% samples in 1 ms
	
	ca_base = ca_get(PRN, trace_me);	
	
%for k = 1:length(FR)
for k = 1:1	
	lo_sig = exp(-2*j*pi * (FR(k)/fd)*(0:N-1));
	CA = fft(lo_sig .* (ca_base.'));
	
	ca = ifft(conj(CA) .* CA)	;
	[acx, shift_ca] = max(ca);

	
	if (trace_me == 1)
		fprintf('PRN:%d\t acx=%05d\t shift_ca=%05d\n', PRN, acx, shift_ca);
		figure(1), plot(abs(ca)), xlim([0,N]);
		figure(2), subplot(2, 1, 1), plot(0:50, abs(ca(1:51)));
		figure(2), subplot(2, 1, 2), plot([N-50]:N, abs(ca(N-50:N))), xlim([N-50,N]);;
	end % if (trace_me == 1)
end % for k = 1:length(FR)

if (trace_me == 1)
	fprintf('\n[acq_fft] exit....\n', PRN);
end %if (trace_me == 1)

end
