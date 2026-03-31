
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2a8080e7          	jalr	680(ra) # 2b0 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	2a2080e7          	jalr	674(ra) # 2b8 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	328080e7          	jalr	808(ra) # 348 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  32:	87aa                	mv	a5,a0
  34:	0585                	addi	a1,a1,1
  36:	0785                	addi	a5,a5,1
  38:	fff5c703          	lbu	a4,-1(a1)
  3c:	fee78fa3          	sb	a4,-1(a5)
  40:	fb75                	bnez	a4,34 <strcpy+0xa>
    ;
  return os;
}
  42:	60a2                	ld	ra,8(sp)
  44:	6402                	ld	s0,0(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret

000000000000004a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4a:	1141                	addi	sp,sp,-16
  4c:	e406                	sd	ra,8(sp)
  4e:	e022                	sd	s0,0(sp)
  50:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  52:	00054783          	lbu	a5,0(a0)
  56:	cb91                	beqz	a5,6a <strcmp+0x20>
  58:	0005c703          	lbu	a4,0(a1)
  5c:	00f71763          	bne	a4,a5,6a <strcmp+0x20>
    p++, q++;
  60:	0505                	addi	a0,a0,1
  62:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	fbe5                	bnez	a5,58 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  6a:	0005c503          	lbu	a0,0(a1)
}
  6e:	40a7853b          	subw	a0,a5,a0
  72:	60a2                	ld	ra,8(sp)
  74:	6402                	ld	s0,0(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strlen>:

uint
strlen(const char *s)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e406                	sd	ra,8(sp)
  7e:	e022                	sd	s0,0(sp)
  80:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  82:	00054783          	lbu	a5,0(a0)
  86:	cf91                	beqz	a5,a2 <strlen+0x28>
  88:	00150793          	addi	a5,a0,1
  8c:	86be                	mv	a3,a5
  8e:	0785                	addi	a5,a5,1
  90:	fff7c703          	lbu	a4,-1(a5)
  94:	ff65                	bnez	a4,8c <strlen+0x12>
  96:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  9a:	60a2                	ld	ra,8(sp)
  9c:	6402                	ld	s0,0(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret
  for(n = 0; s[n]; n++)
  a2:	4501                	li	a0,0
  a4:	bfdd                	j	9a <strlen+0x20>

00000000000000a6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e406                	sd	ra,8(sp)
  aa:	e022                	sd	s0,0(sp)
  ac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ae:	ca19                	beqz	a2,c4 <memset+0x1e>
  b0:	87aa                	mv	a5,a0
  b2:	1602                	slli	a2,a2,0x20
  b4:	9201                	srli	a2,a2,0x20
  b6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  be:	0785                	addi	a5,a5,1
  c0:	fee79de3          	bne	a5,a4,ba <memset+0x14>
  }
  return dst;
}
  c4:	60a2                	ld	ra,8(sp)
  c6:	6402                	ld	s0,0(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strchr>:

char*
strchr(const char *s, char c)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
  for(; *s; s++)
  d4:	00054783          	lbu	a5,0(a0)
  d8:	cf81                	beqz	a5,f0 <strchr+0x24>
    if(*s == c)
  da:	00f58763          	beq	a1,a5,e8 <strchr+0x1c>
  for(; *s; s++)
  de:	0505                	addi	a0,a0,1
  e0:	00054783          	lbu	a5,0(a0)
  e4:	fbfd                	bnez	a5,da <strchr+0xe>
      return (char*)s;
  return 0;
  e6:	4501                	li	a0,0
}
  e8:	60a2                	ld	ra,8(sp)
  ea:	6402                	ld	s0,0(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret
  return 0;
  f0:	4501                	li	a0,0
  f2:	bfdd                	j	e8 <strchr+0x1c>

00000000000000f4 <gets>:

char*
gets(char *buf, int max)
{
  f4:	711d                	addi	sp,sp,-96
  f6:	ec86                	sd	ra,88(sp)
  f8:	e8a2                	sd	s0,80(sp)
  fa:	e4a6                	sd	s1,72(sp)
  fc:	e0ca                	sd	s2,64(sp)
  fe:	fc4e                	sd	s3,56(sp)
 100:	f852                	sd	s4,48(sp)
 102:	f456                	sd	s5,40(sp)
 104:	f05a                	sd	s6,32(sp)
 106:	ec5e                	sd	s7,24(sp)
 108:	e862                	sd	s8,16(sp)
 10a:	1080                	addi	s0,sp,96
 10c:	8baa                	mv	s7,a0
 10e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 110:	892a                	mv	s2,a0
 112:	4481                	li	s1,0
    cc = read(0, &c, 1);
 114:	faf40b13          	addi	s6,s0,-81
 118:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 11a:	8c26                	mv	s8,s1
 11c:	0014899b          	addiw	s3,s1,1
 120:	84ce                	mv	s1,s3
 122:	0349d663          	bge	s3,s4,14e <gets+0x5a>
    cc = read(0, &c, 1);
 126:	8656                	mv	a2,s5
 128:	85da                	mv	a1,s6
 12a:	4501                	li	a0,0
 12c:	00000097          	auipc	ra,0x0
 130:	1a4080e7          	jalr	420(ra) # 2d0 <read>
    if(cc < 1)
 134:	00a05d63          	blez	a0,14e <gets+0x5a>
      break;
    buf[i++] = c;
 138:	faf44783          	lbu	a5,-81(s0)
 13c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 140:	0905                	addi	s2,s2,1
 142:	ff678713          	addi	a4,a5,-10
 146:	c319                	beqz	a4,14c <gets+0x58>
 148:	17cd                	addi	a5,a5,-13
 14a:	fbe1                	bnez	a5,11a <gets+0x26>
    buf[i++] = c;
 14c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 14e:	9c5e                	add	s8,s8,s7
 150:	000c0023          	sb	zero,0(s8)
  return buf;
}
 154:	855e                	mv	a0,s7
 156:	60e6                	ld	ra,88(sp)
 158:	6446                	ld	s0,80(sp)
 15a:	64a6                	ld	s1,72(sp)
 15c:	6906                	ld	s2,64(sp)
 15e:	79e2                	ld	s3,56(sp)
 160:	7a42                	ld	s4,48(sp)
 162:	7aa2                	ld	s5,40(sp)
 164:	7b02                	ld	s6,32(sp)
 166:	6be2                	ld	s7,24(sp)
 168:	6c42                	ld	s8,16(sp)
 16a:	6125                	addi	sp,sp,96
 16c:	8082                	ret

000000000000016e <stat>:

int
stat(const char *n, struct stat *st)
{
 16e:	1101                	addi	sp,sp,-32
 170:	ec06                	sd	ra,24(sp)
 172:	e822                	sd	s0,16(sp)
 174:	e04a                	sd	s2,0(sp)
 176:	1000                	addi	s0,sp,32
 178:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17a:	4581                	li	a1,0
 17c:	00000097          	auipc	ra,0x0
 180:	17c080e7          	jalr	380(ra) # 2f8 <open>
  if(fd < 0)
 184:	02054663          	bltz	a0,1b0 <stat+0x42>
 188:	e426                	sd	s1,8(sp)
 18a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18c:	85ca                	mv	a1,s2
 18e:	00000097          	auipc	ra,0x0
 192:	182080e7          	jalr	386(ra) # 310 <fstat>
 196:	892a                	mv	s2,a0
  close(fd);
 198:	8526                	mv	a0,s1
 19a:	00000097          	auipc	ra,0x0
 19e:	146080e7          	jalr	326(ra) # 2e0 <close>
  return r;
 1a2:	64a2                	ld	s1,8(sp)
}
 1a4:	854a                	mv	a0,s2
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	6902                	ld	s2,0(sp)
 1ac:	6105                	addi	sp,sp,32
 1ae:	8082                	ret
    return -1;
 1b0:	57fd                	li	a5,-1
 1b2:	893e                	mv	s2,a5
 1b4:	bfc5                	j	1a4 <stat+0x36>

00000000000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e406                	sd	ra,8(sp)
 1ba:	e022                	sd	s0,0(sp)
 1bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1be:	00054683          	lbu	a3,0(a0)
 1c2:	fd06879b          	addiw	a5,a3,-48
 1c6:	0ff7f793          	zext.b	a5,a5
 1ca:	4625                	li	a2,9
 1cc:	02f66963          	bltu	a2,a5,1fe <atoi+0x48>
 1d0:	872a                	mv	a4,a0
  n = 0;
 1d2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d4:	0705                	addi	a4,a4,1
 1d6:	0025179b          	slliw	a5,a0,0x2
 1da:	9fa9                	addw	a5,a5,a0
 1dc:	0017979b          	slliw	a5,a5,0x1
 1e0:	9fb5                	addw	a5,a5,a3
 1e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e6:	00074683          	lbu	a3,0(a4)
 1ea:	fd06879b          	addiw	a5,a3,-48
 1ee:	0ff7f793          	zext.b	a5,a5
 1f2:	fef671e3          	bgeu	a2,a5,1d4 <atoi+0x1e>
  return n;
}
 1f6:	60a2                	ld	ra,8(sp)
 1f8:	6402                	ld	s0,0(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  n = 0;
 1fe:	4501                	li	a0,0
 200:	bfdd                	j	1f6 <atoi+0x40>

0000000000000202 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 202:	1141                	addi	sp,sp,-16
 204:	e406                	sd	ra,8(sp)
 206:	e022                	sd	s0,0(sp)
 208:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20a:	02b57563          	bgeu	a0,a1,234 <memmove+0x32>
    while(n-- > 0)
 20e:	00c05f63          	blez	a2,22c <memmove+0x2a>
 212:	1602                	slli	a2,a2,0x20
 214:	9201                	srli	a2,a2,0x20
 216:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 21a:	872a                	mv	a4,a0
      *dst++ = *src++;
 21c:	0585                	addi	a1,a1,1
 21e:	0705                	addi	a4,a4,1
 220:	fff5c683          	lbu	a3,-1(a1)
 224:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 228:	fee79ae3          	bne	a5,a4,21c <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 22c:	60a2                	ld	ra,8(sp)
 22e:	6402                	ld	s0,0(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
    while(n-- > 0)
 234:	fec05ce3          	blez	a2,22c <memmove+0x2a>
    dst += n;
 238:	00c50733          	add	a4,a0,a2
    src += n;
 23c:	95b2                	add	a1,a1,a2
 23e:	fff6079b          	addiw	a5,a2,-1
 242:	1782                	slli	a5,a5,0x20
 244:	9381                	srli	a5,a5,0x20
 246:	fff7c793          	not	a5,a5
 24a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24c:	15fd                	addi	a1,a1,-1
 24e:	177d                	addi	a4,a4,-1
 250:	0005c683          	lbu	a3,0(a1)
 254:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 258:	fef71ae3          	bne	a4,a5,24c <memmove+0x4a>
 25c:	bfc1                	j	22c <memmove+0x2a>

000000000000025e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e406                	sd	ra,8(sp)
 262:	e022                	sd	s0,0(sp)
 264:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 266:	c61d                	beqz	a2,294 <memcmp+0x36>
 268:	1602                	slli	a2,a2,0x20
 26a:	9201                	srli	a2,a2,0x20
 26c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 270:	00054783          	lbu	a5,0(a0)
 274:	0005c703          	lbu	a4,0(a1)
 278:	00e79863          	bne	a5,a4,288 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 27c:	0505                	addi	a0,a0,1
    p2++;
 27e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 280:	fed518e3          	bne	a0,a3,270 <memcmp+0x12>
  }
  return 0;
 284:	4501                	li	a0,0
 286:	a019                	j	28c <memcmp+0x2e>
      return *p1 - *p2;
 288:	40e7853b          	subw	a0,a5,a4
}
 28c:	60a2                	ld	ra,8(sp)
 28e:	6402                	ld	s0,0(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  return 0;
 294:	4501                	li	a0,0
 296:	bfdd                	j	28c <memcmp+0x2e>

0000000000000298 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e406                	sd	ra,8(sp)
 29c:	e022                	sd	s0,0(sp)
 29e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a0:	00000097          	auipc	ra,0x0
 2a4:	f62080e7          	jalr	-158(ra) # 202 <memmove>
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret

00000000000002b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2b0:	4885                	li	a7,1
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b8:	4889                	li	a7,2
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2c0:	488d                	li	a7,3
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c8:	4891                	li	a7,4
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <read>:
.global read
read:
 li a7, SYS_read
 2d0:	4895                	li	a7,5
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <write>:
.global write
write:
 li a7, SYS_write
 2d8:	48c1                	li	a7,16
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <close>:
.global close
close:
 li a7, SYS_close
 2e0:	48d5                	li	a7,21
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e8:	4899                	li	a7,6
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2f0:	489d                	li	a7,7
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <open>:
.global open
open:
 li a7, SYS_open
 2f8:	48bd                	li	a7,15
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 300:	48c5                	li	a7,17
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 308:	48c9                	li	a7,18
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 310:	48a1                	li	a7,8
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <link>:
.global link
link:
 li a7, SYS_link
 318:	48cd                	li	a7,19
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 320:	48d1                	li	a7,20
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 328:	48a5                	li	a7,9
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <dup>:
.global dup
dup:
 li a7, SYS_dup
 330:	48a9                	li	a7,10
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 338:	48ad                	li	a7,11
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 340:	48b1                	li	a7,12
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 348:	48b5                	li	a7,13
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 350:	48b9                	li	a7,14
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 358:	48d9                	li	a7,22
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 360:	1101                	addi	sp,sp,-32
 362:	ec06                	sd	ra,24(sp)
 364:	e822                	sd	s0,16(sp)
 366:	1000                	addi	s0,sp,32
 368:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 36c:	4605                	li	a2,1
 36e:	fef40593          	addi	a1,s0,-17
 372:	00000097          	auipc	ra,0x0
 376:	f66080e7          	jalr	-154(ra) # 2d8 <write>
}
 37a:	60e2                	ld	ra,24(sp)
 37c:	6442                	ld	s0,16(sp)
 37e:	6105                	addi	sp,sp,32
 380:	8082                	ret

