%    Simple GPS/Navstar generate function
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRN - satellite PRN number
% freq_delta - freq delta (doppler effect)
% ca_phase - C/A phase in incoming signal
% snr - signal to noise rate
% DumpSize - number of the samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FIXME - remove dummy var, it's just indicate that now we work with SNR
% instead of sigma and we need rework the old code
function res = signal_generate(PRN, freq_delta, ca_phase, snr, DumpSize, dummy)

fd= 16.368e6;		% 16.368 MHz
fs = 4.092e6;
N = 16368;

x_ca16 = ca_get(PRN, 0) ;
x_ca16 = repmat(x_ca16, DumpSize/N + 1, 1);

%delta = 199 ;
x = cos(2*pi*(fs + freq_delta)/fd*(0:length(x_ca16)-1)).' ;
    
    %bit_shift = round(abs(rand(1)*(length(x)-1))) ;
    %x(bit_shift:end)=x(bit_shift:end) * (-1) ;
    %x(length(x)/2+1000:end)=x(length(x)/2+1000:end) * (-1) ;
    
x = x .* x_ca16 ;
x = x(ca_phase:DumpSize + ca_phase - 1);

%wn = (sigma/sqrt(2)) * (randn(DumpSize, 1) + j * randn(DumpSize, 1));
%res = x + wn ;

res = awgn(x, snr, 'measured');
    
end   % function res = signal_generate(freq_delta, ca_phase, sigma)