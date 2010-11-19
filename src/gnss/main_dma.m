PRN = 1:32;
fs = 4.092e6-1e3 : 1e3 : 4.092e6+1e3;
%fs = 4.092e6;
trace_me = 0;
DumpSize = 16368*3 ;

model = 0;				% is it model

% ========= generate =======================
if model
   x_ca16 = ca_get(1, 0) ;
   x_ca16 = [x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;
       x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;
       x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;
       x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;
       x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16;x_ca16] ;
   x = exp(2*j*pi*4092000/16368000*(0:length(x_ca16)-1)).' ;

    delta = 199 ;
    x = cos(2*pi*(4092000 + delta)/16368000*(0:length(x_ca16)-1)).' ;
    %bit_shift = round(abs(rand(1)*(length(x)-1))) ;
    %x(bit_shift:end)=x(bit_shift:end) * (-1) ;
    %x(length(x)/2+1000:end)=x(length(x)/2+1000:end) * (-1) ;
    x = x .* x_ca16 ;
    x = x(101:end);
    x=x+randn(size(x))*2 ;
    fprintf('Generated\n');
else
	x = readdump_bin_2bsm('./data/flush.bin', DumpSize);
end
% ========= generate =======================

acx = zeros(length(PRN), 2);
freq_sat = zeros(length(PRN), 1);
acx_local = zeros(2, 2);

%for k = PRN
for k = PRN
		
	%acx_local(2) = 0;
	
	%for t = fs
		 %acx_local = acq_dma(x, PRN(k), t, trace_me);
		 acx(k, :)= acq_dma(x, PRN(k), trace_me);
		 %acx(k, :) = acx_local;
		 %if( acx(k, 2) < acx_local(2))
		 	%freq_sat(k) = t;
		 	%acx(k, :) = acx_local;
	 	%endif
	%end
	
	fprintf('%02d: acx=%15.5f shift_ca=%05d\n', k, acx(k,2), acx(k, 1));
end

barh(acx(:, 2));