clc; clear all;

addpath('../tsim/model/');

sigma = 1 ;
Fd = 16.368e6 ;
Delta = 1/Fd ;

SNR_dB = -30:1:5 ;
SNR_range = 10.^(SNR_dB ./ 10) ;

%%%%%%%%%%%%%%%%%%%%%%%%
% ACF boost
N = 16368 ;
Fs = 4 ;    
BT = N / Fs ;

SNR3 = zeros(length(SNR_dB), 1) ;

for kk=1:length(SNR_range)
    SNR1 = 2 * BT * SNR_range(kk) / (2 + 1/SNR_range(kk) ) ;
    SNR2 = 2 * BT * SNR1 / (2 + 1/SNR1 ) ;
    SNR3(kk) = 2 * BT * SNR2 / (2 + 1/SNR2 ) ;
end ;

SNR3_dB = 10 * log10(SNR3) ;

E = SNR3;
phi = 0 ;
i = 1:N ;
f = 4.092e6 ;

SNR = 1/sigma^2 ;
b22_parameter = zeros(length(E), 1) ;

for ff = 1:length(E)
    A = sqrt(2*E(ff)) ;
    
    phase = 2*pi*f*Delta.*i + phi ;
    B11 = sum(SNR .* (sin(phase)).^2) ;
    B22 = sum(SNR .* (2 * pi * Delta .* i * A .* cos(phase)).^2) ;
    B33 = sum(SNR .* (A*cos(phase)).^2) ;
    B12 = sum(SNR .* (2 * pi * Delta .* i * A) .* sin(phase) .* cos(phase)) ;
    B13 = sum(SNR .* A .* sin(phase) .* cos(phase)) ;
    B23 = sum(SNR .* (2*pi*Delta.*i .*(A*cos(phase)).^2)) ;
    B = [B11 B12 B13 ; B12 B22 B23 ; B13 B23 B33] ;
    B = inv(B) ;
    
    b22_parameter(ff) = B(2,2) ;
end ;

%load('../acf/freq_sko_ar.mat')
load('../acf/acf_ar_sko_300000.mat')
%plot(SNR_db, sqrt(b22_parameter))
%    phd_figure_style(gcf) ;

% cut high SNR, was read from the file
SNR_dB = SNR_dB(1:36);

% eq from
% Single-Tone Parameter Estimation from Discrete-Time Observations
% DAVID C. RIFE, ROBERT R. BOORSTYN
%var_omega = 6 ./ (SNR3 .* N * (N^2-1)) ;
var_omega = 12 ./ (SNR3 .* N * (N^2-1)) ;

figure(1)
hold off, semilogy(SNR_dB, sqrt(var_omega), '-mx')
hold on,  semilogy(  SNR_dB, freq1(1:length(SNR_dB)), '-go', ...
                    SNR_dB, freq2(1:length(SNR_dB)), '-b*', ...
                    SNR_dB, freq3(1:length(SNR_dB)), '-r+') ,
    %legend('������� �������-���', '1 ��������','2 ��������','3 ��������') ,
    legend('������� �������-���', '1 ��������','2 ��������','3 ��������')
    xlabel('���, ��') ,
    ylabel('��') ,
    xlim([SNR_dB(1) SNR_dB(end)])
    phd_figure_style(gcf) ;    


rmpath('../tsim/model/');
    