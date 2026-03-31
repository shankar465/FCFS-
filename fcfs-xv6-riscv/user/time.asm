
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/fcntl.h"

int 
main(int argc, char ** argv) 
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	892a                	mv	s2,a0
   e:	84ae                	mv	s1,a1
  int pid = fork();
  10:	00000097          	auipc	ra,0x0
  14:	324080e7          	jalr	804(ra) # 334 <fork>
  if(pid < 0) {
  18:	02054a63          	bltz	a0,4c <main+0x4c>
    printf("fork(): failed\n");
    exit(1);
  } else if(pid == 0) {
  1c:	ed39                	bnez	a0,7a <main+0x7a>
    if(argc == 1) {
  1e:	4785                	li	a5,1
  20:	04f90363          	beq	s2,a5,66 <main+0x66>
      sleep(10);
      exit(0);
    } else {
      exec(argv[1], argv + 1);
  24:	00848593          	addi	a1,s1,8
  28:	6488                	ld	a0,8(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	34a080e7          	jalr	842(ra) # 374 <exec>
      printf("exec(): failed\n");
  32:	00001517          	auipc	a0,0x1
  36:	83e50513          	addi	a0,a0,-1986 # 870 <malloc+0x10a>
  3a:	00000097          	auipc	ra,0x0
  3e:	670080e7          	jalr	1648(ra) # 6aa <printf>
      exit(1);
  42:	4505                	li	a0,1
  44:	00000097          	auipc	ra,0x0
  48:	2f8080e7          	jalr	760(ra) # 33c <exit>
    printf("fork(): failed\n");
  4c:	00001517          	auipc	a0,0x1
  50:	81450513          	addi	a0,a0,-2028 # 860 <malloc+0xfa>
  54:	00000097          	auipc	ra,0x0
  58:	656080e7          	jalr	1622(ra) # 6aa <printf>
    exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	2de080e7          	jalr	734(ra) # 33c <exit>
      sleep(10);
  66:	4529                	li	a0,10
  68:	00000097          	auipc	ra,0x0
  6c:	364080e7          	jalr	868(ra) # 3cc <sleep>
      exit(0);
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	2ca080e7          	jalr	714(ra) # 33c <exit>
    }  
  } else {
    int rtime, wtime;
    waitx(0, &wtime, &rtime);
  7a:	fd840613          	addi	a2,s0,-40
  7e:	fdc40593          	addi	a1,s0,-36
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	358080e7          	jalr	856(ra) # 3dc <waitx>
    printf("\nwaiting:%d\nrunning:%d\n", wtime, rtime);
  8c:	fd842603          	lw	a2,-40(s0)
  90:	fdc42583          	lw	a1,-36(s0)
  94:	00000517          	auipc	a0,0x0
  98:	7ec50513          	addi	a0,a0,2028 # 880 <malloc+0x11a>
  9c:	00000097          	auipc	ra,0x0
  a0:	60e080e7          	jalr	1550(ra) # 6aa <printf>
  }
  exit(0);
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	296080e7          	jalr	662(ra) # 33c <exit>

00000000000000ae <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e406                	sd	ra,8(sp)
  b2:	e022                	sd	s0,0(sp)
  b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  b6:	87aa                	mv	a5,a0
  b8:	0585                	addi	a1,a1,1
  ba:	0785                	addi	a5,a5,1
  bc:	fff5c703          	lbu	a4,-1(a1)
  c0:	fee78fa3          	sb	a4,-1(a5)
  c4:	fb75                	bnez	a4,b8 <strcpy+0xa>
    ;
  return os;
}
  c6:	60a2                	ld	ra,8(sp)
  c8:	6402                	ld	s0,0(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret

00000000000000ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e406                	sd	ra,8(sp)
  d2:	e022                	sd	s0,0(sp)
  d4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cb91                	beqz	a5,ee <strcmp+0x20>
  dc:	0005c703          	lbu	a4,0(a1)
  e0:	00f71763          	bne	a4,a5,ee <strcmp+0x20>
    p++, q++;
  e4:	0505                	addi	a0,a0,1
  e6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	fbe5                	bnez	a5,dc <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  ee:	0005c503          	lbu	a0,0(a1)
}
  f2:	40a7853b          	subw	a0,a5,a0
  f6:	60a2                	ld	ra,8(sp)
  f8:	6402                	ld	s0,0(sp)
  fa:	0141                	addi	sp,sp,16
  fc:	8082                	ret

00000000000000fe <strlen>:

