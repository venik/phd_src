%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Acquisition - serial correaltor 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function res = acq_serial(x, PRN, FR, trace_me)

fd = 16.368e6 ; 		% sampling frequency
N = 16368;			% samples in 1 ms

x = x(1:N);						% get 1ms of data
ca_base = ca_get(PRN, trace_me);		% generate C/A code
ca_base = repmat(ca_base, 2, 1);

result = zeros(length(FR), 2);			% [acx, ca_shift] array
corr_vals = zeros(N, 1);				%
lo_x = zeros(N, 1);				%

for k=1:length(FR)

	%lo_sig = exp(j*2*pi * (FR(k)/fd)*(0:N-1)).';
	lo_sig = cos(2*pi * (FR(k)/fd)*(0:2*N-1)).';
		
	for ca_shift=1:N
		% curcular convolution - in the fft manner
		lo_x = lo_sig(ca_shift : ca_shift + N -1) .* ca_base(ca_shift : ca_shift + N -1);
				
		acx = sum(real(lo_x) .* x) ;
		acx = acx .* conj(acx) ;
		corr_vals(ca_shift) = acx / N;
		
	end 	% for k=ca_shift:N
	
	[val, ca_phase]= max(corr_vals);
	result(k, :) = [val, ca_phase];
	if (trace_me == 1)
		fprintf('PRN:%d FR:%d \t acx=%15.5f\t shift_ca=%05d\n', PRN, FR(k), result(k,1), result(k,2));
	end
	
end 	%for k=1:length(FR)

% get the max
res = zeros(3,1);
[res(1), res(3)] = max(result(1:length(FR),1));
res(2) = result(res(3),2);
res(3) = FR(res(3));

end %function res = acq_serial(x, PRN, FR, trace_me)