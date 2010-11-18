PRN = 1:32;
fs = 4.092e6-5e3 : 1e3 : 4.092e6+5e3;
%fs = 4.092e6;
trace_me = 0;
DumpSize = 16368*2 ;

x = readdump_bin_2bsm('./data/flush.bin', DumpSize);

acx = zeros(length(PRN), 2);
freq_sat = zeros(length(PRN), 1);
acx_local = zeros(2, 2);

for k = PRN
		
	acx_local(2) = 0;
	
	for t = fs
		 acx_local = acq_dma(x, PRN(k), t, trace_me);
		 if( acx(k, 2) < acx_local(2))
		 	freq_sat(k) = t;
		 	acx(k, :) = acx_local;
	 	endif
	end
	
	fprintf('%02d: acx=%15.5f shift_ca=%05d freq:%4.1f\n', k, acx(k,2), acx(k, 1), freq_sat(k));
end

barh(acx(:, 2));