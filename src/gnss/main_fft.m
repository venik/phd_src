%    Top module for the parralel correaltor acuisition method
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
%
% Reference: 	Tsui "Fundamentals of Global Positioning System Receivers" 2nd edition
% 			chapter 7

clc; clear all; clf;

DumpSize = 16368*6 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
ts = 1/16.368e6 ;

time_offs = 100;
PRN_range = 1:32 ;
%PRN_range = 1 ;

debug_me = 0;
model = 0;				% is it the model?

% ========= generate =======================
if model
	x = signal_generate(	1,	\  %PRN
					1,	\  % freq delta in Hz
					1,	\  % CA phase
					10,	\  % snr, dB
					DumpSize);
	fprintf('Generated\n');
else
	%x = readdump_txt('./data/flush.txt', DumpSize);	% create data vector
	x = readdump_bin_2bsm('./data/flush.bin', DumpSize);
	fprintf('Real\n');
end
% ========= generate =======================

% calculate threshold

sat_acx_val = zeros(length(PRN_range), 4) ;		% [acx, ca_phase, freq, detected state]

for k=PRN_range
	sat_acx_val(k, :) = acq_fft(x, k, fs, debug_me);
	%sat_acx_val(k, :) = acq_fft(x, k, 4.092e6, t);
	fprintf('%02d: acx=%15.5f shift_ca=%05d freq:%4.1f \n', \
		k,
		sat_acx_val(k, 1),
		sat_acx_val(k, 2),
		sat_acx_val(k, 3),
	);
end

% check for vector length - we want to work just with 1 satellite
% if more than 1, just show barh() and exit
if length(PRN_range) > 1
	barh(sat_acx_val((1:32),1)),
		grid on,
		title('Correlation with DFT', 'Fontsize', 18),
		ylim([0 ,33]);
	return;
endif;

return
	
% need proper phase estimation
fr_fine = acq_fine_freq_estimation( x,			
				PRN_range,		
				sat_acx_val(PRN_range, 3),			% freq
				sat_acx_val(PRN_range, 2),			% CA phase
				0);						% trace me
%x_lo = x(6:end);
%acq_serial(x_lo, 1, sat_acx_val(1, 3), 1);

% make simple filter
fprintf('fine freq  freq:%03.05f\n', fr_fine);
ca16 = ca_get(PRN_range, 0);				% generate C/A code
ca16 = repmat(ca16, 5, 1); 

Fc=400 ;
[b,a]=butter(2, Fc/(16.368e6/2));

data_5ms = x(sat_acx_val(PRN_range, 2) : sat_acx_val(PRN_range, 2) + 5*N-1);
data_5ms = ca16 .* data_5ms ;

sig = data_5ms.' .* exp(j*2*pi * fr_fine *ts * (0:5*N-1)) ;
sig=filter(b,a,sig);

plot(real(sig));