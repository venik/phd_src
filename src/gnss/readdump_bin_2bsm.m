%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Decode data from binary file  to Octave vector, 2 bit sign magnitude mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    Copyright (C) 2010 Alex Nikiforov  nikiforov.alex[dog]rf-lab.org
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

#!/usr/bin/octave -qf
function x = readdump_bin_2bsm(fname,nDumpSize)
fprintf('readdump_bin()\n')

gps_value = [2; 6; -2; -6];

%printf ("%s", program_name ());

fd = fopen(fname, "r");
fseek(fd, 327, SEEK_SET);

% read all stuff and convert it
x_binary = fread(fd, nDumpSize, "uint8", "ieee-le");
x = zeros(length(x_binary)/2, 1);

idx = 1;
idx_b = 1;
for idx_b=1:nDumpSize
    imag2 = gps_value(bitshift(bitand(x_binary(idx_b), 0xc0), -6) + 1);
    real2   = gps_value(bitshift(bitand(x_binary(idx_b), 0x30), -4) + 1) ;
    imag1 = gps_value(bitshift(bitand(x_binary(idx_b), 0x0c), -2) + 1) ;
    real1   = gps_value(bitand(x_binary(idx_b), 0x03) + 1);
    
    x(idx) = real1 + j*imag1;
    x(idx + 1) = real2 + j*imag2;
    
    idx = idx + 2;
end

% destroy
fclose(fd);
