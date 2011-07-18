%    Signal detection based on 2 peaks
%    Copyright (C) 2010 - 2011 Alex Nikiforov  nikiforov.alex@rf-lab.org
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
%    Reference: this approach used in fastgps software

%    Input values:	x - data after correlation in time domain
%			trace_me - trace flag
%   Output values: max1 - first max
%			pos1 - position  of max1(phase of the first max - the highest)
%			max2 - second max
%			pos2 - position of the max2(phase of the second max)
			
function res = threshold_2max(x, trace_me)

if (trace_me == 1)
	fprintf('threshold_2max():\n' );
end

% get the first max
[max1, pos1] = max(x);
x(pos1) = -1;

% find second max, but it MUST be not closer than
% F discretisation / 1.023e6 (for 16.368e6 not closer than 16 samples)
% and we take in consider circullar corerlatuion 
% for example is first peak is on 1 position 16 samples to left and to the right
% may be from the same correlation point (remember that in 16.368e6 we have 16 
% points which corralte - 16 points in 1 C/A chip)
while 1 
	[max2, pos2] = max(x);
	x(pos2) = -1;
	tmp_pos = abs(pos1 - pos2);
	if( (tmp_pos > 16) && (tmp_pos < (16138-16)) ) 
		break
	end;
end;	% while

res = zeros(5, 1);
res(1) = max1;
res(2) = pos1;
res(3) = max2;
res(4) = pos2;

% check for the signal presence
if( max1/max2 > 10 )
	% detected
	res(5) = 1;
else
	% not detected
	res(5) = 0;
end; %if()

if (trace_me == 1)
	fprintf('max1 = %f pos1 = %05d max2 = %f pos2 = %05d\n', max1, pos1, max2, pos2);
	if  res(5) == 1
		fprintf('Detected\n');
	else
		fprintf('Not detected\n');
	end;	% if  res(5)
end
	
end 	% function