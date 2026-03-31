
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	e05a                	sd	s6,0(sp)
  12:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  14:	4785                	li	a5,1
  16:	06a7d863          	bge	a5,a0,86 <main+0x86>
  1a:	00858493          	addi	s1,a1,8
  1e:	3579                	addiw	a0,a0,-2
  20:	02051793          	slli	a5,a0,0x20
  24:	01d7d513          	srli	a0,a5,0x1d
  28:	00a48ab3          	add	s5,s1,a0
  2c:	05c1                	addi	a1,a1,16
  2e:	00a58a33          	add	s4,a1,a0
    write(1, argv[i], strlen(argv[i]));
  32:	4985                	li	s3,1
    if(i + 1 < argc){
      write(1, " ", 1);
  34:	00001b17          	auipc	s6,0x1
  38:	814b0b13          	addi	s6,s6,-2028 # 848 <malloc+0x100>
  3c:	a819                	j	52 <main+0x52>
  3e:	864e                	mv	a2,s3
  40:	85da                	mv	a1,s6
  42:	854e                	mv	a0,s3
  44:	00000097          	auipc	ra,0x0
  48:	2fa080e7          	jalr	762(ra) # 33e <write>
  for(i = 1; i < argc; i++){
  4c:	04a1                	addi	s1,s1,8
  4e:	03448c63          	beq	s1,s4,86 <main+0x86>
    write(1, argv[i], strlen(argv[i]));
  52:	0004b903          	ld	s2,0(s1)
  56:	854a                	mv	a0,s2
  58:	00000097          	auipc	ra,0x0
  5c:	088080e7          	jalr	136(ra) # e0 <strlen>
  60:	862a                	mv	a2,a0
  62:	85ca                	mv	a1,s2
  64:	854e                	mv	a0,s3
  66:	00000097          	auipc	ra,0x0
  6a:	2d8080e7          	jalr	728(ra) # 33e <write>
    if(i + 1 < argc){
  6e:	fd5498e3          	bne	s1,s5,3e <main+0x3e>
    } else {
      write(1, "\n", 1);
  72:	4605                	li	a2,1
  74:	00000597          	auipc	a1,0x0
  78:	7dc58593          	addi	a1,a1,2012 # 850 <malloc+0x108>
  7c:	8532                	mv	a0,a2
  7e:	00000097          	auipc	ra,0x0
  82:	2c0080e7          	jalr	704(ra) # 33e <write>
    }
  }
  exit(0);
  86:	4501                	li	a0,0
  88:	00000097          	auipc	ra,0x0
  8c:	296080e7          	jalr	662(ra) # 31e <exit>

0000000000000090 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  90:	1141                	addi	sp,sp,-16
  92:	e406                	sd	ra,8(sp)
  94:	e022                	sd	s0,0(sp)
  96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  98:	87aa                	mv	a5,a0
  9a:	0585                	addi	a1,a1,1
  9c:	0785                	addi	a5,a5,1
  9e:	fff5c703          	lbu	a4,-1(a1)
  a2:	fee78fa3          	sb	a4,-1(a5)
  a6:	fb75                	bnez	a4,9a <strcpy+0xa>
    ;
  return os;
}
  a8:	60a2                	ld	ra,8(sp)
  aa:	6402                	ld	s0,0(sp)
  ac:	0141                	addi	sp,sp,16
  ae:	8082                	ret

