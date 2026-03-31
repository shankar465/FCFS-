
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7df63          	bge	a5,a0,48 <main+0x48>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1cc080e7          	jalr	460(ra) # 1f4 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2f6080e7          	jalr	758(ra) # 326 <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2b6080e7          	jalr	694(ra) # 2f6 <exit>
  48:	e426                	sd	s1,8(sp)
  4a:	e04a                	sd	s2,0(sp)
    fprintf(2, "usage: kill pid...\n");
  4c:	00000597          	auipc	a1,0x0
  50:	7d458593          	addi	a1,a1,2004 # 820 <malloc+0x100>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5e0080e7          	jalr	1504(ra) # 636 <fprintf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	296080e7          	jalr	662(ra) # 2f6 <exit>

0000000000000068 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  68:	1141                	addi	sp,sp,-16
  6a:	e406                	sd	ra,8(sp)
  6c:	e022                	sd	s0,0(sp)
  6e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  70:	87aa                	mv	a5,a0
  72:	0585                	addi	a1,a1,1
  74:	0785                	addi	a5,a5,1
  76:	fff5c703          	lbu	a4,-1(a1)
  7a:	fee78fa3          	sb	a4,-1(a5)
  7e:	fb75                	bnez	a4,72 <strcpy+0xa>
    ;
  return os;
}
  80:	60a2                	ld	ra,8(sp)
  82:	6402                	ld	s0,0(sp)
  84:	0141                	addi	sp,sp,16
  86:	8082                	ret

0000000000000088 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  88:	1141                	addi	sp,sp,-16
  8a:	e406                	sd	ra,8(sp)
  8c:	e022                	sd	s0,0(sp)
  8e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  90:	00054783          	lbu	a5,0(a0)
  94:	cb91                	beqz	a5,a8 <strcmp+0x20>
  96:	0005c703          	lbu	a4,0(a1)
  9a:	00f71763          	bne	a4,a5,a8 <strcmp+0x20>
    p++, q++;
  9e:	0505                	addi	a0,a0,1
  a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  a2:	00054783          	lbu	a5,0(a0)
  a6:	fbe5                	bnez	a5,96 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  a8:	0005c503          	lbu	a0,0(a1)
}
  ac:	40a7853b          	subw	a0,a5,a0
  b0:	60a2                	ld	ra,8(sp)
  b2:	6402                	ld	s0,0(sp)
  b4:	0141                	addi	sp,sp,16
  b6:	8082                	ret

00000000000000b8 <strlen>:

