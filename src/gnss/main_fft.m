clc; clear all;

DumpSize = 16368*6 ;
%DumpSize = 100 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
ts = 1/16.368e6 ;

time_offs = 100;
%PRN_range = 1:32 ;
PRN_range = 31 ;

%x = readdump_txt('./data/flush.txt', DumpSize);				% create data vector
x = readdump_bin_2bsm('./data/flush.bin', DumpSize);				% create data vector

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
end

barh(sat_acx_val((1:32),1)), grid on, title('Correlation', 'Fontsize', 18), ylim([0 ,33]);
%print -deps 'corr_bar.eps'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ===========================
% tsui phase magic
% ===========================
% get rid from possible phase change
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