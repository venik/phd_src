PRN = 1:32;
%PRN = 31:32;
trace_me = 0;
DumpSize = 16368*10 ;

model = 1;				% is it the model?

% ========= generate =======================
if model
	x = signal_generate(	1,	\  %PRN
					50,	\  % freq delta in Hz
					199,	\  % CA phase
					0.1,	\  % noise sigma
					DumpSize);
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