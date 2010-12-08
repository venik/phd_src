clear all;
%sigma_n = 0.3 ;
sigma_n = 1 ;

N = 1024*64 ;
xp = sin(2*pi/64*(0:63)).' ;
x = repmat(xp,N/64,1) ;
%x(x>0.7) = 0.7 ;
%x(x<-0.7) = -0.7 ;

%plot(x) ;

%y = x+x+randn(size(x))*sigma_n+randn(size(x))*sigma_n ;
y = x+randn(size(x))*sigma_n ;

h = xp(end:-1:1) ;

offs = 45 ;
hold off, plot(1+offs:(length(y)+offs),y)

f = zeros(size(x)) ;
f = conv(h, y);
%for k=1:length(x)
%    for n=1:min(k,length(h))
%        f(k) = f(k) + h(n)*y(k-n+1) ;
%    end
%end

hold on, plot(f/(h'*conj(h)),'r-','Linewidth',2)

X = zeros(64,64) ;
for k=1:length(xp)
    %X(:,k) = 2*[xp(k:end);xp(1:k-1)] ;
    X(:,k) = [xp(k:end);xp(1:k-1)] ;
end
Rxx = X'*X/length(xp) ;

Es = h(end:-1:1)'*Rxx*h(end:-1:1) ;
%En = h(end:-1:1)'*eye(64)*(2*sigma_n)^2*h(end:-1:1) ;
En = h(end:-1:1)'*eye(64)*(sigma_n)^2*h(end:-1:1) ;
sigma_f = Es + En ;

fprintf('signal sigma:%f error sigma:%f\n', Es, En);

fprintf('estimated: %f  actual:%f  SNR:%f\n',sigma_f, var(f),10*log10(Es/En)) ;