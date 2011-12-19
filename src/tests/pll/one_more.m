clc, clear ;
N = 5e4 ;   % number of simulated points
dt = 0.001 ;   % simulation time step (integration step)
omega0 = 10 ; % unshifted local oscillator frequency
dOmega = 0 ;  % input frequency shift
phi = 1 ;  % input phase shift
% PLL parameters
Kd =  0.6 ;
K0 = 1 ;
Ki = 1;
Kp = 1 ;
x = zeros(N,1) ;
y = zeros(N,1) ;
e = zeros(N,1) ;
Int_x = 0 ;
Int_e = 0 ;
psi = zeros(N,1) ;
yn = 0 ;
for n=1:N
    t = (n-1)*dt ; % simulation time
    x(n) = Kd*(sin((omega0+dOmega)*t+phi)*yn) ;
    Int_x = Int_x + dt*x(n) ; % integrating x
    e(n) = Kp*x(n) + Ki*Int_x ;
    Int_e = Int_e + e(n)*dt ; % integrating e (VCO model)
    yn = cos((omega0)*t+K0*Int_e) ;
    y(n) = yn ;
    psi(n) = K0*Int_e ;
end
%sigphase = N0*B/(2*A0^2) ;
omega_r = sqrt(Kd*K0*Ki) ;
zeta = Kd*K0*Kp/2/omega_r ;
B = omega_r*(zeta+1/(4*zeta))/2 ;
tf = 4*dOmega^2/B^3 ;
tp = 1.3/B ;
clf ;
hold on ;
%plot([0 (N-1)*dt],[dOmega dOmega],'k-','LineWidth',1,'Color',[.6 .6 .6]) ;
%hold on,plot(0:dt:(N-1)*dt,e*K0), grid on, xlabel('t,sec','FontSize',14) ;
%sys = tf([Kd*K0*Kp Kd*K0*Ki],[1 Kd*K0*Kp Kd*K0*Ki]) ;
Kdf = Kd/2 ; % because 1/2sin(.)

sys = tf2sys([Kdf*K0*Kp Kdf*K0*Ki],[1 Kdf*K0*Kp Kdf*K0*Ki]);
[V, T] = step(sys) ;

plot(T, V, 0:dt:(N-1)*dt,psi), grid on, legend('step response', 'real phase');
%plot(psi), grid on;
hold off;
%hold on,plot(0:dt:(N-1)*dt,psi,'k-') ;
%hold on,plot(t0,sh*phi,'r-'), grid on ;
%ylabel('VCO input e(t)','FontSize',14) ;
%title('PLL simulation results','FontSize',14) ;