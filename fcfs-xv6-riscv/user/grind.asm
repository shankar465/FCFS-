
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       8:	611c                	ld	a5,0(a0)
       a:	0017d693          	srli	a3,a5,0x1
       e:	c0000737          	lui	a4,0xc0000
      12:	0705                	addi	a4,a4,1 # ffffffffc0000001 <__global_pointer$+0xffffffffbfffdb85>
      14:	1706                	slli	a4,a4,0x21
      16:	0725                	addi	a4,a4,9
      18:	02e6b733          	mulhu	a4,a3,a4
      1c:	8375                	srli	a4,a4,0x1d
      1e:	01e71693          	slli	a3,a4,0x1e
      22:	40e68733          	sub	a4,a3,a4
      26:	0706                	slli	a4,a4,0x1
      28:	8f99                	sub	a5,a5,a4
      2a:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      2c:	1fe406b7          	lui	a3,0x1fe40
      30:	b7968693          	addi	a3,a3,-1159 # 1fe3fb79 <__global_pointer$+0x1fe3d6fd>
      34:	41a70737          	lui	a4,0x41a70
      38:	5af70713          	addi	a4,a4,1455 # 41a705af <__global_pointer$+0x41a6e133>
      3c:	1702                	slli	a4,a4,0x20
      3e:	9736                	add	a4,a4,a3
      40:	02e79733          	mulh	a4,a5,a4
      44:	873d                	srai	a4,a4,0xf
      46:	43f7d693          	srai	a3,a5,0x3f
      4a:	8f15                	sub	a4,a4,a3
      4c:	66fd                	lui	a3,0x1f
      4e:	31d68693          	addi	a3,a3,797 # 1f31d <__global_pointer$+0x1cea1>
      52:	02d706b3          	mul	a3,a4,a3
      56:	8f95                	sub	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      58:	6691                	lui	a3,0x4
      5a:	1a768693          	addi	a3,a3,423 # 41a7 <__global_pointer$+0x1d2b>
      5e:	02d787b3          	mul	a5,a5,a3
      62:	76fd                	lui	a3,0xfffff
      64:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <__global_pointer$+0xffffffffffffd070>
      68:	02d70733          	mul	a4,a4,a3
      6c:	97ba                	add	a5,a5,a4
    if (x < 0)
      6e:	0007ca63          	bltz	a5,82 <do_rand+0x82>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      72:	17fd                	addi	a5,a5,-1
    *ctx = x;
      74:	e11c                	sd	a5,0(a0)
    return (x);
}
      76:	0007851b          	sext.w	a0,a5
      7a:	60a2                	ld	ra,8(sp)
      7c:	6402                	ld	s0,0(sp)
      7e:	0141                	addi	sp,sp,16
      80:	8082                	ret
        x += 0x7fffffff;
      82:	80000737          	lui	a4,0x80000
      86:	fff74713          	not	a4,a4
      8a:	97ba                	add	a5,a5,a4
      8c:	b7dd                	j	72 <do_rand+0x72>

000000000000008e <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      8e:	1141                	addi	sp,sp,-16
      90:	e406                	sd	ra,8(sp)
      92:	e022                	sd	s0,0(sp)
      94:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      96:	00002517          	auipc	a0,0x2
      9a:	bea50513          	addi	a0,a0,-1046 # 1c80 <rand_next>
      9e:	00000097          	auipc	ra,0x0
      a2:	f62080e7          	jalr	-158(ra) # 0 <do_rand>
}
      a6:	60a2                	ld	ra,8(sp)
      a8:	6402                	ld	s0,0(sp)
      aa:	0141                	addi	sp,sp,16
      ac:	8082                	ret

00000000000000ae <go>:

