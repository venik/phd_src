#!/usr/bin/octave -qf

printf ("%s", program_name ());

fd = fopen("/tmp/flush", "r");

% read all stuff and convert it
x_binary = fread(fd, Inf, "int8", "ieee-le");

x = zeros(length(x_binary) * 4, 1);

idx = 1;
idx_b = 1;
for idx_b=1:length(x_binary)

    x(idx)     = bitshift(bitand(x_binary(idx_b), 0xc0), -6);
    x(idx + 1) = bitshift(bitand(x_binary(idx_b), 0x30), -4);
    x(idx + 2) = bitshift(bitand(x_binary(idx_b), 0x0c), -2);
    x(idx + 3) =          bitand(x_binary(idx_b), 0x03);

    %x(idx + 1) = x_binary(idx_b) & 0xbf;
    %x(idx + 2) = x_binary(idx_b) & 0xf3;
    %x(idx + 3) = x_binary(idx_b) & 0xfb;

    idx = idx + 4;
end

%x

% destroy
fclose(fd);
