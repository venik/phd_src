% simple convolution POC

function out = my_conv(a,b)
	fprintf('My convolution\n');
	
	N = length(a);
	M = length(b);
	NM = N+M-1;
	
	b_res = zeros(1, NM);
	b_res(1:M) = b;
	out = zeros(1, NM);
	a_res = zeros(1, NM);
	a_res(1:N) = a;

	
	fprintf('Resulted vector will be %d\n',  NM);

	for n=1:NM	
		%fprintf('[%d]\n', n) ;
		for m = 1:n
			%fprintf('\t[%d] b_idx = %d\n', m, n-m+1) ;
			out(n) = out(n) + a_res(m)*b_res(n-m+1) ;
		end
	end

	fprintf('My variant \n'); out
	fprintf('Buildin variant \n'); conv(a,b)
	
end