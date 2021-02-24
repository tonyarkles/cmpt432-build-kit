/*	main.c - This is where the main setup of the kernel will be done.  This 
 *	is all done in protected mode.  It includes initializing hardware,
 *	interrupts, multitasking, and our spawning off our first processe(s).
 */

void printk_bootstrap(const char* msg) {
  int i = 0;
  char* vid_mem_address = (char*)0xb8000;

  while(msg[i] != 0) {
    vid_mem_address[0] = msg[i];
    vid_mem_address[1] = 0x1F;
    vid_mem_address += 2;
    i++;
  }
}

void k_main()
{	
  printk_bootstrap("Hello from k_main");
spin:
	goto spin;
	return;
}

