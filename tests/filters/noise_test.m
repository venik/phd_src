clc, clear all ;

Fs = 16368e3 ;         % sampling in Hz
Fc = 50 ;              % lower bound        -0.707 dB
Fb = 60 ;              % higher bound       -30 dB

% convert to rad/sec
Wc = 2*pi*Fc ;
Wb = 2*pi*Fb ;
Ws = 2*pi*Fs ;

% generate AWGN
len = 1024;
awgn = randn(1, len*10);
%plot(awgn), grid on, xlim([1, len]) ;

% calculate filter
[N, Wn] = buttord(Wc, Wb, 0.707, 30, 's') ;
[b, a] = butter(N, Wn, 's') ;

fprintf('Filter N = %d, Wn = %f\n', N, Wn);

wa = 1:(70*2*pi) ;      % bcoz wa in rad/sec
h = freqs(b, a, wa) ;
y = 20*log10(abs(h)) ;
figure(1), plot(wa/(2*pi), y), grid on, ylabel('Gain [dB]'), xlabel('Freq response') ;

% filter it

filtered_awgn = filter(b, a, awgn) ;

% visualize
figure(2),
    plot(1:length(awgn), awgn, 'r', 1:length(filtered_awgn), filtered_awgn, 'g');