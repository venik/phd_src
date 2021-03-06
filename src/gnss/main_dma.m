%    Top module for the DMA acuisition method
%    Copyright (C)
%	2010 - 2011 Alex Nikiforov  nikiforov.alex@rf-lab.org
%	2010 - 2011 Alexey Melnikov melnikov.aleksey@rf-lab.org
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
%

clc; clear all; clf;

PRN_range = 1:32;
%PRN_range = 14;
debug_me = 0;
DumpSize = 16368*10 ;

% Algoritm specific data
tau = 33;
iteration = 5;

model = 0;				% is it the model?

% ========= generate =======================
if model
	PRN_mod = 1:5;
	freq_deltas = [1, 1, 1, 1, 1];
	ca_deltas = [1, 1, 1, 1, 1 ];
	SNRs = [25, 10, 10, 10, 10];
	x = signal_generate(	PRN_mod(1),	\  %PRN
			freq_deltas(1),	\  % freq delta in Hz
			ca_deltas(1),	\  % CA phase
			SNRs(1),	\  % SNR
			DumpSize,
			debug_me);
	fprintf('Generated\n');
else
	x = readdump_bin_2bsm('./data/flush.bin', DumpSize);
	fprintf('Real\n');
end
% ========= generate =======================

% [acx, ca_phase]
sat_acx_val = zeros(length(PRN_range), 2);

for k = PRN_range
	sat_acx_val(k, :)= acq_dma(x, k, tau, iteration, debug_me);
		
	fprintf('%02d: acx=%15.5f shift_ca=%05d\n', k, sat_acx_val(k, 1), sat_acx_val(k, 2));
end

if length(PRN_range) > 1
	barh(sat_acx_val((1:32),1)),
		grid on,
		title('Correlation with DMA', 'Fontsize', 18),
		ylim([0 ,33]);
	return;
endif;