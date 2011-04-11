% File: c9 MCBPSK.m
snrdB_min = -3; snrdB_max = 8;
% SNR (in dB) limits
snrdB = snrdB_min:1:snrdB_max;
Nsymbols = input('Enter number of symbols > ');
snr = 10.^(snrdB/10);
% convert from dB
%h = waitbar(0, 'SNR Iteration');

len_snr = length(snrdB);
for j=1:len_snr
% increment SNR
%waitbar(j/len_snr)
sigma = sqrt(1/(2*snr(j)));
% noise standard deviation
error_count = 0;
for k=1:Nsymbols
% simulation loop begins
d = round(rand(1));
% data
% transmitter output
x_d = 2*d - 1;
% noise
n_d = sigma*randn(1);
y_d = x_d + n_d;
% receiver inpt
if y_d > 0
% test condition
% conditional data estimate
d_est = 1;
else
% conditional data estimate
d_est = 0;
end
if (d_est ~= d)
error_count = error_count + 1; % error counter
end
end % simulation loop ends
% store error count for plot
errors(j) = error_count;
end
%close(h)
% BER estimate
ber_sim = errors/Nsymbols;
%ber_theor = q(sqrt(2*snr));
ber_theor = 0.5*erfc(sqrt(10.^(snr/10))); % theoretical ber
% theoretical BER
semilogy(snrdB,ber_theor,snrdB,ber_sim,'o')
%semilogy(snrdB,ber_sim,'o')
axis([snrdB_min snrdB_max 0.0001 1])
xlabel('SNR in dB')
ylabel('BER')
legend('Theoretical','Simulation')
% End of script file.
