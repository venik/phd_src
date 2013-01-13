clc, clear all ;
N = 16368 ;
n2 = 10 ; % !!!
fsig = 3000 ;
x = cos(2*pi*fsig/16368*(0:N-1)) + randn(1,N)*sqrt(n2) ;
rxx = [x*circshift(x,0)';x*circshift(x',1);x*circshift(x',2)] ;
txx = [cos(2*pi*fsig/16368*0);cos(2*pi*fsig/16368*1);cos(2*pi*fsig/16368*2)]*N/2 ;
cxx = [txx(1)+n2*N;txx(2);txx(3)] ;
[rxx, txx, cxx]

% Utilize Newton iterations to compute 
% Signal Energy, Noise Energy and Frequency
z = [rxx(1)/2;rxx(1)/2;1] ;
tau = 1 ;
for n=1:10
    % Get Jacobian
    J = [1 1 0;...
        cos(z(3)*tau) 0 -tau*z(1)*sin(z(3)*tau);...
        cos(2*z(3)*tau) 0 -2*tau*z(1)*sin(2*z(3)*tau)] ;

    % Update solution
    z = z + pinv(J)* ...
        (-[z(1)+z(2)-rxx(1);z(1)*cos(z(3)*tau)-rxx(2);z(1)*cos(2*z(3)*tau)-rxx(3)]) ;
end

[z,[txx(1);n2*N;2*pi*fsig/16368]]

fprintf('Frequency: %f\n', mod(z(3)*16368/2/pi,16368/2)) ;
fprintf('Noise Enr: %f\n', z(2)/N) ;
fprintf('Signl Enr: %f\n', z(1)/N) ;