0000000000000382 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 382:	7139                	addi	sp,sp,-64
 384:	fc06                	sd	ra,56(sp)
 386:	f822                	sd	s0,48(sp)
 388:	f04a                	sd	s2,32(sp)
 38a:	ec4e                	sd	s3,24(sp)
 38c:	0080                	addi	s0,sp,64
 38e:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 390:	cad9                	beqz	a3,426 <printint+0xa4>
 392:	01f5d79b          	srliw	a5,a1,0x1f
 396:	cbc1                	beqz	a5,426 <printint+0xa4>
    neg = 1;
    x = -xx;
 398:	40b005bb          	negw	a1,a1
    neg = 1;
 39c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 39e:	fc040993          	addi	s3,s0,-64
  neg = 0;
 3a2:	86ce                	mv	a3,s3
  i = 0;
 3a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3a6:	00000817          	auipc	a6,0x0
 3aa:	49a80813          	addi	a6,a6,1178 # 840 <digits>
 3ae:	88ba                	mv	a7,a4
 3b0:	0017051b          	addiw	a0,a4,1
 3b4:	872a                	mv	a4,a0
 3b6:	02c5f7bb          	remuw	a5,a1,a2
 3ba:	1782                	slli	a5,a5,0x20
 3bc:	9381                	srli	a5,a5,0x20
 3be:	97c2                	add	a5,a5,a6
 3c0:	0007c783          	lbu	a5,0(a5)
 3c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3c8:	87ae                	mv	a5,a1
 3ca:	02c5d5bb          	divuw	a1,a1,a2
 3ce:	0685                	addi	a3,a3,1
 3d0:	fcc7ffe3          	bgeu	a5,a2,3ae <printint+0x2c>
  if(neg)
 3d4:	00030c63          	beqz	t1,3ec <printint+0x6a>
    buf[i++] = '-';
 3d8:	fd050793          	addi	a5,a0,-48
 3dc:	00878533          	add	a0,a5,s0
 3e0:	02d00793          	li	a5,45
 3e4:	fef50823          	sb	a5,-16(a0)
 3e8:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 3ec:	02e05763          	blez	a4,41a <printint+0x98>
 3f0:	f426                	sd	s1,40(sp)
 3f2:	377d                	addiw	a4,a4,-1
 3f4:	00e984b3          	add	s1,s3,a4
 3f8:	19fd                	addi	s3,s3,-1
 3fa:	99ba                	add	s3,s3,a4
 3fc:	1702                	slli	a4,a4,0x20
 3fe:	9301                	srli	a4,a4,0x20
 400:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 404:	0004c583          	lbu	a1,0(s1)
 408:	854a                	mv	a0,s2
 40a:	00000097          	auipc	ra,0x0
 40e:	f56080e7          	jalr	-170(ra) # 360 <putc>
  while(--i >= 0)
 412:	14fd                	addi	s1,s1,-1
 414:	ff3498e3          	bne	s1,s3,404 <printint+0x82>
 418:	74a2                	ld	s1,40(sp)
}
 41a:	70e2                	ld	ra,56(sp)
 41c:	7442                	ld	s0,48(sp)
 41e:	7902                	ld	s2,32(sp)
 420:	69e2                	ld	s3,24(sp)
 422:	6121                	addi	sp,sp,64
 424:	8082                	ret
  neg = 0;
 426:	4301                	li	t1,0
 428:	bf9d                	j	39e <printint+0x1c>