uint
strlen(const char *s)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e406                	sd	ra,8(sp)
 102:	e022                	sd	s0,0(sp)
 104:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 106:	00054783          	lbu	a5,0(a0)
 10a:	cf91                	beqz	a5,126 <strlen+0x28>
 10c:	00150793          	addi	a5,a0,1
 110:	86be                	mv	a3,a5
 112:	0785                	addi	a5,a5,1
 114:	fff7c703          	lbu	a4,-1(a5)
 118:	ff65                	bnez	a4,110 <strlen+0x12>
 11a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 11e:	60a2                	ld	ra,8(sp)
 120:	6402                	ld	s0,0(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret
  for(n = 0; s[n]; n++)
 126:	4501                	li	a0,0
 128:	bfdd                	j	11e <strlen+0x20>

000000000000012a <memset>:

void*
memset(void *dst, int c, uint n)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e406                	sd	ra,8(sp)
 12e:	e022                	sd	s0,0(sp)
 130:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 132:	ca19                	beqz	a2,148 <memset+0x1e>
 134:	87aa                	mv	a5,a0
 136:	1602                	slli	a2,a2,0x20
 138:	9201                	srli	a2,a2,0x20
 13a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 13e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 142:	0785                	addi	a5,a5,1
 144:	fee79de3          	bne	a5,a4,13e <memset+0x14>
  }
  return dst;
}
 148:	60a2                	ld	ra,8(sp)
 14a:	6402                	ld	s0,0(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strchr>:

char*
strchr(const char *s, char c)
{
 150:	1141                	addi	sp,sp,-16
 152:	e406                	sd	ra,8(sp)
 154:	e022                	sd	s0,0(sp)
 156:	0800                	addi	s0,sp,16
  for(; *s; s++)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cf81                	beqz	a5,174 <strchr+0x24>
    if(*s == c)
 15e:	00f58763          	beq	a1,a5,16c <strchr+0x1c>
  for(; *s; s++)
 162:	0505                	addi	a0,a0,1
 164:	00054783          	lbu	a5,0(a0)
 168:	fbfd                	bnez	a5,15e <strchr+0xe>
      return (char*)s;
  return 0;
 16a:	4501                	li	a0,0
}
 16c:	60a2                	ld	ra,8(sp)
 16e:	6402                	ld	s0,0(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret
  return 0;
 174:	4501                	li	a0,0
 176:	bfdd                	j	16c <strchr+0x1c>

0000000000000178 <gets>:

char*
gets(char *buf, int max)
{
 178:	711d                	addi	sp,sp,-96
 17a:	ec86                	sd	ra,88(sp)
 17c:	e8a2                	sd	s0,80(sp)
 17e:	e4a6                	sd	s1,72(sp)
 180:	e0ca                	sd	s2,64(sp)
 182:	fc4e                	sd	s3,56(sp)
 184:	f852                	sd	s4,48(sp)
 186:	f456                	sd	s5,40(sp)
 188:	f05a                	sd	s6,32(sp)
 18a:	ec5e                	sd	s7,24(sp)
 18c:	e862                	sd	s8,16(sp)
 18e:	1080                	addi	s0,sp,96
 190:	8baa                	mv	s7,a0
 192:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 194:	892a                	mv	s2,a0
 196:	4481                	li	s1,0
    cc = read(0, &c, 1);
 198:	faf40b13          	addi	s6,s0,-81
 19c:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 19e:	8c26                	mv	s8,s1
 1a0:	0014899b          	addiw	s3,s1,1
 1a4:	84ce                	mv	s1,s3
 1a6:	0349d663          	bge	s3,s4,1d2 <gets+0x5a>
    cc = read(0, &c, 1);
 1aa:	8656                	mv	a2,s5
 1ac:	85da                	mv	a1,s6
 1ae:	4501                	li	a0,0
 1b0:	00000097          	auipc	ra,0x0
 1b4:	1a4080e7          	jalr	420(ra) # 354 <read>
    if(cc < 1)
 1b8:	00a05d63          	blez	a0,1d2 <gets+0x5a>
      break;
    buf[i++] = c;
 1bc:	faf44783          	lbu	a5,-81(s0)
 1c0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c4:	0905                	addi	s2,s2,1
 1c6:	ff678713          	addi	a4,a5,-10
 1ca:	c319                	beqz	a4,1d0 <gets+0x58>
 1cc:	17cd                	addi	a5,a5,-13
 1ce:	fbe1                	bnez	a5,19e <gets+0x26>
    buf[i++] = c;
 1d0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1d2:	9c5e                	add	s8,s8,s7
 1d4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1d8:	855e                	mv	a0,s7
 1da:	60e6                	ld	ra,88(sp)
 1dc:	6446                	ld	s0,80(sp)
 1de:	64a6                	ld	s1,72(sp)
 1e0:	6906                	ld	s2,64(sp)
 1e2:	79e2                	ld	s3,56(sp)
 1e4:	7a42                	ld	s4,48(sp)
 1e6:	7aa2                	ld	s5,40(sp)
 1e8:	7b02                	ld	s6,32(sp)
 1ea:	6be2                	ld	s7,24(sp)
 1ec:	6c42                	ld	s8,16(sp)
 1ee:	6125                	addi	sp,sp,96
 1f0:	8082                	ret

00000000000001f2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f2:	1101                	addi	sp,sp,-32
 1f4:	ec06                	sd	ra,24(sp)
 1f6:	e822                	sd	s0,16(sp)
 1f8:	e04a                	sd	s2,0(sp)
 1fa:	1000                	addi	s0,sp,32
 1fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fe:	4581                	li	a1,0
 200:	00000097          	auipc	ra,0x0
 204:	17c080e7          	jalr	380(ra) # 37c <open>
  if(fd < 0)
 208:	02054663          	bltz	a0,234 <stat+0x42>
 20c:	e426                	sd	s1,8(sp)
 20e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 210:	85ca                	mv	a1,s2
 212:	00000097          	auipc	ra,0x0
 216:	182080e7          	jalr	386(ra) # 394 <fstat>
 21a:	892a                	mv	s2,a0
  close(fd);
 21c:	8526                	mv	a0,s1
 21e:	00000097          	auipc	ra,0x0
 222:	146080e7          	jalr	326(ra) # 364 <close>
  return r;
 226:	64a2                	ld	s1,8(sp)
}
 228:	854a                	mv	a0,s2
 22a:	60e2                	ld	ra,24(sp)
 22c:	6442                	ld	s0,16(sp)
 22e:	6902                	ld	s2,0(sp)
 230:	6105                	addi	sp,sp,32
 232:	8082                	ret
    return -1;
 234:	57fd                	li	a5,-1
 236:	893e                	mv	s2,a5
 238:	bfc5                	j	228 <stat+0x36>

000000000000023a <atoi>:

int
atoi(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e406                	sd	ra,8(sp)
 23e:	e022                	sd	s0,0(sp)
 240:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 242:	00054683          	lbu	a3,0(a0)
 246:	fd06879b          	addiw	a5,a3,-48
 24a:	0ff7f793          	zext.b	a5,a5
 24e:	4625                	li	a2,9
 250:	02f66963          	bltu	a2,a5,282 <atoi+0x48>
 254:	872a                	mv	a4,a0
  n = 0;
 256:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 258:	0705                	addi	a4,a4,1
 25a:	0025179b          	slliw	a5,a0,0x2
 25e:	9fa9                	addw	a5,a5,a0
 260:	0017979b          	slliw	a5,a5,0x1
 264:	9fb5                	addw	a5,a5,a3
 266:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 26a:	00074683          	lbu	a3,0(a4)
 26e:	fd06879b          	addiw	a5,a3,-48
 272:	0ff7f793          	zext.b	a5,a5
 276:	fef671e3          	bgeu	a2,a5,258 <atoi+0x1e>
  return n;
}
 27a:	60a2                	ld	ra,8(sp)
 27c:	6402                	ld	s0,0(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
  n = 0;
 282:	4501                	li	a0,0
 284:	bfdd                	j	27a <atoi+0x40>

0000000000000286 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 28e:	02b57563          	bgeu	a0,a1,2b8 <memmove+0x32>
    while(n-- > 0)
 292:	00c05f63          	blez	a2,2b0 <memmove+0x2a>
 296:	1602                	slli	a2,a2,0x20
 298:	9201                	srli	a2,a2,0x20
 29a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 29e:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a0:	0585                	addi	a1,a1,1
 2a2:	0705                	addi	a4,a4,1
 2a4:	fff5c683          	lbu	a3,-1(a1)
 2a8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ac:	fee79ae3          	bne	a5,a4,2a0 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b0:	60a2                	ld	ra,8(sp)
 2b2:	6402                	ld	s0,0(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
    while(n-- > 0)
 2b8:	fec05ce3          	blez	a2,2b0 <memmove+0x2a>
    dst += n;
 2bc:	00c50733          	add	a4,a0,a2
    src += n;
 2c0:	95b2                	add	a1,a1,a2
 2c2:	fff6079b          	addiw	a5,a2,-1
 2c6:	1782                	slli	a5,a5,0x20
 2c8:	9381                	srli	a5,a5,0x20
 2ca:	fff7c793          	not	a5,a5
 2ce:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d0:	15fd                	addi	a1,a1,-1
 2d2:	177d                	addi	a4,a4,-1
 2d4:	0005c683          	lbu	a3,0(a1)
 2d8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2dc:	fef71ae3          	bne	a4,a5,2d0 <memmove+0x4a>
 2e0:	bfc1                	j	2b0 <memmove+0x2a>

00000000000002e2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e406                	sd	ra,8(sp)
 2e6:	e022                	sd	s0,0(sp)
 2e8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ea:	c61d                	beqz	a2,318 <memcmp+0x36>
 2ec:	1602                	slli	a2,a2,0x20
 2ee:	9201                	srli	a2,a2,0x20
 2f0:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2f4:	00054783          	lbu	a5,0(a0)
 2f8:	0005c703          	lbu	a4,0(a1)
 2fc:	00e79863          	bne	a5,a4,30c <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 300:	0505                	addi	a0,a0,1
    p2++;
 302:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 304:	fed518e3          	bne	a0,a3,2f4 <memcmp+0x12>
  }
  return 0;
 308:	4501                	li	a0,0
 30a:	a019                	j	310 <memcmp+0x2e>
      return *p1 - *p2;
 30c:	40e7853b          	subw	a0,a5,a4
}
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
  return 0;
 318:	4501                	li	a0,0
 31a:	bfdd                	j	310 <memcmp+0x2e>

000000000000031c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 324:	00000097          	auipc	ra,0x0
 328:	f62080e7          	jalr	-158(ra) # 286 <memmove>
}
 32c:	60a2                	ld	ra,8(sp)
 32e:	6402                	ld	s0,0(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 334:	4885                	li	a7,1
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <exit>:
.global exit
exit:
 li a7, SYS_exit
 33c:	4889                	li	a7,2
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <wait>:
.global wait
wait:
 li a7, SYS_wait
 344:	488d                	li	a7,3
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34c:	4891                	li	a7,4
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <read>:
.global read
read:
 li a7, SYS_read
 354:	4895                	li	a7,5
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <write>:
.global write
write:
 li a7, SYS_write
 35c:	48c1                	li	a7,16
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <close>:
.global close
close:
 li a7, SYS_close
 364:	48d5                	li	a7,21
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <kill>:
.global kill
kill:
 li a7, SYS_kill
 36c:	4899                	li	a7,6
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <exec>:
.global exec
exec:
 li a7, SYS_exec
 374:	489d                	li	a7,7
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <open>:
.global open
open:
 li a7, SYS_open
 37c:	48bd                	li	a7,15
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 384:	48c5                	li	a7,17
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38c:	48c9                	li	a7,18
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 394:	48a1                	li	a7,8
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <link>:
.global link
link:
 li a7, SYS_link
 39c:	48cd                	li	a7,19
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a4:	48d1                	li	a7,20
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ac:	48a5                	li	a7,9
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b4:	48a9                	li	a7,10
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3bc:	48ad                	li	a7,11
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c4:	48b1                	li	a7,12
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3cc:	48b5                	li	a7,13
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d4:	48b9                	li	a7,14
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3dc:	48d9                	li	a7,22
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e4:	1101                	addi	sp,sp,-32
 3e6:	ec06                	sd	ra,24(sp)
 3e8:	e822                	sd	s0,16(sp)
 3ea:	1000                	addi	s0,sp,32
 3ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f0:	4605                	li	a2,1
 3f2:	fef40593          	addi	a1,s0,-17
 3f6:	00000097          	auipc	ra,0x0
 3fa:	f66080e7          	jalr	-154(ra) # 35c <write>
}
 3fe:	60e2                	ld	ra,24(sp)
 400:	6442                	ld	s0,16(sp)
 402:	6105                	addi	sp,sp,32
 404:	8082                	ret

0000000000000406 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 406:	7139                	addi	sp,sp,-64
 408:	fc06                	sd	ra,56(sp)
 40a:	f822                	sd	s0,48(sp)
 40c:	f04a                	sd	s2,32(sp)
 40e:	ec4e                	sd	s3,24(sp)
 410:	0080                	addi	s0,sp,64
 412:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 414:	cad9                	beqz	a3,4aa <printint+0xa4>
 416:	01f5d79b          	srliw	a5,a1,0x1f
 41a:	cbc1                	beqz	a5,4aa <printint+0xa4>
    neg = 1;
    x = -xx;
 41c:	40b005bb          	negw	a1,a1
    neg = 1;
 420:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 422:	fc040993          	addi	s3,s0,-64
  neg = 0;
 426:	86ce                	mv	a3,s3
  i = 0;
 428:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 42a:	00000817          	auipc	a6,0x0
 42e:	4ce80813          	addi	a6,a6,1230 # 8f8 <digits>
 432:	88ba                	mv	a7,a4
 434:	0017051b          	addiw	a0,a4,1
 438:	872a                	mv	a4,a0
 43a:	02c5f7bb          	remuw	a5,a1,a2
 43e:	1782                	slli	a5,a5,0x20
 440:	9381                	srli	a5,a5,0x20
 442:	97c2                	add	a5,a5,a6
 444:	0007c783          	lbu	a5,0(a5)
 448:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 44c:	87ae                	mv	a5,a1
 44e:	02c5d5bb          	divuw	a1,a1,a2
 452:	0685                	addi	a3,a3,1
 454:	fcc7ffe3          	bgeu	a5,a2,432 <printint+0x2c>
  if(neg)
 458:	00030c63          	beqz	t1,470 <printint+0x6a>
    buf[i++] = '-';
 45c:	fd050793          	addi	a5,a0,-48
 460:	00878533          	add	a0,a5,s0
 464:	02d00793          	li	a5,45
 468:	fef50823          	sb	a5,-16(a0)
 46c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 470:	02e05763          	blez	a4,49e <printint+0x98>
 474:	f426                	sd	s1,40(sp)
 476:	377d                	addiw	a4,a4,-1
 478:	00e984b3          	add	s1,s3,a4
 47c:	19fd                	addi	s3,s3,-1
 47e:	99ba                	add	s3,s3,a4
 480:	1702                	slli	a4,a4,0x20
 482:	9301                	srli	a4,a4,0x20
 484:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 488:	0004c583          	lbu	a1,0(s1)
 48c:	854a                	mv	a0,s2
 48e:	00000097          	auipc	ra,0x0
 492:	f56080e7          	jalr	-170(ra) # 3e4 <putc>
  while(--i >= 0)
 496:	14fd                	addi	s1,s1,-1
 498:	ff3498e3          	bne	s1,s3,488 <printint+0x82>
 49c:	74a2                	ld	s1,40(sp)
}
 49e:	70e2                	ld	ra,56(sp)
 4a0:	7442                	ld	s0,48(sp)
 4a2:	7902                	ld	s2,32(sp)
 4a4:	69e2                	ld	s3,24(sp)
 4a6:	6121                	addi	sp,sp,64
 4a8:	8082                	ret
  neg = 0;
 4aa:	4301                	li	t1,0
 4ac:	bf9d                	j	422 <printint+0x1c>

