%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      C/A code generator for GPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    C/A code generator for GPS - generate C/A sequence
%    Copyright (C) 2010 Alex Nikiforov  nikiforov.pub[dog]gmail.com
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
%    we can implement XOR as multiply 
%
%   A XOR  B = C	A    *    B =  C
%   0         0 = 0	-1        -1 =  1
%   0         1 = 1	-1         1 = -1
%   1         0 = 1	 1        -1 = -1
%   0         1 = 0	 1         1 =  1
%
% {0, 1} => {1, -1}
%

function code_array = ca_generate_bits(PRN, trace_me)

if (trace_me == 1)
	fprintf('[ca_generate_bits] SVN:%02d\n', PRN);
end
% Shits for sattelites
K = [ 2,6; 3,7; 4,8; 5,9; 1,9; 2,10;1,8;2,9;3,10;2,3;3,4;5,6;6,7;7,8;8,9;9,10;...
    1,4;2,5;3,6;4,7;5,8;6,9;1,3;4,6;5,7;6,8;7,9;8,10;1,6;2,7;3,8;4,9] ;
    
k1 = K(PRN, 1);
k2 = K(PRN, 2);

g1 = (-1) * ones(10, 1);
g2 = (-1) * ones(10, 1);

code_array = [];

for k=1:1023
	code_array = [code_array; g1(10) * (g2(k1) * g2(k2)) ];
	
	% update G1 shift registers
	g1_1 = g1(10) * g1(3);
	g1(2:10) = g1(1:9);
	g1(1) = g1_1;
	
	% update G2 shift registers
	g2_1 = g2(2) * g2(3) * g2(6) * g2(8) * g2(9) * g2(10) ;
	g2(2:10) = g2(1:9);
	g2(1) = g2_1;
	
end

if (trace_me == 1)
	% we can our generator via the first 10 bits
	% refer to Tsui book, chapter 5
	% but first we must map {1, -1} => {0, 1}
	code_array_n =  abs((code_array - 1) ./ (-2));
	% code_array(1:10)
	val =	(1*code_array_n(1))*512	+       ...
		(4*code_array_n(2) +                ...
	 	 2*code_array_n(3) +                ...
 	 	 1*code_array_n(4))*64 	+           ...
		(4*code_array_n(5) +                ...
	 	 2*code_array_n(6) +                ...
	  	 1*code_array_n(7))*8 	+           ...
		(4*code_array_n(8) +                ...
		 2*code_array_n(9) +                ...
		 1*code_array_n(10))*1;
	
	fprintf('PRN:%d val:%o\n', PRN, val);
end %if 0

end % function code_array = ca_generate_bits(PRN)