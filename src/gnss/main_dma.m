PRN = 1:32;
%PRN = 31:32;
trace_me = 0;
DumpSize = 16368*10 ;

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
	fprintf('Real\n');
end
% ========= generate =======================

acx = zeros(length(PRN), 2);

for k = PRN
	acx(k, :)= acq_dma(x, PRN(k), 33, 5, trace_me);
		
	fprintf('%02d: acx=%15.5f shift_ca=%05d\n', k, acx(k,2), acx(k, 1));
end

barh(acx(:, 2));