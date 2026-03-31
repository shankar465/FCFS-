
user/_setpriority:     file format elf64-littleriscv


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
   8:	1800                	addi	s0,sp,48
   a:	84ae                	mv	s1,a1
    int old_sp, new_sp, pid;

    if (argc != 3) {
   c:	478d                	li	a5,3
   e:	02f50463          	beq	a0,a5,36 <main+0x36>
  12:	e84a                	sd	s2,16(sp)
  14:	e44e                	sd	s3,8(sp)
  16:	e052                	sd	s4,0(sp)
        fprintf(2, "%s: execution failed - insufficient number of arguments\n", argv[0]);
  18:	6190                	ld	a2,0(a1)
  1a:	00001597          	auipc	a1,0x1
  1e:	87658593          	addi	a1,a1,-1930 # 890 <malloc+0xfa>
  22:	4509                	li	a0,2
  24:	00000097          	auipc	ra,0x0
  28:	688080e7          	jalr	1672(ra) # 6ac <fprintf>
        exit(1);
  2c:	4505                	li	a0,1
  2e:	00000097          	auipc	ra,0x0
  32:	32e080e7          	jalr	814(ra) # 35c <exit>
  36:	e84a                	sd	s2,16(sp)
  38:	e44e                	sd	s3,8(sp)
  3a:	e052                	sd	s4,0(sp)
    }

    new_sp = atoi(argv[1]);
  3c:	6588                	ld	a0,8(a1)
  3e:	00000097          	auipc	ra,0x0
  42:	21c080e7          	jalr	540(ra) # 25a <atoi>
  46:	892a                	mv	s2,a0
  48:	89aa                	mv	s3,a0
    pid = atoi(argv[2]);
  4a:	6888                	ld	a0,16(s1)
  4c:	00000097          	auipc	ra,0x0
  50:	20e080e7          	jalr	526(ra) # 25a <atoi>
  54:	8a2a                	mv	s4,a0

    if (new_sp < 0 || new_sp > 100) {
  56:	06400793          	li	a5,100
  5a:	0327f163          	bgeu	a5,s2,7c <main+0x7c>
        fprintf(2, "%s: execution failed - static priority should be in the range 0-100\n", argv[0]);
  5e:	6090                	ld	a2,0(s1)
  60:	00001597          	auipc	a1,0x1
  64:	87058593          	addi	a1,a1,-1936 # 8d0 <malloc+0x13a>
  68:	4509                	li	a0,2
  6a:	00000097          	auipc	ra,0x0
  6e:	642080e7          	jalr	1602(ra) # 6ac <fprintf>
        exit(1);
  72:	4505                	li	a0,1
  74:	00000097          	auipc	ra,0x0
  78:	2e8080e7          	jalr	744(ra) # 35c <exit>
    }

    old_sp = set_priority(new_sp, pid);
  7c:	85aa                	mv	a1,a0
  7e:	854a                	mv	a0,s2
  80:	00000097          	auipc	ra,0x0
  84:	38c080e7          	jalr	908(ra) # 40c <set_priority>
  88:	86aa                	mv	a3,a0
    if (old_sp < 0) {
  8a:	02054263          	bltz	a0,ae <main+0xae>
        fprintf(2, "%s: execution failed - no process with process ID %d exists\n", argv[0], pid);
        exit(1);
    }

    printf("%s: priority of process with ID %d successfully updated from %d to %d\n", argv[0], pid, old_sp, new_sp);
  8e:	874e                	mv	a4,s3
  90:	8652                	mv	a2,s4
  92:	608c                	ld	a1,0(s1)
  94:	00001517          	auipc	a0,0x1
  98:	8c450513          	addi	a0,a0,-1852 # 958 <malloc+0x1c2>
  9c:	00000097          	auipc	ra,0x0
  a0:	63e080e7          	jalr	1598(ra) # 6da <printf>
    exit(0);
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	2b6080e7          	jalr	694(ra) # 35c <exit>
        fprintf(2, "%s: execution failed - no process with process ID %d exists\n", argv[0], pid);
  ae:	86d2                	mv	a3,s4
  b0:	6090                	ld	a2,0(s1)
  b2:	00001597          	auipc	a1,0x1
  b6:	86658593          	addi	a1,a1,-1946 # 918 <malloc+0x182>
  ba:	4509                	li	a0,2
  bc:	00000097          	auipc	ra,0x0
  c0:	5f0080e7          	jalr	1520(ra) # 6ac <fprintf>
        exit(1);
  c4:	4505                	li	a0,1
  c6:	00000097          	auipc	ra,0x0
  ca:	296080e7          	jalr	662(ra) # 35c <exit>

