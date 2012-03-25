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

clc; clear all; clf;

% LPC related
P = 2 ;        % order of LPC analysis

% Signal related
DumpSize = 16368*6 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
fs = 16.368e6;
ts = 1/fs ;

%PRN_range = 1:32 ;
PRN_range = 1 ;
model = 1;				% is it the model?

% ========= generate =======================
if model
	x = signal_generate(	1,	\  %PRN
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

ca_base = ca_get(PRN_range, 0);		% generate C/A code
%ca_base = repmat(ca_base, 2, 1);

%[freq,E] = lpcs(tx(16369-ca_error:16368*2-ca_error),code(1:16368)) ;
[freq,E] = acq_lpcs(x(1:N), ca_base) ;
%plot(freq*fd/2/pi), grid on ;
plot(E),grid on ;
[~,ca_shift] = max(E) ;
f = freq(ca_shift) ;
fprintf('freq:%8.2f,  pwr:%5.2f, k:%4d\n', f*fs/2/pi, E(ca_shift), ca_shift-1 ) ;