%    C/A resampling code 1.023 MHz => 16.368 MHz
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

%%%%%%%%%%%%%%%%%%%%%%
%      Resampling C/A code
%%%%%%%%%%%%%%%%%%%%%%

% FIXME - add delay support

function ca = ca_get(PRN, trace_me)

fs = 16.368e6;			% sampling rate GPS data in Hz
fc =   1.023e6;			% sampling rate C/A in Hz

% we know that in out case fs/fc = integer digit
ca_bits = ca_generate_bits(PRN, trace_me) ;
b = fs / fc;
ca_16 = zeros(length(ca_bits)*b, 1);
%ca_16 = zeros(16368, 1);

for i=1:length(ca_bits)
	for j = 1:b
		ca_16((i-1)*b + j) = ca_bits(i)  ;
	end
end

ca = ca_16;

%plot(xcorr(ca_16))