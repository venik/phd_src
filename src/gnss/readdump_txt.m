%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Read data from text file, without any decoding, all decoding
%   proccessed in board_daemon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    Copyright (C) 2009	Alexey Melnikov melnikov.alexey[dog]rf-lab.org
%			 2010 Alex Nikiforov  nikiforov.alex[dog]rf-lab.org
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

% /* readdump(fname,nDumpSize) */
% /* function reads textual dump with I,Q samples */
% /* nDumpSize - number of samples to read */
% /* Status: almost tested */
function x = readdump_txt(fname,nDumpSize)
fprintf('file_read_txt\n')
bComplexData = 1 ;
x = zeros(nDumpSize,1) ;
f = fopen(fname,'r+t') ;
% /* read header */
%str = fgets(f) ;
%for n=1:nDumpSize
n = 1;

while( n ~= nDumpSize)

    if feof(f)
        fprintf('[readdump], Warning: End of file detected at sample %d\n',n) ;
        break ;
    end
    str = fgets(f) ;
    str_tr = strtrim(str) ;
    if str_tr(1)=='#'
        fprintf(str) ;
        continue ;
    end
    if bComplexData
        [v,k] = sscanf(str,'%d  %d') ;
        if k==2
           x(n) = v(1) + j*v(2) ;
        else
           fprintf('[readdump], Error: unknown format\n') ;
           break ;
        end
    else
        [v,k] = sscanf(str,'%d') ;
        if k==1
            x(n) = v(1) ;
        else
            fprintf('[readdump], Error: unknown format\n') ;
            break ;
        end
    end
    
    n=n+1;
end

fclose(f) ;