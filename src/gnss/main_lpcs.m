%    Top module for the parralel correaltor acuisition method
%    Copyright (C)
%	2012 Alex Nikiforov  nikiforov.alex@rf-lab.org
%	2012 Alexey Melnikov melnikov.aleksey@rf-lab.org
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

clc; clear all; clf;

% LPC related
P = 2 ;        % order of LPC analysis

% Signal related
DumpSize = 16368*6 ;
N = 16368 ;

debug_me = 0;
iteration = 1;

%PRN_range = 1:32 ;
PRN_range = 31 ;
model = 1;				% is it the model?

% ========= generate =======================
if model
	x = signal_generate(	31,	\  %PRN
					1,	\  % freq delta in Hz
					1023,	\  % CA phase
					10,	\  % snr, dB
					DumpSize);
	fprintf('Generated\n');
else
	%x = readdump_txt('./data/flush.txt', DumpSize);				% create data vector
	x = readdump_bin_2bsm('./data/flush.bin', DumpSize);			% create data vector
	fprintf('Real\n');
end
% ========= generate =======================

% [acx, ca_phase, freq]
sat_acx_val = zeros(length(PRN_range), 3);

for k = PRN_range
	sat_acx_val(k, :) = acq_lpcs(x, k, iteration, debug_me) ;

	fprintf('%02d: pwr:%5.2f shift_ca=%05d freq:%8.2f\n', k, sat_acx_val(k, 1), sat_acx_val(k, 2), sat_acx_val(k, 3)) ;
end

%plot(freq*fd/2/pi), grid on ;
%plot(E),grid on ;
%[~,ca_shift] = max(E) ;
%f = freq(ca_shift) ;
%fprintf('freq:%8.2f,  pwr:%5.2f, k:%4d\n', f*fd/2/pi, E(ca_shift), ca_shift-1 ) ;

if length(PRN_range) > 1
	barh(sat_acx_val((1:32),1)),
		grid on,
		title('Correlation with LPC', 'Fontsize', 18),
		ylim([0 ,33]);
	return;
endif;

% print -djpeg '/tmp/lpc_corr.jpg'