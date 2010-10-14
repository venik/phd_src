function ca = ca_get(PRN, trace_me)

fs = 16.368e6;			% sampling rate GPS data in Hz
fc =   1.023e6;			% sampling rate C/A in Hz

% we know that in out case fs/fc = integer digit
ca_bits = ca_generate_bits(PRN, 0) ;
b = fs / fc;
ca_16 = zeros(length(ca_bits)*b, 1);
%ca_16 = zeros(16368, 1);

for i=1:length(ca_bits)
%for i=1:1
	for j = 1:b
		ca_16((i-1)*b + j) = ca_bits(i)  ;
	end
end

ca = ca_16;

%plot(xcorr(ca_16))