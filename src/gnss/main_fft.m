clc; clear all;

DumpSize = 16368*3 ;
N = 16368 ;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
%ts = 1/fs ;

time_offs = 100;
PRN_range = 1:32 ;

x = file_read_txt('./data/flush', N);				% create data vector
%data = x(100:32000);
sat_acx_val = zeros(32,1) ;

for k=PRN_range
	acx = acq_fft(x, k, fs, 0);
	sat_acx_val(k) = acx(1);
	fprintf('%02d: acx=%15.5f shift_ca=%05d freq:%4.1f\n', k, acx(1), acx(2), acx(3));
end

barh(sat_acx_val((1:32),1)), grid on, title('Correlation');