void
go(int which_child)
{
      ae:	7171                	addi	sp,sp,-176
      b0:	f506                	sd	ra,168(sp)
      b2:	f122                	sd	s0,160(sp)
      b4:	ed26                	sd	s1,152(sp)
      b6:	1900                	addi	s0,sp,176
      b8:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      ba:	4501                	li	a0,0
      bc:	00001097          	auipc	ra,0x1
      c0:	e96080e7          	jalr	-362(ra) # f52 <sbrk>
      c4:	f4a43c23          	sd	a0,-168(s0)
  uint64 iters = 0;

  mkdir("grindir");
      c8:	00001517          	auipc	a0,0x1
      cc:	32850513          	addi	a0,a0,808 # 13f0 <malloc+0xfc>
      d0:	00001097          	auipc	ra,0x1
      d4:	e62080e7          	jalr	-414(ra) # f32 <mkdir>
  if(chdir("grindir") != 0){
      d8:	00001517          	auipc	a0,0x1
      dc:	31850513          	addi	a0,a0,792 # 13f0 <malloc+0xfc>
      e0:	00001097          	auipc	ra,0x1
      e4:	e5a080e7          	jalr	-422(ra) # f3a <chdir>
      e8:	c905                	beqz	a0,118 <go+0x6a>
      ea:	e94a                	sd	s2,144(sp)
      ec:	e54e                	sd	s3,136(sp)
      ee:	e152                	sd	s4,128(sp)
      f0:	fcd6                	sd	s5,120(sp)
      f2:	f8da                	sd	s6,112(sp)
      f4:	f4de                	sd	s7,104(sp)
      f6:	f0e2                	sd	s8,96(sp)
      f8:	ece6                	sd	s9,88(sp)
      fa:	e8ea                	sd	s10,80(sp)
      fc:	e4ee                	sd	s11,72(sp)
    printf("grind: chdir grindir failed\n");
      fe:	00001517          	auipc	a0,0x1
     102:	2fa50513          	addi	a0,a0,762 # 13f8 <malloc+0x104>
     106:	00001097          	auipc	ra,0x1
     10a:	132080e7          	jalr	306(ra) # 1238 <printf>
    exit(1);
     10e:	4505                	li	a0,1
     110:	00001097          	auipc	ra,0x1
     114:	dba080e7          	jalr	-582(ra) # eca <exit>
     118:	e94a                	sd	s2,144(sp)
     11a:	e54e                	sd	s3,136(sp)
     11c:	e152                	sd	s4,128(sp)
     11e:	fcd6                	sd	s5,120(sp)
     120:	f8da                	sd	s6,112(sp)
     122:	f4de                	sd	s7,104(sp)
     124:	f0e2                	sd	s8,96(sp)
     126:	ece6                	sd	s9,88(sp)
     128:	e8ea                	sd	s10,80(sp)
     12a:	e4ee                	sd	s11,72(sp)
  }
  chdir("/");
     12c:	00001517          	auipc	a0,0x1
     130:	2f450513          	addi	a0,a0,756 # 1420 <malloc+0x12c>
     134:	00001097          	auipc	ra,0x1
     138:	e06080e7          	jalr	-506(ra) # f3a <chdir>
     13c:	00001c17          	auipc	s8,0x1
     140:	2f4c0c13          	addi	s8,s8,756 # 1430 <malloc+0x13c>
     144:	c489                	beqz	s1,14e <go+0xa0>
     146:	00001c17          	auipc	s8,0x1
     14a:	2e2c0c13          	addi	s8,s8,738 # 1428 <malloc+0x134>
  uint64 iters = 0;
     14e:	4481                	li	s1,0
  int fd = -1;
     150:	5cfd                	li	s9,-1
  
  while(1){
    iters++;
    if((iters % 500) == 0)
     152:	106259b7          	lui	s3,0x10625
     156:	dd398993          	addi	s3,s3,-557 # 10624dd3 <__global_pointer$+0x10622957>
     15a:	09be                	slli	s3,s3,0xf
     15c:	8d598993          	addi	s3,s3,-1835
     160:	09ca                	slli	s3,s3,0x12
     162:	80098993          	addi	s3,s3,-2048
     166:	fcf98993          	addi	s3,s3,-49
     16a:	1f400b93          	li	s7,500
      write(1, which_child?"B":"A", 1);
     16e:	4a05                	li	s4,1
    int what = rand() % 23;
     170:	b2164ab7          	lui	s5,0xb2164
     174:	2c9a8a93          	addi	s5,s5,713 # ffffffffb21642c9 <__global_pointer$+0xffffffffb2161e4d>
     178:	4b59                	li	s6,22
     17a:	00001917          	auipc	s2,0x1
     17e:	58690913          	addi	s2,s2,1414 # 1700 <malloc+0x40c>
      close(fd1);
      unlink("c");
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     182:	f6840d93          	addi	s11,s0,-152
     186:	a839                	j	1a4 <go+0xf6>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     188:	20200593          	li	a1,514
     18c:	00001517          	auipc	a0,0x1
     190:	2ac50513          	addi	a0,a0,684 # 1438 <malloc+0x144>
     194:	00001097          	auipc	ra,0x1
     198:	d76080e7          	jalr	-650(ra) # f0a <open>
     19c:	00001097          	auipc	ra,0x1
     1a0:	d56080e7          	jalr	-682(ra) # ef2 <close>
    iters++;
     1a4:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     1a6:	0024d793          	srli	a5,s1,0x2
     1aa:	0337b7b3          	mulhu	a5,a5,s3
     1ae:	8391                	srli	a5,a5,0x4
     1b0:	037787b3          	mul	a5,a5,s7
     1b4:	00f49963          	bne	s1,a5,1c6 <go+0x118>
      write(1, which_child?"B":"A", 1);
     1b8:	8652                	mv	a2,s4
     1ba:	85e2                	mv	a1,s8
     1bc:	8552                	mv	a0,s4
     1be:	00001097          	auipc	ra,0x1
     1c2:	d2c080e7          	jalr	-724(ra) # eea <write>
    int what = rand() % 23;
     1c6:	00000097          	auipc	ra,0x0
     1ca:	ec8080e7          	jalr	-312(ra) # 8e <rand>
     1ce:	035507b3          	mul	a5,a0,s5
     1d2:	9381                	srli	a5,a5,0x20
     1d4:	9fa9                	addw	a5,a5,a0
     1d6:	4047d79b          	sraiw	a5,a5,0x4
     1da:	41f5571b          	sraiw	a4,a0,0x1f
     1de:	9f99                	subw	a5,a5,a4
     1e0:	0017971b          	slliw	a4,a5,0x1
     1e4:	9f3d                	addw	a4,a4,a5
     1e6:	0037171b          	slliw	a4,a4,0x3
     1ea:	40f707bb          	subw	a5,a4,a5
     1ee:	9d1d                	subw	a0,a0,a5
     1f0:	faab6ae3          	bltu	s6,a0,1a4 <go+0xf6>
     1f4:	02051793          	slli	a5,a0,0x20
     1f8:	01e7d513          	srli	a0,a5,0x1e
     1fc:	954a                	add	a0,a0,s2
     1fe:	411c                	lw	a5,0(a0)
     200:	97ca                	add	a5,a5,s2
     202:	8782                	jr	a5
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     204:	20200593          	li	a1,514
     208:	00001517          	auipc	a0,0x1
     20c:	24050513          	addi	a0,a0,576 # 1448 <malloc+0x154>
     210:	00001097          	auipc	ra,0x1
     214:	cfa080e7          	jalr	-774(ra) # f0a <open>
     218:	00001097          	auipc	ra,0x1
     21c:	cda080e7          	jalr	-806(ra) # ef2 <close>
     220:	b751                	j	1a4 <go+0xf6>
      unlink("grindir/../a");
     222:	00001517          	auipc	a0,0x1
     226:	21650513          	addi	a0,a0,534 # 1438 <malloc+0x144>
     22a:	00001097          	auipc	ra,0x1
     22e:	cf0080e7          	jalr	-784(ra) # f1a <unlink>
     232:	bf8d                	j	1a4 <go+0xf6>
      if(chdir("grindir") != 0){
     234:	00001517          	auipc	a0,0x1
     238:	1bc50513          	addi	a0,a0,444 # 13f0 <malloc+0xfc>
     23c:	00001097          	auipc	ra,0x1
     240:	cfe080e7          	jalr	-770(ra) # f3a <chdir>
     244:	e115                	bnez	a0,268 <go+0x1ba>
      unlink("../b");
     246:	00001517          	auipc	a0,0x1
     24a:	21a50513          	addi	a0,a0,538 # 1460 <malloc+0x16c>
     24e:	00001097          	auipc	ra,0x1
     252:	ccc080e7          	jalr	-820(ra) # f1a <unlink>
      chdir("/");
     256:	00001517          	auipc	a0,0x1
     25a:	1ca50513          	addi	a0,a0,458 # 1420 <malloc+0x12c>
     25e:	00001097          	auipc	ra,0x1
     262:	cdc080e7          	jalr	-804(ra) # f3a <chdir>
     266:	bf3d                	j	1a4 <go+0xf6>
        printf("grind: chdir grindir failed\n");
     268:	00001517          	auipc	a0,0x1
     26c:	19050513          	addi	a0,a0,400 # 13f8 <malloc+0x104>
     270:	00001097          	auipc	ra,0x1
     274:	fc8080e7          	jalr	-56(ra) # 1238 <printf>
        exit(1);
     278:	4505                	li	a0,1
     27a:	00001097          	auipc	ra,0x1
     27e:	c50080e7          	jalr	-944(ra) # eca <exit>
      close(fd);
     282:	8566                	mv	a0,s9
     284:	00001097          	auipc	ra,0x1
     288:	c6e080e7          	jalr	-914(ra) # ef2 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     28c:	20200593          	li	a1,514
     290:	00001517          	auipc	a0,0x1
     294:	1d850513          	addi	a0,a0,472 # 1468 <malloc+0x174>
     298:	00001097          	auipc	ra,0x1
     29c:	c72080e7          	jalr	-910(ra) # f0a <open>
     2a0:	8caa                	mv	s9,a0
     2a2:	b709                	j	1a4 <go+0xf6>
      close(fd);
     2a4:	8566                	mv	a0,s9
     2a6:	00001097          	auipc	ra,0x1
     2aa:	c4c080e7          	jalr	-948(ra) # ef2 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     2ae:	20200593          	li	a1,514
     2b2:	00001517          	auipc	a0,0x1
     2b6:	1c650513          	addi	a0,a0,454 # 1478 <malloc+0x184>
     2ba:	00001097          	auipc	ra,0x1
     2be:	c50080e7          	jalr	-944(ra) # f0a <open>
     2c2:	8caa                	mv	s9,a0
     2c4:	b5c5                	j	1a4 <go+0xf6>
      write(fd, buf, sizeof(buf));
     2c6:	3e700613          	li	a2,999
     2ca:	00002597          	auipc	a1,0x2
     2ce:	9c658593          	addi	a1,a1,-1594 # 1c90 <buf.0>
     2d2:	8566                	mv	a0,s9
     2d4:	00001097          	auipc	ra,0x1
     2d8:	c16080e7          	jalr	-1002(ra) # eea <write>
     2dc:	b5e1                	j	1a4 <go+0xf6>
      read(fd, buf, sizeof(buf));
     2de:	3e700613          	li	a2,999
     2e2:	00002597          	auipc	a1,0x2
     2e6:	9ae58593          	addi	a1,a1,-1618 # 1c90 <buf.0>
     2ea:	8566                	mv	a0,s9
     2ec:	00001097          	auipc	ra,0x1
     2f0:	bf6080e7          	jalr	-1034(ra) # ee2 <read>
     2f4:	bd45                	j	1a4 <go+0xf6>
      mkdir("grindir/../a");
     2f6:	00001517          	auipc	a0,0x1
     2fa:	14250513          	addi	a0,a0,322 # 1438 <malloc+0x144>
     2fe:	00001097          	auipc	ra,0x1
     302:	c34080e7          	jalr	-972(ra) # f32 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     306:	20200593          	li	a1,514
     30a:	00001517          	auipc	a0,0x1
     30e:	18650513          	addi	a0,a0,390 # 1490 <malloc+0x19c>
     312:	00001097          	auipc	ra,0x1
     316:	bf8080e7          	jalr	-1032(ra) # f0a <open>
     31a:	00001097          	auipc	ra,0x1
     31e:	bd8080e7          	jalr	-1064(ra) # ef2 <close>
      unlink("a/a");
     322:	00001517          	auipc	a0,0x1
     326:	17e50513          	addi	a0,a0,382 # 14a0 <malloc+0x1ac>
     32a:	00001097          	auipc	ra,0x1
     32e:	bf0080e7          	jalr	-1040(ra) # f1a <unlink>
     332:	bd8d                	j	1a4 <go+0xf6>
      mkdir("/../b");
     334:	00001517          	auipc	a0,0x1
     338:	17450513          	addi	a0,a0,372 # 14a8 <malloc+0x1b4>
     33c:	00001097          	auipc	ra,0x1
     340:	bf6080e7          	jalr	-1034(ra) # f32 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     344:	20200593          	li	a1,514
     348:	00001517          	auipc	a0,0x1
     34c:	16850513          	addi	a0,a0,360 # 14b0 <malloc+0x1bc>
     350:	00001097          	auipc	ra,0x1
     354:	bba080e7          	jalr	-1094(ra) # f0a <open>
     358:	00001097          	auipc	ra,0x1
     35c:	b9a080e7          	jalr	-1126(ra) # ef2 <close>
      unlink("b/b");
     360:	00001517          	auipc	a0,0x1
     364:	16050513          	addi	a0,a0,352 # 14c0 <malloc+0x1cc>
     368:	00001097          	auipc	ra,0x1
     36c:	bb2080e7          	jalr	-1102(ra) # f1a <unlink>
     370:	bd15                	j	1a4 <go+0xf6>
      unlink("b");
     372:	00001517          	auipc	a0,0x1
     376:	15650513          	addi	a0,a0,342 # 14c8 <malloc+0x1d4>
     37a:	00001097          	auipc	ra,0x1
     37e:	ba0080e7          	jalr	-1120(ra) # f1a <unlink>
      link("../grindir/./../a", "../b");
     382:	00001597          	auipc	a1,0x1
     386:	0de58593          	addi	a1,a1,222 # 1460 <malloc+0x16c>
     38a:	00001517          	auipc	a0,0x1
     38e:	14650513          	addi	a0,a0,326 # 14d0 <malloc+0x1dc>
     392:	00001097          	auipc	ra,0x1
     396:	b98080e7          	jalr	-1128(ra) # f2a <link>
     39a:	b529                	j	1a4 <go+0xf6>
      unlink("../grindir/../a");
     39c:	00001517          	auipc	a0,0x1
     3a0:	14c50513          	addi	a0,a0,332 # 14e8 <malloc+0x1f4>
     3a4:	00001097          	auipc	ra,0x1
     3a8:	b76080e7          	jalr	-1162(ra) # f1a <unlink>
      link(".././b", "/grindir/../a");
     3ac:	00001597          	auipc	a1,0x1
     3b0:	0bc58593          	addi	a1,a1,188 # 1468 <malloc+0x174>
     3b4:	00001517          	auipc	a0,0x1
     3b8:	14450513          	addi	a0,a0,324 # 14f8 <malloc+0x204>
     3bc:	00001097          	auipc	ra,0x1
     3c0:	b6e080e7          	jalr	-1170(ra) # f2a <link>
     3c4:	b3c5                	j	1a4 <go+0xf6>
      int pid = fork();
     3c6:	00001097          	auipc	ra,0x1
     3ca:	afc080e7          	jalr	-1284(ra) # ec2 <fork>
      if(pid == 0){
     3ce:	c909                	beqz	a0,3e0 <go+0x332>
      } else if(pid < 0){
     3d0:	00054c63          	bltz	a0,3e8 <go+0x33a>
      wait(0);
     3d4:	4501                	li	a0,0
     3d6:	00001097          	auipc	ra,0x1
     3da:	afc080e7          	jalr	-1284(ra) # ed2 <wait>
     3de:	b3d9                	j	1a4 <go+0xf6>
        exit(0);
     3e0:	00001097          	auipc	ra,0x1
     3e4:	aea080e7          	jalr	-1302(ra) # eca <exit>
        printf("grind: fork failed\n");
     3e8:	00001517          	auipc	a0,0x1
     3ec:	11850513          	addi	a0,a0,280 # 1500 <malloc+0x20c>
     3f0:	00001097          	auipc	ra,0x1
     3f4:	e48080e7          	jalr	-440(ra) # 1238 <printf>
        exit(1);
     3f8:	4505                	li	a0,1
     3fa:	00001097          	auipc	ra,0x1
     3fe:	ad0080e7          	jalr	-1328(ra) # eca <exit>
      int pid = fork();
     402:	00001097          	auipc	ra,0x1
     406:	ac0080e7          	jalr	-1344(ra) # ec2 <fork>
      if(pid == 0){
     40a:	c909                	beqz	a0,41c <go+0x36e>
      } else if(pid < 0){
     40c:	02054563          	bltz	a0,436 <go+0x388>
      wait(0);
     410:	4501                	li	a0,0
     412:	00001097          	auipc	ra,0x1
     416:	ac0080e7          	jalr	-1344(ra) # ed2 <wait>
     41a:	b369                	j	1a4 <go+0xf6>
        fork();
     41c:	00001097          	auipc	ra,0x1
     420:	aa6080e7          	jalr	-1370(ra) # ec2 <fork>
        fork();
     424:	00001097          	auipc	ra,0x1
     428:	a9e080e7          	jalr	-1378(ra) # ec2 <fork>
        exit(0);
     42c:	4501                	li	a0,0
     42e:	00001097          	auipc	ra,0x1
     432:	a9c080e7          	jalr	-1380(ra) # eca <exit>
        printf("grind: fork failed\n");
     436:	00001517          	auipc	a0,0x1
     43a:	0ca50513          	addi	a0,a0,202 # 1500 <malloc+0x20c>
     43e:	00001097          	auipc	ra,0x1
     442:	dfa080e7          	jalr	-518(ra) # 1238 <printf>
        exit(1);
     446:	4505                	li	a0,1
     448:	00001097          	auipc	ra,0x1
     44c:	a82080e7          	jalr	-1406(ra) # eca <exit>
      sbrk(6011);
     450:	6505                	lui	a0,0x1
     452:	77b50513          	addi	a0,a0,1915 # 177b <malloc+0x487>
     456:	00001097          	auipc	ra,0x1
     45a:	afc080e7          	jalr	-1284(ra) # f52 <sbrk>
     45e:	b399                	j	1a4 <go+0xf6>
      if(sbrk(0) > break0)
     460:	4501                	li	a0,0
     462:	00001097          	auipc	ra,0x1
     466:	af0080e7          	jalr	-1296(ra) # f52 <sbrk>
     46a:	f5843783          	ld	a5,-168(s0)
     46e:	d2a7fbe3          	bgeu	a5,a0,1a4 <go+0xf6>
        sbrk(-(sbrk(0) - break0));
     472:	4501                	li	a0,0
     474:	00001097          	auipc	ra,0x1
     478:	ade080e7          	jalr	-1314(ra) # f52 <sbrk>
     47c:	f5843783          	ld	a5,-168(s0)
     480:	40a7853b          	subw	a0,a5,a0
     484:	00001097          	auipc	ra,0x1
     488:	ace080e7          	jalr	-1330(ra) # f52 <sbrk>
     48c:	bb21                	j	1a4 <go+0xf6>
      int pid = fork();
     48e:	00001097          	auipc	ra,0x1
     492:	a34080e7          	jalr	-1484(ra) # ec2 <fork>
     496:	8d2a                	mv	s10,a0
      if(pid == 0){
     498:	c51d                	beqz	a0,4c6 <go+0x418>
      } else if(pid < 0){
     49a:	04054963          	bltz	a0,4ec <go+0x43e>
      if(chdir("../grindir/..") != 0){
     49e:	00001517          	auipc	a0,0x1
     4a2:	08250513          	addi	a0,a0,130 # 1520 <malloc+0x22c>
     4a6:	00001097          	auipc	ra,0x1
     4aa:	a94080e7          	jalr	-1388(ra) # f3a <chdir>
     4ae:	ed21                	bnez	a0,506 <go+0x458>
      kill(pid);
     4b0:	856a                	mv	a0,s10
     4b2:	00001097          	auipc	ra,0x1
     4b6:	a48080e7          	jalr	-1464(ra) # efa <kill>
      wait(0);
     4ba:	4501                	li	a0,0
     4bc:	00001097          	auipc	ra,0x1
     4c0:	a16080e7          	jalr	-1514(ra) # ed2 <wait>
     4c4:	b1c5                	j	1a4 <go+0xf6>
        close(open("a", O_CREATE|O_RDWR));
     4c6:	20200593          	li	a1,514
     4ca:	00001517          	auipc	a0,0x1
     4ce:	04e50513          	addi	a0,a0,78 # 1518 <malloc+0x224>
     4d2:	00001097          	auipc	ra,0x1
     4d6:	a38080e7          	jalr	-1480(ra) # f0a <open>
     4da:	00001097          	auipc	ra,0x1
     4de:	a18080e7          	jalr	-1512(ra) # ef2 <close>
        exit(0);
     4e2:	4501                	li	a0,0
     4e4:	00001097          	auipc	ra,0x1
     4e8:	9e6080e7          	jalr	-1562(ra) # eca <exit>
        printf("grind: fork failed\n");
     4ec:	00001517          	auipc	a0,0x1
     4f0:	01450513          	addi	a0,a0,20 # 1500 <malloc+0x20c>
     4f4:	00001097          	auipc	ra,0x1
     4f8:	d44080e7          	jalr	-700(ra) # 1238 <printf>
        exit(1);
     4fc:	4505                	li	a0,1
     4fe:	00001097          	auipc	ra,0x1
     502:	9cc080e7          	jalr	-1588(ra) # eca <exit>
        printf("grind: chdir failed\n");
     506:	00001517          	auipc	a0,0x1
     50a:	02a50513          	addi	a0,a0,42 # 1530 <malloc+0x23c>
     50e:	00001097          	auipc	ra,0x1
     512:	d2a080e7          	jalr	-726(ra) # 1238 <printf>
        exit(1);
     516:	4505                	li	a0,1
     518:	00001097          	auipc	ra,0x1
     51c:	9b2080e7          	jalr	-1614(ra) # eca <exit>
      int pid = fork();
     520:	00001097          	auipc	ra,0x1
     524:	9a2080e7          	jalr	-1630(ra) # ec2 <fork>
      if(pid == 0){
     528:	c909                	beqz	a0,53a <go+0x48c>
      } else if(pid < 0){
     52a:	02054563          	bltz	a0,554 <go+0x4a6>
      wait(0);
     52e:	4501                	li	a0,0
     530:	00001097          	auipc	ra,0x1
     534:	9a2080e7          	jalr	-1630(ra) # ed2 <wait>
     538:	b1b5                	j	1a4 <go+0xf6>
        kill(getpid());
     53a:	00001097          	auipc	ra,0x1
     53e:	a10080e7          	jalr	-1520(ra) # f4a <getpid>
     542:	00001097          	auipc	ra,0x1
     546:	9b8080e7          	jalr	-1608(ra) # efa <kill>
        exit(0);
     54a:	4501                	li	a0,0
     54c:	00001097          	auipc	ra,0x1
     550:	97e080e7          	jalr	-1666(ra) # eca <exit>
        printf("grind: fork failed\n");
     554:	00001517          	auipc	a0,0x1
     558:	fac50513          	addi	a0,a0,-84 # 1500 <malloc+0x20c>
     55c:	00001097          	auipc	ra,0x1
     560:	cdc080e7          	jalr	-804(ra) # 1238 <printf>
        exit(1);
     564:	4505                	li	a0,1
     566:	00001097          	auipc	ra,0x1
     56a:	964080e7          	jalr	-1692(ra) # eca <exit>
      if(pipe(fds) < 0){
     56e:	f7840513          	addi	a0,s0,-136
     572:	00001097          	auipc	ra,0x1
     576:	968080e7          	jalr	-1688(ra) # eda <pipe>
     57a:	02054b63          	bltz	a0,5b0 <go+0x502>
      int pid = fork();
     57e:	00001097          	auipc	ra,0x1
     582:	944080e7          	jalr	-1724(ra) # ec2 <fork>
      if(pid == 0){
     586:	c131                	beqz	a0,5ca <go+0x51c>
      } else if(pid < 0){
     588:	0a054a63          	bltz	a0,63c <go+0x58e>
      close(fds[0]);
     58c:	f7842503          	lw	a0,-136(s0)
     590:	00001097          	auipc	ra,0x1
     594:	962080e7          	jalr	-1694(ra) # ef2 <close>
      close(fds[1]);
     598:	f7c42503          	lw	a0,-132(s0)
     59c:	00001097          	auipc	ra,0x1
     5a0:	956080e7          	jalr	-1706(ra) # ef2 <close>
      wait(0);
     5a4:	4501                	li	a0,0
     5a6:	00001097          	auipc	ra,0x1
     5aa:	92c080e7          	jalr	-1748(ra) # ed2 <wait>
     5ae:	bedd                	j	1a4 <go+0xf6>
        printf("grind: pipe failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	f9850513          	addi	a0,a0,-104 # 1548 <malloc+0x254>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c80080e7          	jalr	-896(ra) # 1238 <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	908080e7          	jalr	-1784(ra) # eca <exit>
        fork();
     5ca:	00001097          	auipc	ra,0x1
     5ce:	8f8080e7          	jalr	-1800(ra) # ec2 <fork>
        fork();
     5d2:	00001097          	auipc	ra,0x1
     5d6:	8f0080e7          	jalr	-1808(ra) # ec2 <fork>
        if(write(fds[1], "x", 1) != 1)
     5da:	4605                	li	a2,1
     5dc:	00001597          	auipc	a1,0x1
     5e0:	f8458593          	addi	a1,a1,-124 # 1560 <malloc+0x26c>
     5e4:	f7c42503          	lw	a0,-132(s0)
     5e8:	00001097          	auipc	ra,0x1
     5ec:	902080e7          	jalr	-1790(ra) # eea <write>
     5f0:	4785                	li	a5,1
     5f2:	02f51363          	bne	a0,a5,618 <go+0x56a>
        if(read(fds[0], &c, 1) != 1)
     5f6:	4605                	li	a2,1
     5f8:	f7040593          	addi	a1,s0,-144
     5fc:	f7842503          	lw	a0,-136(s0)
     600:	00001097          	auipc	ra,0x1
     604:	8e2080e7          	jalr	-1822(ra) # ee2 <read>
     608:	4785                	li	a5,1
     60a:	02f51063          	bne	a0,a5,62a <go+0x57c>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	8ba080e7          	jalr	-1862(ra) # eca <exit>
          printf("grind: pipe write failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	f5050513          	addi	a0,a0,-176 # 1568 <malloc+0x274>
     620:	00001097          	auipc	ra,0x1
     624:	c18080e7          	jalr	-1000(ra) # 1238 <printf>
     628:	b7f9                	j	5f6 <go+0x548>
          printf("grind: pipe read failed\n");
     62a:	00001517          	auipc	a0,0x1
     62e:	f5e50513          	addi	a0,a0,-162 # 1588 <malloc+0x294>
     632:	00001097          	auipc	ra,0x1
     636:	c06080e7          	jalr	-1018(ra) # 1238 <printf>
     63a:	bfd1                	j	60e <go+0x560>
        printf("grind: fork failed\n");
     63c:	00001517          	auipc	a0,0x1
     640:	ec450513          	addi	a0,a0,-316 # 1500 <malloc+0x20c>
     644:	00001097          	auipc	ra,0x1
     648:	bf4080e7          	jalr	-1036(ra) # 1238 <printf>
        exit(1);
     64c:	4505                	li	a0,1
     64e:	00001097          	auipc	ra,0x1
     652:	87c080e7          	jalr	-1924(ra) # eca <exit>
      int pid = fork();
     656:	00001097          	auipc	ra,0x1
     65a:	86c080e7          	jalr	-1940(ra) # ec2 <fork>
      if(pid == 0){
     65e:	c909                	beqz	a0,670 <go+0x5c2>
      } else if(pid < 0){
     660:	06054f63          	bltz	a0,6de <go+0x630>
      wait(0);
     664:	4501                	li	a0,0
     666:	00001097          	auipc	ra,0x1
     66a:	86c080e7          	jalr	-1940(ra) # ed2 <wait>
     66e:	be1d                	j	1a4 <go+0xf6>
        unlink("a");
     670:	00001517          	auipc	a0,0x1
     674:	ea850513          	addi	a0,a0,-344 # 1518 <malloc+0x224>
     678:	00001097          	auipc	ra,0x1
     67c:	8a2080e7          	jalr	-1886(ra) # f1a <unlink>
        mkdir("a");
     680:	00001517          	auipc	a0,0x1
     684:	e9850513          	addi	a0,a0,-360 # 1518 <malloc+0x224>
     688:	00001097          	auipc	ra,0x1
     68c:	8aa080e7          	jalr	-1878(ra) # f32 <mkdir>
        chdir("a");
     690:	00001517          	auipc	a0,0x1
     694:	e8850513          	addi	a0,a0,-376 # 1518 <malloc+0x224>
     698:	00001097          	auipc	ra,0x1
     69c:	8a2080e7          	jalr	-1886(ra) # f3a <chdir>
        unlink("../a");
     6a0:	00001517          	auipc	a0,0x1
     6a4:	f0850513          	addi	a0,a0,-248 # 15a8 <malloc+0x2b4>
     6a8:	00001097          	auipc	ra,0x1
     6ac:	872080e7          	jalr	-1934(ra) # f1a <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     6b0:	20200593          	li	a1,514
     6b4:	00001517          	auipc	a0,0x1
     6b8:	eac50513          	addi	a0,a0,-340 # 1560 <malloc+0x26c>
     6bc:	00001097          	auipc	ra,0x1
     6c0:	84e080e7          	jalr	-1970(ra) # f0a <open>
        unlink("x");
     6c4:	00001517          	auipc	a0,0x1
     6c8:	e9c50513          	addi	a0,a0,-356 # 1560 <malloc+0x26c>
     6cc:	00001097          	auipc	ra,0x1
     6d0:	84e080e7          	jalr	-1970(ra) # f1a <unlink>
        exit(0);
     6d4:	4501                	li	a0,0
     6d6:	00000097          	auipc	ra,0x0
     6da:	7f4080e7          	jalr	2036(ra) # eca <exit>
        printf("grind: fork failed\n");
     6de:	00001517          	auipc	a0,0x1
     6e2:	e2250513          	addi	a0,a0,-478 # 1500 <malloc+0x20c>
     6e6:	00001097          	auipc	ra,0x1
     6ea:	b52080e7          	jalr	-1198(ra) # 1238 <printf>
        exit(1);
     6ee:	4505                	li	a0,1
     6f0:	00000097          	auipc	ra,0x0
     6f4:	7da080e7          	jalr	2010(ra) # eca <exit>
      unlink("c");
     6f8:	00001517          	auipc	a0,0x1
     6fc:	eb850513          	addi	a0,a0,-328 # 15b0 <malloc+0x2bc>
     700:	00001097          	auipc	ra,0x1
     704:	81a080e7          	jalr	-2022(ra) # f1a <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     708:	20200593          	li	a1,514
     70c:	00001517          	auipc	a0,0x1
     710:	ea450513          	addi	a0,a0,-348 # 15b0 <malloc+0x2bc>
     714:	00000097          	auipc	ra,0x0
     718:	7f6080e7          	jalr	2038(ra) # f0a <open>
     71c:	8d2a                	mv	s10,a0
      if(fd1 < 0){
     71e:	04054d63          	bltz	a0,778 <go+0x6ca>
      if(write(fd1, "x", 1) != 1){
     722:	8652                	mv	a2,s4
     724:	00001597          	auipc	a1,0x1
     728:	e3c58593          	addi	a1,a1,-452 # 1560 <malloc+0x26c>
     72c:	00000097          	auipc	ra,0x0
     730:	7be080e7          	jalr	1982(ra) # eea <write>
     734:	05451f63          	bne	a0,s4,792 <go+0x6e4>
      if(fstat(fd1, &st) != 0){
     738:	f7840593          	addi	a1,s0,-136
     73c:	856a                	mv	a0,s10
     73e:	00000097          	auipc	ra,0x0
     742:	7e4080e7          	jalr	2020(ra) # f22 <fstat>
     746:	e13d                	bnez	a0,7ac <go+0x6fe>
      if(st.size != 1){
     748:	f8843583          	ld	a1,-120(s0)
     74c:	07459d63          	bne	a1,s4,7c6 <go+0x718>
      if(st.ino > 200){
     750:	f7c42583          	lw	a1,-132(s0)
     754:	0c800793          	li	a5,200
     758:	08b7e563          	bltu	a5,a1,7e2 <go+0x734>
      close(fd1);
     75c:	856a                	mv	a0,s10
     75e:	00000097          	auipc	ra,0x0
     762:	794080e7          	jalr	1940(ra) # ef2 <close>
      unlink("c");
     766:	00001517          	auipc	a0,0x1
     76a:	e4a50513          	addi	a0,a0,-438 # 15b0 <malloc+0x2bc>
     76e:	00000097          	auipc	ra,0x0
     772:	7ac080e7          	jalr	1964(ra) # f1a <unlink>
     776:	b43d                	j	1a4 <go+0xf6>
        printf("grind: create c failed\n");
     778:	00001517          	auipc	a0,0x1
     77c:	e4050513          	addi	a0,a0,-448 # 15b8 <malloc+0x2c4>
     780:	00001097          	auipc	ra,0x1
     784:	ab8080e7          	jalr	-1352(ra) # 1238 <printf>
        exit(1);
     788:	4505                	li	a0,1
     78a:	00000097          	auipc	ra,0x0
     78e:	740080e7          	jalr	1856(ra) # eca <exit>
        printf("grind: write c failed\n");
     792:	00001517          	auipc	a0,0x1
     796:	e3e50513          	addi	a0,a0,-450 # 15d0 <malloc+0x2dc>
     79a:	00001097          	auipc	ra,0x1
     79e:	a9e080e7          	jalr	-1378(ra) # 1238 <printf>
        exit(1);
     7a2:	4505                	li	a0,1
     7a4:	00000097          	auipc	ra,0x0
     7a8:	726080e7          	jalr	1830(ra) # eca <exit>
        printf("grind: fstat failed\n");
     7ac:	00001517          	auipc	a0,0x1
     7b0:	e3c50513          	addi	a0,a0,-452 # 15e8 <malloc+0x2f4>
     7b4:	00001097          	auipc	ra,0x1
     7b8:	a84080e7          	jalr	-1404(ra) # 1238 <printf>
        exit(1);
     7bc:	4505                	li	a0,1
     7be:	00000097          	auipc	ra,0x0
     7c2:	70c080e7          	jalr	1804(ra) # eca <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     7c6:	2581                	sext.w	a1,a1
     7c8:	00001517          	auipc	a0,0x1
     7cc:	e3850513          	addi	a0,a0,-456 # 1600 <malloc+0x30c>
     7d0:	00001097          	auipc	ra,0x1
     7d4:	a68080e7          	jalr	-1432(ra) # 1238 <printf>
        exit(1);
     7d8:	4505                	li	a0,1
     7da:	00000097          	auipc	ra,0x0
     7de:	6f0080e7          	jalr	1776(ra) # eca <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     7e2:	00001517          	auipc	a0,0x1
     7e6:	e4650513          	addi	a0,a0,-442 # 1628 <malloc+0x334>
     7ea:	00001097          	auipc	ra,0x1
     7ee:	a4e080e7          	jalr	-1458(ra) # 1238 <printf>
        exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00000097          	auipc	ra,0x0
     7f8:	6d6080e7          	jalr	1750(ra) # eca <exit>
      if(pipe(aa) < 0){
     7fc:	856e                	mv	a0,s11
     7fe:	00000097          	auipc	ra,0x0
     802:	6dc080e7          	jalr	1756(ra) # eda <pipe>
     806:	10054063          	bltz	a0,906 <go+0x858>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     80a:	f7040513          	addi	a0,s0,-144
     80e:	00000097          	auipc	ra,0x0
     812:	6cc080e7          	jalr	1740(ra) # eda <pipe>
     816:	10054663          	bltz	a0,922 <go+0x874>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     81a:	00000097          	auipc	ra,0x0
     81e:	6a8080e7          	jalr	1704(ra) # ec2 <fork>
      if(pid1 == 0){
     822:	10050e63          	beqz	a0,93e <go+0x890>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     826:	1c054663          	bltz	a0,9f2 <go+0x944>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     82a:	00000097          	auipc	ra,0x0
     82e:	698080e7          	jalr	1688(ra) # ec2 <fork>
      if(pid2 == 0){
     832:	1c050e63          	beqz	a0,a0e <go+0x960>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     836:	2a054a63          	bltz	a0,aea <go+0xa3c>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     83a:	f6842503          	lw	a0,-152(s0)
     83e:	00000097          	auipc	ra,0x0
     842:	6b4080e7          	jalr	1716(ra) # ef2 <close>
      close(aa[1]);
     846:	f6c42503          	lw	a0,-148(s0)
     84a:	00000097          	auipc	ra,0x0
     84e:	6a8080e7          	jalr	1704(ra) # ef2 <close>
      close(bb[1]);
     852:	f7442503          	lw	a0,-140(s0)
     856:	00000097          	auipc	ra,0x0
     85a:	69c080e7          	jalr	1692(ra) # ef2 <close>
      char buf[4] = { 0, 0, 0, 0 };
     85e:	f6042023          	sw	zero,-160(s0)
      read(bb[0], buf+0, 1);
     862:	8652                	mv	a2,s4
     864:	f6040593          	addi	a1,s0,-160
     868:	f7042503          	lw	a0,-144(s0)
     86c:	00000097          	auipc	ra,0x0
     870:	676080e7          	jalr	1654(ra) # ee2 <read>
      read(bb[0], buf+1, 1);
     874:	8652                	mv	a2,s4
     876:	f6140593          	addi	a1,s0,-159
     87a:	f7042503          	lw	a0,-144(s0)
     87e:	00000097          	auipc	ra,0x0
     882:	664080e7          	jalr	1636(ra) # ee2 <read>
      read(bb[0], buf+2, 1);
     886:	8652                	mv	a2,s4
     888:	f6240593          	addi	a1,s0,-158
     88c:	f7042503          	lw	a0,-144(s0)
     890:	00000097          	auipc	ra,0x0
     894:	652080e7          	jalr	1618(ra) # ee2 <read>
      close(bb[0]);
     898:	f7042503          	lw	a0,-144(s0)
     89c:	00000097          	auipc	ra,0x0
     8a0:	656080e7          	jalr	1622(ra) # ef2 <close>
      int st1, st2;
      wait(&st1);
     8a4:	f6440513          	addi	a0,s0,-156
     8a8:	00000097          	auipc	ra,0x0
     8ac:	62a080e7          	jalr	1578(ra) # ed2 <wait>
      wait(&st2);
     8b0:	f7840513          	addi	a0,s0,-136
     8b4:	00000097          	auipc	ra,0x0
     8b8:	61e080e7          	jalr	1566(ra) # ed2 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     8bc:	f6442783          	lw	a5,-156(s0)
     8c0:	f7842703          	lw	a4,-136(s0)
     8c4:	8fd9                	or	a5,a5,a4
     8c6:	ef89                	bnez	a5,8e0 <go+0x832>
     8c8:	00001597          	auipc	a1,0x1
     8cc:	e0058593          	addi	a1,a1,-512 # 16c8 <malloc+0x3d4>
     8d0:	f6040513          	addi	a0,s0,-160
     8d4:	00000097          	auipc	ra,0x0
     8d8:	388080e7          	jalr	904(ra) # c5c <strcmp>
     8dc:	8c0504e3          	beqz	a0,1a4 <go+0xf6>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     8e0:	f6040693          	addi	a3,s0,-160
     8e4:	f7842603          	lw	a2,-136(s0)
     8e8:	f6442583          	lw	a1,-156(s0)
     8ec:	00001517          	auipc	a0,0x1
     8f0:	de450513          	addi	a0,a0,-540 # 16d0 <malloc+0x3dc>
     8f4:	00001097          	auipc	ra,0x1
     8f8:	944080e7          	jalr	-1724(ra) # 1238 <printf>
        exit(1);
     8fc:	4505                	li	a0,1
     8fe:	00000097          	auipc	ra,0x0
     902:	5cc080e7          	jalr	1484(ra) # eca <exit>
        fprintf(2, "grind: pipe failed\n");
     906:	00001597          	auipc	a1,0x1
     90a:	c4258593          	addi	a1,a1,-958 # 1548 <malloc+0x254>
     90e:	4509                	li	a0,2
     910:	00001097          	auipc	ra,0x1
     914:	8fa080e7          	jalr	-1798(ra) # 120a <fprintf>
        exit(1);
     918:	4505                	li	a0,1
     91a:	00000097          	auipc	ra,0x0
     91e:	5b0080e7          	jalr	1456(ra) # eca <exit>
        fprintf(2, "grind: pipe failed\n");
     922:	00001597          	auipc	a1,0x1
     926:	c2658593          	addi	a1,a1,-986 # 1548 <malloc+0x254>
     92a:	4509                	li	a0,2
     92c:	00001097          	auipc	ra,0x1
     930:	8de080e7          	jalr	-1826(ra) # 120a <fprintf>
        exit(1);
     934:	4505                	li	a0,1
     936:	00000097          	auipc	ra,0x0
     93a:	594080e7          	jalr	1428(ra) # eca <exit>
        close(bb[0]);
     93e:	f7042503          	lw	a0,-144(s0)
     942:	00000097          	auipc	ra,0x0
     946:	5b0080e7          	jalr	1456(ra) # ef2 <close>
        close(bb[1]);
     94a:	f7442503          	lw	a0,-140(s0)
     94e:	00000097          	auipc	ra,0x0
     952:	5a4080e7          	jalr	1444(ra) # ef2 <close>
        close(aa[0]);
     956:	f6842503          	lw	a0,-152(s0)
     95a:	00000097          	auipc	ra,0x0
     95e:	598080e7          	jalr	1432(ra) # ef2 <close>
        close(1);
     962:	4505                	li	a0,1
     964:	00000097          	auipc	ra,0x0
     968:	58e080e7          	jalr	1422(ra) # ef2 <close>
        if(dup(aa[1]) != 1){
     96c:	f6c42503          	lw	a0,-148(s0)
     970:	00000097          	auipc	ra,0x0
     974:	5d2080e7          	jalr	1490(ra) # f42 <dup>
     978:	4785                	li	a5,1
     97a:	02f50063          	beq	a0,a5,99a <go+0x8ec>
          fprintf(2, "grind: dup failed\n");
     97e:	00001597          	auipc	a1,0x1
     982:	cd258593          	addi	a1,a1,-814 # 1650 <malloc+0x35c>
     986:	4509                	li	a0,2
     988:	00001097          	auipc	ra,0x1
     98c:	882080e7          	jalr	-1918(ra) # 120a <fprintf>
          exit(1);
     990:	4505                	li	a0,1
     992:	00000097          	auipc	ra,0x0
     996:	538080e7          	jalr	1336(ra) # eca <exit>
        close(aa[1]);
     99a:	f6c42503          	lw	a0,-148(s0)
     99e:	00000097          	auipc	ra,0x0
     9a2:	554080e7          	jalr	1364(ra) # ef2 <close>
        char *args[3] = { "echo", "hi", 0 };
     9a6:	00001797          	auipc	a5,0x1
     9aa:	cc278793          	addi	a5,a5,-830 # 1668 <malloc+0x374>
     9ae:	f6f43c23          	sd	a5,-136(s0)
     9b2:	00001797          	auipc	a5,0x1
     9b6:	cbe78793          	addi	a5,a5,-834 # 1670 <malloc+0x37c>
     9ba:	f8f43023          	sd	a5,-128(s0)
     9be:	f8043423          	sd	zero,-120(s0)
        exec("grindir/../echo", args);
     9c2:	f7840593          	addi	a1,s0,-136
     9c6:	00001517          	auipc	a0,0x1
     9ca:	cb250513          	addi	a0,a0,-846 # 1678 <malloc+0x384>
     9ce:	00000097          	auipc	ra,0x0
     9d2:	534080e7          	jalr	1332(ra) # f02 <exec>
        fprintf(2, "grind: echo: not found\n");
     9d6:	00001597          	auipc	a1,0x1
     9da:	cb258593          	addi	a1,a1,-846 # 1688 <malloc+0x394>
     9de:	4509                	li	a0,2
     9e0:	00001097          	auipc	ra,0x1
     9e4:	82a080e7          	jalr	-2006(ra) # 120a <fprintf>
        exit(2);
     9e8:	4509                	li	a0,2
     9ea:	00000097          	auipc	ra,0x0
     9ee:	4e0080e7          	jalr	1248(ra) # eca <exit>
        fprintf(2, "grind: fork failed\n");
     9f2:	00001597          	auipc	a1,0x1
     9f6:	b0e58593          	addi	a1,a1,-1266 # 1500 <malloc+0x20c>
     9fa:	4509                	li	a0,2
     9fc:	00001097          	auipc	ra,0x1
     a00:	80e080e7          	jalr	-2034(ra) # 120a <fprintf>
        exit(3);
     a04:	450d                	li	a0,3
     a06:	00000097          	auipc	ra,0x0
     a0a:	4c4080e7          	jalr	1220(ra) # eca <exit>
        close(aa[1]);
     a0e:	f6c42503          	lw	a0,-148(s0)
     a12:	00000097          	auipc	ra,0x0
     a16:	4e0080e7          	jalr	1248(ra) # ef2 <close>
        close(bb[0]);
     a1a:	f7042503          	lw	a0,-144(s0)
     a1e:	00000097          	auipc	ra,0x0
     a22:	4d4080e7          	jalr	1236(ra) # ef2 <close>
        close(0);
     a26:	4501                	li	a0,0
     a28:	00000097          	auipc	ra,0x0
     a2c:	4ca080e7          	jalr	1226(ra) # ef2 <close>
        if(dup(aa[0]) != 0){
     a30:	f6842503          	lw	a0,-152(s0)
     a34:	00000097          	auipc	ra,0x0
     a38:	50e080e7          	jalr	1294(ra) # f42 <dup>
     a3c:	cd19                	beqz	a0,a5a <go+0x9ac>
          fprintf(2, "grind: dup failed\n");
     a3e:	00001597          	auipc	a1,0x1
     a42:	c1258593          	addi	a1,a1,-1006 # 1650 <malloc+0x35c>
     a46:	4509                	li	a0,2
     a48:	00000097          	auipc	ra,0x0
     a4c:	7c2080e7          	jalr	1986(ra) # 120a <fprintf>
          exit(4);
     a50:	4511                	li	a0,4
     a52:	00000097          	auipc	ra,0x0
     a56:	478080e7          	jalr	1144(ra) # eca <exit>
        close(aa[0]);
     a5a:	f6842503          	lw	a0,-152(s0)
     a5e:	00000097          	auipc	ra,0x0
     a62:	494080e7          	jalr	1172(ra) # ef2 <close>
        close(1);
     a66:	4505                	li	a0,1
     a68:	00000097          	auipc	ra,0x0
     a6c:	48a080e7          	jalr	1162(ra) # ef2 <close>
        if(dup(bb[1]) != 1){
     a70:	f7442503          	lw	a0,-140(s0)
     a74:	00000097          	auipc	ra,0x0
     a78:	4ce080e7          	jalr	1230(ra) # f42 <dup>
     a7c:	4785                	li	a5,1
     a7e:	02f50063          	beq	a0,a5,a9e <go+0x9f0>
          fprintf(2, "grind: dup failed\n");
     a82:	00001597          	auipc	a1,0x1
     a86:	bce58593          	addi	a1,a1,-1074 # 1650 <malloc+0x35c>
     a8a:	4509                	li	a0,2
     a8c:	00000097          	auipc	ra,0x0
     a90:	77e080e7          	jalr	1918(ra) # 120a <fprintf>
          exit(5);
     a94:	4515                	li	a0,5
     a96:	00000097          	auipc	ra,0x0
     a9a:	434080e7          	jalr	1076(ra) # eca <exit>
        close(bb[1]);
     a9e:	f7442503          	lw	a0,-140(s0)
     aa2:	00000097          	auipc	ra,0x0
     aa6:	450080e7          	jalr	1104(ra) # ef2 <close>
        char *args[2] = { "cat", 0 };
     aaa:	00001797          	auipc	a5,0x1
     aae:	bf678793          	addi	a5,a5,-1034 # 16a0 <malloc+0x3ac>
     ab2:	f6f43c23          	sd	a5,-136(s0)
     ab6:	f8043023          	sd	zero,-128(s0)
        exec("/cat", args);
     aba:	f7840593          	addi	a1,s0,-136
     abe:	00001517          	auipc	a0,0x1
     ac2:	bea50513          	addi	a0,a0,-1046 # 16a8 <malloc+0x3b4>
     ac6:	00000097          	auipc	ra,0x0
     aca:	43c080e7          	jalr	1084(ra) # f02 <exec>
        fprintf(2, "grind: cat: not found\n");
     ace:	00001597          	auipc	a1,0x1
     ad2:	be258593          	addi	a1,a1,-1054 # 16b0 <malloc+0x3bc>
     ad6:	4509                	li	a0,2
     ad8:	00000097          	auipc	ra,0x0
     adc:	732080e7          	jalr	1842(ra) # 120a <fprintf>
        exit(6);
     ae0:	4519                	li	a0,6
     ae2:	00000097          	auipc	ra,0x0
     ae6:	3e8080e7          	jalr	1000(ra) # eca <exit>
        fprintf(2, "grind: fork failed\n");
     aea:	00001597          	auipc	a1,0x1
     aee:	a1658593          	addi	a1,a1,-1514 # 1500 <malloc+0x20c>
     af2:	4509                	li	a0,2
     af4:	00000097          	auipc	ra,0x0
     af8:	716080e7          	jalr	1814(ra) # 120a <fprintf>
        exit(7);
     afc:	451d                	li	a0,7
     afe:	00000097          	auipc	ra,0x0
     b02:	3cc080e7          	jalr	972(ra) # eca <exit>

0000000000000b06 <iter>:
  }
}

void
iter()
{
     b06:	7179                	addi	sp,sp,-48
     b08:	f406                	sd	ra,40(sp)
     b0a:	f022                	sd	s0,32(sp)
     b0c:	1800                	addi	s0,sp,48
  unlink("a");
     b0e:	00001517          	auipc	a0,0x1
     b12:	a0a50513          	addi	a0,a0,-1526 # 1518 <malloc+0x224>
     b16:	00000097          	auipc	ra,0x0
     b1a:	404080e7          	jalr	1028(ra) # f1a <unlink>
  unlink("b");
     b1e:	00001517          	auipc	a0,0x1
     b22:	9aa50513          	addi	a0,a0,-1622 # 14c8 <malloc+0x1d4>
     b26:	00000097          	auipc	ra,0x0
     b2a:	3f4080e7          	jalr	1012(ra) # f1a <unlink>
  
  int pid1 = fork();
     b2e:	00000097          	auipc	ra,0x0
     b32:	394080e7          	jalr	916(ra) # ec2 <fork>
  if(pid1 < 0){
     b36:	02054063          	bltz	a0,b56 <iter+0x50>
     b3a:	ec26                	sd	s1,24(sp)
     b3c:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     b3e:	e91d                	bnez	a0,b74 <iter+0x6e>
     b40:	e84a                	sd	s2,16(sp)
    rand_next = 31;
     b42:	47fd                	li	a5,31
     b44:	00001717          	auipc	a4,0x1
     b48:	12f73e23          	sd	a5,316(a4) # 1c80 <rand_next>
    go(0);
     b4c:	4501                	li	a0,0
     b4e:	fffff097          	auipc	ra,0xfffff
     b52:	560080e7          	jalr	1376(ra) # ae <go>
     b56:	ec26                	sd	s1,24(sp)
     b58:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     b5a:	00001517          	auipc	a0,0x1
     b5e:	9a650513          	addi	a0,a0,-1626 # 1500 <malloc+0x20c>
     b62:	00000097          	auipc	ra,0x0
     b66:	6d6080e7          	jalr	1750(ra) # 1238 <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00000097          	auipc	ra,0x0
     b70:	35e080e7          	jalr	862(ra) # eca <exit>
     b74:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     b76:	00000097          	auipc	ra,0x0
     b7a:	34c080e7          	jalr	844(ra) # ec2 <fork>
     b7e:	892a                	mv	s2,a0
  if(pid2 < 0){
     b80:	00054f63          	bltz	a0,b9e <iter+0x98>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b84:	e915                	bnez	a0,bb8 <iter+0xb2>
    rand_next = 7177;
     b86:	6789                	lui	a5,0x2
     b88:	c0978793          	addi	a5,a5,-1015 # 1c09 <digits+0x451>
     b8c:	00001717          	auipc	a4,0x1
     b90:	0ef73a23          	sd	a5,244(a4) # 1c80 <rand_next>
    go(1);
     b94:	4505                	li	a0,1
     b96:	fffff097          	auipc	ra,0xfffff
     b9a:	518080e7          	jalr	1304(ra) # ae <go>
    printf("grind: fork failed\n");
     b9e:	00001517          	auipc	a0,0x1
     ba2:	96250513          	addi	a0,a0,-1694 # 1500 <malloc+0x20c>
     ba6:	00000097          	auipc	ra,0x0
     baa:	692080e7          	jalr	1682(ra) # 1238 <printf>
    exit(1);
     bae:	4505                	li	a0,1
     bb0:	00000097          	auipc	ra,0x0
     bb4:	31a080e7          	jalr	794(ra) # eca <exit>
    exit(0);
  }

  int st1 = -1;
     bb8:	57fd                	li	a5,-1
     bba:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     bbe:	fdc40513          	addi	a0,s0,-36
     bc2:	00000097          	auipc	ra,0x0
     bc6:	310080e7          	jalr	784(ra) # ed2 <wait>
  if(st1 != 0){
     bca:	fdc42783          	lw	a5,-36(s0)
     bce:	ef99                	bnez	a5,bec <iter+0xe6>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     bd0:	57fd                	li	a5,-1
     bd2:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     bd6:	fd840513          	addi	a0,s0,-40
     bda:	00000097          	auipc	ra,0x0
     bde:	2f8080e7          	jalr	760(ra) # ed2 <wait>

  exit(0);
     be2:	4501                	li	a0,0
     be4:	00000097          	auipc	ra,0x0
     be8:	2e6080e7          	jalr	742(ra) # eca <exit>
    kill(pid1);
     bec:	8526                	mv	a0,s1
     bee:	00000097          	auipc	ra,0x0
     bf2:	30c080e7          	jalr	780(ra) # efa <kill>
    kill(pid2);
     bf6:	854a                	mv	a0,s2
     bf8:	00000097          	auipc	ra,0x0
     bfc:	302080e7          	jalr	770(ra) # efa <kill>
     c00:	bfc1                	j	bd0 <iter+0xca>

0000000000000c02 <main>:
}

int
main()
{
     c02:	1101                	addi	sp,sp,-32
     c04:	ec06                	sd	ra,24(sp)
     c06:	e822                	sd	s0,16(sp)
     c08:	e426                	sd	s1,8(sp)
     c0a:	1000                	addi	s0,sp,32
      exit(0);
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
     c0c:	44d1                	li	s1,20
     c0e:	a811                	j	c22 <main+0x20>
      iter();
     c10:	00000097          	auipc	ra,0x0
     c14:	ef6080e7          	jalr	-266(ra) # b06 <iter>
    sleep(20);
     c18:	8526                	mv	a0,s1
     c1a:	00000097          	auipc	ra,0x0
     c1e:	340080e7          	jalr	832(ra) # f5a <sleep>
    int pid = fork();
     c22:	00000097          	auipc	ra,0x0
     c26:	2a0080e7          	jalr	672(ra) # ec2 <fork>
    if(pid == 0){
     c2a:	d17d                	beqz	a0,c10 <main+0xe>
    if(pid > 0){
     c2c:	fea056e3          	blez	a0,c18 <main+0x16>
      wait(0);
     c30:	4501                	li	a0,0
     c32:	00000097          	auipc	ra,0x0
     c36:	2a0080e7          	jalr	672(ra) # ed2 <wait>
     c3a:	bff9                	j	c18 <main+0x16>

0000000000000c3c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     c3c:	1141                	addi	sp,sp,-16
     c3e:	e406                	sd	ra,8(sp)
     c40:	e022                	sd	s0,0(sp)
     c42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c44:	87aa                	mv	a5,a0
     c46:	0585                	addi	a1,a1,1
     c48:	0785                	addi	a5,a5,1
     c4a:	fff5c703          	lbu	a4,-1(a1)
     c4e:	fee78fa3          	sb	a4,-1(a5)
     c52:	fb75                	bnez	a4,c46 <strcpy+0xa>
    ;
  return os;
}
     c54:	60a2                	ld	ra,8(sp)
     c56:	6402                	ld	s0,0(sp)
     c58:	0141                	addi	sp,sp,16
     c5a:	8082                	ret

0000000000000c5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c5c:	1141                	addi	sp,sp,-16
     c5e:	e406                	sd	ra,8(sp)
     c60:	e022                	sd	s0,0(sp)
     c62:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c64:	00054783          	lbu	a5,0(a0)
     c68:	cb91                	beqz	a5,c7c <strcmp+0x20>
     c6a:	0005c703          	lbu	a4,0(a1)
     c6e:	00f71763          	bne	a4,a5,c7c <strcmp+0x20>
    p++, q++;
     c72:	0505                	addi	a0,a0,1
     c74:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c76:	00054783          	lbu	a5,0(a0)
     c7a:	fbe5                	bnez	a5,c6a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     c7c:	0005c503          	lbu	a0,0(a1)
}
     c80:	40a7853b          	subw	a0,a5,a0
     c84:	60a2                	ld	ra,8(sp)
     c86:	6402                	ld	s0,0(sp)
     c88:	0141                	addi	sp,sp,16
     c8a:	8082                	ret

0000000000000c8c <strlen>:

uint
strlen(const char *s)
{
     c8c:	1141                	addi	sp,sp,-16
     c8e:	e406                	sd	ra,8(sp)
     c90:	e022                	sd	s0,0(sp)
     c92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c94:	00054783          	lbu	a5,0(a0)
     c98:	cf91                	beqz	a5,cb4 <strlen+0x28>
     c9a:	00150793          	addi	a5,a0,1
     c9e:	86be                	mv	a3,a5
     ca0:	0785                	addi	a5,a5,1
     ca2:	fff7c703          	lbu	a4,-1(a5)
     ca6:	ff65                	bnez	a4,c9e <strlen+0x12>
     ca8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     cac:	60a2                	ld	ra,8(sp)
     cae:	6402                	ld	s0,0(sp)
     cb0:	0141                	addi	sp,sp,16
     cb2:	8082                	ret
  for(n = 0; s[n]; n++)
     cb4:	4501                	li	a0,0
     cb6:	bfdd                	j	cac <strlen+0x20>

0000000000000cb8 <memset>:

void*
memset(void *dst, int c, uint n)
{
     cb8:	1141                	addi	sp,sp,-16
     cba:	e406                	sd	ra,8(sp)
     cbc:	e022                	sd	s0,0(sp)
     cbe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cc0:	ca19                	beqz	a2,cd6 <memset+0x1e>
     cc2:	87aa                	mv	a5,a0
     cc4:	1602                	slli	a2,a2,0x20
     cc6:	9201                	srli	a2,a2,0x20
     cc8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     ccc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cd0:	0785                	addi	a5,a5,1
     cd2:	fee79de3          	bne	a5,a4,ccc <memset+0x14>
  }
  return dst;
}
     cd6:	60a2                	ld	ra,8(sp)
     cd8:	6402                	ld	s0,0(sp)
     cda:	0141                	addi	sp,sp,16
     cdc:	8082                	ret

0000000000000cde <strchr>:

char*
strchr(const char *s, char c)
{
     cde:	1141                	addi	sp,sp,-16
     ce0:	e406                	sd	ra,8(sp)
     ce2:	e022                	sd	s0,0(sp)
     ce4:	0800                	addi	s0,sp,16
  for(; *s; s++)
     ce6:	00054783          	lbu	a5,0(a0)
     cea:	cf81                	beqz	a5,d02 <strchr+0x24>
    if(*s == c)
     cec:	00f58763          	beq	a1,a5,cfa <strchr+0x1c>
  for(; *s; s++)
     cf0:	0505                	addi	a0,a0,1
     cf2:	00054783          	lbu	a5,0(a0)
     cf6:	fbfd                	bnez	a5,cec <strchr+0xe>
      return (char*)s;
  return 0;
     cf8:	4501                	li	a0,0
}
     cfa:	60a2                	ld	ra,8(sp)
     cfc:	6402                	ld	s0,0(sp)
     cfe:	0141                	addi	sp,sp,16
     d00:	8082                	ret
  return 0;
     d02:	4501                	li	a0,0
     d04:	bfdd                	j	cfa <strchr+0x1c>

0000000000000d06 <gets>:

char*
gets(char *buf, int max)
{
     d06:	711d                	addi	sp,sp,-96
     d08:	ec86                	sd	ra,88(sp)
     d0a:	e8a2                	sd	s0,80(sp)
     d0c:	e4a6                	sd	s1,72(sp)
     d0e:	e0ca                	sd	s2,64(sp)
     d10:	fc4e                	sd	s3,56(sp)
     d12:	f852                	sd	s4,48(sp)
     d14:	f456                	sd	s5,40(sp)
     d16:	f05a                	sd	s6,32(sp)
     d18:	ec5e                	sd	s7,24(sp)
     d1a:	e862                	sd	s8,16(sp)
     d1c:	1080                	addi	s0,sp,96
     d1e:	8baa                	mv	s7,a0
     d20:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d22:	892a                	mv	s2,a0
     d24:	4481                	li	s1,0
    cc = read(0, &c, 1);
     d26:	faf40b13          	addi	s6,s0,-81
     d2a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
     d2c:	8c26                	mv	s8,s1
     d2e:	0014899b          	addiw	s3,s1,1
     d32:	84ce                	mv	s1,s3
     d34:	0349d663          	bge	s3,s4,d60 <gets+0x5a>
    cc = read(0, &c, 1);
     d38:	8656                	mv	a2,s5
     d3a:	85da                	mv	a1,s6
     d3c:	4501                	li	a0,0
     d3e:	00000097          	auipc	ra,0x0
     d42:	1a4080e7          	jalr	420(ra) # ee2 <read>
    if(cc < 1)
     d46:	00a05d63          	blez	a0,d60 <gets+0x5a>
      break;
    buf[i++] = c;
     d4a:	faf44783          	lbu	a5,-81(s0)
     d4e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d52:	0905                	addi	s2,s2,1
     d54:	ff678713          	addi	a4,a5,-10
     d58:	c319                	beqz	a4,d5e <gets+0x58>
     d5a:	17cd                	addi	a5,a5,-13
     d5c:	fbe1                	bnez	a5,d2c <gets+0x26>
    buf[i++] = c;
     d5e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     d60:	9c5e                	add	s8,s8,s7
     d62:	000c0023          	sb	zero,0(s8)
  return buf;
}
     d66:	855e                	mv	a0,s7
     d68:	60e6                	ld	ra,88(sp)
     d6a:	6446                	ld	s0,80(sp)
     d6c:	64a6                	ld	s1,72(sp)
     d6e:	6906                	ld	s2,64(sp)
     d70:	79e2                	ld	s3,56(sp)
     d72:	7a42                	ld	s4,48(sp)
     d74:	7aa2                	ld	s5,40(sp)
     d76:	7b02                	ld	s6,32(sp)
     d78:	6be2                	ld	s7,24(sp)
     d7a:	6c42                	ld	s8,16(sp)
     d7c:	6125                	addi	sp,sp,96
     d7e:	8082                	ret

0000000000000d80 <stat>:

int
stat(const char *n, struct stat *st)
{
     d80:	1101                	addi	sp,sp,-32
     d82:	ec06                	sd	ra,24(sp)
     d84:	e822                	sd	s0,16(sp)
     d86:	e04a                	sd	s2,0(sp)
     d88:	1000                	addi	s0,sp,32
     d8a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d8c:	4581                	li	a1,0
     d8e:	00000097          	auipc	ra,0x0
     d92:	17c080e7          	jalr	380(ra) # f0a <open>
  if(fd < 0)
     d96:	02054663          	bltz	a0,dc2 <stat+0x42>
     d9a:	e426                	sd	s1,8(sp)
     d9c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d9e:	85ca                	mv	a1,s2
     da0:	00000097          	auipc	ra,0x0
     da4:	182080e7          	jalr	386(ra) # f22 <fstat>
     da8:	892a                	mv	s2,a0
  close(fd);
     daa:	8526                	mv	a0,s1
     dac:	00000097          	auipc	ra,0x0
     db0:	146080e7          	jalr	326(ra) # ef2 <close>
  return r;
     db4:	64a2                	ld	s1,8(sp)
}
     db6:	854a                	mv	a0,s2
     db8:	60e2                	ld	ra,24(sp)
     dba:	6442                	ld	s0,16(sp)
     dbc:	6902                	ld	s2,0(sp)
     dbe:	6105                	addi	sp,sp,32
     dc0:	8082                	ret
    return -1;
     dc2:	57fd                	li	a5,-1
     dc4:	893e                	mv	s2,a5
     dc6:	bfc5                	j	db6 <stat+0x36>

0000000000000dc8 <atoi>:

int
atoi(const char *s)
{
     dc8:	1141                	addi	sp,sp,-16
     dca:	e406                	sd	ra,8(sp)
     dcc:	e022                	sd	s0,0(sp)
     dce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     dd0:	00054683          	lbu	a3,0(a0)
     dd4:	fd06879b          	addiw	a5,a3,-48
     dd8:	0ff7f793          	zext.b	a5,a5
     ddc:	4625                	li	a2,9
     dde:	02f66963          	bltu	a2,a5,e10 <atoi+0x48>
     de2:	872a                	mv	a4,a0
  n = 0;
     de4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     de6:	0705                	addi	a4,a4,1
     de8:	0025179b          	slliw	a5,a0,0x2
     dec:	9fa9                	addw	a5,a5,a0
     dee:	0017979b          	slliw	a5,a5,0x1
     df2:	9fb5                	addw	a5,a5,a3
     df4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     df8:	00074683          	lbu	a3,0(a4)
     dfc:	fd06879b          	addiw	a5,a3,-48
     e00:	0ff7f793          	zext.b	a5,a5
     e04:	fef671e3          	bgeu	a2,a5,de6 <atoi+0x1e>
  return n;
}
     e08:	60a2                	ld	ra,8(sp)
     e0a:	6402                	ld	s0,0(sp)
     e0c:	0141                	addi	sp,sp,16
     e0e:	8082                	ret
  n = 0;
     e10:	4501                	li	a0,0
     e12:	bfdd                	j	e08 <atoi+0x40>

0000000000000e14 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e14:	1141                	addi	sp,sp,-16
     e16:	e406                	sd	ra,8(sp)
     e18:	e022                	sd	s0,0(sp)
     e1a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e1c:	02b57563          	bgeu	a0,a1,e46 <memmove+0x32>
    while(n-- > 0)
     e20:	00c05f63          	blez	a2,e3e <memmove+0x2a>
     e24:	1602                	slli	a2,a2,0x20
     e26:	9201                	srli	a2,a2,0x20
     e28:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e2c:	872a                	mv	a4,a0
      *dst++ = *src++;
     e2e:	0585                	addi	a1,a1,1
     e30:	0705                	addi	a4,a4,1
     e32:	fff5c683          	lbu	a3,-1(a1)
     e36:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e3a:	fee79ae3          	bne	a5,a4,e2e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e3e:	60a2                	ld	ra,8(sp)
     e40:	6402                	ld	s0,0(sp)
     e42:	0141                	addi	sp,sp,16
     e44:	8082                	ret
    while(n-- > 0)
     e46:	fec05ce3          	blez	a2,e3e <memmove+0x2a>
    dst += n;
     e4a:	00c50733          	add	a4,a0,a2
    src += n;
     e4e:	95b2                	add	a1,a1,a2
     e50:	fff6079b          	addiw	a5,a2,-1
     e54:	1782                	slli	a5,a5,0x20
     e56:	9381                	srli	a5,a5,0x20
     e58:	fff7c793          	not	a5,a5
     e5c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e5e:	15fd                	addi	a1,a1,-1
     e60:	177d                	addi	a4,a4,-1
     e62:	0005c683          	lbu	a3,0(a1)
     e66:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e6a:	fef71ae3          	bne	a4,a5,e5e <memmove+0x4a>
     e6e:	bfc1                	j	e3e <memmove+0x2a>

0000000000000e70 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e70:	1141                	addi	sp,sp,-16
     e72:	e406                	sd	ra,8(sp)
     e74:	e022                	sd	s0,0(sp)
     e76:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e78:	c61d                	beqz	a2,ea6 <memcmp+0x36>
     e7a:	1602                	slli	a2,a2,0x20
     e7c:	9201                	srli	a2,a2,0x20
     e7e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     e82:	00054783          	lbu	a5,0(a0)
     e86:	0005c703          	lbu	a4,0(a1)
     e8a:	00e79863          	bne	a5,a4,e9a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     e8e:	0505                	addi	a0,a0,1
    p2++;
     e90:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e92:	fed518e3          	bne	a0,a3,e82 <memcmp+0x12>
  }
  return 0;
     e96:	4501                	li	a0,0
     e98:	a019                	j	e9e <memcmp+0x2e>
      return *p1 - *p2;
     e9a:	40e7853b          	subw	a0,a5,a4
}
     e9e:	60a2                	ld	ra,8(sp)
     ea0:	6402                	ld	s0,0(sp)
     ea2:	0141                	addi	sp,sp,16
     ea4:	8082                	ret
  return 0;
     ea6:	4501                	li	a0,0
     ea8:	bfdd                	j	e9e <memcmp+0x2e>

0000000000000eaa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     eaa:	1141                	addi	sp,sp,-16
     eac:	e406                	sd	ra,8(sp)
     eae:	e022                	sd	s0,0(sp)
     eb0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     eb2:	00000097          	auipc	ra,0x0
     eb6:	f62080e7          	jalr	-158(ra) # e14 <memmove>
}
     eba:	60a2                	ld	ra,8(sp)
     ebc:	6402                	ld	s0,0(sp)
     ebe:	0141                	addi	sp,sp,16
     ec0:	8082                	ret

0000000000000ec2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ec2:	4885                	li	a7,1
 ecall
     ec4:	00000073          	ecall
 ret
     ec8:	8082                	ret

0000000000000eca <exit>:
.global exit
exit:
 li a7, SYS_exit
     eca:	4889                	li	a7,2
 ecall
     ecc:	00000073          	ecall
 ret
     ed0:	8082                	ret

0000000000000ed2 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ed2:	488d                	li	a7,3
 ecall
     ed4:	00000073          	ecall
 ret
     ed8:	8082                	ret

0000000000000eda <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eda:	4891                	li	a7,4
 ecall
     edc:	00000073          	ecall
 ret
     ee0:	8082                	ret

0000000000000ee2 <read>:
.global read
read:
 li a7, SYS_read
     ee2:	4895                	li	a7,5
 ecall
     ee4:	00000073          	ecall
 ret
     ee8:	8082                	ret

0000000000000eea <write>:
.global write
write:
 li a7, SYS_write
     eea:	48c1                	li	a7,16
 ecall
     eec:	00000073          	ecall
 ret
     ef0:	8082                	ret

0000000000000ef2 <close>:
.global close
close:
 li a7, SYS_close
     ef2:	48d5                	li	a7,21
 ecall
     ef4:	00000073          	ecall
 ret
     ef8:	8082                	ret

0000000000000efa <kill>:
.global kill
kill:
 li a7, SYS_kill
     efa:	4899                	li	a7,6
 ecall
     efc:	00000073          	ecall
 ret
     f00:	8082                	ret

0000000000000f02 <exec>:
.global exec
exec:
 li a7, SYS_exec
     f02:	489d                	li	a7,7
 ecall
     f04:	00000073          	ecall
 ret
     f08:	8082                	ret

0000000000000f0a <open>:
.global open
open:
 li a7, SYS_open
     f0a:	48bd                	li	a7,15
 ecall
     f0c:	00000073          	ecall
 ret
     f10:	8082                	ret

0000000000000f12 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     f12:	48c5                	li	a7,17
 ecall
     f14:	00000073          	ecall
 ret
     f18:	8082                	ret

0000000000000f1a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f1a:	48c9                	li	a7,18
 ecall
     f1c:	00000073          	ecall
 ret
     f20:	8082                	ret

0000000000000f22 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f22:	48a1                	li	a7,8
 ecall
     f24:	00000073          	ecall
 ret
     f28:	8082                	ret

0000000000000f2a <link>:
.global link
link:
 li a7, SYS_link
     f2a:	48cd                	li	a7,19
 ecall
     f2c:	00000073          	ecall
 ret
     f30:	8082                	ret

0000000000000f32 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f32:	48d1                	li	a7,20
 ecall
     f34:	00000073          	ecall
 ret
     f38:	8082                	ret

0000000000000f3a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f3a:	48a5                	li	a7,9
 ecall
     f3c:	00000073          	ecall
 ret
     f40:	8082                	ret

0000000000000f42 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f42:	48a9                	li	a7,10
 ecall
     f44:	00000073          	ecall
 ret
     f48:	8082                	ret

0000000000000f4a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f4a:	48ad                	li	a7,11
 ecall
     f4c:	00000073          	ecall
 ret
     f50:	8082                	ret

0000000000000f52 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f52:	48b1                	li	a7,12
 ecall
     f54:	00000073          	ecall
 ret
     f58:	8082                	ret

0000000000000f5a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f5a:	48b5                	li	a7,13
 ecall
     f5c:	00000073          	ecall
 ret
     f60:	8082                	ret

0000000000000f62 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f62:	48b9                	li	a7,14
 ecall
     f64:	00000073          	ecall
 ret
     f68:	8082                	ret

0000000000000f6a <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
     f6a:	48d9                	li	a7,22
 ecall
     f6c:	00000073          	ecall
 ret
     f70:	8082                	ret

0000000000000f72 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f72:	1101                	addi	sp,sp,-32
     f74:	ec06                	sd	ra,24(sp)
     f76:	e822                	sd	s0,16(sp)
     f78:	1000                	addi	s0,sp,32
     f7a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f7e:	4605                	li	a2,1
     f80:	fef40593          	addi	a1,s0,-17
     f84:	00000097          	auipc	ra,0x0
     f88:	f66080e7          	jalr	-154(ra) # eea <write>
}
     f8c:	60e2                	ld	ra,24(sp)
     f8e:	6442                	ld	s0,16(sp)
     f90:	6105                	addi	sp,sp,32
     f92:	8082                	ret

0000000000000f94 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f94:	7139                	addi	sp,sp,-64
     f96:	fc06                	sd	ra,56(sp)
     f98:	f822                	sd	s0,48(sp)
     f9a:	f04a                	sd	s2,32(sp)
     f9c:	ec4e                	sd	s3,24(sp)
     f9e:	0080                	addi	s0,sp,64
     fa0:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fa2:	cad9                	beqz	a3,1038 <printint+0xa4>
     fa4:	01f5d79b          	srliw	a5,a1,0x1f
     fa8:	cbc1                	beqz	a5,1038 <printint+0xa4>
    neg = 1;
    x = -xx;
     faa:	40b005bb          	negw	a1,a1
    neg = 1;
     fae:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     fb0:	fc040993          	addi	s3,s0,-64
  neg = 0;
     fb4:	86ce                	mv	a3,s3
  i = 0;
     fb6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fb8:	00001817          	auipc	a6,0x1
     fbc:	80080813          	addi	a6,a6,-2048 # 17b8 <digits>
     fc0:	88ba                	mv	a7,a4
     fc2:	0017051b          	addiw	a0,a4,1
     fc6:	872a                	mv	a4,a0
     fc8:	02c5f7bb          	remuw	a5,a1,a2
     fcc:	1782                	slli	a5,a5,0x20
     fce:	9381                	srli	a5,a5,0x20
     fd0:	97c2                	add	a5,a5,a6
     fd2:	0007c783          	lbu	a5,0(a5)
     fd6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fda:	87ae                	mv	a5,a1
     fdc:	02c5d5bb          	divuw	a1,a1,a2
     fe0:	0685                	addi	a3,a3,1
     fe2:	fcc7ffe3          	bgeu	a5,a2,fc0 <printint+0x2c>
  if(neg)
     fe6:	00030c63          	beqz	t1,ffe <printint+0x6a>
    buf[i++] = '-';
     fea:	fd050793          	addi	a5,a0,-48
     fee:	00878533          	add	a0,a5,s0
     ff2:	02d00793          	li	a5,45
     ff6:	fef50823          	sb	a5,-16(a0)
     ffa:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
     ffe:	02e05763          	blez	a4,102c <printint+0x98>
    1002:	f426                	sd	s1,40(sp)
    1004:	377d                	addiw	a4,a4,-1
    1006:	00e984b3          	add	s1,s3,a4
    100a:	19fd                	addi	s3,s3,-1
    100c:	99ba                	add	s3,s3,a4
    100e:	1702                	slli	a4,a4,0x20
    1010:	9301                	srli	a4,a4,0x20
    1012:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1016:	0004c583          	lbu	a1,0(s1)
    101a:	854a                	mv	a0,s2
    101c:	00000097          	auipc	ra,0x0
    1020:	f56080e7          	jalr	-170(ra) # f72 <putc>
  while(--i >= 0)
    1024:	14fd                	addi	s1,s1,-1
    1026:	ff3498e3          	bne	s1,s3,1016 <printint+0x82>
    102a:	74a2                	ld	s1,40(sp)
}
    102c:	70e2                	ld	ra,56(sp)
    102e:	7442                	ld	s0,48(sp)
    1030:	7902                	ld	s2,32(sp)
    1032:	69e2                	ld	s3,24(sp)
    1034:	6121                	addi	sp,sp,64
    1036:	8082                	ret
  neg = 0;
    1038:	4301                	li	t1,0
    103a:	bf9d                	j	fb0 <printint+0x1c>

000000000000103c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    103c:	715d                	addi	sp,sp,-80
    103e:	e486                	sd	ra,72(sp)
    1040:	e0a2                	sd	s0,64(sp)
    1042:	f84a                	sd	s2,48(sp)
    1044:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1046:	0005c903          	lbu	s2,0(a1)
    104a:	1a090b63          	beqz	s2,1200 <vprintf+0x1c4>
    104e:	fc26                	sd	s1,56(sp)
    1050:	f44e                	sd	s3,40(sp)
    1052:	f052                	sd	s4,32(sp)
    1054:	ec56                	sd	s5,24(sp)
    1056:	e85a                	sd	s6,16(sp)
    1058:	e45e                	sd	s7,8(sp)
    105a:	8aaa                	mv	s5,a0
    105c:	8bb2                	mv	s7,a2
    105e:	00158493          	addi	s1,a1,1
  state = 0;
    1062:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1064:	02500a13          	li	s4,37
    1068:	4b55                	li	s6,21
    106a:	a839                	j	1088 <vprintf+0x4c>
        putc(fd, c);
    106c:	85ca                	mv	a1,s2
    106e:	8556                	mv	a0,s5
    1070:	00000097          	auipc	ra,0x0
    1074:	f02080e7          	jalr	-254(ra) # f72 <putc>
    1078:	a019                	j	107e <vprintf+0x42>
    } else if(state == '%'){
    107a:	01498d63          	beq	s3,s4,1094 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
    107e:	0485                	addi	s1,s1,1
    1080:	fff4c903          	lbu	s2,-1(s1)
    1084:	16090863          	beqz	s2,11f4 <vprintf+0x1b8>
    if(state == 0){
    1088:	fe0999e3          	bnez	s3,107a <vprintf+0x3e>
      if(c == '%'){
    108c:	ff4910e3          	bne	s2,s4,106c <vprintf+0x30>
        state = '%';
    1090:	89d2                	mv	s3,s4
    1092:	b7f5                	j	107e <vprintf+0x42>
      if(c == 'd'){
    1094:	13490563          	beq	s2,s4,11be <vprintf+0x182>
    1098:	f9d9079b          	addiw	a5,s2,-99
    109c:	0ff7f793          	zext.b	a5,a5
    10a0:	12fb6863          	bltu	s6,a5,11d0 <vprintf+0x194>
    10a4:	f9d9079b          	addiw	a5,s2,-99
    10a8:	0ff7f713          	zext.b	a4,a5
    10ac:	12eb6263          	bltu	s6,a4,11d0 <vprintf+0x194>
    10b0:	00271793          	slli	a5,a4,0x2
    10b4:	00000717          	auipc	a4,0x0
    10b8:	6ac70713          	addi	a4,a4,1708 # 1760 <malloc+0x46c>
    10bc:	97ba                	add	a5,a5,a4
    10be:	439c                	lw	a5,0(a5)
    10c0:	97ba                	add	a5,a5,a4
    10c2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    10c4:	008b8913          	addi	s2,s7,8
    10c8:	4685                	li	a3,1
    10ca:	4629                	li	a2,10
    10cc:	000ba583          	lw	a1,0(s7)
    10d0:	8556                	mv	a0,s5
    10d2:	00000097          	auipc	ra,0x0
    10d6:	ec2080e7          	jalr	-318(ra) # f94 <printint>
    10da:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    10dc:	4981                	li	s3,0
    10de:	b745                	j	107e <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10e0:	008b8913          	addi	s2,s7,8
    10e4:	4681                	li	a3,0
    10e6:	4629                	li	a2,10
    10e8:	000ba583          	lw	a1,0(s7)
    10ec:	8556                	mv	a0,s5
    10ee:	00000097          	auipc	ra,0x0
    10f2:	ea6080e7          	jalr	-346(ra) # f94 <printint>
    10f6:	8bca                	mv	s7,s2
      state = 0;
    10f8:	4981                	li	s3,0
    10fa:	b751                	j	107e <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    10fc:	008b8913          	addi	s2,s7,8
    1100:	4681                	li	a3,0
    1102:	4641                	li	a2,16
    1104:	000ba583          	lw	a1,0(s7)
    1108:	8556                	mv	a0,s5
    110a:	00000097          	auipc	ra,0x0
    110e:	e8a080e7          	jalr	-374(ra) # f94 <printint>
    1112:	8bca                	mv	s7,s2
      state = 0;
    1114:	4981                	li	s3,0
    1116:	b7a5                	j	107e <vprintf+0x42>
    1118:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    111a:	008b8793          	addi	a5,s7,8
    111e:	8c3e                	mv	s8,a5
    1120:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    1124:	03000593          	li	a1,48
    1128:	8556                	mv	a0,s5
    112a:	00000097          	auipc	ra,0x0
    112e:	e48080e7          	jalr	-440(ra) # f72 <putc>
  putc(fd, 'x');
    1132:	07800593          	li	a1,120
    1136:	8556                	mv	a0,s5
    1138:	00000097          	auipc	ra,0x0
    113c:	e3a080e7          	jalr	-454(ra) # f72 <putc>
    1140:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1142:	00000b97          	auipc	s7,0x0
    1146:	676b8b93          	addi	s7,s7,1654 # 17b8 <digits>
    114a:	03c9d793          	srli	a5,s3,0x3c
    114e:	97de                	add	a5,a5,s7
    1150:	0007c583          	lbu	a1,0(a5)
    1154:	8556                	mv	a0,s5
    1156:	00000097          	auipc	ra,0x0
    115a:	e1c080e7          	jalr	-484(ra) # f72 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    115e:	0992                	slli	s3,s3,0x4
    1160:	397d                	addiw	s2,s2,-1
    1162:	fe0914e3          	bnez	s2,114a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
    1166:	8be2                	mv	s7,s8
      state = 0;
    1168:	4981                	li	s3,0
    116a:	6c02                	ld	s8,0(sp)
    116c:	bf09                	j	107e <vprintf+0x42>
        s = va_arg(ap, char*);
    116e:	008b8993          	addi	s3,s7,8
    1172:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    1176:	02090163          	beqz	s2,1198 <vprintf+0x15c>
        while(*s != 0){
    117a:	00094583          	lbu	a1,0(s2)
    117e:	c9a5                	beqz	a1,11ee <vprintf+0x1b2>
          putc(fd, *s);
    1180:	8556                	mv	a0,s5
    1182:	00000097          	auipc	ra,0x0
    1186:	df0080e7          	jalr	-528(ra) # f72 <putc>
          s++;
    118a:	0905                	addi	s2,s2,1
        while(*s != 0){
    118c:	00094583          	lbu	a1,0(s2)
    1190:	f9e5                	bnez	a1,1180 <vprintf+0x144>
        s = va_arg(ap, char*);
    1192:	8bce                	mv	s7,s3
      state = 0;
    1194:	4981                	li	s3,0
    1196:	b5e5                	j	107e <vprintf+0x42>
          s = "(null)";
    1198:	00000917          	auipc	s2,0x0
    119c:	56090913          	addi	s2,s2,1376 # 16f8 <malloc+0x404>
        while(*s != 0){
    11a0:	02800593          	li	a1,40
    11a4:	bff1                	j	1180 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
    11a6:	008b8913          	addi	s2,s7,8
    11aa:	000bc583          	lbu	a1,0(s7)
    11ae:	8556                	mv	a0,s5
    11b0:	00000097          	auipc	ra,0x0
    11b4:	dc2080e7          	jalr	-574(ra) # f72 <putc>
    11b8:	8bca                	mv	s7,s2
      state = 0;
    11ba:	4981                	li	s3,0
    11bc:	b5c9                	j	107e <vprintf+0x42>
        putc(fd, c);
    11be:	02500593          	li	a1,37
    11c2:	8556                	mv	a0,s5
    11c4:	00000097          	auipc	ra,0x0
    11c8:	dae080e7          	jalr	-594(ra) # f72 <putc>
      state = 0;
    11cc:	4981                	li	s3,0
    11ce:	bd45                	j	107e <vprintf+0x42>
        putc(fd, '%');
    11d0:	02500593          	li	a1,37
    11d4:	8556                	mv	a0,s5
    11d6:	00000097          	auipc	ra,0x0
    11da:	d9c080e7          	jalr	-612(ra) # f72 <putc>
        putc(fd, c);
    11de:	85ca                	mv	a1,s2
    11e0:	8556                	mv	a0,s5
    11e2:	00000097          	auipc	ra,0x0
    11e6:	d90080e7          	jalr	-624(ra) # f72 <putc>
      state = 0;
    11ea:	4981                	li	s3,0
    11ec:	bd49                	j	107e <vprintf+0x42>
        s = va_arg(ap, char*);
    11ee:	8bce                	mv	s7,s3
      state = 0;
    11f0:	4981                	li	s3,0
    11f2:	b571                	j	107e <vprintf+0x42>
    11f4:	74e2                	ld	s1,56(sp)
    11f6:	79a2                	ld	s3,40(sp)
    11f8:	7a02                	ld	s4,32(sp)
    11fa:	6ae2                	ld	s5,24(sp)
    11fc:	6b42                	ld	s6,16(sp)
    11fe:	6ba2                	ld	s7,8(sp)
    }
  }
}
    1200:	60a6                	ld	ra,72(sp)
    1202:	6406                	ld	s0,64(sp)
    1204:	7942                	ld	s2,48(sp)
    1206:	6161                	addi	sp,sp,80
    1208:	8082                	ret

000000000000120a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    120a:	715d                	addi	sp,sp,-80
    120c:	ec06                	sd	ra,24(sp)
    120e:	e822                	sd	s0,16(sp)
    1210:	1000                	addi	s0,sp,32
    1212:	e010                	sd	a2,0(s0)
    1214:	e414                	sd	a3,8(s0)
    1216:	e818                	sd	a4,16(s0)
    1218:	ec1c                	sd	a5,24(s0)
    121a:	03043023          	sd	a6,32(s0)
    121e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1222:	8622                	mv	a2,s0
    1224:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1228:	00000097          	auipc	ra,0x0
    122c:	e14080e7          	jalr	-492(ra) # 103c <vprintf>
}
    1230:	60e2                	ld	ra,24(sp)
    1232:	6442                	ld	s0,16(sp)
    1234:	6161                	addi	sp,sp,80
    1236:	8082                	ret

0000000000001238 <printf>:

void
printf(const char *fmt, ...)
{
    1238:	711d                	addi	sp,sp,-96
    123a:	ec06                	sd	ra,24(sp)
    123c:	e822                	sd	s0,16(sp)
    123e:	1000                	addi	s0,sp,32
    1240:	e40c                	sd	a1,8(s0)
    1242:	e810                	sd	a2,16(s0)
    1244:	ec14                	sd	a3,24(s0)
    1246:	f018                	sd	a4,32(s0)
    1248:	f41c                	sd	a5,40(s0)
    124a:	03043823          	sd	a6,48(s0)
    124e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1252:	00840613          	addi	a2,s0,8
    1256:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    125a:	85aa                	mv	a1,a0
    125c:	4505                	li	a0,1
    125e:	00000097          	auipc	ra,0x0
    1262:	dde080e7          	jalr	-546(ra) # 103c <vprintf>
}
    1266:	60e2                	ld	ra,24(sp)
    1268:	6442                	ld	s0,16(sp)
    126a:	6125                	addi	sp,sp,96
    126c:	8082                	ret

000000000000126e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    126e:	1141                	addi	sp,sp,-16
    1270:	e406                	sd	ra,8(sp)
    1272:	e022                	sd	s0,0(sp)
    1274:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1276:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    127a:	00001797          	auipc	a5,0x1
    127e:	a0e7b783          	ld	a5,-1522(a5) # 1c88 <freep>
    1282:	a039                	j	1290 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1284:	6398                	ld	a4,0(a5)
    1286:	00e7e463          	bltu	a5,a4,128e <free+0x20>
    128a:	00e6ea63          	bltu	a3,a4,129e <free+0x30>
{
    128e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1290:	fed7fae3          	bgeu	a5,a3,1284 <free+0x16>
    1294:	6398                	ld	a4,0(a5)
    1296:	00e6e463          	bltu	a3,a4,129e <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    129a:	fee7eae3          	bltu	a5,a4,128e <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
    129e:	ff852583          	lw	a1,-8(a0)
    12a2:	6390                	ld	a2,0(a5)
    12a4:	02059813          	slli	a6,a1,0x20
    12a8:	01c85713          	srli	a4,a6,0x1c
    12ac:	9736                	add	a4,a4,a3
    12ae:	02e60563          	beq	a2,a4,12d8 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    12b2:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    12b6:	4790                	lw	a2,8(a5)
    12b8:	02061593          	slli	a1,a2,0x20
    12bc:	01c5d713          	srli	a4,a1,0x1c
    12c0:	973e                	add	a4,a4,a5
    12c2:	02e68263          	beq	a3,a4,12e6 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    12c6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    12c8:	00001717          	auipc	a4,0x1
    12cc:	9cf73023          	sd	a5,-1600(a4) # 1c88 <freep>
}
    12d0:	60a2                	ld	ra,8(sp)
    12d2:	6402                	ld	s0,0(sp)
    12d4:	0141                	addi	sp,sp,16
    12d6:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    12d8:	4618                	lw	a4,8(a2)
    12da:	9f2d                	addw	a4,a4,a1
    12dc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    12e0:	6398                	ld	a4,0(a5)
    12e2:	6310                	ld	a2,0(a4)
    12e4:	b7f9                	j	12b2 <free+0x44>
    p->s.size += bp->s.size;
    12e6:	ff852703          	lw	a4,-8(a0)
    12ea:	9f31                	addw	a4,a4,a2
    12ec:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    12ee:	ff053683          	ld	a3,-16(a0)
    12f2:	bfd1                	j	12c6 <free+0x58>

00000000000012f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12f4:	7139                	addi	sp,sp,-64
    12f6:	fc06                	sd	ra,56(sp)
    12f8:	f822                	sd	s0,48(sp)
    12fa:	f04a                	sd	s2,32(sp)
    12fc:	ec4e                	sd	s3,24(sp)
    12fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1300:	02051993          	slli	s3,a0,0x20
    1304:	0209d993          	srli	s3,s3,0x20
    1308:	09bd                	addi	s3,s3,15
    130a:	0049d993          	srli	s3,s3,0x4
    130e:	2985                	addiw	s3,s3,1
    1310:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    1312:	00001517          	auipc	a0,0x1
    1316:	97653503          	ld	a0,-1674(a0) # 1c88 <freep>
    131a:	c905                	beqz	a0,134a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    131c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    131e:	4798                	lw	a4,8(a5)
    1320:	09377a63          	bgeu	a4,s3,13b4 <malloc+0xc0>
    1324:	f426                	sd	s1,40(sp)
    1326:	e852                	sd	s4,16(sp)
    1328:	e456                	sd	s5,8(sp)
    132a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    132c:	8a4e                	mv	s4,s3
    132e:	6705                	lui	a4,0x1
    1330:	00e9f363          	bgeu	s3,a4,1336 <malloc+0x42>
    1334:	6a05                	lui	s4,0x1
    1336:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    133a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    133e:	00001497          	auipc	s1,0x1
    1342:	94a48493          	addi	s1,s1,-1718 # 1c88 <freep>
  if(p == (char*)-1)
    1346:	5afd                	li	s5,-1
    1348:	a089                	j	138a <malloc+0x96>
    134a:	f426                	sd	s1,40(sp)
    134c:	e852                	sd	s4,16(sp)
    134e:	e456                	sd	s5,8(sp)
    1350:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    1352:	00001797          	auipc	a5,0x1
    1356:	d2678793          	addi	a5,a5,-730 # 2078 <base>
    135a:	00001717          	auipc	a4,0x1
    135e:	92f73723          	sd	a5,-1746(a4) # 1c88 <freep>
    1362:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1364:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1368:	b7d1                	j	132c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    136a:	6398                	ld	a4,0(a5)
    136c:	e118                	sd	a4,0(a0)
    136e:	a8b9                	j	13cc <malloc+0xd8>
  hp->s.size = nu;
    1370:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1374:	0541                	addi	a0,a0,16
    1376:	00000097          	auipc	ra,0x0
    137a:	ef8080e7          	jalr	-264(ra) # 126e <free>
  return freep;
    137e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    1380:	c135                	beqz	a0,13e4 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1382:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1384:	4798                	lw	a4,8(a5)
    1386:	03277363          	bgeu	a4,s2,13ac <malloc+0xb8>
    if(p == freep)
    138a:	6098                	ld	a4,0(s1)
    138c:	853e                	mv	a0,a5
    138e:	fef71ae3          	bne	a4,a5,1382 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    1392:	8552                	mv	a0,s4
    1394:	00000097          	auipc	ra,0x0
    1398:	bbe080e7          	jalr	-1090(ra) # f52 <sbrk>
  if(p == (char*)-1)
    139c:	fd551ae3          	bne	a0,s5,1370 <malloc+0x7c>
        return 0;
    13a0:	4501                	li	a0,0
    13a2:	74a2                	ld	s1,40(sp)
    13a4:	6a42                	ld	s4,16(sp)
    13a6:	6aa2                	ld	s5,8(sp)
    13a8:	6b02                	ld	s6,0(sp)
    13aa:	a03d                	j	13d8 <malloc+0xe4>
    13ac:	74a2                	ld	s1,40(sp)
    13ae:	6a42                	ld	s4,16(sp)
    13b0:	6aa2                	ld	s5,8(sp)
    13b2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    13b4:	fae90be3          	beq	s2,a4,136a <malloc+0x76>
        p->s.size -= nunits;
    13b8:	4137073b          	subw	a4,a4,s3
    13bc:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13be:	02071693          	slli	a3,a4,0x20
    13c2:	01c6d713          	srli	a4,a3,0x1c
    13c6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13c8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    13cc:	00001717          	auipc	a4,0x1
    13d0:	8aa73e23          	sd	a0,-1860(a4) # 1c88 <freep>
      return (void*)(p + 1);
    13d4:	01078513          	addi	a0,a5,16
  }
}
    13d8:	70e2                	ld	ra,56(sp)
    13da:	7442                	ld	s0,48(sp)
    13dc:	7902                	ld	s2,32(sp)
    13de:	69e2                	ld	s3,24(sp)
    13e0:	6121                	addi	sp,sp,64
    13e2:	8082                	ret
    13e4:	74a2                	ld	s1,40(sp)
    13e6:	6a42                	ld	s4,16(sp)
    13e8:	6aa2                	ld	s5,8(sp)
    13ea:	6b02                	ld	s6,0(sp)
    13ec:	b7f5                	j	13d8 <malloc+0xe4>