000000000000042a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 42a:	715d                	addi	sp,sp,-80
 42c:	e486                	sd	ra,72(sp)
 42e:	e0a2                	sd	s0,64(sp)
 430:	f84a                	sd	s2,48(sp)
 432:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 434:	0005c903          	lbu	s2,0(a1)
 438:	1a090b63          	beqz	s2,5ee <vprintf+0x1c4>
 43c:	fc26                	sd	s1,56(sp)
 43e:	f44e                	sd	s3,40(sp)
 440:	f052                	sd	s4,32(sp)
 442:	ec56                	sd	s5,24(sp)
 444:	e85a                	sd	s6,16(sp)
 446:	e45e                	sd	s7,8(sp)
 448:	8aaa                	mv	s5,a0
 44a:	8bb2                	mv	s7,a2
 44c:	00158493          	addi	s1,a1,1
  state = 0;
 450:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 452:	02500a13          	li	s4,37
 456:	4b55                	li	s6,21
 458:	a839                	j	476 <vprintf+0x4c>
        putc(fd, c);
 45a:	85ca                	mv	a1,s2
 45c:	8556                	mv	a0,s5
 45e:	00000097          	auipc	ra,0x0
 462:	f02080e7          	jalr	-254(ra) # 360 <putc>
 466:	a019                	j	46c <vprintf+0x42>
    } else if(state == '%'){
 468:	01498d63          	beq	s3,s4,482 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 46c:	0485                	addi	s1,s1,1
 46e:	fff4c903          	lbu	s2,-1(s1)
 472:	16090863          	beqz	s2,5e2 <vprintf+0x1b8>
    if(state == 0){
 476:	fe0999e3          	bnez	s3,468 <vprintf+0x3e>
      if(c == '%'){
 47a:	ff4910e3          	bne	s2,s4,45a <vprintf+0x30>
        state = '%';
 47e:	89d2                	mv	s3,s4
 480:	b7f5                	j	46c <vprintf+0x42>
      if(c == 'd'){
 482:	13490563          	beq	s2,s4,5ac <vprintf+0x182>
 486:	f9d9079b          	addiw	a5,s2,-99
 48a:	0ff7f793          	zext.b	a5,a5
 48e:	12fb6863          	bltu	s6,a5,5be <vprintf+0x194>
 492:	f9d9079b          	addiw	a5,s2,-99
 496:	0ff7f713          	zext.b	a4,a5
 49a:	12eb6263          	bltu	s6,a4,5be <vprintf+0x194>
 49e:	00271793          	slli	a5,a4,0x2
 4a2:	00000717          	auipc	a4,0x0
 4a6:	34670713          	addi	a4,a4,838 # 7e8 <malloc+0x106>
 4aa:	97ba                	add	a5,a5,a4
 4ac:	439c                	lw	a5,0(a5)
 4ae:	97ba                	add	a5,a5,a4
 4b0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4b2:	008b8913          	addi	s2,s7,8
 4b6:	4685                	li	a3,1
 4b8:	4629                	li	a2,10
 4ba:	000ba583          	lw	a1,0(s7)
 4be:	8556                	mv	a0,s5
 4c0:	00000097          	auipc	ra,0x0
 4c4:	ec2080e7          	jalr	-318(ra) # 382 <printint>
 4c8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4ca:	4981                	li	s3,0
 4cc:	b745                	j	46c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4ce:	008b8913          	addi	s2,s7,8
 4d2:	4681                	li	a3,0
 4d4:	4629                	li	a2,10
 4d6:	000ba583          	lw	a1,0(s7)
 4da:	8556                	mv	a0,s5
 4dc:	00000097          	auipc	ra,0x0
 4e0:	ea6080e7          	jalr	-346(ra) # 382 <printint>
 4e4:	8bca                	mv	s7,s2
      state = 0;
 4e6:	4981                	li	s3,0
 4e8:	b751                	j	46c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 4ea:	008b8913          	addi	s2,s7,8
 4ee:	4681                	li	a3,0
 4f0:	4641                	li	a2,16
 4f2:	000ba583          	lw	a1,0(s7)
 4f6:	8556                	mv	a0,s5
 4f8:	00000097          	auipc	ra,0x0
 4fc:	e8a080e7          	jalr	-374(ra) # 382 <printint>
 500:	8bca                	mv	s7,s2
      state = 0;
 502:	4981                	li	s3,0
 504:	b7a5                	j	46c <vprintf+0x42>
 506:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 508:	008b8793          	addi	a5,s7,8
 50c:	8c3e                	mv	s8,a5
 50e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 512:	03000593          	li	a1,48
 516:	8556                	mv	a0,s5
 518:	00000097          	auipc	ra,0x0
 51c:	e48080e7          	jalr	-440(ra) # 360 <putc>
  putc(fd, 'x');
 520:	07800593          	li	a1,120
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	e3a080e7          	jalr	-454(ra) # 360 <putc>
 52e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 530:	00000b97          	auipc	s7,0x0
 534:	310b8b93          	addi	s7,s7,784 # 840 <digits>
 538:	03c9d793          	srli	a5,s3,0x3c
 53c:	97de                	add	a5,a5,s7
 53e:	0007c583          	lbu	a1,0(a5)
 542:	8556                	mv	a0,s5
 544:	00000097          	auipc	ra,0x0
 548:	e1c080e7          	jalr	-484(ra) # 360 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 54c:	0992                	slli	s3,s3,0x4
 54e:	397d                	addiw	s2,s2,-1
 550:	fe0914e3          	bnez	s2,538 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 554:	8be2                	mv	s7,s8
      state = 0;
 556:	4981                	li	s3,0
 558:	6c02                	ld	s8,0(sp)
 55a:	bf09                	j	46c <vprintf+0x42>
        s = va_arg(ap, char*);
 55c:	008b8993          	addi	s3,s7,8
 560:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 564:	02090163          	beqz	s2,586 <vprintf+0x15c>
        while(*s != 0){
 568:	00094583          	lbu	a1,0(s2)
 56c:	c9a5                	beqz	a1,5dc <vprintf+0x1b2>
          putc(fd, *s);
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	df0080e7          	jalr	-528(ra) # 360 <putc>
          s++;
 578:	0905                	addi	s2,s2,1
        while(*s != 0){
 57a:	00094583          	lbu	a1,0(s2)
 57e:	f9e5                	bnez	a1,56e <vprintf+0x144>
        s = va_arg(ap, char*);
 580:	8bce                	mv	s7,s3
      state = 0;
 582:	4981                	li	s3,0
 584:	b5e5                	j	46c <vprintf+0x42>
          s = "(null)";
 586:	00000917          	auipc	s2,0x0
 58a:	25a90913          	addi	s2,s2,602 # 7e0 <malloc+0xfe>
        while(*s != 0){
 58e:	02800593          	li	a1,40
 592:	bff1                	j	56e <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 594:	008b8913          	addi	s2,s7,8
 598:	000bc583          	lbu	a1,0(s7)
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	dc2080e7          	jalr	-574(ra) # 360 <putc>
 5a6:	8bca                	mv	s7,s2
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	b5c9                	j	46c <vprintf+0x42>
        putc(fd, c);
 5ac:	02500593          	li	a1,37
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	dae080e7          	jalr	-594(ra) # 360 <putc>
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	bd45                	j	46c <vprintf+0x42>
        putc(fd, '%');
 5be:	02500593          	li	a1,37
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	d9c080e7          	jalr	-612(ra) # 360 <putc>
        putc(fd, c);
 5cc:	85ca                	mv	a1,s2
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	d90080e7          	jalr	-624(ra) # 360 <putc>
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	bd49                	j	46c <vprintf+0x42>
        s = va_arg(ap, char*);
 5dc:	8bce                	mv	s7,s3
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b571                	j	46c <vprintf+0x42>
 5e2:	74e2                	ld	s1,56(sp)
 5e4:	79a2                	ld	s3,40(sp)
 5e6:	7a02                	ld	s4,32(sp)
 5e8:	6ae2                	ld	s5,24(sp)
 5ea:	6b42                	ld	s6,16(sp)
 5ec:	6ba2                	ld	s7,8(sp)
    }
  }
}
 5ee:	60a6                	ld	ra,72(sp)
 5f0:	6406                	ld	s0,64(sp)
 5f2:	7942                	ld	s2,48(sp)
 5f4:	6161                	addi	sp,sp,80
 5f6:	8082                	ret

00000000000005f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5f8:	715d                	addi	sp,sp,-80
 5fa:	ec06                	sd	ra,24(sp)
 5fc:	e822                	sd	s0,16(sp)
 5fe:	1000                	addi	s0,sp,32
 600:	e010                	sd	a2,0(s0)
 602:	e414                	sd	a3,8(s0)
 604:	e818                	sd	a4,16(s0)
 606:	ec1c                	sd	a5,24(s0)
 608:	03043023          	sd	a6,32(s0)
 60c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 610:	8622                	mv	a2,s0
 612:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 616:	00000097          	auipc	ra,0x0
 61a:	e14080e7          	jalr	-492(ra) # 42a <vprintf>
}
 61e:	60e2                	ld	ra,24(sp)
 620:	6442                	ld	s0,16(sp)
 622:	6161                	addi	sp,sp,80
 624:	8082                	ret

0000000000000626 <printf>:

void
printf(const char *fmt, ...)
{
 626:	711d                	addi	sp,sp,-96
 628:	ec06                	sd	ra,24(sp)
 62a:	e822                	sd	s0,16(sp)
 62c:	1000                	addi	s0,sp,32
 62e:	e40c                	sd	a1,8(s0)
 630:	e810                	sd	a2,16(s0)
 632:	ec14                	sd	a3,24(s0)
 634:	f018                	sd	a4,32(s0)
 636:	f41c                	sd	a5,40(s0)
 638:	03043823          	sd	a6,48(s0)
 63c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 640:	00840613          	addi	a2,s0,8
 644:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 648:	85aa                	mv	a1,a0
 64a:	4505                	li	a0,1
 64c:	00000097          	auipc	ra,0x0
 650:	dde080e7          	jalr	-546(ra) # 42a <vprintf>
}
 654:	60e2                	ld	ra,24(sp)
 656:	6442                	ld	s0,16(sp)
 658:	6125                	addi	sp,sp,96
 65a:	8082                	ret

000000000000065c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 65c:	1141                	addi	sp,sp,-16
 65e:	e406                	sd	ra,8(sp)
 660:	e022                	sd	s0,0(sp)
 662:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 664:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 668:	00000797          	auipc	a5,0x0
 66c:	5d07b783          	ld	a5,1488(a5) # c38 <freep>
 670:	a039                	j	67e <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 672:	6398                	ld	a4,0(a5)
 674:	00e7e463          	bltu	a5,a4,67c <free+0x20>
 678:	00e6ea63          	bltu	a3,a4,68c <free+0x30>
{
 67c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67e:	fed7fae3          	bgeu	a5,a3,672 <free+0x16>
 682:	6398                	ld	a4,0(a5)
 684:	00e6e463          	bltu	a3,a4,68c <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 688:	fee7eae3          	bltu	a5,a4,67c <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 68c:	ff852583          	lw	a1,-8(a0)
 690:	6390                	ld	a2,0(a5)
 692:	02059813          	slli	a6,a1,0x20
 696:	01c85713          	srli	a4,a6,0x1c
 69a:	9736                	add	a4,a4,a3
 69c:	02e60563          	beq	a2,a4,6c6 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 6a0:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 6a4:	4790                	lw	a2,8(a5)
 6a6:	02061593          	slli	a1,a2,0x20
 6aa:	01c5d713          	srli	a4,a1,0x1c
 6ae:	973e                	add	a4,a4,a5
 6b0:	02e68263          	beq	a3,a4,6d4 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 6b4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6b6:	00000717          	auipc	a4,0x0
 6ba:	58f73123          	sd	a5,1410(a4) # c38 <freep>
}
 6be:	60a2                	ld	ra,8(sp)
 6c0:	6402                	ld	s0,0(sp)
 6c2:	0141                	addi	sp,sp,16
 6c4:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 6c6:	4618                	lw	a4,8(a2)
 6c8:	9f2d                	addw	a4,a4,a1
 6ca:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ce:	6398                	ld	a4,0(a5)
 6d0:	6310                	ld	a2,0(a4)
 6d2:	b7f9                	j	6a0 <free+0x44>
    p->s.size += bp->s.size;
 6d4:	ff852703          	lw	a4,-8(a0)
 6d8:	9f31                	addw	a4,a4,a2
 6da:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6dc:	ff053683          	ld	a3,-16(a0)
 6e0:	bfd1                	j	6b4 <free+0x58>

00000000000006e2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6e2:	7139                	addi	sp,sp,-64
 6e4:	fc06                	sd	ra,56(sp)
 6e6:	f822                	sd	s0,48(sp)
 6e8:	f04a                	sd	s2,32(sp)
 6ea:	ec4e                	sd	s3,24(sp)
 6ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6ee:	02051993          	slli	s3,a0,0x20
 6f2:	0209d993          	srli	s3,s3,0x20
 6f6:	09bd                	addi	s3,s3,15
 6f8:	0049d993          	srli	s3,s3,0x4
 6fc:	2985                	addiw	s3,s3,1
 6fe:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 700:	00000517          	auipc	a0,0x0
 704:	53853503          	ld	a0,1336(a0) # c38 <freep>
 708:	c905                	beqz	a0,738 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 70a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 70c:	4798                	lw	a4,8(a5)
 70e:	09377a63          	bgeu	a4,s3,7a2 <malloc+0xc0>
 712:	f426                	sd	s1,40(sp)
 714:	e852                	sd	s4,16(sp)
 716:	e456                	sd	s5,8(sp)
 718:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 71a:	8a4e                	mv	s4,s3
 71c:	6705                	lui	a4,0x1
 71e:	00e9f363          	bgeu	s3,a4,724 <malloc+0x42>
 722:	6a05                	lui	s4,0x1
 724:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 728:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 72c:	00000497          	auipc	s1,0x0
 730:	50c48493          	addi	s1,s1,1292 # c38 <freep>
  if(p == (char*)-1)
 734:	5afd                	li	s5,-1
 736:	a089                	j	778 <malloc+0x96>
 738:	f426                	sd	s1,40(sp)
 73a:	e852                	sd	s4,16(sp)
 73c:	e456                	sd	s5,8(sp)
 73e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 740:	00000797          	auipc	a5,0x0
 744:	50078793          	addi	a5,a5,1280 # c40 <base>
 748:	00000717          	auipc	a4,0x0
 74c:	4ef73823          	sd	a5,1264(a4) # c38 <freep>
 750:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 752:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 756:	b7d1                	j	71a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 758:	6398                	ld	a4,0(a5)
 75a:	e118                	sd	a4,0(a0)
 75c:	a8b9                	j	7ba <malloc+0xd8>
  hp->s.size = nu;
 75e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 762:	0541                	addi	a0,a0,16
 764:	00000097          	auipc	ra,0x0
 768:	ef8080e7          	jalr	-264(ra) # 65c <free>
  return freep;
 76c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 76e:	c135                	beqz	a0,7d2 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 770:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 772:	4798                	lw	a4,8(a5)
 774:	03277363          	bgeu	a4,s2,79a <malloc+0xb8>
    if(p == freep)
 778:	6098                	ld	a4,0(s1)
 77a:	853e                	mv	a0,a5
 77c:	fef71ae3          	bne	a4,a5,770 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 780:	8552                	mv	a0,s4
 782:	00000097          	auipc	ra,0x0
 786:	bbe080e7          	jalr	-1090(ra) # 340 <sbrk>
  if(p == (char*)-1)
 78a:	fd551ae3          	bne	a0,s5,75e <malloc+0x7c>
        return 0;
 78e:	4501                	li	a0,0
 790:	74a2                	ld	s1,40(sp)
 792:	6a42                	ld	s4,16(sp)
 794:	6aa2                	ld	s5,8(sp)
 796:	6b02                	ld	s6,0(sp)
 798:	a03d                	j	7c6 <malloc+0xe4>
 79a:	74a2                	ld	s1,40(sp)
 79c:	6a42                	ld	s4,16(sp)
 79e:	6aa2                	ld	s5,8(sp)
 7a0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7a2:	fae90be3          	beq	s2,a4,758 <malloc+0x76>
        p->s.size -= nunits;
 7a6:	4137073b          	subw	a4,a4,s3
 7aa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ac:	02071693          	slli	a3,a4,0x20
 7b0:	01c6d713          	srli	a4,a3,0x1c
 7b4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7b6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ba:	00000717          	auipc	a4,0x0
 7be:	46a73f23          	sd	a0,1150(a4) # c38 <freep>
      return (void*)(p + 1);
 7c2:	01078513          	addi	a0,a5,16
  }
}
 7c6:	70e2                	ld	ra,56(sp)
 7c8:	7442                	ld	s0,48(sp)
 7ca:	7902                	ld	s2,32(sp)
 7cc:	69e2                	ld	s3,24(sp)
 7ce:	6121                	addi	sp,sp,64
 7d0:	8082                	ret
 7d2:	74a2                	ld	s1,40(sp)
 7d4:	6a42                	ld	s4,16(sp)
 7d6:	6aa2                	ld	s5,8(sp)
 7d8:	6b02                	ld	s6,0(sp)
 7da:	b7f5                	j	7c6 <malloc+0xe4>
