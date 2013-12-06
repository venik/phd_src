clc, clear all ;

%addpath('../../../gnss/');
addpath('../../tsim/model/');

N = 1023 ;
ntimes = 400 ;
SNR_dB = [10:1:40] ;
%SNR_dB = 40 ;

interference = 0 ; 

ifsmp.snr_db = 0 ;
if interference == 0 
    ifsmp.sats = [1] ;
    ifsmp.vars = [1] ;
    ifsmp.fs = [4.092e6] ;
    ifsmp.fd = [16.368e6] ;
    ifsmp.delays = [200] ;
else
    ifsmp.sats = [1, 2, 3] ;
    ifsmp.vars = [1, 1, 1] ;
    ifsmp.fs = [4.092e6, 4.095e6, 4.090e6] ;
    ifsmp.fd = 16.368e6 ;
    ifsmp.delays = [200, 300, 100] ;
end ;

freq = zeros(length(SNR_dB), 1) ; 
init_rand(1) ;

ifsmps = repmat(ifsmp,numel(SNR_dB),1) ;
matlabpool open 8 ;

parfor k = 1:length(SNR_dB)
    fprintf('SNR: %2.2f\n', SNR_dB(k)) ;
    ifsmps(k).snr_db = SNR_dB(k) ;
    for kk = 1:ntimes
        [x, y, sats, delays, signoise] = get_if_signal(ifsmps(k)) ;
        y = y(1:16368) ;
        [omega0, ca_shift, E, Hjw] = lpcs(y, get_ca_code16(N, ifsmps(k).sats), 0) ;
        %fprintf('freq:%8.2f\t CA_phase:%d\n', omega0*ifsmp.fd/2/pi, ca_shift ) ;
        
        freq(k) = freq(k) + (omega0*ifsmps(k).fd/2/pi - ifsmps(k).fs)^2 ;
    end % for kk
    
    freq(k) = sqrt(freq(k) / ntimes) ;

end % for k

matlabpool close ;

figure(1) ,
    semilogy(SNR_dB, freq, '-r+') ,
    title('SKO') ,
    xlabel('SNR, dB') ;
    ylabel('f') ;
    phd_figure_style(gcf) ;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath('../../tsim/model/');