00000000000000b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e406                	sd	ra,8(sp)
  b4:	e022                	sd	s0,0(sp)
  b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	cb91                	beqz	a5,d0 <strcmp+0x20>
  be:	0005c703          	lbu	a4,0(a1)
  c2:	00f71763          	bne	a4,a5,d0 <strcmp+0x20>
    p++, q++;
  c6:	0505                	addi	a0,a0,1
  c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	fbe5                	bnez	a5,be <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  d0:	0005c503          	lbu	a0,0(a1)
}
  d4:	40a7853b          	subw	a0,a5,a0
  d8:	60a2                	ld	ra,8(sp)
  da:	6402                	ld	s0,0(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret

00000000000000e0 <strlen>:

uint
strlen(const char *s)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e406                	sd	ra,8(sp)
  e4:	e022                	sd	s0,0(sp)
  e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	cf91                	beqz	a5,108 <strlen+0x28>
  ee:	00150793          	addi	a5,a0,1
  f2:	86be                	mv	a3,a5
  f4:	0785                	addi	a5,a5,1
  f6:	fff7c703          	lbu	a4,-1(a5)
  fa:	ff65                	bnez	a4,f2 <strlen+0x12>
  fc:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 100:	60a2                	ld	ra,8(sp)
 102:	6402                	ld	s0,0(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret
  for(n = 0; s[n]; n++)
 108:	4501                	li	a0,0
 10a:	bfdd                	j	100 <strlen+0x20>

000000000000010c <memset>:

void*
memset(void *dst, int c, uint n)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 114:	ca19                	beqz	a2,12a <memset+0x1e>
 116:	87aa                	mv	a5,a0
 118:	1602                	slli	a2,a2,0x20
 11a:	9201                	srli	a2,a2,0x20
 11c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 120:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 124:	0785                	addi	a5,a5,1
 126:	fee79de3          	bne	a5,a4,120 <memset+0x14>
  }
  return dst;
}
 12a:	60a2                	ld	ra,8(sp)
 12c:	6402                	ld	s0,0(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret

0000000000000132 <strchr>:

char*
strchr(const char *s, char c)
{
 132:	1141                	addi	sp,sp,-16
 134:	e406                	sd	ra,8(sp)
 136:	e022                	sd	s0,0(sp)
 138:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cf81                	beqz	a5,156 <strchr+0x24>
    if(*s == c)
 140:	00f58763          	beq	a1,a5,14e <strchr+0x1c>
  for(; *s; s++)
 144:	0505                	addi	a0,a0,1
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbfd                	bnez	a5,140 <strchr+0xe>
      return (char*)s;
  return 0;
 14c:	4501                	li	a0,0
}
 14e:	60a2                	ld	ra,8(sp)
 150:	6402                	ld	s0,0(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  return 0;
 156:	4501                	li	a0,0
 158:	bfdd                	j	14e <strchr+0x1c>

000000000000015a <gets>:

char*
gets(char *buf, int max)
{
 15a:	711d                	addi	sp,sp,-96
 15c:	ec86                	sd	ra,88(sp)
 15e:	e8a2                	sd	s0,80(sp)
 160:	e4a6                	sd	s1,72(sp)
 162:	e0ca                	sd	s2,64(sp)
 164:	fc4e                	sd	s3,56(sp)
 166:	f852                	sd	s4,48(sp)
 168:	f456                	sd	s5,40(sp)
 16a:	f05a                	sd	s6,32(sp)
 16c:	ec5e                	sd	s7,24(sp)
 16e:	e862                	sd	s8,16(sp)
 170:	1080                	addi	s0,sp,96
 172:	8baa                	mv	s7,a0
 174:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 176:	892a                	mv	s2,a0
 178:	4481                	li	s1,0
    cc = read(0, &c, 1);
 17a:	faf40b13          	addi	s6,s0,-81
 17e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 180:	8c26                	mv	s8,s1
 182:	0014899b          	addiw	s3,s1,1
 186:	84ce                	mv	s1,s3
 188:	0349d663          	bge	s3,s4,1b4 <gets+0x5a>
    cc = read(0, &c, 1);
 18c:	8656                	mv	a2,s5
 18e:	85da                	mv	a1,s6
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	1a4080e7          	jalr	420(ra) # 336 <read>
    if(cc < 1)
 19a:	00a05d63          	blez	a0,1b4 <gets+0x5a>
      break;
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	0905                	addi	s2,s2,1
 1a8:	ff678713          	addi	a4,a5,-10
 1ac:	c319                	beqz	a4,1b2 <gets+0x58>
 1ae:	17cd                	addi	a5,a5,-13
 1b0:	fbe1                	bnez	a5,180 <gets+0x26>
    buf[i++] = c;
 1b2:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1b4:	9c5e                	add	s8,s8,s7
 1b6:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1ba:	855e                	mv	a0,s7
 1bc:	60e6                	ld	ra,88(sp)
 1be:	6446                	ld	s0,80(sp)
 1c0:	64a6                	ld	s1,72(sp)
 1c2:	6906                	ld	s2,64(sp)
 1c4:	79e2                	ld	s3,56(sp)
 1c6:	7a42                	ld	s4,48(sp)
 1c8:	7aa2                	ld	s5,40(sp)
 1ca:	7b02                	ld	s6,32(sp)
 1cc:	6be2                	ld	s7,24(sp)
 1ce:	6c42                	ld	s8,16(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e04a                	sd	s2,0(sp)
 1dc:	1000                	addi	s0,sp,32
 1de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e0:	4581                	li	a1,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	17c080e7          	jalr	380(ra) # 35e <open>
  if(fd < 0)
 1ea:	02054663          	bltz	a0,216 <stat+0x42>
 1ee:	e426                	sd	s1,8(sp)
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	00000097          	auipc	ra,0x0
 1f8:	182080e7          	jalr	386(ra) # 376 <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	00000097          	auipc	ra,0x0
 204:	146080e7          	jalr	326(ra) # 346 <close>
  return r;
 208:	64a2                	ld	s1,8(sp)
}
 20a:	854a                	mv	a0,s2
 20c:	60e2                	ld	ra,24(sp)
 20e:	6442                	ld	s0,16(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	57fd                	li	a5,-1
 218:	893e                	mv	s2,a5
 21a:	bfc5                	j	20a <stat+0x36>

000000000000021c <atoi>:

int
atoi(const char *s)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 224:	00054683          	lbu	a3,0(a0)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	4625                	li	a2,9
 232:	02f66963          	bltu	a2,a5,264 <atoi+0x48>
 236:	872a                	mv	a4,a0
  n = 0;
 238:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23a:	0705                	addi	a4,a4,1
 23c:	0025179b          	slliw	a5,a0,0x2
 240:	9fa9                	addw	a5,a5,a0
 242:	0017979b          	slliw	a5,a5,0x1
 246:	9fb5                	addw	a5,a5,a3
 248:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24c:	00074683          	lbu	a3,0(a4)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	fef671e3          	bgeu	a2,a5,23a <atoi+0x1e>
  return n;
}
 25c:	60a2                	ld	ra,8(sp)
 25e:	6402                	ld	s0,0(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
  n = 0;
 264:	4501                	li	a0,0
 266:	bfdd                	j	25c <atoi+0x40>

0000000000000268 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 270:	02b57563          	bgeu	a0,a1,29a <memmove+0x32>
    while(n-- > 0)
 274:	00c05f63          	blez	a2,292 <memmove+0x2a>
 278:	1602                	slli	a2,a2,0x20
 27a:	9201                	srli	a2,a2,0x20
 27c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 280:	872a                	mv	a4,a0
      *dst++ = *src++;
 282:	0585                	addi	a1,a1,1
 284:	0705                	addi	a4,a4,1
 286:	fff5c683          	lbu	a3,-1(a1)
 28a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28e:	fee79ae3          	bne	a5,a4,282 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
    while(n-- > 0)
 29a:	fec05ce3          	blez	a2,292 <memmove+0x2a>
    dst += n;
 29e:	00c50733          	add	a4,a0,a2
    src += n;
 2a2:	95b2                	add	a1,a1,a2
 2a4:	fff6079b          	addiw	a5,a2,-1
 2a8:	1782                	slli	a5,a5,0x20
 2aa:	9381                	srli	a5,a5,0x20
 2ac:	fff7c793          	not	a5,a5
 2b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b2:	15fd                	addi	a1,a1,-1
 2b4:	177d                	addi	a4,a4,-1
 2b6:	0005c683          	lbu	a3,0(a1)
 2ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2be:	fef71ae3          	bne	a4,a5,2b2 <memmove+0x4a>
 2c2:	bfc1                	j	292 <memmove+0x2a>

00000000000002c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2cc:	c61d                	beqz	a2,2fa <memcmp+0x36>
 2ce:	1602                	slli	a2,a2,0x20
 2d0:	9201                	srli	a2,a2,0x20
 2d2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	0005c703          	lbu	a4,0(a1)
 2de:	00e79863          	bne	a5,a4,2ee <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2e2:	0505                	addi	a0,a0,1
    p2++;
 2e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e6:	fed518e3          	bne	a0,a3,2d6 <memcmp+0x12>
  }
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	a019                	j	2f2 <memcmp+0x2e>
      return *p1 - *p2;
 2ee:	40e7853b          	subw	a0,a5,a4
}
 2f2:	60a2                	ld	ra,8(sp)
 2f4:	6402                	ld	s0,0(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	bfdd                	j	2f2 <memcmp+0x2e>

00000000000002fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 306:	00000097          	auipc	ra,0x0
 30a:	f62080e7          	jalr	-158(ra) # 268 <memmove>
}
 30e:	60a2                	ld	ra,8(sp)
 310:	6402                	ld	s0,0(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret

0000000000000316 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 316:	4885                	li	a7,1
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <exit>:
.global exit
exit:
 li a7, SYS_exit
 31e:	4889                	li	a7,2
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <wait>:
.global wait
wait:
 li a7, SYS_wait
 326:	488d                	li	a7,3
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32e:	4891                	li	a7,4
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <read>:
.global read
read:
 li a7, SYS_read
 336:	4895                	li	a7,5
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <write>:
.global write
write:
 li a7, SYS_write
 33e:	48c1                	li	a7,16
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <close>:
.global close
close:
 li a7, SYS_close
 346:	48d5                	li	a7,21
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <kill>:
.global kill
kill:
 li a7, SYS_kill
 34e:	4899                	li	a7,6
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <exec>:
.global exec
exec:
 li a7, SYS_exec
 356:	489d                	li	a7,7
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <open>:
.global open
open:
 li a7, SYS_open
 35e:	48bd                	li	a7,15
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 366:	48c5                	li	a7,17
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 36e:	48c9                	li	a7,18
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 376:	48a1                	li	a7,8
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <link>:
.global link
link:
 li a7, SYS_link
 37e:	48cd                	li	a7,19
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 386:	48d1                	li	a7,20
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 38e:	48a5                	li	a7,9
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <dup>:
.global dup
dup:
 li a7, SYS_dup
 396:	48a9                	li	a7,10
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 39e:	48ad                	li	a7,11
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a6:	48b1                	li	a7,12
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ae:	48b5                	li	a7,13
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b6:	48b9                	li	a7,14
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3be:	48d9                	li	a7,22
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c6:	1101                	addi	sp,sp,-32
 3c8:	ec06                	sd	ra,24(sp)
 3ca:	e822                	sd	s0,16(sp)
 3cc:	1000                	addi	s0,sp,32
 3ce:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d2:	4605                	li	a2,1
 3d4:	fef40593          	addi	a1,s0,-17
 3d8:	00000097          	auipc	ra,0x0
 3dc:	f66080e7          	jalr	-154(ra) # 33e <write>
}
 3e0:	60e2                	ld	ra,24(sp)
 3e2:	6442                	ld	s0,16(sp)
 3e4:	6105                	addi	sp,sp,32
 3e6:	8082                	ret

00000000000003e8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e8:	7139                	addi	sp,sp,-64
 3ea:	fc06                	sd	ra,56(sp)
 3ec:	f822                	sd	s0,48(sp)
 3ee:	f04a                	sd	s2,32(sp)
 3f0:	ec4e                	sd	s3,24(sp)
 3f2:	0080                	addi	s0,sp,64
 3f4:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f6:	cad9                	beqz	a3,48c <printint+0xa4>
 3f8:	01f5d79b          	srliw	a5,a1,0x1f
 3fc:	cbc1                	beqz	a5,48c <printint+0xa4>
    neg = 1;
    x = -xx;
 3fe:	40b005bb          	negw	a1,a1
    neg = 1;
 402:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 404:	fc040993          	addi	s3,s0,-64
  neg = 0;
 408:	86ce                	mv	a3,s3
  i = 0;
 40a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 40c:	00000817          	auipc	a6,0x0
 410:	4ac80813          	addi	a6,a6,1196 # 8b8 <digits>
 414:	88ba                	mv	a7,a4
 416:	0017051b          	addiw	a0,a4,1
 41a:	872a                	mv	a4,a0
 41c:	02c5f7bb          	remuw	a5,a1,a2
 420:	1782                	slli	a5,a5,0x20
 422:	9381                	srli	a5,a5,0x20
 424:	97c2                	add	a5,a5,a6
 426:	0007c783          	lbu	a5,0(a5)
 42a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 42e:	87ae                	mv	a5,a1
 430:	02c5d5bb          	divuw	a1,a1,a2
 434:	0685                	addi	a3,a3,1
 436:	fcc7ffe3          	bgeu	a5,a2,414 <printint+0x2c>
  if(neg)
 43a:	00030c63          	beqz	t1,452 <printint+0x6a>
    buf[i++] = '-';
 43e:	fd050793          	addi	a5,a0,-48
 442:	00878533          	add	a0,a5,s0
 446:	02d00793          	li	a5,45
 44a:	fef50823          	sb	a5,-16(a0)
 44e:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 452:	02e05763          	blez	a4,480 <printint+0x98>
 456:	f426                	sd	s1,40(sp)
 458:	377d                	addiw	a4,a4,-1
 45a:	00e984b3          	add	s1,s3,a4
 45e:	19fd                	addi	s3,s3,-1
 460:	99ba                	add	s3,s3,a4
 462:	1702                	slli	a4,a4,0x20
 464:	9301                	srli	a4,a4,0x20
 466:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 46a:	0004c583          	lbu	a1,0(s1)
 46e:	854a                	mv	a0,s2
 470:	00000097          	auipc	ra,0x0
 474:	f56080e7          	jalr	-170(ra) # 3c6 <putc>
  while(--i >= 0)
 478:	14fd                	addi	s1,s1,-1
 47a:	ff3498e3          	bne	s1,s3,46a <printint+0x82>
 47e:	74a2                	ld	s1,40(sp)
}
 480:	70e2                	ld	ra,56(sp)
 482:	7442                	ld	s0,48(sp)
 484:	7902                	ld	s2,32(sp)
 486:	69e2                	ld	s3,24(sp)
 488:	6121                	addi	sp,sp,64
 48a:	8082                	ret
  neg = 0;
 48c:	4301                	li	t1,0
 48e:	bf9d                	j	404 <printint+0x1c>

0000000000000490 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 490:	715d                	addi	sp,sp,-80
 492:	e486                	sd	ra,72(sp)
 494:	e0a2                	sd	s0,64(sp)
 496:	f84a                	sd	s2,48(sp)
 498:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49a:	0005c903          	lbu	s2,0(a1)
 49e:	1a090b63          	beqz	s2,654 <vprintf+0x1c4>
 4a2:	fc26                	sd	s1,56(sp)
 4a4:	f44e                	sd	s3,40(sp)
 4a6:	f052                	sd	s4,32(sp)
 4a8:	ec56                	sd	s5,24(sp)
 4aa:	e85a                	sd	s6,16(sp)
 4ac:	e45e                	sd	s7,8(sp)
 4ae:	8aaa                	mv	s5,a0
 4b0:	8bb2                	mv	s7,a2
 4b2:	00158493          	addi	s1,a1,1
  state = 0;
 4b6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b8:	02500a13          	li	s4,37
 4bc:	4b55                	li	s6,21
 4be:	a839                	j	4dc <vprintf+0x4c>
        putc(fd, c);
 4c0:	85ca                	mv	a1,s2
 4c2:	8556                	mv	a0,s5
 4c4:	00000097          	auipc	ra,0x0
 4c8:	f02080e7          	jalr	-254(ra) # 3c6 <putc>
 4cc:	a019                	j	4d2 <vprintf+0x42>
    } else if(state == '%'){
 4ce:	01498d63          	beq	s3,s4,4e8 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4d2:	0485                	addi	s1,s1,1
 4d4:	fff4c903          	lbu	s2,-1(s1)
 4d8:	16090863          	beqz	s2,648 <vprintf+0x1b8>
    if(state == 0){
 4dc:	fe0999e3          	bnez	s3,4ce <vprintf+0x3e>
      if(c == '%'){
 4e0:	ff4910e3          	bne	s2,s4,4c0 <vprintf+0x30>
        state = '%';
 4e4:	89d2                	mv	s3,s4
 4e6:	b7f5                	j	4d2 <vprintf+0x42>
      if(c == 'd'){
 4e8:	13490563          	beq	s2,s4,612 <vprintf+0x182>
 4ec:	f9d9079b          	addiw	a5,s2,-99
 4f0:	0ff7f793          	zext.b	a5,a5
 4f4:	12fb6863          	bltu	s6,a5,624 <vprintf+0x194>
 4f8:	f9d9079b          	addiw	a5,s2,-99
 4fc:	0ff7f713          	zext.b	a4,a5
 500:	12eb6263          	bltu	s6,a4,624 <vprintf+0x194>
 504:	00271793          	slli	a5,a4,0x2
 508:	00000717          	auipc	a4,0x0
 50c:	35870713          	addi	a4,a4,856 # 860 <malloc+0x118>
 510:	97ba                	add	a5,a5,a4
 512:	439c                	lw	a5,0(a5)
 514:	97ba                	add	a5,a5,a4
 516:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 518:	008b8913          	addi	s2,s7,8
 51c:	4685                	li	a3,1
 51e:	4629                	li	a2,10
 520:	000ba583          	lw	a1,0(s7)
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	ec2080e7          	jalr	-318(ra) # 3e8 <printint>
 52e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 530:	4981                	li	s3,0
 532:	b745                	j	4d2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 534:	008b8913          	addi	s2,s7,8
 538:	4681                	li	a3,0
 53a:	4629                	li	a2,10
 53c:	000ba583          	lw	a1,0(s7)
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	ea6080e7          	jalr	-346(ra) # 3e8 <printint>
 54a:	8bca                	mv	s7,s2
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b751                	j	4d2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 550:	008b8913          	addi	s2,s7,8
 554:	4681                	li	a3,0
 556:	4641                	li	a2,16
 558:	000ba583          	lw	a1,0(s7)
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e8a080e7          	jalr	-374(ra) # 3e8 <printint>
 566:	8bca                	mv	s7,s2
      state = 0;
 568:	4981                	li	s3,0
 56a:	b7a5                	j	4d2 <vprintf+0x42>
 56c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 56e:	008b8793          	addi	a5,s7,8
 572:	8c3e                	mv	s8,a5
 574:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 578:	03000593          	li	a1,48
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e48080e7          	jalr	-440(ra) # 3c6 <putc>
  putc(fd, 'x');
 586:	07800593          	li	a1,120
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	e3a080e7          	jalr	-454(ra) # 3c6 <putc>
 594:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 596:	00000b97          	auipc	s7,0x0
 59a:	322b8b93          	addi	s7,s7,802 # 8b8 <digits>
 59e:	03c9d793          	srli	a5,s3,0x3c
 5a2:	97de                	add	a5,a5,s7
 5a4:	0007c583          	lbu	a1,0(a5)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e1c080e7          	jalr	-484(ra) # 3c6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b2:	0992                	slli	s3,s3,0x4
 5b4:	397d                	addiw	s2,s2,-1
 5b6:	fe0914e3          	bnez	s2,59e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 5ba:	8be2                	mv	s7,s8
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	6c02                	ld	s8,0(sp)
 5c0:	bf09                	j	4d2 <vprintf+0x42>
        s = va_arg(ap, char*);
 5c2:	008b8993          	addi	s3,s7,8
 5c6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5ca:	02090163          	beqz	s2,5ec <vprintf+0x15c>
        while(*s != 0){
 5ce:	00094583          	lbu	a1,0(s2)
 5d2:	c9a5                	beqz	a1,642 <vprintf+0x1b2>
          putc(fd, *s);
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	df0080e7          	jalr	-528(ra) # 3c6 <putc>
          s++;
 5de:	0905                	addi	s2,s2,1
        while(*s != 0){
 5e0:	00094583          	lbu	a1,0(s2)
 5e4:	f9e5                	bnez	a1,5d4 <vprintf+0x144>
        s = va_arg(ap, char*);
 5e6:	8bce                	mv	s7,s3
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b5e5                	j	4d2 <vprintf+0x42>
          s = "(null)";
 5ec:	00000917          	auipc	s2,0x0
 5f0:	26c90913          	addi	s2,s2,620 # 858 <malloc+0x110>
        while(*s != 0){
 5f4:	02800593          	li	a1,40
 5f8:	bff1                	j	5d4 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 5fa:	008b8913          	addi	s2,s7,8
 5fe:	000bc583          	lbu	a1,0(s7)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	dc2080e7          	jalr	-574(ra) # 3c6 <putc>
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	b5c9                	j	4d2 <vprintf+0x42>
        putc(fd, c);
 612:	02500593          	li	a1,37
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	dae080e7          	jalr	-594(ra) # 3c6 <putc>
      state = 0;
 620:	4981                	li	s3,0
 622:	bd45                	j	4d2 <vprintf+0x42>
        putc(fd, '%');
 624:	02500593          	li	a1,37
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	d9c080e7          	jalr	-612(ra) # 3c6 <putc>
        putc(fd, c);
 632:	85ca                	mv	a1,s2
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	d90080e7          	jalr	-624(ra) # 3c6 <putc>
      state = 0;
 63e:	4981                	li	s3,0
 640:	bd49                	j	4d2 <vprintf+0x42>
        s = va_arg(ap, char*);
 642:	8bce                	mv	s7,s3
      state = 0;
 644:	4981                	li	s3,0
 646:	b571                	j	4d2 <vprintf+0x42>
 648:	74e2                	ld	s1,56(sp)
 64a:	79a2                	ld	s3,40(sp)
 64c:	7a02                	ld	s4,32(sp)
 64e:	6ae2                	ld	s5,24(sp)
 650:	6b42                	ld	s6,16(sp)
 652:	6ba2                	ld	s7,8(sp)
    }
  }
}
 654:	60a6                	ld	ra,72(sp)
 656:	6406                	ld	s0,64(sp)
 658:	7942                	ld	s2,48(sp)
 65a:	6161                	addi	sp,sp,80
 65c:	8082                	ret

000000000000065e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 65e:	715d                	addi	sp,sp,-80
 660:	ec06                	sd	ra,24(sp)
 662:	e822                	sd	s0,16(sp)
 664:	1000                	addi	s0,sp,32
 666:	e010                	sd	a2,0(s0)
 668:	e414                	sd	a3,8(s0)
 66a:	e818                	sd	a4,16(s0)
 66c:	ec1c                	sd	a5,24(s0)
 66e:	03043023          	sd	a6,32(s0)
 672:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 676:	8622                	mv	a2,s0
 678:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 67c:	00000097          	auipc	ra,0x0
 680:	e14080e7          	jalr	-492(ra) # 490 <vprintf>
}
 684:	60e2                	ld	ra,24(sp)
 686:	6442                	ld	s0,16(sp)
 688:	6161                	addi	sp,sp,80
 68a:	8082                	ret

000000000000068c <printf>:

void
printf(const char *fmt, ...)
{
 68c:	711d                	addi	sp,sp,-96
 68e:	ec06                	sd	ra,24(sp)
 690:	e822                	sd	s0,16(sp)
 692:	1000                	addi	s0,sp,32
 694:	e40c                	sd	a1,8(s0)
 696:	e810                	sd	a2,16(s0)
 698:	ec14                	sd	a3,24(s0)
 69a:	f018                	sd	a4,32(s0)
 69c:	f41c                	sd	a5,40(s0)
 69e:	03043823          	sd	a6,48(s0)
 6a2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6a6:	00840613          	addi	a2,s0,8
 6aa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ae:	85aa                	mv	a1,a0
 6b0:	4505                	li	a0,1
 6b2:	00000097          	auipc	ra,0x0
 6b6:	dde080e7          	jalr	-546(ra) # 490 <vprintf>
}
 6ba:	60e2                	ld	ra,24(sp)
 6bc:	6442                	ld	s0,16(sp)
 6be:	6125                	addi	sp,sp,96
 6c0:	8082                	ret

00000000000006c2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c2:	1141                	addi	sp,sp,-16
 6c4:	e406                	sd	ra,8(sp)
 6c6:	e022                	sd	s0,0(sp)
 6c8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ca:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ce:	00000797          	auipc	a5,0x0
 6d2:	5ea7b783          	ld	a5,1514(a5) # cb8 <freep>
 6d6:	a039                	j	6e4 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d8:	6398                	ld	a4,0(a5)
 6da:	00e7e463          	bltu	a5,a4,6e2 <free+0x20>
 6de:	00e6ea63          	bltu	a3,a4,6f2 <free+0x30>
{
 6e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e4:	fed7fae3          	bgeu	a5,a3,6d8 <free+0x16>
 6e8:	6398                	ld	a4,0(a5)
 6ea:	00e6e463          	bltu	a3,a4,6f2 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ee:	fee7eae3          	bltu	a5,a4,6e2 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f2:	ff852583          	lw	a1,-8(a0)
 6f6:	6390                	ld	a2,0(a5)
 6f8:	02059813          	slli	a6,a1,0x20
 6fc:	01c85713          	srli	a4,a6,0x1c
 700:	9736                	add	a4,a4,a3
 702:	02e60563          	beq	a2,a4,72c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 706:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 70a:	4790                	lw	a2,8(a5)
 70c:	02061593          	slli	a1,a2,0x20
 710:	01c5d713          	srli	a4,a1,0x1c
 714:	973e                	add	a4,a4,a5
 716:	02e68263          	beq	a3,a4,73a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 71a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 71c:	00000717          	auipc	a4,0x0
 720:	58f73e23          	sd	a5,1436(a4) # cb8 <freep>
}
 724:	60a2                	ld	ra,8(sp)
 726:	6402                	ld	s0,0(sp)
 728:	0141                	addi	sp,sp,16
 72a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 72c:	4618                	lw	a4,8(a2)
 72e:	9f2d                	addw	a4,a4,a1
 730:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 734:	6398                	ld	a4,0(a5)
 736:	6310                	ld	a2,0(a4)
 738:	b7f9                	j	706 <free+0x44>
    p->s.size += bp->s.size;
 73a:	ff852703          	lw	a4,-8(a0)
 73e:	9f31                	addw	a4,a4,a2
 740:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 742:	ff053683          	ld	a3,-16(a0)
 746:	bfd1                	j	71a <free+0x58>

0000000000000748 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 748:	7139                	addi	sp,sp,-64
 74a:	fc06                	sd	ra,56(sp)
 74c:	f822                	sd	s0,48(sp)
 74e:	f04a                	sd	s2,32(sp)
 750:	ec4e                	sd	s3,24(sp)
 752:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 754:	02051993          	slli	s3,a0,0x20
 758:	0209d993          	srli	s3,s3,0x20
 75c:	09bd                	addi	s3,s3,15
 75e:	0049d993          	srli	s3,s3,0x4
 762:	2985                	addiw	s3,s3,1
 764:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 766:	00000517          	auipc	a0,0x0
 76a:	55253503          	ld	a0,1362(a0) # cb8 <freep>
 76e:	c905                	beqz	a0,79e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 770:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 772:	4798                	lw	a4,8(a5)
 774:	09377a63          	bgeu	a4,s3,808 <malloc+0xc0>
 778:	f426                	sd	s1,40(sp)
 77a:	e852                	sd	s4,16(sp)
 77c:	e456                	sd	s5,8(sp)
 77e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 780:	8a4e                	mv	s4,s3
 782:	6705                	lui	a4,0x1
 784:	00e9f363          	bgeu	s3,a4,78a <malloc+0x42>
 788:	6a05                	lui	s4,0x1
 78a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 78e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 792:	00000497          	auipc	s1,0x0
 796:	52648493          	addi	s1,s1,1318 # cb8 <freep>
  if(p == (char*)-1)
 79a:	5afd                	li	s5,-1
 79c:	a089                	j	7de <malloc+0x96>
 79e:	f426                	sd	s1,40(sp)
 7a0:	e852                	sd	s4,16(sp)
 7a2:	e456                	sd	s5,8(sp)
 7a4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7a6:	00000797          	auipc	a5,0x0
 7aa:	51a78793          	addi	a5,a5,1306 # cc0 <base>
 7ae:	00000717          	auipc	a4,0x0
 7b2:	50f73523          	sd	a5,1290(a4) # cb8 <freep>
 7b6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7b8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7bc:	b7d1                	j	780 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 7be:	6398                	ld	a4,0(a5)
 7c0:	e118                	sd	a4,0(a0)
 7c2:	a8b9                	j	820 <malloc+0xd8>
  hp->s.size = nu;
 7c4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7c8:	0541                	addi	a0,a0,16
 7ca:	00000097          	auipc	ra,0x0
 7ce:	ef8080e7          	jalr	-264(ra) # 6c2 <free>
  return freep;
 7d2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7d4:	c135                	beqz	a0,838 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d8:	4798                	lw	a4,8(a5)
 7da:	03277363          	bgeu	a4,s2,800 <malloc+0xb8>
    if(p == freep)
 7de:	6098                	ld	a4,0(s1)
 7e0:	853e                	mv	a0,a5
 7e2:	fef71ae3          	bne	a4,a5,7d6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 7e6:	8552                	mv	a0,s4
 7e8:	00000097          	auipc	ra,0x0
 7ec:	bbe080e7          	jalr	-1090(ra) # 3a6 <sbrk>
  if(p == (char*)-1)
 7f0:	fd551ae3          	bne	a0,s5,7c4 <malloc+0x7c>
        return 0;
 7f4:	4501                	li	a0,0
 7f6:	74a2                	ld	s1,40(sp)
 7f8:	6a42                	ld	s4,16(sp)
 7fa:	6aa2                	ld	s5,8(sp)
 7fc:	6b02                	ld	s6,0(sp)
 7fe:	a03d                	j	82c <malloc+0xe4>
 800:	74a2                	ld	s1,40(sp)
 802:	6a42                	ld	s4,16(sp)
 804:	6aa2                	ld	s5,8(sp)
 806:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 808:	fae90be3          	beq	s2,a4,7be <malloc+0x76>
        p->s.size -= nunits;
 80c:	4137073b          	subw	a4,a4,s3
 810:	c798                	sw	a4,8(a5)
        p += p->s.size;
 812:	02071693          	slli	a3,a4,0x20
 816:	01c6d713          	srli	a4,a3,0x1c
 81a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 81c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 820:	00000717          	auipc	a4,0x0
 824:	48a73c23          	sd	a0,1176(a4) # cb8 <freep>
      return (void*)(p + 1);
 828:	01078513          	addi	a0,a5,16
  }
}
 82c:	70e2                	ld	ra,56(sp)
 82e:	7442                	ld	s0,48(sp)
 830:	7902                	ld	s2,32(sp)
 832:	69e2                	ld	s3,24(sp)
 834:	6121                	addi	sp,sp,64
 836:	8082                	ret
 838:	74a2                	ld	s1,40(sp)
 83a:	6a42                	ld	s4,16(sp)
 83c:	6aa2                	ld	s5,8(sp)
 83e:	6b02                	ld	s6,0(sp)
 840:	b7f5                	j	82c <malloc+0xe4>