00000000000004ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ae:	715d                	addi	sp,sp,-80
 4b0:	e486                	sd	ra,72(sp)
 4b2:	e0a2                	sd	s0,64(sp)
 4b4:	f84a                	sd	s2,48(sp)
 4b6:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b8:	0005c903          	lbu	s2,0(a1)
 4bc:	1a090b63          	beqz	s2,672 <vprintf+0x1c4>
 4c0:	fc26                	sd	s1,56(sp)
 4c2:	f44e                	sd	s3,40(sp)
 4c4:	f052                	sd	s4,32(sp)
 4c6:	ec56                	sd	s5,24(sp)
 4c8:	e85a                	sd	s6,16(sp)
 4ca:	e45e                	sd	s7,8(sp)
 4cc:	8aaa                	mv	s5,a0
 4ce:	8bb2                	mv	s7,a2
 4d0:	00158493          	addi	s1,a1,1
  state = 0;
 4d4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4d6:	02500a13          	li	s4,37
 4da:	4b55                	li	s6,21
 4dc:	a839                	j	4fa <vprintf+0x4c>
        putc(fd, c);
 4de:	85ca                	mv	a1,s2
 4e0:	8556                	mv	a0,s5
 4e2:	00000097          	auipc	ra,0x0
 4e6:	f02080e7          	jalr	-254(ra) # 3e4 <putc>
 4ea:	a019                	j	4f0 <vprintf+0x42>
    } else if(state == '%'){
 4ec:	01498d63          	beq	s3,s4,506 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4f0:	0485                	addi	s1,s1,1
 4f2:	fff4c903          	lbu	s2,-1(s1)
 4f6:	16090863          	beqz	s2,666 <vprintf+0x1b8>
    if(state == 0){
 4fa:	fe0999e3          	bnez	s3,4ec <vprintf+0x3e>
      if(c == '%'){
 4fe:	ff4910e3          	bne	s2,s4,4de <vprintf+0x30>
        state = '%';
 502:	89d2                	mv	s3,s4
 504:	b7f5                	j	4f0 <vprintf+0x42>
      if(c == 'd'){
 506:	13490563          	beq	s2,s4,630 <vprintf+0x182>
 50a:	f9d9079b          	addiw	a5,s2,-99
 50e:	0ff7f793          	zext.b	a5,a5
 512:	12fb6863          	bltu	s6,a5,642 <vprintf+0x194>
 516:	f9d9079b          	addiw	a5,s2,-99
 51a:	0ff7f713          	zext.b	a4,a5
 51e:	12eb6263          	bltu	s6,a4,642 <vprintf+0x194>
 522:	00271793          	slli	a5,a4,0x2
 526:	00000717          	auipc	a4,0x0
 52a:	37a70713          	addi	a4,a4,890 # 8a0 <malloc+0x13a>
 52e:	97ba                	add	a5,a5,a4
 530:	439c                	lw	a5,0(a5)
 532:	97ba                	add	a5,a5,a4
 534:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 536:	008b8913          	addi	s2,s7,8
 53a:	4685                	li	a3,1
 53c:	4629                	li	a2,10
 53e:	000ba583          	lw	a1,0(s7)
 542:	8556                	mv	a0,s5
 544:	00000097          	auipc	ra,0x0
 548:	ec2080e7          	jalr	-318(ra) # 406 <printint>
 54c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 54e:	4981                	li	s3,0
 550:	b745                	j	4f0 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 552:	008b8913          	addi	s2,s7,8
 556:	4681                	li	a3,0
 558:	4629                	li	a2,10
 55a:	000ba583          	lw	a1,0(s7)
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	ea6080e7          	jalr	-346(ra) # 406 <printint>
 568:	8bca                	mv	s7,s2
      state = 0;
 56a:	4981                	li	s3,0
 56c:	b751                	j	4f0 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 56e:	008b8913          	addi	s2,s7,8
 572:	4681                	li	a3,0
 574:	4641                	li	a2,16
 576:	000ba583          	lw	a1,0(s7)
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e8a080e7          	jalr	-374(ra) # 406 <printint>
 584:	8bca                	mv	s7,s2
      state = 0;
 586:	4981                	li	s3,0
 588:	b7a5                	j	4f0 <vprintf+0x42>
 58a:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 58c:	008b8793          	addi	a5,s7,8
 590:	8c3e                	mv	s8,a5
 592:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 596:	03000593          	li	a1,48
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e48080e7          	jalr	-440(ra) # 3e4 <putc>
  putc(fd, 'x');
 5a4:	07800593          	li	a1,120
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e3a080e7          	jalr	-454(ra) # 3e4 <putc>
 5b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b4:	00000b97          	auipc	s7,0x0
 5b8:	344b8b93          	addi	s7,s7,836 # 8f8 <digits>
 5bc:	03c9d793          	srli	a5,s3,0x3c
 5c0:	97de                	add	a5,a5,s7
 5c2:	0007c583          	lbu	a1,0(a5)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e1c080e7          	jalr	-484(ra) # 3e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5d0:	0992                	slli	s3,s3,0x4
 5d2:	397d                	addiw	s2,s2,-1
 5d4:	fe0914e3          	bnez	s2,5bc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 5d8:	8be2                	mv	s7,s8
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	6c02                	ld	s8,0(sp)
 5de:	bf09                	j	4f0 <vprintf+0x42>
        s = va_arg(ap, char*);
 5e0:	008b8993          	addi	s3,s7,8
 5e4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5e8:	02090163          	beqz	s2,60a <vprintf+0x15c>
        while(*s != 0){
 5ec:	00094583          	lbu	a1,0(s2)
 5f0:	c9a5                	beqz	a1,660 <vprintf+0x1b2>
          putc(fd, *s);
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	df0080e7          	jalr	-528(ra) # 3e4 <putc>
          s++;
 5fc:	0905                	addi	s2,s2,1
        while(*s != 0){
 5fe:	00094583          	lbu	a1,0(s2)
 602:	f9e5                	bnez	a1,5f2 <vprintf+0x144>
        s = va_arg(ap, char*);
 604:	8bce                	mv	s7,s3
      state = 0;
 606:	4981                	li	s3,0
 608:	b5e5                	j	4f0 <vprintf+0x42>
          s = "(null)";
 60a:	00000917          	auipc	s2,0x0
 60e:	28e90913          	addi	s2,s2,654 # 898 <malloc+0x132>
        while(*s != 0){
 612:	02800593          	li	a1,40
 616:	bff1                	j	5f2 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 618:	008b8913          	addi	s2,s7,8
 61c:	000bc583          	lbu	a1,0(s7)
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	dc2080e7          	jalr	-574(ra) # 3e4 <putc>
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b5c9                	j	4f0 <vprintf+0x42>
        putc(fd, c);
 630:	02500593          	li	a1,37
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	dae080e7          	jalr	-594(ra) # 3e4 <putc>
      state = 0;
 63e:	4981                	li	s3,0
 640:	bd45                	j	4f0 <vprintf+0x42>
        putc(fd, '%');
 642:	02500593          	li	a1,37
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	d9c080e7          	jalr	-612(ra) # 3e4 <putc>
        putc(fd, c);
 650:	85ca                	mv	a1,s2
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	d90080e7          	jalr	-624(ra) # 3e4 <putc>
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bd49                	j	4f0 <vprintf+0x42>
        s = va_arg(ap, char*);
 660:	8bce                	mv	s7,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	b571                	j	4f0 <vprintf+0x42>
 666:	74e2                	ld	s1,56(sp)
 668:	79a2                	ld	s3,40(sp)
 66a:	7a02                	ld	s4,32(sp)
 66c:	6ae2                	ld	s5,24(sp)
 66e:	6b42                	ld	s6,16(sp)
 670:	6ba2                	ld	s7,8(sp)
    }
  }
}
 672:	60a6                	ld	ra,72(sp)
 674:	6406                	ld	s0,64(sp)
 676:	7942                	ld	s2,48(sp)
 678:	6161                	addi	sp,sp,80
 67a:	8082                	ret

000000000000067c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 67c:	715d                	addi	sp,sp,-80
 67e:	ec06                	sd	ra,24(sp)
 680:	e822                	sd	s0,16(sp)
 682:	1000                	addi	s0,sp,32
 684:	e010                	sd	a2,0(s0)
 686:	e414                	sd	a3,8(s0)
 688:	e818                	sd	a4,16(s0)
 68a:	ec1c                	sd	a5,24(s0)
 68c:	03043023          	sd	a6,32(s0)
 690:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 694:	8622                	mv	a2,s0
 696:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 69a:	00000097          	auipc	ra,0x0
 69e:	e14080e7          	jalr	-492(ra) # 4ae <vprintf>
}
 6a2:	60e2                	ld	ra,24(sp)
 6a4:	6442                	ld	s0,16(sp)
 6a6:	6161                	addi	sp,sp,80
 6a8:	8082                	ret

00000000000006aa <printf>:

void
printf(const char *fmt, ...)
{
 6aa:	711d                	addi	sp,sp,-96
 6ac:	ec06                	sd	ra,24(sp)
 6ae:	e822                	sd	s0,16(sp)
 6b0:	1000                	addi	s0,sp,32
 6b2:	e40c                	sd	a1,8(s0)
 6b4:	e810                	sd	a2,16(s0)
 6b6:	ec14                	sd	a3,24(s0)
 6b8:	f018                	sd	a4,32(s0)
 6ba:	f41c                	sd	a5,40(s0)
 6bc:	03043823          	sd	a6,48(s0)
 6c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	00840613          	addi	a2,s0,8
 6c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6cc:	85aa                	mv	a1,a0
 6ce:	4505                	li	a0,1
 6d0:	00000097          	auipc	ra,0x0
 6d4:	dde080e7          	jalr	-546(ra) # 4ae <vprintf>
}
 6d8:	60e2                	ld	ra,24(sp)
 6da:	6442                	ld	s0,16(sp)
 6dc:	6125                	addi	sp,sp,96
 6de:	8082                	ret

00000000000006e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e0:	1141                	addi	sp,sp,-16
 6e2:	e406                	sd	ra,8(sp)
 6e4:	e022                	sd	s0,0(sp)
 6e6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ec:	00000797          	auipc	a5,0x0
 6f0:	6047b783          	ld	a5,1540(a5) # cf0 <freep>
 6f4:	a039                	j	702 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f6:	6398                	ld	a4,0(a5)
 6f8:	00e7e463          	bltu	a5,a4,700 <free+0x20>
 6fc:	00e6ea63          	bltu	a3,a4,710 <free+0x30>
{
 700:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 702:	fed7fae3          	bgeu	a5,a3,6f6 <free+0x16>
 706:	6398                	ld	a4,0(a5)
 708:	00e6e463          	bltu	a3,a4,710 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70c:	fee7eae3          	bltu	a5,a4,700 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 710:	ff852583          	lw	a1,-8(a0)
 714:	6390                	ld	a2,0(a5)
 716:	02059813          	slli	a6,a1,0x20
 71a:	01c85713          	srli	a4,a6,0x1c
 71e:	9736                	add	a4,a4,a3
 720:	02e60563          	beq	a2,a4,74a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 724:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 728:	4790                	lw	a2,8(a5)
 72a:	02061593          	slli	a1,a2,0x20
 72e:	01c5d713          	srli	a4,a1,0x1c
 732:	973e                	add	a4,a4,a5
 734:	02e68263          	beq	a3,a4,758 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 738:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 73a:	00000717          	auipc	a4,0x0
 73e:	5af73b23          	sd	a5,1462(a4) # cf0 <freep>
}
 742:	60a2                	ld	ra,8(sp)
 744:	6402                	ld	s0,0(sp)
 746:	0141                	addi	sp,sp,16
 748:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 74a:	4618                	lw	a4,8(a2)
 74c:	9f2d                	addw	a4,a4,a1
 74e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 752:	6398                	ld	a4,0(a5)
 754:	6310                	ld	a2,0(a4)
 756:	b7f9                	j	724 <free+0x44>
    p->s.size += bp->s.size;
 758:	ff852703          	lw	a4,-8(a0)
 75c:	9f31                	addw	a4,a4,a2
 75e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 760:	ff053683          	ld	a3,-16(a0)
 764:	bfd1                	j	738 <free+0x58>

0000000000000766 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 766:	7139                	addi	sp,sp,-64
 768:	fc06                	sd	ra,56(sp)
 76a:	f822                	sd	s0,48(sp)
 76c:	f04a                	sd	s2,32(sp)
 76e:	ec4e                	sd	s3,24(sp)
 770:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 772:	02051993          	slli	s3,a0,0x20
 776:	0209d993          	srli	s3,s3,0x20
 77a:	09bd                	addi	s3,s3,15
 77c:	0049d993          	srli	s3,s3,0x4
 780:	2985                	addiw	s3,s3,1
 782:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 784:	00000517          	auipc	a0,0x0
 788:	56c53503          	ld	a0,1388(a0) # cf0 <freep>
 78c:	c905                	beqz	a0,7bc <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 790:	4798                	lw	a4,8(a5)
 792:	09377a63          	bgeu	a4,s3,826 <malloc+0xc0>
 796:	f426                	sd	s1,40(sp)
 798:	e852                	sd	s4,16(sp)
 79a:	e456                	sd	s5,8(sp)
 79c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 79e:	8a4e                	mv	s4,s3
 7a0:	6705                	lui	a4,0x1
 7a2:	00e9f363          	bgeu	s3,a4,7a8 <malloc+0x42>
 7a6:	6a05                	lui	s4,0x1
 7a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7b0:	00000497          	auipc	s1,0x0
 7b4:	54048493          	addi	s1,s1,1344 # cf0 <freep>
  if(p == (char*)-1)
 7b8:	5afd                	li	s5,-1
 7ba:	a089                	j	7fc <malloc+0x96>
 7bc:	f426                	sd	s1,40(sp)
 7be:	e852                	sd	s4,16(sp)
 7c0:	e456                	sd	s5,8(sp)
 7c2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7c4:	00000797          	auipc	a5,0x0
 7c8:	53478793          	addi	a5,a5,1332 # cf8 <base>
 7cc:	00000717          	auipc	a4,0x0
 7d0:	52f73223          	sd	a5,1316(a4) # cf0 <freep>
 7d4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7d6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7da:	b7d1                	j	79e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 7dc:	6398                	ld	a4,0(a5)
 7de:	e118                	sd	a4,0(a0)
 7e0:	a8b9                	j	83e <malloc+0xd8>
  hp->s.size = nu;
 7e2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7e6:	0541                	addi	a0,a0,16
 7e8:	00000097          	auipc	ra,0x0
 7ec:	ef8080e7          	jalr	-264(ra) # 6e0 <free>
  return freep;
 7f0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7f2:	c135                	beqz	a0,856 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f6:	4798                	lw	a4,8(a5)
 7f8:	03277363          	bgeu	a4,s2,81e <malloc+0xb8>
    if(p == freep)
 7fc:	6098                	ld	a4,0(s1)
 7fe:	853e                	mv	a0,a5
 800:	fef71ae3          	bne	a4,a5,7f4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 804:	8552                	mv	a0,s4
 806:	00000097          	auipc	ra,0x0
 80a:	bbe080e7          	jalr	-1090(ra) # 3c4 <sbrk>
  if(p == (char*)-1)
 80e:	fd551ae3          	bne	a0,s5,7e2 <malloc+0x7c>
        return 0;
 812:	4501                	li	a0,0
 814:	74a2                	ld	s1,40(sp)
 816:	6a42                	ld	s4,16(sp)
 818:	6aa2                	ld	s5,8(sp)
 81a:	6b02                	ld	s6,0(sp)
 81c:	a03d                	j	84a <malloc+0xe4>
 81e:	74a2                	ld	s1,40(sp)
 820:	6a42                	ld	s4,16(sp)
 822:	6aa2                	ld	s5,8(sp)
 824:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 826:	fae90be3          	beq	s2,a4,7dc <malloc+0x76>
        p->s.size -= nunits;
 82a:	4137073b          	subw	a4,a4,s3
 82e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 830:	02071693          	slli	a3,a4,0x20
 834:	01c6d713          	srli	a4,a3,0x1c
 838:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 83a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 83e:	00000717          	auipc	a4,0x0
 842:	4aa73923          	sd	a0,1202(a4) # cf0 <freep>
      return (void*)(p + 1);
 846:	01078513          	addi	a0,a5,16
  }
}
 84a:	70e2                	ld	ra,56(sp)
 84c:	7442                	ld	s0,48(sp)
 84e:	7902                	ld	s2,32(sp)
 850:	69e2                	ld	s3,24(sp)
 852:	6121                	addi	sp,sp,64
 854:	8082                	ret
 856:	74a2                	ld	s1,40(sp)
 858:	6a42                	ld	s4,16(sp)
 85a:	6aa2                	ld	s5,8(sp)
 85c:	6b02                	ld	s6,0(sp)
 85e:	b7f5                	j	84a <malloc+0xe4>
