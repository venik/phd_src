%    Top module for the Serial correaltor acuisition method
%    Copyright (C) 2010 Alex Nikiforov  nikiforov.alex@rf-lab.org
%			 2010 Alexey Melnikov melnikov.aleksey@rf-lab.org
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

clc; clear all;

DumpSize = 16368*6 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
ts = 1/16.368e6 ;

time_offs = 100;
PRN_range = 1:32 ;
%PRN_range = 1 ;

model = 0;				% is it the model?

% ========= generate =======================
if model
	x = signal_generate(	1,	\  %PRN
					0,	\  % freq delta in Hz
					199,	\  % CA phase
					0,	\  % noise sigma
					DumpSize);
	fprintf('Generated signal \n');
else
	%x = readdump_txt('./data/flush.txt', DumpSize);				% create data vector
	x = readdump_bin_2bsm('./data/flush.bin', DumpSize);			% create data vector
	fprintf('Real signal\n');
end
% ========= generate =======================

%data = x(100:32000);
sat_acx_val = zeros(32,3) ;		% [acx, ca_phase, freq]

for k=PRN_range
	sat_acx_val(k, :) = acq_serial(x, k, fs, 0);
	fprintf('%02d: acx=%15.5f shift_ca=%05d freq:%4.1f\n', \
		k,
		sat_acx_val(k, 1),
		sat_acx_val(k, 2),
		sat_acx_val(k, 3)
	);	
end

barh(sat_acx_val((1:32),1)), grid on, title('Correlation', 'Fontsize', 18), ylim([0 ,33]);
%print -deps 'corr_bar.eps'