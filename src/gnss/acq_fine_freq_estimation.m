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
	fprintf('[acq_fine_freq_estimation] SVN:%02d shift_ca=%05d freq:%4.1f\n',
		PRN,
		ca_phase,
		FR);
end

N = 16368 ;
ts = 1/16.368e6 ;

if length(x) < N*5
	fprintf('[ERR] cannot estimate phase, because signal is < 5ms');
	return;
endif;

ca16 = ca_get(PRN, trace_me);				% generate C/A code
ca16 = repmat(ca16, 5, 1);
lo_x = zeros(N, 1);

% adjust to +- 400Hz
fr = zeros(3,1) ;
for i=[1:3]
	fr(i) = FR - 400 + (i - 1) * 400 ; 			% in Hz
end

% calculate early-prompt-late correlation in the +- 400Hz area
for i=[1:3]
	lo_sig = exp(j*2*pi * fr(i)*ts *(0:2*N-1)).';

	lo_x = lo_sig(ca_phase : ca_phase + N - 1) .* ca16(ca_phase : ca_phase + N - 1);
	acx = sum(lo_x .* x(1:N)) ;
	
	acx = acx .* conj(acx); 
	max_bin_freq(i) = acx / N;		% FIXME
	
	if (trace_me == 1)
		fprintf('\t%d:FR:%d \t acx=%15.5f\n', i, fr(i), max_bin_freq(i));
	endif;
end	% for i=[1:3]

% adjust freq in freq bin
[acx, k] = max(max_bin_freq) ;
FR = fr(k);
if trace_me == 1
	fprintf('\t New FR=%4.1f \n', FR);
endif;

% phase estimation
data_5ms = x(ca_phase : ca_phase + 5*N-1); 

% despread
data_5ms = ca16 .* data_5ms ;

% downconvert to the baseband and calculate phase
sig = data_5ms.' .* exp(j*2*pi * FR *ts * (0:5*N-1)) ;
%sig = data_5ms.' .* cos(j*2*pi * FR *ts * (0:5*N-1)) ;
phase = diff(-angle(sum(reshape(sig, N, 5))));
phase_fix = phase;

threshold = (2.3*pi)/5 ; 		% FIXME - check this. freq: 408.60

if trace_me == 1
	fprintf('\t threshold:%02.03f\n\tphase => \n', threshold);
	%phase
endif;

for i=1:4
      if trace_me == 1
      		fprintf('\t %d: phase:%01.03f freq:%03.05f\n',
      			i, phase(i), phase(i)/2*pi * 180 );
      endif;
      
      if(abs(phase(i))) > threshold
          phase(i) = phase_fix(i) - sign(phase(i))* 2 * pi ;
          if trace_me == 1
      		fprintf('\t\t %d: phase:%01.03f freq:%03.05f\n',
      			i, phase(i), phase(i)/2*pi * 180 );
	endif;
          
          if(abs(phase(i))) > threshold
              phase(i) = phase(i) - sign(phase(i)) * pi ;
              if trace_me == 1
      		fprintf('\t\t\t %d: phase:%01.03f freq:%03.05f\n',
      			i, phase(i), phase(i)/2*pi * 180 );
	    endif;
           
              if(abs(phase(i))) > threshold
                  phase(i) = phase_fix(i) - sign(phase(i))* 2 * pi ;
                  if trace_me == 1
      		fprintf('\t\t\t %d: phase:%01.03f freq:%03.05f\n',
      			i, phase(i), phase(i)/2*pi * 180 );
	        endif;
              endif;
              
          endif;
      endif;
end;		% for i=1:4

dfrq = mean(phase)*1000 / (2*pi) ;

if (trace_me == 1)
	fprintf('[acq_fine_freq_estimation] freq.:%5.1f phase_FREQ.%03.02f real= %5.1f exit...\n', FR, dfrq, FR + dfrq) ;
end %if (trace_me == 1)  

res = FR + dfrq;
  
end		% function res = acq_fine_freq_part()
