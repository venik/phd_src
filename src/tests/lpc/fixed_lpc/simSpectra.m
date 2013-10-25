clc, clear all ;

%addpath('../../../gnss/');
addpath('../../tsim/model/');

ifsmp.sats = [1] ;
ifsmp.vars = [1] ;
ifsmp.fs = [4.092e6] ;
ifsmp.fd = [16.368e6] ;
ifsmp.delays = [200] ;
ifsmp.snr_db = [100] ;

N = 1023*15 ;

[x, y, sats, delays, signoise] = get_if_signal(ifsmp) ;

[omega0, ca_shift, E, Hjw] = lpcs(y, get_ca_code16(N, ifsmp.sats), 0) ;
fprintf('freq:%8.2f\t CA_phase:%d\n', omega0*ifsmp.fd/2/pi, ca_shift ) ;

rmpath('../../tsim/model/');