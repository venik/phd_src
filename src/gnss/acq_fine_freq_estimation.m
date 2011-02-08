%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Fine frequency estimator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main idea described in the "Fundamentals of global positioning system receivers:
% a software approach" by James Bao-yen Tsui
% you can read this in in the Google online library:
%http://books.google.ru/books?id=HQCGPr7pGV8C&lpg=PR8&dq=Fine%20frequency%20estimation%20tsui%20gps%20books&hl=en&pg=PA146#v=onepage&q&f=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = acq_fine_freq_estimation(x, PRN, FR, ca_phase, trace_me)

if (trace_me == 1)
	fprintf('[acq_fine_freq_estimation] SVN:%02d\n', PRN);
end

N = 16368 ;
ts = 1/16.368e6 ;

if length(x) < N*5
	fprintf('[ERR] cannot estimate phase, because signal is < 5ms');
	return;
endif;

% +- 400 Hz in freq bin
phase_data = zeros(3,1) ;
data_5ms = x(ca_phase : ca_phase + 5*N-1);

sig = data_5ms.' .* exp(j*2*pi * FR *ts * (0:5*N-1)) ;
phase = diff(-angle(sum(reshape(sig, N, 5))));
phase_fix = phase;

threshold = (2.3*pi)/5 ; 

for i=1:4 ;
      %fprintf('\t %d => %f => %f\n', i, phase(i), phase(i)/2*pi * 180 );
      
      if(abs(phase(i))) > threshold ;
          phase(i) = phase_fix(i) - sign(phase(i))* 2 * pi ;
          %fprintf('\t\t %d => %f => %f\n', i, phase(i), phase(i)/2*pi * 180 );
          
          if(abs(phase(i))) > threshold ;
              phase(i) = phase(i) - sign(phase(i))* pi ;
              %fprintf('\t\t\t %d => %f => %f\n', i, phase(i), phase(i)/2*pi * 180 );
              
              if(abs(phase(i))) > threshold ;
                  phase(i) = phase_fix(i) - sign(phase(i))* 2 * pi ;
                  %fprintf('\t\t\t\t %d => %f => %f\n', i, phase(i), phase(i)/2*pi * 180 );
              end
          end
      end
  end

dfrq = mean(phase)*1000 / (2*pi) ;

if (trace_me == 1)
	fprintf('\%[acq_fine_freq_estimation] freq.:%5.1f phase_FREQ.%5.1f\n', FR, dfrq) ;
end %if (trace_me == 1)  


res = dfrq;
  
end		% function res = acq_fine_freq_part()
