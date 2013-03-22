clc, clear all ;

N = 1000 ;
shifts = zeros(N,1) ;
freqs = zeros(N,1) ;
H2Counter = 0 ;
H1Counter = 0 ;
H0Counter = 0 ;
for n=1:10000
    [shifts(n), freqs(n), p1, p1_noise] = simModel( n, -8, 'ENoise;ESignal' ) ;
    if p1_noise>10
        H0Counter = H0Counter+1 ;
    end
    if p1>10 && abs(shifts(n)-100)<16
        H1Counter = H1Counter+1 ;
    end
    if p1>10 && abs(shifts(n)-100)>16
        H2Counter = H2Counter+1 ;
    end
    
    fprintf('N=%4d: H0Counter:%4d, H1Counter: %4d, H2Counter: %4d\n', n, H0Counter, H1Counter, H2Counter ) ;
    
end