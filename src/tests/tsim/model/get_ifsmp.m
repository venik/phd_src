function ifsmp = get_ifsmp()
ifsmp.maxSats = 10 ;
ifsmp.sats   = 1:ifsmp.maxSats ;
ifsmp.snr_db = -5 ;
ifsmp.vars   = [1,1,1,0.7,0.6,0.6,0.3,0.3,0.3,0.1] ;
ifsmp.fs     = [4000,3200,4000,3800,3100,3200,3300,3400,3500,4500] ;
ifsmp.fd     = 16368 ;
ifsmp.delays = [100,150,200,60,90,190,320,210,200,260] ;