00000000000000ce <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e406                	sd	ra,8(sp)
  d2:	e022                	sd	s0,0(sp)
  d4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d6:	87aa                	mv	a5,a0
  d8:	0585                	addi	a1,a1,1
  da:	0785                	addi	a5,a5,1
  dc:	fff5c703          	lbu	a4,-1(a1)
  e0:	fee78fa3          	sb	a4,-1(a5)
  e4:	fb75                	bnez	a4,d8 <strcpy+0xa>
    ;
  return os;
}
  e6:	60a2                	ld	ra,8(sp)
  e8:	6402                	ld	s0,0(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e406                	sd	ra,8(sp)
  f2:	e022                	sd	s0,0(sp)
  f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x20>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x20>
    p++, q++;
 104:	0505                	addi	a0,a0,1
 106:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	60a2                	ld	ra,8(sp)
 118:	6402                	ld	s0,0(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strlen>:

uint
strlen(const char *s)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cf91                	beqz	a5,146 <strlen+0x28>
 12c:	00150793          	addi	a5,a0,1
 130:	86be                	mv	a3,a5
 132:	0785                	addi	a5,a5,1
 134:	fff7c703          	lbu	a4,-1(a5)
 138:	ff65                	bnez	a4,130 <strlen+0x12>
 13a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 13e:	60a2                	ld	ra,8(sp)
 140:	6402                	ld	s0,0(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret
  for(n = 0; s[n]; n++)
 146:	4501                	li	a0,0
 148:	bfdd                	j	13e <strlen+0x20>

000000000000014a <memset>:

void*
memset(void *dst, int c, uint n)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e406                	sd	ra,8(sp)
 14e:	e022                	sd	s0,0(sp)
 150:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 152:	ca19                	beqz	a2,168 <memset+0x1e>
 154:	87aa                	mv	a5,a0
 156:	1602                	slli	a2,a2,0x20
 158:	9201                	srli	a2,a2,0x20
 15a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 162:	0785                	addi	a5,a5,1
 164:	fee79de3          	bne	a5,a4,15e <memset+0x14>
  }
  return dst;
}
 168:	60a2                	ld	ra,8(sp)
 16a:	6402                	ld	s0,0(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret

0000000000000170 <strchr>:

char*
strchr(const char *s, char c)
{
 170:	1141                	addi	sp,sp,-16
 172:	e406                	sd	ra,8(sp)
 174:	e022                	sd	s0,0(sp)
 176:	0800                	addi	s0,sp,16
  for(; *s; s++)
 178:	00054783          	lbu	a5,0(a0)
 17c:	cf81                	beqz	a5,194 <strchr+0x24>
    if(*s == c)
 17e:	00f58763          	beq	a1,a5,18c <strchr+0x1c>
  for(; *s; s++)
 182:	0505                	addi	a0,a0,1
 184:	00054783          	lbu	a5,0(a0)
 188:	fbfd                	bnez	a5,17e <strchr+0xe>
      return (char*)s;
  return 0;
 18a:	4501                	li	a0,0
}
 18c:	60a2                	ld	ra,8(sp)
 18e:	6402                	ld	s0,0(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret
  return 0;
 194:	4501                	li	a0,0
 196:	bfdd                	j	18c <strchr+0x1c>

0000000000000198 <gets>:

char*
gets(char *buf, int max)
{
 198:	711d                	addi	sp,sp,-96
 19a:	ec86                	sd	ra,88(sp)
 19c:	e8a2                	sd	s0,80(sp)
 19e:	e4a6                	sd	s1,72(sp)
 1a0:	e0ca                	sd	s2,64(sp)
 1a2:	fc4e                	sd	s3,56(sp)
 1a4:	f852                	sd	s4,48(sp)
 1a6:	f456                	sd	s5,40(sp)
 1a8:	f05a                	sd	s6,32(sp)
 1aa:	ec5e                	sd	s7,24(sp)
 1ac:	e862                	sd	s8,16(sp)
 1ae:	1080                	addi	s0,sp,96
 1b0:	8baa                	mv	s7,a0
 1b2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b4:	892a                	mv	s2,a0
 1b6:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1b8:	faf40b13          	addi	s6,s0,-81
 1bc:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1be:	8c26                	mv	s8,s1
 1c0:	0014899b          	addiw	s3,s1,1
 1c4:	84ce                	mv	s1,s3
 1c6:	0349d663          	bge	s3,s4,1f2 <gets+0x5a>
    cc = read(0, &c, 1);
 1ca:	8656                	mv	a2,s5
 1cc:	85da                	mv	a1,s6
 1ce:	4501                	li	a0,0
 1d0:	00000097          	auipc	ra,0x0
 1d4:	1a4080e7          	jalr	420(ra) # 374 <read>
    if(cc < 1)
 1d8:	00a05d63          	blez	a0,1f2 <gets+0x5a>
      break;
    buf[i++] = c;
 1dc:	faf44783          	lbu	a5,-81(s0)
 1e0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e4:	0905                	addi	s2,s2,1
 1e6:	ff678713          	addi	a4,a5,-10
 1ea:	c319                	beqz	a4,1f0 <gets+0x58>
 1ec:	17cd                	addi	a5,a5,-13
 1ee:	fbe1                	bnez	a5,1be <gets+0x26>
    buf[i++] = c;
 1f0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1f2:	9c5e                	add	s8,s8,s7
 1f4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1f8:	855e                	mv	a0,s7
 1fa:	60e6                	ld	ra,88(sp)
 1fc:	6446                	ld	s0,80(sp)
 1fe:	64a6                	ld	s1,72(sp)
 200:	6906                	ld	s2,64(sp)
 202:	79e2                	ld	s3,56(sp)
 204:	7a42                	ld	s4,48(sp)
 206:	7aa2                	ld	s5,40(sp)
 208:	7b02                	ld	s6,32(sp)
 20a:	6be2                	ld	s7,24(sp)
 20c:	6c42                	ld	s8,16(sp)
 20e:	6125                	addi	sp,sp,96
 210:	8082                	ret

0000000000000212 <stat>:

int
stat(const char *n, struct stat *st)
{
 212:	1101                	addi	sp,sp,-32
 214:	ec06                	sd	ra,24(sp)
 216:	e822                	sd	s0,16(sp)
 218:	e04a                	sd	s2,0(sp)
 21a:	1000                	addi	s0,sp,32
 21c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21e:	4581                	li	a1,0
 220:	00000097          	auipc	ra,0x0
 224:	17c080e7          	jalr	380(ra) # 39c <open>
  if(fd < 0)
 228:	02054663          	bltz	a0,254 <stat+0x42>
 22c:	e426                	sd	s1,8(sp)
 22e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 230:	85ca                	mv	a1,s2
 232:	00000097          	auipc	ra,0x0
 236:	182080e7          	jalr	386(ra) # 3b4 <fstat>
 23a:	892a                	mv	s2,a0
  close(fd);
 23c:	8526                	mv	a0,s1
 23e:	00000097          	auipc	ra,0x0
 242:	146080e7          	jalr	326(ra) # 384 <close>
  return r;
 246:	64a2                	ld	s1,8(sp)
}
 248:	854a                	mv	a0,s2
 24a:	60e2                	ld	ra,24(sp)
 24c:	6442                	ld	s0,16(sp)
 24e:	6902                	ld	s2,0(sp)
 250:	6105                	addi	sp,sp,32
 252:	8082                	ret
    return -1;
 254:	57fd                	li	a5,-1
 256:	893e                	mv	s2,a5
 258:	bfc5                	j	248 <stat+0x36>

000000000000025a <atoi>:

int
atoi(const char *s)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e406                	sd	ra,8(sp)
 25e:	e022                	sd	s0,0(sp)
 260:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 262:	00054683          	lbu	a3,0(a0)
 266:	fd06879b          	addiw	a5,a3,-48
 26a:	0ff7f793          	zext.b	a5,a5
 26e:	4625                	li	a2,9
 270:	02f66963          	bltu	a2,a5,2a2 <atoi+0x48>
 274:	872a                	mv	a4,a0
  n = 0;
 276:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 278:	0705                	addi	a4,a4,1
 27a:	0025179b          	slliw	a5,a0,0x2
 27e:	9fa9                	addw	a5,a5,a0
 280:	0017979b          	slliw	a5,a5,0x1
 284:	9fb5                	addw	a5,a5,a3
 286:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 28a:	00074683          	lbu	a3,0(a4)
 28e:	fd06879b          	addiw	a5,a3,-48
 292:	0ff7f793          	zext.b	a5,a5
 296:	fef671e3          	bgeu	a2,a5,278 <atoi+0x1e>
  return n;
}
 29a:	60a2                	ld	ra,8(sp)
 29c:	6402                	ld	s0,0(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  n = 0;
 2a2:	4501                	li	a0,0
 2a4:	bfdd                	j	29a <atoi+0x40>

00000000000002a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e406                	sd	ra,8(sp)
 2aa:	e022                	sd	s0,0(sp)
 2ac:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ae:	02b57563          	bgeu	a0,a1,2d8 <memmove+0x32>
    while(n-- > 0)
 2b2:	00c05f63          	blez	a2,2d0 <memmove+0x2a>
 2b6:	1602                	slli	a2,a2,0x20
 2b8:	9201                	srli	a2,a2,0x20
 2ba:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2be:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c0:	0585                	addi	a1,a1,1
 2c2:	0705                	addi	a4,a4,1
 2c4:	fff5c683          	lbu	a3,-1(a1)
 2c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2cc:	fee79ae3          	bne	a5,a4,2c0 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d0:	60a2                	ld	ra,8(sp)
 2d2:	6402                	ld	s0,0(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
    while(n-- > 0)
 2d8:	fec05ce3          	blez	a2,2d0 <memmove+0x2a>
    dst += n;
 2dc:	00c50733          	add	a4,a0,a2
    src += n;
 2e0:	95b2                	add	a1,a1,a2
 2e2:	fff6079b          	addiw	a5,a2,-1
 2e6:	1782                	slli	a5,a5,0x20
 2e8:	9381                	srli	a5,a5,0x20
 2ea:	fff7c793          	not	a5,a5
 2ee:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f0:	15fd                	addi	a1,a1,-1
 2f2:	177d                	addi	a4,a4,-1
 2f4:	0005c683          	lbu	a3,0(a1)
 2f8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fc:	fef71ae3          	bne	a4,a5,2f0 <memmove+0x4a>
 300:	bfc1                	j	2d0 <memmove+0x2a>

0000000000000302 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e406                	sd	ra,8(sp)
 306:	e022                	sd	s0,0(sp)
 308:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30a:	c61d                	beqz	a2,338 <memcmp+0x36>
 30c:	1602                	slli	a2,a2,0x20
 30e:	9201                	srli	a2,a2,0x20
 310:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 314:	00054783          	lbu	a5,0(a0)
 318:	0005c703          	lbu	a4,0(a1)
 31c:	00e79863          	bne	a5,a4,32c <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 320:	0505                	addi	a0,a0,1
    p2++;
 322:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 324:	fed518e3          	bne	a0,a3,314 <memcmp+0x12>
  }
  return 0;
 328:	4501                	li	a0,0
 32a:	a019                	j	330 <memcmp+0x2e>
      return *p1 - *p2;
 32c:	40e7853b          	subw	a0,a5,a4
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
  return 0;
 338:	4501                	li	a0,0
 33a:	bfdd                	j	330 <memcmp+0x2e>

000000000000033c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33c:	1141                	addi	sp,sp,-16
 33e:	e406                	sd	ra,8(sp)
 340:	e022                	sd	s0,0(sp)
 342:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 344:	00000097          	auipc	ra,0x0
 348:	f62080e7          	jalr	-158(ra) # 2a6 <memmove>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 354:	4885                	li	a7,1
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <exit>:
.global exit
exit:
 li a7, SYS_exit
 35c:	4889                	li	a7,2
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <wait>:
.global wait
wait:
 li a7, SYS_wait
 364:	488d                	li	a7,3
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36c:	4891                	li	a7,4
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <read>:
.global read
read:
 li a7, SYS_read
 374:	4895                	li	a7,5
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <write>:
.global write
write:
 li a7, SYS_write
 37c:	48c1                	li	a7,16
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <close>:
.global close
close:
 li a7, SYS_close
 384:	48d5                	li	a7,21
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <kill>:
.global kill
kill:
 li a7, SYS_kill
 38c:	4899                	li	a7,6
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <exec>:
.global exec
exec:
 li a7, SYS_exec
 394:	489d                	li	a7,7
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <open>:
.global open
open:
 li a7, SYS_open
 39c:	48bd                	li	a7,15
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a4:	48c5                	li	a7,17
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ac:	48c9                	li	a7,18
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b4:	48a1                	li	a7,8
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <link>:
.global link
link:
 li a7, SYS_link
 3bc:	48cd                	li	a7,19
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c4:	48d1                	li	a7,20
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3cc:	48a5                	li	a7,9
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d4:	48a9                	li	a7,10
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3dc:	48ad                	li	a7,11
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3e4:	48b1                	li	a7,12
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ec:	48b5                	li	a7,13
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f4:	48b9                	li	a7,14
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3fc:	48d9                	li	a7,22
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <trace>:
.global trace
trace:
 li a7, SYS_trace
 404:	48dd                	li	a7,23
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 40c:	48e1                	li	a7,24
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 414:	1101                	addi	sp,sp,-32
 416:	ec06                	sd	ra,24(sp)
 418:	e822                	sd	s0,16(sp)
 41a:	1000                	addi	s0,sp,32
 41c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 420:	4605                	li	a2,1
 422:	fef40593          	addi	a1,s0,-17
 426:	00000097          	auipc	ra,0x0
 42a:	f56080e7          	jalr	-170(ra) # 37c <write>
}
 42e:	60e2                	ld	ra,24(sp)
 430:	6442                	ld	s0,16(sp)
 432:	6105                	addi	sp,sp,32
 434:	8082                	ret

0000000000000436 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 436:	7139                	addi	sp,sp,-64
 438:	fc06                	sd	ra,56(sp)
 43a:	f822                	sd	s0,48(sp)
 43c:	f04a                	sd	s2,32(sp)
 43e:	ec4e                	sd	s3,24(sp)
 440:	0080                	addi	s0,sp,64
 442:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 444:	cad9                	beqz	a3,4da <printint+0xa4>
 446:	01f5d79b          	srliw	a5,a1,0x1f
 44a:	cbc1                	beqz	a5,4da <printint+0xa4>
    neg = 1;
    x = -xx;
 44c:	40b005bb          	negw	a1,a1
    neg = 1;
 450:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 452:	fc040993          	addi	s3,s0,-64
  neg = 0;
 456:	86ce                	mv	a3,s3
  i = 0;
 458:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 45a:	00000817          	auipc	a6,0x0
 45e:	5a680813          	addi	a6,a6,1446 # a00 <digits>
 462:	88ba                	mv	a7,a4
 464:	0017051b          	addiw	a0,a4,1
 468:	872a                	mv	a4,a0
 46a:	02c5f7bb          	remuw	a5,a1,a2
 46e:	1782                	slli	a5,a5,0x20
 470:	9381                	srli	a5,a5,0x20
 472:	97c2                	add	a5,a5,a6
 474:	0007c783          	lbu	a5,0(a5)
 478:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 47c:	87ae                	mv	a5,a1
 47e:	02c5d5bb          	divuw	a1,a1,a2
 482:	0685                	addi	a3,a3,1
 484:	fcc7ffe3          	bgeu	a5,a2,462 <printint+0x2c>
  if(neg)
 488:	00030c63          	beqz	t1,4a0 <printint+0x6a>
    buf[i++] = '-';
 48c:	fd050793          	addi	a5,a0,-48
 490:	00878533          	add	a0,a5,s0
 494:	02d00793          	li	a5,45
 498:	fef50823          	sb	a5,-16(a0)
 49c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4a0:	02e05763          	blez	a4,4ce <printint+0x98>
 4a4:	f426                	sd	s1,40(sp)
 4a6:	377d                	addiw	a4,a4,-1
 4a8:	00e984b3          	add	s1,s3,a4
 4ac:	19fd                	addi	s3,s3,-1
 4ae:	99ba                	add	s3,s3,a4
 4b0:	1702                	slli	a4,a4,0x20
 4b2:	9301                	srli	a4,a4,0x20
 4b4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b8:	0004c583          	lbu	a1,0(s1)
 4bc:	854a                	mv	a0,s2
 4be:	00000097          	auipc	ra,0x0
 4c2:	f56080e7          	jalr	-170(ra) # 414 <putc>
  while(--i >= 0)
 4c6:	14fd                	addi	s1,s1,-1
 4c8:	ff3498e3          	bne	s1,s3,4b8 <printint+0x82>
 4cc:	74a2                	ld	s1,40(sp)
}
 4ce:	70e2                	ld	ra,56(sp)
 4d0:	7442                	ld	s0,48(sp)
 4d2:	7902                	ld	s2,32(sp)
 4d4:	69e2                	ld	s3,24(sp)
 4d6:	6121                	addi	sp,sp,64
 4d8:	8082                	ret
  neg = 0;
 4da:	4301                	li	t1,0
 4dc:	bf9d                	j	452 <printint+0x1c>

00000000000004de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4de:	715d                	addi	sp,sp,-80
 4e0:	e486                	sd	ra,72(sp)
 4e2:	e0a2                	sd	s0,64(sp)
 4e4:	f84a                	sd	s2,48(sp)
 4e6:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e8:	0005c903          	lbu	s2,0(a1)
 4ec:	1a090b63          	beqz	s2,6a2 <vprintf+0x1c4>
 4f0:	fc26                	sd	s1,56(sp)
 4f2:	f44e                	sd	s3,40(sp)
 4f4:	f052                	sd	s4,32(sp)
 4f6:	ec56                	sd	s5,24(sp)
 4f8:	e85a                	sd	s6,16(sp)
 4fa:	e45e                	sd	s7,8(sp)
 4fc:	8aaa                	mv	s5,a0
 4fe:	8bb2                	mv	s7,a2
 500:	00158493          	addi	s1,a1,1
  state = 0;
 504:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 506:	02500a13          	li	s4,37
 50a:	4b55                	li	s6,21
 50c:	a839                	j	52a <vprintf+0x4c>
        putc(fd, c);
 50e:	85ca                	mv	a1,s2
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	f02080e7          	jalr	-254(ra) # 414 <putc>
 51a:	a019                	j	520 <vprintf+0x42>
    } else if(state == '%'){
 51c:	01498d63          	beq	s3,s4,536 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 520:	0485                	addi	s1,s1,1
 522:	fff4c903          	lbu	s2,-1(s1)
 526:	16090863          	beqz	s2,696 <vprintf+0x1b8>
    if(state == 0){
 52a:	fe0999e3          	bnez	s3,51c <vprintf+0x3e>
      if(c == '%'){
 52e:	ff4910e3          	bne	s2,s4,50e <vprintf+0x30>
        state = '%';
 532:	89d2                	mv	s3,s4
 534:	b7f5                	j	520 <vprintf+0x42>
      if(c == 'd'){
 536:	13490563          	beq	s2,s4,660 <vprintf+0x182>
 53a:	f9d9079b          	addiw	a5,s2,-99
 53e:	0ff7f793          	zext.b	a5,a5
 542:	12fb6863          	bltu	s6,a5,672 <vprintf+0x194>
 546:	f9d9079b          	addiw	a5,s2,-99
 54a:	0ff7f713          	zext.b	a4,a5
 54e:	12eb6263          	bltu	s6,a4,672 <vprintf+0x194>
 552:	00271793          	slli	a5,a4,0x2
 556:	00000717          	auipc	a4,0x0
 55a:	45270713          	addi	a4,a4,1106 # 9a8 <malloc+0x212>
 55e:	97ba                	add	a5,a5,a4
 560:	439c                	lw	a5,0(a5)
 562:	97ba                	add	a5,a5,a4
 564:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 566:	008b8913          	addi	s2,s7,8
 56a:	4685                	li	a3,1
 56c:	4629                	li	a2,10
 56e:	000ba583          	lw	a1,0(s7)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	ec2080e7          	jalr	-318(ra) # 436 <printint>
 57c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 57e:	4981                	li	s3,0
 580:	b745                	j	520 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 582:	008b8913          	addi	s2,s7,8
 586:	4681                	li	a3,0
 588:	4629                	li	a2,10
 58a:	000ba583          	lw	a1,0(s7)
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	ea6080e7          	jalr	-346(ra) # 436 <printint>
 598:	8bca                	mv	s7,s2
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b751                	j	520 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 59e:	008b8913          	addi	s2,s7,8
 5a2:	4681                	li	a3,0
 5a4:	4641                	li	a2,16
 5a6:	000ba583          	lw	a1,0(s7)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	e8a080e7          	jalr	-374(ra) # 436 <printint>
 5b4:	8bca                	mv	s7,s2
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b7a5                	j	520 <vprintf+0x42>
 5ba:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5bc:	008b8793          	addi	a5,s7,8
 5c0:	8c3e                	mv	s8,a5
 5c2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5c6:	03000593          	li	a1,48
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	e48080e7          	jalr	-440(ra) # 414 <putc>
  putc(fd, 'x');
 5d4:	07800593          	li	a1,120
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	e3a080e7          	jalr	-454(ra) # 414 <putc>
 5e2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e4:	00000b97          	auipc	s7,0x0
 5e8:	41cb8b93          	addi	s7,s7,1052 # a00 <digits>
 5ec:	03c9d793          	srli	a5,s3,0x3c
 5f0:	97de                	add	a5,a5,s7
 5f2:	0007c583          	lbu	a1,0(a5)
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e1c080e7          	jalr	-484(ra) # 414 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 600:	0992                	slli	s3,s3,0x4
 602:	397d                	addiw	s2,s2,-1
 604:	fe0914e3          	bnez	s2,5ec <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 608:	8be2                	mv	s7,s8
      state = 0;
 60a:	4981                	li	s3,0
 60c:	6c02                	ld	s8,0(sp)
 60e:	bf09                	j	520 <vprintf+0x42>
        s = va_arg(ap, char*);
 610:	008b8993          	addi	s3,s7,8
 614:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 618:	02090163          	beqz	s2,63a <vprintf+0x15c>
        while(*s != 0){
 61c:	00094583          	lbu	a1,0(s2)
 620:	c9a5                	beqz	a1,690 <vprintf+0x1b2>
          putc(fd, *s);
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	df0080e7          	jalr	-528(ra) # 414 <putc>
          s++;
 62c:	0905                	addi	s2,s2,1
        while(*s != 0){
 62e:	00094583          	lbu	a1,0(s2)
 632:	f9e5                	bnez	a1,622 <vprintf+0x144>
        s = va_arg(ap, char*);
 634:	8bce                	mv	s7,s3
      state = 0;
 636:	4981                	li	s3,0
 638:	b5e5                	j	520 <vprintf+0x42>
          s = "(null)";
 63a:	00000917          	auipc	s2,0x0
 63e:	36690913          	addi	s2,s2,870 # 9a0 <malloc+0x20a>
        while(*s != 0){
 642:	02800593          	li	a1,40
 646:	bff1                	j	622 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 648:	008b8913          	addi	s2,s7,8
 64c:	000bc583          	lbu	a1,0(s7)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	dc2080e7          	jalr	-574(ra) # 414 <putc>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b5c9                	j	520 <vprintf+0x42>
        putc(fd, c);
 660:	02500593          	li	a1,37
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	dae080e7          	jalr	-594(ra) # 414 <putc>
      state = 0;
 66e:	4981                	li	s3,0
 670:	bd45                	j	520 <vprintf+0x42>
        putc(fd, '%');
 672:	02500593          	li	a1,37
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	d9c080e7          	jalr	-612(ra) # 414 <putc>
        putc(fd, c);
 680:	85ca                	mv	a1,s2
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	d90080e7          	jalr	-624(ra) # 414 <putc>
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bd49                	j	520 <vprintf+0x42>
        s = va_arg(ap, char*);
 690:	8bce                	mv	s7,s3
      state = 0;
 692:	4981                	li	s3,0
 694:	b571                	j	520 <vprintf+0x42>
 696:	74e2                	ld	s1,56(sp)
 698:	79a2                	ld	s3,40(sp)
 69a:	7a02                	ld	s4,32(sp)
 69c:	6ae2                	ld	s5,24(sp)
 69e:	6b42                	ld	s6,16(sp)
 6a0:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6a2:	60a6                	ld	ra,72(sp)
 6a4:	6406                	ld	s0,64(sp)
 6a6:	7942                	ld	s2,48(sp)
 6a8:	6161                	addi	sp,sp,80
 6aa:	8082                	ret

00000000000006ac <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ac:	715d                	addi	sp,sp,-80
 6ae:	ec06                	sd	ra,24(sp)
 6b0:	e822                	sd	s0,16(sp)
 6b2:	1000                	addi	s0,sp,32
 6b4:	e010                	sd	a2,0(s0)
 6b6:	e414                	sd	a3,8(s0)
 6b8:	e818                	sd	a4,16(s0)
 6ba:	ec1c                	sd	a5,24(s0)
 6bc:	03043023          	sd	a6,32(s0)
 6c0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	8622                	mv	a2,s0
 6c6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e14080e7          	jalr	-492(ra) # 4de <vprintf>
}
 6d2:	60e2                	ld	ra,24(sp)
 6d4:	6442                	ld	s0,16(sp)
 6d6:	6161                	addi	sp,sp,80
 6d8:	8082                	ret

00000000000006da <printf>:

void
printf(const char *fmt, ...)
{
 6da:	711d                	addi	sp,sp,-96
 6dc:	ec06                	sd	ra,24(sp)
 6de:	e822                	sd	s0,16(sp)
 6e0:	1000                	addi	s0,sp,32
 6e2:	e40c                	sd	a1,8(s0)
 6e4:	e810                	sd	a2,16(s0)
 6e6:	ec14                	sd	a3,24(s0)
 6e8:	f018                	sd	a4,32(s0)
 6ea:	f41c                	sd	a5,40(s0)
 6ec:	03043823          	sd	a6,48(s0)
 6f0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f4:	00840613          	addi	a2,s0,8
 6f8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6fc:	85aa                	mv	a1,a0
 6fe:	4505                	li	a0,1
 700:	00000097          	auipc	ra,0x0
 704:	dde080e7          	jalr	-546(ra) # 4de <vprintf>
}
 708:	60e2                	ld	ra,24(sp)
 70a:	6442                	ld	s0,16(sp)
 70c:	6125                	addi	sp,sp,96
 70e:	8082                	ret

0000000000000710 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 710:	1141                	addi	sp,sp,-16
 712:	e406                	sd	ra,8(sp)
 714:	e022                	sd	s0,0(sp)
 716:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 718:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71c:	00000797          	auipc	a5,0x0
 720:	6ec7b783          	ld	a5,1772(a5) # e08 <freep>
 724:	a039                	j	732 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 726:	6398                	ld	a4,0(a5)
 728:	00e7e463          	bltu	a5,a4,730 <free+0x20>
 72c:	00e6ea63          	bltu	a3,a4,740 <free+0x30>
{
 730:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 732:	fed7fae3          	bgeu	a5,a3,726 <free+0x16>
 736:	6398                	ld	a4,0(a5)
 738:	00e6e463          	bltu	a3,a4,740 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73c:	fee7eae3          	bltu	a5,a4,730 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 740:	ff852583          	lw	a1,-8(a0)
 744:	6390                	ld	a2,0(a5)
 746:	02059813          	slli	a6,a1,0x20
 74a:	01c85713          	srli	a4,a6,0x1c
 74e:	9736                	add	a4,a4,a3
 750:	02e60563          	beq	a2,a4,77a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 754:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 758:	4790                	lw	a2,8(a5)
 75a:	02061593          	slli	a1,a2,0x20
 75e:	01c5d713          	srli	a4,a1,0x1c
 762:	973e                	add	a4,a4,a5
 764:	02e68263          	beq	a3,a4,788 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 768:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 76a:	00000717          	auipc	a4,0x0
 76e:	68f73f23          	sd	a5,1694(a4) # e08 <freep>
}
 772:	60a2                	ld	ra,8(sp)
 774:	6402                	ld	s0,0(sp)
 776:	0141                	addi	sp,sp,16
 778:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 77a:	4618                	lw	a4,8(a2)
 77c:	9f2d                	addw	a4,a4,a1
 77e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 782:	6398                	ld	a4,0(a5)
 784:	6310                	ld	a2,0(a4)
 786:	b7f9                	j	754 <free+0x44>
    p->s.size += bp->s.size;
 788:	ff852703          	lw	a4,-8(a0)
 78c:	9f31                	addw	a4,a4,a2
 78e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 790:	ff053683          	ld	a3,-16(a0)
 794:	bfd1                	j	768 <free+0x58>

0000000000000796 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 796:	7139                	addi	sp,sp,-64
 798:	fc06                	sd	ra,56(sp)
 79a:	f822                	sd	s0,48(sp)
 79c:	f04a                	sd	s2,32(sp)
 79e:	ec4e                	sd	s3,24(sp)
 7a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a2:	02051993          	slli	s3,a0,0x20
 7a6:	0209d993          	srli	s3,s3,0x20
 7aa:	09bd                	addi	s3,s3,15
 7ac:	0049d993          	srli	s3,s3,0x4
 7b0:	2985                	addiw	s3,s3,1
 7b2:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7b4:	00000517          	auipc	a0,0x0
 7b8:	65453503          	ld	a0,1620(a0) # e08 <freep>
 7bc:	c905                	beqz	a0,7ec <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c0:	4798                	lw	a4,8(a5)
 7c2:	09377a63          	bgeu	a4,s3,856 <malloc+0xc0>
 7c6:	f426                	sd	s1,40(sp)
 7c8:	e852                	sd	s4,16(sp)
 7ca:	e456                	sd	s5,8(sp)
 7cc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7ce:	8a4e                	mv	s4,s3
 7d0:	6705                	lui	a4,0x1
 7d2:	00e9f363          	bgeu	s3,a4,7d8 <malloc+0x42>
 7d6:	6a05                	lui	s4,0x1
 7d8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7dc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7e0:	00000497          	auipc	s1,0x0
 7e4:	62848493          	addi	s1,s1,1576 # e08 <freep>
  if(p == (char*)-1)
 7e8:	5afd                	li	s5,-1
 7ea:	a089                	j	82c <malloc+0x96>
 7ec:	f426                	sd	s1,40(sp)
 7ee:	e852                	sd	s4,16(sp)
 7f0:	e456                	sd	s5,8(sp)
 7f2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7f4:	00000797          	auipc	a5,0x0
 7f8:	61c78793          	addi	a5,a5,1564 # e10 <base>
 7fc:	00000717          	auipc	a4,0x0
 800:	60f73623          	sd	a5,1548(a4) # e08 <freep>
 804:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 806:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 80a:	b7d1                	j	7ce <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 80c:	6398                	ld	a4,0(a5)
 80e:	e118                	sd	a4,0(a0)
 810:	a8b9                	j	86e <malloc+0xd8>
  hp->s.size = nu;
 812:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 816:	0541                	addi	a0,a0,16
 818:	00000097          	auipc	ra,0x0
 81c:	ef8080e7          	jalr	-264(ra) # 710 <free>
  return freep;
 820:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 822:	c135                	beqz	a0,886 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 824:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 826:	4798                	lw	a4,8(a5)
 828:	03277363          	bgeu	a4,s2,84e <malloc+0xb8>
    if(p == freep)
 82c:	6098                	ld	a4,0(s1)
 82e:	853e                	mv	a0,a5
 830:	fef71ae3          	bne	a4,a5,824 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 834:	8552                	mv	a0,s4
 836:	00000097          	auipc	ra,0x0
 83a:	bae080e7          	jalr	-1106(ra) # 3e4 <sbrk>
  if(p == (char*)-1)
 83e:	fd551ae3          	bne	a0,s5,812 <malloc+0x7c>
        return 0;
 842:	4501                	li	a0,0
 844:	74a2                	ld	s1,40(sp)
 846:	6a42                	ld	s4,16(sp)
 848:	6aa2                	ld	s5,8(sp)
 84a:	6b02                	ld	s6,0(sp)
 84c:	a03d                	j	87a <malloc+0xe4>
 84e:	74a2                	ld	s1,40(sp)
 850:	6a42                	ld	s4,16(sp)
 852:	6aa2                	ld	s5,8(sp)
 854:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 856:	fae90be3          	beq	s2,a4,80c <malloc+0x76>
        p->s.size -= nunits;
 85a:	4137073b          	subw	a4,a4,s3
 85e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 860:	02071693          	slli	a3,a4,0x20
 864:	01c6d713          	srli	a4,a3,0x1c
 868:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 86a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 86e:	00000717          	auipc	a4,0x0
 872:	58a73d23          	sd	a0,1434(a4) # e08 <freep>
      return (void*)(p + 1);
 876:	01078513          	addi	a0,a5,16
  }
}
 87a:	70e2                	ld	ra,56(sp)
 87c:	7442                	ld	s0,48(sp)
 87e:	7902                	ld	s2,32(sp)
 880:	69e2                	ld	s3,24(sp)
 882:	6121                	addi	sp,sp,64
 884:	8082                	ret
 886:	74a2                	ld	s1,40(sp)
 888:	6a42                	ld	s4,16(sp)
 88a:	6aa2                	ld	s5,8(sp)
 88c:	6b02                	ld	s6,0(sp)
 88e:	b7f5                	j	87a <malloc+0xe4>
