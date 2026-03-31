
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fcntl.h"

#define NFORK 10
#define IO 5

int main() {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  int n, pid;
  int wtime, rtime;
  int twtime=0, trtime=0;
  for(n=0; n < NFORK;n++) {
  12:	4481                	li	s1,0
  14:	4929                	li	s2,10
      pid = fork();
  16:	00000097          	auipc	ra,0x0
  1a:	372080e7          	jalr	882(ra) # 388 <fork>
      if (pid < 0)
  1e:	00054d63          	bltz	a0,38 <main+0x38>
          break;
      if (pid == 0) {
  22:	cd31                	beqz	a0,7e <main+0x7e>
  for(n=0; n < NFORK;n++) {
  24:	2485                	addiw	s1,s1,1
  26:	ff2498e3          	bne	s1,s2,16 <main+0x16>
  2a:	4901                	li	s2,0
  2c:	4981                	li	s3,0
        set_priority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes 
#endif
      }
  }
  for(;n > 0; n--) {
      if(waitx(0,&wtime,&rtime) >= 0) {
  2e:	fb840a93          	addi	s5,s0,-72
  32:	fbc40a13          	addi	s4,s0,-68
  36:	a065                	j	de <main+0xde>
  for(;n > 0; n--) {
  38:	fe9049e3          	bgtz	s1,2a <main+0x2a>
  3c:	4901                	li	s2,0
  3e:	4981                	li	s3,0
          trtime += rtime;
          twtime += wtime;
      } 
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  40:	666665b7          	lui	a1,0x66666
  44:	66758593          	addi	a1,a1,1639 # 66666667 <__global_pointer$+0x6666511b>
  48:	02b98633          	mul	a2,s3,a1
  4c:	9609                	srai	a2,a2,0x22
  4e:	41f9d99b          	sraiw	s3,s3,0x1f
  52:	02b905b3          	mul	a1,s2,a1
  56:	9589                	srai	a1,a1,0x22
  58:	41f9591b          	sraiw	s2,s2,0x1f
  5c:	4136063b          	subw	a2,a2,s3
  60:	412585bb          	subw	a1,a1,s2
  64:	00001517          	auipc	a0,0x1
  68:	86c50513          	addi	a0,a0,-1940 # 8d0 <malloc+0x116>
  6c:	00000097          	auipc	ra,0x0
  70:	692080e7          	jalr	1682(ra) # 6fe <printf>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	31a080e7          	jalr	794(ra) # 390 <exit>
          if (n < IO) {
  7e:	4791                	li	a5,4
  80:	0497d663          	bge	a5,s1,cc <main+0xcc>
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process 
  84:	fa042a23          	sw	zero,-76(s0)
  88:	fb442703          	lw	a4,-76(s0)
  8c:	2701                	sext.w	a4,a4
  8e:	3b9ad7b7          	lui	a5,0x3b9ad
  92:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab4b3>
  96:	00e7cd63          	blt	a5,a4,b0 <main+0xb0>
  9a:	873e                	mv	a4,a5
  9c:	fb442783          	lw	a5,-76(s0)
  a0:	2785                	addiw	a5,a5,1
  a2:	faf42a23          	sw	a5,-76(s0)
  a6:	fb442783          	lw	a5,-76(s0)
  aa:	2781                	sext.w	a5,a5
  ac:	fef758e3          	bge	a4,a5,9c <main+0x9c>
          printf("Process %d finished", n);
  b0:	85a6                	mv	a1,s1
  b2:	00001517          	auipc	a0,0x1
  b6:	80650513          	addi	a0,a0,-2042 # 8b8 <malloc+0xfe>
  ba:	00000097          	auipc	ra,0x0
  be:	644080e7          	jalr	1604(ra) # 6fe <printf>
          exit(0);
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	2cc080e7          	jalr	716(ra) # 390 <exit>
            sleep(200); // IO bound processes
  cc:	0c800513          	li	a0,200
  d0:	00000097          	auipc	ra,0x0
  d4:	350080e7          	jalr	848(ra) # 420 <sleep>
  d8:	bfe1                	j	b0 <main+0xb0>
  for(;n > 0; n--) {
  da:	34fd                	addiw	s1,s1,-1
  dc:	d0b5                	beqz	s1,40 <main+0x40>
      if(waitx(0,&wtime,&rtime) >= 0) {
  de:	8656                	mv	a2,s5
  e0:	85d2                	mv	a1,s4
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	34c080e7          	jalr	844(ra) # 430 <waitx>
  ec:	fe0547e3          	bltz	a0,da <main+0xda>
          trtime += rtime;
  f0:	fb842783          	lw	a5,-72(s0)
  f4:	0127893b          	addw	s2,a5,s2
          twtime += wtime;
  f8:	fbc42783          	lw	a5,-68(s0)
  fc:	013789bb          	addw	s3,a5,s3
 100:	bfe9                	j	da <main+0xda>

0000000000000102 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10a:	87aa                	mv	a5,a0
 10c:	0585                	addi	a1,a1,1
 10e:	0785                	addi	a5,a5,1
 110:	fff5c703          	lbu	a4,-1(a1)
 114:	fee78fa3          	sb	a4,-1(a5)
 118:	fb75                	bnez	a4,10c <strcpy+0xa>
    ;
  return os;
}
 11a:	60a2                	ld	ra,8(sp)
 11c:	6402                	ld	s0,0(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret

0000000000000122 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 122:	1141                	addi	sp,sp,-16
 124:	e406                	sd	ra,8(sp)
 126:	e022                	sd	s0,0(sp)
 128:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	cb91                	beqz	a5,142 <strcmp+0x20>
 130:	0005c703          	lbu	a4,0(a1)
 134:	00f71763          	bne	a4,a5,142 <strcmp+0x20>
    p++, q++;
 138:	0505                	addi	a0,a0,1
 13a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13c:	00054783          	lbu	a5,0(a0)
 140:	fbe5                	bnez	a5,130 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 142:	0005c503          	lbu	a0,0(a1)
}
 146:	40a7853b          	subw	a0,a5,a0
 14a:	60a2                	ld	ra,8(sp)
 14c:	6402                	ld	s0,0(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strlen>:

uint
strlen(const char *s)
{
 152:	1141                	addi	sp,sp,-16
 154:	e406                	sd	ra,8(sp)
 156:	e022                	sd	s0,0(sp)
 158:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cf91                	beqz	a5,17a <strlen+0x28>
 160:	00150793          	addi	a5,a0,1
 164:	86be                	mv	a3,a5
 166:	0785                	addi	a5,a5,1
 168:	fff7c703          	lbu	a4,-1(a5)
 16c:	ff65                	bnez	a4,164 <strlen+0x12>
 16e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 172:	60a2                	ld	ra,8(sp)
 174:	6402                	ld	s0,0(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret
  for(n = 0; s[n]; n++)
 17a:	4501                	li	a0,0
 17c:	bfdd                	j	172 <strlen+0x20>

000000000000017e <memset>:

void*
memset(void *dst, int c, uint n)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 186:	ca19                	beqz	a2,19c <memset+0x1e>
 188:	87aa                	mv	a5,a0
 18a:	1602                	slli	a2,a2,0x20
 18c:	9201                	srli	a2,a2,0x20
 18e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 192:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 196:	0785                	addi	a5,a5,1
 198:	fee79de3          	bne	a5,a4,192 <memset+0x14>
  }
  return dst;
}
 19c:	60a2                	ld	ra,8(sp)
 19e:	6402                	ld	s0,0(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strchr>:

char*
strchr(const char *s, char c)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e406                	sd	ra,8(sp)
 1a8:	e022                	sd	s0,0(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cf81                	beqz	a5,1c8 <strchr+0x24>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1c>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xe>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	60a2                	ld	ra,8(sp)
 1c2:	6402                	ld	s0,0(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret
  return 0;
 1c8:	4501                	li	a0,0
 1ca:	bfdd                	j	1c0 <strchr+0x1c>

00000000000001cc <gets>:

char*
gets(char *buf, int max)
{
 1cc:	711d                	addi	sp,sp,-96
 1ce:	ec86                	sd	ra,88(sp)
 1d0:	e8a2                	sd	s0,80(sp)
 1d2:	e4a6                	sd	s1,72(sp)
 1d4:	e0ca                	sd	s2,64(sp)
 1d6:	fc4e                	sd	s3,56(sp)
 1d8:	f852                	sd	s4,48(sp)
 1da:	f456                	sd	s5,40(sp)
 1dc:	f05a                	sd	s6,32(sp)
 1de:	ec5e                	sd	s7,24(sp)
 1e0:	e862                	sd	s8,16(sp)
 1e2:	1080                	addi	s0,sp,96
 1e4:	8baa                	mv	s7,a0
 1e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e8:	892a                	mv	s2,a0
 1ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1ec:	faf40b13          	addi	s6,s0,-81
 1f0:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1f2:	8c26                	mv	s8,s1
 1f4:	0014899b          	addiw	s3,s1,1
 1f8:	84ce                	mv	s1,s3
 1fa:	0349d663          	bge	s3,s4,226 <gets+0x5a>
    cc = read(0, &c, 1);
 1fe:	8656                	mv	a2,s5
 200:	85da                	mv	a1,s6
 202:	4501                	li	a0,0
 204:	00000097          	auipc	ra,0x0
 208:	1a4080e7          	jalr	420(ra) # 3a8 <read>
    if(cc < 1)
 20c:	00a05d63          	blez	a0,226 <gets+0x5a>
      break;
    buf[i++] = c;
 210:	faf44783          	lbu	a5,-81(s0)
 214:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 218:	0905                	addi	s2,s2,1
 21a:	ff678713          	addi	a4,a5,-10
 21e:	c319                	beqz	a4,224 <gets+0x58>
 220:	17cd                	addi	a5,a5,-13
 222:	fbe1                	bnez	a5,1f2 <gets+0x26>
    buf[i++] = c;
 224:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 226:	9c5e                	add	s8,s8,s7
 228:	000c0023          	sb	zero,0(s8)
  return buf;
}
 22c:	855e                	mv	a0,s7
 22e:	60e6                	ld	ra,88(sp)
 230:	6446                	ld	s0,80(sp)
 232:	64a6                	ld	s1,72(sp)
 234:	6906                	ld	s2,64(sp)
 236:	79e2                	ld	s3,56(sp)
 238:	7a42                	ld	s4,48(sp)
 23a:	7aa2                	ld	s5,40(sp)
 23c:	7b02                	ld	s6,32(sp)
 23e:	6be2                	ld	s7,24(sp)
 240:	6c42                	ld	s8,16(sp)
 242:	6125                	addi	sp,sp,96
 244:	8082                	ret

0000000000000246 <stat>:

int
stat(const char *n, struct stat *st)
{
 246:	1101                	addi	sp,sp,-32
 248:	ec06                	sd	ra,24(sp)
 24a:	e822                	sd	s0,16(sp)
 24c:	e04a                	sd	s2,0(sp)
 24e:	1000                	addi	s0,sp,32
 250:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 252:	4581                	li	a1,0
 254:	00000097          	auipc	ra,0x0
 258:	17c080e7          	jalr	380(ra) # 3d0 <open>
  if(fd < 0)
 25c:	02054663          	bltz	a0,288 <stat+0x42>
 260:	e426                	sd	s1,8(sp)
 262:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 264:	85ca                	mv	a1,s2
 266:	00000097          	auipc	ra,0x0
 26a:	182080e7          	jalr	386(ra) # 3e8 <fstat>
 26e:	892a                	mv	s2,a0
  close(fd);
 270:	8526                	mv	a0,s1
 272:	00000097          	auipc	ra,0x0
 276:	146080e7          	jalr	326(ra) # 3b8 <close>
  return r;
 27a:	64a2                	ld	s1,8(sp)
}
 27c:	854a                	mv	a0,s2
 27e:	60e2                	ld	ra,24(sp)
 280:	6442                	ld	s0,16(sp)
 282:	6902                	ld	s2,0(sp)
 284:	6105                	addi	sp,sp,32
 286:	8082                	ret
    return -1;
 288:	57fd                	li	a5,-1
 28a:	893e                	mv	s2,a5
 28c:	bfc5                	j	27c <stat+0x36>

000000000000028e <atoi>:

int
atoi(const char *s)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 296:	00054683          	lbu	a3,0(a0)
 29a:	fd06879b          	addiw	a5,a3,-48
 29e:	0ff7f793          	zext.b	a5,a5
 2a2:	4625                	li	a2,9
 2a4:	02f66963          	bltu	a2,a5,2d6 <atoi+0x48>
 2a8:	872a                	mv	a4,a0
  n = 0;
 2aa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ac:	0705                	addi	a4,a4,1
 2ae:	0025179b          	slliw	a5,a0,0x2
 2b2:	9fa9                	addw	a5,a5,a0
 2b4:	0017979b          	slliw	a5,a5,0x1
 2b8:	9fb5                	addw	a5,a5,a3
 2ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2be:	00074683          	lbu	a3,0(a4)
 2c2:	fd06879b          	addiw	a5,a3,-48
 2c6:	0ff7f793          	zext.b	a5,a5
 2ca:	fef671e3          	bgeu	a2,a5,2ac <atoi+0x1e>
  return n;
}
 2ce:	60a2                	ld	ra,8(sp)
 2d0:	6402                	ld	s0,0(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret
  n = 0;
 2d6:	4501                	li	a0,0
 2d8:	bfdd                	j	2ce <atoi+0x40>

00000000000002da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e2:	02b57563          	bgeu	a0,a1,30c <memmove+0x32>
    while(n-- > 0)
 2e6:	00c05f63          	blez	a2,304 <memmove+0x2a>
 2ea:	1602                	slli	a2,a2,0x20
 2ec:	9201                	srli	a2,a2,0x20
 2ee:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f4:	0585                	addi	a1,a1,1
 2f6:	0705                	addi	a4,a4,1
 2f8:	fff5c683          	lbu	a3,-1(a1)
 2fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 300:	fee79ae3          	bne	a5,a4,2f4 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
    while(n-- > 0)
 30c:	fec05ce3          	blez	a2,304 <memmove+0x2a>
    dst += n;
 310:	00c50733          	add	a4,a0,a2
    src += n;
 314:	95b2                	add	a1,a1,a2
 316:	fff6079b          	addiw	a5,a2,-1
 31a:	1782                	slli	a5,a5,0x20
 31c:	9381                	srli	a5,a5,0x20
 31e:	fff7c793          	not	a5,a5
 322:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 324:	15fd                	addi	a1,a1,-1
 326:	177d                	addi	a4,a4,-1
 328:	0005c683          	lbu	a3,0(a1)
 32c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 330:	fef71ae3          	bne	a4,a5,324 <memmove+0x4a>
 334:	bfc1                	j	304 <memmove+0x2a>

0000000000000336 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e406                	sd	ra,8(sp)
 33a:	e022                	sd	s0,0(sp)
 33c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	c61d                	beqz	a2,36c <memcmp+0x36>
 340:	1602                	slli	a2,a2,0x20
 342:	9201                	srli	a2,a2,0x20
 344:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 348:	00054783          	lbu	a5,0(a0)
 34c:	0005c703          	lbu	a4,0(a1)
 350:	00e79863          	bne	a5,a4,360 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 354:	0505                	addi	a0,a0,1
    p2++;
 356:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 358:	fed518e3          	bne	a0,a3,348 <memcmp+0x12>
  }
  return 0;
 35c:	4501                	li	a0,0
 35e:	a019                	j	364 <memcmp+0x2e>
      return *p1 - *p2;
 360:	40e7853b          	subw	a0,a5,a4
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  return 0;
 36c:	4501                	li	a0,0
 36e:	bfdd                	j	364 <memcmp+0x2e>

0000000000000370 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 378:	00000097          	auipc	ra,0x0
 37c:	f62080e7          	jalr	-158(ra) # 2da <memmove>
}
 380:	60a2                	ld	ra,8(sp)
 382:	6402                	ld	s0,0(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 388:	4885                	li	a7,1
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exit>:
.global exit
exit:
 li a7, SYS_exit
 390:	4889                	li	a7,2
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <wait>:
.global wait
wait:
 li a7, SYS_wait
 398:	488d                	li	a7,3
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a0:	4891                	li	a7,4
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <read>:
.global read
read:
 li a7, SYS_read
 3a8:	4895                	li	a7,5
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <write>:
.global write
write:
 li a7, SYS_write
 3b0:	48c1                	li	a7,16
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <close>:
.global close
close:
 li a7, SYS_close
 3b8:	48d5                	li	a7,21
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c0:	4899                	li	a7,6
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c8:	489d                	li	a7,7
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <open>:
.global open
open:
 li a7, SYS_open
 3d0:	48bd                	li	a7,15
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d8:	48c5                	li	a7,17
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e0:	48c9                	li	a7,18
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e8:	48a1                	li	a7,8
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <link>:
.global link
link:
 li a7, SYS_link
 3f0:	48cd                	li	a7,19
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f8:	48d1                	li	a7,20
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 400:	48a5                	li	a7,9
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <dup>:
.global dup
dup:
 li a7, SYS_dup
 408:	48a9                	li	a7,10
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 410:	48ad                	li	a7,11
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 418:	48b1                	li	a7,12
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 420:	48b5                	li	a7,13
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 428:	48b9                	li	a7,14
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 430:	48d9                	li	a7,22
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 438:	1101                	addi	sp,sp,-32
 43a:	ec06                	sd	ra,24(sp)
 43c:	e822                	sd	s0,16(sp)
 43e:	1000                	addi	s0,sp,32
 440:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 444:	4605                	li	a2,1
 446:	fef40593          	addi	a1,s0,-17
 44a:	00000097          	auipc	ra,0x0
 44e:	f66080e7          	jalr	-154(ra) # 3b0 <write>
}
 452:	60e2                	ld	ra,24(sp)
 454:	6442                	ld	s0,16(sp)
 456:	6105                	addi	sp,sp,32
 458:	8082                	ret

000000000000045a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45a:	7139                	addi	sp,sp,-64
 45c:	fc06                	sd	ra,56(sp)
 45e:	f822                	sd	s0,48(sp)
 460:	f04a                	sd	s2,32(sp)
 462:	ec4e                	sd	s3,24(sp)
 464:	0080                	addi	s0,sp,64
 466:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 468:	cad9                	beqz	a3,4fe <printint+0xa4>
 46a:	01f5d79b          	srliw	a5,a1,0x1f
 46e:	cbc1                	beqz	a5,4fe <printint+0xa4>
    neg = 1;
    x = -xx;
 470:	40b005bb          	negw	a1,a1
    neg = 1;
 474:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 476:	fc040993          	addi	s3,s0,-64
  neg = 0;
 47a:	86ce                	mv	a3,s3
  i = 0;
 47c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47e:	00000817          	auipc	a6,0x0
 482:	4d280813          	addi	a6,a6,1234 # 950 <digits>
 486:	88ba                	mv	a7,a4
 488:	0017051b          	addiw	a0,a4,1
 48c:	872a                	mv	a4,a0
 48e:	02c5f7bb          	remuw	a5,a1,a2
 492:	1782                	slli	a5,a5,0x20
 494:	9381                	srli	a5,a5,0x20
 496:	97c2                	add	a5,a5,a6
 498:	0007c783          	lbu	a5,0(a5)
 49c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a0:	87ae                	mv	a5,a1
 4a2:	02c5d5bb          	divuw	a1,a1,a2
 4a6:	0685                	addi	a3,a3,1
 4a8:	fcc7ffe3          	bgeu	a5,a2,486 <printint+0x2c>
  if(neg)
 4ac:	00030c63          	beqz	t1,4c4 <printint+0x6a>
    buf[i++] = '-';
 4b0:	fd050793          	addi	a5,a0,-48
 4b4:	00878533          	add	a0,a5,s0
 4b8:	02d00793          	li	a5,45
 4bc:	fef50823          	sb	a5,-16(a0)
 4c0:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4c4:	02e05763          	blez	a4,4f2 <printint+0x98>
 4c8:	f426                	sd	s1,40(sp)
 4ca:	377d                	addiw	a4,a4,-1
 4cc:	00e984b3          	add	s1,s3,a4
 4d0:	19fd                	addi	s3,s3,-1
 4d2:	99ba                	add	s3,s3,a4
 4d4:	1702                	slli	a4,a4,0x20
 4d6:	9301                	srli	a4,a4,0x20
 4d8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4dc:	0004c583          	lbu	a1,0(s1)
 4e0:	854a                	mv	a0,s2
 4e2:	00000097          	auipc	ra,0x0
 4e6:	f56080e7          	jalr	-170(ra) # 438 <putc>
  while(--i >= 0)
 4ea:	14fd                	addi	s1,s1,-1
 4ec:	ff3498e3          	bne	s1,s3,4dc <printint+0x82>
 4f0:	74a2                	ld	s1,40(sp)
}
 4f2:	70e2                	ld	ra,56(sp)
 4f4:	7442                	ld	s0,48(sp)
 4f6:	7902                	ld	s2,32(sp)
 4f8:	69e2                	ld	s3,24(sp)
 4fa:	6121                	addi	sp,sp,64
 4fc:	8082                	ret
  neg = 0;
 4fe:	4301                	li	t1,0
 500:	bf9d                	j	476 <printint+0x1c>

0000000000000502 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 502:	715d                	addi	sp,sp,-80
 504:	e486                	sd	ra,72(sp)
 506:	e0a2                	sd	s0,64(sp)
 508:	f84a                	sd	s2,48(sp)
 50a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50c:	0005c903          	lbu	s2,0(a1)
 510:	1a090b63          	beqz	s2,6c6 <vprintf+0x1c4>
 514:	fc26                	sd	s1,56(sp)
 516:	f44e                	sd	s3,40(sp)
 518:	f052                	sd	s4,32(sp)
 51a:	ec56                	sd	s5,24(sp)
 51c:	e85a                	sd	s6,16(sp)
 51e:	e45e                	sd	s7,8(sp)
 520:	8aaa                	mv	s5,a0
 522:	8bb2                	mv	s7,a2
 524:	00158493          	addi	s1,a1,1
  state = 0;
 528:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 52a:	02500a13          	li	s4,37
 52e:	4b55                	li	s6,21
 530:	a839                	j	54e <vprintf+0x4c>
        putc(fd, c);
 532:	85ca                	mv	a1,s2
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	f02080e7          	jalr	-254(ra) # 438 <putc>
 53e:	a019                	j	544 <vprintf+0x42>
    } else if(state == '%'){
 540:	01498d63          	beq	s3,s4,55a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 544:	0485                	addi	s1,s1,1
 546:	fff4c903          	lbu	s2,-1(s1)
 54a:	16090863          	beqz	s2,6ba <vprintf+0x1b8>
    if(state == 0){
 54e:	fe0999e3          	bnez	s3,540 <vprintf+0x3e>
      if(c == '%'){
 552:	ff4910e3          	bne	s2,s4,532 <vprintf+0x30>
        state = '%';
 556:	89d2                	mv	s3,s4
 558:	b7f5                	j	544 <vprintf+0x42>
      if(c == 'd'){
 55a:	13490563          	beq	s2,s4,684 <vprintf+0x182>
 55e:	f9d9079b          	addiw	a5,s2,-99
 562:	0ff7f793          	zext.b	a5,a5
 566:	12fb6863          	bltu	s6,a5,696 <vprintf+0x194>
 56a:	f9d9079b          	addiw	a5,s2,-99
 56e:	0ff7f713          	zext.b	a4,a5
 572:	12eb6263          	bltu	s6,a4,696 <vprintf+0x194>
 576:	00271793          	slli	a5,a4,0x2
 57a:	00000717          	auipc	a4,0x0
 57e:	37e70713          	addi	a4,a4,894 # 8f8 <malloc+0x13e>
 582:	97ba                	add	a5,a5,a4
 584:	439c                	lw	a5,0(a5)
 586:	97ba                	add	a5,a5,a4
 588:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 58a:	008b8913          	addi	s2,s7,8
 58e:	4685                	li	a3,1
 590:	4629                	li	a2,10
 592:	000ba583          	lw	a1,0(s7)
 596:	8556                	mv	a0,s5
 598:	00000097          	auipc	ra,0x0
 59c:	ec2080e7          	jalr	-318(ra) # 45a <printint>
 5a0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	b745                	j	544 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a6:	008b8913          	addi	s2,s7,8
 5aa:	4681                	li	a3,0
 5ac:	4629                	li	a2,10
 5ae:	000ba583          	lw	a1,0(s7)
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	ea6080e7          	jalr	-346(ra) # 45a <printint>
 5bc:	8bca                	mv	s7,s2
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b751                	j	544 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4681                	li	a3,0
 5c8:	4641                	li	a2,16
 5ca:	000ba583          	lw	a1,0(s7)
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e8a080e7          	jalr	-374(ra) # 45a <printint>
 5d8:	8bca                	mv	s7,s2
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b7a5                	j	544 <vprintf+0x42>
 5de:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5e0:	008b8793          	addi	a5,s7,8
 5e4:	8c3e                	mv	s8,a5
 5e6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ea:	03000593          	li	a1,48
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e48080e7          	jalr	-440(ra) # 438 <putc>
  putc(fd, 'x');
 5f8:	07800593          	li	a1,120
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	e3a080e7          	jalr	-454(ra) # 438 <putc>
 606:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 608:	00000b97          	auipc	s7,0x0
 60c:	348b8b93          	addi	s7,s7,840 # 950 <digits>
 610:	03c9d793          	srli	a5,s3,0x3c
 614:	97de                	add	a5,a5,s7
 616:	0007c583          	lbu	a1,0(a5)
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e1c080e7          	jalr	-484(ra) # 438 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 624:	0992                	slli	s3,s3,0x4
 626:	397d                	addiw	s2,s2,-1
 628:	fe0914e3          	bnez	s2,610 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 62c:	8be2                	mv	s7,s8
      state = 0;
 62e:	4981                	li	s3,0
 630:	6c02                	ld	s8,0(sp)
 632:	bf09                	j	544 <vprintf+0x42>
        s = va_arg(ap, char*);
 634:	008b8993          	addi	s3,s7,8
 638:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 63c:	02090163          	beqz	s2,65e <vprintf+0x15c>
        while(*s != 0){
 640:	00094583          	lbu	a1,0(s2)
 644:	c9a5                	beqz	a1,6b4 <vprintf+0x1b2>
          putc(fd, *s);
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	df0080e7          	jalr	-528(ra) # 438 <putc>
          s++;
 650:	0905                	addi	s2,s2,1
        while(*s != 0){
 652:	00094583          	lbu	a1,0(s2)
 656:	f9e5                	bnez	a1,646 <vprintf+0x144>
        s = va_arg(ap, char*);
 658:	8bce                	mv	s7,s3
      state = 0;
 65a:	4981                	li	s3,0
 65c:	b5e5                	j	544 <vprintf+0x42>
          s = "(null)";
 65e:	00000917          	auipc	s2,0x0
 662:	29290913          	addi	s2,s2,658 # 8f0 <malloc+0x136>
        while(*s != 0){
 666:	02800593          	li	a1,40
 66a:	bff1                	j	646 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 66c:	008b8913          	addi	s2,s7,8
 670:	000bc583          	lbu	a1,0(s7)
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	dc2080e7          	jalr	-574(ra) # 438 <putc>
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	b5c9                	j	544 <vprintf+0x42>
        putc(fd, c);
 684:	02500593          	li	a1,37
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	dae080e7          	jalr	-594(ra) # 438 <putc>
      state = 0;
 692:	4981                	li	s3,0
 694:	bd45                	j	544 <vprintf+0x42>
        putc(fd, '%');
 696:	02500593          	li	a1,37
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	d9c080e7          	jalr	-612(ra) # 438 <putc>
        putc(fd, c);
 6a4:	85ca                	mv	a1,s2
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	d90080e7          	jalr	-624(ra) # 438 <putc>
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bd49                	j	544 <vprintf+0x42>
        s = va_arg(ap, char*);
 6b4:	8bce                	mv	s7,s3
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b571                	j	544 <vprintf+0x42>
 6ba:	74e2                	ld	s1,56(sp)
 6bc:	79a2                	ld	s3,40(sp)
 6be:	7a02                	ld	s4,32(sp)
 6c0:	6ae2                	ld	s5,24(sp)
 6c2:	6b42                	ld	s6,16(sp)
 6c4:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6c6:	60a6                	ld	ra,72(sp)
 6c8:	6406                	ld	s0,64(sp)
 6ca:	7942                	ld	s2,48(sp)
 6cc:	6161                	addi	sp,sp,80
 6ce:	8082                	ret

00000000000006d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d0:	715d                	addi	sp,sp,-80
 6d2:	ec06                	sd	ra,24(sp)
 6d4:	e822                	sd	s0,16(sp)
 6d6:	1000                	addi	s0,sp,32
 6d8:	e010                	sd	a2,0(s0)
 6da:	e414                	sd	a3,8(s0)
 6dc:	e818                	sd	a4,16(s0)
 6de:	ec1c                	sd	a5,24(s0)
 6e0:	03043023          	sd	a6,32(s0)
 6e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e8:	8622                	mv	a2,s0
 6ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ee:	00000097          	auipc	ra,0x0
 6f2:	e14080e7          	jalr	-492(ra) # 502 <vprintf>
}
 6f6:	60e2                	ld	ra,24(sp)
 6f8:	6442                	ld	s0,16(sp)
 6fa:	6161                	addi	sp,sp,80
 6fc:	8082                	ret

00000000000006fe <printf>:

void
printf(const char *fmt, ...)
{
 6fe:	711d                	addi	sp,sp,-96
 700:	ec06                	sd	ra,24(sp)
 702:	e822                	sd	s0,16(sp)
 704:	1000                	addi	s0,sp,32
 706:	e40c                	sd	a1,8(s0)
 708:	e810                	sd	a2,16(s0)
 70a:	ec14                	sd	a3,24(s0)
 70c:	f018                	sd	a4,32(s0)
 70e:	f41c                	sd	a5,40(s0)
 710:	03043823          	sd	a6,48(s0)
 714:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 718:	00840613          	addi	a2,s0,8
 71c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 720:	85aa                	mv	a1,a0
 722:	4505                	li	a0,1
 724:	00000097          	auipc	ra,0x0
 728:	dde080e7          	jalr	-546(ra) # 502 <vprintf>
}
 72c:	60e2                	ld	ra,24(sp)
 72e:	6442                	ld	s0,16(sp)
 730:	6125                	addi	sp,sp,96
 732:	8082                	ret

0000000000000734 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 734:	1141                	addi	sp,sp,-16
 736:	e406                	sd	ra,8(sp)
 738:	e022                	sd	s0,0(sp)
 73a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 740:	00000797          	auipc	a5,0x0
 744:	6107b783          	ld	a5,1552(a5) # d50 <freep>
 748:	a039                	j	756 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74a:	6398                	ld	a4,0(a5)
 74c:	00e7e463          	bltu	a5,a4,754 <free+0x20>
 750:	00e6ea63          	bltu	a3,a4,764 <free+0x30>
{
 754:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 756:	fed7fae3          	bgeu	a5,a3,74a <free+0x16>
 75a:	6398                	ld	a4,0(a5)
 75c:	00e6e463          	bltu	a3,a4,764 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 760:	fee7eae3          	bltu	a5,a4,754 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 764:	ff852583          	lw	a1,-8(a0)
 768:	6390                	ld	a2,0(a5)
 76a:	02059813          	slli	a6,a1,0x20
 76e:	01c85713          	srli	a4,a6,0x1c
 772:	9736                	add	a4,a4,a3
 774:	02e60563          	beq	a2,a4,79e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 778:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 77c:	4790                	lw	a2,8(a5)
 77e:	02061593          	slli	a1,a2,0x20
 782:	01c5d713          	srli	a4,a1,0x1c
 786:	973e                	add	a4,a4,a5
 788:	02e68263          	beq	a3,a4,7ac <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 78c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 78e:	00000717          	auipc	a4,0x0
 792:	5cf73123          	sd	a5,1474(a4) # d50 <freep>
}
 796:	60a2                	ld	ra,8(sp)
 798:	6402                	ld	s0,0(sp)
 79a:	0141                	addi	sp,sp,16
 79c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 79e:	4618                	lw	a4,8(a2)
 7a0:	9f2d                	addw	a4,a4,a1
 7a2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a6:	6398                	ld	a4,0(a5)
 7a8:	6310                	ld	a2,0(a4)
 7aa:	b7f9                	j	778 <free+0x44>
    p->s.size += bp->s.size;
 7ac:	ff852703          	lw	a4,-8(a0)
 7b0:	9f31                	addw	a4,a4,a2
 7b2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b4:	ff053683          	ld	a3,-16(a0)
 7b8:	bfd1                	j	78c <free+0x58>

00000000000007ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ba:	7139                	addi	sp,sp,-64
 7bc:	fc06                	sd	ra,56(sp)
 7be:	f822                	sd	s0,48(sp)
 7c0:	f04a                	sd	s2,32(sp)
 7c2:	ec4e                	sd	s3,24(sp)
 7c4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c6:	02051993          	slli	s3,a0,0x20
 7ca:	0209d993          	srli	s3,s3,0x20
 7ce:	09bd                	addi	s3,s3,15
 7d0:	0049d993          	srli	s3,s3,0x4
 7d4:	2985                	addiw	s3,s3,1
 7d6:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7d8:	00000517          	auipc	a0,0x0
 7dc:	57853503          	ld	a0,1400(a0) # d50 <freep>
 7e0:	c905                	beqz	a0,810 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e4:	4798                	lw	a4,8(a5)
 7e6:	09377a63          	bgeu	a4,s3,87a <malloc+0xc0>
 7ea:	f426                	sd	s1,40(sp)
 7ec:	e852                	sd	s4,16(sp)
 7ee:	e456                	sd	s5,8(sp)
 7f0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7f2:	8a4e                	mv	s4,s3
 7f4:	6705                	lui	a4,0x1
 7f6:	00e9f363          	bgeu	s3,a4,7fc <malloc+0x42>
 7fa:	6a05                	lui	s4,0x1
 7fc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 800:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 804:	00000497          	auipc	s1,0x0
 808:	54c48493          	addi	s1,s1,1356 # d50 <freep>
  if(p == (char*)-1)
 80c:	5afd                	li	s5,-1
 80e:	a089                	j	850 <malloc+0x96>
 810:	f426                	sd	s1,40(sp)
 812:	e852                	sd	s4,16(sp)
 814:	e456                	sd	s5,8(sp)
 816:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 818:	00000797          	auipc	a5,0x0
 81c:	54078793          	addi	a5,a5,1344 # d58 <base>
 820:	00000717          	auipc	a4,0x0
 824:	52f73823          	sd	a5,1328(a4) # d50 <freep>
 828:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 82a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 82e:	b7d1                	j	7f2 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 830:	6398                	ld	a4,0(a5)
 832:	e118                	sd	a4,0(a0)
 834:	a8b9                	j	892 <malloc+0xd8>
  hp->s.size = nu;
 836:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 83a:	0541                	addi	a0,a0,16
 83c:	00000097          	auipc	ra,0x0
 840:	ef8080e7          	jalr	-264(ra) # 734 <free>
  return freep;
 844:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 846:	c135                	beqz	a0,8aa <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84a:	4798                	lw	a4,8(a5)
 84c:	03277363          	bgeu	a4,s2,872 <malloc+0xb8>
    if(p == freep)
 850:	6098                	ld	a4,0(s1)
 852:	853e                	mv	a0,a5
 854:	fef71ae3          	bne	a4,a5,848 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 858:	8552                	mv	a0,s4
 85a:	00000097          	auipc	ra,0x0
 85e:	bbe080e7          	jalr	-1090(ra) # 418 <sbrk>
  if(p == (char*)-1)
 862:	fd551ae3          	bne	a0,s5,836 <malloc+0x7c>
        return 0;
 866:	4501                	li	a0,0
 868:	74a2                	ld	s1,40(sp)
 86a:	6a42                	ld	s4,16(sp)
 86c:	6aa2                	ld	s5,8(sp)
 86e:	6b02                	ld	s6,0(sp)
 870:	a03d                	j	89e <malloc+0xe4>
 872:	74a2                	ld	s1,40(sp)
 874:	6a42                	ld	s4,16(sp)
 876:	6aa2                	ld	s5,8(sp)
 878:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 87a:	fae90be3          	beq	s2,a4,830 <malloc+0x76>
        p->s.size -= nunits;
 87e:	4137073b          	subw	a4,a4,s3
 882:	c798                	sw	a4,8(a5)
        p += p->s.size;
 884:	02071693          	slli	a3,a4,0x20
 888:	01c6d713          	srli	a4,a3,0x1c
 88c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 88e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 892:	00000717          	auipc	a4,0x0
 896:	4aa73f23          	sd	a0,1214(a4) # d50 <freep>
      return (void*)(p + 1);
 89a:	01078513          	addi	a0,a5,16
  }
}
 89e:	70e2                	ld	ra,56(sp)
 8a0:	7442                	ld	s0,48(sp)
 8a2:	7902                	ld	s2,32(sp)
 8a4:	69e2                	ld	s3,24(sp)
 8a6:	6121                	addi	sp,sp,64
 8a8:	8082                	ret
 8aa:	74a2                	ld	s1,40(sp)
 8ac:	6a42                	ld	s4,16(sp)
 8ae:	6aa2                	ld	s5,8(sp)
 8b0:	6b02                	ld	s6,0(sp)
 8b2:	b7f5                	j	89e <malloc+0xe4>
