#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

int main(void)
{
    int res;

    int fd = open("/tmp/flush", (O_RDWR|O_CREAT|O_TRUNC), (S_IWUSR|S_IRUSR|S_IRGRP|S_IWGRP));
    if ( fd < 0 ) {
	printf("[err] cannot open flush file. errno: %s", strerror(errno));
	exit(-1);
    }

    /* 2 bits per value = 4 vals per 1 octet */
    /* LSB->MSB 00 01 10 11 = 0x1b */
    uint8_t val = 0x1b ;

    for( res = 0; res < 128; res++)  {
	write(fd, &val, 1);
    }

    close(fd);

    return 0;
}
