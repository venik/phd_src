function [b,poles] = lpcmodel(x,P)
N = length(x) ;

M = P+1 ;
rxx = zeros(M,1) ;
for k=1:M
    for m=1:1:N-P
        rxx(k) = rxx(k) + x(m)*x(m+k-1) ;
    end
end
rxx = rxx/(N-M-1) ;

Rxx = zeros(P,P) ;
for r=1:1:P
    for c=1:1:r-1
        Rxx(r,c) = rxx(r-c+1) ;
    end
    for c=r:1:P
        Rxx(r,c) = rxx(c-r+1) ;
    end
end
b = pinv(Rxx)*rxx(2:end) ;
b = [1;-b] ;
poles = roots(b) ;