uint
strlen(const char *s)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	cf91                	beqz	a5,e0 <strlen+0x28>
  c6:	00150793          	addi	a5,a0,1
  ca:	86be                	mv	a3,a5
  cc:	0785                	addi	a5,a5,1
  ce:	fff7c703          	lbu	a4,-1(a5)
  d2:	ff65                	bnez	a4,ca <strlen+0x12>
  d4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  d8:	60a2                	ld	ra,8(sp)
  da:	6402                	ld	s0,0(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret
  for(n = 0; s[n]; n++)
  e0:	4501                	li	a0,0
  e2:	bfdd                	j	d8 <strlen+0x20>

00000000000000e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ec:	ca19                	beqz	a2,102 <memset+0x1e>
  ee:	87aa                	mv	a5,a0
  f0:	1602                	slli	a2,a2,0x20
  f2:	9201                	srli	a2,a2,0x20
  f4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  f8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  fc:	0785                	addi	a5,a5,1
  fe:	fee79de3          	bne	a5,a4,f8 <memset+0x14>
  }
  return dst;
}
 102:	60a2                	ld	ra,8(sp)
 104:	6402                	ld	s0,0(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strchr>:

char*
strchr(const char *s, char c)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e406                	sd	ra,8(sp)
 10e:	e022                	sd	s0,0(sp)
 110:	0800                	addi	s0,sp,16
  for(; *s; s++)
 112:	00054783          	lbu	a5,0(a0)
 116:	cf81                	beqz	a5,12e <strchr+0x24>
    if(*s == c)
 118:	00f58763          	beq	a1,a5,126 <strchr+0x1c>
  for(; *s; s++)
 11c:	0505                	addi	a0,a0,1
 11e:	00054783          	lbu	a5,0(a0)
 122:	fbfd                	bnez	a5,118 <strchr+0xe>
      return (char*)s;
  return 0;
 124:	4501                	li	a0,0
}
 126:	60a2                	ld	ra,8(sp)
 128:	6402                	ld	s0,0(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  return 0;
 12e:	4501                	li	a0,0
 130:	bfdd                	j	126 <strchr+0x1c>

0000000000000132 <gets>:

char*
gets(char *buf, int max)
{
 132:	711d                	addi	sp,sp,-96
 134:	ec86                	sd	ra,88(sp)
 136:	e8a2                	sd	s0,80(sp)
 138:	e4a6                	sd	s1,72(sp)
 13a:	e0ca                	sd	s2,64(sp)
 13c:	fc4e                	sd	s3,56(sp)
 13e:	f852                	sd	s4,48(sp)
 140:	f456                	sd	s5,40(sp)
 142:	f05a                	sd	s6,32(sp)
 144:	ec5e                	sd	s7,24(sp)
 146:	e862                	sd	s8,16(sp)
 148:	1080                	addi	s0,sp,96
 14a:	8baa                	mv	s7,a0
 14c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14e:	892a                	mv	s2,a0
 150:	4481                	li	s1,0
    cc = read(0, &c, 1);
 152:	faf40b13          	addi	s6,s0,-81
 156:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 158:	8c26                	mv	s8,s1
 15a:	0014899b          	addiw	s3,s1,1
 15e:	84ce                	mv	s1,s3
 160:	0349d663          	bge	s3,s4,18c <gets+0x5a>
    cc = read(0, &c, 1);
 164:	8656                	mv	a2,s5
 166:	85da                	mv	a1,s6
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	1a4080e7          	jalr	420(ra) # 30e <read>
    if(cc < 1)
 172:	00a05d63          	blez	a0,18c <gets+0x5a>
      break;
    buf[i++] = c;
 176:	faf44783          	lbu	a5,-81(s0)
 17a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17e:	0905                	addi	s2,s2,1
 180:	ff678713          	addi	a4,a5,-10
 184:	c319                	beqz	a4,18a <gets+0x58>
 186:	17cd                	addi	a5,a5,-13
 188:	fbe1                	bnez	a5,158 <gets+0x26>
    buf[i++] = c;
 18a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 18c:	9c5e                	add	s8,s8,s7
 18e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6c42                	ld	s8,16(sp)
 1a8:	6125                	addi	sp,sp,96
 1aa:	8082                	ret

00000000000001ac <stat>:

int
stat(const char *n, struct stat *st)
{
 1ac:	1101                	addi	sp,sp,-32
 1ae:	ec06                	sd	ra,24(sp)
 1b0:	e822                	sd	s0,16(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	17c080e7          	jalr	380(ra) # 336 <open>
  if(fd < 0)
 1c2:	02054663          	bltz	a0,1ee <stat+0x42>
 1c6:	e426                	sd	s1,8(sp)
 1c8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ca:	85ca                	mv	a1,s2
 1cc:	00000097          	auipc	ra,0x0
 1d0:	182080e7          	jalr	386(ra) # 34e <fstat>
 1d4:	892a                	mv	s2,a0
  close(fd);
 1d6:	8526                	mv	a0,s1
 1d8:	00000097          	auipc	ra,0x0
 1dc:	146080e7          	jalr	326(ra) # 31e <close>
  return r;
 1e0:	64a2                	ld	s1,8(sp)
}
 1e2:	854a                	mv	a0,s2
 1e4:	60e2                	ld	ra,24(sp)
 1e6:	6442                	ld	s0,16(sp)
 1e8:	6902                	ld	s2,0(sp)
 1ea:	6105                	addi	sp,sp,32
 1ec:	8082                	ret
    return -1;
 1ee:	57fd                	li	a5,-1
 1f0:	893e                	mv	s2,a5
 1f2:	bfc5                	j	1e2 <stat+0x36>

00000000000001f4 <atoi>:

int
atoi(const char *s)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e406                	sd	ra,8(sp)
 1f8:	e022                	sd	s0,0(sp)
 1fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fc:	00054683          	lbu	a3,0(a0)
 200:	fd06879b          	addiw	a5,a3,-48
 204:	0ff7f793          	zext.b	a5,a5
 208:	4625                	li	a2,9
 20a:	02f66963          	bltu	a2,a5,23c <atoi+0x48>
 20e:	872a                	mv	a4,a0
  n = 0;
 210:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 212:	0705                	addi	a4,a4,1
 214:	0025179b          	slliw	a5,a0,0x2
 218:	9fa9                	addw	a5,a5,a0
 21a:	0017979b          	slliw	a5,a5,0x1
 21e:	9fb5                	addw	a5,a5,a3
 220:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 224:	00074683          	lbu	a3,0(a4)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	fef671e3          	bgeu	a2,a5,212 <atoi+0x1e>
  return n;
}
 234:	60a2                	ld	ra,8(sp)
 236:	6402                	ld	s0,0(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  n = 0;
 23c:	4501                	li	a0,0
 23e:	bfdd                	j	234 <atoi+0x40>

0000000000000240 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e406                	sd	ra,8(sp)
 244:	e022                	sd	s0,0(sp)
 246:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 248:	02b57563          	bgeu	a0,a1,272 <memmove+0x32>
    while(n-- > 0)
 24c:	00c05f63          	blez	a2,26a <memmove+0x2a>
 250:	1602                	slli	a2,a2,0x20
 252:	9201                	srli	a2,a2,0x20
 254:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 258:	872a                	mv	a4,a0
      *dst++ = *src++;
 25a:	0585                	addi	a1,a1,1
 25c:	0705                	addi	a4,a4,1
 25e:	fff5c683          	lbu	a3,-1(a1)
 262:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 266:	fee79ae3          	bne	a5,a4,25a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26a:	60a2                	ld	ra,8(sp)
 26c:	6402                	ld	s0,0(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
    while(n-- > 0)
 272:	fec05ce3          	blez	a2,26a <memmove+0x2a>
    dst += n;
 276:	00c50733          	add	a4,a0,a2
    src += n;
 27a:	95b2                	add	a1,a1,a2
 27c:	fff6079b          	addiw	a5,a2,-1
 280:	1782                	slli	a5,a5,0x20
 282:	9381                	srli	a5,a5,0x20
 284:	fff7c793          	not	a5,a5
 288:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 28a:	15fd                	addi	a1,a1,-1
 28c:	177d                	addi	a4,a4,-1
 28e:	0005c683          	lbu	a3,0(a1)
 292:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 296:	fef71ae3          	bne	a4,a5,28a <memmove+0x4a>
 29a:	bfc1                	j	26a <memmove+0x2a>

000000000000029c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e406                	sd	ra,8(sp)
 2a0:	e022                	sd	s0,0(sp)
 2a2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a4:	c61d                	beqz	a2,2d2 <memcmp+0x36>
 2a6:	1602                	slli	a2,a2,0x20
 2a8:	9201                	srli	a2,a2,0x20
 2aa:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	0005c703          	lbu	a4,0(a1)
 2b6:	00e79863          	bne	a5,a4,2c6 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2ba:	0505                	addi	a0,a0,1
    p2++;
 2bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2be:	fed518e3          	bne	a0,a3,2ae <memcmp+0x12>
  }
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	a019                	j	2ca <memcmp+0x2e>
      return *p1 - *p2;
 2c6:	40e7853b          	subw	a0,a5,a4
}
 2ca:	60a2                	ld	ra,8(sp)
 2cc:	6402                	ld	s0,0(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret
  return 0;
 2d2:	4501                	li	a0,0
 2d4:	bfdd                	j	2ca <memcmp+0x2e>

00000000000002d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e406                	sd	ra,8(sp)
 2da:	e022                	sd	s0,0(sp)
 2dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2de:	00000097          	auipc	ra,0x0
 2e2:	f62080e7          	jalr	-158(ra) # 240 <memmove>
}
 2e6:	60a2                	ld	ra,8(sp)
 2e8:	6402                	ld	s0,0(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret

00000000000002ee <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ee:	4885                	li	a7,1
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f6:	4889                	li	a7,2
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <wait>:
.global wait
wait:
 li a7, SYS_wait
 2fe:	488d                	li	a7,3
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 306:	4891                	li	a7,4
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <read>:
.global read
read:
 li a7, SYS_read
 30e:	4895                	li	a7,5
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <write>:
.global write
write:
 li a7, SYS_write
 316:	48c1                	li	a7,16
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <close>:
.global close
close:
 li a7, SYS_close
 31e:	48d5                	li	a7,21
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <kill>:
.global kill
kill:
 li a7, SYS_kill
 326:	4899                	li	a7,6
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <exec>:
.global exec
exec:
 li a7, SYS_exec
 32e:	489d                	li	a7,7
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <open>:
.global open
open:
 li a7, SYS_open
 336:	48bd                	li	a7,15
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 33e:	48c5                	li	a7,17
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 346:	48c9                	li	a7,18
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 34e:	48a1                	li	a7,8
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <link>:
.global link
link:
 li a7, SYS_link
 356:	48cd                	li	a7,19
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 35e:	48d1                	li	a7,20
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 366:	48a5                	li	a7,9
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <dup>:
.global dup
dup:
 li a7, SYS_dup
 36e:	48a9                	li	a7,10
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 376:	48ad                	li	a7,11
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 37e:	48b1                	li	a7,12
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 386:	48b5                	li	a7,13
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 38e:	48b9                	li	a7,14
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 396:	48d9                	li	a7,22
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 39e:	1101                	addi	sp,sp,-32
 3a0:	ec06                	sd	ra,24(sp)
 3a2:	e822                	sd	s0,16(sp)
 3a4:	1000                	addi	s0,sp,32
 3a6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3aa:	4605                	li	a2,1
 3ac:	fef40593          	addi	a1,s0,-17
 3b0:	00000097          	auipc	ra,0x0
 3b4:	f66080e7          	jalr	-154(ra) # 316 <write>
}
 3b8:	60e2                	ld	ra,24(sp)
 3ba:	6442                	ld	s0,16(sp)
 3bc:	6105                	addi	sp,sp,32
 3be:	8082                	ret

00000000000003c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c0:	7139                	addi	sp,sp,-64
 3c2:	fc06                	sd	ra,56(sp)
 3c4:	f822                	sd	s0,48(sp)
 3c6:	f04a                	sd	s2,32(sp)
 3c8:	ec4e                	sd	s3,24(sp)
 3ca:	0080                	addi	s0,sp,64
 3cc:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ce:	cad9                	beqz	a3,464 <printint+0xa4>
 3d0:	01f5d79b          	srliw	a5,a1,0x1f
 3d4:	cbc1                	beqz	a5,464 <printint+0xa4>
    neg = 1;
    x = -xx;
 3d6:	40b005bb          	negw	a1,a1
    neg = 1;
 3da:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3dc:	fc040993          	addi	s3,s0,-64
  neg = 0;
 3e0:	86ce                	mv	a3,s3
  i = 0;
 3e2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e4:	00000817          	auipc	a6,0x0
 3e8:	4b480813          	addi	a6,a6,1204 # 898 <digits>
 3ec:	88ba                	mv	a7,a4
 3ee:	0017051b          	addiw	a0,a4,1
 3f2:	872a                	mv	a4,a0
 3f4:	02c5f7bb          	remuw	a5,a1,a2
 3f8:	1782                	slli	a5,a5,0x20
 3fa:	9381                	srli	a5,a5,0x20
 3fc:	97c2                	add	a5,a5,a6
 3fe:	0007c783          	lbu	a5,0(a5)
 402:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 406:	87ae                	mv	a5,a1
 408:	02c5d5bb          	divuw	a1,a1,a2
 40c:	0685                	addi	a3,a3,1
 40e:	fcc7ffe3          	bgeu	a5,a2,3ec <printint+0x2c>
  if(neg)
 412:	00030c63          	beqz	t1,42a <printint+0x6a>
    buf[i++] = '-';
 416:	fd050793          	addi	a5,a0,-48
 41a:	00878533          	add	a0,a5,s0
 41e:	02d00793          	li	a5,45
 422:	fef50823          	sb	a5,-16(a0)
 426:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 42a:	02e05763          	blez	a4,458 <printint+0x98>
 42e:	f426                	sd	s1,40(sp)
 430:	377d                	addiw	a4,a4,-1
 432:	00e984b3          	add	s1,s3,a4
 436:	19fd                	addi	s3,s3,-1
 438:	99ba                	add	s3,s3,a4
 43a:	1702                	slli	a4,a4,0x20
 43c:	9301                	srli	a4,a4,0x20
 43e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 442:	0004c583          	lbu	a1,0(s1)
 446:	854a                	mv	a0,s2
 448:	00000097          	auipc	ra,0x0
 44c:	f56080e7          	jalr	-170(ra) # 39e <putc>
  while(--i >= 0)
 450:	14fd                	addi	s1,s1,-1
 452:	ff3498e3          	bne	s1,s3,442 <printint+0x82>
 456:	74a2                	ld	s1,40(sp)
}
 458:	70e2                	ld	ra,56(sp)
 45a:	7442                	ld	s0,48(sp)
 45c:	7902                	ld	s2,32(sp)
 45e:	69e2                	ld	s3,24(sp)
 460:	6121                	addi	sp,sp,64
 462:	8082                	ret
  neg = 0;
 464:	4301                	li	t1,0
 466:	bf9d                	j	3dc <printint+0x1c>

0000000000000468 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 468:	715d                	addi	sp,sp,-80
 46a:	e486                	sd	ra,72(sp)
 46c:	e0a2                	sd	s0,64(sp)
 46e:	f84a                	sd	s2,48(sp)
 470:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 472:	0005c903          	lbu	s2,0(a1)
 476:	1a090b63          	beqz	s2,62c <vprintf+0x1c4>
 47a:	fc26                	sd	s1,56(sp)
 47c:	f44e                	sd	s3,40(sp)
 47e:	f052                	sd	s4,32(sp)
 480:	ec56                	sd	s5,24(sp)
 482:	e85a                	sd	s6,16(sp)
 484:	e45e                	sd	s7,8(sp)
 486:	8aaa                	mv	s5,a0
 488:	8bb2                	mv	s7,a2
 48a:	00158493          	addi	s1,a1,1
  state = 0;
 48e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 490:	02500a13          	li	s4,37
 494:	4b55                	li	s6,21
 496:	a839                	j	4b4 <vprintf+0x4c>
        putc(fd, c);
 498:	85ca                	mv	a1,s2
 49a:	8556                	mv	a0,s5
 49c:	00000097          	auipc	ra,0x0
 4a0:	f02080e7          	jalr	-254(ra) # 39e <putc>
 4a4:	a019                	j	4aa <vprintf+0x42>
    } else if(state == '%'){
 4a6:	01498d63          	beq	s3,s4,4c0 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4aa:	0485                	addi	s1,s1,1
 4ac:	fff4c903          	lbu	s2,-1(s1)
 4b0:	16090863          	beqz	s2,620 <vprintf+0x1b8>
    if(state == 0){
 4b4:	fe0999e3          	bnez	s3,4a6 <vprintf+0x3e>
      if(c == '%'){
 4b8:	ff4910e3          	bne	s2,s4,498 <vprintf+0x30>
        state = '%';
 4bc:	89d2                	mv	s3,s4
 4be:	b7f5                	j	4aa <vprintf+0x42>
      if(c == 'd'){
 4c0:	13490563          	beq	s2,s4,5ea <vprintf+0x182>
 4c4:	f9d9079b          	addiw	a5,s2,-99
 4c8:	0ff7f793          	zext.b	a5,a5
 4cc:	12fb6863          	bltu	s6,a5,5fc <vprintf+0x194>
 4d0:	f9d9079b          	addiw	a5,s2,-99
 4d4:	0ff7f713          	zext.b	a4,a5
 4d8:	12eb6263          	bltu	s6,a4,5fc <vprintf+0x194>
 4dc:	00271793          	slli	a5,a4,0x2
 4e0:	00000717          	auipc	a4,0x0
 4e4:	36070713          	addi	a4,a4,864 # 840 <malloc+0x120>
 4e8:	97ba                	add	a5,a5,a4
 4ea:	439c                	lw	a5,0(a5)
 4ec:	97ba                	add	a5,a5,a4
 4ee:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4f0:	008b8913          	addi	s2,s7,8
 4f4:	4685                	li	a3,1
 4f6:	4629                	li	a2,10
 4f8:	000ba583          	lw	a1,0(s7)
 4fc:	8556                	mv	a0,s5
 4fe:	00000097          	auipc	ra,0x0
 502:	ec2080e7          	jalr	-318(ra) # 3c0 <printint>
 506:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 508:	4981                	li	s3,0
 50a:	b745                	j	4aa <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 50c:	008b8913          	addi	s2,s7,8
 510:	4681                	li	a3,0
 512:	4629                	li	a2,10
 514:	000ba583          	lw	a1,0(s7)
 518:	8556                	mv	a0,s5
 51a:	00000097          	auipc	ra,0x0
 51e:	ea6080e7          	jalr	-346(ra) # 3c0 <printint>
 522:	8bca                	mv	s7,s2
      state = 0;
 524:	4981                	li	s3,0
 526:	b751                	j	4aa <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 528:	008b8913          	addi	s2,s7,8
 52c:	4681                	li	a3,0
 52e:	4641                	li	a2,16
 530:	000ba583          	lw	a1,0(s7)
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e8a080e7          	jalr	-374(ra) # 3c0 <printint>
 53e:	8bca                	mv	s7,s2
      state = 0;
 540:	4981                	li	s3,0
 542:	b7a5                	j	4aa <vprintf+0x42>
 544:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 546:	008b8793          	addi	a5,s7,8
 54a:	8c3e                	mv	s8,a5
 54c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 550:	03000593          	li	a1,48
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	e48080e7          	jalr	-440(ra) # 39e <putc>
  putc(fd, 'x');
 55e:	07800593          	li	a1,120
 562:	8556                	mv	a0,s5
 564:	00000097          	auipc	ra,0x0
 568:	e3a080e7          	jalr	-454(ra) # 39e <putc>
 56c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56e:	00000b97          	auipc	s7,0x0
 572:	32ab8b93          	addi	s7,s7,810 # 898 <digits>
 576:	03c9d793          	srli	a5,s3,0x3c
 57a:	97de                	add	a5,a5,s7
 57c:	0007c583          	lbu	a1,0(a5)
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e1c080e7          	jalr	-484(ra) # 39e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 58a:	0992                	slli	s3,s3,0x4
 58c:	397d                	addiw	s2,s2,-1
 58e:	fe0914e3          	bnez	s2,576 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 592:	8be2                	mv	s7,s8
      state = 0;
 594:	4981                	li	s3,0
 596:	6c02                	ld	s8,0(sp)
 598:	bf09                	j	4aa <vprintf+0x42>
        s = va_arg(ap, char*);
 59a:	008b8993          	addi	s3,s7,8
 59e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5a2:	02090163          	beqz	s2,5c4 <vprintf+0x15c>
        while(*s != 0){
 5a6:	00094583          	lbu	a1,0(s2)
 5aa:	c9a5                	beqz	a1,61a <vprintf+0x1b2>
          putc(fd, *s);
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	df0080e7          	jalr	-528(ra) # 39e <putc>
          s++;
 5b6:	0905                	addi	s2,s2,1
        while(*s != 0){
 5b8:	00094583          	lbu	a1,0(s2)
 5bc:	f9e5                	bnez	a1,5ac <vprintf+0x144>
        s = va_arg(ap, char*);
 5be:	8bce                	mv	s7,s3
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	b5e5                	j	4aa <vprintf+0x42>
          s = "(null)";
 5c4:	00000917          	auipc	s2,0x0
 5c8:	27490913          	addi	s2,s2,628 # 838 <malloc+0x118>
        while(*s != 0){
 5cc:	02800593          	li	a1,40
 5d0:	bff1                	j	5ac <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	000bc583          	lbu	a1,0(s7)
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	dc2080e7          	jalr	-574(ra) # 39e <putc>
 5e4:	8bca                	mv	s7,s2
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b5c9                	j	4aa <vprintf+0x42>
        putc(fd, c);
 5ea:	02500593          	li	a1,37
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	dae080e7          	jalr	-594(ra) # 39e <putc>
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	bd45                	j	4aa <vprintf+0x42>
        putc(fd, '%');
 5fc:	02500593          	li	a1,37
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	d9c080e7          	jalr	-612(ra) # 39e <putc>
        putc(fd, c);
 60a:	85ca                	mv	a1,s2
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	d90080e7          	jalr	-624(ra) # 39e <putc>
      state = 0;
 616:	4981                	li	s3,0
 618:	bd49                	j	4aa <vprintf+0x42>
        s = va_arg(ap, char*);
 61a:	8bce                	mv	s7,s3
      state = 0;
 61c:	4981                	li	s3,0
 61e:	b571                	j	4aa <vprintf+0x42>
 620:	74e2                	ld	s1,56(sp)
 622:	79a2                	ld	s3,40(sp)
 624:	7a02                	ld	s4,32(sp)
 626:	6ae2                	ld	s5,24(sp)
 628:	6b42                	ld	s6,16(sp)
 62a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 62c:	60a6                	ld	ra,72(sp)
 62e:	6406                	ld	s0,64(sp)
 630:	7942                	ld	s2,48(sp)
 632:	6161                	addi	sp,sp,80
 634:	8082                	ret

0000000000000636 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 636:	715d                	addi	sp,sp,-80
 638:	ec06                	sd	ra,24(sp)
 63a:	e822                	sd	s0,16(sp)
 63c:	1000                	addi	s0,sp,32
 63e:	e010                	sd	a2,0(s0)
 640:	e414                	sd	a3,8(s0)
 642:	e818                	sd	a4,16(s0)
 644:	ec1c                	sd	a5,24(s0)
 646:	03043023          	sd	a6,32(s0)
 64a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 64e:	8622                	mv	a2,s0
 650:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 654:	00000097          	auipc	ra,0x0
 658:	e14080e7          	jalr	-492(ra) # 468 <vprintf>
}
 65c:	60e2                	ld	ra,24(sp)
 65e:	6442                	ld	s0,16(sp)
 660:	6161                	addi	sp,sp,80
 662:	8082                	ret

0000000000000664 <printf>:

void
printf(const char *fmt, ...)
{
 664:	711d                	addi	sp,sp,-96
 666:	ec06                	sd	ra,24(sp)
 668:	e822                	sd	s0,16(sp)
 66a:	1000                	addi	s0,sp,32
 66c:	e40c                	sd	a1,8(s0)
 66e:	e810                	sd	a2,16(s0)
 670:	ec14                	sd	a3,24(s0)
 672:	f018                	sd	a4,32(s0)
 674:	f41c                	sd	a5,40(s0)
 676:	03043823          	sd	a6,48(s0)
 67a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 67e:	00840613          	addi	a2,s0,8
 682:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 686:	85aa                	mv	a1,a0
 688:	4505                	li	a0,1
 68a:	00000097          	auipc	ra,0x0
 68e:	dde080e7          	jalr	-546(ra) # 468 <vprintf>
}
 692:	60e2                	ld	ra,24(sp)
 694:	6442                	ld	s0,16(sp)
 696:	6125                	addi	sp,sp,96
 698:	8082                	ret

000000000000069a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 69a:	1141                	addi	sp,sp,-16
 69c:	e406                	sd	ra,8(sp)
 69e:	e022                	sd	s0,0(sp)
 6a0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a6:	00000797          	auipc	a5,0x0
 6aa:	5f27b783          	ld	a5,1522(a5) # c98 <freep>
 6ae:	a039                	j	6bc <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b0:	6398                	ld	a4,0(a5)
 6b2:	00e7e463          	bltu	a5,a4,6ba <free+0x20>
 6b6:	00e6ea63          	bltu	a3,a4,6ca <free+0x30>
{
 6ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bc:	fed7fae3          	bgeu	a5,a3,6b0 <free+0x16>
 6c0:	6398                	ld	a4,0(a5)
 6c2:	00e6e463          	bltu	a3,a4,6ca <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c6:	fee7eae3          	bltu	a5,a4,6ba <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ca:	ff852583          	lw	a1,-8(a0)
 6ce:	6390                	ld	a2,0(a5)
 6d0:	02059813          	slli	a6,a1,0x20
 6d4:	01c85713          	srli	a4,a6,0x1c
 6d8:	9736                	add	a4,a4,a3
 6da:	02e60563          	beq	a2,a4,704 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 6de:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 6e2:	4790                	lw	a2,8(a5)
 6e4:	02061593          	slli	a1,a2,0x20
 6e8:	01c5d713          	srli	a4,a1,0x1c
 6ec:	973e                	add	a4,a4,a5
 6ee:	02e68263          	beq	a3,a4,712 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 6f2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6f4:	00000717          	auipc	a4,0x0
 6f8:	5af73223          	sd	a5,1444(a4) # c98 <freep>
}
 6fc:	60a2                	ld	ra,8(sp)
 6fe:	6402                	ld	s0,0(sp)
 700:	0141                	addi	sp,sp,16
 702:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 704:	4618                	lw	a4,8(a2)
 706:	9f2d                	addw	a4,a4,a1
 708:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 70c:	6398                	ld	a4,0(a5)
 70e:	6310                	ld	a2,0(a4)
 710:	b7f9                	j	6de <free+0x44>
    p->s.size += bp->s.size;
 712:	ff852703          	lw	a4,-8(a0)
 716:	9f31                	addw	a4,a4,a2
 718:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 71a:	ff053683          	ld	a3,-16(a0)
 71e:	bfd1                	j	6f2 <free+0x58>

0000000000000720 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 720:	7139                	addi	sp,sp,-64
 722:	fc06                	sd	ra,56(sp)
 724:	f822                	sd	s0,48(sp)
 726:	f04a                	sd	s2,32(sp)
 728:	ec4e                	sd	s3,24(sp)
 72a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 72c:	02051993          	slli	s3,a0,0x20
 730:	0209d993          	srli	s3,s3,0x20
 734:	09bd                	addi	s3,s3,15
 736:	0049d993          	srli	s3,s3,0x4
 73a:	2985                	addiw	s3,s3,1
 73c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 73e:	00000517          	auipc	a0,0x0
 742:	55a53503          	ld	a0,1370(a0) # c98 <freep>
 746:	c905                	beqz	a0,776 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 748:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 74a:	4798                	lw	a4,8(a5)
 74c:	09377a63          	bgeu	a4,s3,7e0 <malloc+0xc0>
 750:	f426                	sd	s1,40(sp)
 752:	e852                	sd	s4,16(sp)
 754:	e456                	sd	s5,8(sp)
 756:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 758:	8a4e                	mv	s4,s3
 75a:	6705                	lui	a4,0x1
 75c:	00e9f363          	bgeu	s3,a4,762 <malloc+0x42>
 760:	6a05                	lui	s4,0x1
 762:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 766:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 76a:	00000497          	auipc	s1,0x0
 76e:	52e48493          	addi	s1,s1,1326 # c98 <freep>
  if(p == (char*)-1)
 772:	5afd                	li	s5,-1
 774:	a089                	j	7b6 <malloc+0x96>
 776:	f426                	sd	s1,40(sp)
 778:	e852                	sd	s4,16(sp)
 77a:	e456                	sd	s5,8(sp)
 77c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 77e:	00000797          	auipc	a5,0x0
 782:	52278793          	addi	a5,a5,1314 # ca0 <base>
 786:	00000717          	auipc	a4,0x0
 78a:	50f73923          	sd	a5,1298(a4) # c98 <freep>
 78e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 790:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 794:	b7d1                	j	758 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 796:	6398                	ld	a4,0(a5)
 798:	e118                	sd	a4,0(a0)
 79a:	a8b9                	j	7f8 <malloc+0xd8>
  hp->s.size = nu;
 79c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7a0:	0541                	addi	a0,a0,16
 7a2:	00000097          	auipc	ra,0x0
 7a6:	ef8080e7          	jalr	-264(ra) # 69a <free>
  return freep;
 7aa:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7ac:	c135                	beqz	a0,810 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b0:	4798                	lw	a4,8(a5)
 7b2:	03277363          	bgeu	a4,s2,7d8 <malloc+0xb8>
    if(p == freep)
 7b6:	6098                	ld	a4,0(s1)
 7b8:	853e                	mv	a0,a5
 7ba:	fef71ae3          	bne	a4,a5,7ae <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 7be:	8552                	mv	a0,s4
 7c0:	00000097          	auipc	ra,0x0
 7c4:	bbe080e7          	jalr	-1090(ra) # 37e <sbrk>
  if(p == (char*)-1)
 7c8:	fd551ae3          	bne	a0,s5,79c <malloc+0x7c>
        return 0;
 7cc:	4501                	li	a0,0
 7ce:	74a2                	ld	s1,40(sp)
 7d0:	6a42                	ld	s4,16(sp)
 7d2:	6aa2                	ld	s5,8(sp)
 7d4:	6b02                	ld	s6,0(sp)
 7d6:	a03d                	j	804 <malloc+0xe4>
 7d8:	74a2                	ld	s1,40(sp)
 7da:	6a42                	ld	s4,16(sp)
 7dc:	6aa2                	ld	s5,8(sp)
 7de:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7e0:	fae90be3          	beq	s2,a4,796 <malloc+0x76>
        p->s.size -= nunits;
 7e4:	4137073b          	subw	a4,a4,s3
 7e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ea:	02071693          	slli	a3,a4,0x20
 7ee:	01c6d713          	srli	a4,a3,0x1c
 7f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7f8:	00000717          	auipc	a4,0x0
 7fc:	4aa73023          	sd	a0,1184(a4) # c98 <freep>
      return (void*)(p + 1);
 800:	01078513          	addi	a0,a5,16
  }
}
 804:	70e2                	ld	ra,56(sp)
 806:	7442                	ld	s0,48(sp)
 808:	7902                	ld	s2,32(sp)
 80a:	69e2                	ld	s3,24(sp)
 80c:	6121                	addi	sp,sp,64
 80e:	8082                	ret
 810:	74a2                	ld	s1,40(sp)
 812:	6a42                	ld	s4,16(sp)
 814:	6aa2                	ld	s5,8(sp)
 816:	6b02                	ld	s6,0(sp)
 818:	b7f5                	j	804 <malloc+0xe4>
