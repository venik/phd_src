%    Top module for the Serial correaltor acuisition method
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

DumpSize = 16368*2 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
ts = 1/16.368e6 ;

time_offs = 100;
%PRN_range = 1:32 ;
PRN_range = 31 ;

model = 0;				% is it the model?

% ========= generate =======================
if model
	x = signal_generate(	1,	\  %PRN
					0,	\  % freq delta in Hz
					199,	\  % CA phase
					0,	\  % noise sigma
					DumpSize);
	fprintf('Generated\n');
else
	%x = readdump_txt('./data/flush.txt', DumpSize);				% create data vector
	x = readdump_bin_2bsm('./data/flush.bin', DumpSize);			% create data vector
	fprintf('Real\n');
end
% ========= generate =======================

% calculate threshold
X = fft(x(1:N));
threshold = std(X);
threshold = threshold * sqrt(-2 * log(10^(-3)));
fprintf('threshold = %f \n', threshold);

%data = x(100:32000);
sat_acx_val = zeros(32,3) ;		% [acx, ca_phase, freq]

for k=PRN_range
	sat_acx_val(k, :) = acq_fft(x, k, fs, 0);
	fprintf('%02d: acx=%15.5f shift_ca=%05d freq:%4.1f\n', \
		k,
		sat_acx_val(k, 1),
		sat_acx_val(k, 2),
		sat_acx_val(k, 3)
	);
	
	% get in dB scale
	%SNR = 10*log10(sat_acx_val(k, 1)/noise);
	%if( SNR > 3 )
	%	fprintf("presented [%d] satellite SNR=%d\n", k, SNR);
	%end % if( SNR > 3 )
end

bar(sat_acx_val((1:32),1)),
	grid on,
	title('Correlation', 'Fontsize', 18),
	ylim([0 ,33]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ===========================
% tsui phase magic
% ===========================
% get rid from possible phase change
if 0
fprintf('Fine freq part ===>     \n') ;

% +- 400 Hz in freq bin
phase_data = zeros(3,1) ;
PRN_sat = 31;
data_5ms = x(sat_acx_val(PRN_sat , 2): sat_acx_val(PRN_sat , 2) + 5*N-1);

sig = data_5ms.' .* exp(j*2*pi * sat_acx_val(PRN_sat, 3) *ts * (0:5*N-1)) ;
phase = diff(-angle(sum(reshape(sig, N, 5))));
phase_fix = phase;

threshold = (2.3*pi)/5 ; % FIXME / or \

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
phase_data(PRN_sat) =  sat_acx_val(PRN_sat, 3)  + dfrq;
  
fprintf('\t#PRN: %2d ff_FREQ.:%5.1f phase_FREQ.%5.1f\n', \
  		PRN_sat,
  		sat_acx_val(PRN_sat, 3),
  		phase_data(PRN_sat)
  ) ;
end