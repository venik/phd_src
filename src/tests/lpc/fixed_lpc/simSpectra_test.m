clc, clear all ;

%addpath('../../../gnss/');
addpath('../../tsim/model/');

N = 1023*15 ;
times = 100 ;

interference = 1 ; 

if interference == 0 
    ifsmp.sats = [1] ;
    ifsmp.vars = [1] ;
    ifsmp.fs = [4.092e6] ;
    ifsmp.fd = [16.368e6] ;
    ifsmp.delays = [200] ;
    SNR_db = [20:2.5:40] ;
else
    ifsmp.sats = [1, 2, 3] ;
    ifsmp.vars = [1, 1, 1] ;
    ifsmp.fs = [4.092e6, 4.095e6, 4.090e6] ;
    ifsmp.fd = 16.368e6 ;
    ifsmp.delays = [200, 300, 100] ;
    SNR_db = [20:2.5:40] ;
end ;

real_delta = zeros(length(SNR_db), 1) ; 

T = 10^-3 ;

%%%%%%%%%%%%%%%%%%
% without ACF
SNR = 10.^(SNR_db ./ 10) ;
marple_eq = 1.03 ./ (2*T*(3*SNR)) ;

for k = 1:length(SNR_db)
    fprintf('SNR: %2.2f\n', SNR_db(k)) ;
    for kk = 1:times
        ifsmp.snr_db = [SNR_db(k)] ;
        [x, y, sats, delays, signoise] = get_if_signal(ifsmp) ;
        [omega0, ca_shift, E, Hjw] = lpcs(y, get_ca_code16(N, ifsmp.sats), 0) ;
        %fprintf('freq:%8.2f\t CA_phase:%d\n', omega0*ifsmp.fd/2/pi, ca_shift ) ;

        real_delta(k) = real_delta(k) + (ifsmp.fs(1) - omega0*ifsmp.fd/2/pi) ^2 ;
    end % for kk
    
    real_delta(k) = sqrt(real_delta(k) ./ times) ;
    
end % for k

pll_base = repmat(18, length(SNR_db), 1) ;

figure(1) ,
    semilogy(SNR_db, real_delta, SNR_db, pll_base) ,
    xlabel('SNR, dB') ,
    ylabel('F, Hz') ,
    legend('Algorithm', 'Max frequency offset'),
    phd_figure_style(gcf) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath('../../tsim/model/');