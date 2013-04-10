function [preciseFreq, precisePower] = get_precise_frequency2(signal2ms, initialFreq, samplingFreq)
% estimation parameters
n1 = 14 ;
n2 = 15 ;
Nnw = 12 ; % Number of Newton iterations

% estimation algorithm
msSamples = length(signal2ms)/2 ;

% estimate rxx
totalPower = sum(signal2ms(1:msSamples).*conj(signal2ms(1:msSamples)))/msSamples ;
r1 = sum(signal2ms(1:msSamples).*conj(signal2ms(1+n1:msSamples+n1)))/msSamples ;
r2 = sum(signal2ms(1:msSamples).*conj(signal2ms(1+n2:msSamples+n2)))/msSamples ;

z = zeros(2,Nnw) ;
initialPower = totalPower*.8 ;
InitialAlpha = 2*pi*initialFreq/samplingFreq*n1 ;
z(:,1) = [initialPower InitialAlpha] ;
for n=2:Nnw
    N_gamma = z(1,n-1) ;
    N_alpha = z(2,n-1) ;
    F = [N_gamma*cos(N_alpha)-r1; N_gamma*cos(n2/n1*N_alpha)-r2] ;
    J = [cos(N_alpha),        -N_gamma*sin(N_alpha); ...
         cos(n2/n1*N_alpha),  -n2/n1*N_gamma*sin(n2/n1*N_alpha)] ;
    z(:,n) = z(:,n-1) - pinv(J)*F ;
end

preciseFreq = z(2,end)/2/pi*samplingFreq/n1 ;
precisePower = z(1,end) ;
