#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "stdio.h"
#include "errno.h"
#include "config.h"

#include <netinet/in.h>
#include <sys/socket.h>

#ifdef PerlIO
typedef PerlIO * InputStream;
#else
#define PERLIO_IS_STDIO 1
typedef FILE * InputStream;
#define PerlIO_fileno(f) fileno(f)
#endif

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

MODULE = IO::Socket::Multicast	PACKAGE = IO::Socket

void
_mcast_add(sock,mcast_group,interface_addr="")
     InputStream sock
     char* mcast_group
     char* interface_addr
     PROTOTYPE: $$;$
     PREINIT:
     int fd;
     struct ip_mreq mreq;
     PPCODE:
     {
       fd = PerlIO_fileno(sock);
       if (!inet_aton(mcast_group,&mreq.imr_multiaddr))
         croak("Invalid address used for mcast group");
       if ((strlen(interface_addr) > 0)) {
	 if (!inet_aton(interface_addr,&mreq.imr_interface))
	   croak("Invalid address used for local interface");
       } else {
	 mreq.imr_interface.s_addr = INADDR_ANY;
       }
       if (setsockopt(fd,IPPROTO_IP,IP_ADD_MEMBERSHIP,(void*) &mreq,sizeof(mreq)) < 0)
	 XSRETURN_EMPTY;
       else
	 XSRETURN_YES;
     }

void
_mcast_drop(sock,mcast_group,interface_addr="")
     InputStream sock
     char* mcast_group
     char* interface_addr
     PROTOTYPE: $$;$
     PREINIT:
     int fd;
     struct ip_mreq mreq;
     PPCODE:
     {
       fd = PerlIO_fileno(sock);
       if (!inet_aton(mcast_group,&mreq.imr_multiaddr))
         croak("Invalid address used for mcast group");
       if ((strlen(interface_addr) > 0)) {
	 if (!inet_aton(interface_addr,&mreq.imr_interface))
	   croak("Invalid address used for local interface");
       } else {
	 mreq.imr_interface.s_addr = htonl(INADDR_ANY);
       }
       if (setsockopt(fd,IPPROTO_IP,IP_DROP_MEMBERSHIP,(void*)&mreq,sizeof(mreq)) < 0)
	 XSRETURN_EMPTY;
       else
	 XSRETURN_YES;
     }

int
mcast_loopback(sock,...)
     InputStream sock
     PROTOTYPE: $;$
     PREINIT:
     int fd,len;
     unsigned char previous,loopback;
     CODE:
     {
       fd = PerlIO_fileno(sock);
       /* get previous value of flag */
       len = sizeof(previous);
       if (getsockopt(fd,IPPROTO_IP,IP_MULTICAST_LOOP,(void*)&previous,&len) < 0)
	 XSRETURN_UNDEF;
       
       if (items > 1) { /* set value */
	 loopback = SvIV(ST(1));
	 if (setsockopt(fd,IPPROTO_IP,IP_MULTICAST_LOOP,&loopback,sizeof(loopback)) < 0)
	   XSRETURN_UNDEF;
       }
       RETVAL = previous;
     }
     OUTPUT:
       RETVAL

int
mcast_ttl(sock,...)
     InputStream sock
     PROTOTYPE: $;$
     PREINIT:
     int fd,len;
     unsigned char previous,ttl;
     CODE:
     {
       fd = PerlIO_fileno(sock);
       /* get previous value of flag */
       len = sizeof(previous);
       if (getsockopt(fd,IPPROTO_IP,IP_MULTICAST_TTL,(void*)&previous,&len) < 0)
	 XSRETURN_UNDEF;
       
       if (items > 1) { /* set value */
	 ttl = SvIV(ST(1));
	 if (setsockopt(fd,IPPROTO_IP,IP_MULTICAST_TTL,&ttl,sizeof(ttl)) < 0)
	   XSRETURN_UNDEF;
       }
       RETVAL = previous;
     }
     OUTPUT:
       RETVAL

void
_mcast_if(sock,...)
     InputStream sock
     PROTOTYPE: $;$
     PREINIT:
     int                fd,len;
     char*              addr;
     struct in_addr     ifaddr;
     struct ip_mreq     mreq;
     PPCODE:
     {
       fd = PerlIO_fileno(sock);
       if (items > 1) { /* setting interface */
	 addr = SvPV(ST(1),len);
	 if (inet_aton(addr,&ifaddr) == 0 )
	   XSRETURN_EMPTY;
	 if (setsockopt(fd,IPPROTO_IP,IP_MULTICAST_IF,(void*)&ifaddr,sizeof(ifaddr)) == 0)
	   XSRETURN_YES;
	 else
	   XSRETURN_NO;
       } else {  /* getting interface address */

	 /* freakin' bug in Linux -- IP_MULTICAST_IF returns a struct mreqn rather than
	    an in_addr (contrary to Stevens and the setsockopt()!  
	    We work around this by looking at size of returned thing and doing a 
	    ugly cast */

	 len = sizeof(mreq);
	 if (getsockopt(fd,IPPROTO_IP,IP_MULTICAST_IF,(void*) &mreq,&len) != 0)
	   XSRETURN_EMPTY;
	 
	 if (len == sizeof(mreq)) {
	   XPUSHs(sv_2mortal(newSVpv(inet_ntoa(mreq.imr_interface),0)));
	 } else if (len == sizeof (struct in_addr)) {
	   XPUSHs(sv_2mortal(newSVpv(inet_ntoa(*(struct in_addr*)&mreq),0)));
	 } else {
	   croak("getsockopt() returned a data type I don't understand");
	 }

       }
     }
