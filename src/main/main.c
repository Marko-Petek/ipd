#include <stdio.h>
#include <stdlib.h>
#include <uv.h>


int main()
{
	uv_loop_t *pLoop = malloc(sizeof(uv_loop_t));
	uv_loop_init(pLoop);

	printf("Now quitting.\n");
	uv_run(pLoop, UV_RUN_DEFAULT);

	uv_loop_close(pLoop);
	free(pLoop);
	return 0;
}

