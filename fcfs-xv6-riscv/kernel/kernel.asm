
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	1b013103          	ld	sp,432(sp) # 8000b1b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000024:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000028:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037961b          	slliw	a2,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	963a                	add	a2,a2,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f46b7          	lui	a3,0xf4
    80000040:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9736                	add	a4,a4,a3
    80000046:	e218                	sd	a4,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00279713          	slli	a4,a5,0x2
    8000004c:	973e                	add	a4,a4,a5
    8000004e:	070e                	slli	a4,a4,0x3
    80000050:	0000c797          	auipc	a5,0xc
    80000054:	ff078793          	addi	a5,a5,-16 # 8000c040 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	f7e78793          	addi	a5,a5,-130 # 80005fe0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	60a2                	ld	ra,8(sp)
    80000088:	6402                	ld	s0,0(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd57ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e5878793          	addi	a5,a5,-424 # 80000f06 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	711d                	addi	sp,sp,-96
    80000104:	ec86                	sd	ra,88(sp)
    80000106:	e8a2                	sd	s0,80(sp)
    80000108:	e0ca                	sd	s2,64(sp)
    8000010a:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    8000010c:	04c05b63          	blez	a2,80000162 <consolewrite+0x60>
    80000110:	e4a6                	sd	s1,72(sp)
    80000112:	fc4e                	sd	s3,56(sp)
    80000114:	f852                	sd	s4,48(sp)
    80000116:	f456                	sd	s5,40(sp)
    80000118:	f05a                	sd	s6,32(sp)
    8000011a:	ec5e                	sd	s7,24(sp)
    8000011c:	8a2a                	mv	s4,a0
    8000011e:	84ae                	mv	s1,a1
    80000120:	89b2                	mv	s3,a2
    80000122:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000124:	faf40b93          	addi	s7,s0,-81
    80000128:	4b05                	li	s6,1
    8000012a:	5afd                	li	s5,-1
    8000012c:	86da                	mv	a3,s6
    8000012e:	8626                	mv	a2,s1
    80000130:	85d2                	mv	a1,s4
    80000132:	855e                	mv	a0,s7
    80000134:	00002097          	auipc	ra,0x2
    80000138:	60c080e7          	jalr	1548(ra) # 80002740 <either_copyin>
    8000013c:	03550563          	beq	a0,s5,80000166 <consolewrite+0x64>
      break;
    uartputc(c);
    80000140:	faf44503          	lbu	a0,-81(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	7d0080e7          	jalr	2000(ra) # 80000914 <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299ee3          	bne	s3,s2,8000012c <consolewrite+0x2a>
    80000154:	64a6                	ld	s1,72(sp)
    80000156:	79e2                	ld	s3,56(sp)
    80000158:	7a42                	ld	s4,48(sp)
    8000015a:	7aa2                	ld	s5,40(sp)
    8000015c:	7b02                	ld	s6,32(sp)
    8000015e:	6be2                	ld	s7,24(sp)
    80000160:	a809                	j	80000172 <consolewrite+0x70>
    80000162:	4901                	li	s2,0
    80000164:	a039                	j	80000172 <consolewrite+0x70>
    80000166:	64a6                	ld	s1,72(sp)
    80000168:	79e2                	ld	s3,56(sp)
    8000016a:	7a42                	ld	s4,48(sp)
    8000016c:	7aa2                	ld	s5,40(sp)
    8000016e:	7b02                	ld	s6,32(sp)
    80000170:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    80000172:	854a                	mv	a0,s2
    80000174:	60e6                	ld	ra,88(sp)
    80000176:	6446                	ld	s0,80(sp)
    80000178:	6906                	ld	s2,64(sp)
    8000017a:	6125                	addi	sp,sp,96
    8000017c:	8082                	ret

000000008000017e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000017e:	711d                	addi	sp,sp,-96
    80000180:	ec86                	sd	ra,88(sp)
    80000182:	e8a2                	sd	s0,80(sp)
    80000184:	e4a6                	sd	s1,72(sp)
    80000186:	e0ca                	sd	s2,64(sp)
    80000188:	fc4e                	sd	s3,56(sp)
    8000018a:	f852                	sd	s4,48(sp)
    8000018c:	f05a                	sd	s6,32(sp)
    8000018e:	ec5e                	sd	s7,24(sp)
    80000190:	1080                	addi	s0,sp,96
    80000192:	8b2a                	mv	s6,a0
    80000194:	8a2e                	mv	s4,a1
    80000196:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000198:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    8000019a:	00014517          	auipc	a0,0x14
    8000019e:	fe650513          	addi	a0,a0,-26 # 80014180 <cons>
    800001a2:	00001097          	auipc	ra,0x1
    800001a6:	ab2080e7          	jalr	-1358(ra) # 80000c54 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001aa:	00014497          	auipc	s1,0x14
    800001ae:	fd648493          	addi	s1,s1,-42 # 80014180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b2:	00014917          	auipc	s2,0x14
    800001b6:	06690913          	addi	s2,s2,102 # 80014218 <cons+0x98>
  while(n > 0){
    800001ba:	0d305263          	blez	s3,8000027e <consoleread+0x100>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	0af71763          	bne	a4,a5,80000274 <consoleread+0xf6>
      if(myproc()->killed){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	8b0080e7          	jalr	-1872(ra) # 80001a7a <myproc>
    800001d2:	551c                	lw	a5,40(a0)
    800001d4:	e7ad                	bnez	a5,8000023e <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	01c080e7          	jalr	28(ra) # 800021f6 <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fef700e3          	beq	a4,a5,800001ca <consoleread+0x4c>
    800001ee:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f0:	00014717          	auipc	a4,0x14
    800001f4:	f9070713          	addi	a4,a4,-112 # 80014180 <cons>
    800001f8:	0017869b          	addiw	a3,a5,1
    800001fc:	08d72c23          	sw	a3,152(a4)
    80000200:	07f7f693          	andi	a3,a5,127
    80000204:	9736                	add	a4,a4,a3
    80000206:	01874703          	lbu	a4,24(a4)
    8000020a:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    8000020e:	4691                	li	a3,4
    80000210:	04da8a63          	beq	s5,a3,80000264 <consoleread+0xe6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000214:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000218:	4685                	li	a3,1
    8000021a:	faf40613          	addi	a2,s0,-81
    8000021e:	85d2                	mv	a1,s4
    80000220:	855a                	mv	a0,s6
    80000222:	00002097          	auipc	ra,0x2
    80000226:	4c8080e7          	jalr	1224(ra) # 800026ea <either_copyout>
    8000022a:	57fd                	li	a5,-1
    8000022c:	04f50863          	beq	a0,a5,8000027c <consoleread+0xfe>
      break;

    dst++;
    80000230:	0a05                	addi	s4,s4,1
    --n;
    80000232:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000234:	47a9                	li	a5,10
    80000236:	04fa8f63          	beq	s5,a5,80000294 <consoleread+0x116>
    8000023a:	7aa2                	ld	s5,40(sp)
    8000023c:	bfbd                	j	800001ba <consoleread+0x3c>
        release(&cons.lock);
    8000023e:	00014517          	auipc	a0,0x14
    80000242:	f4250513          	addi	a0,a0,-190 # 80014180 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	abe080e7          	jalr	-1346(ra) # 80000d04 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7b02                	ld	s6,32(sp)
    8000025e:	6be2                	ld	s7,24(sp)
    80000260:	6125                	addi	sp,sp,96
    80000262:	8082                	ret
      if(n < target){
    80000264:	0179fa63          	bgeu	s3,s7,80000278 <consoleread+0xfa>
        cons.r--;
    80000268:	00014717          	auipc	a4,0x14
    8000026c:	faf72823          	sw	a5,-80(a4) # 80014218 <cons+0x98>
    80000270:	7aa2                	ld	s5,40(sp)
    80000272:	a031                	j	8000027e <consoleread+0x100>
    80000274:	f456                	sd	s5,40(sp)
    80000276:	bfad                	j	800001f0 <consoleread+0x72>
    80000278:	7aa2                	ld	s5,40(sp)
    8000027a:	a011                	j	8000027e <consoleread+0x100>
    8000027c:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    8000027e:	00014517          	auipc	a0,0x14
    80000282:	f0250513          	addi	a0,a0,-254 # 80014180 <cons>
    80000286:	00001097          	auipc	ra,0x1
    8000028a:	a7e080e7          	jalr	-1410(ra) # 80000d04 <release>
  return target - n;
    8000028e:	413b853b          	subw	a0,s7,s3
    80000292:	bf7d                	j	80000250 <consoleread+0xd2>
    80000294:	7aa2                	ld	s5,40(sp)
    80000296:	b7e5                	j	8000027e <consoleread+0x100>

0000000080000298 <consputc>:
{
    80000298:	1141                	addi	sp,sp,-16
    8000029a:	e406                	sd	ra,8(sp)
    8000029c:	e022                	sd	s0,0(sp)
    8000029e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a0:	10000793          	li	a5,256
    800002a4:	00f50a63          	beq	a0,a5,800002b8 <consputc+0x20>
    uartputc_sync(c);
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	58e080e7          	jalr	1422(ra) # 80000836 <uartputc_sync>
}
    800002b0:	60a2                	ld	ra,8(sp)
    800002b2:	6402                	ld	s0,0(sp)
    800002b4:	0141                	addi	sp,sp,16
    800002b6:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	57c080e7          	jalr	1404(ra) # 80000836 <uartputc_sync>
    800002c2:	02000513          	li	a0,32
    800002c6:	00000097          	auipc	ra,0x0
    800002ca:	570080e7          	jalr	1392(ra) # 80000836 <uartputc_sync>
    800002ce:	4521                	li	a0,8
    800002d0:	00000097          	auipc	ra,0x0
    800002d4:	566080e7          	jalr	1382(ra) # 80000836 <uartputc_sync>
    800002d8:	bfe1                	j	800002b0 <consputc+0x18>

00000000800002da <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002da:	1101                	addi	sp,sp,-32
    800002dc:	ec06                	sd	ra,24(sp)
    800002de:	e822                	sd	s0,16(sp)
    800002e0:	e426                	sd	s1,8(sp)
    800002e2:	1000                	addi	s0,sp,32
    800002e4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e6:	00014517          	auipc	a0,0x14
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80014180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	966080e7          	jalr	-1690(ra) # 80000c54 <acquire>

  switch(c){
    800002f6:	47d5                	li	a5,21
    800002f8:	0af48263          	beq	s1,a5,8000039c <consoleintr+0xc2>
    800002fc:	0297c963          	blt	a5,s1,8000032e <consoleintr+0x54>
    80000300:	47a1                	li	a5,8
    80000302:	0ef48963          	beq	s1,a5,800003f4 <consoleintr+0x11a>
    80000306:	47c1                	li	a5,16
    80000308:	10f49c63          	bne	s1,a5,80000420 <consoleintr+0x146>
  case C('P'):  // Print process list.
    procdump();
    8000030c:	00002097          	auipc	ra,0x2
    80000310:	48a080e7          	jalr	1162(ra) # 80002796 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000314:	00014517          	auipc	a0,0x14
    80000318:	e6c50513          	addi	a0,a0,-404 # 80014180 <cons>
    8000031c:	00001097          	auipc	ra,0x1
    80000320:	9e8080e7          	jalr	-1560(ra) # 80000d04 <release>
}
    80000324:	60e2                	ld	ra,24(sp)
    80000326:	6442                	ld	s0,16(sp)
    80000328:	64a2                	ld	s1,8(sp)
    8000032a:	6105                	addi	sp,sp,32
    8000032c:	8082                	ret
  switch(c){
    8000032e:	07f00793          	li	a5,127
    80000332:	0cf48163          	beq	s1,a5,800003f4 <consoleintr+0x11a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000336:	00014717          	auipc	a4,0x14
    8000033a:	e4a70713          	addi	a4,a4,-438 # 80014180 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09872703          	lw	a4,152(a4)
    80000346:	9f99                	subw	a5,a5,a4
    80000348:	07f00713          	li	a4,127
    8000034c:	fcf764e3          	bltu	a4,a5,80000314 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000350:	47b5                	li	a5,13
    80000352:	0cf48a63          	beq	s1,a5,80000426 <consoleintr+0x14c>
      consputc(c);
    80000356:	8526                	mv	a0,s1
    80000358:	00000097          	auipc	ra,0x0
    8000035c:	f40080e7          	jalr	-192(ra) # 80000298 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000360:	00014717          	auipc	a4,0x14
    80000364:	e2070713          	addi	a4,a4,-480 # 80014180 <cons>
    80000368:	0a072683          	lw	a3,160(a4)
    8000036c:	0016879b          	addiw	a5,a3,1
    80000370:	863e                	mv	a2,a5
    80000372:	0af72023          	sw	a5,160(a4)
    80000376:	07f6f693          	andi	a3,a3,127
    8000037a:	9736                	add	a4,a4,a3
    8000037c:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000380:	ff648713          	addi	a4,s1,-10
    80000384:	c779                	beqz	a4,80000452 <consoleintr+0x178>
    80000386:	14f1                	addi	s1,s1,-4
    80000388:	c4e9                	beqz	s1,80000452 <consoleintr+0x178>
    8000038a:	00014797          	auipc	a5,0x14
    8000038e:	e8e7a783          	lw	a5,-370(a5) # 80014218 <cons+0x98>
    80000392:	0807879b          	addiw	a5,a5,128
    80000396:	f6f61fe3          	bne	a2,a5,80000314 <consoleintr+0x3a>
    8000039a:	a865                	j	80000452 <consoleintr+0x178>
    8000039c:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000039e:	00014717          	auipc	a4,0x14
    800003a2:	de270713          	addi	a4,a4,-542 # 80014180 <cons>
    800003a6:	0a072783          	lw	a5,160(a4)
    800003aa:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ae:	00014497          	auipc	s1,0x14
    800003b2:	dd248493          	addi	s1,s1,-558 # 80014180 <cons>
    while(cons.e != cons.w &&
    800003b6:	4929                	li	s2,10
    800003b8:	02f70a63          	beq	a4,a5,800003ec <consoleintr+0x112>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003bc:	37fd                	addiw	a5,a5,-1
    800003be:	07f7f713          	andi	a4,a5,127
    800003c2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c4:	01874703          	lbu	a4,24(a4)
    800003c8:	03270463          	beq	a4,s2,800003f0 <consoleintr+0x116>
      cons.e--;
    800003cc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d0:	10000513          	li	a0,256
    800003d4:	00000097          	auipc	ra,0x0
    800003d8:	ec4080e7          	jalr	-316(ra) # 80000298 <consputc>
    while(cons.e != cons.w &&
    800003dc:	0a04a783          	lw	a5,160(s1)
    800003e0:	09c4a703          	lw	a4,156(s1)
    800003e4:	fcf71ce3          	bne	a4,a5,800003bc <consoleintr+0xe2>
    800003e8:	6902                	ld	s2,0(sp)
    800003ea:	b72d                	j	80000314 <consoleintr+0x3a>
    800003ec:	6902                	ld	s2,0(sp)
    800003ee:	b71d                	j	80000314 <consoleintr+0x3a>
    800003f0:	6902                	ld	s2,0(sp)
    800003f2:	b70d                	j	80000314 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f4:	00014717          	auipc	a4,0x14
    800003f8:	d8c70713          	addi	a4,a4,-628 # 80014180 <cons>
    800003fc:	0a072783          	lw	a5,160(a4)
    80000400:	09c72703          	lw	a4,156(a4)
    80000404:	f0f708e3          	beq	a4,a5,80000314 <consoleintr+0x3a>
      cons.e--;
    80000408:	37fd                	addiw	a5,a5,-1
    8000040a:	00014717          	auipc	a4,0x14
    8000040e:	e0f72b23          	sw	a5,-490(a4) # 80014220 <cons+0xa0>
      consputc(BACKSPACE);
    80000412:	10000513          	li	a0,256
    80000416:	00000097          	auipc	ra,0x0
    8000041a:	e82080e7          	jalr	-382(ra) # 80000298 <consputc>
    8000041e:	bddd                	j	80000314 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000420:	ee048ae3          	beqz	s1,80000314 <consoleintr+0x3a>
    80000424:	bf09                	j	80000336 <consoleintr+0x5c>
      consputc(c);
    80000426:	4529                	li	a0,10
    80000428:	00000097          	auipc	ra,0x0
    8000042c:	e70080e7          	jalr	-400(ra) # 80000298 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000430:	00014717          	auipc	a4,0x14
    80000434:	d5070713          	addi	a4,a4,-688 # 80014180 <cons>
    80000438:	0a072683          	lw	a3,160(a4)
    8000043c:	0016861b          	addiw	a2,a3,1
    80000440:	87b2                	mv	a5,a2
    80000442:	0ac72023          	sw	a2,160(a4)
    80000446:	07f6f693          	andi	a3,a3,127
    8000044a:	9736                	add	a4,a4,a3
    8000044c:	46a9                	li	a3,10
    8000044e:	00d70c23          	sb	a3,24(a4)
        cons.w = cons.e;
    80000452:	00014717          	auipc	a4,0x14
    80000456:	dcf72523          	sw	a5,-566(a4) # 8001421c <cons+0x9c>
        wakeup(&cons.r);
    8000045a:	00014517          	auipc	a0,0x14
    8000045e:	dbe50513          	addi	a0,a0,-578 # 80014218 <cons+0x98>
    80000462:	00002097          	auipc	ra,0x2
    80000466:	060080e7          	jalr	96(ra) # 800024c2 <wakeup>
    8000046a:	b56d                	j	80000314 <consoleintr+0x3a>

000000008000046c <consoleinit>:

void
consoleinit(void)
{
    8000046c:	1141                	addi	sp,sp,-16
    8000046e:	e406                	sd	ra,8(sp)
    80000470:	e022                	sd	s0,0(sp)
    80000472:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000474:	00008597          	auipc	a1,0x8
    80000478:	b8c58593          	addi	a1,a1,-1140 # 80008000 <etext>
    8000047c:	00014517          	auipc	a0,0x14
    80000480:	d0450513          	addi	a0,a0,-764 # 80014180 <cons>
    80000484:	00000097          	auipc	ra,0x0
    80000488:	736080e7          	jalr	1846(ra) # 80000bba <initlock>

  uartinit();
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	350080e7          	jalr	848(ra) # 800007dc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000494:	00024797          	auipc	a5,0x24
    80000498:	28478793          	addi	a5,a5,644 # 80024718 <devsw>
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	ce270713          	addi	a4,a4,-798 # 8000017e <consoleread>
    800004a4:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a6:	00000717          	auipc	a4,0x0
    800004aa:	c5c70713          	addi	a4,a4,-932 # 80000102 <consolewrite>
    800004ae:	ef98                	sd	a4,24(a5)
}
    800004b0:	60a2                	ld	ra,8(sp)
    800004b2:	6402                	ld	s0,0(sp)
    800004b4:	0141                	addi	sp,sp,16
    800004b6:	8082                	ret

00000000800004b8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004b8:	7179                	addi	sp,sp,-48
    800004ba:	f406                	sd	ra,40(sp)
    800004bc:	f022                	sd	s0,32(sp)
    800004be:	e84a                	sd	s2,16(sp)
    800004c0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c2:	c219                	beqz	a2,800004c8 <printint+0x10>
    800004c4:	08054563          	bltz	a0,8000054e <printint+0x96>
    x = -xx;
  else
    x = xx;
    800004c8:	4301                	li	t1,0

  i = 0;
    800004ca:	fd040913          	addi	s2,s0,-48
    x = xx;
    800004ce:	86ca                	mv	a3,s2
  i = 0;
    800004d0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d2:	00008817          	auipc	a6,0x8
    800004d6:	24680813          	addi	a6,a6,582 # 80008718 <digits>
    800004da:	88ba                	mv	a7,a4
    800004dc:	0017061b          	addiw	a2,a4,1
    800004e0:	8732                	mv	a4,a2
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97c2                	add	a5,a5,a6
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	87aa                	mv	a5,a0
    800004f6:	02b5553b          	divuw	a0,a0,a1
    800004fa:	0685                	addi	a3,a3,1
    800004fc:	fcb7ffe3          	bgeu	a5,a1,800004da <printint+0x22>

  if(sign)
    80000500:	00030c63          	beqz	t1,80000518 <printint+0x60>
    buf[i++] = '-';
    80000504:	fe060793          	addi	a5,a2,-32
    80000508:	00878633          	add	a2,a5,s0
    8000050c:	02d00793          	li	a5,45
    80000510:	fef60823          	sb	a5,-16(a2)
    80000514:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    80000518:	02e05663          	blez	a4,80000544 <printint+0x8c>
    8000051c:	ec26                	sd	s1,24(sp)
    8000051e:	377d                	addiw	a4,a4,-1
    80000520:	00e904b3          	add	s1,s2,a4
    80000524:	197d                	addi	s2,s2,-1
    80000526:	993a                	add	s2,s2,a4
    80000528:	1702                	slli	a4,a4,0x20
    8000052a:	9301                	srli	a4,a4,0x20
    8000052c:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000530:	0004c503          	lbu	a0,0(s1)
    80000534:	00000097          	auipc	ra,0x0
    80000538:	d64080e7          	jalr	-668(ra) # 80000298 <consputc>
  while(--i >= 0)
    8000053c:	14fd                	addi	s1,s1,-1
    8000053e:	ff2499e3          	bne	s1,s2,80000530 <printint+0x78>
    80000542:	64e2                	ld	s1,24(sp)
}
    80000544:	70a2                	ld	ra,40(sp)
    80000546:	7402                	ld	s0,32(sp)
    80000548:	6942                	ld	s2,16(sp)
    8000054a:	6145                	addi	sp,sp,48
    8000054c:	8082                	ret
    x = -xx;
    8000054e:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000552:	4305                	li	t1,1
    x = -xx;
    80000554:	bf9d                	j	800004ca <printint+0x12>

0000000080000556 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000556:	1101                	addi	sp,sp,-32
    80000558:	ec06                	sd	ra,24(sp)
    8000055a:	e822                	sd	s0,16(sp)
    8000055c:	e426                	sd	s1,8(sp)
    8000055e:	1000                	addi	s0,sp,32
    80000560:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000562:	00014797          	auipc	a5,0x14
    80000566:	cc07af23          	sw	zero,-802(a5) # 80014240 <pr+0x18>
  printf("panic: ");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	a9e50513          	addi	a0,a0,-1378 # 80008008 <etext+0x8>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	02e080e7          	jalr	46(ra) # 800005a0 <printf>
  printf(s);
    8000057a:	8526                	mv	a0,s1
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	024080e7          	jalr	36(ra) # 800005a0 <printf>
  printf("\n");
    80000584:	00008517          	auipc	a0,0x8
    80000588:	a8c50513          	addi	a0,a0,-1396 # 80008010 <etext+0x10>
    8000058c:	00000097          	auipc	ra,0x0
    80000590:	014080e7          	jalr	20(ra) # 800005a0 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000594:	4785                	li	a5,1
    80000596:	0000c717          	auipc	a4,0xc
    8000059a:	a6f72523          	sw	a5,-1430(a4) # 8000c000 <panicked>
  for(;;)
    8000059e:	a001                	j	8000059e <panic+0x48>

00000000800005a0 <printf>:
{
    800005a0:	7131                	addi	sp,sp,-192
    800005a2:	fc86                	sd	ra,120(sp)
    800005a4:	f8a2                	sd	s0,112(sp)
    800005a6:	e8d2                	sd	s4,80(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00014d97          	auipc	s11,0x14
    800005c4:	c80dad83          	lw	s11,-896(s11) # 80014240 <pr+0x18>
  if(locking)
    800005c8:	040d9463          	bnez	s11,80000610 <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0b63          	beqz	s4,80000622 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	18050c63          	beqz	a0,80000774 <printf+0x1d4>
    800005e0:	f4a6                	sd	s1,104(sp)
    800005e2:	f0ca                	sd	s2,96(sp)
    800005e4:	ecce                	sd	s3,88(sp)
    800005e6:	e4d6                	sd	s5,72(sp)
    800005e8:	e0da                	sd	s6,64(sp)
    800005ea:	fc5e                	sd	s7,56(sp)
    800005ec:	f862                	sd	s8,48(sp)
    800005ee:	f466                	sd	s9,40(sp)
    800005f0:	f06a                	sd	s10,32(sp)
    800005f2:	4981                	li	s3,0
    if(c != '%'){
    800005f4:	02500b13          	li	s6,37
    switch(c){
    800005f8:	07000b93          	li	s7,112
  consputc('x');
    800005fc:	07800c93          	li	s9,120
    80000600:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000602:	00008a97          	auipc	s5,0x8
    80000606:	116a8a93          	addi	s5,s5,278 # 80008718 <digits>
    switch(c){
    8000060a:	07300c13          	li	s8,115
    8000060e:	a0b9                	j	8000065c <printf+0xbc>
    acquire(&pr.lock);
    80000610:	00014517          	auipc	a0,0x14
    80000614:	c1850513          	addi	a0,a0,-1000 # 80014228 <pr>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	63c080e7          	jalr	1596(ra) # 80000c54 <acquire>
    80000620:	b775                	j	800005cc <printf+0x2c>
    80000622:	f4a6                	sd	s1,104(sp)
    80000624:	f0ca                	sd	s2,96(sp)
    80000626:	ecce                	sd	s3,88(sp)
    80000628:	e4d6                	sd	s5,72(sp)
    8000062a:	e0da                	sd	s6,64(sp)
    8000062c:	fc5e                	sd	s7,56(sp)
    8000062e:	f862                	sd	s8,48(sp)
    80000630:	f466                	sd	s9,40(sp)
    80000632:	f06a                	sd	s10,32(sp)
    panic("null fmt");
    80000634:	00008517          	auipc	a0,0x8
    80000638:	9ec50513          	addi	a0,a0,-1556 # 80008020 <etext+0x20>
    8000063c:	00000097          	auipc	ra,0x0
    80000640:	f1a080e7          	jalr	-230(ra) # 80000556 <panic>
      consputc(c);
    80000644:	00000097          	auipc	ra,0x0
    80000648:	c54080e7          	jalr	-940(ra) # 80000298 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000064c:	0019879b          	addiw	a5,s3,1
    80000650:	89be                	mv	s3,a5
    80000652:	97d2                	add	a5,a5,s4
    80000654:	0007c503          	lbu	a0,0(a5)
    80000658:	10050563          	beqz	a0,80000762 <printf+0x1c2>
    if(c != '%'){
    8000065c:	ff6514e3          	bne	a0,s6,80000644 <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000660:	0019879b          	addiw	a5,s3,1
    80000664:	89be                	mv	s3,a5
    80000666:	97d2                	add	a5,a5,s4
    80000668:	0007c783          	lbu	a5,0(a5)
    8000066c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000670:	10078a63          	beqz	a5,80000784 <printf+0x1e4>
    switch(c){
    80000674:	05778a63          	beq	a5,s7,800006c8 <printf+0x128>
    80000678:	02fbf463          	bgeu	s7,a5,800006a0 <printf+0x100>
    8000067c:	09878763          	beq	a5,s8,8000070a <printf+0x16a>
    80000680:	0d979663          	bne	a5,s9,8000074c <printf+0x1ac>
      printint(va_arg(ap, int), 16, 1);
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	4605                	li	a2,1
    80000692:	85ea                	mv	a1,s10
    80000694:	4388                	lw	a0,0(a5)
    80000696:	00000097          	auipc	ra,0x0
    8000069a:	e22080e7          	jalr	-478(ra) # 800004b8 <printint>
      break;
    8000069e:	b77d                	j	8000064c <printf+0xac>
    switch(c){
    800006a0:	0b678063          	beq	a5,s6,80000740 <printf+0x1a0>
    800006a4:	06400713          	li	a4,100
    800006a8:	0ae79263          	bne	a5,a4,8000074c <printf+0x1ac>
      printint(va_arg(ap, int), 10, 1);
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	4605                	li	a2,1
    800006ba:	45a9                	li	a1,10
    800006bc:	4388                	lw	a0,0(a5)
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	dfa080e7          	jalr	-518(ra) # 800004b8 <printint>
      break;
    800006c6:	b759                	j	8000064c <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006d8:	03000513          	li	a0,48
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	bbc080e7          	jalr	-1092(ra) # 80000298 <consputc>
  consputc('x');
    800006e4:	8566                	mv	a0,s9
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	bb2080e7          	jalr	-1102(ra) # 80000298 <consputc>
    800006ee:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f0:	03c95793          	srli	a5,s2,0x3c
    800006f4:	97d6                	add	a5,a5,s5
    800006f6:	0007c503          	lbu	a0,0(a5)
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	b9e080e7          	jalr	-1122(ra) # 80000298 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0912                	slli	s2,s2,0x4
    80000704:	34fd                	addiw	s1,s1,-1
    80000706:	f4ed                	bnez	s1,800006f0 <printf+0x150>
    80000708:	b791                	j	8000064c <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    8000070a:	f8843783          	ld	a5,-120(s0)
    8000070e:	00878713          	addi	a4,a5,8
    80000712:	f8e43423          	sd	a4,-120(s0)
    80000716:	6384                	ld	s1,0(a5)
    80000718:	cc89                	beqz	s1,80000732 <printf+0x192>
      for(; *s; s++)
    8000071a:	0004c503          	lbu	a0,0(s1)
    8000071e:	d51d                	beqz	a0,8000064c <printf+0xac>
        consputc(*s);
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b78080e7          	jalr	-1160(ra) # 80000298 <consputc>
      for(; *s; s++)
    80000728:	0485                	addi	s1,s1,1
    8000072a:	0004c503          	lbu	a0,0(s1)
    8000072e:	f96d                	bnez	a0,80000720 <printf+0x180>
    80000730:	bf31                	j	8000064c <printf+0xac>
        s = "(null)";
    80000732:	00008497          	auipc	s1,0x8
    80000736:	8e648493          	addi	s1,s1,-1818 # 80008018 <etext+0x18>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7cd                	j	80000720 <printf+0x180>
      consputc('%');
    80000740:	855a                	mv	a0,s6
    80000742:	00000097          	auipc	ra,0x0
    80000746:	b56080e7          	jalr	-1194(ra) # 80000298 <consputc>
      break;
    8000074a:	b709                	j	8000064c <printf+0xac>
      consputc('%');
    8000074c:	855a                	mv	a0,s6
    8000074e:	00000097          	auipc	ra,0x0
    80000752:	b4a080e7          	jalr	-1206(ra) # 80000298 <consputc>
      consputc(c);
    80000756:	8526                	mv	a0,s1
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	b40080e7          	jalr	-1216(ra) # 80000298 <consputc>
      break;
    80000760:	b5f5                	j	8000064c <printf+0xac>
    80000762:	74a6                	ld	s1,104(sp)
    80000764:	7906                	ld	s2,96(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6aa6                	ld	s5,72(sp)
    8000076a:	6b06                	ld	s6,64(sp)
    8000076c:	7be2                	ld	s7,56(sp)
    8000076e:	7c42                	ld	s8,48(sp)
    80000770:	7ca2                	ld	s9,40(sp)
    80000772:	7d02                	ld	s10,32(sp)
  if(locking)
    80000774:	020d9263          	bnez	s11,80000798 <printf+0x1f8>
}
    80000778:	70e6                	ld	ra,120(sp)
    8000077a:	7446                	ld	s0,112(sp)
    8000077c:	6a46                	ld	s4,80(sp)
    8000077e:	6de2                	ld	s11,24(sp)
    80000780:	6129                	addi	sp,sp,192
    80000782:	8082                	ret
    80000784:	74a6                	ld	s1,104(sp)
    80000786:	7906                	ld	s2,96(sp)
    80000788:	69e6                	ld	s3,88(sp)
    8000078a:	6aa6                	ld	s5,72(sp)
    8000078c:	6b06                	ld	s6,64(sp)
    8000078e:	7be2                	ld	s7,56(sp)
    80000790:	7c42                	ld	s8,48(sp)
    80000792:	7ca2                	ld	s9,40(sp)
    80000794:	7d02                	ld	s10,32(sp)
    80000796:	bff9                	j	80000774 <printf+0x1d4>
    release(&pr.lock);
    80000798:	00014517          	auipc	a0,0x14
    8000079c:	a9050513          	addi	a0,a0,-1392 # 80014228 <pr>
    800007a0:	00000097          	auipc	ra,0x0
    800007a4:	564080e7          	jalr	1380(ra) # 80000d04 <release>
}
    800007a8:	bfc1                	j	80000778 <printf+0x1d8>

00000000800007aa <printfinit>:
    ;
}

void
printfinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007b2:	00008597          	auipc	a1,0x8
    800007b6:	87e58593          	addi	a1,a1,-1922 # 80008030 <etext+0x30>
    800007ba:	00014517          	auipc	a0,0x14
    800007be:	a6e50513          	addi	a0,a0,-1426 # 80014228 <pr>
    800007c2:	00000097          	auipc	ra,0x0
    800007c6:	3f8080e7          	jalr	1016(ra) # 80000bba <initlock>
  pr.locking = 1;
    800007ca:	4785                	li	a5,1
    800007cc:	00014717          	auipc	a4,0x14
    800007d0:	a6f72a23          	sw	a5,-1420(a4) # 80014240 <pr+0x18>
}
    800007d4:	60a2                	ld	ra,8(sp)
    800007d6:	6402                	ld	s0,0(sp)
    800007d8:	0141                	addi	sp,sp,16
    800007da:	8082                	ret

00000000800007dc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007dc:	1141                	addi	sp,sp,-16
    800007de:	e406                	sd	ra,8(sp)
    800007e0:	e022                	sd	s0,0(sp)
    800007e2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007e4:	100007b7          	lui	a5,0x10000
    800007e8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ec:	10000737          	lui	a4,0x10000
    800007f0:	f8000693          	li	a3,-128
    800007f4:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007f8:	468d                	li	a3,3
    800007fa:	10000637          	lui	a2,0x10000
    800007fe:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000802:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000806:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000080a:	8732                	mv	a4,a2
    8000080c:	461d                	li	a2,7
    8000080e:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000812:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000816:	00008597          	auipc	a1,0x8
    8000081a:	82258593          	addi	a1,a1,-2014 # 80008038 <etext+0x38>
    8000081e:	00014517          	auipc	a0,0x14
    80000822:	a2a50513          	addi	a0,a0,-1494 # 80014248 <uart_tx_lock>
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	394080e7          	jalr	916(ra) # 80000bba <initlock>
}
    8000082e:	60a2                	ld	ra,8(sp)
    80000830:	6402                	ld	s0,0(sp)
    80000832:	0141                	addi	sp,sp,16
    80000834:	8082                	ret

0000000080000836 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000836:	1101                	addi	sp,sp,-32
    80000838:	ec06                	sd	ra,24(sp)
    8000083a:	e822                	sd	s0,16(sp)
    8000083c:	e426                	sd	s1,8(sp)
    8000083e:	1000                	addi	s0,sp,32
    80000840:	84aa                	mv	s1,a0
  push_off();
    80000842:	00000097          	auipc	ra,0x0
    80000846:	3c2080e7          	jalr	962(ra) # 80000c04 <push_off>

  if(panicked){
    8000084a:	0000b797          	auipc	a5,0xb
    8000084e:	7b67a783          	lw	a5,1974(a5) # 8000c000 <panicked>
    80000852:	eb85                	bnez	a5,80000882 <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000854:	10000737          	lui	a4,0x10000
    80000858:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000085a:	00074783          	lbu	a5,0(a4)
    8000085e:	0207f793          	andi	a5,a5,32
    80000862:	dfe5                	beqz	a5,8000085a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000864:	0ff4f513          	zext.b	a0,s1
    80000868:	100007b7          	lui	a5,0x10000
    8000086c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000870:	00000097          	auipc	ra,0x0
    80000874:	438080e7          	jalr	1080(ra) # 80000ca8 <pop_off>
}
    80000878:	60e2                	ld	ra,24(sp)
    8000087a:	6442                	ld	s0,16(sp)
    8000087c:	64a2                	ld	s1,8(sp)
    8000087e:	6105                	addi	sp,sp,32
    80000880:	8082                	ret
    for(;;)
    80000882:	a001                	j	80000882 <uartputc_sync+0x4c>

0000000080000884 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000884:	0000b797          	auipc	a5,0xb
    80000888:	7847b783          	ld	a5,1924(a5) # 8000c008 <uart_tx_r>
    8000088c:	0000b717          	auipc	a4,0xb
    80000890:	78473703          	ld	a4,1924(a4) # 8000c010 <uart_tx_w>
    80000894:	06f70f63          	beq	a4,a5,80000912 <uartstart+0x8e>
{
    80000898:	7139                	addi	sp,sp,-64
    8000089a:	fc06                	sd	ra,56(sp)
    8000089c:	f822                	sd	s0,48(sp)
    8000089e:	f426                	sd	s1,40(sp)
    800008a0:	f04a                	sd	s2,32(sp)
    800008a2:	ec4e                	sd	s3,24(sp)
    800008a4:	e852                	sd	s4,16(sp)
    800008a6:	e456                	sd	s5,8(sp)
    800008a8:	e05a                	sd	s6,0(sp)
    800008aa:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ac:	10000937          	lui	s2,0x10000
    800008b0:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008b2:	00014a97          	auipc	s5,0x14
    800008b6:	996a8a93          	addi	s5,s5,-1642 # 80014248 <uart_tx_lock>
    uart_tx_r += 1;
    800008ba:	0000b497          	auipc	s1,0xb
    800008be:	74e48493          	addi	s1,s1,1870 # 8000c008 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008c2:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008c6:	0000b997          	auipc	s3,0xb
    800008ca:	74a98993          	addi	s3,s3,1866 # 8000c010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ce:	00094703          	lbu	a4,0(s2)
    800008d2:	02077713          	andi	a4,a4,32
    800008d6:	c705                	beqz	a4,800008fe <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008d8:	01f7f713          	andi	a4,a5,31
    800008dc:	9756                	add	a4,a4,s5
    800008de:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008e2:	0785                	addi	a5,a5,1
    800008e4:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008e6:	8526                	mv	a0,s1
    800008e8:	00002097          	auipc	ra,0x2
    800008ec:	bda080e7          	jalr	-1062(ra) # 800024c2 <wakeup>
    WriteReg(THR, c);
    800008f0:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008f4:	609c                	ld	a5,0(s1)
    800008f6:	0009b703          	ld	a4,0(s3)
    800008fa:	fcf71ae3          	bne	a4,a5,800008ce <uartstart+0x4a>
  }
}
    800008fe:	70e2                	ld	ra,56(sp)
    80000900:	7442                	ld	s0,48(sp)
    80000902:	74a2                	ld	s1,40(sp)
    80000904:	7902                	ld	s2,32(sp)
    80000906:	69e2                	ld	s3,24(sp)
    80000908:	6a42                	ld	s4,16(sp)
    8000090a:	6aa2                	ld	s5,8(sp)
    8000090c:	6b02                	ld	s6,0(sp)
    8000090e:	6121                	addi	sp,sp,64
    80000910:	8082                	ret
    80000912:	8082                	ret

0000000080000914 <uartputc>:
{
    80000914:	7179                	addi	sp,sp,-48
    80000916:	f406                	sd	ra,40(sp)
    80000918:	f022                	sd	s0,32(sp)
    8000091a:	e052                	sd	s4,0(sp)
    8000091c:	1800                	addi	s0,sp,48
    8000091e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000920:	00014517          	auipc	a0,0x14
    80000924:	92850513          	addi	a0,a0,-1752 # 80014248 <uart_tx_lock>
    80000928:	00000097          	auipc	ra,0x0
    8000092c:	32c080e7          	jalr	812(ra) # 80000c54 <acquire>
  if(panicked){
    80000930:	0000b797          	auipc	a5,0xb
    80000934:	6d07a783          	lw	a5,1744(a5) # 8000c000 <panicked>
    80000938:	c391                	beqz	a5,8000093c <uartputc+0x28>
    for(;;)
    8000093a:	a001                	j	8000093a <uartputc+0x26>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000093c:	0000b717          	auipc	a4,0xb
    80000940:	6d473703          	ld	a4,1748(a4) # 8000c010 <uart_tx_w>
    80000944:	0000b797          	auipc	a5,0xb
    80000948:	6c47b783          	ld	a5,1732(a5) # 8000c008 <uart_tx_r>
    8000094c:	02078793          	addi	a5,a5,32
    80000950:	04e79163          	bne	a5,a4,80000992 <uartputc+0x7e>
    80000954:	ec26                	sd	s1,24(sp)
    80000956:	e84a                	sd	s2,16(sp)
    80000958:	e44e                	sd	s3,8(sp)
      sleep(&uart_tx_r, &uart_tx_lock);
    8000095a:	00014997          	auipc	s3,0x14
    8000095e:	8ee98993          	addi	s3,s3,-1810 # 80014248 <uart_tx_lock>
    80000962:	0000b497          	auipc	s1,0xb
    80000966:	6a648493          	addi	s1,s1,1702 # 8000c008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096a:	0000b917          	auipc	s2,0xb
    8000096e:	6a690913          	addi	s2,s2,1702 # 8000c010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000972:	85ce                	mv	a1,s3
    80000974:	8526                	mv	a0,s1
    80000976:	00002097          	auipc	ra,0x2
    8000097a:	880080e7          	jalr	-1920(ra) # 800021f6 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000097e:	00093703          	ld	a4,0(s2)
    80000982:	609c                	ld	a5,0(s1)
    80000984:	02078793          	addi	a5,a5,32
    80000988:	fee785e3          	beq	a5,a4,80000972 <uartputc+0x5e>
    8000098c:	64e2                	ld	s1,24(sp)
    8000098e:	6942                	ld	s2,16(sp)
    80000990:	69a2                	ld	s3,8(sp)
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000992:	01f77693          	andi	a3,a4,31
    80000996:	00014797          	auipc	a5,0x14
    8000099a:	8b278793          	addi	a5,a5,-1870 # 80014248 <uart_tx_lock>
    8000099e:	97b6                	add	a5,a5,a3
    800009a0:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    800009a4:	0705                	addi	a4,a4,1
    800009a6:	0000b797          	auipc	a5,0xb
    800009aa:	66e7b523          	sd	a4,1642(a5) # 8000c010 <uart_tx_w>
      uartstart();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	ed6080e7          	jalr	-298(ra) # 80000884 <uartstart>
      release(&uart_tx_lock);
    800009b6:	00014517          	auipc	a0,0x14
    800009ba:	89250513          	addi	a0,a0,-1902 # 80014248 <uart_tx_lock>
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	346080e7          	jalr	838(ra) # 80000d04 <release>
}
    800009c6:	70a2                	ld	ra,40(sp)
    800009c8:	7402                	ld	s0,32(sp)
    800009ca:	6a02                	ld	s4,0(sp)
    800009cc:	6145                	addi	sp,sp,48
    800009ce:	8082                	ret

00000000800009d0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d0:	1141                	addi	sp,sp,-16
    800009d2:	e406                	sd	ra,8(sp)
    800009d4:	e022                	sd	s0,0(sp)
    800009d6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009d8:	100007b7          	lui	a5,0x10000
    800009dc:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e0:	8b85                	andi	a5,a5,1
    800009e2:	cb89                	beqz	a5,800009f4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e4:	100007b7          	lui	a5,0x10000
    800009e8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009ec:	60a2                	ld	ra,8(sp)
    800009ee:	6402                	ld	s0,0(sp)
    800009f0:	0141                	addi	sp,sp,16
    800009f2:	8082                	ret
    return -1;
    800009f4:	557d                	li	a0,-1
    800009f6:	bfdd                	j	800009ec <uartgetc+0x1c>

00000000800009f8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a02:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a04:	00000097          	auipc	ra,0x0
    80000a08:	fcc080e7          	jalr	-52(ra) # 800009d0 <uartgetc>
    if(c == -1)
    80000a0c:	00950763          	beq	a0,s1,80000a1a <uartintr+0x22>
      break;
    consoleintr(c);
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	8ca080e7          	jalr	-1846(ra) # 800002da <consoleintr>
  while(1){
    80000a18:	b7f5                	j	80000a04 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1a:	00014517          	auipc	a0,0x14
    80000a1e:	82e50513          	addi	a0,a0,-2002 # 80014248 <uart_tx_lock>
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	232080e7          	jalr	562(ra) # 80000c54 <acquire>
  uartstart();
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	e5a080e7          	jalr	-422(ra) # 80000884 <uartstart>
  release(&uart_tx_lock);
    80000a32:	00014517          	auipc	a0,0x14
    80000a36:	81650513          	addi	a0,a0,-2026 # 80014248 <uart_tx_lock>
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	2ca080e7          	jalr	714(ra) # 80000d04 <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6105                	addi	sp,sp,32
    80000a4a:	8082                	ret

0000000080000a4c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4c:	1101                	addi	sp,sp,-32
    80000a4e:	ec06                	sd	ra,24(sp)
    80000a50:	e822                	sd	s0,16(sp)
    80000a52:	e426                	sd	s1,8(sp)
    80000a54:	e04a                	sd	s2,0(sp)
    80000a56:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a58:	00028797          	auipc	a5,0x28
    80000a5c:	5a878793          	addi	a5,a5,1448 # 80029000 <end>
    80000a60:	00f53733          	sltu	a4,a0,a5
    80000a64:	47c5                	li	a5,17
    80000a66:	07ee                	slli	a5,a5,0x1b
    80000a68:	17fd                	addi	a5,a5,-1
    80000a6a:	00a7b7b3          	sltu	a5,a5,a0
    80000a6e:	8fd9                	or	a5,a5,a4
    80000a70:	e7a1                	bnez	a5,80000ab8 <kfree+0x6c>
    80000a72:	84aa                	mv	s1,a0
    80000a74:	03451793          	slli	a5,a0,0x34
    80000a78:	e3a1                	bnez	a5,80000ab8 <kfree+0x6c>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a7a:	6605                	lui	a2,0x1
    80000a7c:	4585                	li	a1,1
    80000a7e:	00000097          	auipc	ra,0x0
    80000a82:	2ce080e7          	jalr	718(ra) # 80000d4c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a86:	00013917          	auipc	s2,0x13
    80000a8a:	7fa90913          	addi	s2,s2,2042 # 80014280 <kmem>
    80000a8e:	854a                	mv	a0,s2
    80000a90:	00000097          	auipc	ra,0x0
    80000a94:	1c4080e7          	jalr	452(ra) # 80000c54 <acquire>
  r->next = kmem.freelist;
    80000a98:	01893783          	ld	a5,24(s2)
    80000a9c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a9e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aa2:	854a                	mv	a0,s2
    80000aa4:	00000097          	auipc	ra,0x0
    80000aa8:	260080e7          	jalr	608(ra) # 80000d04 <release>
}
    80000aac:	60e2                	ld	ra,24(sp)
    80000aae:	6442                	ld	s0,16(sp)
    80000ab0:	64a2                	ld	s1,8(sp)
    80000ab2:	6902                	ld	s2,0(sp)
    80000ab4:	6105                	addi	sp,sp,32
    80000ab6:	8082                	ret
    panic("kfree");
    80000ab8:	00007517          	auipc	a0,0x7
    80000abc:	58850513          	addi	a0,a0,1416 # 80008040 <etext+0x40>
    80000ac0:	00000097          	auipc	ra,0x0
    80000ac4:	a96080e7          	jalr	-1386(ra) # 80000556 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e463          	bltu	a1,s1,80000b0a <freerange+0x42>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	f56080e7          	jalr	-170(ra) # 80000a4c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afe:	94ce                	add	s1,s1,s3
    80000b00:	fe9979e3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b04:	6942                	ld	s2,16(sp)
    80000b06:	69a2                	ld	s3,8(sp)
    80000b08:	6a02                	ld	s4,0(sp)
}
    80000b0a:	70a2                	ld	ra,40(sp)
    80000b0c:	7402                	ld	s0,32(sp)
    80000b0e:	64e2                	ld	s1,24(sp)
    80000b10:	6145                	addi	sp,sp,48
    80000b12:	8082                	ret

0000000080000b14 <kinit>:
{
    80000b14:	1141                	addi	sp,sp,-16
    80000b16:	e406                	sd	ra,8(sp)
    80000b18:	e022                	sd	s0,0(sp)
    80000b1a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b1c:	00007597          	auipc	a1,0x7
    80000b20:	52c58593          	addi	a1,a1,1324 # 80008048 <etext+0x48>
    80000b24:	00013517          	auipc	a0,0x13
    80000b28:	75c50513          	addi	a0,a0,1884 # 80014280 <kmem>
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	08e080e7          	jalr	142(ra) # 80000bba <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b34:	45c5                	li	a1,17
    80000b36:	05ee                	slli	a1,a1,0x1b
    80000b38:	00028517          	auipc	a0,0x28
    80000b3c:	4c850513          	addi	a0,a0,1224 # 80029000 <end>
    80000b40:	00000097          	auipc	ra,0x0
    80000b44:	f88080e7          	jalr	-120(ra) # 80000ac8 <freerange>
}
    80000b48:	60a2                	ld	ra,8(sp)
    80000b4a:	6402                	ld	s0,0(sp)
    80000b4c:	0141                	addi	sp,sp,16
    80000b4e:	8082                	ret

0000000080000b50 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b5a:	00013517          	auipc	a0,0x13
    80000b5e:	72650513          	addi	a0,a0,1830 # 80014280 <kmem>
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	0f2080e7          	jalr	242(ra) # 80000c54 <acquire>
  r = kmem.freelist;
    80000b6a:	00013497          	auipc	s1,0x13
    80000b6e:	72e4b483          	ld	s1,1838(s1) # 80014298 <kmem+0x18>
  if(r)
    80000b72:	c89d                	beqz	s1,80000ba8 <kalloc+0x58>
    kmem.freelist = r->next;
    80000b74:	609c                	ld	a5,0(s1)
    80000b76:	00013717          	auipc	a4,0x13
    80000b7a:	72f73123          	sd	a5,1826(a4) # 80014298 <kmem+0x18>
  release(&kmem.lock);
    80000b7e:	00013517          	auipc	a0,0x13
    80000b82:	70250513          	addi	a0,a0,1794 # 80014280 <kmem>
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	17e080e7          	jalr	382(ra) # 80000d04 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b8e:	6605                	lui	a2,0x1
    80000b90:	4595                	li	a1,5
    80000b92:	8526                	mv	a0,s1
    80000b94:	00000097          	auipc	ra,0x0
    80000b98:	1b8080e7          	jalr	440(ra) # 80000d4c <memset>
  return (void*)r;
}
    80000b9c:	8526                	mv	a0,s1
    80000b9e:	60e2                	ld	ra,24(sp)
    80000ba0:	6442                	ld	s0,16(sp)
    80000ba2:	64a2                	ld	s1,8(sp)
    80000ba4:	6105                	addi	sp,sp,32
    80000ba6:	8082                	ret
  release(&kmem.lock);
    80000ba8:	00013517          	auipc	a0,0x13
    80000bac:	6d850513          	addi	a0,a0,1752 # 80014280 <kmem>
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	154080e7          	jalr	340(ra) # 80000d04 <release>
  if(r)
    80000bb8:	b7d5                	j	80000b9c <kalloc+0x4c>

0000000080000bba <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bba:	1141                	addi	sp,sp,-16
    80000bbc:	e406                	sd	ra,8(sp)
    80000bbe:	e022                	sd	s0,0(sp)
    80000bc0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bc2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bc4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bc8:	00053823          	sd	zero,16(a0)
}
    80000bcc:	60a2                	ld	ra,8(sp)
    80000bce:	6402                	ld	s0,0(sp)
    80000bd0:	0141                	addi	sp,sp,16
    80000bd2:	8082                	ret

0000000080000bd4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bd4:	411c                	lw	a5,0(a0)
    80000bd6:	e399                	bnez	a5,80000bdc <holding+0x8>
    80000bd8:	4501                	li	a0,0
  return r;
}
    80000bda:	8082                	ret
{
    80000bdc:	1101                	addi	sp,sp,-32
    80000bde:	ec06                	sd	ra,24(sp)
    80000be0:	e822                	sd	s0,16(sp)
    80000be2:	e426                	sd	s1,8(sp)
    80000be4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000be6:	691c                	ld	a5,16(a0)
    80000be8:	84be                	mv	s1,a5
    80000bea:	00001097          	auipc	ra,0x1
    80000bee:	e70080e7          	jalr	-400(ra) # 80001a5a <mycpu>
    80000bf2:	40a48533          	sub	a0,s1,a0
    80000bf6:	00153513          	seqz	a0,a0
}
    80000bfa:	60e2                	ld	ra,24(sp)
    80000bfc:	6442                	ld	s0,16(sp)
    80000bfe:	64a2                	ld	s1,8(sp)
    80000c00:	6105                	addi	sp,sp,32
    80000c02:	8082                	ret

0000000080000c04 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c04:	1101                	addi	sp,sp,-32
    80000c06:	ec06                	sd	ra,24(sp)
    80000c08:	e822                	sd	s0,16(sp)
    80000c0a:	e426                	sd	s1,8(sp)
    80000c0c:	1000                	addi	s0,sp,32

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c0e:	100027f3          	csrr	a5,sstatus
    80000c12:	84be                	mv	s1,a5
    80000c14:	100027f3          	csrr	a5,sstatus

// disable device interrupts
static inline void
intr_off()
{
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c1a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	e3c080e7          	jalr	-452(ra) # 80001a5a <mycpu>
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	cf89                	beqz	a5,80000c42 <push_off+0x3e>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c2a:	00001097          	auipc	ra,0x1
    80000c2e:	e30080e7          	jalr	-464(ra) # 80001a5a <mycpu>
    80000c32:	5d3c                	lw	a5,120(a0)
    80000c34:	2785                	addiw	a5,a5,1
    80000c36:	dd3c                	sw	a5,120(a0)
}
    80000c38:	60e2                	ld	ra,24(sp)
    80000c3a:	6442                	ld	s0,16(sp)
    80000c3c:	64a2                	ld	s1,8(sp)
    80000c3e:	6105                	addi	sp,sp,32
    80000c40:	8082                	ret
    mycpu()->intena = old;
    80000c42:	00001097          	auipc	ra,0x1
    80000c46:	e18080e7          	jalr	-488(ra) # 80001a5a <mycpu>
// are device interrupts enabled?
static inline int
intr_get()
{
  uint64 x = r_sstatus();
  return (x & SSTATUS_SIE) != 0;
    80000c4a:	0014d793          	srli	a5,s1,0x1
    80000c4e:	8b85                	andi	a5,a5,1
    80000c50:	dd7c                	sw	a5,124(a0)
    80000c52:	bfe1                	j	80000c2a <push_off+0x26>

0000000080000c54 <acquire>:
{
    80000c54:	1101                	addi	sp,sp,-32
    80000c56:	ec06                	sd	ra,24(sp)
    80000c58:	e822                	sd	s0,16(sp)
    80000c5a:	e426                	sd	s1,8(sp)
    80000c5c:	1000                	addi	s0,sp,32
    80000c5e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c60:	00000097          	auipc	ra,0x0
    80000c64:	fa4080e7          	jalr	-92(ra) # 80000c04 <push_off>
  if(holding(lk))
    80000c68:	8526                	mv	a0,s1
    80000c6a:	00000097          	auipc	ra,0x0
    80000c6e:	f6a080e7          	jalr	-150(ra) # 80000bd4 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c72:	4705                	li	a4,1
  if(holding(lk))
    80000c74:	e115                	bnez	a0,80000c98 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c76:	87ba                	mv	a5,a4
    80000c78:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c7c:	2781                	sext.w	a5,a5
    80000c7e:	ffe5                	bnez	a5,80000c76 <acquire+0x22>
  __sync_synchronize();
    80000c80:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c84:	00001097          	auipc	ra,0x1
    80000c88:	dd6080e7          	jalr	-554(ra) # 80001a5a <mycpu>
    80000c8c:	e888                	sd	a0,16(s1)
}
    80000c8e:	60e2                	ld	ra,24(sp)
    80000c90:	6442                	ld	s0,16(sp)
    80000c92:	64a2                	ld	s1,8(sp)
    80000c94:	6105                	addi	sp,sp,32
    80000c96:	8082                	ret
    panic("acquire");
    80000c98:	00007517          	auipc	a0,0x7
    80000c9c:	3b850513          	addi	a0,a0,952 # 80008050 <etext+0x50>
    80000ca0:	00000097          	auipc	ra,0x0
    80000ca4:	8b6080e7          	jalr	-1866(ra) # 80000556 <panic>

0000000080000ca8 <pop_off>:

void
pop_off(void)
{
    80000ca8:	1141                	addi	sp,sp,-16
    80000caa:	e406                	sd	ra,8(sp)
    80000cac:	e022                	sd	s0,0(sp)
    80000cae:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb0:	00001097          	auipc	ra,0x1
    80000cb4:	daa080e7          	jalr	-598(ra) # 80001a5a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cbc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cbe:	e39d                	bnez	a5,80000ce4 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc0:	5d3c                	lw	a5,120(a0)
    80000cc2:	02f05963          	blez	a5,80000cf4 <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000cc6:	37fd                	addiw	a5,a5,-1
    80000cc8:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cca:	eb89                	bnez	a5,80000cdc <pop_off+0x34>
    80000ccc:	5d7c                	lw	a5,124(a0)
    80000cce:	c799                	beqz	a5,80000cdc <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cd4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd8:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cdc:	60a2                	ld	ra,8(sp)
    80000cde:	6402                	ld	s0,0(sp)
    80000ce0:	0141                	addi	sp,sp,16
    80000ce2:	8082                	ret
    panic("pop_off - interruptible");
    80000ce4:	00007517          	auipc	a0,0x7
    80000ce8:	37450513          	addi	a0,a0,884 # 80008058 <etext+0x58>
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	86a080e7          	jalr	-1942(ra) # 80000556 <panic>
    panic("pop_off");
    80000cf4:	00007517          	auipc	a0,0x7
    80000cf8:	37c50513          	addi	a0,a0,892 # 80008070 <etext+0x70>
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	85a080e7          	jalr	-1958(ra) # 80000556 <panic>

0000000080000d04 <release>:
{
    80000d04:	1101                	addi	sp,sp,-32
    80000d06:	ec06                	sd	ra,24(sp)
    80000d08:	e822                	sd	s0,16(sp)
    80000d0a:	e426                	sd	s1,8(sp)
    80000d0c:	1000                	addi	s0,sp,32
    80000d0e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d10:	00000097          	auipc	ra,0x0
    80000d14:	ec4080e7          	jalr	-316(ra) # 80000bd4 <holding>
    80000d18:	c115                	beqz	a0,80000d3c <release+0x38>
  lk->cpu = 0;
    80000d1a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d1e:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d22:	0310000f          	fence	rw,w
    80000d26:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d2a:	00000097          	auipc	ra,0x0
    80000d2e:	f7e080e7          	jalr	-130(ra) # 80000ca8 <pop_off>
}
    80000d32:	60e2                	ld	ra,24(sp)
    80000d34:	6442                	ld	s0,16(sp)
    80000d36:	64a2                	ld	s1,8(sp)
    80000d38:	6105                	addi	sp,sp,32
    80000d3a:	8082                	ret
    panic("release");
    80000d3c:	00007517          	auipc	a0,0x7
    80000d40:	33c50513          	addi	a0,a0,828 # 80008078 <etext+0x78>
    80000d44:	00000097          	auipc	ra,0x0
    80000d48:	812080e7          	jalr	-2030(ra) # 80000556 <panic>

0000000080000d4c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d4c:	1141                	addi	sp,sp,-16
    80000d4e:	e406                	sd	ra,8(sp)
    80000d50:	e022                	sd	s0,0(sp)
    80000d52:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d54:	ca19                	beqz	a2,80000d6a <memset+0x1e>
    80000d56:	87aa                	mv	a5,a0
    80000d58:	1602                	slli	a2,a2,0x20
    80000d5a:	9201                	srli	a2,a2,0x20
    80000d5c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d60:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d64:	0785                	addi	a5,a5,1
    80000d66:	fee79de3          	bne	a5,a4,80000d60 <memset+0x14>
  }
  return dst;
}
    80000d6a:	60a2                	ld	ra,8(sp)
    80000d6c:	6402                	ld	s0,0(sp)
    80000d6e:	0141                	addi	sp,sp,16
    80000d70:	8082                	ret

0000000080000d72 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d72:	1141                	addi	sp,sp,-16
    80000d74:	e406                	sd	ra,8(sp)
    80000d76:	e022                	sd	s0,0(sp)
    80000d78:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d7a:	c61d                	beqz	a2,80000da8 <memcmp+0x36>
    80000d7c:	1602                	slli	a2,a2,0x20
    80000d7e:	9201                	srli	a2,a2,0x20
    80000d80:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d84:	00054783          	lbu	a5,0(a0)
    80000d88:	0005c703          	lbu	a4,0(a1)
    80000d8c:	00e79863          	bne	a5,a4,80000d9c <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d90:	0505                	addi	a0,a0,1
    80000d92:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d94:	fed518e3          	bne	a0,a3,80000d84 <memcmp+0x12>
  }

  return 0;
    80000d98:	4501                	li	a0,0
    80000d9a:	a019                	j	80000da0 <memcmp+0x2e>
      return *s1 - *s2;
    80000d9c:	40e7853b          	subw	a0,a5,a4
}
    80000da0:	60a2                	ld	ra,8(sp)
    80000da2:	6402                	ld	s0,0(sp)
    80000da4:	0141                	addi	sp,sp,16
    80000da6:	8082                	ret
  return 0;
    80000da8:	4501                	li	a0,0
    80000daa:	bfdd                	j	80000da0 <memcmp+0x2e>

0000000080000dac <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dac:	1141                	addi	sp,sp,-16
    80000dae:	e406                	sd	ra,8(sp)
    80000db0:	e022                	sd	s0,0(sp)
    80000db2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000db4:	c205                	beqz	a2,80000dd4 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000db6:	02a5e363          	bltu	a1,a0,80000ddc <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dba:	1602                	slli	a2,a2,0x20
    80000dbc:	9201                	srli	a2,a2,0x20
    80000dbe:	00c587b3          	add	a5,a1,a2
{
    80000dc2:	872a                	mv	a4,a0
      *d++ = *s++;
    80000dc4:	0585                	addi	a1,a1,1
    80000dc6:	0705                	addi	a4,a4,1
    80000dc8:	fff5c683          	lbu	a3,-1(a1)
    80000dcc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dd0:	feb79ae3          	bne	a5,a1,80000dc4 <memmove+0x18>

  return dst;
}
    80000dd4:	60a2                	ld	ra,8(sp)
    80000dd6:	6402                	ld	s0,0(sp)
    80000dd8:	0141                	addi	sp,sp,16
    80000dda:	8082                	ret
  if(s < d && s + n > d){
    80000ddc:	02061693          	slli	a3,a2,0x20
    80000de0:	9281                	srli	a3,a3,0x20
    80000de2:	00d58733          	add	a4,a1,a3
    80000de6:	fce57ae3          	bgeu	a0,a4,80000dba <memmove+0xe>
    d += n;
    80000dea:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dec:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000df0:	1782                	slli	a5,a5,0x20
    80000df2:	9381                	srli	a5,a5,0x20
    80000df4:	fff7c793          	not	a5,a5
    80000df8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dfa:	177d                	addi	a4,a4,-1
    80000dfc:	16fd                	addi	a3,a3,-1
    80000dfe:	00074603          	lbu	a2,0(a4)
    80000e02:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e06:	fee79ae3          	bne	a5,a4,80000dfa <memmove+0x4e>
    80000e0a:	b7e9                	j	80000dd4 <memmove+0x28>

0000000080000e0c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e0c:	1141                	addi	sp,sp,-16
    80000e0e:	e406                	sd	ra,8(sp)
    80000e10:	e022                	sd	s0,0(sp)
    80000e12:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e14:	00000097          	auipc	ra,0x0
    80000e18:	f98080e7          	jalr	-104(ra) # 80000dac <memmove>
}
    80000e1c:	60a2                	ld	ra,8(sp)
    80000e1e:	6402                	ld	s0,0(sp)
    80000e20:	0141                	addi	sp,sp,16
    80000e22:	8082                	ret

0000000080000e24 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e406                	sd	ra,8(sp)
    80000e28:	e022                	sd	s0,0(sp)
    80000e2a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e2c:	ce11                	beqz	a2,80000e48 <strncmp+0x24>
    80000e2e:	00054783          	lbu	a5,0(a0)
    80000e32:	cf89                	beqz	a5,80000e4c <strncmp+0x28>
    80000e34:	0005c703          	lbu	a4,0(a1)
    80000e38:	00f71a63          	bne	a4,a5,80000e4c <strncmp+0x28>
    n--, p++, q++;
    80000e3c:	367d                	addiw	a2,a2,-1
    80000e3e:	0505                	addi	a0,a0,1
    80000e40:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e42:	f675                	bnez	a2,80000e2e <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e44:	4501                	li	a0,0
    80000e46:	a801                	j	80000e56 <strncmp+0x32>
    80000e48:	4501                	li	a0,0
    80000e4a:	a031                	j	80000e56 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e4c:	00054503          	lbu	a0,0(a0)
    80000e50:	0005c783          	lbu	a5,0(a1)
    80000e54:	9d1d                	subw	a0,a0,a5
}
    80000e56:	60a2                	ld	ra,8(sp)
    80000e58:	6402                	ld	s0,0(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret

0000000080000e5e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e5e:	1141                	addi	sp,sp,-16
    80000e60:	e406                	sd	ra,8(sp)
    80000e62:	e022                	sd	s0,0(sp)
    80000e64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e66:	87aa                	mv	a5,a0
    80000e68:	a011                	j	80000e6c <strncpy+0xe>
    80000e6a:	8636                	mv	a2,a3
    80000e6c:	02c05863          	blez	a2,80000e9c <strncpy+0x3e>
    80000e70:	fff6069b          	addiw	a3,a2,-1
    80000e74:	8836                	mv	a6,a3
    80000e76:	0785                	addi	a5,a5,1
    80000e78:	0005c703          	lbu	a4,0(a1)
    80000e7c:	fee78fa3          	sb	a4,-1(a5)
    80000e80:	0585                	addi	a1,a1,1
    80000e82:	f765                	bnez	a4,80000e6a <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e84:	873e                	mv	a4,a5
    80000e86:	01005b63          	blez	a6,80000e9c <strncpy+0x3e>
    80000e8a:	9fb1                	addw	a5,a5,a2
    80000e8c:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e8e:	0705                	addi	a4,a4,1
    80000e90:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e94:	40e786bb          	subw	a3,a5,a4
    80000e98:	fed04be3          	bgtz	a3,80000e8e <strncpy+0x30>
  return os;
}
    80000e9c:	60a2                	ld	ra,8(sp)
    80000e9e:	6402                	ld	s0,0(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret

0000000080000ea4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e406                	sd	ra,8(sp)
    80000ea8:	e022                	sd	s0,0(sp)
    80000eaa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eac:	02c05363          	blez	a2,80000ed2 <safestrcpy+0x2e>
    80000eb0:	fff6069b          	addiw	a3,a2,-1
    80000eb4:	1682                	slli	a3,a3,0x20
    80000eb6:	9281                	srli	a3,a3,0x20
    80000eb8:	96ae                	add	a3,a3,a1
    80000eba:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ebc:	00d58963          	beq	a1,a3,80000ece <safestrcpy+0x2a>
    80000ec0:	0585                	addi	a1,a1,1
    80000ec2:	0785                	addi	a5,a5,1
    80000ec4:	fff5c703          	lbu	a4,-1(a1)
    80000ec8:	fee78fa3          	sb	a4,-1(a5)
    80000ecc:	fb65                	bnez	a4,80000ebc <safestrcpy+0x18>
    ;
  *s = 0;
    80000ece:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ed2:	60a2                	ld	ra,8(sp)
    80000ed4:	6402                	ld	s0,0(sp)
    80000ed6:	0141                	addi	sp,sp,16
    80000ed8:	8082                	ret

0000000080000eda <strlen>:

int
strlen(const char *s)
{
    80000eda:	1141                	addi	sp,sp,-16
    80000edc:	e406                	sd	ra,8(sp)
    80000ede:	e022                	sd	s0,0(sp)
    80000ee0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ee2:	00054783          	lbu	a5,0(a0)
    80000ee6:	cf91                	beqz	a5,80000f02 <strlen+0x28>
    80000ee8:	00150793          	addi	a5,a0,1
    80000eec:	86be                	mv	a3,a5
    80000eee:	0785                	addi	a5,a5,1
    80000ef0:	fff7c703          	lbu	a4,-1(a5)
    80000ef4:	ff65                	bnez	a4,80000eec <strlen+0x12>
    80000ef6:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000efa:	60a2                	ld	ra,8(sp)
    80000efc:	6402                	ld	s0,0(sp)
    80000efe:	0141                	addi	sp,sp,16
    80000f00:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f02:	4501                	li	a0,0
    80000f04:	bfdd                	j	80000efa <strlen+0x20>

0000000080000f06 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f06:	1141                	addi	sp,sp,-16
    80000f08:	e406                	sd	ra,8(sp)
    80000f0a:	e022                	sd	s0,0(sp)
    80000f0c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f0e:	00001097          	auipc	ra,0x1
    80000f12:	b38080e7          	jalr	-1224(ra) # 80001a46 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f16:	0000b717          	auipc	a4,0xb
    80000f1a:	10270713          	addi	a4,a4,258 # 8000c018 <started>
  if(cpuid() == 0){
    80000f1e:	c139                	beqz	a0,80000f64 <main+0x5e>
    while(started == 0)
    80000f20:	431c                	lw	a5,0(a4)
    80000f22:	2781                	sext.w	a5,a5
    80000f24:	dff5                	beqz	a5,80000f20 <main+0x1a>
      ;
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f2a:	00001097          	auipc	ra,0x1
    80000f2e:	b1c080e7          	jalr	-1252(ra) # 80001a46 <cpuid>
    80000f32:	85aa                	mv	a1,a0
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	16450513          	addi	a0,a0,356 # 80008098 <etext+0x98>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	664080e7          	jalr	1636(ra) # 800005a0 <printf>
    kvminithart();    // turn on paging
    80000f44:	00000097          	auipc	ra,0x0
    80000f48:	0d8080e7          	jalr	216(ra) # 8000101c <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	9be080e7          	jalr	-1602(ra) # 8000290a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	0d0080e7          	jalr	208(ra) # 80006024 <plicinithart>
  }

  scheduler();        
    80000f5c:	00001097          	auipc	ra,0x1
    80000f60:	0aa080e7          	jalr	170(ra) # 80002006 <scheduler>
    consoleinit();
    80000f64:	fffff097          	auipc	ra,0xfffff
    80000f68:	508080e7          	jalr	1288(ra) # 8000046c <consoleinit>
    printfinit();
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	83e080e7          	jalr	-1986(ra) # 800007aa <printfinit>
    printf("\n");
    80000f74:	00007517          	auipc	a0,0x7
    80000f78:	09c50513          	addi	a0,a0,156 # 80008010 <etext+0x10>
    80000f7c:	fffff097          	auipc	ra,0xfffff
    80000f80:	624080e7          	jalr	1572(ra) # 800005a0 <printf>
    printf("xv6 kernel is booting\n");
    80000f84:	00007517          	auipc	a0,0x7
    80000f88:	0fc50513          	addi	a0,a0,252 # 80008080 <etext+0x80>
    80000f8c:	fffff097          	auipc	ra,0xfffff
    80000f90:	614080e7          	jalr	1556(ra) # 800005a0 <printf>
    printf("\n");
    80000f94:	00007517          	auipc	a0,0x7
    80000f98:	07c50513          	addi	a0,a0,124 # 80008010 <etext+0x10>
    80000f9c:	fffff097          	auipc	ra,0xfffff
    80000fa0:	604080e7          	jalr	1540(ra) # 800005a0 <printf>
    kinit();         // physical page allocator
    80000fa4:	00000097          	auipc	ra,0x0
    80000fa8:	b70080e7          	jalr	-1168(ra) # 80000b14 <kinit>
    kvminit();       // create kernel page table
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	320080e7          	jalr	800(ra) # 800012cc <kvminit>
    kvminithart();   // turn on paging
    80000fb4:	00000097          	auipc	ra,0x0
    80000fb8:	068080e7          	jalr	104(ra) # 8000101c <kvminithart>
    procinit();      // process table
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	9d2080e7          	jalr	-1582(ra) # 8000198e <procinit>
    trapinit();      // trap vectors
    80000fc4:	00002097          	auipc	ra,0x2
    80000fc8:	91e080e7          	jalr	-1762(ra) # 800028e2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fcc:	00002097          	auipc	ra,0x2
    80000fd0:	93e080e7          	jalr	-1730(ra) # 8000290a <trapinithart>
    plicinit();      // set up interrupt controller
    80000fd4:	00005097          	auipc	ra,0x5
    80000fd8:	036080e7          	jalr	54(ra) # 8000600a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	048080e7          	jalr	72(ra) # 80006024 <plicinithart>
    binit();         // buffer cache
    80000fe4:	00002097          	auipc	ra,0x2
    80000fe8:	104080e7          	jalr	260(ra) # 800030e8 <binit>
    iinit();         // inode table
    80000fec:	00002097          	auipc	ra,0x2
    80000ff0:	762080e7          	jalr	1890(ra) # 8000374e <iinit>
    fileinit();      // file table
    80000ff4:	00003097          	auipc	ra,0x3
    80000ff8:	744080e7          	jalr	1860(ra) # 80004738 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ffc:	00005097          	auipc	ra,0x5
    80001000:	148080e7          	jalr	328(ra) # 80006144 <virtio_disk_init>
    userinit();      // first user process
    80001004:	00001097          	auipc	ra,0x1
    80001008:	d68080e7          	jalr	-664(ra) # 80001d6c <userinit>
    __sync_synchronize();
    8000100c:	0330000f          	fence	rw,rw
    started = 1;
    80001010:	4785                	li	a5,1
    80001012:	0000b717          	auipc	a4,0xb
    80001016:	00f72323          	sw	a5,6(a4) # 8000c018 <started>
    8000101a:	b789                	j	80000f5c <main+0x56>

000000008000101c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000101c:	1141                	addi	sp,sp,-16
    8000101e:	e406                	sd	ra,8(sp)
    80001020:	e022                	sd	s0,0(sp)
    80001022:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001024:	0000b797          	auipc	a5,0xb
    80001028:	ffc7b783          	ld	a5,-4(a5) # 8000c020 <kernel_pagetable>
    8000102c:	83b1                	srli	a5,a5,0xc
    8000102e:	577d                	li	a4,-1
    80001030:	177e                	slli	a4,a4,0x3f
    80001032:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001034:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001038:	12000073          	sfence.vma
  sfence_vma();
}
    8000103c:	60a2                	ld	ra,8(sp)
    8000103e:	6402                	ld	s0,0(sp)
    80001040:	0141                	addi	sp,sp,16
    80001042:	8082                	ret

0000000080001044 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001044:	7139                	addi	sp,sp,-64
    80001046:	fc06                	sd	ra,56(sp)
    80001048:	f822                	sd	s0,48(sp)
    8000104a:	f426                	sd	s1,40(sp)
    8000104c:	f04a                	sd	s2,32(sp)
    8000104e:	ec4e                	sd	s3,24(sp)
    80001050:	e852                	sd	s4,16(sp)
    80001052:	e456                	sd	s5,8(sp)
    80001054:	e05a                	sd	s6,0(sp)
    80001056:	0080                	addi	s0,sp,64
    80001058:	84aa                	mv	s1,a0
    8000105a:	89ae                	mv	s3,a1
    8000105c:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    8000105e:	57fd                	li	a5,-1
    80001060:	83e9                	srli	a5,a5,0x1a
    80001062:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001064:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001066:	04b7e263          	bltu	a5,a1,800010aa <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    8000106a:	0149d933          	srl	s2,s3,s4
    8000106e:	1ff97913          	andi	s2,s2,511
    80001072:	090e                	slli	s2,s2,0x3
    80001074:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001076:	00093483          	ld	s1,0(s2)
    8000107a:	0014f793          	andi	a5,s1,1
    8000107e:	cf95                	beqz	a5,800010ba <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001080:	80a9                	srli	s1,s1,0xa
    80001082:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001084:	3a5d                	addiw	s4,s4,-9
    80001086:	ff5a12e3          	bne	s4,s5,8000106a <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    8000108a:	00c9d513          	srli	a0,s3,0xc
    8000108e:	1ff57513          	andi	a0,a0,511
    80001092:	050e                	slli	a0,a0,0x3
    80001094:	9526                	add	a0,a0,s1
}
    80001096:	70e2                	ld	ra,56(sp)
    80001098:	7442                	ld	s0,48(sp)
    8000109a:	74a2                	ld	s1,40(sp)
    8000109c:	7902                	ld	s2,32(sp)
    8000109e:	69e2                	ld	s3,24(sp)
    800010a0:	6a42                	ld	s4,16(sp)
    800010a2:	6aa2                	ld	s5,8(sp)
    800010a4:	6b02                	ld	s6,0(sp)
    800010a6:	6121                	addi	sp,sp,64
    800010a8:	8082                	ret
    panic("walk");
    800010aa:	00007517          	auipc	a0,0x7
    800010ae:	00650513          	addi	a0,a0,6 # 800080b0 <etext+0xb0>
    800010b2:	fffff097          	auipc	ra,0xfffff
    800010b6:	4a4080e7          	jalr	1188(ra) # 80000556 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010ba:	020b0663          	beqz	s6,800010e6 <walk+0xa2>
    800010be:	00000097          	auipc	ra,0x0
    800010c2:	a92080e7          	jalr	-1390(ra) # 80000b50 <kalloc>
    800010c6:	84aa                	mv	s1,a0
    800010c8:	d579                	beqz	a0,80001096 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    800010ca:	6605                	lui	a2,0x1
    800010cc:	4581                	li	a1,0
    800010ce:	00000097          	auipc	ra,0x0
    800010d2:	c7e080e7          	jalr	-898(ra) # 80000d4c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010d6:	00c4d793          	srli	a5,s1,0xc
    800010da:	07aa                	slli	a5,a5,0xa
    800010dc:	0017e793          	ori	a5,a5,1
    800010e0:	00f93023          	sd	a5,0(s2)
    800010e4:	b745                	j	80001084 <walk+0x40>
        return 0;
    800010e6:	4501                	li	a0,0
    800010e8:	b77d                	j	80001096 <walk+0x52>

00000000800010ea <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010ea:	57fd                	li	a5,-1
    800010ec:	83e9                	srli	a5,a5,0x1a
    800010ee:	00b7f463          	bgeu	a5,a1,800010f6 <walkaddr+0xc>
    return 0;
    800010f2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010f4:	8082                	ret
{
    800010f6:	1141                	addi	sp,sp,-16
    800010f8:	e406                	sd	ra,8(sp)
    800010fa:	e022                	sd	s0,0(sp)
    800010fc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010fe:	4601                	li	a2,0
    80001100:	00000097          	auipc	ra,0x0
    80001104:	f44080e7          	jalr	-188(ra) # 80001044 <walk>
  if(pte == 0)
    80001108:	c901                	beqz	a0,80001118 <walkaddr+0x2e>
  if((*pte & PTE_V) == 0)
    8000110a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000110c:	0117f693          	andi	a3,a5,17
    80001110:	4745                	li	a4,17
    return 0;
    80001112:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001114:	00e68663          	beq	a3,a4,80001120 <walkaddr+0x36>
}
    80001118:	60a2                	ld	ra,8(sp)
    8000111a:	6402                	ld	s0,0(sp)
    8000111c:	0141                	addi	sp,sp,16
    8000111e:	8082                	ret
  pa = PTE2PA(*pte);
    80001120:	83a9                	srli	a5,a5,0xa
    80001122:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001126:	bfcd                	j	80001118 <walkaddr+0x2e>

0000000080001128 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001128:	715d                	addi	sp,sp,-80
    8000112a:	e486                	sd	ra,72(sp)
    8000112c:	e0a2                	sd	s0,64(sp)
    8000112e:	fc26                	sd	s1,56(sp)
    80001130:	f84a                	sd	s2,48(sp)
    80001132:	f44e                	sd	s3,40(sp)
    80001134:	f052                	sd	s4,32(sp)
    80001136:	ec56                	sd	s5,24(sp)
    80001138:	e85a                	sd	s6,16(sp)
    8000113a:	e45e                	sd	s7,8(sp)
    8000113c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000113e:	ca21                	beqz	a2,8000118e <mappages+0x66>
    80001140:	8a2a                	mv	s4,a0
    80001142:	8aba                	mv	s5,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001144:	777d                	lui	a4,0xfffff
    80001146:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000114a:	fff58913          	addi	s2,a1,-1
    8000114e:	9932                	add	s2,s2,a2
    80001150:	00e97933          	and	s2,s2,a4
  a = PGROUNDDOWN(va);
    80001154:	84be                	mv	s1,a5
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001156:	4b05                	li	s6,1
    80001158:	40f689b3          	sub	s3,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000115c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115e:	865a                	mv	a2,s6
    80001160:	85a6                	mv	a1,s1
    80001162:	8552                	mv	a0,s4
    80001164:	00000097          	auipc	ra,0x0
    80001168:	ee0080e7          	jalr	-288(ra) # 80001044 <walk>
    8000116c:	c129                	beqz	a0,800011ae <mappages+0x86>
    if(*pte & PTE_V)
    8000116e:	611c                	ld	a5,0(a0)
    80001170:	8b85                	andi	a5,a5,1
    80001172:	e795                	bnez	a5,8000119e <mappages+0x76>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001174:	013487b3          	add	a5,s1,s3
    80001178:	83b1                	srli	a5,a5,0xc
    8000117a:	07aa                	slli	a5,a5,0xa
    8000117c:	0157e7b3          	or	a5,a5,s5
    80001180:	0017e793          	ori	a5,a5,1
    80001184:	e11c                	sd	a5,0(a0)
    if(a == last)
    80001186:	05248063          	beq	s1,s2,800011c6 <mappages+0x9e>
    a += PGSIZE;
    8000118a:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000118c:	bfc9                	j	8000115e <mappages+0x36>
    panic("mappages: size");
    8000118e:	00007517          	auipc	a0,0x7
    80001192:	f2a50513          	addi	a0,a0,-214 # 800080b8 <etext+0xb8>
    80001196:	fffff097          	auipc	ra,0xfffff
    8000119a:	3c0080e7          	jalr	960(ra) # 80000556 <panic>
      panic("mappages: remap");
    8000119e:	00007517          	auipc	a0,0x7
    800011a2:	f2a50513          	addi	a0,a0,-214 # 800080c8 <etext+0xc8>
    800011a6:	fffff097          	auipc	ra,0xfffff
    800011aa:	3b0080e7          	jalr	944(ra) # 80000556 <panic>
      return -1;
    800011ae:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011b0:	60a6                	ld	ra,72(sp)
    800011b2:	6406                	ld	s0,64(sp)
    800011b4:	74e2                	ld	s1,56(sp)
    800011b6:	7942                	ld	s2,48(sp)
    800011b8:	79a2                	ld	s3,40(sp)
    800011ba:	7a02                	ld	s4,32(sp)
    800011bc:	6ae2                	ld	s5,24(sp)
    800011be:	6b42                	ld	s6,16(sp)
    800011c0:	6ba2                	ld	s7,8(sp)
    800011c2:	6161                	addi	sp,sp,80
    800011c4:	8082                	ret
  return 0;
    800011c6:	4501                	li	a0,0
    800011c8:	b7e5                	j	800011b0 <mappages+0x88>

00000000800011ca <kvmmap>:
{
    800011ca:	1141                	addi	sp,sp,-16
    800011cc:	e406                	sd	ra,8(sp)
    800011ce:	e022                	sd	s0,0(sp)
    800011d0:	0800                	addi	s0,sp,16
    800011d2:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011d4:	86b2                	mv	a3,a2
    800011d6:	863e                	mv	a2,a5
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	f50080e7          	jalr	-176(ra) # 80001128 <mappages>
    800011e0:	e509                	bnez	a0,800011ea <kvmmap+0x20>
}
    800011e2:	60a2                	ld	ra,8(sp)
    800011e4:	6402                	ld	s0,0(sp)
    800011e6:	0141                	addi	sp,sp,16
    800011e8:	8082                	ret
    panic("kvmmap");
    800011ea:	00007517          	auipc	a0,0x7
    800011ee:	eee50513          	addi	a0,a0,-274 # 800080d8 <etext+0xd8>
    800011f2:	fffff097          	auipc	ra,0xfffff
    800011f6:	364080e7          	jalr	868(ra) # 80000556 <panic>

00000000800011fa <kvmmake>:
{
    800011fa:	1101                	addi	sp,sp,-32
    800011fc:	ec06                	sd	ra,24(sp)
    800011fe:	e822                	sd	s0,16(sp)
    80001200:	e426                	sd	s1,8(sp)
    80001202:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001204:	00000097          	auipc	ra,0x0
    80001208:	94c080e7          	jalr	-1716(ra) # 80000b50 <kalloc>
    8000120c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000120e:	6605                	lui	a2,0x1
    80001210:	4581                	li	a1,0
    80001212:	00000097          	auipc	ra,0x0
    80001216:	b3a080e7          	jalr	-1222(ra) # 80000d4c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000121a:	4719                	li	a4,6
    8000121c:	6685                	lui	a3,0x1
    8000121e:	10000637          	lui	a2,0x10000
    80001222:	85b2                	mv	a1,a2
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	fa4080e7          	jalr	-92(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000122e:	4719                	li	a4,6
    80001230:	6685                	lui	a3,0x1
    80001232:	10001637          	lui	a2,0x10001
    80001236:	85b2                	mv	a1,a2
    80001238:	8526                	mv	a0,s1
    8000123a:	00000097          	auipc	ra,0x0
    8000123e:	f90080e7          	jalr	-112(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001242:	4719                	li	a4,6
    80001244:	004006b7          	lui	a3,0x400
    80001248:	0c000637          	lui	a2,0xc000
    8000124c:	85b2                	mv	a1,a2
    8000124e:	8526                	mv	a0,s1
    80001250:	00000097          	auipc	ra,0x0
    80001254:	f7a080e7          	jalr	-134(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001258:	4729                	li	a4,10
    8000125a:	80007697          	auipc	a3,0x80007
    8000125e:	da668693          	addi	a3,a3,-602 # 8000 <_entry-0x7fff8000>
    80001262:	4605                	li	a2,1
    80001264:	067e                	slli	a2,a2,0x1f
    80001266:	85b2                	mv	a1,a2
    80001268:	8526                	mv	a0,s1
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f60080e7          	jalr	-160(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001272:	4719                	li	a4,6
    80001274:	00007697          	auipc	a3,0x7
    80001278:	d8c68693          	addi	a3,a3,-628 # 80008000 <etext>
    8000127c:	47c5                	li	a5,17
    8000127e:	07ee                	slli	a5,a5,0x1b
    80001280:	40d786b3          	sub	a3,a5,a3
    80001284:	00007617          	auipc	a2,0x7
    80001288:	d7c60613          	addi	a2,a2,-644 # 80008000 <etext>
    8000128c:	85b2                	mv	a1,a2
    8000128e:	8526                	mv	a0,s1
    80001290:	00000097          	auipc	ra,0x0
    80001294:	f3a080e7          	jalr	-198(ra) # 800011ca <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001298:	4729                	li	a4,10
    8000129a:	6685                	lui	a3,0x1
    8000129c:	00006617          	auipc	a2,0x6
    800012a0:	d6460613          	addi	a2,a2,-668 # 80007000 <_trampoline>
    800012a4:	040005b7          	lui	a1,0x4000
    800012a8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012aa:	05b2                	slli	a1,a1,0xc
    800012ac:	8526                	mv	a0,s1
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f1c080e7          	jalr	-228(ra) # 800011ca <kvmmap>
  proc_mapstacks(kpgtbl);
    800012b6:	8526                	mv	a0,s1
    800012b8:	00000097          	auipc	ra,0x0
    800012bc:	62c080e7          	jalr	1580(ra) # 800018e4 <proc_mapstacks>
}
    800012c0:	8526                	mv	a0,s1
    800012c2:	60e2                	ld	ra,24(sp)
    800012c4:	6442                	ld	s0,16(sp)
    800012c6:	64a2                	ld	s1,8(sp)
    800012c8:	6105                	addi	sp,sp,32
    800012ca:	8082                	ret

00000000800012cc <kvminit>:
{
    800012cc:	1141                	addi	sp,sp,-16
    800012ce:	e406                	sd	ra,8(sp)
    800012d0:	e022                	sd	s0,0(sp)
    800012d2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012d4:	00000097          	auipc	ra,0x0
    800012d8:	f26080e7          	jalr	-218(ra) # 800011fa <kvmmake>
    800012dc:	0000b797          	auipc	a5,0xb
    800012e0:	d4a7b223          	sd	a0,-700(a5) # 8000c020 <kernel_pagetable>
}
    800012e4:	60a2                	ld	ra,8(sp)
    800012e6:	6402                	ld	s0,0(sp)
    800012e8:	0141                	addi	sp,sp,16
    800012ea:	8082                	ret

00000000800012ec <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012ec:	715d                	addi	sp,sp,-80
    800012ee:	e486                	sd	ra,72(sp)
    800012f0:	e0a2                	sd	s0,64(sp)
    800012f2:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012f4:	03459793          	slli	a5,a1,0x34
    800012f8:	e39d                	bnez	a5,8000131e <uvmunmap+0x32>
    800012fa:	f84a                	sd	s2,48(sp)
    800012fc:	f44e                	sd	s3,40(sp)
    800012fe:	f052                	sd	s4,32(sp)
    80001300:	ec56                	sd	s5,24(sp)
    80001302:	e85a                	sd	s6,16(sp)
    80001304:	e45e                	sd	s7,8(sp)
    80001306:	8a2a                	mv	s4,a0
    80001308:	892e                	mv	s2,a1
    8000130a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	0632                	slli	a2,a2,0xc
    8000130e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001312:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001314:	6b05                	lui	s6,0x1
    80001316:	0935fb63          	bgeu	a1,s3,800013ac <uvmunmap+0xc0>
    8000131a:	fc26                	sd	s1,56(sp)
    8000131c:	a8a9                	j	80001376 <uvmunmap+0x8a>
    8000131e:	fc26                	sd	s1,56(sp)
    80001320:	f84a                	sd	s2,48(sp)
    80001322:	f44e                	sd	s3,40(sp)
    80001324:	f052                	sd	s4,32(sp)
    80001326:	ec56                	sd	s5,24(sp)
    80001328:	e85a                	sd	s6,16(sp)
    8000132a:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    8000132c:	00007517          	auipc	a0,0x7
    80001330:	db450513          	addi	a0,a0,-588 # 800080e0 <etext+0xe0>
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	222080e7          	jalr	546(ra) # 80000556 <panic>
      panic("uvmunmap: walk");
    8000133c:	00007517          	auipc	a0,0x7
    80001340:	dbc50513          	addi	a0,a0,-580 # 800080f8 <etext+0xf8>
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	212080e7          	jalr	530(ra) # 80000556 <panic>
      panic("uvmunmap: not mapped");
    8000134c:	00007517          	auipc	a0,0x7
    80001350:	dbc50513          	addi	a0,a0,-580 # 80008108 <etext+0x108>
    80001354:	fffff097          	auipc	ra,0xfffff
    80001358:	202080e7          	jalr	514(ra) # 80000556 <panic>
      panic("uvmunmap: not a leaf");
    8000135c:	00007517          	auipc	a0,0x7
    80001360:	dc450513          	addi	a0,a0,-572 # 80008120 <etext+0x120>
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	1f2080e7          	jalr	498(ra) # 80000556 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000136c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001370:	995a                	add	s2,s2,s6
    80001372:	03397c63          	bgeu	s2,s3,800013aa <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001376:	4601                	li	a2,0
    80001378:	85ca                	mv	a1,s2
    8000137a:	8552                	mv	a0,s4
    8000137c:	00000097          	auipc	ra,0x0
    80001380:	cc8080e7          	jalr	-824(ra) # 80001044 <walk>
    80001384:	84aa                	mv	s1,a0
    80001386:	d95d                	beqz	a0,8000133c <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001388:	6108                	ld	a0,0(a0)
    8000138a:	00157793          	andi	a5,a0,1
    8000138e:	dfdd                	beqz	a5,8000134c <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001390:	3ff57793          	andi	a5,a0,1023
    80001394:	fd7784e3          	beq	a5,s7,8000135c <uvmunmap+0x70>
    if(do_free){
    80001398:	fc0a8ae3          	beqz	s5,8000136c <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000139c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000139e:	0532                	slli	a0,a0,0xc
    800013a0:	fffff097          	auipc	ra,0xfffff
    800013a4:	6ac080e7          	jalr	1708(ra) # 80000a4c <kfree>
    800013a8:	b7d1                	j	8000136c <uvmunmap+0x80>
    800013aa:	74e2                	ld	s1,56(sp)
    800013ac:	7942                	ld	s2,48(sp)
    800013ae:	79a2                	ld	s3,40(sp)
    800013b0:	7a02                	ld	s4,32(sp)
    800013b2:	6ae2                	ld	s5,24(sp)
    800013b4:	6b42                	ld	s6,16(sp)
    800013b6:	6ba2                	ld	s7,8(sp)
  }
}
    800013b8:	60a6                	ld	ra,72(sp)
    800013ba:	6406                	ld	s0,64(sp)
    800013bc:	6161                	addi	sp,sp,80
    800013be:	8082                	ret

00000000800013c0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013c0:	1101                	addi	sp,sp,-32
    800013c2:	ec06                	sd	ra,24(sp)
    800013c4:	e822                	sd	s0,16(sp)
    800013c6:	e426                	sd	s1,8(sp)
    800013c8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	786080e7          	jalr	1926(ra) # 80000b50 <kalloc>
    800013d2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013d4:	c519                	beqz	a0,800013e2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013d6:	6605                	lui	a2,0x1
    800013d8:	4581                	li	a1,0
    800013da:	00000097          	auipc	ra,0x0
    800013de:	972080e7          	jalr	-1678(ra) # 80000d4c <memset>
  return pagetable;
}
    800013e2:	8526                	mv	a0,s1
    800013e4:	60e2                	ld	ra,24(sp)
    800013e6:	6442                	ld	s0,16(sp)
    800013e8:	64a2                	ld	s1,8(sp)
    800013ea:	6105                	addi	sp,sp,32
    800013ec:	8082                	ret

00000000800013ee <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013ee:	7179                	addi	sp,sp,-48
    800013f0:	f406                	sd	ra,40(sp)
    800013f2:	f022                	sd	s0,32(sp)
    800013f4:	ec26                	sd	s1,24(sp)
    800013f6:	e84a                	sd	s2,16(sp)
    800013f8:	e44e                	sd	s3,8(sp)
    800013fa:	e052                	sd	s4,0(sp)
    800013fc:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013fe:	6785                	lui	a5,0x1
    80001400:	04f67863          	bgeu	a2,a5,80001450 <uvminit+0x62>
    80001404:	89aa                	mv	s3,a0
    80001406:	8a2e                	mv	s4,a1
    80001408:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000140a:	fffff097          	auipc	ra,0xfffff
    8000140e:	746080e7          	jalr	1862(ra) # 80000b50 <kalloc>
    80001412:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001414:	6605                	lui	a2,0x1
    80001416:	4581                	li	a1,0
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	934080e7          	jalr	-1740(ra) # 80000d4c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001420:	4779                	li	a4,30
    80001422:	86ca                	mv	a3,s2
    80001424:	6605                	lui	a2,0x1
    80001426:	4581                	li	a1,0
    80001428:	854e                	mv	a0,s3
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	cfe080e7          	jalr	-770(ra) # 80001128 <mappages>
  memmove(mem, src, sz);
    80001432:	8626                	mv	a2,s1
    80001434:	85d2                	mv	a1,s4
    80001436:	854a                	mv	a0,s2
    80001438:	00000097          	auipc	ra,0x0
    8000143c:	974080e7          	jalr	-1676(ra) # 80000dac <memmove>
}
    80001440:	70a2                	ld	ra,40(sp)
    80001442:	7402                	ld	s0,32(sp)
    80001444:	64e2                	ld	s1,24(sp)
    80001446:	6942                	ld	s2,16(sp)
    80001448:	69a2                	ld	s3,8(sp)
    8000144a:	6a02                	ld	s4,0(sp)
    8000144c:	6145                	addi	sp,sp,48
    8000144e:	8082                	ret
    panic("inituvm: more than a page");
    80001450:	00007517          	auipc	a0,0x7
    80001454:	ce850513          	addi	a0,a0,-792 # 80008138 <etext+0x138>
    80001458:	fffff097          	auipc	ra,0xfffff
    8000145c:	0fe080e7          	jalr	254(ra) # 80000556 <panic>

0000000080001460 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001460:	1101                	addi	sp,sp,-32
    80001462:	ec06                	sd	ra,24(sp)
    80001464:	e822                	sd	s0,16(sp)
    80001466:	e426                	sd	s1,8(sp)
    80001468:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000146a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000146c:	00b67d63          	bgeu	a2,a1,80001486 <uvmdealloc+0x26>
    80001470:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001472:	6785                	lui	a5,0x1
    80001474:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001476:	00f60733          	add	a4,a2,a5
    8000147a:	76fd                	lui	a3,0xfffff
    8000147c:	8f75                	and	a4,a4,a3
    8000147e:	97ae                	add	a5,a5,a1
    80001480:	8ff5                	and	a5,a5,a3
    80001482:	00f76863          	bltu	a4,a5,80001492 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001486:	8526                	mv	a0,s1
    80001488:	60e2                	ld	ra,24(sp)
    8000148a:	6442                	ld	s0,16(sp)
    8000148c:	64a2                	ld	s1,8(sp)
    8000148e:	6105                	addi	sp,sp,32
    80001490:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001492:	8f99                	sub	a5,a5,a4
    80001494:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001496:	4685                	li	a3,1
    80001498:	0007861b          	sext.w	a2,a5
    8000149c:	85ba                	mv	a1,a4
    8000149e:	00000097          	auipc	ra,0x0
    800014a2:	e4e080e7          	jalr	-434(ra) # 800012ec <uvmunmap>
    800014a6:	b7c5                	j	80001486 <uvmdealloc+0x26>

00000000800014a8 <uvmalloc>:
  if(newsz < oldsz)
    800014a8:	0ab66c63          	bltu	a2,a1,80001560 <uvmalloc+0xb8>
{
    800014ac:	715d                	addi	sp,sp,-80
    800014ae:	e486                	sd	ra,72(sp)
    800014b0:	e0a2                	sd	s0,64(sp)
    800014b2:	f84a                	sd	s2,48(sp)
    800014b4:	f052                	sd	s4,32(sp)
    800014b6:	ec56                	sd	s5,24(sp)
    800014b8:	e45e                	sd	s7,8(sp)
    800014ba:	0880                	addi	s0,sp,80
    800014bc:	8aaa                	mv	s5,a0
    800014be:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014c0:	6785                	lui	a5,0x1
    800014c2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014c4:	95be                	add	a1,a1,a5
    800014c6:	77fd                	lui	a5,0xfffff
    800014c8:	00f5f933          	and	s2,a1,a5
    800014cc:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ce:	08c97b63          	bgeu	s2,a2,80001564 <uvmalloc+0xbc>
    800014d2:	fc26                	sd	s1,56(sp)
    800014d4:	f44e                	sd	s3,40(sp)
    800014d6:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800014d8:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014da:	4b79                	li	s6,30
    mem = kalloc();
    800014dc:	fffff097          	auipc	ra,0xfffff
    800014e0:	674080e7          	jalr	1652(ra) # 80000b50 <kalloc>
    800014e4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014e6:	c90d                	beqz	a0,80001518 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014e8:	864e                	mv	a2,s3
    800014ea:	4581                	li	a1,0
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	860080e7          	jalr	-1952(ra) # 80000d4c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014f4:	875a                	mv	a4,s6
    800014f6:	86a6                	mv	a3,s1
    800014f8:	864e                	mv	a2,s3
    800014fa:	85ca                	mv	a1,s2
    800014fc:	8556                	mv	a0,s5
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	c2a080e7          	jalr	-982(ra) # 80001128 <mappages>
    80001506:	ed05                	bnez	a0,8000153e <uvmalloc+0x96>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001508:	994e                	add	s2,s2,s3
    8000150a:	fd4969e3          	bltu	s2,s4,800014dc <uvmalloc+0x34>
  return newsz;
    8000150e:	8552                	mv	a0,s4
    80001510:	74e2                	ld	s1,56(sp)
    80001512:	79a2                	ld	s3,40(sp)
    80001514:	6b42                	ld	s6,16(sp)
    80001516:	a821                	j	8000152e <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	865e                	mv	a2,s7
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f42080e7          	jalr	-190(ra) # 80001460 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74e2                	ld	s1,56(sp)
    8000152a:	79a2                	ld	s3,40(sp)
    8000152c:	6b42                	ld	s6,16(sp)
}
    8000152e:	60a6                	ld	ra,72(sp)
    80001530:	6406                	ld	s0,64(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	7a02                	ld	s4,32(sp)
    80001536:	6ae2                	ld	s5,24(sp)
    80001538:	6ba2                	ld	s7,8(sp)
    8000153a:	6161                	addi	sp,sp,80
    8000153c:	8082                	ret
      kfree(mem);
    8000153e:	8526                	mv	a0,s1
    80001540:	fffff097          	auipc	ra,0xfffff
    80001544:	50c080e7          	jalr	1292(ra) # 80000a4c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001548:	865e                	mv	a2,s7
    8000154a:	85ca                	mv	a1,s2
    8000154c:	8556                	mv	a0,s5
    8000154e:	00000097          	auipc	ra,0x0
    80001552:	f12080e7          	jalr	-238(ra) # 80001460 <uvmdealloc>
      return 0;
    80001556:	4501                	li	a0,0
    80001558:	74e2                	ld	s1,56(sp)
    8000155a:	79a2                	ld	s3,40(sp)
    8000155c:	6b42                	ld	s6,16(sp)
    8000155e:	bfc1                	j	8000152e <uvmalloc+0x86>
    return oldsz;
    80001560:	852e                	mv	a0,a1
}
    80001562:	8082                	ret
  return newsz;
    80001564:	8532                	mv	a0,a2
    80001566:	b7e1                	j	8000152e <uvmalloc+0x86>

0000000080001568 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001568:	7179                	addi	sp,sp,-48
    8000156a:	f406                	sd	ra,40(sp)
    8000156c:	f022                	sd	s0,32(sp)
    8000156e:	ec26                	sd	s1,24(sp)
    80001570:	e84a                	sd	s2,16(sp)
    80001572:	e44e                	sd	s3,8(sp)
    80001574:	1800                	addi	s0,sp,48
    80001576:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001578:	84aa                	mv	s1,a0
    8000157a:	6905                	lui	s2,0x1
    8000157c:	992a                	add	s2,s2,a0
    8000157e:	a821                	j	80001596 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    80001580:	00007517          	auipc	a0,0x7
    80001584:	bd850513          	addi	a0,a0,-1064 # 80008158 <etext+0x158>
    80001588:	fffff097          	auipc	ra,0xfffff
    8000158c:	fce080e7          	jalr	-50(ra) # 80000556 <panic>
  for(int i = 0; i < 512; i++){
    80001590:	04a1                	addi	s1,s1,8
    80001592:	03248363          	beq	s1,s2,800015b8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001596:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001598:	0017f713          	andi	a4,a5,1
    8000159c:	db75                	beqz	a4,80001590 <freewalk+0x28>
    8000159e:	00e7f713          	andi	a4,a5,14
    800015a2:	ff79                	bnez	a4,80001580 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800015a4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015a6:	00c79513          	slli	a0,a5,0xc
    800015aa:	00000097          	auipc	ra,0x0
    800015ae:	fbe080e7          	jalr	-66(ra) # 80001568 <freewalk>
      pagetable[i] = 0;
    800015b2:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015b6:	bfe9                	j	80001590 <freewalk+0x28>
    }
  }
  kfree((void*)pagetable);
    800015b8:	854e                	mv	a0,s3
    800015ba:	fffff097          	auipc	ra,0xfffff
    800015be:	492080e7          	jalr	1170(ra) # 80000a4c <kfree>
}
    800015c2:	70a2                	ld	ra,40(sp)
    800015c4:	7402                	ld	s0,32(sp)
    800015c6:	64e2                	ld	s1,24(sp)
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	69a2                	ld	s3,8(sp)
    800015cc:	6145                	addi	sp,sp,48
    800015ce:	8082                	ret

00000000800015d0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015d0:	1101                	addi	sp,sp,-32
    800015d2:	ec06                	sd	ra,24(sp)
    800015d4:	e822                	sd	s0,16(sp)
    800015d6:	e426                	sd	s1,8(sp)
    800015d8:	1000                	addi	s0,sp,32
    800015da:	84aa                	mv	s1,a0
  if(sz > 0)
    800015dc:	e999                	bnez	a1,800015f2 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015de:	8526                	mv	a0,s1
    800015e0:	00000097          	auipc	ra,0x0
    800015e4:	f88080e7          	jalr	-120(ra) # 80001568 <freewalk>
}
    800015e8:	60e2                	ld	ra,24(sp)
    800015ea:	6442                	ld	s0,16(sp)
    800015ec:	64a2                	ld	s1,8(sp)
    800015ee:	6105                	addi	sp,sp,32
    800015f0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015f2:	6785                	lui	a5,0x1
    800015f4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015f6:	95be                	add	a1,a1,a5
    800015f8:	4685                	li	a3,1
    800015fa:	00c5d613          	srli	a2,a1,0xc
    800015fe:	4581                	li	a1,0
    80001600:	00000097          	auipc	ra,0x0
    80001604:	cec080e7          	jalr	-788(ra) # 800012ec <uvmunmap>
    80001608:	bfd9                	j	800015de <uvmfree+0xe>

000000008000160a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000160a:	c669                	beqz	a2,800016d4 <uvmcopy+0xca>
{
    8000160c:	715d                	addi	sp,sp,-80
    8000160e:	e486                	sd	ra,72(sp)
    80001610:	e0a2                	sd	s0,64(sp)
    80001612:	fc26                	sd	s1,56(sp)
    80001614:	f84a                	sd	s2,48(sp)
    80001616:	f44e                	sd	s3,40(sp)
    80001618:	f052                	sd	s4,32(sp)
    8000161a:	ec56                	sd	s5,24(sp)
    8000161c:	e85a                	sd	s6,16(sp)
    8000161e:	e45e                	sd	s7,8(sp)
    80001620:	0880                	addi	s0,sp,80
    80001622:	8b2a                	mv	s6,a0
    80001624:	8aae                	mv	s5,a1
    80001626:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001628:	4901                	li	s2,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162a:	6985                	lui	s3,0x1
    if((pte = walk(old, i, 0)) == 0)
    8000162c:	4601                	li	a2,0
    8000162e:	85ca                	mv	a1,s2
    80001630:	855a                	mv	a0,s6
    80001632:	00000097          	auipc	ra,0x0
    80001636:	a12080e7          	jalr	-1518(ra) # 80001044 <walk>
    8000163a:	c139                	beqz	a0,80001680 <uvmcopy+0x76>
    if((*pte & PTE_V) == 0)
    8000163c:	00053b83          	ld	s7,0(a0)
    80001640:	001bf793          	andi	a5,s7,1
    80001644:	c7b1                	beqz	a5,80001690 <uvmcopy+0x86>
    if((mem = kalloc()) == 0)
    80001646:	fffff097          	auipc	ra,0xfffff
    8000164a:	50a080e7          	jalr	1290(ra) # 80000b50 <kalloc>
    8000164e:	84aa                	mv	s1,a0
    80001650:	cd29                	beqz	a0,800016aa <uvmcopy+0xa0>
    pa = PTE2PA(*pte);
    80001652:	00abd593          	srli	a1,s7,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001656:	864e                	mv	a2,s3
    80001658:	05b2                	slli	a1,a1,0xc
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	752080e7          	jalr	1874(ra) # 80000dac <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001662:	3ffbf713          	andi	a4,s7,1023
    80001666:	86a6                	mv	a3,s1
    80001668:	864e                	mv	a2,s3
    8000166a:	85ca                	mv	a1,s2
    8000166c:	8556                	mv	a0,s5
    8000166e:	00000097          	auipc	ra,0x0
    80001672:	aba080e7          	jalr	-1350(ra) # 80001128 <mappages>
    80001676:	e50d                	bnez	a0,800016a0 <uvmcopy+0x96>
  for(i = 0; i < sz; i += PGSIZE){
    80001678:	994e                	add	s2,s2,s3
    8000167a:	fb4969e3          	bltu	s2,s4,8000162c <uvmcopy+0x22>
    8000167e:	a081                	j	800016be <uvmcopy+0xb4>
      panic("uvmcopy: pte should exist");
    80001680:	00007517          	auipc	a0,0x7
    80001684:	ae850513          	addi	a0,a0,-1304 # 80008168 <etext+0x168>
    80001688:	fffff097          	auipc	ra,0xfffff
    8000168c:	ece080e7          	jalr	-306(ra) # 80000556 <panic>
      panic("uvmcopy: page not present");
    80001690:	00007517          	auipc	a0,0x7
    80001694:	af850513          	addi	a0,a0,-1288 # 80008188 <etext+0x188>
    80001698:	fffff097          	auipc	ra,0xfffff
    8000169c:	ebe080e7          	jalr	-322(ra) # 80000556 <panic>
      kfree(mem);
    800016a0:	8526                	mv	a0,s1
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	3aa080e7          	jalr	938(ra) # 80000a4c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016aa:	4685                	li	a3,1
    800016ac:	00c95613          	srli	a2,s2,0xc
    800016b0:	4581                	li	a1,0
    800016b2:	8556                	mv	a0,s5
    800016b4:	00000097          	auipc	ra,0x0
    800016b8:	c38080e7          	jalr	-968(ra) # 800012ec <uvmunmap>
  return -1;
    800016bc:	557d                	li	a0,-1
}
    800016be:	60a6                	ld	ra,72(sp)
    800016c0:	6406                	ld	s0,64(sp)
    800016c2:	74e2                	ld	s1,56(sp)
    800016c4:	7942                	ld	s2,48(sp)
    800016c6:	79a2                	ld	s3,40(sp)
    800016c8:	7a02                	ld	s4,32(sp)
    800016ca:	6ae2                	ld	s5,24(sp)
    800016cc:	6b42                	ld	s6,16(sp)
    800016ce:	6ba2                	ld	s7,8(sp)
    800016d0:	6161                	addi	sp,sp,80
    800016d2:	8082                	ret
  return 0;
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret

00000000800016d8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016d8:	1141                	addi	sp,sp,-16
    800016da:	e406                	sd	ra,8(sp)
    800016dc:	e022                	sd	s0,0(sp)
    800016de:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016e0:	4601                	li	a2,0
    800016e2:	00000097          	auipc	ra,0x0
    800016e6:	962080e7          	jalr	-1694(ra) # 80001044 <walk>
  if(pte == 0)
    800016ea:	c901                	beqz	a0,800016fa <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016ec:	611c                	ld	a5,0(a0)
    800016ee:	9bbd                	andi	a5,a5,-17
    800016f0:	e11c                	sd	a5,0(a0)
}
    800016f2:	60a2                	ld	ra,8(sp)
    800016f4:	6402                	ld	s0,0(sp)
    800016f6:	0141                	addi	sp,sp,16
    800016f8:	8082                	ret
    panic("uvmclear");
    800016fa:	00007517          	auipc	a0,0x7
    800016fe:	aae50513          	addi	a0,a0,-1362 # 800081a8 <etext+0x1a8>
    80001702:	fffff097          	auipc	ra,0xfffff
    80001706:	e54080e7          	jalr	-428(ra) # 80000556 <panic>

000000008000170a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000170a:	c6bd                	beqz	a3,80001778 <copyout+0x6e>
{
    8000170c:	715d                	addi	sp,sp,-80
    8000170e:	e486                	sd	ra,72(sp)
    80001710:	e0a2                	sd	s0,64(sp)
    80001712:	fc26                	sd	s1,56(sp)
    80001714:	f84a                	sd	s2,48(sp)
    80001716:	f44e                	sd	s3,40(sp)
    80001718:	f052                	sd	s4,32(sp)
    8000171a:	ec56                	sd	s5,24(sp)
    8000171c:	e85a                	sd	s6,16(sp)
    8000171e:	e45e                	sd	s7,8(sp)
    80001720:	e062                	sd	s8,0(sp)
    80001722:	0880                	addi	s0,sp,80
    80001724:	8b2a                	mv	s6,a0
    80001726:	8c2e                	mv	s8,a1
    80001728:	8a32                	mv	s4,a2
    8000172a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000172c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000172e:	6a85                	lui	s5,0x1
    80001730:	a015                	j	80001754 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001732:	9562                	add	a0,a0,s8
    80001734:	0004861b          	sext.w	a2,s1
    80001738:	85d2                	mv	a1,s4
    8000173a:	41250533          	sub	a0,a0,s2
    8000173e:	fffff097          	auipc	ra,0xfffff
    80001742:	66e080e7          	jalr	1646(ra) # 80000dac <memmove>

    len -= n;
    80001746:	409989b3          	sub	s3,s3,s1
    src += n;
    8000174a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000174c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001750:	02098263          	beqz	s3,80001774 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001754:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001758:	85ca                	mv	a1,s2
    8000175a:	855a                	mv	a0,s6
    8000175c:	00000097          	auipc	ra,0x0
    80001760:	98e080e7          	jalr	-1650(ra) # 800010ea <walkaddr>
    if(pa0 == 0)
    80001764:	cd01                	beqz	a0,8000177c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001766:	418904b3          	sub	s1,s2,s8
    8000176a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000176c:	fc99f3e3          	bgeu	s3,s1,80001732 <copyout+0x28>
    80001770:	84ce                	mv	s1,s3
    80001772:	b7c1                	j	80001732 <copyout+0x28>
  }
  return 0;
    80001774:	4501                	li	a0,0
    80001776:	a021                	j	8000177e <copyout+0x74>
    80001778:	4501                	li	a0,0
}
    8000177a:	8082                	ret
      return -1;
    8000177c:	557d                	li	a0,-1
}
    8000177e:	60a6                	ld	ra,72(sp)
    80001780:	6406                	ld	s0,64(sp)
    80001782:	74e2                	ld	s1,56(sp)
    80001784:	7942                	ld	s2,48(sp)
    80001786:	79a2                	ld	s3,40(sp)
    80001788:	7a02                	ld	s4,32(sp)
    8000178a:	6ae2                	ld	s5,24(sp)
    8000178c:	6b42                	ld	s6,16(sp)
    8000178e:	6ba2                	ld	s7,8(sp)
    80001790:	6c02                	ld	s8,0(sp)
    80001792:	6161                	addi	sp,sp,80
    80001794:	8082                	ret

0000000080001796 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001796:	caa5                	beqz	a3,80001806 <copyin+0x70>
{
    80001798:	715d                	addi	sp,sp,-80
    8000179a:	e486                	sd	ra,72(sp)
    8000179c:	e0a2                	sd	s0,64(sp)
    8000179e:	fc26                	sd	s1,56(sp)
    800017a0:	f84a                	sd	s2,48(sp)
    800017a2:	f44e                	sd	s3,40(sp)
    800017a4:	f052                	sd	s4,32(sp)
    800017a6:	ec56                	sd	s5,24(sp)
    800017a8:	e85a                	sd	s6,16(sp)
    800017aa:	e45e                	sd	s7,8(sp)
    800017ac:	e062                	sd	s8,0(sp)
    800017ae:	0880                	addi	s0,sp,80
    800017b0:	8b2a                	mv	s6,a0
    800017b2:	8a2e                	mv	s4,a1
    800017b4:	8c32                	mv	s8,a2
    800017b6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017b8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ba:	6a85                	lui	s5,0x1
    800017bc:	a01d                	j	800017e2 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017be:	018505b3          	add	a1,a0,s8
    800017c2:	0004861b          	sext.w	a2,s1
    800017c6:	412585b3          	sub	a1,a1,s2
    800017ca:	8552                	mv	a0,s4
    800017cc:	fffff097          	auipc	ra,0xfffff
    800017d0:	5e0080e7          	jalr	1504(ra) # 80000dac <memmove>

    len -= n;
    800017d4:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017d8:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017da:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017de:	02098263          	beqz	s3,80001802 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017e2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017e6:	85ca                	mv	a1,s2
    800017e8:	855a                	mv	a0,s6
    800017ea:	00000097          	auipc	ra,0x0
    800017ee:	900080e7          	jalr	-1792(ra) # 800010ea <walkaddr>
    if(pa0 == 0)
    800017f2:	cd01                	beqz	a0,8000180a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017f4:	418904b3          	sub	s1,s2,s8
    800017f8:	94d6                	add	s1,s1,s5
    if(n > len)
    800017fa:	fc99f2e3          	bgeu	s3,s1,800017be <copyin+0x28>
    800017fe:	84ce                	mv	s1,s3
    80001800:	bf7d                	j	800017be <copyin+0x28>
  }
  return 0;
    80001802:	4501                	li	a0,0
    80001804:	a021                	j	8000180c <copyin+0x76>
    80001806:	4501                	li	a0,0
}
    80001808:	8082                	ret
      return -1;
    8000180a:	557d                	li	a0,-1
}
    8000180c:	60a6                	ld	ra,72(sp)
    8000180e:	6406                	ld	s0,64(sp)
    80001810:	74e2                	ld	s1,56(sp)
    80001812:	7942                	ld	s2,48(sp)
    80001814:	79a2                	ld	s3,40(sp)
    80001816:	7a02                	ld	s4,32(sp)
    80001818:	6ae2                	ld	s5,24(sp)
    8000181a:	6b42                	ld	s6,16(sp)
    8000181c:	6ba2                	ld	s7,8(sp)
    8000181e:	6c02                	ld	s8,0(sp)
    80001820:	6161                	addi	sp,sp,80
    80001822:	8082                	ret

0000000080001824 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001824:	cad5                	beqz	a3,800018d8 <copyinstr+0xb4>
{
    80001826:	715d                	addi	sp,sp,-80
    80001828:	e486                	sd	ra,72(sp)
    8000182a:	e0a2                	sd	s0,64(sp)
    8000182c:	fc26                	sd	s1,56(sp)
    8000182e:	f84a                	sd	s2,48(sp)
    80001830:	f44e                	sd	s3,40(sp)
    80001832:	f052                	sd	s4,32(sp)
    80001834:	ec56                	sd	s5,24(sp)
    80001836:	e85a                	sd	s6,16(sp)
    80001838:	e45e                	sd	s7,8(sp)
    8000183a:	0880                	addi	s0,sp,80
    8000183c:	8aaa                	mv	s5,a0
    8000183e:	84ae                	mv	s1,a1
    80001840:	8bb2                	mv	s7,a2
    80001842:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001844:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001846:	6a05                	lui	s4,0x1
    80001848:	a82d                	j	80001882 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000184a:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000184e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001850:	0017c793          	xori	a5,a5,1
    80001854:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001858:	60a6                	ld	ra,72(sp)
    8000185a:	6406                	ld	s0,64(sp)
    8000185c:	74e2                	ld	s1,56(sp)
    8000185e:	7942                	ld	s2,48(sp)
    80001860:	79a2                	ld	s3,40(sp)
    80001862:	7a02                	ld	s4,32(sp)
    80001864:	6ae2                	ld	s5,24(sp)
    80001866:	6b42                	ld	s6,16(sp)
    80001868:	6ba2                	ld	s7,8(sp)
    8000186a:	6161                	addi	sp,sp,80
    8000186c:	8082                	ret
    8000186e:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001872:	9726                	add	a4,a4,s1
      --max;
    80001874:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001878:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000187c:	04e58663          	beq	a1,a4,800018c8 <copyinstr+0xa4>
{
    80001880:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001882:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001886:	85ca                	mv	a1,s2
    80001888:	8556                	mv	a0,s5
    8000188a:	00000097          	auipc	ra,0x0
    8000188e:	860080e7          	jalr	-1952(ra) # 800010ea <walkaddr>
    if(pa0 == 0)
    80001892:	cd0d                	beqz	a0,800018cc <copyinstr+0xa8>
    n = PGSIZE - (srcva - va0);
    80001894:	417906b3          	sub	a3,s2,s7
    80001898:	96d2                	add	a3,a3,s4
    if(n > max)
    8000189a:	00d9f363          	bgeu	s3,a3,800018a0 <copyinstr+0x7c>
    8000189e:	86ce                	mv	a3,s3
    while(n > 0){
    800018a0:	ca85                	beqz	a3,800018d0 <copyinstr+0xac>
    char *p = (char *) (pa0 + (srcva - va0));
    800018a2:	01750633          	add	a2,a0,s7
    800018a6:	41260633          	sub	a2,a2,s2
    800018aa:	87a6                	mv	a5,s1
      if(*p == '\0'){
    800018ac:	8e05                	sub	a2,a2,s1
    while(n > 0){
    800018ae:	96a6                	add	a3,a3,s1
    800018b0:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018b2:	00f60733          	add	a4,a2,a5
    800018b6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd6000>
    800018ba:	db41                	beqz	a4,8000184a <copyinstr+0x26>
        *dst = *p;
    800018bc:	00e78023          	sb	a4,0(a5)
      dst++;
    800018c0:	0785                	addi	a5,a5,1
    while(n > 0){
    800018c2:	fed797e3          	bne	a5,a3,800018b0 <copyinstr+0x8c>
    800018c6:	b765                	j	8000186e <copyinstr+0x4a>
    800018c8:	4781                	li	a5,0
    800018ca:	b759                	j	80001850 <copyinstr+0x2c>
      return -1;
    800018cc:	557d                	li	a0,-1
    800018ce:	b769                	j	80001858 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800018d0:	6b85                	lui	s7,0x1
    800018d2:	9bca                	add	s7,s7,s2
    800018d4:	87a6                	mv	a5,s1
    800018d6:	b76d                	j	80001880 <copyinstr+0x5c>
  int got_null = 0;
    800018d8:	4781                	li	a5,0
  if(got_null){
    800018da:	0017c793          	xori	a5,a5,1
    800018de:	40f0053b          	negw	a0,a5
}
    800018e2:	8082                	ret

00000000800018e4 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    800018e4:	715d                	addi	sp,sp,-80
    800018e6:	e486                	sd	ra,72(sp)
    800018e8:	e0a2                	sd	s0,64(sp)
    800018ea:	fc26                	sd	s1,56(sp)
    800018ec:	f84a                	sd	s2,48(sp)
    800018ee:	f44e                	sd	s3,40(sp)
    800018f0:	f052                	sd	s4,32(sp)
    800018f2:	ec56                	sd	s5,24(sp)
    800018f4:	e85a                	sd	s6,16(sp)
    800018f6:	e45e                	sd	s7,8(sp)
    800018f8:	e062                	sd	s8,0(sp)
    800018fa:	0880                	addi	s0,sp,80
    800018fc:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00013497          	auipc	s1,0x13
    80001902:	dd248493          	addi	s1,s1,-558 # 800146d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001906:	8c26                	mv	s8,s1
    80001908:	677d47b7          	lui	a5,0x677d4
    8000190c:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    80001910:	51b3c937          	lui	s2,0x51b3c
    80001914:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    80001918:	1902                	slli	s2,s2,0x20
    8000191a:	993e                	add	s2,s2,a5
    8000191c:	040009b7          	lui	s3,0x4000
    80001920:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001922:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001924:	4b99                	li	s7,6
    80001926:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001928:	00019a97          	auipc	s5,0x19
    8000192c:	ba8a8a93          	addi	s5,s5,-1112 # 8001a4d0 <tickslock>
    char *pa = kalloc();
    80001930:	fffff097          	auipc	ra,0xfffff
    80001934:	220080e7          	jalr	544(ra) # 80000b50 <kalloc>
    80001938:	862a                	mv	a2,a0
    if(pa == 0)
    8000193a:	c131                	beqz	a0,8000197e <proc_mapstacks+0x9a>
    uint64 va = KSTACK((int) (p - proc));
    8000193c:	418485b3          	sub	a1,s1,s8
    80001940:	858d                	srai	a1,a1,0x3
    80001942:	032585b3          	mul	a1,a1,s2
    80001946:	05b6                	slli	a1,a1,0xd
    80001948:	6789                	lui	a5,0x2
    8000194a:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000194c:	875e                	mv	a4,s7
    8000194e:	86da                	mv	a3,s6
    80001950:	40b985b3          	sub	a1,s3,a1
    80001954:	8552                	mv	a0,s4
    80001956:	00000097          	auipc	ra,0x0
    8000195a:	874080e7          	jalr	-1932(ra) # 800011ca <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	17848493          	addi	s1,s1,376
    80001962:	fd5497e3          	bne	s1,s5,80001930 <proc_mapstacks+0x4c>
  }
}
    80001966:	60a6                	ld	ra,72(sp)
    80001968:	6406                	ld	s0,64(sp)
    8000196a:	74e2                	ld	s1,56(sp)
    8000196c:	7942                	ld	s2,48(sp)
    8000196e:	79a2                	ld	s3,40(sp)
    80001970:	7a02                	ld	s4,32(sp)
    80001972:	6ae2                	ld	s5,24(sp)
    80001974:	6b42                	ld	s6,16(sp)
    80001976:	6ba2                	ld	s7,8(sp)
    80001978:	6c02                	ld	s8,0(sp)
    8000197a:	6161                	addi	sp,sp,80
    8000197c:	8082                	ret
      panic("kalloc");
    8000197e:	00007517          	auipc	a0,0x7
    80001982:	83a50513          	addi	a0,a0,-1990 # 800081b8 <etext+0x1b8>
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	bd0080e7          	jalr	-1072(ra) # 80000556 <panic>

000000008000198e <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000198e:	7139                	addi	sp,sp,-64
    80001990:	fc06                	sd	ra,56(sp)
    80001992:	f822                	sd	s0,48(sp)
    80001994:	f426                	sd	s1,40(sp)
    80001996:	f04a                	sd	s2,32(sp)
    80001998:	ec4e                	sd	s3,24(sp)
    8000199a:	e852                	sd	s4,16(sp)
    8000199c:	e456                	sd	s5,8(sp)
    8000199e:	e05a                	sd	s6,0(sp)
    800019a0:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800019a2:	00007597          	auipc	a1,0x7
    800019a6:	81e58593          	addi	a1,a1,-2018 # 800081c0 <etext+0x1c0>
    800019aa:	00013517          	auipc	a0,0x13
    800019ae:	8f650513          	addi	a0,a0,-1802 # 800142a0 <pid_lock>
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	208080e7          	jalr	520(ra) # 80000bba <initlock>
  initlock(&wait_lock, "wait_lock");
    800019ba:	00007597          	auipc	a1,0x7
    800019be:	80e58593          	addi	a1,a1,-2034 # 800081c8 <etext+0x1c8>
    800019c2:	00013517          	auipc	a0,0x13
    800019c6:	8f650513          	addi	a0,a0,-1802 # 800142b8 <wait_lock>
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	1f0080e7          	jalr	496(ra) # 80000bba <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d2:	00013497          	auipc	s1,0x13
    800019d6:	cfe48493          	addi	s1,s1,-770 # 800146d0 <proc>
      initlock(&p->lock, "proc");
    800019da:	00006b17          	auipc	s6,0x6
    800019de:	7feb0b13          	addi	s6,s6,2046 # 800081d8 <etext+0x1d8>
      p->kstack = KSTACK((int) (p - proc));
    800019e2:	8aa6                	mv	s5,s1
    800019e4:	677d47b7          	lui	a5,0x677d4
    800019e8:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    800019ec:	51b3c937          	lui	s2,0x51b3c
    800019f0:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    800019f4:	1902                	slli	s2,s2,0x20
    800019f6:	993e                	add	s2,s2,a5
    800019f8:	040009b7          	lui	s3,0x4000
    800019fc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019fe:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a00:	00019a17          	auipc	s4,0x19
    80001a04:	ad0a0a13          	addi	s4,s4,-1328 # 8001a4d0 <tickslock>
      initlock(&p->lock, "proc");
    80001a08:	85da                	mv	a1,s6
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	1ae080e7          	jalr	430(ra) # 80000bba <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001a14:	415487b3          	sub	a5,s1,s5
    80001a18:	878d                	srai	a5,a5,0x3
    80001a1a:	032787b3          	mul	a5,a5,s2
    80001a1e:	07b6                	slli	a5,a5,0xd
    80001a20:	6709                	lui	a4,0x2
    80001a22:	9fb9                	addw	a5,a5,a4
    80001a24:	40f987b3          	sub	a5,s3,a5
    80001a28:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a2a:	17848493          	addi	s1,s1,376
    80001a2e:	fd449de3          	bne	s1,s4,80001a08 <procinit+0x7a>
  }
}
    80001a32:	70e2                	ld	ra,56(sp)
    80001a34:	7442                	ld	s0,48(sp)
    80001a36:	74a2                	ld	s1,40(sp)
    80001a38:	7902                	ld	s2,32(sp)
    80001a3a:	69e2                	ld	s3,24(sp)
    80001a3c:	6a42                	ld	s4,16(sp)
    80001a3e:	6aa2                	ld	s5,8(sp)
    80001a40:	6b02                	ld	s6,0(sp)
    80001a42:	6121                	addi	sp,sp,64
    80001a44:	8082                	ret

0000000080001a46 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a46:	1141                	addi	sp,sp,-16
    80001a48:	e406                	sd	ra,8(sp)
    80001a4a:	e022                	sd	s0,0(sp)
    80001a4c:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a4e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a50:	2501                	sext.w	a0,a0
    80001a52:	60a2                	ld	ra,8(sp)
    80001a54:	6402                	ld	s0,0(sp)
    80001a56:	0141                	addi	sp,sp,16
    80001a58:	8082                	ret

0000000080001a5a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a5a:	1141                	addi	sp,sp,-16
    80001a5c:	e406                	sd	ra,8(sp)
    80001a5e:	e022                	sd	s0,0(sp)
    80001a60:	0800                	addi	s0,sp,16
    80001a62:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a64:	2781                	sext.w	a5,a5
    80001a66:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a68:	00013517          	auipc	a0,0x13
    80001a6c:	86850513          	addi	a0,a0,-1944 # 800142d0 <cpus>
    80001a70:	953e                	add	a0,a0,a5
    80001a72:	60a2                	ld	ra,8(sp)
    80001a74:	6402                	ld	s0,0(sp)
    80001a76:	0141                	addi	sp,sp,16
    80001a78:	8082                	ret

0000000080001a7a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a7a:	1101                	addi	sp,sp,-32
    80001a7c:	ec06                	sd	ra,24(sp)
    80001a7e:	e822                	sd	s0,16(sp)
    80001a80:	e426                	sd	s1,8(sp)
    80001a82:	1000                	addi	s0,sp,32
  push_off();
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	180080e7          	jalr	384(ra) # 80000c04 <push_off>
    80001a8c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a8e:	2781                	sext.w	a5,a5
    80001a90:	079e                	slli	a5,a5,0x7
    80001a92:	00013717          	auipc	a4,0x13
    80001a96:	80e70713          	addi	a4,a4,-2034 # 800142a0 <pid_lock>
    80001a9a:	97ba                	add	a5,a5,a4
    80001a9c:	7b9c                	ld	a5,48(a5)
    80001a9e:	84be                	mv	s1,a5
  pop_off();
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	208080e7          	jalr	520(ra) # 80000ca8 <pop_off>
  return p;
}
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	60e2                	ld	ra,24(sp)
    80001aac:	6442                	ld	s0,16(sp)
    80001aae:	64a2                	ld	s1,8(sp)
    80001ab0:	6105                	addi	sp,sp,32
    80001ab2:	8082                	ret

0000000080001ab4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001ab4:	1141                	addi	sp,sp,-16
    80001ab6:	e406                	sd	ra,8(sp)
    80001ab8:	e022                	sd	s0,0(sp)
    80001aba:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001abc:	00000097          	auipc	ra,0x0
    80001ac0:	fbe080e7          	jalr	-66(ra) # 80001a7a <myproc>
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	240080e7          	jalr	576(ra) # 80000d04 <release>

  if (first) {
    80001acc:	00009797          	auipc	a5,0x9
    80001ad0:	6947a783          	lw	a5,1684(a5) # 8000b160 <first.1>
    80001ad4:	eb89                	bnez	a5,80001ae6 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ad6:	00001097          	auipc	ra,0x1
    80001ada:	e50080e7          	jalr	-432(ra) # 80002926 <usertrapret>
}
    80001ade:	60a2                	ld	ra,8(sp)
    80001ae0:	6402                	ld	s0,0(sp)
    80001ae2:	0141                	addi	sp,sp,16
    80001ae4:	8082                	ret
    first = 0;
    80001ae6:	00009797          	auipc	a5,0x9
    80001aea:	6607ad23          	sw	zero,1658(a5) # 8000b160 <first.1>
    fsinit(ROOTDEV);
    80001aee:	4505                	li	a0,1
    80001af0:	00002097          	auipc	ra,0x2
    80001af4:	be0080e7          	jalr	-1056(ra) # 800036d0 <fsinit>
    80001af8:	bff9                	j	80001ad6 <forkret+0x22>

0000000080001afa <allocpid>:
allocpid() {
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b04:	00012517          	auipc	a0,0x12
    80001b08:	79c50513          	addi	a0,a0,1948 # 800142a0 <pid_lock>
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	148080e7          	jalr	328(ra) # 80000c54 <acquire>
  pid = nextpid;
    80001b14:	00009797          	auipc	a5,0x9
    80001b18:	65078793          	addi	a5,a5,1616 # 8000b164 <nextpid>
    80001b1c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b1e:	0014871b          	addiw	a4,s1,1
    80001b22:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b24:	00012517          	auipc	a0,0x12
    80001b28:	77c50513          	addi	a0,a0,1916 # 800142a0 <pid_lock>
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	1d8080e7          	jalr	472(ra) # 80000d04 <release>
}
    80001b34:	8526                	mv	a0,s1
    80001b36:	60e2                	ld	ra,24(sp)
    80001b38:	6442                	ld	s0,16(sp)
    80001b3a:	64a2                	ld	s1,8(sp)
    80001b3c:	6105                	addi	sp,sp,32
    80001b3e:	8082                	ret

0000000080001b40 <proc_pagetable>:
{
    80001b40:	1101                	addi	sp,sp,-32
    80001b42:	ec06                	sd	ra,24(sp)
    80001b44:	e822                	sd	s0,16(sp)
    80001b46:	e426                	sd	s1,8(sp)
    80001b48:	e04a                	sd	s2,0(sp)
    80001b4a:	1000                	addi	s0,sp,32
    80001b4c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b4e:	00000097          	auipc	ra,0x0
    80001b52:	872080e7          	jalr	-1934(ra) # 800013c0 <uvmcreate>
    80001b56:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b58:	c121                	beqz	a0,80001b98 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b5a:	4729                	li	a4,10
    80001b5c:	00005697          	auipc	a3,0x5
    80001b60:	4a468693          	addi	a3,a3,1188 # 80007000 <_trampoline>
    80001b64:	6605                	lui	a2,0x1
    80001b66:	040005b7          	lui	a1,0x4000
    80001b6a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b6c:	05b2                	slli	a1,a1,0xc
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	5ba080e7          	jalr	1466(ra) # 80001128 <mappages>
    80001b76:	02054863          	bltz	a0,80001ba6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b7a:	4719                	li	a4,6
    80001b7c:	05893683          	ld	a3,88(s2)
    80001b80:	6605                	lui	a2,0x1
    80001b82:	020005b7          	lui	a1,0x2000
    80001b86:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b88:	05b6                	slli	a1,a1,0xd
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	59c080e7          	jalr	1436(ra) # 80001128 <mappages>
    80001b94:	02054163          	bltz	a0,80001bb6 <proc_pagetable+0x76>
}
    80001b98:	8526                	mv	a0,s1
    80001b9a:	60e2                	ld	ra,24(sp)
    80001b9c:	6442                	ld	s0,16(sp)
    80001b9e:	64a2                	ld	s1,8(sp)
    80001ba0:	6902                	ld	s2,0(sp)
    80001ba2:	6105                	addi	sp,sp,32
    80001ba4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ba6:	4581                	li	a1,0
    80001ba8:	8526                	mv	a0,s1
    80001baa:	00000097          	auipc	ra,0x0
    80001bae:	a26080e7          	jalr	-1498(ra) # 800015d0 <uvmfree>
    return 0;
    80001bb2:	4481                	li	s1,0
    80001bb4:	b7d5                	j	80001b98 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb6:	4681                	li	a3,0
    80001bb8:	4605                	li	a2,1
    80001bba:	040005b7          	lui	a1,0x4000
    80001bbe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bc0:	05b2                	slli	a1,a1,0xc
    80001bc2:	8526                	mv	a0,s1
    80001bc4:	fffff097          	auipc	ra,0xfffff
    80001bc8:	728080e7          	jalr	1832(ra) # 800012ec <uvmunmap>
    uvmfree(pagetable, 0);
    80001bcc:	4581                	li	a1,0
    80001bce:	8526                	mv	a0,s1
    80001bd0:	00000097          	auipc	ra,0x0
    80001bd4:	a00080e7          	jalr	-1536(ra) # 800015d0 <uvmfree>
    return 0;
    80001bd8:	4481                	li	s1,0
    80001bda:	bf7d                	j	80001b98 <proc_pagetable+0x58>

0000000080001bdc <proc_freepagetable>:
{
    80001bdc:	1101                	addi	sp,sp,-32
    80001bde:	ec06                	sd	ra,24(sp)
    80001be0:	e822                	sd	s0,16(sp)
    80001be2:	e426                	sd	s1,8(sp)
    80001be4:	e04a                	sd	s2,0(sp)
    80001be6:	1000                	addi	s0,sp,32
    80001be8:	84aa                	mv	s1,a0
    80001bea:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bec:	4681                	li	a3,0
    80001bee:	4605                	li	a2,1
    80001bf0:	040005b7          	lui	a1,0x4000
    80001bf4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bf6:	05b2                	slli	a1,a1,0xc
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	6f4080e7          	jalr	1780(ra) # 800012ec <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c00:	4681                	li	a3,0
    80001c02:	4605                	li	a2,1
    80001c04:	020005b7          	lui	a1,0x2000
    80001c08:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c0a:	05b6                	slli	a1,a1,0xd
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	6de080e7          	jalr	1758(ra) # 800012ec <uvmunmap>
  uvmfree(pagetable, sz);
    80001c16:	85ca                	mv	a1,s2
    80001c18:	8526                	mv	a0,s1
    80001c1a:	00000097          	auipc	ra,0x0
    80001c1e:	9b6080e7          	jalr	-1610(ra) # 800015d0 <uvmfree>
}
    80001c22:	60e2                	ld	ra,24(sp)
    80001c24:	6442                	ld	s0,16(sp)
    80001c26:	64a2                	ld	s1,8(sp)
    80001c28:	6902                	ld	s2,0(sp)
    80001c2a:	6105                	addi	sp,sp,32
    80001c2c:	8082                	ret

0000000080001c2e <freeproc>:
{
    80001c2e:	1101                	addi	sp,sp,-32
    80001c30:	ec06                	sd	ra,24(sp)
    80001c32:	e822                	sd	s0,16(sp)
    80001c34:	e426                	sd	s1,8(sp)
    80001c36:	1000                	addi	s0,sp,32
    80001c38:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c3a:	6d28                	ld	a0,88(a0)
    80001c3c:	c509                	beqz	a0,80001c46 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	e0e080e7          	jalr	-498(ra) # 80000a4c <kfree>
  p->trapframe = 0;
    80001c46:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c4a:	68a8                	ld	a0,80(s1)
    80001c4c:	c511                	beqz	a0,80001c58 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c4e:	64ac                	ld	a1,72(s1)
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	f8c080e7          	jalr	-116(ra) # 80001bdc <proc_freepagetable>
  p->pagetable = 0;
    80001c58:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c5c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c60:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c64:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c68:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c6c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c70:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c74:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c78:	0004ac23          	sw	zero,24(s1)
}
    80001c7c:	60e2                	ld	ra,24(sp)
    80001c7e:	6442                	ld	s0,16(sp)
    80001c80:	64a2                	ld	s1,8(sp)
    80001c82:	6105                	addi	sp,sp,32
    80001c84:	8082                	ret

0000000080001c86 <allocproc>:
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	e04a                	sd	s2,0(sp)
    80001c90:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c92:	00013497          	auipc	s1,0x13
    80001c96:	a3e48493          	addi	s1,s1,-1474 # 800146d0 <proc>
    80001c9a:	00019917          	auipc	s2,0x19
    80001c9e:	83690913          	addi	s2,s2,-1994 # 8001a4d0 <tickslock>
    acquire(&p->lock);
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	fb0080e7          	jalr	-80(ra) # 80000c54 <acquire>
    if(p->state == UNUSED) {
    80001cac:	4c9c                	lw	a5,24(s1)
    80001cae:	cf81                	beqz	a5,80001cc6 <allocproc+0x40>
      release(&p->lock);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	052080e7          	jalr	82(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cba:	17848493          	addi	s1,s1,376
    80001cbe:	ff2492e3          	bne	s1,s2,80001ca2 <allocproc+0x1c>
  return 0;
    80001cc2:	4481                	li	s1,0
    80001cc4:	a0ad                	j	80001d2e <allocproc+0xa8>
  p->pid = allocpid();
    80001cc6:	00000097          	auipc	ra,0x0
    80001cca:	e34080e7          	jalr	-460(ra) # 80001afa <allocpid>
    80001cce:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cd0:	4785                	li	a5,1
    80001cd2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	e7c080e7          	jalr	-388(ra) # 80000b50 <kalloc>
    80001cdc:	892a                	mv	s2,a0
    80001cde:	eca8                	sd	a0,88(s1)
    80001ce0:	cd31                	beqz	a0,80001d3c <allocproc+0xb6>
  p->pagetable = proc_pagetable(p);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	e5c080e7          	jalr	-420(ra) # 80001b40 <proc_pagetable>
    80001cec:	892a                	mv	s2,a0
    80001cee:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cf0:	c135                	beqz	a0,80001d54 <allocproc+0xce>
  memset(&p->context, 0, sizeof(p->context));
    80001cf2:	07000613          	li	a2,112
    80001cf6:	4581                	li	a1,0
    80001cf8:	06048513          	addi	a0,s1,96
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	050080e7          	jalr	80(ra) # 80000d4c <memset>
  p->context.ra = (uint64)forkret;
    80001d04:	00000797          	auipc	a5,0x0
    80001d08:	db078793          	addi	a5,a5,-592 # 80001ab4 <forkret>
    80001d0c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d0e:	60bc                	ld	a5,64(s1)
    80001d10:	6705                	lui	a4,0x1
    80001d12:	97ba                	add	a5,a5,a4
    80001d14:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001d16:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001d1a:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001d1e:	0000a797          	auipc	a5,0xa
    80001d22:	3127a783          	lw	a5,786(a5) # 8000c030 <ticks>
    80001d26:	16f4a623          	sw	a5,364(s1)
  p->no_of_times_scheduled = 0;
    80001d2a:	1604aa23          	sw	zero,372(s1)
}
    80001d2e:	8526                	mv	a0,s1
    80001d30:	60e2                	ld	ra,24(sp)
    80001d32:	6442                	ld	s0,16(sp)
    80001d34:	64a2                	ld	s1,8(sp)
    80001d36:	6902                	ld	s2,0(sp)
    80001d38:	6105                	addi	sp,sp,32
    80001d3a:	8082                	ret
    freeproc(p);
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	00000097          	auipc	ra,0x0
    80001d42:	ef0080e7          	jalr	-272(ra) # 80001c2e <freeproc>
    release(&p->lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	fbc080e7          	jalr	-68(ra) # 80000d04 <release>
    return 0;
    80001d50:	84ca                	mv	s1,s2
    80001d52:	bff1                	j	80001d2e <allocproc+0xa8>
    freeproc(p);
    80001d54:	8526                	mv	a0,s1
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	ed8080e7          	jalr	-296(ra) # 80001c2e <freeproc>
    release(&p->lock);
    80001d5e:	8526                	mv	a0,s1
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	fa4080e7          	jalr	-92(ra) # 80000d04 <release>
    return 0;
    80001d68:	84ca                	mv	s1,s2
    80001d6a:	b7d1                	j	80001d2e <allocproc+0xa8>

0000000080001d6c <userinit>:
{
    80001d6c:	1101                	addi	sp,sp,-32
    80001d6e:	ec06                	sd	ra,24(sp)
    80001d70:	e822                	sd	s0,16(sp)
    80001d72:	e426                	sd	s1,8(sp)
    80001d74:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	f10080e7          	jalr	-240(ra) # 80001c86 <allocproc>
    80001d7e:	84aa                	mv	s1,a0
  initproc = p;
    80001d80:	0000a797          	auipc	a5,0xa
    80001d84:	2aa7b423          	sd	a0,680(a5) # 8000c028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d88:	03400613          	li	a2,52
    80001d8c:	00009597          	auipc	a1,0x9
    80001d90:	3e458593          	addi	a1,a1,996 # 8000b170 <initcode>
    80001d94:	6928                	ld	a0,80(a0)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	658080e7          	jalr	1624(ra) # 800013ee <uvminit>
  p->sz = PGSIZE;
    80001d9e:	6785                	lui	a5,0x1
    80001da0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001da2:	6cb8                	ld	a4,88(s1)
    80001da4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001da8:	6cb8                	ld	a4,88(s1)
    80001daa:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dac:	4641                	li	a2,16
    80001dae:	00006597          	auipc	a1,0x6
    80001db2:	43258593          	addi	a1,a1,1074 # 800081e0 <etext+0x1e0>
    80001db6:	15848513          	addi	a0,s1,344
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	0ea080e7          	jalr	234(ra) # 80000ea4 <safestrcpy>
  p->cwd = namei("/");
    80001dc2:	00006517          	auipc	a0,0x6
    80001dc6:	42e50513          	addi	a0,a0,1070 # 800081f0 <etext+0x1f0>
    80001dca:	00002097          	auipc	ra,0x2
    80001dce:	36a080e7          	jalr	874(ra) # 80004134 <namei>
    80001dd2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001dd6:	478d                	li	a5,3
    80001dd8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	f28080e7          	jalr	-216(ra) # 80000d04 <release>
}
    80001de4:	60e2                	ld	ra,24(sp)
    80001de6:	6442                	ld	s0,16(sp)
    80001de8:	64a2                	ld	s1,8(sp)
    80001dea:	6105                	addi	sp,sp,32
    80001dec:	8082                	ret

0000000080001dee <growproc>:
{
    80001dee:	1101                	addi	sp,sp,-32
    80001df0:	ec06                	sd	ra,24(sp)
    80001df2:	e822                	sd	s0,16(sp)
    80001df4:	e426                	sd	s1,8(sp)
    80001df6:	e04a                	sd	s2,0(sp)
    80001df8:	1000                	addi	s0,sp,32
    80001dfa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dfc:	00000097          	auipc	ra,0x0
    80001e00:	c7e080e7          	jalr	-898(ra) # 80001a7a <myproc>
    80001e04:	892a                	mv	s2,a0
  sz = p->sz;
    80001e06:	652c                	ld	a1,72(a0)
    80001e08:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001e0c:	00904f63          	bgtz	s1,80001e2a <growproc+0x3c>
  } else if(n < 0){
    80001e10:	0204cd63          	bltz	s1,80001e4a <growproc+0x5c>
  p->sz = sz;
    80001e14:	1782                	slli	a5,a5,0x20
    80001e16:	9381                	srli	a5,a5,0x20
    80001e18:	04f93423          	sd	a5,72(s2)
  return 0;
    80001e1c:	4501                	li	a0,0
}
    80001e1e:	60e2                	ld	ra,24(sp)
    80001e20:	6442                	ld	s0,16(sp)
    80001e22:	64a2                	ld	s1,8(sp)
    80001e24:	6902                	ld	s2,0(sp)
    80001e26:	6105                	addi	sp,sp,32
    80001e28:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e2a:	00f4863b          	addw	a2,s1,a5
    80001e2e:	1602                	slli	a2,a2,0x20
    80001e30:	9201                	srli	a2,a2,0x20
    80001e32:	1582                	slli	a1,a1,0x20
    80001e34:	9181                	srli	a1,a1,0x20
    80001e36:	6928                	ld	a0,80(a0)
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	670080e7          	jalr	1648(ra) # 800014a8 <uvmalloc>
    80001e40:	0005079b          	sext.w	a5,a0
    80001e44:	fbe1                	bnez	a5,80001e14 <growproc+0x26>
      return -1;
    80001e46:	557d                	li	a0,-1
    80001e48:	bfd9                	j	80001e1e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e4a:	00f4863b          	addw	a2,s1,a5
    80001e4e:	1602                	slli	a2,a2,0x20
    80001e50:	9201                	srli	a2,a2,0x20
    80001e52:	1582                	slli	a1,a1,0x20
    80001e54:	9181                	srli	a1,a1,0x20
    80001e56:	6928                	ld	a0,80(a0)
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	608080e7          	jalr	1544(ra) # 80001460 <uvmdealloc>
    80001e60:	0005079b          	sext.w	a5,a0
    80001e64:	bf45                	j	80001e14 <growproc+0x26>

0000000080001e66 <fork>:
{
    80001e66:	7139                	addi	sp,sp,-64
    80001e68:	fc06                	sd	ra,56(sp)
    80001e6a:	f822                	sd	s0,48(sp)
    80001e6c:	f426                	sd	s1,40(sp)
    80001e6e:	e456                	sd	s5,8(sp)
    80001e70:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e72:	00000097          	auipc	ra,0x0
    80001e76:	c08080e7          	jalr	-1016(ra) # 80001a7a <myproc>
    80001e7a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e7c:	00000097          	auipc	ra,0x0
    80001e80:	e0a080e7          	jalr	-502(ra) # 80001c86 <allocproc>
    80001e84:	12050063          	beqz	a0,80001fa4 <fork+0x13e>
    80001e88:	e852                	sd	s4,16(sp)
    80001e8a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e8c:	048ab603          	ld	a2,72(s5)
    80001e90:	692c                	ld	a1,80(a0)
    80001e92:	050ab503          	ld	a0,80(s5)
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	774080e7          	jalr	1908(ra) # 8000160a <uvmcopy>
    80001e9e:	04054863          	bltz	a0,80001eee <fork+0x88>
    80001ea2:	f04a                	sd	s2,32(sp)
    80001ea4:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001ea6:	048ab783          	ld	a5,72(s5)
    80001eaa:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001eae:	058ab683          	ld	a3,88(s5)
    80001eb2:	87b6                	mv	a5,a3
    80001eb4:	058a3703          	ld	a4,88(s4)
    80001eb8:	12068693          	addi	a3,a3,288
    80001ebc:	6388                	ld	a0,0(a5)
    80001ebe:	678c                	ld	a1,8(a5)
    80001ec0:	6b90                	ld	a2,16(a5)
    80001ec2:	e308                	sd	a0,0(a4)
    80001ec4:	e70c                	sd	a1,8(a4)
    80001ec6:	eb10                	sd	a2,16(a4)
    80001ec8:	6f90                	ld	a2,24(a5)
    80001eca:	ef10                	sd	a2,24(a4)
    80001ecc:	02078793          	addi	a5,a5,32 # 1020 <_entry-0x7fffefe0>
    80001ed0:	02070713          	addi	a4,a4,32
    80001ed4:	fed794e3          	bne	a5,a3,80001ebc <fork+0x56>
  np->trapframe->a0 = 0;
    80001ed8:	058a3783          	ld	a5,88(s4)
    80001edc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ee0:	0d0a8493          	addi	s1,s5,208
    80001ee4:	0d0a0913          	addi	s2,s4,208
    80001ee8:	150a8993          	addi	s3,s5,336
    80001eec:	a015                	j	80001f10 <fork+0xaa>
    freeproc(np);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	00000097          	auipc	ra,0x0
    80001ef4:	d3e080e7          	jalr	-706(ra) # 80001c2e <freeproc>
    release(&np->lock);
    80001ef8:	8552                	mv	a0,s4
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	e0a080e7          	jalr	-502(ra) # 80000d04 <release>
    return -1;
    80001f02:	54fd                	li	s1,-1
    80001f04:	6a42                	ld	s4,16(sp)
    80001f06:	a841                	j	80001f96 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001f08:	04a1                	addi	s1,s1,8
    80001f0a:	0921                	addi	s2,s2,8
    80001f0c:	01348b63          	beq	s1,s3,80001f22 <fork+0xbc>
    if(p->ofile[i])
    80001f10:	6088                	ld	a0,0(s1)
    80001f12:	d97d                	beqz	a0,80001f08 <fork+0xa2>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f14:	00003097          	auipc	ra,0x3
    80001f18:	8b6080e7          	jalr	-1866(ra) # 800047ca <filedup>
    80001f1c:	00a93023          	sd	a0,0(s2)
    80001f20:	b7e5                	j	80001f08 <fork+0xa2>
  np->cwd = idup(p->cwd);
    80001f22:	150ab503          	ld	a0,336(s5)
    80001f26:	00002097          	auipc	ra,0x2
    80001f2a:	9de080e7          	jalr	-1570(ra) # 80003904 <idup>
    80001f2e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f32:	4641                	li	a2,16
    80001f34:	158a8593          	addi	a1,s5,344
    80001f38:	158a0513          	addi	a0,s4,344
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	f68080e7          	jalr	-152(ra) # 80000ea4 <safestrcpy>
  pid = np->pid;
    80001f44:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001f48:	8552                	mv	a0,s4
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	dba080e7          	jalr	-582(ra) # 80000d04 <release>
  acquire(&wait_lock);
    80001f52:	00012517          	auipc	a0,0x12
    80001f56:	36650513          	addi	a0,a0,870 # 800142b8 <wait_lock>
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	cfa080e7          	jalr	-774(ra) # 80000c54 <acquire>
  np->parent = p;
    80001f62:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f66:	00012517          	auipc	a0,0x12
    80001f6a:	35250513          	addi	a0,a0,850 # 800142b8 <wait_lock>
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	d96080e7          	jalr	-618(ra) # 80000d04 <release>
  acquire(&np->lock);
    80001f76:	8552                	mv	a0,s4
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	cdc080e7          	jalr	-804(ra) # 80000c54 <acquire>
  np->state = RUNNABLE;
    80001f80:	478d                	li	a5,3
    80001f82:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f86:	8552                	mv	a0,s4
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	d7c080e7          	jalr	-644(ra) # 80000d04 <release>
  return pid;
    80001f90:	7902                	ld	s2,32(sp)
    80001f92:	69e2                	ld	s3,24(sp)
    80001f94:	6a42                	ld	s4,16(sp)
}
    80001f96:	8526                	mv	a0,s1
    80001f98:	70e2                	ld	ra,56(sp)
    80001f9a:	7442                	ld	s0,48(sp)
    80001f9c:	74a2                	ld	s1,40(sp)
    80001f9e:	6aa2                	ld	s5,8(sp)
    80001fa0:	6121                	addi	sp,sp,64
    80001fa2:	8082                	ret
    return -1;
    80001fa4:	54fd                	li	s1,-1
    80001fa6:	bfc5                	j	80001f96 <fork+0x130>

0000000080001fa8 <update_time>:
{
    80001fa8:	7179                	addi	sp,sp,-48
    80001faa:	f406                	sd	ra,40(sp)
    80001fac:	f022                	sd	s0,32(sp)
    80001fae:	ec26                	sd	s1,24(sp)
    80001fb0:	e84a                	sd	s2,16(sp)
    80001fb2:	e44e                	sd	s3,8(sp)
    80001fb4:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fb6:	00012497          	auipc	s1,0x12
    80001fba:	71a48493          	addi	s1,s1,1818 # 800146d0 <proc>
    if (p->state == RUNNING) {
    80001fbe:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fc0:	00018917          	auipc	s2,0x18
    80001fc4:	51090913          	addi	s2,s2,1296 # 8001a4d0 <tickslock>
    80001fc8:	a811                	j	80001fdc <update_time+0x34>
    release(&p->lock); 
    80001fca:	8526                	mv	a0,s1
    80001fcc:	fffff097          	auipc	ra,0xfffff
    80001fd0:	d38080e7          	jalr	-712(ra) # 80000d04 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fd4:	17848493          	addi	s1,s1,376
    80001fd8:	03248063          	beq	s1,s2,80001ff8 <update_time+0x50>
    acquire(&p->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	c76080e7          	jalr	-906(ra) # 80000c54 <acquire>
    if (p->state == RUNNING) {
    80001fe6:	4c9c                	lw	a5,24(s1)
    80001fe8:	ff3791e3          	bne	a5,s3,80001fca <update_time+0x22>
      p->rtime++;
    80001fec:	1684a783          	lw	a5,360(s1)
    80001ff0:	2785                	addiw	a5,a5,1
    80001ff2:	16f4a423          	sw	a5,360(s1)
    80001ff6:	bfd1                	j	80001fca <update_time+0x22>
}
    80001ff8:	70a2                	ld	ra,40(sp)
    80001ffa:	7402                	ld	s0,32(sp)
    80001ffc:	64e2                	ld	s1,24(sp)
    80001ffe:	6942                	ld	s2,16(sp)
    80002000:	69a2                	ld	s3,8(sp)
    80002002:	6145                	addi	sp,sp,48
    80002004:	8082                	ret

0000000080002006 <scheduler>:
{
    80002006:	7139                	addi	sp,sp,-64
    80002008:	fc06                	sd	ra,56(sp)
    8000200a:	f822                	sd	s0,48(sp)
    8000200c:	f426                	sd	s1,40(sp)
    8000200e:	f04a                	sd	s2,32(sp)
    80002010:	ec4e                	sd	s3,24(sp)
    80002012:	e852                	sd	s4,16(sp)
    80002014:	e456                	sd	s5,8(sp)
    80002016:	e05a                	sd	s6,0(sp)
    80002018:	0080                	addi	s0,sp,64
    8000201a:	8792                	mv	a5,tp
  int id = r_tp();
    8000201c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000201e:	00779693          	slli	a3,a5,0x7
    80002022:	00012717          	auipc	a4,0x12
    80002026:	27e70713          	addi	a4,a4,638 # 800142a0 <pid_lock>
    8000202a:	9736                	add	a4,a4,a3
    8000202c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &minProc->context);
    80002030:	00012717          	auipc	a4,0x12
    80002034:	2a870713          	addi	a4,a4,680 # 800142d8 <cpus+0x8>
    80002038:	9736                	add	a4,a4,a3
    8000203a:	8b3a                	mv	s6,a4
      if (p->state == RUNNABLE) {
    8000203c:	448d                	li	s1,3
    for (p = proc; p < &proc[NPROC]; p++) {
    8000203e:	00018917          	auipc	s2,0x18
    80002042:	49290913          	addi	s2,s2,1170 # 8001a4d0 <tickslock>
        c->proc = minProc;
    80002046:	00012a17          	auipc	s4,0x12
    8000204a:	25aa0a13          	addi	s4,s4,602 # 800142a0 <pid_lock>
    8000204e:	9a36                	add	s4,s4,a3
    80002050:	a035                	j	8000207c <scheduler+0x76>
        if (minProc == 0)
    80002052:	08098463          	beqz	s3,800020da <scheduler+0xd4>
        else if (minProc->ctime > p->ctime)
    80002056:	16c9a683          	lw	a3,364(s3)
    8000205a:	16c7a703          	lw	a4,364(a5)
    8000205e:	08d76063          	bltu	a4,a3,800020de <scheduler+0xd8>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002062:	17878793          	addi	a5,a5,376
    80002066:	03278763          	beq	a5,s2,80002094 <scheduler+0x8e>
      if (p->state == RUNNABLE) {
    8000206a:	4f98                	lw	a4,24(a5)
    8000206c:	fe9703e3          	beq	a4,s1,80002052 <scheduler+0x4c>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002070:	17878793          	addi	a5,a5,376
    80002074:	ff279be3          	bne	a5,s2,8000206a <scheduler+0x64>
    if (minProc != 0) {
    80002078:	00099e63          	bnez	s3,80002094 <scheduler+0x8e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000207c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002080:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002084:	10079073          	csrw	sstatus,a5
    struct proc *minProc = 0;
    80002088:	4981                	li	s3,0
    for (p = proc; p < &proc[NPROC]; p++) {
    8000208a:	00012797          	auipc	a5,0x12
    8000208e:	64678793          	addi	a5,a5,1606 # 800146d0 <proc>
    80002092:	bfe1                	j	8000206a <scheduler+0x64>
      acquire(&minProc->lock);
    80002094:	8ace                	mv	s5,s3
    80002096:	854e                	mv	a0,s3
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bbc080e7          	jalr	-1092(ra) # 80000c54 <acquire>
      if (minProc->state == RUNNABLE) {
    800020a0:	0189a783          	lw	a5,24(s3)
    800020a4:	02979563          	bne	a5,s1,800020ce <scheduler+0xc8>
        minProc->no_of_times_scheduled++;
    800020a8:	1749a783          	lw	a5,372(s3)
    800020ac:	2785                	addiw	a5,a5,1
    800020ae:	16f9aa23          	sw	a5,372(s3)
        minProc->state = RUNNING;
    800020b2:	4791                	li	a5,4
    800020b4:	00f9ac23          	sw	a5,24(s3)
        c->proc = minProc;
    800020b8:	033a3823          	sd	s3,48(s4)
        swtch(&c->context, &minProc->context);
    800020bc:	06098593          	addi	a1,s3,96
    800020c0:	855a                	mv	a0,s6
    800020c2:	00000097          	auipc	ra,0x0
    800020c6:	7b6080e7          	jalr	1974(ra) # 80002878 <swtch>
        c->proc = 0;
    800020ca:	020a3823          	sd	zero,48(s4)
      release(&minProc->lock);
    800020ce:	8556                	mv	a0,s5
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	c34080e7          	jalr	-972(ra) # 80000d04 <release>
    800020d8:	b755                	j	8000207c <scheduler+0x76>
          minProc = p;
    800020da:	89be                	mv	s3,a5
    800020dc:	b759                	j	80002062 <scheduler+0x5c>
          minProc = p;
    800020de:	89be                	mv	s3,a5
    800020e0:	b749                	j	80002062 <scheduler+0x5c>

00000000800020e2 <sched>:
{
    800020e2:	7179                	addi	sp,sp,-48
    800020e4:	f406                	sd	ra,40(sp)
    800020e6:	f022                	sd	s0,32(sp)
    800020e8:	ec26                	sd	s1,24(sp)
    800020ea:	e84a                	sd	s2,16(sp)
    800020ec:	e44e                	sd	s3,8(sp)
    800020ee:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020f0:	00000097          	auipc	ra,0x0
    800020f4:	98a080e7          	jalr	-1654(ra) # 80001a7a <myproc>
    800020f8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	ada080e7          	jalr	-1318(ra) # 80000bd4 <holding>
    80002102:	cd25                	beqz	a0,8000217a <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002104:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002106:	2781                	sext.w	a5,a5
    80002108:	079e                	slli	a5,a5,0x7
    8000210a:	00012717          	auipc	a4,0x12
    8000210e:	19670713          	addi	a4,a4,406 # 800142a0 <pid_lock>
    80002112:	97ba                	add	a5,a5,a4
    80002114:	0a87a703          	lw	a4,168(a5)
    80002118:	4785                	li	a5,1
    8000211a:	06f71863          	bne	a4,a5,8000218a <sched+0xa8>
  if(p->state == RUNNING)
    8000211e:	4c98                	lw	a4,24(s1)
    80002120:	4791                	li	a5,4
    80002122:	06f70c63          	beq	a4,a5,8000219a <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002126:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000212a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000212c:	efbd                	bnez	a5,800021aa <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000212e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002130:	00012917          	auipc	s2,0x12
    80002134:	17090913          	addi	s2,s2,368 # 800142a0 <pid_lock>
    80002138:	2781                	sext.w	a5,a5
    8000213a:	079e                	slli	a5,a5,0x7
    8000213c:	97ca                	add	a5,a5,s2
    8000213e:	0ac7a983          	lw	s3,172(a5)
    80002142:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002144:	2781                	sext.w	a5,a5
    80002146:	079e                	slli	a5,a5,0x7
    80002148:	07a1                	addi	a5,a5,8
    8000214a:	00012597          	auipc	a1,0x12
    8000214e:	18658593          	addi	a1,a1,390 # 800142d0 <cpus>
    80002152:	95be                	add	a1,a1,a5
    80002154:	06048513          	addi	a0,s1,96
    80002158:	00000097          	auipc	ra,0x0
    8000215c:	720080e7          	jalr	1824(ra) # 80002878 <swtch>
    80002160:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002162:	2781                	sext.w	a5,a5
    80002164:	079e                	slli	a5,a5,0x7
    80002166:	993e                	add	s2,s2,a5
    80002168:	0b392623          	sw	s3,172(s2)
}
    8000216c:	70a2                	ld	ra,40(sp)
    8000216e:	7402                	ld	s0,32(sp)
    80002170:	64e2                	ld	s1,24(sp)
    80002172:	6942                	ld	s2,16(sp)
    80002174:	69a2                	ld	s3,8(sp)
    80002176:	6145                	addi	sp,sp,48
    80002178:	8082                	ret
    panic("sched p->lock");
    8000217a:	00006517          	auipc	a0,0x6
    8000217e:	07e50513          	addi	a0,a0,126 # 800081f8 <etext+0x1f8>
    80002182:	ffffe097          	auipc	ra,0xffffe
    80002186:	3d4080e7          	jalr	980(ra) # 80000556 <panic>
    panic("sched locks");
    8000218a:	00006517          	auipc	a0,0x6
    8000218e:	07e50513          	addi	a0,a0,126 # 80008208 <etext+0x208>
    80002192:	ffffe097          	auipc	ra,0xffffe
    80002196:	3c4080e7          	jalr	964(ra) # 80000556 <panic>
    panic("sched running");
    8000219a:	00006517          	auipc	a0,0x6
    8000219e:	07e50513          	addi	a0,a0,126 # 80008218 <etext+0x218>
    800021a2:	ffffe097          	auipc	ra,0xffffe
    800021a6:	3b4080e7          	jalr	948(ra) # 80000556 <panic>
    panic("sched interruptible");
    800021aa:	00006517          	auipc	a0,0x6
    800021ae:	07e50513          	addi	a0,a0,126 # 80008228 <etext+0x228>
    800021b2:	ffffe097          	auipc	ra,0xffffe
    800021b6:	3a4080e7          	jalr	932(ra) # 80000556 <panic>

00000000800021ba <yield>:
{
    800021ba:	1101                	addi	sp,sp,-32
    800021bc:	ec06                	sd	ra,24(sp)
    800021be:	e822                	sd	s0,16(sp)
    800021c0:	e426                	sd	s1,8(sp)
    800021c2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	8b6080e7          	jalr	-1866(ra) # 80001a7a <myproc>
    800021cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	a86080e7          	jalr	-1402(ra) # 80000c54 <acquire>
  p->state = RUNNABLE;
    800021d6:	478d                	li	a5,3
    800021d8:	cc9c                	sw	a5,24(s1)
  sched();
    800021da:	00000097          	auipc	ra,0x0
    800021de:	f08080e7          	jalr	-248(ra) # 800020e2 <sched>
  release(&p->lock);
    800021e2:	8526                	mv	a0,s1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	b20080e7          	jalr	-1248(ra) # 80000d04 <release>
}
    800021ec:	60e2                	ld	ra,24(sp)
    800021ee:	6442                	ld	s0,16(sp)
    800021f0:	64a2                	ld	s1,8(sp)
    800021f2:	6105                	addi	sp,sp,32
    800021f4:	8082                	ret

00000000800021f6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	1800                	addi	s0,sp,48
    80002204:	89aa                	mv	s3,a0
    80002206:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002208:	00000097          	auipc	ra,0x0
    8000220c:	872080e7          	jalr	-1934(ra) # 80001a7a <myproc>
    80002210:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	a42080e7          	jalr	-1470(ra) # 80000c54 <acquire>
  release(lk);
    8000221a:	854a                	mv	a0,s2
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	ae8080e7          	jalr	-1304(ra) # 80000d04 <release>

  // Go to sleep.
  p->chan = chan;
    80002224:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002228:	4789                	li	a5,2
    8000222a:	cc9c                	sw	a5,24(s1)
  sched();
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	eb6080e7          	jalr	-330(ra) # 800020e2 <sched>

  // Tidy up.
  p->chan = 0;
    80002234:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002238:	8526                	mv	a0,s1
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	aca080e7          	jalr	-1334(ra) # 80000d04 <release>
  acquire(lk);
    80002242:	854a                	mv	a0,s2
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	a10080e7          	jalr	-1520(ra) # 80000c54 <acquire>
}
    8000224c:	70a2                	ld	ra,40(sp)
    8000224e:	7402                	ld	s0,32(sp)
    80002250:	64e2                	ld	s1,24(sp)
    80002252:	6942                	ld	s2,16(sp)
    80002254:	69a2                	ld	s3,8(sp)
    80002256:	6145                	addi	sp,sp,48
    80002258:	8082                	ret

000000008000225a <wait>:
{
    8000225a:	715d                	addi	sp,sp,-80
    8000225c:	e486                	sd	ra,72(sp)
    8000225e:	e0a2                	sd	s0,64(sp)
    80002260:	fc26                	sd	s1,56(sp)
    80002262:	f84a                	sd	s2,48(sp)
    80002264:	f44e                	sd	s3,40(sp)
    80002266:	f052                	sd	s4,32(sp)
    80002268:	ec56                	sd	s5,24(sp)
    8000226a:	e85a                	sd	s6,16(sp)
    8000226c:	e45e                	sd	s7,8(sp)
    8000226e:	0880                	addi	s0,sp,80
    80002270:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002272:	00000097          	auipc	ra,0x0
    80002276:	808080e7          	jalr	-2040(ra) # 80001a7a <myproc>
    8000227a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000227c:	00012517          	auipc	a0,0x12
    80002280:	03c50513          	addi	a0,a0,60 # 800142b8 <wait_lock>
    80002284:	fffff097          	auipc	ra,0xfffff
    80002288:	9d0080e7          	jalr	-1584(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    8000228c:	4a15                	li	s4,5
        havekids = 1;
    8000228e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002290:	00018997          	auipc	s3,0x18
    80002294:	24098993          	addi	s3,s3,576 # 8001a4d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002298:	00012b17          	auipc	s6,0x12
    8000229c:	020b0b13          	addi	s6,s6,32 # 800142b8 <wait_lock>
    800022a0:	a875                	j	8000235c <wait+0x102>
          pid = np->pid;
    800022a2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022a6:	000b8e63          	beqz	s7,800022c2 <wait+0x68>
    800022aa:	4691                	li	a3,4
    800022ac:	02c48613          	addi	a2,s1,44
    800022b0:	85de                	mv	a1,s7
    800022b2:	05093503          	ld	a0,80(s2)
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	454080e7          	jalr	1108(ra) # 8000170a <copyout>
    800022be:	04054063          	bltz	a0,800022fe <wait+0xa4>
          freeproc(np);
    800022c2:	8526                	mv	a0,s1
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	96a080e7          	jalr	-1686(ra) # 80001c2e <freeproc>
          release(&np->lock);
    800022cc:	8526                	mv	a0,s1
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	a36080e7          	jalr	-1482(ra) # 80000d04 <release>
          release(&wait_lock);
    800022d6:	00012517          	auipc	a0,0x12
    800022da:	fe250513          	addi	a0,a0,-30 # 800142b8 <wait_lock>
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	a26080e7          	jalr	-1498(ra) # 80000d04 <release>
}
    800022e6:	854e                	mv	a0,s3
    800022e8:	60a6                	ld	ra,72(sp)
    800022ea:	6406                	ld	s0,64(sp)
    800022ec:	74e2                	ld	s1,56(sp)
    800022ee:	7942                	ld	s2,48(sp)
    800022f0:	79a2                	ld	s3,40(sp)
    800022f2:	7a02                	ld	s4,32(sp)
    800022f4:	6ae2                	ld	s5,24(sp)
    800022f6:	6b42                	ld	s6,16(sp)
    800022f8:	6ba2                	ld	s7,8(sp)
    800022fa:	6161                	addi	sp,sp,80
    800022fc:	8082                	ret
            release(&np->lock);
    800022fe:	8526                	mv	a0,s1
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	a04080e7          	jalr	-1532(ra) # 80000d04 <release>
            release(&wait_lock);
    80002308:	00012517          	auipc	a0,0x12
    8000230c:	fb050513          	addi	a0,a0,-80 # 800142b8 <wait_lock>
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	9f4080e7          	jalr	-1548(ra) # 80000d04 <release>
            return -1;
    80002318:	59fd                	li	s3,-1
    8000231a:	b7f1                	j	800022e6 <wait+0x8c>
    for(np = proc; np < &proc[NPROC]; np++){
    8000231c:	17848493          	addi	s1,s1,376
    80002320:	03348463          	beq	s1,s3,80002348 <wait+0xee>
      if(np->parent == p){
    80002324:	7c9c                	ld	a5,56(s1)
    80002326:	ff279be3          	bne	a5,s2,8000231c <wait+0xc2>
        acquire(&np->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	928080e7          	jalr	-1752(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    80002334:	4c9c                	lw	a5,24(s1)
    80002336:	f74786e3          	beq	a5,s4,800022a2 <wait+0x48>
        release(&np->lock);
    8000233a:	8526                	mv	a0,s1
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	9c8080e7          	jalr	-1592(ra) # 80000d04 <release>
        havekids = 1;
    80002344:	8756                	mv	a4,s5
    80002346:	bfd9                	j	8000231c <wait+0xc2>
    if(!havekids || p->killed){
    80002348:	c305                	beqz	a4,80002368 <wait+0x10e>
    8000234a:	02892783          	lw	a5,40(s2)
    8000234e:	ef89                	bnez	a5,80002368 <wait+0x10e>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002350:	85da                	mv	a1,s6
    80002352:	854a                	mv	a0,s2
    80002354:	00000097          	auipc	ra,0x0
    80002358:	ea2080e7          	jalr	-350(ra) # 800021f6 <sleep>
    havekids = 0;
    8000235c:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    8000235e:	00012497          	auipc	s1,0x12
    80002362:	37248493          	addi	s1,s1,882 # 800146d0 <proc>
    80002366:	bf7d                	j	80002324 <wait+0xca>
      release(&wait_lock);
    80002368:	00012517          	auipc	a0,0x12
    8000236c:	f5050513          	addi	a0,a0,-176 # 800142b8 <wait_lock>
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	994080e7          	jalr	-1644(ra) # 80000d04 <release>
      return -1;
    80002378:	59fd                	li	s3,-1
    8000237a:	b7b5                	j	800022e6 <wait+0x8c>

000000008000237c <waitx>:
{
    8000237c:	711d                	addi	sp,sp,-96
    8000237e:	ec86                	sd	ra,88(sp)
    80002380:	e8a2                	sd	s0,80(sp)
    80002382:	e4a6                	sd	s1,72(sp)
    80002384:	e0ca                	sd	s2,64(sp)
    80002386:	fc4e                	sd	s3,56(sp)
    80002388:	f852                	sd	s4,48(sp)
    8000238a:	f456                	sd	s5,40(sp)
    8000238c:	f05a                	sd	s6,32(sp)
    8000238e:	ec5e                	sd	s7,24(sp)
    80002390:	e862                	sd	s8,16(sp)
    80002392:	e466                	sd	s9,8(sp)
    80002394:	1080                	addi	s0,sp,96
    80002396:	8baa                	mv	s7,a0
    80002398:	8c2e                	mv	s8,a1
    8000239a:	8cb2                	mv	s9,a2
  struct proc *p = myproc();
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	6de080e7          	jalr	1758(ra) # 80001a7a <myproc>
    800023a4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023a6:	00012517          	auipc	a0,0x12
    800023aa:	f1250513          	addi	a0,a0,-238 # 800142b8 <wait_lock>
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	8a6080e7          	jalr	-1882(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    800023b6:	4a15                	li	s4,5
        havekids = 1;
    800023b8:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800023ba:	00018997          	auipc	s3,0x18
    800023be:	11698993          	addi	s3,s3,278 # 8001a4d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023c2:	00012b17          	auipc	s6,0x12
    800023c6:	ef6b0b13          	addi	s6,s6,-266 # 800142b8 <wait_lock>
    800023ca:	a8e1                	j	800024a2 <waitx+0x126>
          pid = np->pid;
    800023cc:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800023d0:	1684a783          	lw	a5,360(s1)
    800023d4:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800023d8:	16c4a703          	lw	a4,364(s1)
    800023dc:	9f3d                	addw	a4,a4,a5
    800023de:	1704a783          	lw	a5,368(s1)
    800023e2:	9f99                	subw	a5,a5,a4
    800023e4:	00fca023          	sw	a5,0(s9)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023e8:	000b8e63          	beqz	s7,80002404 <waitx+0x88>
    800023ec:	4691                	li	a3,4
    800023ee:	02c48613          	addi	a2,s1,44
    800023f2:	85de                	mv	a1,s7
    800023f4:	05093503          	ld	a0,80(s2)
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	312080e7          	jalr	786(ra) # 8000170a <copyout>
    80002400:	04054263          	bltz	a0,80002444 <waitx+0xc8>
          freeproc(np);
    80002404:	8526                	mv	a0,s1
    80002406:	00000097          	auipc	ra,0x0
    8000240a:	828080e7          	jalr	-2008(ra) # 80001c2e <freeproc>
          release(&np->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	8f4080e7          	jalr	-1804(ra) # 80000d04 <release>
          release(&wait_lock);
    80002418:	00012517          	auipc	a0,0x12
    8000241c:	ea050513          	addi	a0,a0,-352 # 800142b8 <wait_lock>
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	8e4080e7          	jalr	-1820(ra) # 80000d04 <release>
}
    80002428:	854e                	mv	a0,s3
    8000242a:	60e6                	ld	ra,88(sp)
    8000242c:	6446                	ld	s0,80(sp)
    8000242e:	64a6                	ld	s1,72(sp)
    80002430:	6906                	ld	s2,64(sp)
    80002432:	79e2                	ld	s3,56(sp)
    80002434:	7a42                	ld	s4,48(sp)
    80002436:	7aa2                	ld	s5,40(sp)
    80002438:	7b02                	ld	s6,32(sp)
    8000243a:	6be2                	ld	s7,24(sp)
    8000243c:	6c42                	ld	s8,16(sp)
    8000243e:	6ca2                	ld	s9,8(sp)
    80002440:	6125                	addi	sp,sp,96
    80002442:	8082                	ret
            release(&np->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	8be080e7          	jalr	-1858(ra) # 80000d04 <release>
            release(&wait_lock);
    8000244e:	00012517          	auipc	a0,0x12
    80002452:	e6a50513          	addi	a0,a0,-406 # 800142b8 <wait_lock>
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	8ae080e7          	jalr	-1874(ra) # 80000d04 <release>
            return -1;
    8000245e:	59fd                	li	s3,-1
    80002460:	b7e1                	j	80002428 <waitx+0xac>
    for(np = proc; np < &proc[NPROC]; np++){
    80002462:	17848493          	addi	s1,s1,376
    80002466:	03348463          	beq	s1,s3,8000248e <waitx+0x112>
      if(np->parent == p){
    8000246a:	7c9c                	ld	a5,56(s1)
    8000246c:	ff279be3          	bne	a5,s2,80002462 <waitx+0xe6>
        acquire(&np->lock);
    80002470:	8526                	mv	a0,s1
    80002472:	ffffe097          	auipc	ra,0xffffe
    80002476:	7e2080e7          	jalr	2018(ra) # 80000c54 <acquire>
        if(np->state == ZOMBIE){
    8000247a:	4c9c                	lw	a5,24(s1)
    8000247c:	f54788e3          	beq	a5,s4,800023cc <waitx+0x50>
        release(&np->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	882080e7          	jalr	-1918(ra) # 80000d04 <release>
        havekids = 1;
    8000248a:	8756                	mv	a4,s5
    8000248c:	bfd9                	j	80002462 <waitx+0xe6>
    if(!havekids || p->killed){
    8000248e:	c305                	beqz	a4,800024ae <waitx+0x132>
    80002490:	02892783          	lw	a5,40(s2)
    80002494:	ef89                	bnez	a5,800024ae <waitx+0x132>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002496:	85da                	mv	a1,s6
    80002498:	854a                	mv	a0,s2
    8000249a:	00000097          	auipc	ra,0x0
    8000249e:	d5c080e7          	jalr	-676(ra) # 800021f6 <sleep>
    havekids = 0;
    800024a2:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800024a4:	00012497          	auipc	s1,0x12
    800024a8:	22c48493          	addi	s1,s1,556 # 800146d0 <proc>
    800024ac:	bf7d                	j	8000246a <waitx+0xee>
      release(&wait_lock);
    800024ae:	00012517          	auipc	a0,0x12
    800024b2:	e0a50513          	addi	a0,a0,-502 # 800142b8 <wait_lock>
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	84e080e7          	jalr	-1970(ra) # 80000d04 <release>
      return -1;
    800024be:	59fd                	li	s3,-1
    800024c0:	b7a5                	j	80002428 <waitx+0xac>

00000000800024c2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800024c2:	7139                	addi	sp,sp,-64
    800024c4:	fc06                	sd	ra,56(sp)
    800024c6:	f822                	sd	s0,48(sp)
    800024c8:	f426                	sd	s1,40(sp)
    800024ca:	f04a                	sd	s2,32(sp)
    800024cc:	ec4e                	sd	s3,24(sp)
    800024ce:	e852                	sd	s4,16(sp)
    800024d0:	e456                	sd	s5,8(sp)
    800024d2:	0080                	addi	s0,sp,64
    800024d4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800024d6:	00012497          	auipc	s1,0x12
    800024da:	1fa48493          	addi	s1,s1,506 # 800146d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800024de:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024e0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800024e2:	00018917          	auipc	s2,0x18
    800024e6:	fee90913          	addi	s2,s2,-18 # 8001a4d0 <tickslock>
    800024ea:	a811                	j	800024fe <wakeup+0x3c>
      }
      release(&p->lock);
    800024ec:	8526                	mv	a0,s1
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	816080e7          	jalr	-2026(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024f6:	17848493          	addi	s1,s1,376
    800024fa:	03248663          	beq	s1,s2,80002526 <wakeup+0x64>
    if(p != myproc()){
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	57c080e7          	jalr	1404(ra) # 80001a7a <myproc>
    80002506:	fe9508e3          	beq	a0,s1,800024f6 <wakeup+0x34>
      acquire(&p->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	748080e7          	jalr	1864(ra) # 80000c54 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002514:	4c9c                	lw	a5,24(s1)
    80002516:	fd379be3          	bne	a5,s3,800024ec <wakeup+0x2a>
    8000251a:	709c                	ld	a5,32(s1)
    8000251c:	fd4798e3          	bne	a5,s4,800024ec <wakeup+0x2a>
        p->state = RUNNABLE;
    80002520:	0154ac23          	sw	s5,24(s1)
    80002524:	b7e1                	j	800024ec <wakeup+0x2a>
    }
  }
}
    80002526:	70e2                	ld	ra,56(sp)
    80002528:	7442                	ld	s0,48(sp)
    8000252a:	74a2                	ld	s1,40(sp)
    8000252c:	7902                	ld	s2,32(sp)
    8000252e:	69e2                	ld	s3,24(sp)
    80002530:	6a42                	ld	s4,16(sp)
    80002532:	6aa2                	ld	s5,8(sp)
    80002534:	6121                	addi	sp,sp,64
    80002536:	8082                	ret

0000000080002538 <reparent>:
{
    80002538:	7179                	addi	sp,sp,-48
    8000253a:	f406                	sd	ra,40(sp)
    8000253c:	f022                	sd	s0,32(sp)
    8000253e:	ec26                	sd	s1,24(sp)
    80002540:	e84a                	sd	s2,16(sp)
    80002542:	e44e                	sd	s3,8(sp)
    80002544:	e052                	sd	s4,0(sp)
    80002546:	1800                	addi	s0,sp,48
    80002548:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000254a:	00012497          	auipc	s1,0x12
    8000254e:	18648493          	addi	s1,s1,390 # 800146d0 <proc>
      pp->parent = initproc;
    80002552:	0000aa17          	auipc	s4,0xa
    80002556:	ad6a0a13          	addi	s4,s4,-1322 # 8000c028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000255a:	00018997          	auipc	s3,0x18
    8000255e:	f7698993          	addi	s3,s3,-138 # 8001a4d0 <tickslock>
    80002562:	a029                	j	8000256c <reparent+0x34>
    80002564:	17848493          	addi	s1,s1,376
    80002568:	01348d63          	beq	s1,s3,80002582 <reparent+0x4a>
    if(pp->parent == p){
    8000256c:	7c9c                	ld	a5,56(s1)
    8000256e:	ff279be3          	bne	a5,s2,80002564 <reparent+0x2c>
      pp->parent = initproc;
    80002572:	000a3503          	ld	a0,0(s4)
    80002576:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002578:	00000097          	auipc	ra,0x0
    8000257c:	f4a080e7          	jalr	-182(ra) # 800024c2 <wakeup>
    80002580:	b7d5                	j	80002564 <reparent+0x2c>
}
    80002582:	70a2                	ld	ra,40(sp)
    80002584:	7402                	ld	s0,32(sp)
    80002586:	64e2                	ld	s1,24(sp)
    80002588:	6942                	ld	s2,16(sp)
    8000258a:	69a2                	ld	s3,8(sp)
    8000258c:	6a02                	ld	s4,0(sp)
    8000258e:	6145                	addi	sp,sp,48
    80002590:	8082                	ret

0000000080002592 <exit>:
{
    80002592:	7179                	addi	sp,sp,-48
    80002594:	f406                	sd	ra,40(sp)
    80002596:	f022                	sd	s0,32(sp)
    80002598:	ec26                	sd	s1,24(sp)
    8000259a:	e84a                	sd	s2,16(sp)
    8000259c:	e44e                	sd	s3,8(sp)
    8000259e:	e052                	sd	s4,0(sp)
    800025a0:	1800                	addi	s0,sp,48
    800025a2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025a4:	fffff097          	auipc	ra,0xfffff
    800025a8:	4d6080e7          	jalr	1238(ra) # 80001a7a <myproc>
    800025ac:	89aa                	mv	s3,a0
  if(p == initproc)
    800025ae:	0000a797          	auipc	a5,0xa
    800025b2:	a7a7b783          	ld	a5,-1414(a5) # 8000c028 <initproc>
    800025b6:	0d050493          	addi	s1,a0,208
    800025ba:	15050913          	addi	s2,a0,336
    800025be:	00a79d63          	bne	a5,a0,800025d8 <exit+0x46>
    panic("init exiting");
    800025c2:	00006517          	auipc	a0,0x6
    800025c6:	c7e50513          	addi	a0,a0,-898 # 80008240 <etext+0x240>
    800025ca:	ffffe097          	auipc	ra,0xffffe
    800025ce:	f8c080e7          	jalr	-116(ra) # 80000556 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800025d2:	04a1                	addi	s1,s1,8
    800025d4:	01248b63          	beq	s1,s2,800025ea <exit+0x58>
    if(p->ofile[fd]){
    800025d8:	6088                	ld	a0,0(s1)
    800025da:	dd65                	beqz	a0,800025d2 <exit+0x40>
      fileclose(f);
    800025dc:	00002097          	auipc	ra,0x2
    800025e0:	240080e7          	jalr	576(ra) # 8000481c <fileclose>
      p->ofile[fd] = 0;
    800025e4:	0004b023          	sd	zero,0(s1)
    800025e8:	b7ed                	j	800025d2 <exit+0x40>
  begin_op();
    800025ea:	00002097          	auipc	ra,0x2
    800025ee:	d50080e7          	jalr	-688(ra) # 8000433a <begin_op>
  iput(p->cwd);
    800025f2:	1509b503          	ld	a0,336(s3)
    800025f6:	00001097          	auipc	ra,0x1
    800025fa:	50a080e7          	jalr	1290(ra) # 80003b00 <iput>
  end_op();
    800025fe:	00002097          	auipc	ra,0x2
    80002602:	dbc080e7          	jalr	-580(ra) # 800043ba <end_op>
  p->cwd = 0;
    80002606:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000260a:	00012517          	auipc	a0,0x12
    8000260e:	cae50513          	addi	a0,a0,-850 # 800142b8 <wait_lock>
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	642080e7          	jalr	1602(ra) # 80000c54 <acquire>
  reparent(p);
    8000261a:	854e                	mv	a0,s3
    8000261c:	00000097          	auipc	ra,0x0
    80002620:	f1c080e7          	jalr	-228(ra) # 80002538 <reparent>
  wakeup(p->parent);
    80002624:	0389b503          	ld	a0,56(s3)
    80002628:	00000097          	auipc	ra,0x0
    8000262c:	e9a080e7          	jalr	-358(ra) # 800024c2 <wakeup>
  acquire(&p->lock);
    80002630:	854e                	mv	a0,s3
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	622080e7          	jalr	1570(ra) # 80000c54 <acquire>
  p->xstate = status;
    8000263a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000263e:	4795                	li	a5,5
    80002640:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002644:	0000a797          	auipc	a5,0xa
    80002648:	9ec7a783          	lw	a5,-1556(a5) # 8000c030 <ticks>
    8000264c:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    80002650:	00012517          	auipc	a0,0x12
    80002654:	c6850513          	addi	a0,a0,-920 # 800142b8 <wait_lock>
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	6ac080e7          	jalr	1708(ra) # 80000d04 <release>
  sched();
    80002660:	00000097          	auipc	ra,0x0
    80002664:	a82080e7          	jalr	-1406(ra) # 800020e2 <sched>
  panic("zombie exit");
    80002668:	00006517          	auipc	a0,0x6
    8000266c:	be850513          	addi	a0,a0,-1048 # 80008250 <etext+0x250>
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	ee6080e7          	jalr	-282(ra) # 80000556 <panic>

0000000080002678 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002678:	7179                	addi	sp,sp,-48
    8000267a:	f406                	sd	ra,40(sp)
    8000267c:	f022                	sd	s0,32(sp)
    8000267e:	ec26                	sd	s1,24(sp)
    80002680:	e84a                	sd	s2,16(sp)
    80002682:	e44e                	sd	s3,8(sp)
    80002684:	1800                	addi	s0,sp,48
    80002686:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002688:	00012497          	auipc	s1,0x12
    8000268c:	04848493          	addi	s1,s1,72 # 800146d0 <proc>
    80002690:	00018997          	auipc	s3,0x18
    80002694:	e4098993          	addi	s3,s3,-448 # 8001a4d0 <tickslock>
    acquire(&p->lock);
    80002698:	8526                	mv	a0,s1
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	5ba080e7          	jalr	1466(ra) # 80000c54 <acquire>
    if(p->pid == pid){
    800026a2:	589c                	lw	a5,48(s1)
    800026a4:	01278d63          	beq	a5,s2,800026be <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026a8:	8526                	mv	a0,s1
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	65a080e7          	jalr	1626(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026b2:	17848493          	addi	s1,s1,376
    800026b6:	ff3491e3          	bne	s1,s3,80002698 <kill+0x20>
  }
  return -1;
    800026ba:	557d                	li	a0,-1
    800026bc:	a829                	j	800026d6 <kill+0x5e>
      p->killed = 1;
    800026be:	4785                	li	a5,1
    800026c0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800026c2:	4c98                	lw	a4,24(s1)
    800026c4:	4789                	li	a5,2
    800026c6:	00f70f63          	beq	a4,a5,800026e4 <kill+0x6c>
      release(&p->lock);
    800026ca:	8526                	mv	a0,s1
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	638080e7          	jalr	1592(ra) # 80000d04 <release>
      return 0;
    800026d4:	4501                	li	a0,0
}
    800026d6:	70a2                	ld	ra,40(sp)
    800026d8:	7402                	ld	s0,32(sp)
    800026da:	64e2                	ld	s1,24(sp)
    800026dc:	6942                	ld	s2,16(sp)
    800026de:	69a2                	ld	s3,8(sp)
    800026e0:	6145                	addi	sp,sp,48
    800026e2:	8082                	ret
        p->state = RUNNABLE;
    800026e4:	478d                	li	a5,3
    800026e6:	cc9c                	sw	a5,24(s1)
    800026e8:	b7cd                	j	800026ca <kill+0x52>

00000000800026ea <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026ea:	7179                	addi	sp,sp,-48
    800026ec:	f406                	sd	ra,40(sp)
    800026ee:	f022                	sd	s0,32(sp)
    800026f0:	ec26                	sd	s1,24(sp)
    800026f2:	e84a                	sd	s2,16(sp)
    800026f4:	e44e                	sd	s3,8(sp)
    800026f6:	e052                	sd	s4,0(sp)
    800026f8:	1800                	addi	s0,sp,48
    800026fa:	84aa                	mv	s1,a0
    800026fc:	8a2e                	mv	s4,a1
    800026fe:	89b2                	mv	s3,a2
    80002700:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002702:	fffff097          	auipc	ra,0xfffff
    80002706:	378080e7          	jalr	888(ra) # 80001a7a <myproc>
  if(user_dst){
    8000270a:	c08d                	beqz	s1,8000272c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000270c:	86ca                	mv	a3,s2
    8000270e:	864e                	mv	a2,s3
    80002710:	85d2                	mv	a1,s4
    80002712:	6928                	ld	a0,80(a0)
    80002714:	fffff097          	auipc	ra,0xfffff
    80002718:	ff6080e7          	jalr	-10(ra) # 8000170a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000271c:	70a2                	ld	ra,40(sp)
    8000271e:	7402                	ld	s0,32(sp)
    80002720:	64e2                	ld	s1,24(sp)
    80002722:	6942                	ld	s2,16(sp)
    80002724:	69a2                	ld	s3,8(sp)
    80002726:	6a02                	ld	s4,0(sp)
    80002728:	6145                	addi	sp,sp,48
    8000272a:	8082                	ret
    memmove((char *)dst, src, len);
    8000272c:	0009061b          	sext.w	a2,s2
    80002730:	85ce                	mv	a1,s3
    80002732:	8552                	mv	a0,s4
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	678080e7          	jalr	1656(ra) # 80000dac <memmove>
    return 0;
    8000273c:	8526                	mv	a0,s1
    8000273e:	bff9                	j	8000271c <either_copyout+0x32>

0000000080002740 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002740:	7179                	addi	sp,sp,-48
    80002742:	f406                	sd	ra,40(sp)
    80002744:	f022                	sd	s0,32(sp)
    80002746:	ec26                	sd	s1,24(sp)
    80002748:	e84a                	sd	s2,16(sp)
    8000274a:	e44e                	sd	s3,8(sp)
    8000274c:	e052                	sd	s4,0(sp)
    8000274e:	1800                	addi	s0,sp,48
    80002750:	8a2a                	mv	s4,a0
    80002752:	84ae                	mv	s1,a1
    80002754:	89b2                	mv	s3,a2
    80002756:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002758:	fffff097          	auipc	ra,0xfffff
    8000275c:	322080e7          	jalr	802(ra) # 80001a7a <myproc>
  if(user_src){
    80002760:	c08d                	beqz	s1,80002782 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002762:	86ca                	mv	a3,s2
    80002764:	864e                	mv	a2,s3
    80002766:	85d2                	mv	a1,s4
    80002768:	6928                	ld	a0,80(a0)
    8000276a:	fffff097          	auipc	ra,0xfffff
    8000276e:	02c080e7          	jalr	44(ra) # 80001796 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002772:	70a2                	ld	ra,40(sp)
    80002774:	7402                	ld	s0,32(sp)
    80002776:	64e2                	ld	s1,24(sp)
    80002778:	6942                	ld	s2,16(sp)
    8000277a:	69a2                	ld	s3,8(sp)
    8000277c:	6a02                	ld	s4,0(sp)
    8000277e:	6145                	addi	sp,sp,48
    80002780:	8082                	ret
    memmove(dst, (char*)src, len);
    80002782:	0009061b          	sext.w	a2,s2
    80002786:	85ce                	mv	a1,s3
    80002788:	8552                	mv	a0,s4
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	622080e7          	jalr	1570(ra) # 80000dac <memmove>
    return 0;
    80002792:	8526                	mv	a0,s1
    80002794:	bff9                	j	80002772 <either_copyin+0x32>

0000000080002796 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002796:	715d                	addi	sp,sp,-80
    80002798:	e486                	sd	ra,72(sp)
    8000279a:	e0a2                	sd	s0,64(sp)
    8000279c:	fc26                	sd	s1,56(sp)
    8000279e:	f84a                	sd	s2,48(sp)
    800027a0:	f44e                	sd	s3,40(sp)
    800027a2:	f052                	sd	s4,32(sp)
    800027a4:	ec56                	sd	s5,24(sp)
    800027a6:	e85a                	sd	s6,16(sp)
    800027a8:	e45e                	sd	s7,8(sp)
    800027aa:	e062                	sd	s8,0(sp)
    800027ac:	0880                	addi	s0,sp,80
  };
  struct proc *p;
  char *state;

  #if defined(DEFAULT) || defined(FCFS)
    printf("\nPID\tState\trtime\twtime\tnrun");
    800027ae:	00006517          	auipc	a0,0x6
    800027b2:	aba50513          	addi	a0,a0,-1350 # 80008268 <etext+0x268>
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	dea080e7          	jalr	-534(ra) # 800005a0 <printf>
  #endif


  printf("\n");
    800027be:	00006517          	auipc	a0,0x6
    800027c2:	85250513          	addi	a0,a0,-1966 # 80008010 <etext+0x10>
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	dda080e7          	jalr	-550(ra) # 800005a0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ce:	00012497          	auipc	s1,0x12
    800027d2:	f0248493          	addi	s1,s1,-254 # 800146d0 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027d6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027d8:	00006997          	auipc	s3,0x6
    800027dc:	a8898993          	addi	s3,s3,-1400 # 80008260 <etext+0x260>
    #if defined(DEFAULT) || defined(FCFS)
      int end_time = p->etime;
      if (end_time == 0)
        end_time = ticks;

      printf("%d\t%s\t%d\t%d\t%d", p->pid, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled);
    800027e0:	00006a97          	auipc	s5,0x6
    800027e4:	aa8a8a93          	addi	s5,s5,-1368 # 80008288 <etext+0x288>
      printf("\n");
    800027e8:	00006a17          	auipc	s4,0x6
    800027ec:	828a0a13          	addi	s4,s4,-2008 # 80008010 <etext+0x10>
        end_time = ticks;
    800027f0:	0000ac17          	auipc	s8,0xa
    800027f4:	840c0c13          	addi	s8,s8,-1984 # 8000c030 <ticks>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027f8:	00006b97          	auipc	s7,0x6
    800027fc:	f38b8b93          	addi	s7,s7,-200 # 80008730 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002800:	00018917          	auipc	s2,0x18
    80002804:	cd090913          	addi	s2,s2,-816 # 8001a4d0 <tickslock>
    80002808:	a835                	j	80002844 <procdump+0xae>
      int end_time = p->etime;
    8000280a:	1704a583          	lw	a1,368(s1)
      if (end_time == 0)
    8000280e:	e199                	bnez	a1,80002814 <procdump+0x7e>
        end_time = ticks;
    80002810:	000c2583          	lw	a1,0(s8)
      printf("%d\t%s\t%d\t%d\t%d", p->pid, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled);
    80002814:	1684a683          	lw	a3,360(s1)
    80002818:	16c4a703          	lw	a4,364(s1)
    8000281c:	9f35                	addw	a4,a4,a3
    8000281e:	1744a783          	lw	a5,372(s1)
    80002822:	40e5873b          	subw	a4,a1,a4
    80002826:	588c                	lw	a1,48(s1)
    80002828:	8556                	mv	a0,s5
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	d76080e7          	jalr	-650(ra) # 800005a0 <printf>
      printf("\n");
    80002832:	8552                	mv	a0,s4
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	d6c080e7          	jalr	-660(ra) # 800005a0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000283c:	17848493          	addi	s1,s1,376
    80002840:	03248063          	beq	s1,s2,80002860 <procdump+0xca>
    if(p->state == UNUSED)
    80002844:	4c9c                	lw	a5,24(s1)
    80002846:	dbfd                	beqz	a5,8000283c <procdump+0xa6>
      state = "???";
    80002848:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000284a:	fcfb60e3          	bltu	s6,a5,8000280a <procdump+0x74>
    8000284e:	02079713          	slli	a4,a5,0x20
    80002852:	01d75793          	srli	a5,a4,0x1d
    80002856:	97de                	add	a5,a5,s7
    80002858:	6390                	ld	a2,0(a5)
    8000285a:	fa45                	bnez	a2,8000280a <procdump+0x74>
      state = "???";
    8000285c:	864e                	mv	a2,s3
    8000285e:	b775                	j	8000280a <procdump+0x74>
    #endif


  }
}
    80002860:	60a6                	ld	ra,72(sp)
    80002862:	6406                	ld	s0,64(sp)
    80002864:	74e2                	ld	s1,56(sp)
    80002866:	7942                	ld	s2,48(sp)
    80002868:	79a2                	ld	s3,40(sp)
    8000286a:	7a02                	ld	s4,32(sp)
    8000286c:	6ae2                	ld	s5,24(sp)
    8000286e:	6b42                	ld	s6,16(sp)
    80002870:	6ba2                	ld	s7,8(sp)
    80002872:	6c02                	ld	s8,0(sp)
    80002874:	6161                	addi	sp,sp,80
    80002876:	8082                	ret

0000000080002878 <swtch>:
    80002878:	00153023          	sd	ra,0(a0)
    8000287c:	00253423          	sd	sp,8(a0)
    80002880:	e900                	sd	s0,16(a0)
    80002882:	ed04                	sd	s1,24(a0)
    80002884:	03253023          	sd	s2,32(a0)
    80002888:	03353423          	sd	s3,40(a0)
    8000288c:	03453823          	sd	s4,48(a0)
    80002890:	03553c23          	sd	s5,56(a0)
    80002894:	05653023          	sd	s6,64(a0)
    80002898:	05753423          	sd	s7,72(a0)
    8000289c:	05853823          	sd	s8,80(a0)
    800028a0:	05953c23          	sd	s9,88(a0)
    800028a4:	07a53023          	sd	s10,96(a0)
    800028a8:	07b53423          	sd	s11,104(a0)
    800028ac:	0005b083          	ld	ra,0(a1)
    800028b0:	0085b103          	ld	sp,8(a1)
    800028b4:	6980                	ld	s0,16(a1)
    800028b6:	6d84                	ld	s1,24(a1)
    800028b8:	0205b903          	ld	s2,32(a1)
    800028bc:	0285b983          	ld	s3,40(a1)
    800028c0:	0305ba03          	ld	s4,48(a1)
    800028c4:	0385ba83          	ld	s5,56(a1)
    800028c8:	0405bb03          	ld	s6,64(a1)
    800028cc:	0485bb83          	ld	s7,72(a1)
    800028d0:	0505bc03          	ld	s8,80(a1)
    800028d4:	0585bc83          	ld	s9,88(a1)
    800028d8:	0605bd03          	ld	s10,96(a1)
    800028dc:	0685bd83          	ld	s11,104(a1)
    800028e0:	8082                	ret

00000000800028e2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028e2:	1141                	addi	sp,sp,-16
    800028e4:	e406                	sd	ra,8(sp)
    800028e6:	e022                	sd	s0,0(sp)
    800028e8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028ea:	00006597          	auipc	a1,0x6
    800028ee:	9d658593          	addi	a1,a1,-1578 # 800082c0 <etext+0x2c0>
    800028f2:	00018517          	auipc	a0,0x18
    800028f6:	bde50513          	addi	a0,a0,-1058 # 8001a4d0 <tickslock>
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	2c0080e7          	jalr	704(ra) # 80000bba <initlock>
}
    80002902:	60a2                	ld	ra,8(sp)
    80002904:	6402                	ld	s0,0(sp)
    80002906:	0141                	addi	sp,sp,16
    80002908:	8082                	ret

000000008000290a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000290a:	1141                	addi	sp,sp,-16
    8000290c:	e406                	sd	ra,8(sp)
    8000290e:	e022                	sd	s0,0(sp)
    80002910:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002912:	00003797          	auipc	a5,0x3
    80002916:	63e78793          	addi	a5,a5,1598 # 80005f50 <kernelvec>
    8000291a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000291e:	60a2                	ld	ra,8(sp)
    80002920:	6402                	ld	s0,0(sp)
    80002922:	0141                	addi	sp,sp,16
    80002924:	8082                	ret

0000000080002926 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002926:	1141                	addi	sp,sp,-16
    80002928:	e406                	sd	ra,8(sp)
    8000292a:	e022                	sd	s0,0(sp)
    8000292c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000292e:	fffff097          	auipc	ra,0xfffff
    80002932:	14c080e7          	jalr	332(ra) # 80001a7a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002936:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000293a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000293c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002940:	00004697          	auipc	a3,0x4
    80002944:	6c068693          	addi	a3,a3,1728 # 80007000 <_trampoline>
    80002948:	00004717          	auipc	a4,0x4
    8000294c:	6b870713          	addi	a4,a4,1720 # 80007000 <_trampoline>
    80002950:	8f15                	sub	a4,a4,a3
    80002952:	040007b7          	lui	a5,0x4000
    80002956:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002958:	07b2                	slli	a5,a5,0xc
    8000295a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000295c:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002960:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002962:	18002673          	csrr	a2,satp
    80002966:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002968:	6d30                	ld	a2,88(a0)
    8000296a:	6138                	ld	a4,64(a0)
    8000296c:	6585                	lui	a1,0x1
    8000296e:	972e                	add	a4,a4,a1
    80002970:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002972:	6d38                	ld	a4,88(a0)
    80002974:	00000617          	auipc	a2,0x0
    80002978:	15260613          	addi	a2,a2,338 # 80002ac6 <usertrap>
    8000297c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000297e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002980:	8612                	mv	a2,tp
    80002982:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002984:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002988:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000298c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002990:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002994:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002996:	6f18                	ld	a4,24(a4)
    80002998:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000299c:	692c                	ld	a1,80(a0)
    8000299e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800029a0:	00004717          	auipc	a4,0x4
    800029a4:	6f070713          	addi	a4,a4,1776 # 80007090 <userret>
    800029a8:	8f15                	sub	a4,a4,a3
    800029aa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800029ac:	577d                	li	a4,-1
    800029ae:	177e                	slli	a4,a4,0x3f
    800029b0:	8dd9                	or	a1,a1,a4
    800029b2:	02000537          	lui	a0,0x2000
    800029b6:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800029b8:	0536                	slli	a0,a0,0xd
    800029ba:	9782                	jalr	a5
}
    800029bc:	60a2                	ld	ra,8(sp)
    800029be:	6402                	ld	s0,0(sp)
    800029c0:	0141                	addi	sp,sp,16
    800029c2:	8082                	ret

00000000800029c4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029c4:	1141                	addi	sp,sp,-16
    800029c6:	e406                	sd	ra,8(sp)
    800029c8:	e022                	sd	s0,0(sp)
    800029ca:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    800029cc:	00018517          	auipc	a0,0x18
    800029d0:	b0450513          	addi	a0,a0,-1276 # 8001a4d0 <tickslock>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	280080e7          	jalr	640(ra) # 80000c54 <acquire>
  ticks++;
    800029dc:	00009717          	auipc	a4,0x9
    800029e0:	65470713          	addi	a4,a4,1620 # 8000c030 <ticks>
    800029e4:	431c                	lw	a5,0(a4)
    800029e6:	2785                	addiw	a5,a5,1
    800029e8:	c31c                	sw	a5,0(a4)
  update_time();
    800029ea:	fffff097          	auipc	ra,0xfffff
    800029ee:	5be080e7          	jalr	1470(ra) # 80001fa8 <update_time>
  wakeup(&ticks);
    800029f2:	00009517          	auipc	a0,0x9
    800029f6:	63e50513          	addi	a0,a0,1598 # 8000c030 <ticks>
    800029fa:	00000097          	auipc	ra,0x0
    800029fe:	ac8080e7          	jalr	-1336(ra) # 800024c2 <wakeup>
  release(&tickslock);
    80002a02:	00018517          	auipc	a0,0x18
    80002a06:	ace50513          	addi	a0,a0,-1330 # 8001a4d0 <tickslock>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	2fa080e7          	jalr	762(ra) # 80000d04 <release>
}
    80002a12:	60a2                	ld	ra,8(sp)
    80002a14:	6402                	ld	s0,0(sp)
    80002a16:	0141                	addi	sp,sp,16
    80002a18:	8082                	ret

0000000080002a1a <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a1a:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a1e:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002a20:	0a07d263          	bgez	a5,80002ac4 <devintr+0xaa>
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002a2c:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002a30:	46a5                	li	a3,9
    80002a32:	00d70c63          	beq	a4,a3,80002a4a <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002a36:	577d                	li	a4,-1
    80002a38:	177e                	slli	a4,a4,0x3f
    80002a3a:	0705                	addi	a4,a4,1
    return 0;
    80002a3c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a3e:	06e78263          	beq	a5,a4,80002aa2 <devintr+0x88>
  }
}
    80002a42:	60e2                	ld	ra,24(sp)
    80002a44:	6442                	ld	s0,16(sp)
    80002a46:	6105                	addi	sp,sp,32
    80002a48:	8082                	ret
    80002a4a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a4c:	00003097          	auipc	ra,0x3
    80002a50:	610080e7          	jalr	1552(ra) # 8000605c <plic_claim>
    80002a54:	872a                	mv	a4,a0
    80002a56:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a58:	47a9                	li	a5,10
    80002a5a:	00f50963          	beq	a0,a5,80002a6c <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ){
    80002a5e:	4785                	li	a5,1
    80002a60:	00f50b63          	beq	a0,a5,80002a76 <devintr+0x5c>
    return 1;
    80002a64:	4505                	li	a0,1
    } else if(irq){
    80002a66:	ef09                	bnez	a4,80002a80 <devintr+0x66>
    80002a68:	64a2                	ld	s1,8(sp)
    80002a6a:	bfe1                	j	80002a42 <devintr+0x28>
      uartintr();
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	f8c080e7          	jalr	-116(ra) # 800009f8 <uartintr>
    if(irq)
    80002a74:	a839                	j	80002a92 <devintr+0x78>
      virtio_disk_intr();
    80002a76:	00004097          	auipc	ra,0x4
    80002a7a:	aa0080e7          	jalr	-1376(ra) # 80006516 <virtio_disk_intr>
    if(irq)
    80002a7e:	a811                	j	80002a92 <devintr+0x78>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a80:	85ba                	mv	a1,a4
    80002a82:	00006517          	auipc	a0,0x6
    80002a86:	84650513          	addi	a0,a0,-1978 # 800082c8 <etext+0x2c8>
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	b16080e7          	jalr	-1258(ra) # 800005a0 <printf>
      plic_complete(irq);
    80002a92:	8526                	mv	a0,s1
    80002a94:	00003097          	auipc	ra,0x3
    80002a98:	5ec080e7          	jalr	1516(ra) # 80006080 <plic_complete>
    return 1;
    80002a9c:	4505                	li	a0,1
    80002a9e:	64a2                	ld	s1,8(sp)
    80002aa0:	b74d                	j	80002a42 <devintr+0x28>
    if(cpuid() == 0){
    80002aa2:	fffff097          	auipc	ra,0xfffff
    80002aa6:	fa4080e7          	jalr	-92(ra) # 80001a46 <cpuid>
    80002aaa:	c901                	beqz	a0,80002aba <devintr+0xa0>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002aac:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ab0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ab2:	14479073          	csrw	sip,a5
    return 2;
    80002ab6:	4509                	li	a0,2
    80002ab8:	b769                	j	80002a42 <devintr+0x28>
      clockintr();
    80002aba:	00000097          	auipc	ra,0x0
    80002abe:	f0a080e7          	jalr	-246(ra) # 800029c4 <clockintr>
    80002ac2:	b7ed                	j	80002aac <devintr+0x92>
}
    80002ac4:	8082                	ret

0000000080002ac6 <usertrap>:
{
    80002ac6:	1101                	addi	sp,sp,-32
    80002ac8:	ec06                	sd	ra,24(sp)
    80002aca:	e822                	sd	s0,16(sp)
    80002acc:	e426                	sd	s1,8(sp)
    80002ace:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ad4:	1007f793          	andi	a5,a5,256
    80002ad8:	e3a5                	bnez	a5,80002b38 <usertrap+0x72>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ada:	00003797          	auipc	a5,0x3
    80002ade:	47678793          	addi	a5,a5,1142 # 80005f50 <kernelvec>
    80002ae2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ae6:	fffff097          	auipc	ra,0xfffff
    80002aea:	f94080e7          	jalr	-108(ra) # 80001a7a <myproc>
    80002aee:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002af0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002af2:	14102773          	csrr	a4,sepc
    80002af6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002afc:	47a1                	li	a5,8
    80002afe:	04f71b63          	bne	a4,a5,80002b54 <usertrap+0x8e>
    if(p->killed)
    80002b02:	551c                	lw	a5,40(a0)
    80002b04:	e3b1                	bnez	a5,80002b48 <usertrap+0x82>
    p->trapframe->epc += 4;
    80002b06:	6cb8                	ld	a4,88(s1)
    80002b08:	6f1c                	ld	a5,24(a4)
    80002b0a:	0791                	addi	a5,a5,4
    80002b0c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b12:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b16:	10079073          	csrw	sstatus,a5
    syscall();
    80002b1a:	00000097          	auipc	ra,0x0
    80002b1e:	29c080e7          	jalr	668(ra) # 80002db6 <syscall>
  if(p->killed)
    80002b22:	549c                	lw	a5,40(s1)
    80002b24:	e7b5                	bnez	a5,80002b90 <usertrap+0xca>
  usertrapret();
    80002b26:	00000097          	auipc	ra,0x0
    80002b2a:	e00080e7          	jalr	-512(ra) # 80002926 <usertrapret>
}
    80002b2e:	60e2                	ld	ra,24(sp)
    80002b30:	6442                	ld	s0,16(sp)
    80002b32:	64a2                	ld	s1,8(sp)
    80002b34:	6105                	addi	sp,sp,32
    80002b36:	8082                	ret
    panic("usertrap: not from user mode");
    80002b38:	00005517          	auipc	a0,0x5
    80002b3c:	7b050513          	addi	a0,a0,1968 # 800082e8 <etext+0x2e8>
    80002b40:	ffffe097          	auipc	ra,0xffffe
    80002b44:	a16080e7          	jalr	-1514(ra) # 80000556 <panic>
      exit(-1);
    80002b48:	557d                	li	a0,-1
    80002b4a:	00000097          	auipc	ra,0x0
    80002b4e:	a48080e7          	jalr	-1464(ra) # 80002592 <exit>
    80002b52:	bf55                	j	80002b06 <usertrap+0x40>
  } else if((which_dev = devintr()) != 0){
    80002b54:	00000097          	auipc	ra,0x0
    80002b58:	ec6080e7          	jalr	-314(ra) # 80002a1a <devintr>
    80002b5c:	f179                	bnez	a0,80002b22 <usertrap+0x5c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b5e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b62:	5890                	lw	a2,48(s1)
    80002b64:	00005517          	auipc	a0,0x5
    80002b68:	7a450513          	addi	a0,a0,1956 # 80008308 <etext+0x308>
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	a34080e7          	jalr	-1484(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b74:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b78:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b7c:	00005517          	auipc	a0,0x5
    80002b80:	7bc50513          	addi	a0,a0,1980 # 80008338 <etext+0x338>
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	a1c080e7          	jalr	-1508(ra) # 800005a0 <printf>
    p->killed = 1;
    80002b8c:	4785                	li	a5,1
    80002b8e:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002b90:	557d                	li	a0,-1
    80002b92:	00000097          	auipc	ra,0x0
    80002b96:	a00080e7          	jalr	-1536(ra) # 80002592 <exit>
    80002b9a:	b771                	j	80002b26 <usertrap+0x60>

0000000080002b9c <kerneltrap>:
{
    80002b9c:	7179                	addi	sp,sp,-48
    80002b9e:	f406                	sd	ra,40(sp)
    80002ba0:	f022                	sd	s0,32(sp)
    80002ba2:	ec26                	sd	s1,24(sp)
    80002ba4:	e84a                	sd	s2,16(sp)
    80002ba6:	e44e                	sd	s3,8(sp)
    80002ba8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002baa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb2:	142027f3          	csrr	a5,scause
    80002bb6:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002bb8:	1004f793          	andi	a5,s1,256
    80002bbc:	c78d                	beqz	a5,80002be6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bc2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bc4:	eb8d                	bnez	a5,80002bf6 <kerneltrap+0x5a>
  if((which_dev = devintr()) == 0){
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	e54080e7          	jalr	-428(ra) # 80002a1a <devintr>
    80002bce:	cd05                	beqz	a0,80002c06 <kerneltrap+0x6a>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bd0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bd4:	10049073          	csrw	sstatus,s1
}
    80002bd8:	70a2                	ld	ra,40(sp)
    80002bda:	7402                	ld	s0,32(sp)
    80002bdc:	64e2                	ld	s1,24(sp)
    80002bde:	6942                	ld	s2,16(sp)
    80002be0:	69a2                	ld	s3,8(sp)
    80002be2:	6145                	addi	sp,sp,48
    80002be4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002be6:	00005517          	auipc	a0,0x5
    80002bea:	77250513          	addi	a0,a0,1906 # 80008358 <etext+0x358>
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	968080e7          	jalr	-1688(ra) # 80000556 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	78a50513          	addi	a0,a0,1930 # 80008380 <etext+0x380>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	958080e7          	jalr	-1704(ra) # 80000556 <panic>
    printf("scause %p\n", scause);
    80002c06:	85ce                	mv	a1,s3
    80002c08:	00005517          	auipc	a0,0x5
    80002c0c:	79850513          	addi	a0,a0,1944 # 800083a0 <etext+0x3a0>
    80002c10:	ffffe097          	auipc	ra,0xffffe
    80002c14:	990080e7          	jalr	-1648(ra) # 800005a0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c18:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c1c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c20:	00005517          	auipc	a0,0x5
    80002c24:	79050513          	addi	a0,a0,1936 # 800083b0 <etext+0x3b0>
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	978080e7          	jalr	-1672(ra) # 800005a0 <printf>
    panic("kerneltrap");
    80002c30:	00005517          	auipc	a0,0x5
    80002c34:	79850513          	addi	a0,a0,1944 # 800083c8 <etext+0x3c8>
    80002c38:	ffffe097          	auipc	ra,0xffffe
    80002c3c:	91e080e7          	jalr	-1762(ra) # 80000556 <panic>

0000000080002c40 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c40:	1101                	addi	sp,sp,-32
    80002c42:	ec06                	sd	ra,24(sp)
    80002c44:	e822                	sd	s0,16(sp)
    80002c46:	e426                	sd	s1,8(sp)
    80002c48:	1000                	addi	s0,sp,32
    80002c4a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	e2e080e7          	jalr	-466(ra) # 80001a7a <myproc>
  switch (n) {
    80002c54:	4795                	li	a5,5
    80002c56:	0497e163          	bltu	a5,s1,80002c98 <argraw+0x58>
    80002c5a:	048a                	slli	s1,s1,0x2
    80002c5c:	00006717          	auipc	a4,0x6
    80002c60:	b0470713          	addi	a4,a4,-1276 # 80008760 <states.0+0x30>
    80002c64:	94ba                	add	s1,s1,a4
    80002c66:	409c                	lw	a5,0(s1)
    80002c68:	97ba                	add	a5,a5,a4
    80002c6a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c6c:	6d3c                	ld	a5,88(a0)
    80002c6e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c70:	60e2                	ld	ra,24(sp)
    80002c72:	6442                	ld	s0,16(sp)
    80002c74:	64a2                	ld	s1,8(sp)
    80002c76:	6105                	addi	sp,sp,32
    80002c78:	8082                	ret
    return p->trapframe->a1;
    80002c7a:	6d3c                	ld	a5,88(a0)
    80002c7c:	7fa8                	ld	a0,120(a5)
    80002c7e:	bfcd                	j	80002c70 <argraw+0x30>
    return p->trapframe->a2;
    80002c80:	6d3c                	ld	a5,88(a0)
    80002c82:	63c8                	ld	a0,128(a5)
    80002c84:	b7f5                	j	80002c70 <argraw+0x30>
    return p->trapframe->a3;
    80002c86:	6d3c                	ld	a5,88(a0)
    80002c88:	67c8                	ld	a0,136(a5)
    80002c8a:	b7dd                	j	80002c70 <argraw+0x30>
    return p->trapframe->a4;
    80002c8c:	6d3c                	ld	a5,88(a0)
    80002c8e:	6bc8                	ld	a0,144(a5)
    80002c90:	b7c5                	j	80002c70 <argraw+0x30>
    return p->trapframe->a5;
    80002c92:	6d3c                	ld	a5,88(a0)
    80002c94:	6fc8                	ld	a0,152(a5)
    80002c96:	bfe9                	j	80002c70 <argraw+0x30>
  panic("argraw");
    80002c98:	00005517          	auipc	a0,0x5
    80002c9c:	74050513          	addi	a0,a0,1856 # 800083d8 <etext+0x3d8>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	8b6080e7          	jalr	-1866(ra) # 80000556 <panic>

0000000080002ca8 <fetchaddr>:
{
    80002ca8:	1101                	addi	sp,sp,-32
    80002caa:	ec06                	sd	ra,24(sp)
    80002cac:	e822                	sd	s0,16(sp)
    80002cae:	e426                	sd	s1,8(sp)
    80002cb0:	e04a                	sd	s2,0(sp)
    80002cb2:	1000                	addi	s0,sp,32
    80002cb4:	84aa                	mv	s1,a0
    80002cb6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	dc2080e7          	jalr	-574(ra) # 80001a7a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002cc0:	653c                	ld	a5,72(a0)
    80002cc2:	02f4f863          	bgeu	s1,a5,80002cf2 <fetchaddr+0x4a>
    80002cc6:	00848713          	addi	a4,s1,8
    80002cca:	02e7e663          	bltu	a5,a4,80002cf6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cce:	46a1                	li	a3,8
    80002cd0:	8626                	mv	a2,s1
    80002cd2:	85ca                	mv	a1,s2
    80002cd4:	6928                	ld	a0,80(a0)
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	ac0080e7          	jalr	-1344(ra) # 80001796 <copyin>
    80002cde:	00a03533          	snez	a0,a0
    80002ce2:	40a0053b          	negw	a0,a0
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	64a2                	ld	s1,8(sp)
    80002cec:	6902                	ld	s2,0(sp)
    80002cee:	6105                	addi	sp,sp,32
    80002cf0:	8082                	ret
    return -1;
    80002cf2:	557d                	li	a0,-1
    80002cf4:	bfcd                	j	80002ce6 <fetchaddr+0x3e>
    80002cf6:	557d                	li	a0,-1
    80002cf8:	b7fd                	j	80002ce6 <fetchaddr+0x3e>

0000000080002cfa <fetchstr>:
{
    80002cfa:	7179                	addi	sp,sp,-48
    80002cfc:	f406                	sd	ra,40(sp)
    80002cfe:	f022                	sd	s0,32(sp)
    80002d00:	ec26                	sd	s1,24(sp)
    80002d02:	e84a                	sd	s2,16(sp)
    80002d04:	e44e                	sd	s3,8(sp)
    80002d06:	1800                	addi	s0,sp,48
    80002d08:	89aa                	mv	s3,a0
    80002d0a:	84ae                	mv	s1,a1
    80002d0c:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	d6c080e7          	jalr	-660(ra) # 80001a7a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d16:	86ca                	mv	a3,s2
    80002d18:	864e                	mv	a2,s3
    80002d1a:	85a6                	mv	a1,s1
    80002d1c:	6928                	ld	a0,80(a0)
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	b06080e7          	jalr	-1274(ra) # 80001824 <copyinstr>
  if(err < 0)
    80002d26:	00054763          	bltz	a0,80002d34 <fetchstr+0x3a>
  return strlen(buf);
    80002d2a:	8526                	mv	a0,s1
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	1ae080e7          	jalr	430(ra) # 80000eda <strlen>
}
    80002d34:	70a2                	ld	ra,40(sp)
    80002d36:	7402                	ld	s0,32(sp)
    80002d38:	64e2                	ld	s1,24(sp)
    80002d3a:	6942                	ld	s2,16(sp)
    80002d3c:	69a2                	ld	s3,8(sp)
    80002d3e:	6145                	addi	sp,sp,48
    80002d40:	8082                	ret

0000000080002d42 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d42:	1101                	addi	sp,sp,-32
    80002d44:	ec06                	sd	ra,24(sp)
    80002d46:	e822                	sd	s0,16(sp)
    80002d48:	e426                	sd	s1,8(sp)
    80002d4a:	1000                	addi	s0,sp,32
    80002d4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	ef2080e7          	jalr	-270(ra) # 80002c40 <argraw>
    80002d56:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d58:	4501                	li	a0,0
    80002d5a:	60e2                	ld	ra,24(sp)
    80002d5c:	6442                	ld	s0,16(sp)
    80002d5e:	64a2                	ld	s1,8(sp)
    80002d60:	6105                	addi	sp,sp,32
    80002d62:	8082                	ret

0000000080002d64 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d64:	1101                	addi	sp,sp,-32
    80002d66:	ec06                	sd	ra,24(sp)
    80002d68:	e822                	sd	s0,16(sp)
    80002d6a:	e426                	sd	s1,8(sp)
    80002d6c:	1000                	addi	s0,sp,32
    80002d6e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d70:	00000097          	auipc	ra,0x0
    80002d74:	ed0080e7          	jalr	-304(ra) # 80002c40 <argraw>
    80002d78:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d7a:	4501                	li	a0,0
    80002d7c:	60e2                	ld	ra,24(sp)
    80002d7e:	6442                	ld	s0,16(sp)
    80002d80:	64a2                	ld	s1,8(sp)
    80002d82:	6105                	addi	sp,sp,32
    80002d84:	8082                	ret

0000000080002d86 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d86:	1101                	addi	sp,sp,-32
    80002d88:	ec06                	sd	ra,24(sp)
    80002d8a:	e822                	sd	s0,16(sp)
    80002d8c:	e426                	sd	s1,8(sp)
    80002d8e:	e04a                	sd	s2,0(sp)
    80002d90:	1000                	addi	s0,sp,32
    80002d92:	892e                	mv	s2,a1
    80002d94:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	eaa080e7          	jalr	-342(ra) # 80002c40 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d9e:	8626                	mv	a2,s1
    80002da0:	85ca                	mv	a1,s2
    80002da2:	00000097          	auipc	ra,0x0
    80002da6:	f58080e7          	jalr	-168(ra) # 80002cfa <fetchstr>
}
    80002daa:	60e2                	ld	ra,24(sp)
    80002dac:	6442                	ld	s0,16(sp)
    80002dae:	64a2                	ld	s1,8(sp)
    80002db0:	6902                	ld	s2,0(sp)
    80002db2:	6105                	addi	sp,sp,32
    80002db4:	8082                	ret

0000000080002db6 <syscall>:
[SYS_waitx]   sys_waitx,
};

void
syscall(void)
{
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	e426                	sd	s1,8(sp)
    80002dbe:	e04a                	sd	s2,0(sp)
    80002dc0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	cb8080e7          	jalr	-840(ra) # 80001a7a <myproc>
    80002dca:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dcc:	05853903          	ld	s2,88(a0)
    80002dd0:	0a893783          	ld	a5,168(s2)
    80002dd4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dd8:	37fd                	addiw	a5,a5,-1
    80002dda:	4755                	li	a4,21
    80002ddc:	00f76f63          	bltu	a4,a5,80002dfa <syscall+0x44>
    80002de0:	00369713          	slli	a4,a3,0x3
    80002de4:	00006797          	auipc	a5,0x6
    80002de8:	99478793          	addi	a5,a5,-1644 # 80008778 <syscalls>
    80002dec:	97ba                	add	a5,a5,a4
    80002dee:	639c                	ld	a5,0(a5)
    80002df0:	c789                	beqz	a5,80002dfa <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002df2:	9782                	jalr	a5
    80002df4:	06a93823          	sd	a0,112(s2)
    80002df8:	a839                	j	80002e16 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002dfa:	15848613          	addi	a2,s1,344
    80002dfe:	588c                	lw	a1,48(s1)
    80002e00:	00005517          	auipc	a0,0x5
    80002e04:	5e050513          	addi	a0,a0,1504 # 800083e0 <etext+0x3e0>
    80002e08:	ffffd097          	auipc	ra,0xffffd
    80002e0c:	798080e7          	jalr	1944(ra) # 800005a0 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e10:	6cbc                	ld	a5,88(s1)
    80002e12:	577d                	li	a4,-1
    80002e14:	fbb8                	sd	a4,112(a5)
  }
}
    80002e16:	60e2                	ld	ra,24(sp)
    80002e18:	6442                	ld	s0,16(sp)
    80002e1a:	64a2                	ld	s1,8(sp)
    80002e1c:	6902                	ld	s2,0(sp)
    80002e1e:	6105                	addi	sp,sp,32
    80002e20:	8082                	ret

0000000080002e22 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e22:	1101                	addi	sp,sp,-32
    80002e24:	ec06                	sd	ra,24(sp)
    80002e26:	e822                	sd	s0,16(sp)
    80002e28:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e2a:	fec40593          	addi	a1,s0,-20
    80002e2e:	4501                	li	a0,0
    80002e30:	00000097          	auipc	ra,0x0
    80002e34:	f12080e7          	jalr	-238(ra) # 80002d42 <argint>
    return -1;
    80002e38:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e3a:	00054963          	bltz	a0,80002e4c <sys_exit+0x2a>
  exit(n);
    80002e3e:	fec42503          	lw	a0,-20(s0)
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	750080e7          	jalr	1872(ra) # 80002592 <exit>
  return 0;  // not reached
    80002e4a:	4781                	li	a5,0
}
    80002e4c:	853e                	mv	a0,a5
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	6105                	addi	sp,sp,32
    80002e54:	8082                	ret

0000000080002e56 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e56:	1141                	addi	sp,sp,-16
    80002e58:	e406                	sd	ra,8(sp)
    80002e5a:	e022                	sd	s0,0(sp)
    80002e5c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	c1c080e7          	jalr	-996(ra) # 80001a7a <myproc>
}
    80002e66:	5908                	lw	a0,48(a0)
    80002e68:	60a2                	ld	ra,8(sp)
    80002e6a:	6402                	ld	s0,0(sp)
    80002e6c:	0141                	addi	sp,sp,16
    80002e6e:	8082                	ret

0000000080002e70 <sys_fork>:

uint64
sys_fork(void)
{
    80002e70:	1141                	addi	sp,sp,-16
    80002e72:	e406                	sd	ra,8(sp)
    80002e74:	e022                	sd	s0,0(sp)
    80002e76:	0800                	addi	s0,sp,16
  return fork();
    80002e78:	fffff097          	auipc	ra,0xfffff
    80002e7c:	fee080e7          	jalr	-18(ra) # 80001e66 <fork>
}
    80002e80:	60a2                	ld	ra,8(sp)
    80002e82:	6402                	ld	s0,0(sp)
    80002e84:	0141                	addi	sp,sp,16
    80002e86:	8082                	ret

0000000080002e88 <sys_wait>:

uint64
sys_wait(void)
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e90:	fe840593          	addi	a1,s0,-24
    80002e94:	4501                	li	a0,0
    80002e96:	00000097          	auipc	ra,0x0
    80002e9a:	ece080e7          	jalr	-306(ra) # 80002d64 <argaddr>
    80002e9e:	87aa                	mv	a5,a0
    return -1;
    80002ea0:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ea2:	0007c863          	bltz	a5,80002eb2 <sys_wait+0x2a>
  return wait(p);
    80002ea6:	fe843503          	ld	a0,-24(s0)
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	3b0080e7          	jalr	944(ra) # 8000225a <wait>
}
    80002eb2:	60e2                	ld	ra,24(sp)
    80002eb4:	6442                	ld	s0,16(sp)
    80002eb6:	6105                	addi	sp,sp,32
    80002eb8:	8082                	ret

0000000080002eba <sys_waitx>:

uint64
sys_waitx(void)
{
    80002eba:	7139                	addi	sp,sp,-64
    80002ebc:	fc06                	sd	ra,56(sp)
    80002ebe:	f822                	sd	s0,48(sp)
    80002ec0:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  if(argaddr(0, &addr) < 0)
    80002ec2:	fd840593          	addi	a1,s0,-40
    80002ec6:	4501                	li	a0,0
    80002ec8:	00000097          	auipc	ra,0x0
    80002ecc:	e9c080e7          	jalr	-356(ra) # 80002d64 <argaddr>
    return -1;
    80002ed0:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0)
    80002ed2:	08054463          	bltz	a0,80002f5a <sys_waitx+0xa0>
  if(argaddr(1, &addr1) < 0) // user virtual memory
    80002ed6:	fd040593          	addi	a1,s0,-48
    80002eda:	4505                	li	a0,1
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	e88080e7          	jalr	-376(ra) # 80002d64 <argaddr>
    return -1;
    80002ee4:	57fd                	li	a5,-1
  if(argaddr(1, &addr1) < 0) // user virtual memory
    80002ee6:	06054a63          	bltz	a0,80002f5a <sys_waitx+0xa0>
  if(argaddr(2, &addr2) < 0)
    80002eea:	fc840593          	addi	a1,s0,-56
    80002eee:	4509                	li	a0,2
    80002ef0:	00000097          	auipc	ra,0x0
    80002ef4:	e74080e7          	jalr	-396(ra) # 80002d64 <argaddr>
    return -1;
    80002ef8:	57fd                	li	a5,-1
  if(argaddr(2, &addr2) < 0)
    80002efa:	06054063          	bltz	a0,80002f5a <sys_waitx+0xa0>
    80002efe:	f426                	sd	s1,40(sp)
    80002f00:	f04a                	sd	s2,32(sp)
  int ret = waitx(addr, &wtime, &rtime);
    80002f02:	fc040613          	addi	a2,s0,-64
    80002f06:	fc440593          	addi	a1,s0,-60
    80002f0a:	fd843503          	ld	a0,-40(s0)
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	46e080e7          	jalr	1134(ra) # 8000237c <waitx>
    80002f16:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80002f18:	fffff097          	auipc	ra,0xfffff
    80002f1c:	b62080e7          	jalr	-1182(ra) # 80001a7a <myproc>
    80002f20:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80002f22:	4691                	li	a3,4
    80002f24:	fc440613          	addi	a2,s0,-60
    80002f28:	fd043583          	ld	a1,-48(s0)
    80002f2c:	6928                	ld	a0,80(a0)
    80002f2e:	ffffe097          	auipc	ra,0xffffe
    80002f32:	7dc080e7          	jalr	2012(ra) # 8000170a <copyout>
    return -1;
    80002f36:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80002f38:	02054a63          	bltz	a0,80002f6c <sys_waitx+0xb2>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80002f3c:	4691                	li	a3,4
    80002f3e:	fc040613          	addi	a2,s0,-64
    80002f42:	fc843583          	ld	a1,-56(s0)
    80002f46:	68a8                	ld	a0,80(s1)
    80002f48:	ffffe097          	auipc	ra,0xffffe
    80002f4c:	7c2080e7          	jalr	1986(ra) # 8000170a <copyout>
    80002f50:	00054a63          	bltz	a0,80002f64 <sys_waitx+0xaa>
    return -1;
  return ret;
    80002f54:	87ca                	mv	a5,s2
    80002f56:	74a2                	ld	s1,40(sp)
    80002f58:	7902                	ld	s2,32(sp)
}
    80002f5a:	853e                	mv	a0,a5
    80002f5c:	70e2                	ld	ra,56(sp)
    80002f5e:	7442                	ld	s0,48(sp)
    80002f60:	6121                	addi	sp,sp,64
    80002f62:	8082                	ret
    return -1;
    80002f64:	57fd                	li	a5,-1
    80002f66:	74a2                	ld	s1,40(sp)
    80002f68:	7902                	ld	s2,32(sp)
    80002f6a:	bfc5                	j	80002f5a <sys_waitx+0xa0>
    80002f6c:	74a2                	ld	s1,40(sp)
    80002f6e:	7902                	ld	s2,32(sp)
    80002f70:	b7ed                	j	80002f5a <sys_waitx+0xa0>

0000000080002f72 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f72:	7179                	addi	sp,sp,-48
    80002f74:	f406                	sd	ra,40(sp)
    80002f76:	f022                	sd	s0,32(sp)
    80002f78:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f7a:	fdc40593          	addi	a1,s0,-36
    80002f7e:	4501                	li	a0,0
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	dc2080e7          	jalr	-574(ra) # 80002d42 <argint>
    return -1;
    80002f88:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f8a:	02054363          	bltz	a0,80002fb0 <sys_sbrk+0x3e>
    80002f8e:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    80002f90:	fffff097          	auipc	ra,0xfffff
    80002f94:	aea080e7          	jalr	-1302(ra) # 80001a7a <myproc>
    80002f98:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002f9a:	fdc42503          	lw	a0,-36(s0)
    80002f9e:	fffff097          	auipc	ra,0xfffff
    80002fa2:	e50080e7          	jalr	-432(ra) # 80001dee <growproc>
    80002fa6:	00054a63          	bltz	a0,80002fba <sys_sbrk+0x48>
    return -1;
  return addr;
    80002faa:	0004879b          	sext.w	a5,s1
    80002fae:	64e2                	ld	s1,24(sp)
}
    80002fb0:	853e                	mv	a0,a5
    80002fb2:	70a2                	ld	ra,40(sp)
    80002fb4:	7402                	ld	s0,32(sp)
    80002fb6:	6145                	addi	sp,sp,48
    80002fb8:	8082                	ret
    return -1;
    80002fba:	57fd                	li	a5,-1
    80002fbc:	64e2                	ld	s1,24(sp)
    80002fbe:	bfcd                	j	80002fb0 <sys_sbrk+0x3e>

0000000080002fc0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fc0:	7139                	addi	sp,sp,-64
    80002fc2:	fc06                	sd	ra,56(sp)
    80002fc4:	f822                	sd	s0,48(sp)
    80002fc6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fc8:	fcc40593          	addi	a1,s0,-52
    80002fcc:	4501                	li	a0,0
    80002fce:	00000097          	auipc	ra,0x0
    80002fd2:	d74080e7          	jalr	-652(ra) # 80002d42 <argint>
    return -1;
    80002fd6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fd8:	06054b63          	bltz	a0,8000304e <sys_sleep+0x8e>
  acquire(&tickslock);
    80002fdc:	00017517          	auipc	a0,0x17
    80002fe0:	4f450513          	addi	a0,a0,1268 # 8001a4d0 <tickslock>
    80002fe4:	ffffe097          	auipc	ra,0xffffe
    80002fe8:	c70080e7          	jalr	-912(ra) # 80000c54 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002fec:	fcc42783          	lw	a5,-52(s0)
    80002ff0:	c7b1                	beqz	a5,8000303c <sys_sleep+0x7c>
    80002ff2:	f426                	sd	s1,40(sp)
    80002ff4:	f04a                	sd	s2,32(sp)
    80002ff6:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ff8:	00009997          	auipc	s3,0x9
    80002ffc:	0389a983          	lw	s3,56(s3) # 8000c030 <ticks>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003000:	00017917          	auipc	s2,0x17
    80003004:	4d090913          	addi	s2,s2,1232 # 8001a4d0 <tickslock>
    80003008:	00009497          	auipc	s1,0x9
    8000300c:	02848493          	addi	s1,s1,40 # 8000c030 <ticks>
    if(myproc()->killed){
    80003010:	fffff097          	auipc	ra,0xfffff
    80003014:	a6a080e7          	jalr	-1430(ra) # 80001a7a <myproc>
    80003018:	551c                	lw	a5,40(a0)
    8000301a:	ef9d                	bnez	a5,80003058 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000301c:	85ca                	mv	a1,s2
    8000301e:	8526                	mv	a0,s1
    80003020:	fffff097          	auipc	ra,0xfffff
    80003024:	1d6080e7          	jalr	470(ra) # 800021f6 <sleep>
  while(ticks - ticks0 < n){
    80003028:	409c                	lw	a5,0(s1)
    8000302a:	413787bb          	subw	a5,a5,s3
    8000302e:	fcc42703          	lw	a4,-52(s0)
    80003032:	fce7efe3          	bltu	a5,a4,80003010 <sys_sleep+0x50>
    80003036:	74a2                	ld	s1,40(sp)
    80003038:	7902                	ld	s2,32(sp)
    8000303a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000303c:	00017517          	auipc	a0,0x17
    80003040:	49450513          	addi	a0,a0,1172 # 8001a4d0 <tickslock>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	cc0080e7          	jalr	-832(ra) # 80000d04 <release>
  return 0;
    8000304c:	4781                	li	a5,0
}
    8000304e:	853e                	mv	a0,a5
    80003050:	70e2                	ld	ra,56(sp)
    80003052:	7442                	ld	s0,48(sp)
    80003054:	6121                	addi	sp,sp,64
    80003056:	8082                	ret
      release(&tickslock);
    80003058:	00017517          	auipc	a0,0x17
    8000305c:	47850513          	addi	a0,a0,1144 # 8001a4d0 <tickslock>
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	ca4080e7          	jalr	-860(ra) # 80000d04 <release>
      return -1;
    80003068:	57fd                	li	a5,-1
    8000306a:	74a2                	ld	s1,40(sp)
    8000306c:	7902                	ld	s2,32(sp)
    8000306e:	69e2                	ld	s3,24(sp)
    80003070:	bff9                	j	8000304e <sys_sleep+0x8e>

0000000080003072 <sys_kill>:

uint64
sys_kill(void)
{
    80003072:	1101                	addi	sp,sp,-32
    80003074:	ec06                	sd	ra,24(sp)
    80003076:	e822                	sd	s0,16(sp)
    80003078:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000307a:	fec40593          	addi	a1,s0,-20
    8000307e:	4501                	li	a0,0
    80003080:	00000097          	auipc	ra,0x0
    80003084:	cc2080e7          	jalr	-830(ra) # 80002d42 <argint>
    80003088:	87aa                	mv	a5,a0
    return -1;
    8000308a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000308c:	0007c863          	bltz	a5,8000309c <sys_kill+0x2a>
  return kill(pid);
    80003090:	fec42503          	lw	a0,-20(s0)
    80003094:	fffff097          	auipc	ra,0xfffff
    80003098:	5e4080e7          	jalr	1508(ra) # 80002678 <kill>
}
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	6105                	addi	sp,sp,32
    800030a2:	8082                	ret

00000000800030a4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030a4:	1101                	addi	sp,sp,-32
    800030a6:	ec06                	sd	ra,24(sp)
    800030a8:	e822                	sd	s0,16(sp)
    800030aa:	e426                	sd	s1,8(sp)
    800030ac:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030ae:	00017517          	auipc	a0,0x17
    800030b2:	42250513          	addi	a0,a0,1058 # 8001a4d0 <tickslock>
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	b9e080e7          	jalr	-1122(ra) # 80000c54 <acquire>
  xticks = ticks;
    800030be:	00009797          	auipc	a5,0x9
    800030c2:	f727a783          	lw	a5,-142(a5) # 8000c030 <ticks>
    800030c6:	84be                	mv	s1,a5
  release(&tickslock);
    800030c8:	00017517          	auipc	a0,0x17
    800030cc:	40850513          	addi	a0,a0,1032 # 8001a4d0 <tickslock>
    800030d0:	ffffe097          	auipc	ra,0xffffe
    800030d4:	c34080e7          	jalr	-972(ra) # 80000d04 <release>
  return xticks;
}
    800030d8:	02049513          	slli	a0,s1,0x20
    800030dc:	9101                	srli	a0,a0,0x20
    800030de:	60e2                	ld	ra,24(sp)
    800030e0:	6442                	ld	s0,16(sp)
    800030e2:	64a2                	ld	s1,8(sp)
    800030e4:	6105                	addi	sp,sp,32
    800030e6:	8082                	ret

00000000800030e8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	e052                	sd	s4,0(sp)
    800030f6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030f8:	00005597          	auipc	a1,0x5
    800030fc:	30858593          	addi	a1,a1,776 # 80008400 <etext+0x400>
    80003100:	00017517          	auipc	a0,0x17
    80003104:	3e850513          	addi	a0,a0,1000 # 8001a4e8 <bcache>
    80003108:	ffffe097          	auipc	ra,0xffffe
    8000310c:	ab2080e7          	jalr	-1358(ra) # 80000bba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003110:	0001f797          	auipc	a5,0x1f
    80003114:	3d878793          	addi	a5,a5,984 # 800224e8 <bcache+0x8000>
    80003118:	0001f717          	auipc	a4,0x1f
    8000311c:	63870713          	addi	a4,a4,1592 # 80022750 <bcache+0x8268>
    80003120:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003124:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003128:	00017497          	auipc	s1,0x17
    8000312c:	3d848493          	addi	s1,s1,984 # 8001a500 <bcache+0x18>
    b->next = bcache.head.next;
    80003130:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003132:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003134:	00005a17          	auipc	s4,0x5
    80003138:	2d4a0a13          	addi	s4,s4,724 # 80008408 <etext+0x408>
    b->next = bcache.head.next;
    8000313c:	2b893783          	ld	a5,696(s2)
    80003140:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003142:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003146:	85d2                	mv	a1,s4
    80003148:	01048513          	addi	a0,s1,16
    8000314c:	00001097          	auipc	ra,0x1
    80003150:	4c2080e7          	jalr	1218(ra) # 8000460e <initsleeplock>
    bcache.head.next->prev = b;
    80003154:	2b893783          	ld	a5,696(s2)
    80003158:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000315a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000315e:	45848493          	addi	s1,s1,1112
    80003162:	fd349de3          	bne	s1,s3,8000313c <binit+0x54>
  }
}
    80003166:	70a2                	ld	ra,40(sp)
    80003168:	7402                	ld	s0,32(sp)
    8000316a:	64e2                	ld	s1,24(sp)
    8000316c:	6942                	ld	s2,16(sp)
    8000316e:	69a2                	ld	s3,8(sp)
    80003170:	6a02                	ld	s4,0(sp)
    80003172:	6145                	addi	sp,sp,48
    80003174:	8082                	ret

0000000080003176 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003176:	7179                	addi	sp,sp,-48
    80003178:	f406                	sd	ra,40(sp)
    8000317a:	f022                	sd	s0,32(sp)
    8000317c:	ec26                	sd	s1,24(sp)
    8000317e:	e84a                	sd	s2,16(sp)
    80003180:	e44e                	sd	s3,8(sp)
    80003182:	1800                	addi	s0,sp,48
    80003184:	892a                	mv	s2,a0
    80003186:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003188:	00017517          	auipc	a0,0x17
    8000318c:	36050513          	addi	a0,a0,864 # 8001a4e8 <bcache>
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	ac4080e7          	jalr	-1340(ra) # 80000c54 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003198:	0001f497          	auipc	s1,0x1f
    8000319c:	6084b483          	ld	s1,1544(s1) # 800227a0 <bcache+0x82b8>
    800031a0:	0001f797          	auipc	a5,0x1f
    800031a4:	5b078793          	addi	a5,a5,1456 # 80022750 <bcache+0x8268>
    800031a8:	02f48f63          	beq	s1,a5,800031e6 <bread+0x70>
    800031ac:	873e                	mv	a4,a5
    800031ae:	a021                	j	800031b6 <bread+0x40>
    800031b0:	68a4                	ld	s1,80(s1)
    800031b2:	02e48a63          	beq	s1,a4,800031e6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031b6:	449c                	lw	a5,8(s1)
    800031b8:	ff279ce3          	bne	a5,s2,800031b0 <bread+0x3a>
    800031bc:	44dc                	lw	a5,12(s1)
    800031be:	ff3799e3          	bne	a5,s3,800031b0 <bread+0x3a>
      b->refcnt++;
    800031c2:	40bc                	lw	a5,64(s1)
    800031c4:	2785                	addiw	a5,a5,1
    800031c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031c8:	00017517          	auipc	a0,0x17
    800031cc:	32050513          	addi	a0,a0,800 # 8001a4e8 <bcache>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	b34080e7          	jalr	-1228(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    800031d8:	01048513          	addi	a0,s1,16
    800031dc:	00001097          	auipc	ra,0x1
    800031e0:	46c080e7          	jalr	1132(ra) # 80004648 <acquiresleep>
      return b;
    800031e4:	a8b9                	j	80003242 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031e6:	0001f497          	auipc	s1,0x1f
    800031ea:	5b24b483          	ld	s1,1458(s1) # 80022798 <bcache+0x82b0>
    800031ee:	0001f797          	auipc	a5,0x1f
    800031f2:	56278793          	addi	a5,a5,1378 # 80022750 <bcache+0x8268>
    800031f6:	00f48863          	beq	s1,a5,80003206 <bread+0x90>
    800031fa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031fc:	40bc                	lw	a5,64(s1)
    800031fe:	cf81                	beqz	a5,80003216 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003200:	64a4                	ld	s1,72(s1)
    80003202:	fee49de3          	bne	s1,a4,800031fc <bread+0x86>
  panic("bget: no buffers");
    80003206:	00005517          	auipc	a0,0x5
    8000320a:	20a50513          	addi	a0,a0,522 # 80008410 <etext+0x410>
    8000320e:	ffffd097          	auipc	ra,0xffffd
    80003212:	348080e7          	jalr	840(ra) # 80000556 <panic>
      b->dev = dev;
    80003216:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000321a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000321e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003222:	4785                	li	a5,1
    80003224:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003226:	00017517          	auipc	a0,0x17
    8000322a:	2c250513          	addi	a0,a0,706 # 8001a4e8 <bcache>
    8000322e:	ffffe097          	auipc	ra,0xffffe
    80003232:	ad6080e7          	jalr	-1322(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80003236:	01048513          	addi	a0,s1,16
    8000323a:	00001097          	auipc	ra,0x1
    8000323e:	40e080e7          	jalr	1038(ra) # 80004648 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003242:	409c                	lw	a5,0(s1)
    80003244:	cb89                	beqz	a5,80003256 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003246:	8526                	mv	a0,s1
    80003248:	70a2                	ld	ra,40(sp)
    8000324a:	7402                	ld	s0,32(sp)
    8000324c:	64e2                	ld	s1,24(sp)
    8000324e:	6942                	ld	s2,16(sp)
    80003250:	69a2                	ld	s3,8(sp)
    80003252:	6145                	addi	sp,sp,48
    80003254:	8082                	ret
    virtio_disk_rw(b, 0);
    80003256:	4581                	li	a1,0
    80003258:	8526                	mv	a0,s1
    8000325a:	00003097          	auipc	ra,0x3
    8000325e:	034080e7          	jalr	52(ra) # 8000628e <virtio_disk_rw>
    b->valid = 1;
    80003262:	4785                	li	a5,1
    80003264:	c09c                	sw	a5,0(s1)
  return b;
    80003266:	b7c5                	j	80003246 <bread+0xd0>

0000000080003268 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003268:	1101                	addi	sp,sp,-32
    8000326a:	ec06                	sd	ra,24(sp)
    8000326c:	e822                	sd	s0,16(sp)
    8000326e:	e426                	sd	s1,8(sp)
    80003270:	1000                	addi	s0,sp,32
    80003272:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003274:	0541                	addi	a0,a0,16
    80003276:	00001097          	auipc	ra,0x1
    8000327a:	46c080e7          	jalr	1132(ra) # 800046e2 <holdingsleep>
    8000327e:	cd01                	beqz	a0,80003296 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003280:	4585                	li	a1,1
    80003282:	8526                	mv	a0,s1
    80003284:	00003097          	auipc	ra,0x3
    80003288:	00a080e7          	jalr	10(ra) # 8000628e <virtio_disk_rw>
}
    8000328c:	60e2                	ld	ra,24(sp)
    8000328e:	6442                	ld	s0,16(sp)
    80003290:	64a2                	ld	s1,8(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret
    panic("bwrite");
    80003296:	00005517          	auipc	a0,0x5
    8000329a:	19250513          	addi	a0,a0,402 # 80008428 <etext+0x428>
    8000329e:	ffffd097          	auipc	ra,0xffffd
    800032a2:	2b8080e7          	jalr	696(ra) # 80000556 <panic>

00000000800032a6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	e426                	sd	s1,8(sp)
    800032ae:	e04a                	sd	s2,0(sp)
    800032b0:	1000                	addi	s0,sp,32
    800032b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032b4:	01050913          	addi	s2,a0,16
    800032b8:	854a                	mv	a0,s2
    800032ba:	00001097          	auipc	ra,0x1
    800032be:	428080e7          	jalr	1064(ra) # 800046e2 <holdingsleep>
    800032c2:	c535                	beqz	a0,8000332e <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    800032c4:	854a                	mv	a0,s2
    800032c6:	00001097          	auipc	ra,0x1
    800032ca:	3d8080e7          	jalr	984(ra) # 8000469e <releasesleep>

  acquire(&bcache.lock);
    800032ce:	00017517          	auipc	a0,0x17
    800032d2:	21a50513          	addi	a0,a0,538 # 8001a4e8 <bcache>
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	97e080e7          	jalr	-1666(ra) # 80000c54 <acquire>
  b->refcnt--;
    800032de:	40bc                	lw	a5,64(s1)
    800032e0:	37fd                	addiw	a5,a5,-1
    800032e2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032e4:	e79d                	bnez	a5,80003312 <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032e6:	68b8                	ld	a4,80(s1)
    800032e8:	64bc                	ld	a5,72(s1)
    800032ea:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800032ec:	68b8                	ld	a4,80(s1)
    800032ee:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032f0:	0001f797          	auipc	a5,0x1f
    800032f4:	1f878793          	addi	a5,a5,504 # 800224e8 <bcache+0x8000>
    800032f8:	2b87b703          	ld	a4,696(a5)
    800032fc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032fe:	0001f717          	auipc	a4,0x1f
    80003302:	45270713          	addi	a4,a4,1106 # 80022750 <bcache+0x8268>
    80003306:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003308:	2b87b703          	ld	a4,696(a5)
    8000330c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000330e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003312:	00017517          	auipc	a0,0x17
    80003316:	1d650513          	addi	a0,a0,470 # 8001a4e8 <bcache>
    8000331a:	ffffe097          	auipc	ra,0xffffe
    8000331e:	9ea080e7          	jalr	-1558(ra) # 80000d04 <release>
}
    80003322:	60e2                	ld	ra,24(sp)
    80003324:	6442                	ld	s0,16(sp)
    80003326:	64a2                	ld	s1,8(sp)
    80003328:	6902                	ld	s2,0(sp)
    8000332a:	6105                	addi	sp,sp,32
    8000332c:	8082                	ret
    panic("brelse");
    8000332e:	00005517          	auipc	a0,0x5
    80003332:	10250513          	addi	a0,a0,258 # 80008430 <etext+0x430>
    80003336:	ffffd097          	auipc	ra,0xffffd
    8000333a:	220080e7          	jalr	544(ra) # 80000556 <panic>

000000008000333e <bpin>:

void
bpin(struct buf *b) {
    8000333e:	1101                	addi	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	1000                	addi	s0,sp,32
    80003348:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000334a:	00017517          	auipc	a0,0x17
    8000334e:	19e50513          	addi	a0,a0,414 # 8001a4e8 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	902080e7          	jalr	-1790(ra) # 80000c54 <acquire>
  b->refcnt++;
    8000335a:	40bc                	lw	a5,64(s1)
    8000335c:	2785                	addiw	a5,a5,1
    8000335e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003360:	00017517          	auipc	a0,0x17
    80003364:	18850513          	addi	a0,a0,392 # 8001a4e8 <bcache>
    80003368:	ffffe097          	auipc	ra,0xffffe
    8000336c:	99c080e7          	jalr	-1636(ra) # 80000d04 <release>
}
    80003370:	60e2                	ld	ra,24(sp)
    80003372:	6442                	ld	s0,16(sp)
    80003374:	64a2                	ld	s1,8(sp)
    80003376:	6105                	addi	sp,sp,32
    80003378:	8082                	ret

000000008000337a <bunpin>:

void
bunpin(struct buf *b) {
    8000337a:	1101                	addi	sp,sp,-32
    8000337c:	ec06                	sd	ra,24(sp)
    8000337e:	e822                	sd	s0,16(sp)
    80003380:	e426                	sd	s1,8(sp)
    80003382:	1000                	addi	s0,sp,32
    80003384:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003386:	00017517          	auipc	a0,0x17
    8000338a:	16250513          	addi	a0,a0,354 # 8001a4e8 <bcache>
    8000338e:	ffffe097          	auipc	ra,0xffffe
    80003392:	8c6080e7          	jalr	-1850(ra) # 80000c54 <acquire>
  b->refcnt--;
    80003396:	40bc                	lw	a5,64(s1)
    80003398:	37fd                	addiw	a5,a5,-1
    8000339a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000339c:	00017517          	auipc	a0,0x17
    800033a0:	14c50513          	addi	a0,a0,332 # 8001a4e8 <bcache>
    800033a4:	ffffe097          	auipc	ra,0xffffe
    800033a8:	960080e7          	jalr	-1696(ra) # 80000d04 <release>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	e426                	sd	s1,8(sp)
    800033be:	e04a                	sd	s2,0(sp)
    800033c0:	1000                	addi	s0,sp,32
    800033c2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033c4:	00d5d79b          	srliw	a5,a1,0xd
    800033c8:	0001f597          	auipc	a1,0x1f
    800033cc:	7fc5a583          	lw	a1,2044(a1) # 80022bc4 <sb+0x1c>
    800033d0:	9dbd                	addw	a1,a1,a5
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	da4080e7          	jalr	-604(ra) # 80003176 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033da:	0074f713          	andi	a4,s1,7
    800033de:	4785                	li	a5,1
    800033e0:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800033e4:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800033e6:	90d9                	srli	s1,s1,0x36
    800033e8:	00950733          	add	a4,a0,s1
    800033ec:	05874703          	lbu	a4,88(a4)
    800033f0:	00e7f6b3          	and	a3,a5,a4
    800033f4:	c69d                	beqz	a3,80003422 <bfree+0x6c>
    800033f6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033f8:	94aa                	add	s1,s1,a0
    800033fa:	fff7c793          	not	a5,a5
    800033fe:	8f7d                	and	a4,a4,a5
    80003400:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003404:	00001097          	auipc	ra,0x1
    80003408:	124080e7          	jalr	292(ra) # 80004528 <log_write>
  brelse(bp);
    8000340c:	854a                	mv	a0,s2
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	e98080e7          	jalr	-360(ra) # 800032a6 <brelse>
}
    80003416:	60e2                	ld	ra,24(sp)
    80003418:	6442                	ld	s0,16(sp)
    8000341a:	64a2                	ld	s1,8(sp)
    8000341c:	6902                	ld	s2,0(sp)
    8000341e:	6105                	addi	sp,sp,32
    80003420:	8082                	ret
    panic("freeing free block");
    80003422:	00005517          	auipc	a0,0x5
    80003426:	01650513          	addi	a0,a0,22 # 80008438 <etext+0x438>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	12c080e7          	jalr	300(ra) # 80000556 <panic>

0000000080003432 <balloc>:
{
    80003432:	715d                	addi	sp,sp,-80
    80003434:	e486                	sd	ra,72(sp)
    80003436:	e0a2                	sd	s0,64(sp)
    80003438:	fc26                	sd	s1,56(sp)
    8000343a:	f84a                	sd	s2,48(sp)
    8000343c:	f44e                	sd	s3,40(sp)
    8000343e:	f052                	sd	s4,32(sp)
    80003440:	ec56                	sd	s5,24(sp)
    80003442:	e85a                	sd	s6,16(sp)
    80003444:	e45e                	sd	s7,8(sp)
    80003446:	e062                	sd	s8,0(sp)
    80003448:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    8000344a:	0001f797          	auipc	a5,0x1f
    8000344e:	7627a783          	lw	a5,1890(a5) # 80022bac <sb+0x4>
    80003452:	cfb5                	beqz	a5,800034ce <balloc+0x9c>
    80003454:	8baa                	mv	s7,a0
    80003456:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003458:	0001fb17          	auipc	s6,0x1f
    8000345c:	750b0b13          	addi	s6,s6,1872 # 80022ba8 <sb>
      m = 1 << (bi % 8);
    80003460:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003462:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003464:	6c09                	lui	s8,0x2
    80003466:	a821                	j	8000347e <balloc+0x4c>
    brelse(bp);
    80003468:	854a                	mv	a0,s2
    8000346a:	00000097          	auipc	ra,0x0
    8000346e:	e3c080e7          	jalr	-452(ra) # 800032a6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003472:	015c0abb          	addw	s5,s8,s5
    80003476:	004b2783          	lw	a5,4(s6)
    8000347a:	04fafa63          	bgeu	s5,a5,800034ce <balloc+0x9c>
    bp = bread(dev, BBLOCK(b, sb));
    8000347e:	40dad59b          	sraiw	a1,s5,0xd
    80003482:	01cb2783          	lw	a5,28(s6)
    80003486:	9dbd                	addw	a1,a1,a5
    80003488:	855e                	mv	a0,s7
    8000348a:	00000097          	auipc	ra,0x0
    8000348e:	cec080e7          	jalr	-788(ra) # 80003176 <bread>
    80003492:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003494:	004b2503          	lw	a0,4(s6)
    80003498:	84d6                	mv	s1,s5
    8000349a:	4701                	li	a4,0
    8000349c:	fca4f6e3          	bgeu	s1,a0,80003468 <balloc+0x36>
      m = 1 << (bi % 8);
    800034a0:	00777693          	andi	a3,a4,7
    800034a4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034a8:	41f7579b          	sraiw	a5,a4,0x1f
    800034ac:	01d7d79b          	srliw	a5,a5,0x1d
    800034b0:	9fb9                	addw	a5,a5,a4
    800034b2:	4037d79b          	sraiw	a5,a5,0x3
    800034b6:	00f90633          	add	a2,s2,a5
    800034ba:	05864603          	lbu	a2,88(a2)
    800034be:	00c6f5b3          	and	a1,a3,a2
    800034c2:	cd91                	beqz	a1,800034de <balloc+0xac>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034c4:	2705                	addiw	a4,a4,1
    800034c6:	2485                	addiw	s1,s1,1
    800034c8:	fd471ae3          	bne	a4,s4,8000349c <balloc+0x6a>
    800034cc:	bf71                	j	80003468 <balloc+0x36>
  panic("balloc: out of blocks");
    800034ce:	00005517          	auipc	a0,0x5
    800034d2:	f8250513          	addi	a0,a0,-126 # 80008450 <etext+0x450>
    800034d6:	ffffd097          	auipc	ra,0xffffd
    800034da:	080080e7          	jalr	128(ra) # 80000556 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034de:	97ca                	add	a5,a5,s2
    800034e0:	8e55                	or	a2,a2,a3
    800034e2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800034e6:	854a                	mv	a0,s2
    800034e8:	00001097          	auipc	ra,0x1
    800034ec:	040080e7          	jalr	64(ra) # 80004528 <log_write>
        brelse(bp);
    800034f0:	854a                	mv	a0,s2
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	db4080e7          	jalr	-588(ra) # 800032a6 <brelse>
  bp = bread(dev, bno);
    800034fa:	85a6                	mv	a1,s1
    800034fc:	855e                	mv	a0,s7
    800034fe:	00000097          	auipc	ra,0x0
    80003502:	c78080e7          	jalr	-904(ra) # 80003176 <bread>
    80003506:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003508:	40000613          	li	a2,1024
    8000350c:	4581                	li	a1,0
    8000350e:	05850513          	addi	a0,a0,88
    80003512:	ffffe097          	auipc	ra,0xffffe
    80003516:	83a080e7          	jalr	-1990(ra) # 80000d4c <memset>
  log_write(bp);
    8000351a:	854a                	mv	a0,s2
    8000351c:	00001097          	auipc	ra,0x1
    80003520:	00c080e7          	jalr	12(ra) # 80004528 <log_write>
  brelse(bp);
    80003524:	854a                	mv	a0,s2
    80003526:	00000097          	auipc	ra,0x0
    8000352a:	d80080e7          	jalr	-640(ra) # 800032a6 <brelse>
}
    8000352e:	8526                	mv	a0,s1
    80003530:	60a6                	ld	ra,72(sp)
    80003532:	6406                	ld	s0,64(sp)
    80003534:	74e2                	ld	s1,56(sp)
    80003536:	7942                	ld	s2,48(sp)
    80003538:	79a2                	ld	s3,40(sp)
    8000353a:	7a02                	ld	s4,32(sp)
    8000353c:	6ae2                	ld	s5,24(sp)
    8000353e:	6b42                	ld	s6,16(sp)
    80003540:	6ba2                	ld	s7,8(sp)
    80003542:	6c02                	ld	s8,0(sp)
    80003544:	6161                	addi	sp,sp,80
    80003546:	8082                	ret

0000000080003548 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003548:	7179                	addi	sp,sp,-48
    8000354a:	f406                	sd	ra,40(sp)
    8000354c:	f022                	sd	s0,32(sp)
    8000354e:	ec26                	sd	s1,24(sp)
    80003550:	e84a                	sd	s2,16(sp)
    80003552:	e44e                	sd	s3,8(sp)
    80003554:	1800                	addi	s0,sp,48
    80003556:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003558:	47ad                	li	a5,11
    8000355a:	04b7fd63          	bgeu	a5,a1,800035b4 <bmap+0x6c>
    8000355e:	e052                	sd	s4,0(sp)
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003560:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80003564:	0ff00793          	li	a5,255
    80003568:	0897ef63          	bltu	a5,s1,80003606 <bmap+0xbe>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000356c:	08052583          	lw	a1,128(a0)
    80003570:	c5a5                	beqz	a1,800035d8 <bmap+0x90>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003572:	00092503          	lw	a0,0(s2)
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	c00080e7          	jalr	-1024(ra) # 80003176 <bread>
    8000357e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003580:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003584:	02049713          	slli	a4,s1,0x20
    80003588:	01e75593          	srli	a1,a4,0x1e
    8000358c:	00b784b3          	add	s1,a5,a1
    80003590:	0004a983          	lw	s3,0(s1)
    80003594:	04098b63          	beqz	s3,800035ea <bmap+0xa2>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003598:	8552                	mv	a0,s4
    8000359a:	00000097          	auipc	ra,0x0
    8000359e:	d0c080e7          	jalr	-756(ra) # 800032a6 <brelse>
    return addr;
    800035a2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800035a4:	854e                	mv	a0,s3
    800035a6:	70a2                	ld	ra,40(sp)
    800035a8:	7402                	ld	s0,32(sp)
    800035aa:	64e2                	ld	s1,24(sp)
    800035ac:	6942                	ld	s2,16(sp)
    800035ae:	69a2                	ld	s3,8(sp)
    800035b0:	6145                	addi	sp,sp,48
    800035b2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800035b4:	02059793          	slli	a5,a1,0x20
    800035b8:	01e7d593          	srli	a1,a5,0x1e
    800035bc:	00b504b3          	add	s1,a0,a1
    800035c0:	0504a983          	lw	s3,80(s1)
    800035c4:	fe0990e3          	bnez	s3,800035a4 <bmap+0x5c>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800035c8:	4108                	lw	a0,0(a0)
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e68080e7          	jalr	-408(ra) # 80003432 <balloc>
    800035d2:	89aa                	mv	s3,a0
    800035d4:	c8a8                	sw	a0,80(s1)
    800035d6:	b7f9                	j	800035a4 <bmap+0x5c>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800035d8:	4108                	lw	a0,0(a0)
    800035da:	00000097          	auipc	ra,0x0
    800035de:	e58080e7          	jalr	-424(ra) # 80003432 <balloc>
    800035e2:	85aa                	mv	a1,a0
    800035e4:	08a92023          	sw	a0,128(s2)
    800035e8:	b769                	j	80003572 <bmap+0x2a>
      a[bn] = addr = balloc(ip->dev);
    800035ea:	00092503          	lw	a0,0(s2)
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	e44080e7          	jalr	-444(ra) # 80003432 <balloc>
    800035f6:	89aa                	mv	s3,a0
    800035f8:	c088                	sw	a0,0(s1)
      log_write(bp);
    800035fa:	8552                	mv	a0,s4
    800035fc:	00001097          	auipc	ra,0x1
    80003600:	f2c080e7          	jalr	-212(ra) # 80004528 <log_write>
    80003604:	bf51                	j	80003598 <bmap+0x50>
  panic("bmap: out of range");
    80003606:	00005517          	auipc	a0,0x5
    8000360a:	e6250513          	addi	a0,a0,-414 # 80008468 <etext+0x468>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	f48080e7          	jalr	-184(ra) # 80000556 <panic>

0000000080003616 <iget>:
{
    80003616:	7179                	addi	sp,sp,-48
    80003618:	f406                	sd	ra,40(sp)
    8000361a:	f022                	sd	s0,32(sp)
    8000361c:	ec26                	sd	s1,24(sp)
    8000361e:	e84a                	sd	s2,16(sp)
    80003620:	e44e                	sd	s3,8(sp)
    80003622:	e052                	sd	s4,0(sp)
    80003624:	1800                	addi	s0,sp,48
    80003626:	892a                	mv	s2,a0
    80003628:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000362a:	0001f517          	auipc	a0,0x1f
    8000362e:	59e50513          	addi	a0,a0,1438 # 80022bc8 <itable>
    80003632:	ffffd097          	auipc	ra,0xffffd
    80003636:	622080e7          	jalr	1570(ra) # 80000c54 <acquire>
  empty = 0;
    8000363a:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000363c:	0001f497          	auipc	s1,0x1f
    80003640:	5a448493          	addi	s1,s1,1444 # 80022be0 <itable+0x18>
    80003644:	00021697          	auipc	a3,0x21
    80003648:	02c68693          	addi	a3,a3,44 # 80024670 <log>
    8000364c:	a809                	j	8000365e <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000364e:	e781                	bnez	a5,80003656 <iget+0x40>
    80003650:	00099363          	bnez	s3,80003656 <iget+0x40>
      empty = ip;
    80003654:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003656:	08848493          	addi	s1,s1,136
    8000365a:	02d48763          	beq	s1,a3,80003688 <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000365e:	449c                	lw	a5,8(s1)
    80003660:	fef057e3          	blez	a5,8000364e <iget+0x38>
    80003664:	4098                	lw	a4,0(s1)
    80003666:	ff2718e3          	bne	a4,s2,80003656 <iget+0x40>
    8000366a:	40d8                	lw	a4,4(s1)
    8000366c:	ff4715e3          	bne	a4,s4,80003656 <iget+0x40>
      ip->ref++;
    80003670:	2785                	addiw	a5,a5,1
    80003672:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003674:	0001f517          	auipc	a0,0x1f
    80003678:	55450513          	addi	a0,a0,1364 # 80022bc8 <itable>
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	688080e7          	jalr	1672(ra) # 80000d04 <release>
      return ip;
    80003684:	89a6                	mv	s3,s1
    80003686:	a025                	j	800036ae <iget+0x98>
  if(empty == 0)
    80003688:	02098c63          	beqz	s3,800036c0 <iget+0xaa>
  ip->dev = dev;
    8000368c:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003690:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003694:	4785                	li	a5,1
    80003696:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    8000369a:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000369e:	0001f517          	auipc	a0,0x1f
    800036a2:	52a50513          	addi	a0,a0,1322 # 80022bc8 <itable>
    800036a6:	ffffd097          	auipc	ra,0xffffd
    800036aa:	65e080e7          	jalr	1630(ra) # 80000d04 <release>
}
    800036ae:	854e                	mv	a0,s3
    800036b0:	70a2                	ld	ra,40(sp)
    800036b2:	7402                	ld	s0,32(sp)
    800036b4:	64e2                	ld	s1,24(sp)
    800036b6:	6942                	ld	s2,16(sp)
    800036b8:	69a2                	ld	s3,8(sp)
    800036ba:	6a02                	ld	s4,0(sp)
    800036bc:	6145                	addi	sp,sp,48
    800036be:	8082                	ret
    panic("iget: no inodes");
    800036c0:	00005517          	auipc	a0,0x5
    800036c4:	dc050513          	addi	a0,a0,-576 # 80008480 <etext+0x480>
    800036c8:	ffffd097          	auipc	ra,0xffffd
    800036cc:	e8e080e7          	jalr	-370(ra) # 80000556 <panic>

00000000800036d0 <fsinit>:
fsinit(int dev) {
    800036d0:	1101                	addi	sp,sp,-32
    800036d2:	ec06                	sd	ra,24(sp)
    800036d4:	e822                	sd	s0,16(sp)
    800036d6:	e426                	sd	s1,8(sp)
    800036d8:	e04a                	sd	s2,0(sp)
    800036da:	1000                	addi	s0,sp,32
    800036dc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036de:	4585                	li	a1,1
    800036e0:	00000097          	auipc	ra,0x0
    800036e4:	a96080e7          	jalr	-1386(ra) # 80003176 <bread>
    800036e8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036ea:	02000613          	li	a2,32
    800036ee:	05850593          	addi	a1,a0,88
    800036f2:	0001f517          	auipc	a0,0x1f
    800036f6:	4b650513          	addi	a0,a0,1206 # 80022ba8 <sb>
    800036fa:	ffffd097          	auipc	ra,0xffffd
    800036fe:	6b2080e7          	jalr	1714(ra) # 80000dac <memmove>
  brelse(bp);
    80003702:	8526                	mv	a0,s1
    80003704:	00000097          	auipc	ra,0x0
    80003708:	ba2080e7          	jalr	-1118(ra) # 800032a6 <brelse>
  if(sb.magic != FSMAGIC)
    8000370c:	0001f717          	auipc	a4,0x1f
    80003710:	49c72703          	lw	a4,1180(a4) # 80022ba8 <sb>
    80003714:	102037b7          	lui	a5,0x10203
    80003718:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000371c:	02f71163          	bne	a4,a5,8000373e <fsinit+0x6e>
  initlog(dev, &sb);
    80003720:	0001f597          	auipc	a1,0x1f
    80003724:	48858593          	addi	a1,a1,1160 # 80022ba8 <sb>
    80003728:	854a                	mv	a0,s2
    8000372a:	00001097          	auipc	ra,0x1
    8000372e:	b78080e7          	jalr	-1160(ra) # 800042a2 <initlog>
}
    80003732:	60e2                	ld	ra,24(sp)
    80003734:	6442                	ld	s0,16(sp)
    80003736:	64a2                	ld	s1,8(sp)
    80003738:	6902                	ld	s2,0(sp)
    8000373a:	6105                	addi	sp,sp,32
    8000373c:	8082                	ret
    panic("invalid file system");
    8000373e:	00005517          	auipc	a0,0x5
    80003742:	d5250513          	addi	a0,a0,-686 # 80008490 <etext+0x490>
    80003746:	ffffd097          	auipc	ra,0xffffd
    8000374a:	e10080e7          	jalr	-496(ra) # 80000556 <panic>

000000008000374e <iinit>:
{
    8000374e:	7179                	addi	sp,sp,-48
    80003750:	f406                	sd	ra,40(sp)
    80003752:	f022                	sd	s0,32(sp)
    80003754:	ec26                	sd	s1,24(sp)
    80003756:	e84a                	sd	s2,16(sp)
    80003758:	e44e                	sd	s3,8(sp)
    8000375a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000375c:	00005597          	auipc	a1,0x5
    80003760:	d4c58593          	addi	a1,a1,-692 # 800084a8 <etext+0x4a8>
    80003764:	0001f517          	auipc	a0,0x1f
    80003768:	46450513          	addi	a0,a0,1124 # 80022bc8 <itable>
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	44e080e7          	jalr	1102(ra) # 80000bba <initlock>
  for(i = 0; i < NINODE; i++) {
    80003774:	0001f497          	auipc	s1,0x1f
    80003778:	47c48493          	addi	s1,s1,1148 # 80022bf0 <itable+0x28>
    8000377c:	00021997          	auipc	s3,0x21
    80003780:	f0498993          	addi	s3,s3,-252 # 80024680 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003784:	00005917          	auipc	s2,0x5
    80003788:	d2c90913          	addi	s2,s2,-724 # 800084b0 <etext+0x4b0>
    8000378c:	85ca                	mv	a1,s2
    8000378e:	8526                	mv	a0,s1
    80003790:	00001097          	auipc	ra,0x1
    80003794:	e7e080e7          	jalr	-386(ra) # 8000460e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003798:	08848493          	addi	s1,s1,136
    8000379c:	ff3498e3          	bne	s1,s3,8000378c <iinit+0x3e>
}
    800037a0:	70a2                	ld	ra,40(sp)
    800037a2:	7402                	ld	s0,32(sp)
    800037a4:	64e2                	ld	s1,24(sp)
    800037a6:	6942                	ld	s2,16(sp)
    800037a8:	69a2                	ld	s3,8(sp)
    800037aa:	6145                	addi	sp,sp,48
    800037ac:	8082                	ret

00000000800037ae <ialloc>:
{
    800037ae:	7139                	addi	sp,sp,-64
    800037b0:	fc06                	sd	ra,56(sp)
    800037b2:	f822                	sd	s0,48(sp)
    800037b4:	f426                	sd	s1,40(sp)
    800037b6:	f04a                	sd	s2,32(sp)
    800037b8:	ec4e                	sd	s3,24(sp)
    800037ba:	e852                	sd	s4,16(sp)
    800037bc:	e456                	sd	s5,8(sp)
    800037be:	e05a                	sd	s6,0(sp)
    800037c0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800037c2:	0001f717          	auipc	a4,0x1f
    800037c6:	3f272703          	lw	a4,1010(a4) # 80022bb4 <sb+0xc>
    800037ca:	4785                	li	a5,1
    800037cc:	04e7f863          	bgeu	a5,a4,8000381c <ialloc+0x6e>
    800037d0:	8aaa                	mv	s5,a0
    800037d2:	8b2e                	mv	s6,a1
    800037d4:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800037d6:	0001fa17          	auipc	s4,0x1f
    800037da:	3d2a0a13          	addi	s4,s4,978 # 80022ba8 <sb>
    800037de:	00495593          	srli	a1,s2,0x4
    800037e2:	018a2783          	lw	a5,24(s4)
    800037e6:	9dbd                	addw	a1,a1,a5
    800037e8:	8556                	mv	a0,s5
    800037ea:	00000097          	auipc	ra,0x0
    800037ee:	98c080e7          	jalr	-1652(ra) # 80003176 <bread>
    800037f2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037f4:	05850993          	addi	s3,a0,88
    800037f8:	00f97793          	andi	a5,s2,15
    800037fc:	079a                	slli	a5,a5,0x6
    800037fe:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003800:	00099783          	lh	a5,0(s3)
    80003804:	c785                	beqz	a5,8000382c <ialloc+0x7e>
    brelse(bp);
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	aa0080e7          	jalr	-1376(ra) # 800032a6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000380e:	0905                	addi	s2,s2,1
    80003810:	00ca2703          	lw	a4,12(s4)
    80003814:	0009079b          	sext.w	a5,s2
    80003818:	fce7e3e3          	bltu	a5,a4,800037de <ialloc+0x30>
  panic("ialloc: no inodes");
    8000381c:	00005517          	auipc	a0,0x5
    80003820:	c9c50513          	addi	a0,a0,-868 # 800084b8 <etext+0x4b8>
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	d32080e7          	jalr	-718(ra) # 80000556 <panic>
      memset(dip, 0, sizeof(*dip));
    8000382c:	04000613          	li	a2,64
    80003830:	4581                	li	a1,0
    80003832:	854e                	mv	a0,s3
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	518080e7          	jalr	1304(ra) # 80000d4c <memset>
      dip->type = type;
    8000383c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003840:	8526                	mv	a0,s1
    80003842:	00001097          	auipc	ra,0x1
    80003846:	ce6080e7          	jalr	-794(ra) # 80004528 <log_write>
      brelse(bp);
    8000384a:	8526                	mv	a0,s1
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	a5a080e7          	jalr	-1446(ra) # 800032a6 <brelse>
      return iget(dev, inum);
    80003854:	0009059b          	sext.w	a1,s2
    80003858:	8556                	mv	a0,s5
    8000385a:	00000097          	auipc	ra,0x0
    8000385e:	dbc080e7          	jalr	-580(ra) # 80003616 <iget>
}
    80003862:	70e2                	ld	ra,56(sp)
    80003864:	7442                	ld	s0,48(sp)
    80003866:	74a2                	ld	s1,40(sp)
    80003868:	7902                	ld	s2,32(sp)
    8000386a:	69e2                	ld	s3,24(sp)
    8000386c:	6a42                	ld	s4,16(sp)
    8000386e:	6aa2                	ld	s5,8(sp)
    80003870:	6b02                	ld	s6,0(sp)
    80003872:	6121                	addi	sp,sp,64
    80003874:	8082                	ret

0000000080003876 <iupdate>:
{
    80003876:	1101                	addi	sp,sp,-32
    80003878:	ec06                	sd	ra,24(sp)
    8000387a:	e822                	sd	s0,16(sp)
    8000387c:	e426                	sd	s1,8(sp)
    8000387e:	e04a                	sd	s2,0(sp)
    80003880:	1000                	addi	s0,sp,32
    80003882:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003884:	415c                	lw	a5,4(a0)
    80003886:	0047d79b          	srliw	a5,a5,0x4
    8000388a:	0001f597          	auipc	a1,0x1f
    8000388e:	3365a583          	lw	a1,822(a1) # 80022bc0 <sb+0x18>
    80003892:	9dbd                	addw	a1,a1,a5
    80003894:	4108                	lw	a0,0(a0)
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	8e0080e7          	jalr	-1824(ra) # 80003176 <bread>
    8000389e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038a0:	05850793          	addi	a5,a0,88
    800038a4:	40d8                	lw	a4,4(s1)
    800038a6:	8b3d                	andi	a4,a4,15
    800038a8:	071a                	slli	a4,a4,0x6
    800038aa:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800038ac:	04449703          	lh	a4,68(s1)
    800038b0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800038b4:	04649703          	lh	a4,70(s1)
    800038b8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800038bc:	04849703          	lh	a4,72(s1)
    800038c0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800038c4:	04a49703          	lh	a4,74(s1)
    800038c8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800038cc:	44f8                	lw	a4,76(s1)
    800038ce:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038d0:	03400613          	li	a2,52
    800038d4:	05048593          	addi	a1,s1,80
    800038d8:	00c78513          	addi	a0,a5,12
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	4d0080e7          	jalr	1232(ra) # 80000dac <memmove>
  log_write(bp);
    800038e4:	854a                	mv	a0,s2
    800038e6:	00001097          	auipc	ra,0x1
    800038ea:	c42080e7          	jalr	-958(ra) # 80004528 <log_write>
  brelse(bp);
    800038ee:	854a                	mv	a0,s2
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	9b6080e7          	jalr	-1610(ra) # 800032a6 <brelse>
}
    800038f8:	60e2                	ld	ra,24(sp)
    800038fa:	6442                	ld	s0,16(sp)
    800038fc:	64a2                	ld	s1,8(sp)
    800038fe:	6902                	ld	s2,0(sp)
    80003900:	6105                	addi	sp,sp,32
    80003902:	8082                	ret

0000000080003904 <idup>:
{
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	1000                	addi	s0,sp,32
    8000390e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003910:	0001f517          	auipc	a0,0x1f
    80003914:	2b850513          	addi	a0,a0,696 # 80022bc8 <itable>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	33c080e7          	jalr	828(ra) # 80000c54 <acquire>
  ip->ref++;
    80003920:	449c                	lw	a5,8(s1)
    80003922:	2785                	addiw	a5,a5,1
    80003924:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003926:	0001f517          	auipc	a0,0x1f
    8000392a:	2a250513          	addi	a0,a0,674 # 80022bc8 <itable>
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	3d6080e7          	jalr	982(ra) # 80000d04 <release>
}
    80003936:	8526                	mv	a0,s1
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6105                	addi	sp,sp,32
    80003940:	8082                	ret

0000000080003942 <ilock>:
{
    80003942:	1101                	addi	sp,sp,-32
    80003944:	ec06                	sd	ra,24(sp)
    80003946:	e822                	sd	s0,16(sp)
    80003948:	e426                	sd	s1,8(sp)
    8000394a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000394c:	c10d                	beqz	a0,8000396e <ilock+0x2c>
    8000394e:	84aa                	mv	s1,a0
    80003950:	451c                	lw	a5,8(a0)
    80003952:	00f05e63          	blez	a5,8000396e <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003956:	0541                	addi	a0,a0,16
    80003958:	00001097          	auipc	ra,0x1
    8000395c:	cf0080e7          	jalr	-784(ra) # 80004648 <acquiresleep>
  if(ip->valid == 0){
    80003960:	40bc                	lw	a5,64(s1)
    80003962:	cf99                	beqz	a5,80003980 <ilock+0x3e>
}
    80003964:	60e2                	ld	ra,24(sp)
    80003966:	6442                	ld	s0,16(sp)
    80003968:	64a2                	ld	s1,8(sp)
    8000396a:	6105                	addi	sp,sp,32
    8000396c:	8082                	ret
    8000396e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003970:	00005517          	auipc	a0,0x5
    80003974:	b6050513          	addi	a0,a0,-1184 # 800084d0 <etext+0x4d0>
    80003978:	ffffd097          	auipc	ra,0xffffd
    8000397c:	bde080e7          	jalr	-1058(ra) # 80000556 <panic>
    80003980:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003982:	40dc                	lw	a5,4(s1)
    80003984:	0047d79b          	srliw	a5,a5,0x4
    80003988:	0001f597          	auipc	a1,0x1f
    8000398c:	2385a583          	lw	a1,568(a1) # 80022bc0 <sb+0x18>
    80003990:	9dbd                	addw	a1,a1,a5
    80003992:	4088                	lw	a0,0(s1)
    80003994:	fffff097          	auipc	ra,0xfffff
    80003998:	7e2080e7          	jalr	2018(ra) # 80003176 <bread>
    8000399c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000399e:	05850593          	addi	a1,a0,88
    800039a2:	40dc                	lw	a5,4(s1)
    800039a4:	8bbd                	andi	a5,a5,15
    800039a6:	079a                	slli	a5,a5,0x6
    800039a8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039aa:	00059783          	lh	a5,0(a1)
    800039ae:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039b2:	00259783          	lh	a5,2(a1)
    800039b6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039ba:	00459783          	lh	a5,4(a1)
    800039be:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039c2:	00659783          	lh	a5,6(a1)
    800039c6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039ca:	459c                	lw	a5,8(a1)
    800039cc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039ce:	03400613          	li	a2,52
    800039d2:	05b1                	addi	a1,a1,12
    800039d4:	05048513          	addi	a0,s1,80
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	3d4080e7          	jalr	980(ra) # 80000dac <memmove>
    brelse(bp);
    800039e0:	854a                	mv	a0,s2
    800039e2:	00000097          	auipc	ra,0x0
    800039e6:	8c4080e7          	jalr	-1852(ra) # 800032a6 <brelse>
    ip->valid = 1;
    800039ea:	4785                	li	a5,1
    800039ec:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039ee:	04449783          	lh	a5,68(s1)
    800039f2:	c399                	beqz	a5,800039f8 <ilock+0xb6>
    800039f4:	6902                	ld	s2,0(sp)
    800039f6:	b7bd                	j	80003964 <ilock+0x22>
      panic("ilock: no type");
    800039f8:	00005517          	auipc	a0,0x5
    800039fc:	ae050513          	addi	a0,a0,-1312 # 800084d8 <etext+0x4d8>
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	b56080e7          	jalr	-1194(ra) # 80000556 <panic>

0000000080003a08 <iunlock>:
{
    80003a08:	1101                	addi	sp,sp,-32
    80003a0a:	ec06                	sd	ra,24(sp)
    80003a0c:	e822                	sd	s0,16(sp)
    80003a0e:	e426                	sd	s1,8(sp)
    80003a10:	e04a                	sd	s2,0(sp)
    80003a12:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a14:	c905                	beqz	a0,80003a44 <iunlock+0x3c>
    80003a16:	84aa                	mv	s1,a0
    80003a18:	01050913          	addi	s2,a0,16
    80003a1c:	854a                	mv	a0,s2
    80003a1e:	00001097          	auipc	ra,0x1
    80003a22:	cc4080e7          	jalr	-828(ra) # 800046e2 <holdingsleep>
    80003a26:	cd19                	beqz	a0,80003a44 <iunlock+0x3c>
    80003a28:	449c                	lw	a5,8(s1)
    80003a2a:	00f05d63          	blez	a5,80003a44 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a2e:	854a                	mv	a0,s2
    80003a30:	00001097          	auipc	ra,0x1
    80003a34:	c6e080e7          	jalr	-914(ra) # 8000469e <releasesleep>
}
    80003a38:	60e2                	ld	ra,24(sp)
    80003a3a:	6442                	ld	s0,16(sp)
    80003a3c:	64a2                	ld	s1,8(sp)
    80003a3e:	6902                	ld	s2,0(sp)
    80003a40:	6105                	addi	sp,sp,32
    80003a42:	8082                	ret
    panic("iunlock");
    80003a44:	00005517          	auipc	a0,0x5
    80003a48:	aa450513          	addi	a0,a0,-1372 # 800084e8 <etext+0x4e8>
    80003a4c:	ffffd097          	auipc	ra,0xffffd
    80003a50:	b0a080e7          	jalr	-1270(ra) # 80000556 <panic>

0000000080003a54 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a54:	7179                	addi	sp,sp,-48
    80003a56:	f406                	sd	ra,40(sp)
    80003a58:	f022                	sd	s0,32(sp)
    80003a5a:	ec26                	sd	s1,24(sp)
    80003a5c:	e84a                	sd	s2,16(sp)
    80003a5e:	e44e                	sd	s3,8(sp)
    80003a60:	1800                	addi	s0,sp,48
    80003a62:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a64:	05050493          	addi	s1,a0,80
    80003a68:	08050913          	addi	s2,a0,128
    80003a6c:	a021                	j	80003a74 <itrunc+0x20>
    80003a6e:	0491                	addi	s1,s1,4
    80003a70:	01248d63          	beq	s1,s2,80003a8a <itrunc+0x36>
    if(ip->addrs[i]){
    80003a74:	408c                	lw	a1,0(s1)
    80003a76:	dde5                	beqz	a1,80003a6e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003a78:	0009a503          	lw	a0,0(s3)
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	93a080e7          	jalr	-1734(ra) # 800033b6 <bfree>
      ip->addrs[i] = 0;
    80003a84:	0004a023          	sw	zero,0(s1)
    80003a88:	b7dd                	j	80003a6e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a8a:	0809a583          	lw	a1,128(s3)
    80003a8e:	ed99                	bnez	a1,80003aac <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a90:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a94:	854e                	mv	a0,s3
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	de0080e7          	jalr	-544(ra) # 80003876 <iupdate>
}
    80003a9e:	70a2                	ld	ra,40(sp)
    80003aa0:	7402                	ld	s0,32(sp)
    80003aa2:	64e2                	ld	s1,24(sp)
    80003aa4:	6942                	ld	s2,16(sp)
    80003aa6:	69a2                	ld	s3,8(sp)
    80003aa8:	6145                	addi	sp,sp,48
    80003aaa:	8082                	ret
    80003aac:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003aae:	0009a503          	lw	a0,0(s3)
    80003ab2:	fffff097          	auipc	ra,0xfffff
    80003ab6:	6c4080e7          	jalr	1732(ra) # 80003176 <bread>
    80003aba:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003abc:	05850493          	addi	s1,a0,88
    80003ac0:	45850913          	addi	s2,a0,1112
    80003ac4:	a021                	j	80003acc <itrunc+0x78>
    80003ac6:	0491                	addi	s1,s1,4
    80003ac8:	01248b63          	beq	s1,s2,80003ade <itrunc+0x8a>
      if(a[j])
    80003acc:	408c                	lw	a1,0(s1)
    80003ace:	dde5                	beqz	a1,80003ac6 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003ad0:	0009a503          	lw	a0,0(s3)
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	8e2080e7          	jalr	-1822(ra) # 800033b6 <bfree>
    80003adc:	b7ed                	j	80003ac6 <itrunc+0x72>
    brelse(bp);
    80003ade:	8552                	mv	a0,s4
    80003ae0:	fffff097          	auipc	ra,0xfffff
    80003ae4:	7c6080e7          	jalr	1990(ra) # 800032a6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ae8:	0809a583          	lw	a1,128(s3)
    80003aec:	0009a503          	lw	a0,0(s3)
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	8c6080e7          	jalr	-1850(ra) # 800033b6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003af8:	0809a023          	sw	zero,128(s3)
    80003afc:	6a02                	ld	s4,0(sp)
    80003afe:	bf49                	j	80003a90 <itrunc+0x3c>

0000000080003b00 <iput>:
{
    80003b00:	1101                	addi	sp,sp,-32
    80003b02:	ec06                	sd	ra,24(sp)
    80003b04:	e822                	sd	s0,16(sp)
    80003b06:	e426                	sd	s1,8(sp)
    80003b08:	1000                	addi	s0,sp,32
    80003b0a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b0c:	0001f517          	auipc	a0,0x1f
    80003b10:	0bc50513          	addi	a0,a0,188 # 80022bc8 <itable>
    80003b14:	ffffd097          	auipc	ra,0xffffd
    80003b18:	140080e7          	jalr	320(ra) # 80000c54 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b1c:	4498                	lw	a4,8(s1)
    80003b1e:	4785                	li	a5,1
    80003b20:	02f70263          	beq	a4,a5,80003b44 <iput+0x44>
  ip->ref--;
    80003b24:	449c                	lw	a5,8(s1)
    80003b26:	37fd                	addiw	a5,a5,-1
    80003b28:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b2a:	0001f517          	auipc	a0,0x1f
    80003b2e:	09e50513          	addi	a0,a0,158 # 80022bc8 <itable>
    80003b32:	ffffd097          	auipc	ra,0xffffd
    80003b36:	1d2080e7          	jalr	466(ra) # 80000d04 <release>
}
    80003b3a:	60e2                	ld	ra,24(sp)
    80003b3c:	6442                	ld	s0,16(sp)
    80003b3e:	64a2                	ld	s1,8(sp)
    80003b40:	6105                	addi	sp,sp,32
    80003b42:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b44:	40bc                	lw	a5,64(s1)
    80003b46:	dff9                	beqz	a5,80003b24 <iput+0x24>
    80003b48:	04a49783          	lh	a5,74(s1)
    80003b4c:	ffe1                	bnez	a5,80003b24 <iput+0x24>
    80003b4e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003b50:	01048793          	addi	a5,s1,16
    80003b54:	893e                	mv	s2,a5
    80003b56:	853e                	mv	a0,a5
    80003b58:	00001097          	auipc	ra,0x1
    80003b5c:	af0080e7          	jalr	-1296(ra) # 80004648 <acquiresleep>
    release(&itable.lock);
    80003b60:	0001f517          	auipc	a0,0x1f
    80003b64:	06850513          	addi	a0,a0,104 # 80022bc8 <itable>
    80003b68:	ffffd097          	auipc	ra,0xffffd
    80003b6c:	19c080e7          	jalr	412(ra) # 80000d04 <release>
    itrunc(ip);
    80003b70:	8526                	mv	a0,s1
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	ee2080e7          	jalr	-286(ra) # 80003a54 <itrunc>
    ip->type = 0;
    80003b7a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b7e:	8526                	mv	a0,s1
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	cf6080e7          	jalr	-778(ra) # 80003876 <iupdate>
    ip->valid = 0;
    80003b88:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b8c:	854a                	mv	a0,s2
    80003b8e:	00001097          	auipc	ra,0x1
    80003b92:	b10080e7          	jalr	-1264(ra) # 8000469e <releasesleep>
    acquire(&itable.lock);
    80003b96:	0001f517          	auipc	a0,0x1f
    80003b9a:	03250513          	addi	a0,a0,50 # 80022bc8 <itable>
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	0b6080e7          	jalr	182(ra) # 80000c54 <acquire>
    80003ba6:	6902                	ld	s2,0(sp)
    80003ba8:	bfb5                	j	80003b24 <iput+0x24>

0000000080003baa <iunlockput>:
{
    80003baa:	1101                	addi	sp,sp,-32
    80003bac:	ec06                	sd	ra,24(sp)
    80003bae:	e822                	sd	s0,16(sp)
    80003bb0:	e426                	sd	s1,8(sp)
    80003bb2:	1000                	addi	s0,sp,32
    80003bb4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bb6:	00000097          	auipc	ra,0x0
    80003bba:	e52080e7          	jalr	-430(ra) # 80003a08 <iunlock>
  iput(ip);
    80003bbe:	8526                	mv	a0,s1
    80003bc0:	00000097          	auipc	ra,0x0
    80003bc4:	f40080e7          	jalr	-192(ra) # 80003b00 <iput>
}
    80003bc8:	60e2                	ld	ra,24(sp)
    80003bca:	6442                	ld	s0,16(sp)
    80003bcc:	64a2                	ld	s1,8(sp)
    80003bce:	6105                	addi	sp,sp,32
    80003bd0:	8082                	ret

0000000080003bd2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bd2:	1141                	addi	sp,sp,-16
    80003bd4:	e406                	sd	ra,8(sp)
    80003bd6:	e022                	sd	s0,0(sp)
    80003bd8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bda:	411c                	lw	a5,0(a0)
    80003bdc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bde:	415c                	lw	a5,4(a0)
    80003be0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003be2:	04451783          	lh	a5,68(a0)
    80003be6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bea:	04a51783          	lh	a5,74(a0)
    80003bee:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bf2:	04c56783          	lwu	a5,76(a0)
    80003bf6:	e99c                	sd	a5,16(a1)
}
    80003bf8:	60a2                	ld	ra,8(sp)
    80003bfa:	6402                	ld	s0,0(sp)
    80003bfc:	0141                	addi	sp,sp,16
    80003bfe:	8082                	ret

0000000080003c00 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c00:	457c                	lw	a5,76(a0)
    80003c02:	0ed7ea63          	bltu	a5,a3,80003cf6 <readi+0xf6>
{
    80003c06:	7159                	addi	sp,sp,-112
    80003c08:	f486                	sd	ra,104(sp)
    80003c0a:	f0a2                	sd	s0,96(sp)
    80003c0c:	eca6                	sd	s1,88(sp)
    80003c0e:	fc56                	sd	s5,56(sp)
    80003c10:	f85a                	sd	s6,48(sp)
    80003c12:	f45e                	sd	s7,40(sp)
    80003c14:	ec66                	sd	s9,24(sp)
    80003c16:	1880                	addi	s0,sp,112
    80003c18:	8baa                	mv	s7,a0
    80003c1a:	8cae                	mv	s9,a1
    80003c1c:	8ab2                	mv	s5,a2
    80003c1e:	84b6                	mv	s1,a3
    80003c20:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c22:	9f35                	addw	a4,a4,a3
    return 0;
    80003c24:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c26:	0ad76763          	bltu	a4,a3,80003cd4 <readi+0xd4>
    80003c2a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003c2c:	00e7f463          	bgeu	a5,a4,80003c34 <readi+0x34>
    n = ip->size - off;
    80003c30:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c34:	0a0b0f63          	beqz	s6,80003cf2 <readi+0xf2>
    80003c38:	e8ca                	sd	s2,80(sp)
    80003c3a:	e0d2                	sd	s4,64(sp)
    80003c3c:	f062                	sd	s8,32(sp)
    80003c3e:	e86a                	sd	s10,16(sp)
    80003c40:	e46e                	sd	s11,8(sp)
    80003c42:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c44:	40000d93          	li	s11,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c48:	5d7d                	li	s10,-1
    80003c4a:	a82d                	j	80003c84 <readi+0x84>
    80003c4c:	020a1c13          	slli	s8,s4,0x20
    80003c50:	020c5c13          	srli	s8,s8,0x20
    80003c54:	05890613          	addi	a2,s2,88
    80003c58:	86e2                	mv	a3,s8
    80003c5a:	963e                	add	a2,a2,a5
    80003c5c:	85d6                	mv	a1,s5
    80003c5e:	8566                	mv	a0,s9
    80003c60:	fffff097          	auipc	ra,0xfffff
    80003c64:	a8a080e7          	jalr	-1398(ra) # 800026ea <either_copyout>
    80003c68:	05a50963          	beq	a0,s10,80003cba <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c6c:	854a                	mv	a0,s2
    80003c6e:	fffff097          	auipc	ra,0xfffff
    80003c72:	638080e7          	jalr	1592(ra) # 800032a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c76:	013a09bb          	addw	s3,s4,s3
    80003c7a:	009a04bb          	addw	s1,s4,s1
    80003c7e:	9ae2                	add	s5,s5,s8
    80003c80:	0769f363          	bgeu	s3,s6,80003ce6 <readi+0xe6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c84:	000ba903          	lw	s2,0(s7)
    80003c88:	00a4d59b          	srliw	a1,s1,0xa
    80003c8c:	855e                	mv	a0,s7
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	8ba080e7          	jalr	-1862(ra) # 80003548 <bmap>
    80003c96:	85aa                	mv	a1,a0
    80003c98:	854a                	mv	a0,s2
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	4dc080e7          	jalr	1244(ra) # 80003176 <bread>
    80003ca2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ca4:	3ff4f793          	andi	a5,s1,1023
    80003ca8:	40fd873b          	subw	a4,s11,a5
    80003cac:	413b06bb          	subw	a3,s6,s3
    80003cb0:	8a3a                	mv	s4,a4
    80003cb2:	f8e6fde3          	bgeu	a3,a4,80003c4c <readi+0x4c>
    80003cb6:	8a36                	mv	s4,a3
    80003cb8:	bf51                	j	80003c4c <readi+0x4c>
      brelse(bp);
    80003cba:	854a                	mv	a0,s2
    80003cbc:	fffff097          	auipc	ra,0xfffff
    80003cc0:	5ea080e7          	jalr	1514(ra) # 800032a6 <brelse>
      tot = -1;
    80003cc4:	59fd                	li	s3,-1
      break;
    80003cc6:	6946                	ld	s2,80(sp)
    80003cc8:	6a06                	ld	s4,64(sp)
    80003cca:	7c02                	ld	s8,32(sp)
    80003ccc:	6d42                	ld	s10,16(sp)
    80003cce:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003cd0:	854e                	mv	a0,s3
    80003cd2:	69a6                	ld	s3,72(sp)
}
    80003cd4:	70a6                	ld	ra,104(sp)
    80003cd6:	7406                	ld	s0,96(sp)
    80003cd8:	64e6                	ld	s1,88(sp)
    80003cda:	7ae2                	ld	s5,56(sp)
    80003cdc:	7b42                	ld	s6,48(sp)
    80003cde:	7ba2                	ld	s7,40(sp)
    80003ce0:	6ce2                	ld	s9,24(sp)
    80003ce2:	6165                	addi	sp,sp,112
    80003ce4:	8082                	ret
    80003ce6:	6946                	ld	s2,80(sp)
    80003ce8:	6a06                	ld	s4,64(sp)
    80003cea:	7c02                	ld	s8,32(sp)
    80003cec:	6d42                	ld	s10,16(sp)
    80003cee:	6da2                	ld	s11,8(sp)
    80003cf0:	b7c5                	j	80003cd0 <readi+0xd0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cf2:	89da                	mv	s3,s6
    80003cf4:	bff1                	j	80003cd0 <readi+0xd0>
    return 0;
    80003cf6:	4501                	li	a0,0
}
    80003cf8:	8082                	ret

0000000080003cfa <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cfa:	457c                	lw	a5,76(a0)
    80003cfc:	10d7e963          	bltu	a5,a3,80003e0e <writei+0x114>
{
    80003d00:	7159                	addi	sp,sp,-112
    80003d02:	f486                	sd	ra,104(sp)
    80003d04:	f0a2                	sd	s0,96(sp)
    80003d06:	e8ca                	sd	s2,80(sp)
    80003d08:	fc56                	sd	s5,56(sp)
    80003d0a:	f45e                	sd	s7,40(sp)
    80003d0c:	f062                	sd	s8,32(sp)
    80003d0e:	ec66                	sd	s9,24(sp)
    80003d10:	1880                	addi	s0,sp,112
    80003d12:	8baa                	mv	s7,a0
    80003d14:	8cae                	mv	s9,a1
    80003d16:	8ab2                	mv	s5,a2
    80003d18:	8936                	mv	s2,a3
    80003d1a:	8c3a                	mv	s8,a4
  if(off > ip->size || off + n < off)
    80003d1c:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d20:	00043737          	lui	a4,0x43
    80003d24:	0ef76763          	bltu	a4,a5,80003e12 <writei+0x118>
    80003d28:	0ed7e563          	bltu	a5,a3,80003e12 <writei+0x118>
    80003d2c:	e0d2                	sd	s4,64(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d2e:	0c0c0863          	beqz	s8,80003dfe <writei+0x104>
    80003d32:	eca6                	sd	s1,88(sp)
    80003d34:	e4ce                	sd	s3,72(sp)
    80003d36:	f85a                	sd	s6,48(sp)
    80003d38:	e86a                	sd	s10,16(sp)
    80003d3a:	e46e                	sd	s11,8(sp)
    80003d3c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d3e:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d42:	5d7d                	li	s10,-1
    80003d44:	a091                	j	80003d88 <writei+0x8e>
    80003d46:	02099b13          	slli	s6,s3,0x20
    80003d4a:	020b5b13          	srli	s6,s6,0x20
    80003d4e:	05848513          	addi	a0,s1,88
    80003d52:	86da                	mv	a3,s6
    80003d54:	8656                	mv	a2,s5
    80003d56:	85e6                	mv	a1,s9
    80003d58:	953e                	add	a0,a0,a5
    80003d5a:	fffff097          	auipc	ra,0xfffff
    80003d5e:	9e6080e7          	jalr	-1562(ra) # 80002740 <either_copyin>
    80003d62:	05a50e63          	beq	a0,s10,80003dbe <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d66:	8526                	mv	a0,s1
    80003d68:	00000097          	auipc	ra,0x0
    80003d6c:	7c0080e7          	jalr	1984(ra) # 80004528 <log_write>
    brelse(bp);
    80003d70:	8526                	mv	a0,s1
    80003d72:	fffff097          	auipc	ra,0xfffff
    80003d76:	534080e7          	jalr	1332(ra) # 800032a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d7a:	01498a3b          	addw	s4,s3,s4
    80003d7e:	0129893b          	addw	s2,s3,s2
    80003d82:	9ada                	add	s5,s5,s6
    80003d84:	058a7263          	bgeu	s4,s8,80003dc8 <writei+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d88:	000ba483          	lw	s1,0(s7)
    80003d8c:	00a9559b          	srliw	a1,s2,0xa
    80003d90:	855e                	mv	a0,s7
    80003d92:	fffff097          	auipc	ra,0xfffff
    80003d96:	7b6080e7          	jalr	1974(ra) # 80003548 <bmap>
    80003d9a:	85aa                	mv	a1,a0
    80003d9c:	8526                	mv	a0,s1
    80003d9e:	fffff097          	auipc	ra,0xfffff
    80003da2:	3d8080e7          	jalr	984(ra) # 80003176 <bread>
    80003da6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003da8:	3ff97793          	andi	a5,s2,1023
    80003dac:	40fd873b          	subw	a4,s11,a5
    80003db0:	414c06bb          	subw	a3,s8,s4
    80003db4:	89ba                	mv	s3,a4
    80003db6:	f8e6f8e3          	bgeu	a3,a4,80003d46 <writei+0x4c>
    80003dba:	89b6                	mv	s3,a3
    80003dbc:	b769                	j	80003d46 <writei+0x4c>
      brelse(bp);
    80003dbe:	8526                	mv	a0,s1
    80003dc0:	fffff097          	auipc	ra,0xfffff
    80003dc4:	4e6080e7          	jalr	1254(ra) # 800032a6 <brelse>
  }

  if(off > ip->size)
    80003dc8:	04cba783          	lw	a5,76(s7)
    80003dcc:	0327fb63          	bgeu	a5,s2,80003e02 <writei+0x108>
    ip->size = off;
    80003dd0:	052ba623          	sw	s2,76(s7)
    80003dd4:	64e6                	ld	s1,88(sp)
    80003dd6:	69a6                	ld	s3,72(sp)
    80003dd8:	7b42                	ld	s6,48(sp)
    80003dda:	6d42                	ld	s10,16(sp)
    80003ddc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003dde:	855e                	mv	a0,s7
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	a96080e7          	jalr	-1386(ra) # 80003876 <iupdate>

  return tot;
    80003de8:	8552                	mv	a0,s4
    80003dea:	6a06                	ld	s4,64(sp)
}
    80003dec:	70a6                	ld	ra,104(sp)
    80003dee:	7406                	ld	s0,96(sp)
    80003df0:	6946                	ld	s2,80(sp)
    80003df2:	7ae2                	ld	s5,56(sp)
    80003df4:	7ba2                	ld	s7,40(sp)
    80003df6:	7c02                	ld	s8,32(sp)
    80003df8:	6ce2                	ld	s9,24(sp)
    80003dfa:	6165                	addi	sp,sp,112
    80003dfc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dfe:	8a62                	mv	s4,s8
    80003e00:	bff9                	j	80003dde <writei+0xe4>
    80003e02:	64e6                	ld	s1,88(sp)
    80003e04:	69a6                	ld	s3,72(sp)
    80003e06:	7b42                	ld	s6,48(sp)
    80003e08:	6d42                	ld	s10,16(sp)
    80003e0a:	6da2                	ld	s11,8(sp)
    80003e0c:	bfc9                	j	80003dde <writei+0xe4>
    return -1;
    80003e0e:	557d                	li	a0,-1
}
    80003e10:	8082                	ret
    return -1;
    80003e12:	557d                	li	a0,-1
    80003e14:	bfe1                	j	80003dec <writei+0xf2>

0000000080003e16 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e16:	1141                	addi	sp,sp,-16
    80003e18:	e406                	sd	ra,8(sp)
    80003e1a:	e022                	sd	s0,0(sp)
    80003e1c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e1e:	4639                	li	a2,14
    80003e20:	ffffd097          	auipc	ra,0xffffd
    80003e24:	004080e7          	jalr	4(ra) # 80000e24 <strncmp>
}
    80003e28:	60a2                	ld	ra,8(sp)
    80003e2a:	6402                	ld	s0,0(sp)
    80003e2c:	0141                	addi	sp,sp,16
    80003e2e:	8082                	ret

0000000080003e30 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e30:	711d                	addi	sp,sp,-96
    80003e32:	ec86                	sd	ra,88(sp)
    80003e34:	e8a2                	sd	s0,80(sp)
    80003e36:	e4a6                	sd	s1,72(sp)
    80003e38:	e0ca                	sd	s2,64(sp)
    80003e3a:	fc4e                	sd	s3,56(sp)
    80003e3c:	f852                	sd	s4,48(sp)
    80003e3e:	f456                	sd	s5,40(sp)
    80003e40:	f05a                	sd	s6,32(sp)
    80003e42:	ec5e                	sd	s7,24(sp)
    80003e44:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e46:	04451703          	lh	a4,68(a0)
    80003e4a:	4785                	li	a5,1
    80003e4c:	00f71f63          	bne	a4,a5,80003e6a <dirlookup+0x3a>
    80003e50:	892a                	mv	s2,a0
    80003e52:	8aae                	mv	s5,a1
    80003e54:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e56:	457c                	lw	a5,76(a0)
    80003e58:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5a:	fa040a13          	addi	s4,s0,-96
    80003e5e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003e60:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e64:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e66:	e79d                	bnez	a5,80003e94 <dirlookup+0x64>
    80003e68:	a88d                	j	80003eda <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80003e6a:	00004517          	auipc	a0,0x4
    80003e6e:	68650513          	addi	a0,a0,1670 # 800084f0 <etext+0x4f0>
    80003e72:	ffffc097          	auipc	ra,0xffffc
    80003e76:	6e4080e7          	jalr	1764(ra) # 80000556 <panic>
      panic("dirlookup read");
    80003e7a:	00004517          	auipc	a0,0x4
    80003e7e:	68e50513          	addi	a0,a0,1678 # 80008508 <etext+0x508>
    80003e82:	ffffc097          	auipc	ra,0xffffc
    80003e86:	6d4080e7          	jalr	1748(ra) # 80000556 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e8a:	24c1                	addiw	s1,s1,16
    80003e8c:	04c92783          	lw	a5,76(s2)
    80003e90:	04f4f463          	bgeu	s1,a5,80003ed8 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e94:	874e                	mv	a4,s3
    80003e96:	86a6                	mv	a3,s1
    80003e98:	8652                	mv	a2,s4
    80003e9a:	4581                	li	a1,0
    80003e9c:	854a                	mv	a0,s2
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	d62080e7          	jalr	-670(ra) # 80003c00 <readi>
    80003ea6:	fd351ae3          	bne	a0,s3,80003e7a <dirlookup+0x4a>
    if(de.inum == 0)
    80003eaa:	fa045783          	lhu	a5,-96(s0)
    80003eae:	dff1                	beqz	a5,80003e8a <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    80003eb0:	85da                	mv	a1,s6
    80003eb2:	8556                	mv	a0,s5
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	f62080e7          	jalr	-158(ra) # 80003e16 <namecmp>
    80003ebc:	f579                	bnez	a0,80003e8a <dirlookup+0x5a>
      if(poff)
    80003ebe:	000b8463          	beqz	s7,80003ec6 <dirlookup+0x96>
        *poff = off;
    80003ec2:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003ec6:	fa045583          	lhu	a1,-96(s0)
    80003eca:	00092503          	lw	a0,0(s2)
    80003ece:	fffff097          	auipc	ra,0xfffff
    80003ed2:	748080e7          	jalr	1864(ra) # 80003616 <iget>
    80003ed6:	a011                	j	80003eda <dirlookup+0xaa>
  return 0;
    80003ed8:	4501                	li	a0,0
}
    80003eda:	60e6                	ld	ra,88(sp)
    80003edc:	6446                	ld	s0,80(sp)
    80003ede:	64a6                	ld	s1,72(sp)
    80003ee0:	6906                	ld	s2,64(sp)
    80003ee2:	79e2                	ld	s3,56(sp)
    80003ee4:	7a42                	ld	s4,48(sp)
    80003ee6:	7aa2                	ld	s5,40(sp)
    80003ee8:	7b02                	ld	s6,32(sp)
    80003eea:	6be2                	ld	s7,24(sp)
    80003eec:	6125                	addi	sp,sp,96
    80003eee:	8082                	ret

0000000080003ef0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ef0:	711d                	addi	sp,sp,-96
    80003ef2:	ec86                	sd	ra,88(sp)
    80003ef4:	e8a2                	sd	s0,80(sp)
    80003ef6:	e4a6                	sd	s1,72(sp)
    80003ef8:	e0ca                	sd	s2,64(sp)
    80003efa:	fc4e                	sd	s3,56(sp)
    80003efc:	f852                	sd	s4,48(sp)
    80003efe:	f456                	sd	s5,40(sp)
    80003f00:	f05a                	sd	s6,32(sp)
    80003f02:	ec5e                	sd	s7,24(sp)
    80003f04:	e862                	sd	s8,16(sp)
    80003f06:	e466                	sd	s9,8(sp)
    80003f08:	e06a                	sd	s10,0(sp)
    80003f0a:	1080                	addi	s0,sp,96
    80003f0c:	84aa                	mv	s1,a0
    80003f0e:	8b2e                	mv	s6,a1
    80003f10:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f12:	00054703          	lbu	a4,0(a0)
    80003f16:	02f00793          	li	a5,47
    80003f1a:	02f70363          	beq	a4,a5,80003f40 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f1e:	ffffe097          	auipc	ra,0xffffe
    80003f22:	b5c080e7          	jalr	-1188(ra) # 80001a7a <myproc>
    80003f26:	15053503          	ld	a0,336(a0)
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	9da080e7          	jalr	-1574(ra) # 80003904 <idup>
    80003f32:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003f34:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003f38:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003f3a:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f3c:	4b85                	li	s7,1
    80003f3e:	a87d                	j	80003ffc <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003f40:	4585                	li	a1,1
    80003f42:	852e                	mv	a0,a1
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	6d2080e7          	jalr	1746(ra) # 80003616 <iget>
    80003f4c:	8a2a                	mv	s4,a0
    80003f4e:	b7dd                	j	80003f34 <namex+0x44>
      iunlockput(ip);
    80003f50:	8552                	mv	a0,s4
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	c58080e7          	jalr	-936(ra) # 80003baa <iunlockput>
      return 0;
    80003f5a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f5c:	8552                	mv	a0,s4
    80003f5e:	60e6                	ld	ra,88(sp)
    80003f60:	6446                	ld	s0,80(sp)
    80003f62:	64a6                	ld	s1,72(sp)
    80003f64:	6906                	ld	s2,64(sp)
    80003f66:	79e2                	ld	s3,56(sp)
    80003f68:	7a42                	ld	s4,48(sp)
    80003f6a:	7aa2                	ld	s5,40(sp)
    80003f6c:	7b02                	ld	s6,32(sp)
    80003f6e:	6be2                	ld	s7,24(sp)
    80003f70:	6c42                	ld	s8,16(sp)
    80003f72:	6ca2                	ld	s9,8(sp)
    80003f74:	6d02                	ld	s10,0(sp)
    80003f76:	6125                	addi	sp,sp,96
    80003f78:	8082                	ret
      iunlock(ip);
    80003f7a:	8552                	mv	a0,s4
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	a8c080e7          	jalr	-1396(ra) # 80003a08 <iunlock>
      return ip;
    80003f84:	bfe1                	j	80003f5c <namex+0x6c>
      iunlockput(ip);
    80003f86:	8552                	mv	a0,s4
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	c22080e7          	jalr	-990(ra) # 80003baa <iunlockput>
      return 0;
    80003f90:	8a4a                	mv	s4,s2
    80003f92:	b7e9                	j	80003f5c <namex+0x6c>
  len = path - s;
    80003f94:	40990633          	sub	a2,s2,s1
    80003f98:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f9c:	09ac5c63          	bge	s8,s10,80004034 <namex+0x144>
    memmove(name, s, DIRSIZ);
    80003fa0:	8666                	mv	a2,s9
    80003fa2:	85a6                	mv	a1,s1
    80003fa4:	8556                	mv	a0,s5
    80003fa6:	ffffd097          	auipc	ra,0xffffd
    80003faa:	e06080e7          	jalr	-506(ra) # 80000dac <memmove>
    80003fae:	84ca                	mv	s1,s2
  while(*path == '/')
    80003fb0:	0004c783          	lbu	a5,0(s1)
    80003fb4:	01379763          	bne	a5,s3,80003fc2 <namex+0xd2>
    path++;
    80003fb8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fba:	0004c783          	lbu	a5,0(s1)
    80003fbe:	ff378de3          	beq	a5,s3,80003fb8 <namex+0xc8>
    ilock(ip);
    80003fc2:	8552                	mv	a0,s4
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	97e080e7          	jalr	-1666(ra) # 80003942 <ilock>
    if(ip->type != T_DIR){
    80003fcc:	044a1783          	lh	a5,68(s4)
    80003fd0:	f97790e3          	bne	a5,s7,80003f50 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003fd4:	000b0563          	beqz	s6,80003fde <namex+0xee>
    80003fd8:	0004c783          	lbu	a5,0(s1)
    80003fdc:	dfd9                	beqz	a5,80003f7a <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fde:	4601                	li	a2,0
    80003fe0:	85d6                	mv	a1,s5
    80003fe2:	8552                	mv	a0,s4
    80003fe4:	00000097          	auipc	ra,0x0
    80003fe8:	e4c080e7          	jalr	-436(ra) # 80003e30 <dirlookup>
    80003fec:	892a                	mv	s2,a0
    80003fee:	dd41                	beqz	a0,80003f86 <namex+0x96>
    iunlockput(ip);
    80003ff0:	8552                	mv	a0,s4
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	bb8080e7          	jalr	-1096(ra) # 80003baa <iunlockput>
    ip = next;
    80003ffa:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003ffc:	0004c783          	lbu	a5,0(s1)
    80004000:	01379763          	bne	a5,s3,8000400e <namex+0x11e>
    path++;
    80004004:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004006:	0004c783          	lbu	a5,0(s1)
    8000400a:	ff378de3          	beq	a5,s3,80004004 <namex+0x114>
  if(*path == 0)
    8000400e:	cf9d                	beqz	a5,8000404c <namex+0x15c>
  while(*path != '/' && *path != 0)
    80004010:	0004c783          	lbu	a5,0(s1)
    80004014:	fd178713          	addi	a4,a5,-47
    80004018:	cb19                	beqz	a4,8000402e <namex+0x13e>
    8000401a:	cb91                	beqz	a5,8000402e <namex+0x13e>
    8000401c:	8926                	mv	s2,s1
    path++;
    8000401e:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80004020:	00094783          	lbu	a5,0(s2)
    80004024:	fd178713          	addi	a4,a5,-47
    80004028:	d735                	beqz	a4,80003f94 <namex+0xa4>
    8000402a:	fbf5                	bnez	a5,8000401e <namex+0x12e>
    8000402c:	b7a5                	j	80003f94 <namex+0xa4>
    8000402e:	8926                	mv	s2,s1
  len = path - s;
    80004030:	4d01                	li	s10,0
    80004032:	4601                	li	a2,0
    memmove(name, s, len);
    80004034:	2601                	sext.w	a2,a2
    80004036:	85a6                	mv	a1,s1
    80004038:	8556                	mv	a0,s5
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	d72080e7          	jalr	-654(ra) # 80000dac <memmove>
    name[len] = 0;
    80004042:	9d56                	add	s10,s10,s5
    80004044:	000d0023          	sb	zero,0(s10)
    80004048:	84ca                	mv	s1,s2
    8000404a:	b79d                	j	80003fb0 <namex+0xc0>
  if(nameiparent){
    8000404c:	f00b08e3          	beqz	s6,80003f5c <namex+0x6c>
    iput(ip);
    80004050:	8552                	mv	a0,s4
    80004052:	00000097          	auipc	ra,0x0
    80004056:	aae080e7          	jalr	-1362(ra) # 80003b00 <iput>
    return 0;
    8000405a:	4a01                	li	s4,0
    8000405c:	b701                	j	80003f5c <namex+0x6c>

000000008000405e <dirlink>:
{
    8000405e:	715d                	addi	sp,sp,-80
    80004060:	e486                	sd	ra,72(sp)
    80004062:	e0a2                	sd	s0,64(sp)
    80004064:	f84a                	sd	s2,48(sp)
    80004066:	ec56                	sd	s5,24(sp)
    80004068:	e85a                	sd	s6,16(sp)
    8000406a:	0880                	addi	s0,sp,80
    8000406c:	892a                	mv	s2,a0
    8000406e:	8aae                	mv	s5,a1
    80004070:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004072:	4601                	li	a2,0
    80004074:	00000097          	auipc	ra,0x0
    80004078:	dbc080e7          	jalr	-580(ra) # 80003e30 <dirlookup>
    8000407c:	e129                	bnez	a0,800040be <dirlink+0x60>
    8000407e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004080:	04c92483          	lw	s1,76(s2)
    80004084:	cca9                	beqz	s1,800040de <dirlink+0x80>
    80004086:	f44e                	sd	s3,40(sp)
    80004088:	f052                	sd	s4,32(sp)
    8000408a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000408c:	fb040a13          	addi	s4,s0,-80
    80004090:	49c1                	li	s3,16
    80004092:	874e                	mv	a4,s3
    80004094:	86a6                	mv	a3,s1
    80004096:	8652                	mv	a2,s4
    80004098:	4581                	li	a1,0
    8000409a:	854a                	mv	a0,s2
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	b64080e7          	jalr	-1180(ra) # 80003c00 <readi>
    800040a4:	03351363          	bne	a0,s3,800040ca <dirlink+0x6c>
    if(de.inum == 0)
    800040a8:	fb045783          	lhu	a5,-80(s0)
    800040ac:	c79d                	beqz	a5,800040da <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ae:	24c1                	addiw	s1,s1,16
    800040b0:	04c92783          	lw	a5,76(s2)
    800040b4:	fcf4efe3          	bltu	s1,a5,80004092 <dirlink+0x34>
    800040b8:	79a2                	ld	s3,40(sp)
    800040ba:	7a02                	ld	s4,32(sp)
    800040bc:	a00d                	j	800040de <dirlink+0x80>
    iput(ip);
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	a42080e7          	jalr	-1470(ra) # 80003b00 <iput>
    return -1;
    800040c6:	557d                	li	a0,-1
    800040c8:	a0a9                	j	80004112 <dirlink+0xb4>
      panic("dirlink read");
    800040ca:	00004517          	auipc	a0,0x4
    800040ce:	44e50513          	addi	a0,a0,1102 # 80008518 <etext+0x518>
    800040d2:	ffffc097          	auipc	ra,0xffffc
    800040d6:	484080e7          	jalr	1156(ra) # 80000556 <panic>
    800040da:	79a2                	ld	s3,40(sp)
    800040dc:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800040de:	4639                	li	a2,14
    800040e0:	85d6                	mv	a1,s5
    800040e2:	fb240513          	addi	a0,s0,-78
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	d78080e7          	jalr	-648(ra) # 80000e5e <strncpy>
  de.inum = inum;
    800040ee:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040f2:	4741                	li	a4,16
    800040f4:	86a6                	mv	a3,s1
    800040f6:	fb040613          	addi	a2,s0,-80
    800040fa:	4581                	li	a1,0
    800040fc:	854a                	mv	a0,s2
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	bfc080e7          	jalr	-1028(ra) # 80003cfa <writei>
    80004106:	872a                	mv	a4,a0
    80004108:	47c1                	li	a5,16
  return 0;
    8000410a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000410c:	00f71a63          	bne	a4,a5,80004120 <dirlink+0xc2>
    80004110:	74e2                	ld	s1,56(sp)
}
    80004112:	60a6                	ld	ra,72(sp)
    80004114:	6406                	ld	s0,64(sp)
    80004116:	7942                	ld	s2,48(sp)
    80004118:	6ae2                	ld	s5,24(sp)
    8000411a:	6b42                	ld	s6,16(sp)
    8000411c:	6161                	addi	sp,sp,80
    8000411e:	8082                	ret
    80004120:	f44e                	sd	s3,40(sp)
    80004122:	f052                	sd	s4,32(sp)
    panic("dirlink");
    80004124:	00004517          	auipc	a0,0x4
    80004128:	50450513          	addi	a0,a0,1284 # 80008628 <etext+0x628>
    8000412c:	ffffc097          	auipc	ra,0xffffc
    80004130:	42a080e7          	jalr	1066(ra) # 80000556 <panic>

0000000080004134 <namei>:

struct inode*
namei(char *path)
{
    80004134:	1101                	addi	sp,sp,-32
    80004136:	ec06                	sd	ra,24(sp)
    80004138:	e822                	sd	s0,16(sp)
    8000413a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000413c:	fe040613          	addi	a2,s0,-32
    80004140:	4581                	li	a1,0
    80004142:	00000097          	auipc	ra,0x0
    80004146:	dae080e7          	jalr	-594(ra) # 80003ef0 <namex>
}
    8000414a:	60e2                	ld	ra,24(sp)
    8000414c:	6442                	ld	s0,16(sp)
    8000414e:	6105                	addi	sp,sp,32
    80004150:	8082                	ret

0000000080004152 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004152:	1141                	addi	sp,sp,-16
    80004154:	e406                	sd	ra,8(sp)
    80004156:	e022                	sd	s0,0(sp)
    80004158:	0800                	addi	s0,sp,16
    8000415a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000415c:	4585                	li	a1,1
    8000415e:	00000097          	auipc	ra,0x0
    80004162:	d92080e7          	jalr	-622(ra) # 80003ef0 <namex>
}
    80004166:	60a2                	ld	ra,8(sp)
    80004168:	6402                	ld	s0,0(sp)
    8000416a:	0141                	addi	sp,sp,16
    8000416c:	8082                	ret

000000008000416e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000416e:	1101                	addi	sp,sp,-32
    80004170:	ec06                	sd	ra,24(sp)
    80004172:	e822                	sd	s0,16(sp)
    80004174:	e426                	sd	s1,8(sp)
    80004176:	e04a                	sd	s2,0(sp)
    80004178:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000417a:	00020917          	auipc	s2,0x20
    8000417e:	4f690913          	addi	s2,s2,1270 # 80024670 <log>
    80004182:	01892583          	lw	a1,24(s2)
    80004186:	02892503          	lw	a0,40(s2)
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	fec080e7          	jalr	-20(ra) # 80003176 <bread>
    80004192:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004194:	02c92603          	lw	a2,44(s2)
    80004198:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000419a:	00c05f63          	blez	a2,800041b8 <write_head+0x4a>
    8000419e:	00020717          	auipc	a4,0x20
    800041a2:	50270713          	addi	a4,a4,1282 # 800246a0 <log+0x30>
    800041a6:	87aa                	mv	a5,a0
    800041a8:	060a                	slli	a2,a2,0x2
    800041aa:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800041ac:	4314                	lw	a3,0(a4)
    800041ae:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800041b0:	0711                	addi	a4,a4,4
    800041b2:	0791                	addi	a5,a5,4
    800041b4:	fec79ce3          	bne	a5,a2,800041ac <write_head+0x3e>
  }
  bwrite(buf);
    800041b8:	8526                	mv	a0,s1
    800041ba:	fffff097          	auipc	ra,0xfffff
    800041be:	0ae080e7          	jalr	174(ra) # 80003268 <bwrite>
  brelse(buf);
    800041c2:	8526                	mv	a0,s1
    800041c4:	fffff097          	auipc	ra,0xfffff
    800041c8:	0e2080e7          	jalr	226(ra) # 800032a6 <brelse>
}
    800041cc:	60e2                	ld	ra,24(sp)
    800041ce:	6442                	ld	s0,16(sp)
    800041d0:	64a2                	ld	s1,8(sp)
    800041d2:	6902                	ld	s2,0(sp)
    800041d4:	6105                	addi	sp,sp,32
    800041d6:	8082                	ret

00000000800041d8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d8:	00020797          	auipc	a5,0x20
    800041dc:	4c47a783          	lw	a5,1220(a5) # 8002469c <log+0x2c>
    800041e0:	0cf05063          	blez	a5,800042a0 <install_trans+0xc8>
{
    800041e4:	715d                	addi	sp,sp,-80
    800041e6:	e486                	sd	ra,72(sp)
    800041e8:	e0a2                	sd	s0,64(sp)
    800041ea:	fc26                	sd	s1,56(sp)
    800041ec:	f84a                	sd	s2,48(sp)
    800041ee:	f44e                	sd	s3,40(sp)
    800041f0:	f052                	sd	s4,32(sp)
    800041f2:	ec56                	sd	s5,24(sp)
    800041f4:	e85a                	sd	s6,16(sp)
    800041f6:	e45e                	sd	s7,8(sp)
    800041f8:	0880                	addi	s0,sp,80
    800041fa:	8b2a                	mv	s6,a0
    800041fc:	00020a97          	auipc	s5,0x20
    80004200:	4a4a8a93          	addi	s5,s5,1188 # 800246a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004204:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004206:	00020997          	auipc	s3,0x20
    8000420a:	46a98993          	addi	s3,s3,1130 # 80024670 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000420e:	40000b93          	li	s7,1024
    80004212:	a00d                	j	80004234 <install_trans+0x5c>
    brelse(lbuf);
    80004214:	854a                	mv	a0,s2
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	090080e7          	jalr	144(ra) # 800032a6 <brelse>
    brelse(dbuf);
    8000421e:	8526                	mv	a0,s1
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	086080e7          	jalr	134(ra) # 800032a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004228:	2a05                	addiw	s4,s4,1
    8000422a:	0a91                	addi	s5,s5,4
    8000422c:	02c9a783          	lw	a5,44(s3)
    80004230:	04fa5d63          	bge	s4,a5,8000428a <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004234:	0189a583          	lw	a1,24(s3)
    80004238:	014585bb          	addw	a1,a1,s4
    8000423c:	2585                	addiw	a1,a1,1
    8000423e:	0289a503          	lw	a0,40(s3)
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	f34080e7          	jalr	-204(ra) # 80003176 <bread>
    8000424a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000424c:	000aa583          	lw	a1,0(s5)
    80004250:	0289a503          	lw	a0,40(s3)
    80004254:	fffff097          	auipc	ra,0xfffff
    80004258:	f22080e7          	jalr	-222(ra) # 80003176 <bread>
    8000425c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000425e:	865e                	mv	a2,s7
    80004260:	05890593          	addi	a1,s2,88
    80004264:	05850513          	addi	a0,a0,88
    80004268:	ffffd097          	auipc	ra,0xffffd
    8000426c:	b44080e7          	jalr	-1212(ra) # 80000dac <memmove>
    bwrite(dbuf);  // write dst to disk
    80004270:	8526                	mv	a0,s1
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	ff6080e7          	jalr	-10(ra) # 80003268 <bwrite>
    if(recovering == 0)
    8000427a:	f80b1de3          	bnez	s6,80004214 <install_trans+0x3c>
      bunpin(dbuf);
    8000427e:	8526                	mv	a0,s1
    80004280:	fffff097          	auipc	ra,0xfffff
    80004284:	0fa080e7          	jalr	250(ra) # 8000337a <bunpin>
    80004288:	b771                	j	80004214 <install_trans+0x3c>
}
    8000428a:	60a6                	ld	ra,72(sp)
    8000428c:	6406                	ld	s0,64(sp)
    8000428e:	74e2                	ld	s1,56(sp)
    80004290:	7942                	ld	s2,48(sp)
    80004292:	79a2                	ld	s3,40(sp)
    80004294:	7a02                	ld	s4,32(sp)
    80004296:	6ae2                	ld	s5,24(sp)
    80004298:	6b42                	ld	s6,16(sp)
    8000429a:	6ba2                	ld	s7,8(sp)
    8000429c:	6161                	addi	sp,sp,80
    8000429e:	8082                	ret
    800042a0:	8082                	ret

00000000800042a2 <initlog>:
{
    800042a2:	7179                	addi	sp,sp,-48
    800042a4:	f406                	sd	ra,40(sp)
    800042a6:	f022                	sd	s0,32(sp)
    800042a8:	ec26                	sd	s1,24(sp)
    800042aa:	e84a                	sd	s2,16(sp)
    800042ac:	e44e                	sd	s3,8(sp)
    800042ae:	1800                	addi	s0,sp,48
    800042b0:	892a                	mv	s2,a0
    800042b2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042b4:	00020497          	auipc	s1,0x20
    800042b8:	3bc48493          	addi	s1,s1,956 # 80024670 <log>
    800042bc:	00004597          	auipc	a1,0x4
    800042c0:	26c58593          	addi	a1,a1,620 # 80008528 <etext+0x528>
    800042c4:	8526                	mv	a0,s1
    800042c6:	ffffd097          	auipc	ra,0xffffd
    800042ca:	8f4080e7          	jalr	-1804(ra) # 80000bba <initlock>
  log.start = sb->logstart;
    800042ce:	0149a583          	lw	a1,20(s3)
    800042d2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042d4:	0109a783          	lw	a5,16(s3)
    800042d8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042da:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042de:	854a                	mv	a0,s2
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	e96080e7          	jalr	-362(ra) # 80003176 <bread>
  log.lh.n = lh->n;
    800042e8:	4d30                	lw	a2,88(a0)
    800042ea:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042ec:	00c05f63          	blez	a2,8000430a <initlog+0x68>
    800042f0:	87aa                	mv	a5,a0
    800042f2:	00020717          	auipc	a4,0x20
    800042f6:	3ae70713          	addi	a4,a4,942 # 800246a0 <log+0x30>
    800042fa:	060a                	slli	a2,a2,0x2
    800042fc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800042fe:	4ff4                	lw	a3,92(a5)
    80004300:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004302:	0791                	addi	a5,a5,4
    80004304:	0711                	addi	a4,a4,4
    80004306:	fec79ce3          	bne	a5,a2,800042fe <initlog+0x5c>
  brelse(buf);
    8000430a:	fffff097          	auipc	ra,0xfffff
    8000430e:	f9c080e7          	jalr	-100(ra) # 800032a6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004312:	4505                	li	a0,1
    80004314:	00000097          	auipc	ra,0x0
    80004318:	ec4080e7          	jalr	-316(ra) # 800041d8 <install_trans>
  log.lh.n = 0;
    8000431c:	00020797          	auipc	a5,0x20
    80004320:	3807a023          	sw	zero,896(a5) # 8002469c <log+0x2c>
  write_head(); // clear the log
    80004324:	00000097          	auipc	ra,0x0
    80004328:	e4a080e7          	jalr	-438(ra) # 8000416e <write_head>
}
    8000432c:	70a2                	ld	ra,40(sp)
    8000432e:	7402                	ld	s0,32(sp)
    80004330:	64e2                	ld	s1,24(sp)
    80004332:	6942                	ld	s2,16(sp)
    80004334:	69a2                	ld	s3,8(sp)
    80004336:	6145                	addi	sp,sp,48
    80004338:	8082                	ret

000000008000433a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000433a:	1101                	addi	sp,sp,-32
    8000433c:	ec06                	sd	ra,24(sp)
    8000433e:	e822                	sd	s0,16(sp)
    80004340:	e426                	sd	s1,8(sp)
    80004342:	e04a                	sd	s2,0(sp)
    80004344:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004346:	00020517          	auipc	a0,0x20
    8000434a:	32a50513          	addi	a0,a0,810 # 80024670 <log>
    8000434e:	ffffd097          	auipc	ra,0xffffd
    80004352:	906080e7          	jalr	-1786(ra) # 80000c54 <acquire>
  while(1){
    if(log.committing){
    80004356:	00020497          	auipc	s1,0x20
    8000435a:	31a48493          	addi	s1,s1,794 # 80024670 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000435e:	4979                	li	s2,30
    80004360:	a039                	j	8000436e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004362:	85a6                	mv	a1,s1
    80004364:	8526                	mv	a0,s1
    80004366:	ffffe097          	auipc	ra,0xffffe
    8000436a:	e90080e7          	jalr	-368(ra) # 800021f6 <sleep>
    if(log.committing){
    8000436e:	50dc                	lw	a5,36(s1)
    80004370:	fbed                	bnez	a5,80004362 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004372:	5098                	lw	a4,32(s1)
    80004374:	2705                	addiw	a4,a4,1
    80004376:	0027179b          	slliw	a5,a4,0x2
    8000437a:	9fb9                	addw	a5,a5,a4
    8000437c:	0017979b          	slliw	a5,a5,0x1
    80004380:	54d4                	lw	a3,44(s1)
    80004382:	9fb5                	addw	a5,a5,a3
    80004384:	00f95963          	bge	s2,a5,80004396 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004388:	85a6                	mv	a1,s1
    8000438a:	8526                	mv	a0,s1
    8000438c:	ffffe097          	auipc	ra,0xffffe
    80004390:	e6a080e7          	jalr	-406(ra) # 800021f6 <sleep>
    80004394:	bfe9                	j	8000436e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004396:	00020797          	auipc	a5,0x20
    8000439a:	2ee7ad23          	sw	a4,762(a5) # 80024690 <log+0x20>
      release(&log.lock);
    8000439e:	00020517          	auipc	a0,0x20
    800043a2:	2d250513          	addi	a0,a0,722 # 80024670 <log>
    800043a6:	ffffd097          	auipc	ra,0xffffd
    800043aa:	95e080e7          	jalr	-1698(ra) # 80000d04 <release>
      break;
    }
  }
}
    800043ae:	60e2                	ld	ra,24(sp)
    800043b0:	6442                	ld	s0,16(sp)
    800043b2:	64a2                	ld	s1,8(sp)
    800043b4:	6902                	ld	s2,0(sp)
    800043b6:	6105                	addi	sp,sp,32
    800043b8:	8082                	ret

00000000800043ba <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043ba:	7139                	addi	sp,sp,-64
    800043bc:	fc06                	sd	ra,56(sp)
    800043be:	f822                	sd	s0,48(sp)
    800043c0:	f426                	sd	s1,40(sp)
    800043c2:	f04a                	sd	s2,32(sp)
    800043c4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043c6:	00020497          	auipc	s1,0x20
    800043ca:	2aa48493          	addi	s1,s1,682 # 80024670 <log>
    800043ce:	8526                	mv	a0,s1
    800043d0:	ffffd097          	auipc	ra,0xffffd
    800043d4:	884080e7          	jalr	-1916(ra) # 80000c54 <acquire>
  log.outstanding -= 1;
    800043d8:	509c                	lw	a5,32(s1)
    800043da:	37fd                	addiw	a5,a5,-1
    800043dc:	893e                	mv	s2,a5
    800043de:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043e0:	50dc                	lw	a5,36(s1)
    800043e2:	efb1                	bnez	a5,8000443e <end_op+0x84>
    panic("log.committing");
  if(log.outstanding == 0){
    800043e4:	06091863          	bnez	s2,80004454 <end_op+0x9a>
    do_commit = 1;
    log.committing = 1;
    800043e8:	00020497          	auipc	s1,0x20
    800043ec:	28848493          	addi	s1,s1,648 # 80024670 <log>
    800043f0:	4785                	li	a5,1
    800043f2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043f4:	8526                	mv	a0,s1
    800043f6:	ffffd097          	auipc	ra,0xffffd
    800043fa:	90e080e7          	jalr	-1778(ra) # 80000d04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043fe:	54dc                	lw	a5,44(s1)
    80004400:	08f04063          	bgtz	a5,80004480 <end_op+0xc6>
    acquire(&log.lock);
    80004404:	00020517          	auipc	a0,0x20
    80004408:	26c50513          	addi	a0,a0,620 # 80024670 <log>
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	848080e7          	jalr	-1976(ra) # 80000c54 <acquire>
    log.committing = 0;
    80004414:	00020797          	auipc	a5,0x20
    80004418:	2807a023          	sw	zero,640(a5) # 80024694 <log+0x24>
    wakeup(&log);
    8000441c:	00020517          	auipc	a0,0x20
    80004420:	25450513          	addi	a0,a0,596 # 80024670 <log>
    80004424:	ffffe097          	auipc	ra,0xffffe
    80004428:	09e080e7          	jalr	158(ra) # 800024c2 <wakeup>
    release(&log.lock);
    8000442c:	00020517          	auipc	a0,0x20
    80004430:	24450513          	addi	a0,a0,580 # 80024670 <log>
    80004434:	ffffd097          	auipc	ra,0xffffd
    80004438:	8d0080e7          	jalr	-1840(ra) # 80000d04 <release>
}
    8000443c:	a825                	j	80004474 <end_op+0xba>
    8000443e:	ec4e                	sd	s3,24(sp)
    80004440:	e852                	sd	s4,16(sp)
    80004442:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004444:	00004517          	auipc	a0,0x4
    80004448:	0ec50513          	addi	a0,a0,236 # 80008530 <etext+0x530>
    8000444c:	ffffc097          	auipc	ra,0xffffc
    80004450:	10a080e7          	jalr	266(ra) # 80000556 <panic>
    wakeup(&log);
    80004454:	00020517          	auipc	a0,0x20
    80004458:	21c50513          	addi	a0,a0,540 # 80024670 <log>
    8000445c:	ffffe097          	auipc	ra,0xffffe
    80004460:	066080e7          	jalr	102(ra) # 800024c2 <wakeup>
  release(&log.lock);
    80004464:	00020517          	auipc	a0,0x20
    80004468:	20c50513          	addi	a0,a0,524 # 80024670 <log>
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	898080e7          	jalr	-1896(ra) # 80000d04 <release>
}
    80004474:	70e2                	ld	ra,56(sp)
    80004476:	7442                	ld	s0,48(sp)
    80004478:	74a2                	ld	s1,40(sp)
    8000447a:	7902                	ld	s2,32(sp)
    8000447c:	6121                	addi	sp,sp,64
    8000447e:	8082                	ret
    80004480:	ec4e                	sd	s3,24(sp)
    80004482:	e852                	sd	s4,16(sp)
    80004484:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004486:	00020a97          	auipc	s5,0x20
    8000448a:	21aa8a93          	addi	s5,s5,538 # 800246a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000448e:	00020a17          	auipc	s4,0x20
    80004492:	1e2a0a13          	addi	s4,s4,482 # 80024670 <log>
    80004496:	018a2583          	lw	a1,24(s4)
    8000449a:	012585bb          	addw	a1,a1,s2
    8000449e:	2585                	addiw	a1,a1,1
    800044a0:	028a2503          	lw	a0,40(s4)
    800044a4:	fffff097          	auipc	ra,0xfffff
    800044a8:	cd2080e7          	jalr	-814(ra) # 80003176 <bread>
    800044ac:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044ae:	000aa583          	lw	a1,0(s5)
    800044b2:	028a2503          	lw	a0,40(s4)
    800044b6:	fffff097          	auipc	ra,0xfffff
    800044ba:	cc0080e7          	jalr	-832(ra) # 80003176 <bread>
    800044be:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044c0:	40000613          	li	a2,1024
    800044c4:	05850593          	addi	a1,a0,88
    800044c8:	05848513          	addi	a0,s1,88
    800044cc:	ffffd097          	auipc	ra,0xffffd
    800044d0:	8e0080e7          	jalr	-1824(ra) # 80000dac <memmove>
    bwrite(to);  // write the log
    800044d4:	8526                	mv	a0,s1
    800044d6:	fffff097          	auipc	ra,0xfffff
    800044da:	d92080e7          	jalr	-622(ra) # 80003268 <bwrite>
    brelse(from);
    800044de:	854e                	mv	a0,s3
    800044e0:	fffff097          	auipc	ra,0xfffff
    800044e4:	dc6080e7          	jalr	-570(ra) # 800032a6 <brelse>
    brelse(to);
    800044e8:	8526                	mv	a0,s1
    800044ea:	fffff097          	auipc	ra,0xfffff
    800044ee:	dbc080e7          	jalr	-580(ra) # 800032a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044f2:	2905                	addiw	s2,s2,1
    800044f4:	0a91                	addi	s5,s5,4
    800044f6:	02ca2783          	lw	a5,44(s4)
    800044fa:	f8f94ee3          	blt	s2,a5,80004496 <end_op+0xdc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044fe:	00000097          	auipc	ra,0x0
    80004502:	c70080e7          	jalr	-912(ra) # 8000416e <write_head>
    install_trans(0); // Now install writes to home locations
    80004506:	4501                	li	a0,0
    80004508:	00000097          	auipc	ra,0x0
    8000450c:	cd0080e7          	jalr	-816(ra) # 800041d8 <install_trans>
    log.lh.n = 0;
    80004510:	00020797          	auipc	a5,0x20
    80004514:	1807a623          	sw	zero,396(a5) # 8002469c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004518:	00000097          	auipc	ra,0x0
    8000451c:	c56080e7          	jalr	-938(ra) # 8000416e <write_head>
    80004520:	69e2                	ld	s3,24(sp)
    80004522:	6a42                	ld	s4,16(sp)
    80004524:	6aa2                	ld	s5,8(sp)
    80004526:	bdf9                	j	80004404 <end_op+0x4a>

0000000080004528 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004528:	1101                	addi	sp,sp,-32
    8000452a:	ec06                	sd	ra,24(sp)
    8000452c:	e822                	sd	s0,16(sp)
    8000452e:	e426                	sd	s1,8(sp)
    80004530:	1000                	addi	s0,sp,32
    80004532:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004534:	00020517          	auipc	a0,0x20
    80004538:	13c50513          	addi	a0,a0,316 # 80024670 <log>
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	718080e7          	jalr	1816(ra) # 80000c54 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004544:	00020617          	auipc	a2,0x20
    80004548:	15862603          	lw	a2,344(a2) # 8002469c <log+0x2c>
    8000454c:	47f5                	li	a5,29
    8000454e:	06c7c663          	blt	a5,a2,800045ba <log_write+0x92>
    80004552:	00020797          	auipc	a5,0x20
    80004556:	13a7a783          	lw	a5,314(a5) # 8002468c <log+0x1c>
    8000455a:	37fd                	addiw	a5,a5,-1
    8000455c:	04f65f63          	bge	a2,a5,800045ba <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004560:	00020797          	auipc	a5,0x20
    80004564:	1307a783          	lw	a5,304(a5) # 80024690 <log+0x20>
    80004568:	06f05163          	blez	a5,800045ca <log_write+0xa2>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000456c:	4781                	li	a5,0
    8000456e:	06c05663          	blez	a2,800045da <log_write+0xb2>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004572:	44cc                	lw	a1,12(s1)
    80004574:	00020717          	auipc	a4,0x20
    80004578:	12c70713          	addi	a4,a4,300 # 800246a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000457c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000457e:	4314                	lw	a3,0(a4)
    80004580:	04b68d63          	beq	a3,a1,800045da <log_write+0xb2>
  for (i = 0; i < log.lh.n; i++) {
    80004584:	2785                	addiw	a5,a5,1
    80004586:	0711                	addi	a4,a4,4
    80004588:	fef61be3          	bne	a2,a5,8000457e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000458c:	060a                	slli	a2,a2,0x2
    8000458e:	02060613          	addi	a2,a2,32
    80004592:	00020797          	auipc	a5,0x20
    80004596:	0de78793          	addi	a5,a5,222 # 80024670 <log>
    8000459a:	97b2                	add	a5,a5,a2
    8000459c:	44d8                	lw	a4,12(s1)
    8000459e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045a0:	8526                	mv	a0,s1
    800045a2:	fffff097          	auipc	ra,0xfffff
    800045a6:	d9c080e7          	jalr	-612(ra) # 8000333e <bpin>
    log.lh.n++;
    800045aa:	00020717          	auipc	a4,0x20
    800045ae:	0c670713          	addi	a4,a4,198 # 80024670 <log>
    800045b2:	575c                	lw	a5,44(a4)
    800045b4:	2785                	addiw	a5,a5,1
    800045b6:	d75c                	sw	a5,44(a4)
    800045b8:	a835                	j	800045f4 <log_write+0xcc>
    panic("too big a transaction");
    800045ba:	00004517          	auipc	a0,0x4
    800045be:	f8650513          	addi	a0,a0,-122 # 80008540 <etext+0x540>
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	f94080e7          	jalr	-108(ra) # 80000556 <panic>
    panic("log_write outside of trans");
    800045ca:	00004517          	auipc	a0,0x4
    800045ce:	f8e50513          	addi	a0,a0,-114 # 80008558 <etext+0x558>
    800045d2:	ffffc097          	auipc	ra,0xffffc
    800045d6:	f84080e7          	jalr	-124(ra) # 80000556 <panic>
  log.lh.block[i] = b->blockno;
    800045da:	00279693          	slli	a3,a5,0x2
    800045de:	02068693          	addi	a3,a3,32
    800045e2:	00020717          	auipc	a4,0x20
    800045e6:	08e70713          	addi	a4,a4,142 # 80024670 <log>
    800045ea:	9736                	add	a4,a4,a3
    800045ec:	44d4                	lw	a3,12(s1)
    800045ee:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045f0:	faf608e3          	beq	a2,a5,800045a0 <log_write+0x78>
  }
  release(&log.lock);
    800045f4:	00020517          	auipc	a0,0x20
    800045f8:	07c50513          	addi	a0,a0,124 # 80024670 <log>
    800045fc:	ffffc097          	auipc	ra,0xffffc
    80004600:	708080e7          	jalr	1800(ra) # 80000d04 <release>
}
    80004604:	60e2                	ld	ra,24(sp)
    80004606:	6442                	ld	s0,16(sp)
    80004608:	64a2                	ld	s1,8(sp)
    8000460a:	6105                	addi	sp,sp,32
    8000460c:	8082                	ret

000000008000460e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000460e:	1101                	addi	sp,sp,-32
    80004610:	ec06                	sd	ra,24(sp)
    80004612:	e822                	sd	s0,16(sp)
    80004614:	e426                	sd	s1,8(sp)
    80004616:	e04a                	sd	s2,0(sp)
    80004618:	1000                	addi	s0,sp,32
    8000461a:	84aa                	mv	s1,a0
    8000461c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000461e:	00004597          	auipc	a1,0x4
    80004622:	f5a58593          	addi	a1,a1,-166 # 80008578 <etext+0x578>
    80004626:	0521                	addi	a0,a0,8
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	592080e7          	jalr	1426(ra) # 80000bba <initlock>
  lk->name = name;
    80004630:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004634:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004638:	0204a423          	sw	zero,40(s1)
}
    8000463c:	60e2                	ld	ra,24(sp)
    8000463e:	6442                	ld	s0,16(sp)
    80004640:	64a2                	ld	s1,8(sp)
    80004642:	6902                	ld	s2,0(sp)
    80004644:	6105                	addi	sp,sp,32
    80004646:	8082                	ret

0000000080004648 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004648:	1101                	addi	sp,sp,-32
    8000464a:	ec06                	sd	ra,24(sp)
    8000464c:	e822                	sd	s0,16(sp)
    8000464e:	e426                	sd	s1,8(sp)
    80004650:	e04a                	sd	s2,0(sp)
    80004652:	1000                	addi	s0,sp,32
    80004654:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004656:	00850913          	addi	s2,a0,8
    8000465a:	854a                	mv	a0,s2
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	5f8080e7          	jalr	1528(ra) # 80000c54 <acquire>
  while (lk->locked) {
    80004664:	409c                	lw	a5,0(s1)
    80004666:	cb89                	beqz	a5,80004678 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004668:	85ca                	mv	a1,s2
    8000466a:	8526                	mv	a0,s1
    8000466c:	ffffe097          	auipc	ra,0xffffe
    80004670:	b8a080e7          	jalr	-1142(ra) # 800021f6 <sleep>
  while (lk->locked) {
    80004674:	409c                	lw	a5,0(s1)
    80004676:	fbed                	bnez	a5,80004668 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004678:	4785                	li	a5,1
    8000467a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000467c:	ffffd097          	auipc	ra,0xffffd
    80004680:	3fe080e7          	jalr	1022(ra) # 80001a7a <myproc>
    80004684:	591c                	lw	a5,48(a0)
    80004686:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004688:	854a                	mv	a0,s2
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	67a080e7          	jalr	1658(ra) # 80000d04 <release>
}
    80004692:	60e2                	ld	ra,24(sp)
    80004694:	6442                	ld	s0,16(sp)
    80004696:	64a2                	ld	s1,8(sp)
    80004698:	6902                	ld	s2,0(sp)
    8000469a:	6105                	addi	sp,sp,32
    8000469c:	8082                	ret

000000008000469e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000469e:	1101                	addi	sp,sp,-32
    800046a0:	ec06                	sd	ra,24(sp)
    800046a2:	e822                	sd	s0,16(sp)
    800046a4:	e426                	sd	s1,8(sp)
    800046a6:	e04a                	sd	s2,0(sp)
    800046a8:	1000                	addi	s0,sp,32
    800046aa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ac:	00850913          	addi	s2,a0,8
    800046b0:	854a                	mv	a0,s2
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	5a2080e7          	jalr	1442(ra) # 80000c54 <acquire>
  lk->locked = 0;
    800046ba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046be:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046c2:	8526                	mv	a0,s1
    800046c4:	ffffe097          	auipc	ra,0xffffe
    800046c8:	dfe080e7          	jalr	-514(ra) # 800024c2 <wakeup>
  release(&lk->lk);
    800046cc:	854a                	mv	a0,s2
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	636080e7          	jalr	1590(ra) # 80000d04 <release>
}
    800046d6:	60e2                	ld	ra,24(sp)
    800046d8:	6442                	ld	s0,16(sp)
    800046da:	64a2                	ld	s1,8(sp)
    800046dc:	6902                	ld	s2,0(sp)
    800046de:	6105                	addi	sp,sp,32
    800046e0:	8082                	ret

00000000800046e2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046e2:	7179                	addi	sp,sp,-48
    800046e4:	f406                	sd	ra,40(sp)
    800046e6:	f022                	sd	s0,32(sp)
    800046e8:	ec26                	sd	s1,24(sp)
    800046ea:	e84a                	sd	s2,16(sp)
    800046ec:	1800                	addi	s0,sp,48
    800046ee:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046f0:	00850913          	addi	s2,a0,8
    800046f4:	854a                	mv	a0,s2
    800046f6:	ffffc097          	auipc	ra,0xffffc
    800046fa:	55e080e7          	jalr	1374(ra) # 80000c54 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046fe:	409c                	lw	a5,0(s1)
    80004700:	ef91                	bnez	a5,8000471c <holdingsleep+0x3a>
    80004702:	4481                	li	s1,0
  release(&lk->lk);
    80004704:	854a                	mv	a0,s2
    80004706:	ffffc097          	auipc	ra,0xffffc
    8000470a:	5fe080e7          	jalr	1534(ra) # 80000d04 <release>
  return r;
}
    8000470e:	8526                	mv	a0,s1
    80004710:	70a2                	ld	ra,40(sp)
    80004712:	7402                	ld	s0,32(sp)
    80004714:	64e2                	ld	s1,24(sp)
    80004716:	6942                	ld	s2,16(sp)
    80004718:	6145                	addi	sp,sp,48
    8000471a:	8082                	ret
    8000471c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000471e:	0284a983          	lw	s3,40(s1)
    80004722:	ffffd097          	auipc	ra,0xffffd
    80004726:	358080e7          	jalr	856(ra) # 80001a7a <myproc>
    8000472a:	5904                	lw	s1,48(a0)
    8000472c:	413484b3          	sub	s1,s1,s3
    80004730:	0014b493          	seqz	s1,s1
    80004734:	69a2                	ld	s3,8(sp)
    80004736:	b7f9                	j	80004704 <holdingsleep+0x22>

0000000080004738 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004738:	1141                	addi	sp,sp,-16
    8000473a:	e406                	sd	ra,8(sp)
    8000473c:	e022                	sd	s0,0(sp)
    8000473e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004740:	00004597          	auipc	a1,0x4
    80004744:	e4858593          	addi	a1,a1,-440 # 80008588 <etext+0x588>
    80004748:	00020517          	auipc	a0,0x20
    8000474c:	07050513          	addi	a0,a0,112 # 800247b8 <ftable>
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	46a080e7          	jalr	1130(ra) # 80000bba <initlock>
}
    80004758:	60a2                	ld	ra,8(sp)
    8000475a:	6402                	ld	s0,0(sp)
    8000475c:	0141                	addi	sp,sp,16
    8000475e:	8082                	ret

0000000080004760 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004760:	1101                	addi	sp,sp,-32
    80004762:	ec06                	sd	ra,24(sp)
    80004764:	e822                	sd	s0,16(sp)
    80004766:	e426                	sd	s1,8(sp)
    80004768:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000476a:	00020517          	auipc	a0,0x20
    8000476e:	04e50513          	addi	a0,a0,78 # 800247b8 <ftable>
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	4e2080e7          	jalr	1250(ra) # 80000c54 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000477a:	00020497          	auipc	s1,0x20
    8000477e:	05648493          	addi	s1,s1,86 # 800247d0 <ftable+0x18>
    80004782:	00021717          	auipc	a4,0x21
    80004786:	fee70713          	addi	a4,a4,-18 # 80025770 <ftable+0xfb8>
    if(f->ref == 0){
    8000478a:	40dc                	lw	a5,4(s1)
    8000478c:	cf99                	beqz	a5,800047aa <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000478e:	02848493          	addi	s1,s1,40
    80004792:	fee49ce3          	bne	s1,a4,8000478a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004796:	00020517          	auipc	a0,0x20
    8000479a:	02250513          	addi	a0,a0,34 # 800247b8 <ftable>
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	566080e7          	jalr	1382(ra) # 80000d04 <release>
  return 0;
    800047a6:	4481                	li	s1,0
    800047a8:	a819                	j	800047be <filealloc+0x5e>
      f->ref = 1;
    800047aa:	4785                	li	a5,1
    800047ac:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047ae:	00020517          	auipc	a0,0x20
    800047b2:	00a50513          	addi	a0,a0,10 # 800247b8 <ftable>
    800047b6:	ffffc097          	auipc	ra,0xffffc
    800047ba:	54e080e7          	jalr	1358(ra) # 80000d04 <release>
}
    800047be:	8526                	mv	a0,s1
    800047c0:	60e2                	ld	ra,24(sp)
    800047c2:	6442                	ld	s0,16(sp)
    800047c4:	64a2                	ld	s1,8(sp)
    800047c6:	6105                	addi	sp,sp,32
    800047c8:	8082                	ret

00000000800047ca <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047ca:	1101                	addi	sp,sp,-32
    800047cc:	ec06                	sd	ra,24(sp)
    800047ce:	e822                	sd	s0,16(sp)
    800047d0:	e426                	sd	s1,8(sp)
    800047d2:	1000                	addi	s0,sp,32
    800047d4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047d6:	00020517          	auipc	a0,0x20
    800047da:	fe250513          	addi	a0,a0,-30 # 800247b8 <ftable>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	476080e7          	jalr	1142(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    800047e6:	40dc                	lw	a5,4(s1)
    800047e8:	02f05263          	blez	a5,8000480c <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047ec:	2785                	addiw	a5,a5,1
    800047ee:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047f0:	00020517          	auipc	a0,0x20
    800047f4:	fc850513          	addi	a0,a0,-56 # 800247b8 <ftable>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	50c080e7          	jalr	1292(ra) # 80000d04 <release>
  return f;
}
    80004800:	8526                	mv	a0,s1
    80004802:	60e2                	ld	ra,24(sp)
    80004804:	6442                	ld	s0,16(sp)
    80004806:	64a2                	ld	s1,8(sp)
    80004808:	6105                	addi	sp,sp,32
    8000480a:	8082                	ret
    panic("filedup");
    8000480c:	00004517          	auipc	a0,0x4
    80004810:	d8450513          	addi	a0,a0,-636 # 80008590 <etext+0x590>
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	d42080e7          	jalr	-702(ra) # 80000556 <panic>

000000008000481c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000481c:	7139                	addi	sp,sp,-64
    8000481e:	fc06                	sd	ra,56(sp)
    80004820:	f822                	sd	s0,48(sp)
    80004822:	f426                	sd	s1,40(sp)
    80004824:	0080                	addi	s0,sp,64
    80004826:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004828:	00020517          	auipc	a0,0x20
    8000482c:	f9050513          	addi	a0,a0,-112 # 800247b8 <ftable>
    80004830:	ffffc097          	auipc	ra,0xffffc
    80004834:	424080e7          	jalr	1060(ra) # 80000c54 <acquire>
  if(f->ref < 1)
    80004838:	40dc                	lw	a5,4(s1)
    8000483a:	04f05c63          	blez	a5,80004892 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    8000483e:	37fd                	addiw	a5,a5,-1
    80004840:	c0dc                	sw	a5,4(s1)
    80004842:	06f04463          	bgtz	a5,800048aa <fileclose+0x8e>
    80004846:	f04a                	sd	s2,32(sp)
    80004848:	ec4e                	sd	s3,24(sp)
    8000484a:	e852                	sd	s4,16(sp)
    8000484c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000484e:	0004a903          	lw	s2,0(s1)
    80004852:	0094c783          	lbu	a5,9(s1)
    80004856:	89be                	mv	s3,a5
    80004858:	689c                	ld	a5,16(s1)
    8000485a:	8a3e                	mv	s4,a5
    8000485c:	6c9c                	ld	a5,24(s1)
    8000485e:	8abe                	mv	s5,a5
  f->ref = 0;
    80004860:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004864:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004868:	00020517          	auipc	a0,0x20
    8000486c:	f5050513          	addi	a0,a0,-176 # 800247b8 <ftable>
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	494080e7          	jalr	1172(ra) # 80000d04 <release>

  if(ff.type == FD_PIPE){
    80004878:	4785                	li	a5,1
    8000487a:	04f90563          	beq	s2,a5,800048c4 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000487e:	ffe9079b          	addiw	a5,s2,-2
    80004882:	4705                	li	a4,1
    80004884:	04f77b63          	bgeu	a4,a5,800048da <fileclose+0xbe>
    80004888:	7902                	ld	s2,32(sp)
    8000488a:	69e2                	ld	s3,24(sp)
    8000488c:	6a42                	ld	s4,16(sp)
    8000488e:	6aa2                	ld	s5,8(sp)
    80004890:	a02d                	j	800048ba <fileclose+0x9e>
    80004892:	f04a                	sd	s2,32(sp)
    80004894:	ec4e                	sd	s3,24(sp)
    80004896:	e852                	sd	s4,16(sp)
    80004898:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000489a:	00004517          	auipc	a0,0x4
    8000489e:	cfe50513          	addi	a0,a0,-770 # 80008598 <etext+0x598>
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	cb4080e7          	jalr	-844(ra) # 80000556 <panic>
    release(&ftable.lock);
    800048aa:	00020517          	auipc	a0,0x20
    800048ae:	f0e50513          	addi	a0,a0,-242 # 800247b8 <ftable>
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	452080e7          	jalr	1106(ra) # 80000d04 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800048ba:	70e2                	ld	ra,56(sp)
    800048bc:	7442                	ld	s0,48(sp)
    800048be:	74a2                	ld	s1,40(sp)
    800048c0:	6121                	addi	sp,sp,64
    800048c2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048c4:	85ce                	mv	a1,s3
    800048c6:	8552                	mv	a0,s4
    800048c8:	00000097          	auipc	ra,0x0
    800048cc:	3b4080e7          	jalr	948(ra) # 80004c7c <pipeclose>
    800048d0:	7902                	ld	s2,32(sp)
    800048d2:	69e2                	ld	s3,24(sp)
    800048d4:	6a42                	ld	s4,16(sp)
    800048d6:	6aa2                	ld	s5,8(sp)
    800048d8:	b7cd                	j	800048ba <fileclose+0x9e>
    begin_op();
    800048da:	00000097          	auipc	ra,0x0
    800048de:	a60080e7          	jalr	-1440(ra) # 8000433a <begin_op>
    iput(ff.ip);
    800048e2:	8556                	mv	a0,s5
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	21c080e7          	jalr	540(ra) # 80003b00 <iput>
    end_op();
    800048ec:	00000097          	auipc	ra,0x0
    800048f0:	ace080e7          	jalr	-1330(ra) # 800043ba <end_op>
    800048f4:	7902                	ld	s2,32(sp)
    800048f6:	69e2                	ld	s3,24(sp)
    800048f8:	6a42                	ld	s4,16(sp)
    800048fa:	6aa2                	ld	s5,8(sp)
    800048fc:	bf7d                	j	800048ba <fileclose+0x9e>

00000000800048fe <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048fe:	715d                	addi	sp,sp,-80
    80004900:	e486                	sd	ra,72(sp)
    80004902:	e0a2                	sd	s0,64(sp)
    80004904:	fc26                	sd	s1,56(sp)
    80004906:	f052                	sd	s4,32(sp)
    80004908:	0880                	addi	s0,sp,80
    8000490a:	84aa                	mv	s1,a0
    8000490c:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000490e:	ffffd097          	auipc	ra,0xffffd
    80004912:	16c080e7          	jalr	364(ra) # 80001a7a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004916:	409c                	lw	a5,0(s1)
    80004918:	37f9                	addiw	a5,a5,-2
    8000491a:	4705                	li	a4,1
    8000491c:	04f76a63          	bltu	a4,a5,80004970 <filestat+0x72>
    80004920:	f84a                	sd	s2,48(sp)
    80004922:	f44e                	sd	s3,40(sp)
    80004924:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004926:	6c88                	ld	a0,24(s1)
    80004928:	fffff097          	auipc	ra,0xfffff
    8000492c:	01a080e7          	jalr	26(ra) # 80003942 <ilock>
    stati(f->ip, &st);
    80004930:	fb840913          	addi	s2,s0,-72
    80004934:	85ca                	mv	a1,s2
    80004936:	6c88                	ld	a0,24(s1)
    80004938:	fffff097          	auipc	ra,0xfffff
    8000493c:	29a080e7          	jalr	666(ra) # 80003bd2 <stati>
    iunlock(f->ip);
    80004940:	6c88                	ld	a0,24(s1)
    80004942:	fffff097          	auipc	ra,0xfffff
    80004946:	0c6080e7          	jalr	198(ra) # 80003a08 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000494a:	46e1                	li	a3,24
    8000494c:	864a                	mv	a2,s2
    8000494e:	85d2                	mv	a1,s4
    80004950:	0509b503          	ld	a0,80(s3)
    80004954:	ffffd097          	auipc	ra,0xffffd
    80004958:	db6080e7          	jalr	-586(ra) # 8000170a <copyout>
    8000495c:	41f5551b          	sraiw	a0,a0,0x1f
    80004960:	7942                	ld	s2,48(sp)
    80004962:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004964:	60a6                	ld	ra,72(sp)
    80004966:	6406                	ld	s0,64(sp)
    80004968:	74e2                	ld	s1,56(sp)
    8000496a:	7a02                	ld	s4,32(sp)
    8000496c:	6161                	addi	sp,sp,80
    8000496e:	8082                	ret
  return -1;
    80004970:	557d                	li	a0,-1
    80004972:	bfcd                	j	80004964 <filestat+0x66>

0000000080004974 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004974:	7179                	addi	sp,sp,-48
    80004976:	f406                	sd	ra,40(sp)
    80004978:	f022                	sd	s0,32(sp)
    8000497a:	e84a                	sd	s2,16(sp)
    8000497c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000497e:	00854783          	lbu	a5,8(a0)
    80004982:	cbc5                	beqz	a5,80004a32 <fileread+0xbe>
    80004984:	ec26                	sd	s1,24(sp)
    80004986:	e44e                	sd	s3,8(sp)
    80004988:	84aa                	mv	s1,a0
    8000498a:	892e                	mv	s2,a1
    8000498c:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    8000498e:	411c                	lw	a5,0(a0)
    80004990:	4705                	li	a4,1
    80004992:	04e78963          	beq	a5,a4,800049e4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004996:	470d                	li	a4,3
    80004998:	04e78f63          	beq	a5,a4,800049f6 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000499c:	4709                	li	a4,2
    8000499e:	08e79263          	bne	a5,a4,80004a22 <fileread+0xae>
    ilock(f->ip);
    800049a2:	6d08                	ld	a0,24(a0)
    800049a4:	fffff097          	auipc	ra,0xfffff
    800049a8:	f9e080e7          	jalr	-98(ra) # 80003942 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049ac:	874e                	mv	a4,s3
    800049ae:	5094                	lw	a3,32(s1)
    800049b0:	864a                	mv	a2,s2
    800049b2:	4585                	li	a1,1
    800049b4:	6c88                	ld	a0,24(s1)
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	24a080e7          	jalr	586(ra) # 80003c00 <readi>
    800049be:	892a                	mv	s2,a0
    800049c0:	00a05563          	blez	a0,800049ca <fileread+0x56>
      f->off += r;
    800049c4:	509c                	lw	a5,32(s1)
    800049c6:	9fa9                	addw	a5,a5,a0
    800049c8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049ca:	6c88                	ld	a0,24(s1)
    800049cc:	fffff097          	auipc	ra,0xfffff
    800049d0:	03c080e7          	jalr	60(ra) # 80003a08 <iunlock>
    800049d4:	64e2                	ld	s1,24(sp)
    800049d6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800049d8:	854a                	mv	a0,s2
    800049da:	70a2                	ld	ra,40(sp)
    800049dc:	7402                	ld	s0,32(sp)
    800049de:	6942                	ld	s2,16(sp)
    800049e0:	6145                	addi	sp,sp,48
    800049e2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049e4:	6908                	ld	a0,16(a0)
    800049e6:	00000097          	auipc	ra,0x0
    800049ea:	422080e7          	jalr	1058(ra) # 80004e08 <piperead>
    800049ee:	892a                	mv	s2,a0
    800049f0:	64e2                	ld	s1,24(sp)
    800049f2:	69a2                	ld	s3,8(sp)
    800049f4:	b7d5                	j	800049d8 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049f6:	02451783          	lh	a5,36(a0)
    800049fa:	03079693          	slli	a3,a5,0x30
    800049fe:	92c1                	srli	a3,a3,0x30
    80004a00:	4725                	li	a4,9
    80004a02:	02d76b63          	bltu	a4,a3,80004a38 <fileread+0xc4>
    80004a06:	0792                	slli	a5,a5,0x4
    80004a08:	00020717          	auipc	a4,0x20
    80004a0c:	d1070713          	addi	a4,a4,-752 # 80024718 <devsw>
    80004a10:	97ba                	add	a5,a5,a4
    80004a12:	639c                	ld	a5,0(a5)
    80004a14:	c79d                	beqz	a5,80004a42 <fileread+0xce>
    r = devsw[f->major].read(1, addr, n);
    80004a16:	4505                	li	a0,1
    80004a18:	9782                	jalr	a5
    80004a1a:	892a                	mv	s2,a0
    80004a1c:	64e2                	ld	s1,24(sp)
    80004a1e:	69a2                	ld	s3,8(sp)
    80004a20:	bf65                	j	800049d8 <fileread+0x64>
    panic("fileread");
    80004a22:	00004517          	auipc	a0,0x4
    80004a26:	b8650513          	addi	a0,a0,-1146 # 800085a8 <etext+0x5a8>
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	b2c080e7          	jalr	-1236(ra) # 80000556 <panic>
    return -1;
    80004a32:	57fd                	li	a5,-1
    80004a34:	893e                	mv	s2,a5
    80004a36:	b74d                	j	800049d8 <fileread+0x64>
      return -1;
    80004a38:	57fd                	li	a5,-1
    80004a3a:	893e                	mv	s2,a5
    80004a3c:	64e2                	ld	s1,24(sp)
    80004a3e:	69a2                	ld	s3,8(sp)
    80004a40:	bf61                	j	800049d8 <fileread+0x64>
    80004a42:	57fd                	li	a5,-1
    80004a44:	893e                	mv	s2,a5
    80004a46:	64e2                	ld	s1,24(sp)
    80004a48:	69a2                	ld	s3,8(sp)
    80004a4a:	b779                	j	800049d8 <fileread+0x64>

0000000080004a4c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a4c:	00954783          	lbu	a5,9(a0)
    80004a50:	12078d63          	beqz	a5,80004b8a <filewrite+0x13e>
{
    80004a54:	711d                	addi	sp,sp,-96
    80004a56:	ec86                	sd	ra,88(sp)
    80004a58:	e8a2                	sd	s0,80(sp)
    80004a5a:	e0ca                	sd	s2,64(sp)
    80004a5c:	f456                	sd	s5,40(sp)
    80004a5e:	f05a                	sd	s6,32(sp)
    80004a60:	1080                	addi	s0,sp,96
    80004a62:	892a                	mv	s2,a0
    80004a64:	8b2e                	mv	s6,a1
    80004a66:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a68:	411c                	lw	a5,0(a0)
    80004a6a:	4705                	li	a4,1
    80004a6c:	02e78a63          	beq	a5,a4,80004aa0 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a70:	470d                	li	a4,3
    80004a72:	02e78d63          	beq	a5,a4,80004aac <filewrite+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a76:	4709                	li	a4,2
    80004a78:	0ee79b63          	bne	a5,a4,80004b6e <filewrite+0x122>
    80004a7c:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a7e:	0cc05663          	blez	a2,80004b4a <filewrite+0xfe>
    80004a82:	e4a6                	sd	s1,72(sp)
    80004a84:	fc4e                	sd	s3,56(sp)
    80004a86:	ec5e                	sd	s7,24(sp)
    80004a88:	e862                	sd	s8,16(sp)
    80004a8a:	e466                	sd	s9,8(sp)
    int i = 0;
    80004a8c:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004a8e:	6b85                	lui	s7,0x1
    80004a90:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a94:	6785                	lui	a5,0x1
    80004a96:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004a9a:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a9c:	4c05                	li	s8,1
    80004a9e:	a849                	j	80004b30 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004aa0:	6908                	ld	a0,16(a0)
    80004aa2:	00000097          	auipc	ra,0x0
    80004aa6:	250080e7          	jalr	592(ra) # 80004cf2 <pipewrite>
    80004aaa:	a85d                	j	80004b60 <filewrite+0x114>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004aac:	02451783          	lh	a5,36(a0)
    80004ab0:	03079693          	slli	a3,a5,0x30
    80004ab4:	92c1                	srli	a3,a3,0x30
    80004ab6:	4725                	li	a4,9
    80004ab8:	0cd76b63          	bltu	a4,a3,80004b8e <filewrite+0x142>
    80004abc:	0792                	slli	a5,a5,0x4
    80004abe:	00020717          	auipc	a4,0x20
    80004ac2:	c5a70713          	addi	a4,a4,-934 # 80024718 <devsw>
    80004ac6:	97ba                	add	a5,a5,a4
    80004ac8:	679c                	ld	a5,8(a5)
    80004aca:	c7e1                	beqz	a5,80004b92 <filewrite+0x146>
    ret = devsw[f->major].write(1, addr, n);
    80004acc:	4505                	li	a0,1
    80004ace:	9782                	jalr	a5
    80004ad0:	a841                	j	80004b60 <filewrite+0x114>
      if(n1 > max)
    80004ad2:	2981                	sext.w	s3,s3
      begin_op();
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	866080e7          	jalr	-1946(ra) # 8000433a <begin_op>
      ilock(f->ip);
    80004adc:	01893503          	ld	a0,24(s2)
    80004ae0:	fffff097          	auipc	ra,0xfffff
    80004ae4:	e62080e7          	jalr	-414(ra) # 80003942 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ae8:	874e                	mv	a4,s3
    80004aea:	02092683          	lw	a3,32(s2)
    80004aee:	016a0633          	add	a2,s4,s6
    80004af2:	85e2                	mv	a1,s8
    80004af4:	01893503          	ld	a0,24(s2)
    80004af8:	fffff097          	auipc	ra,0xfffff
    80004afc:	202080e7          	jalr	514(ra) # 80003cfa <writei>
    80004b00:	84aa                	mv	s1,a0
    80004b02:	00a05763          	blez	a0,80004b10 <filewrite+0xc4>
        f->off += r;
    80004b06:	02092783          	lw	a5,32(s2)
    80004b0a:	9fa9                	addw	a5,a5,a0
    80004b0c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b10:	01893503          	ld	a0,24(s2)
    80004b14:	fffff097          	auipc	ra,0xfffff
    80004b18:	ef4080e7          	jalr	-268(ra) # 80003a08 <iunlock>
      end_op();
    80004b1c:	00000097          	auipc	ra,0x0
    80004b20:	89e080e7          	jalr	-1890(ra) # 800043ba <end_op>

      if(r != n1){
    80004b24:	02999563          	bne	s3,s1,80004b4e <filewrite+0x102>
        // error from writei
        break;
      }
      i += r;
    80004b28:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004b2c:	015a5963          	bge	s4,s5,80004b3e <filewrite+0xf2>
      int n1 = n - i;
    80004b30:	414a87bb          	subw	a5,s5,s4
    80004b34:	89be                	mv	s3,a5
      if(n1 > max)
    80004b36:	f8fbdee3          	bge	s7,a5,80004ad2 <filewrite+0x86>
    80004b3a:	89e6                	mv	s3,s9
    80004b3c:	bf59                	j	80004ad2 <filewrite+0x86>
    80004b3e:	64a6                	ld	s1,72(sp)
    80004b40:	79e2                	ld	s3,56(sp)
    80004b42:	6be2                	ld	s7,24(sp)
    80004b44:	6c42                	ld	s8,16(sp)
    80004b46:	6ca2                	ld	s9,8(sp)
    80004b48:	a801                	j	80004b58 <filewrite+0x10c>
    int i = 0;
    80004b4a:	4a01                	li	s4,0
    80004b4c:	a031                	j	80004b58 <filewrite+0x10c>
    80004b4e:	64a6                	ld	s1,72(sp)
    80004b50:	79e2                	ld	s3,56(sp)
    80004b52:	6be2                	ld	s7,24(sp)
    80004b54:	6c42                	ld	s8,16(sp)
    80004b56:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004b58:	034a9f63          	bne	s5,s4,80004b96 <filewrite+0x14a>
    80004b5c:	8556                	mv	a0,s5
    80004b5e:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b60:	60e6                	ld	ra,88(sp)
    80004b62:	6446                	ld	s0,80(sp)
    80004b64:	6906                	ld	s2,64(sp)
    80004b66:	7aa2                	ld	s5,40(sp)
    80004b68:	7b02                	ld	s6,32(sp)
    80004b6a:	6125                	addi	sp,sp,96
    80004b6c:	8082                	ret
    80004b6e:	e4a6                	sd	s1,72(sp)
    80004b70:	fc4e                	sd	s3,56(sp)
    80004b72:	f852                	sd	s4,48(sp)
    80004b74:	ec5e                	sd	s7,24(sp)
    80004b76:	e862                	sd	s8,16(sp)
    80004b78:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004b7a:	00004517          	auipc	a0,0x4
    80004b7e:	a3e50513          	addi	a0,a0,-1474 # 800085b8 <etext+0x5b8>
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	9d4080e7          	jalr	-1580(ra) # 80000556 <panic>
    return -1;
    80004b8a:	557d                	li	a0,-1
}
    80004b8c:	8082                	ret
      return -1;
    80004b8e:	557d                	li	a0,-1
    80004b90:	bfc1                	j	80004b60 <filewrite+0x114>
    80004b92:	557d                	li	a0,-1
    80004b94:	b7f1                	j	80004b60 <filewrite+0x114>
    ret = (i == n ? n : -1);
    80004b96:	557d                	li	a0,-1
    80004b98:	7a42                	ld	s4,48(sp)
    80004b9a:	b7d9                	j	80004b60 <filewrite+0x114>

0000000080004b9c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b9c:	7179                	addi	sp,sp,-48
    80004b9e:	f406                	sd	ra,40(sp)
    80004ba0:	f022                	sd	s0,32(sp)
    80004ba2:	ec26                	sd	s1,24(sp)
    80004ba4:	e052                	sd	s4,0(sp)
    80004ba6:	1800                	addi	s0,sp,48
    80004ba8:	84aa                	mv	s1,a0
    80004baa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bac:	0005b023          	sd	zero,0(a1)
    80004bb0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bb4:	00000097          	auipc	ra,0x0
    80004bb8:	bac080e7          	jalr	-1108(ra) # 80004760 <filealloc>
    80004bbc:	e088                	sd	a0,0(s1)
    80004bbe:	cd49                	beqz	a0,80004c58 <pipealloc+0xbc>
    80004bc0:	00000097          	auipc	ra,0x0
    80004bc4:	ba0080e7          	jalr	-1120(ra) # 80004760 <filealloc>
    80004bc8:	00aa3023          	sd	a0,0(s4)
    80004bcc:	c141                	beqz	a0,80004c4c <pipealloc+0xb0>
    80004bce:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	f80080e7          	jalr	-128(ra) # 80000b50 <kalloc>
    80004bd8:	892a                	mv	s2,a0
    80004bda:	c13d                	beqz	a0,80004c40 <pipealloc+0xa4>
    80004bdc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004bde:	4985                	li	s3,1
    80004be0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004be4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004be8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004bec:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004bf0:	00004597          	auipc	a1,0x4
    80004bf4:	9d858593          	addi	a1,a1,-1576 # 800085c8 <etext+0x5c8>
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	fc2080e7          	jalr	-62(ra) # 80000bba <initlock>
  (*f0)->type = FD_PIPE;
    80004c00:	609c                	ld	a5,0(s1)
    80004c02:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c06:	609c                	ld	a5,0(s1)
    80004c08:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c0c:	609c                	ld	a5,0(s1)
    80004c0e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c12:	609c                	ld	a5,0(s1)
    80004c14:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c18:	000a3783          	ld	a5,0(s4)
    80004c1c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c20:	000a3783          	ld	a5,0(s4)
    80004c24:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c28:	000a3783          	ld	a5,0(s4)
    80004c2c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c30:	000a3783          	ld	a5,0(s4)
    80004c34:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c38:	4501                	li	a0,0
    80004c3a:	6942                	ld	s2,16(sp)
    80004c3c:	69a2                	ld	s3,8(sp)
    80004c3e:	a03d                	j	80004c6c <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c40:	6088                	ld	a0,0(s1)
    80004c42:	c119                	beqz	a0,80004c48 <pipealloc+0xac>
    80004c44:	6942                	ld	s2,16(sp)
    80004c46:	a029                	j	80004c50 <pipealloc+0xb4>
    80004c48:	6942                	ld	s2,16(sp)
    80004c4a:	a039                	j	80004c58 <pipealloc+0xbc>
    80004c4c:	6088                	ld	a0,0(s1)
    80004c4e:	c50d                	beqz	a0,80004c78 <pipealloc+0xdc>
    fileclose(*f0);
    80004c50:	00000097          	auipc	ra,0x0
    80004c54:	bcc080e7          	jalr	-1076(ra) # 8000481c <fileclose>
  if(*f1)
    80004c58:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c5c:	557d                	li	a0,-1
  if(*f1)
    80004c5e:	c799                	beqz	a5,80004c6c <pipealloc+0xd0>
    fileclose(*f1);
    80004c60:	853e                	mv	a0,a5
    80004c62:	00000097          	auipc	ra,0x0
    80004c66:	bba080e7          	jalr	-1094(ra) # 8000481c <fileclose>
  return -1;
    80004c6a:	557d                	li	a0,-1
}
    80004c6c:	70a2                	ld	ra,40(sp)
    80004c6e:	7402                	ld	s0,32(sp)
    80004c70:	64e2                	ld	s1,24(sp)
    80004c72:	6a02                	ld	s4,0(sp)
    80004c74:	6145                	addi	sp,sp,48
    80004c76:	8082                	ret
  return -1;
    80004c78:	557d                	li	a0,-1
    80004c7a:	bfcd                	j	80004c6c <pipealloc+0xd0>

0000000080004c7c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c7c:	1101                	addi	sp,sp,-32
    80004c7e:	ec06                	sd	ra,24(sp)
    80004c80:	e822                	sd	s0,16(sp)
    80004c82:	e426                	sd	s1,8(sp)
    80004c84:	e04a                	sd	s2,0(sp)
    80004c86:	1000                	addi	s0,sp,32
    80004c88:	84aa                	mv	s1,a0
    80004c8a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c8c:	ffffc097          	auipc	ra,0xffffc
    80004c90:	fc8080e7          	jalr	-56(ra) # 80000c54 <acquire>
  if(writable){
    80004c94:	02090b63          	beqz	s2,80004cca <pipeclose+0x4e>
    pi->writeopen = 0;
    80004c98:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c9c:	21848513          	addi	a0,s1,536
    80004ca0:	ffffe097          	auipc	ra,0xffffe
    80004ca4:	822080e7          	jalr	-2014(ra) # 800024c2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ca8:	2204a783          	lw	a5,544(s1)
    80004cac:	e781                	bnez	a5,80004cb4 <pipeclose+0x38>
    80004cae:	2244a783          	lw	a5,548(s1)
    80004cb2:	c78d                	beqz	a5,80004cdc <pipeclose+0x60>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	04e080e7          	jalr	78(ra) # 80000d04 <release>
}
    80004cbe:	60e2                	ld	ra,24(sp)
    80004cc0:	6442                	ld	s0,16(sp)
    80004cc2:	64a2                	ld	s1,8(sp)
    80004cc4:	6902                	ld	s2,0(sp)
    80004cc6:	6105                	addi	sp,sp,32
    80004cc8:	8082                	ret
    pi->readopen = 0;
    80004cca:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004cce:	21c48513          	addi	a0,s1,540
    80004cd2:	ffffd097          	auipc	ra,0xffffd
    80004cd6:	7f0080e7          	jalr	2032(ra) # 800024c2 <wakeup>
    80004cda:	b7f9                	j	80004ca8 <pipeclose+0x2c>
    release(&pi->lock);
    80004cdc:	8526                	mv	a0,s1
    80004cde:	ffffc097          	auipc	ra,0xffffc
    80004ce2:	026080e7          	jalr	38(ra) # 80000d04 <release>
    kfree((char*)pi);
    80004ce6:	8526                	mv	a0,s1
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	d64080e7          	jalr	-668(ra) # 80000a4c <kfree>
    80004cf0:	b7f9                	j	80004cbe <pipeclose+0x42>

0000000080004cf2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cf2:	7159                	addi	sp,sp,-112
    80004cf4:	f486                	sd	ra,104(sp)
    80004cf6:	f0a2                	sd	s0,96(sp)
    80004cf8:	eca6                	sd	s1,88(sp)
    80004cfa:	e8ca                	sd	s2,80(sp)
    80004cfc:	e4ce                	sd	s3,72(sp)
    80004cfe:	e0d2                	sd	s4,64(sp)
    80004d00:	fc56                	sd	s5,56(sp)
    80004d02:	1880                	addi	s0,sp,112
    80004d04:	84aa                	mv	s1,a0
    80004d06:	8aae                	mv	s5,a1
    80004d08:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d0a:	ffffd097          	auipc	ra,0xffffd
    80004d0e:	d70080e7          	jalr	-656(ra) # 80001a7a <myproc>
    80004d12:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d14:	8526                	mv	a0,s1
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	f3e080e7          	jalr	-194(ra) # 80000c54 <acquire>
  while(i < n){
    80004d1e:	0d405d63          	blez	s4,80004df8 <pipewrite+0x106>
    80004d22:	f85a                	sd	s6,48(sp)
    80004d24:	f45e                	sd	s7,40(sp)
    80004d26:	f062                	sd	s8,32(sp)
    80004d28:	ec66                	sd	s9,24(sp)
    80004d2a:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004d2c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d2e:	f9f40c13          	addi	s8,s0,-97
    80004d32:	4b85                	li	s7,1
    80004d34:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d36:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d3a:	21c48c93          	addi	s9,s1,540
    80004d3e:	a099                	j	80004d84 <pipewrite+0x92>
      release(&pi->lock);
    80004d40:	8526                	mv	a0,s1
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	fc2080e7          	jalr	-62(ra) # 80000d04 <release>
      return -1;
    80004d4a:	597d                	li	s2,-1
    80004d4c:	7b42                	ld	s6,48(sp)
    80004d4e:	7ba2                	ld	s7,40(sp)
    80004d50:	7c02                	ld	s8,32(sp)
    80004d52:	6ce2                	ld	s9,24(sp)
    80004d54:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d56:	854a                	mv	a0,s2
    80004d58:	70a6                	ld	ra,104(sp)
    80004d5a:	7406                	ld	s0,96(sp)
    80004d5c:	64e6                	ld	s1,88(sp)
    80004d5e:	6946                	ld	s2,80(sp)
    80004d60:	69a6                	ld	s3,72(sp)
    80004d62:	6a06                	ld	s4,64(sp)
    80004d64:	7ae2                	ld	s5,56(sp)
    80004d66:	6165                	addi	sp,sp,112
    80004d68:	8082                	ret
      wakeup(&pi->nread);
    80004d6a:	856a                	mv	a0,s10
    80004d6c:	ffffd097          	auipc	ra,0xffffd
    80004d70:	756080e7          	jalr	1878(ra) # 800024c2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d74:	85a6                	mv	a1,s1
    80004d76:	8566                	mv	a0,s9
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	47e080e7          	jalr	1150(ra) # 800021f6 <sleep>
  while(i < n){
    80004d80:	05495b63          	bge	s2,s4,80004dd6 <pipewrite+0xe4>
    if(pi->readopen == 0 || pr->killed){
    80004d84:	2204a783          	lw	a5,544(s1)
    80004d88:	dfc5                	beqz	a5,80004d40 <pipewrite+0x4e>
    80004d8a:	0289a783          	lw	a5,40(s3)
    80004d8e:	fbcd                	bnez	a5,80004d40 <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d90:	2184a783          	lw	a5,536(s1)
    80004d94:	21c4a703          	lw	a4,540(s1)
    80004d98:	2007879b          	addiw	a5,a5,512
    80004d9c:	fcf707e3          	beq	a4,a5,80004d6a <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004da0:	86de                	mv	a3,s7
    80004da2:	01590633          	add	a2,s2,s5
    80004da6:	85e2                	mv	a1,s8
    80004da8:	0509b503          	ld	a0,80(s3)
    80004dac:	ffffd097          	auipc	ra,0xffffd
    80004db0:	9ea080e7          	jalr	-1558(ra) # 80001796 <copyin>
    80004db4:	05650463          	beq	a0,s6,80004dfc <pipewrite+0x10a>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004db8:	21c4a783          	lw	a5,540(s1)
    80004dbc:	0017871b          	addiw	a4,a5,1
    80004dc0:	20e4ae23          	sw	a4,540(s1)
    80004dc4:	1ff7f793          	andi	a5,a5,511
    80004dc8:	97a6                	add	a5,a5,s1
    80004dca:	f9f44703          	lbu	a4,-97(s0)
    80004dce:	00e78c23          	sb	a4,24(a5)
      i++;
    80004dd2:	2905                	addiw	s2,s2,1
    80004dd4:	b775                	j	80004d80 <pipewrite+0x8e>
    80004dd6:	7b42                	ld	s6,48(sp)
    80004dd8:	7ba2                	ld	s7,40(sp)
    80004dda:	7c02                	ld	s8,32(sp)
    80004ddc:	6ce2                	ld	s9,24(sp)
    80004dde:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004de0:	21848513          	addi	a0,s1,536
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	6de080e7          	jalr	1758(ra) # 800024c2 <wakeup>
  release(&pi->lock);
    80004dec:	8526                	mv	a0,s1
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	f16080e7          	jalr	-234(ra) # 80000d04 <release>
  return i;
    80004df6:	b785                	j	80004d56 <pipewrite+0x64>
  int i = 0;
    80004df8:	4901                	li	s2,0
    80004dfa:	b7dd                	j	80004de0 <pipewrite+0xee>
    80004dfc:	7b42                	ld	s6,48(sp)
    80004dfe:	7ba2                	ld	s7,40(sp)
    80004e00:	7c02                	ld	s8,32(sp)
    80004e02:	6ce2                	ld	s9,24(sp)
    80004e04:	6d42                	ld	s10,16(sp)
    80004e06:	bfe9                	j	80004de0 <pipewrite+0xee>

0000000080004e08 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e08:	711d                	addi	sp,sp,-96
    80004e0a:	ec86                	sd	ra,88(sp)
    80004e0c:	e8a2                	sd	s0,80(sp)
    80004e0e:	e4a6                	sd	s1,72(sp)
    80004e10:	e0ca                	sd	s2,64(sp)
    80004e12:	fc4e                	sd	s3,56(sp)
    80004e14:	f852                	sd	s4,48(sp)
    80004e16:	f456                	sd	s5,40(sp)
    80004e18:	1080                	addi	s0,sp,96
    80004e1a:	84aa                	mv	s1,a0
    80004e1c:	892e                	mv	s2,a1
    80004e1e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e20:	ffffd097          	auipc	ra,0xffffd
    80004e24:	c5a080e7          	jalr	-934(ra) # 80001a7a <myproc>
    80004e28:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	e28080e7          	jalr	-472(ra) # 80000c54 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e34:	2184a703          	lw	a4,536(s1)
    80004e38:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e3c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e40:	02f71863          	bne	a4,a5,80004e70 <piperead+0x68>
    80004e44:	2244a783          	lw	a5,548(s1)
    80004e48:	cf9d                	beqz	a5,80004e86 <piperead+0x7e>
    if(pr->killed){
    80004e4a:	028a2783          	lw	a5,40(s4)
    80004e4e:	e78d                	bnez	a5,80004e78 <piperead+0x70>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e50:	85a6                	mv	a1,s1
    80004e52:	854e                	mv	a0,s3
    80004e54:	ffffd097          	auipc	ra,0xffffd
    80004e58:	3a2080e7          	jalr	930(ra) # 800021f6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e5c:	2184a703          	lw	a4,536(s1)
    80004e60:	21c4a783          	lw	a5,540(s1)
    80004e64:	fef700e3          	beq	a4,a5,80004e44 <piperead+0x3c>
    80004e68:	f05a                	sd	s6,32(sp)
    80004e6a:	ec5e                	sd	s7,24(sp)
    80004e6c:	e862                	sd	s8,16(sp)
    80004e6e:	a839                	j	80004e8c <piperead+0x84>
    80004e70:	f05a                	sd	s6,32(sp)
    80004e72:	ec5e                	sd	s7,24(sp)
    80004e74:	e862                	sd	s8,16(sp)
    80004e76:	a819                	j	80004e8c <piperead+0x84>
      release(&pi->lock);
    80004e78:	8526                	mv	a0,s1
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	e8a080e7          	jalr	-374(ra) # 80000d04 <release>
      return -1;
    80004e82:	59fd                	li	s3,-1
    80004e84:	a88d                	j	80004ef6 <piperead+0xee>
    80004e86:	f05a                	sd	s6,32(sp)
    80004e88:	ec5e                	sd	s7,24(sp)
    80004e8a:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e8c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e8e:	faf40c13          	addi	s8,s0,-81
    80004e92:	4b85                	li	s7,1
    80004e94:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e96:	05505263          	blez	s5,80004eda <piperead+0xd2>
    if(pi->nread == pi->nwrite)
    80004e9a:	2184a783          	lw	a5,536(s1)
    80004e9e:	21c4a703          	lw	a4,540(s1)
    80004ea2:	02f70c63          	beq	a4,a5,80004eda <piperead+0xd2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ea6:	0017871b          	addiw	a4,a5,1
    80004eaa:	20e4ac23          	sw	a4,536(s1)
    80004eae:	1ff7f793          	andi	a5,a5,511
    80004eb2:	97a6                	add	a5,a5,s1
    80004eb4:	0187c783          	lbu	a5,24(a5)
    80004eb8:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ebc:	86de                	mv	a3,s7
    80004ebe:	8662                	mv	a2,s8
    80004ec0:	85ca                	mv	a1,s2
    80004ec2:	050a3503          	ld	a0,80(s4)
    80004ec6:	ffffd097          	auipc	ra,0xffffd
    80004eca:	844080e7          	jalr	-1980(ra) # 8000170a <copyout>
    80004ece:	01650663          	beq	a0,s6,80004eda <piperead+0xd2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ed2:	2985                	addiw	s3,s3,1
    80004ed4:	0905                	addi	s2,s2,1
    80004ed6:	fd3a92e3          	bne	s5,s3,80004e9a <piperead+0x92>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004eda:	21c48513          	addi	a0,s1,540
    80004ede:	ffffd097          	auipc	ra,0xffffd
    80004ee2:	5e4080e7          	jalr	1508(ra) # 800024c2 <wakeup>
  release(&pi->lock);
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	e1c080e7          	jalr	-484(ra) # 80000d04 <release>
    80004ef0:	7b02                	ld	s6,32(sp)
    80004ef2:	6be2                	ld	s7,24(sp)
    80004ef4:	6c42                	ld	s8,16(sp)
  return i;
}
    80004ef6:	854e                	mv	a0,s3
    80004ef8:	60e6                	ld	ra,88(sp)
    80004efa:	6446                	ld	s0,80(sp)
    80004efc:	64a6                	ld	s1,72(sp)
    80004efe:	6906                	ld	s2,64(sp)
    80004f00:	79e2                	ld	s3,56(sp)
    80004f02:	7a42                	ld	s4,48(sp)
    80004f04:	7aa2                	ld	s5,40(sp)
    80004f06:	6125                	addi	sp,sp,96
    80004f08:	8082                	ret

0000000080004f0a <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004f0a:	de010113          	addi	sp,sp,-544
    80004f0e:	20113c23          	sd	ra,536(sp)
    80004f12:	20813823          	sd	s0,528(sp)
    80004f16:	20913423          	sd	s1,520(sp)
    80004f1a:	21213023          	sd	s2,512(sp)
    80004f1e:	1400                	addi	s0,sp,544
    80004f20:	892a                	mv	s2,a0
    80004f22:	dea43823          	sd	a0,-528(s0)
    80004f26:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f2a:	ffffd097          	auipc	ra,0xffffd
    80004f2e:	b50080e7          	jalr	-1200(ra) # 80001a7a <myproc>
    80004f32:	84aa                	mv	s1,a0

  begin_op();
    80004f34:	fffff097          	auipc	ra,0xfffff
    80004f38:	406080e7          	jalr	1030(ra) # 8000433a <begin_op>

  if((ip = namei(path)) == 0){
    80004f3c:	854a                	mv	a0,s2
    80004f3e:	fffff097          	auipc	ra,0xfffff
    80004f42:	1f6080e7          	jalr	502(ra) # 80004134 <namei>
    80004f46:	c525                	beqz	a0,80004fae <exec+0xa4>
    80004f48:	fbd2                	sd	s4,496(sp)
    80004f4a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f4c:	fffff097          	auipc	ra,0xfffff
    80004f50:	9f6080e7          	jalr	-1546(ra) # 80003942 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f54:	04000713          	li	a4,64
    80004f58:	4681                	li	a3,0
    80004f5a:	e5040613          	addi	a2,s0,-432
    80004f5e:	4581                	li	a1,0
    80004f60:	8552                	mv	a0,s4
    80004f62:	fffff097          	auipc	ra,0xfffff
    80004f66:	c9e080e7          	jalr	-866(ra) # 80003c00 <readi>
    80004f6a:	04000793          	li	a5,64
    80004f6e:	00f51a63          	bne	a0,a5,80004f82 <exec+0x78>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f72:	e5042703          	lw	a4,-432(s0)
    80004f76:	464c47b7          	lui	a5,0x464c4
    80004f7a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f7e:	02f70e63          	beq	a4,a5,80004fba <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f82:	8552                	mv	a0,s4
    80004f84:	fffff097          	auipc	ra,0xfffff
    80004f88:	c26080e7          	jalr	-986(ra) # 80003baa <iunlockput>
    end_op();
    80004f8c:	fffff097          	auipc	ra,0xfffff
    80004f90:	42e080e7          	jalr	1070(ra) # 800043ba <end_op>
  }
  return -1;
    80004f94:	557d                	li	a0,-1
    80004f96:	7a5e                	ld	s4,496(sp)
}
    80004f98:	21813083          	ld	ra,536(sp)
    80004f9c:	21013403          	ld	s0,528(sp)
    80004fa0:	20813483          	ld	s1,520(sp)
    80004fa4:	20013903          	ld	s2,512(sp)
    80004fa8:	22010113          	addi	sp,sp,544
    80004fac:	8082                	ret
    end_op();
    80004fae:	fffff097          	auipc	ra,0xfffff
    80004fb2:	40c080e7          	jalr	1036(ra) # 800043ba <end_op>
    return -1;
    80004fb6:	557d                	li	a0,-1
    80004fb8:	b7c5                	j	80004f98 <exec+0x8e>
    80004fba:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	ffffd097          	auipc	ra,0xffffd
    80004fc2:	b82080e7          	jalr	-1150(ra) # 80001b40 <proc_pagetable>
    80004fc6:	8b2a                	mv	s6,a0
    80004fc8:	2a050a63          	beqz	a0,8000527c <exec+0x372>
    80004fcc:	ffce                	sd	s3,504(sp)
    80004fce:	f7d6                	sd	s5,488(sp)
    80004fd0:	efde                	sd	s7,472(sp)
    80004fd2:	ebe2                	sd	s8,464(sp)
    80004fd4:	e7e6                	sd	s9,456(sp)
    80004fd6:	e3ea                	sd	s10,448(sp)
    80004fd8:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fda:	e8845783          	lhu	a5,-376(s0)
    80004fde:	cfed                	beqz	a5,800050d8 <exec+0x1ce>
    80004fe0:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fe4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fe6:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fe8:	03800d93          	li	s11,56
    if((ph.vaddr % PGSIZE) != 0)
    80004fec:	6c85                	lui	s9,0x1
    80004fee:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ff2:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004ff6:	6a85                	lui	s5,0x1
    80004ff8:	a0b5                	j	80005064 <exec+0x15a>
      panic("loadseg: address should exist");
    80004ffa:	00003517          	auipc	a0,0x3
    80004ffe:	5d650513          	addi	a0,a0,1494 # 800085d0 <etext+0x5d0>
    80005002:	ffffb097          	auipc	ra,0xffffb
    80005006:	554080e7          	jalr	1364(ra) # 80000556 <panic>
    if(sz - i < PGSIZE)
    8000500a:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000500c:	874a                	mv	a4,s2
    8000500e:	009c06bb          	addw	a3,s8,s1
    80005012:	4581                	li	a1,0
    80005014:	8552                	mv	a0,s4
    80005016:	fffff097          	auipc	ra,0xfffff
    8000501a:	bea080e7          	jalr	-1046(ra) # 80003c00 <readi>
    8000501e:	26a91363          	bne	s2,a0,80005284 <exec+0x37a>
  for(i = 0; i < sz; i += PGSIZE){
    80005022:	009a84bb          	addw	s1,s5,s1
    80005026:	0334f463          	bgeu	s1,s3,8000504e <exec+0x144>
    pa = walkaddr(pagetable, va + i);
    8000502a:	02049593          	slli	a1,s1,0x20
    8000502e:	9181                	srli	a1,a1,0x20
    80005030:	95de                	add	a1,a1,s7
    80005032:	855a                	mv	a0,s6
    80005034:	ffffc097          	auipc	ra,0xffffc
    80005038:	0b6080e7          	jalr	182(ra) # 800010ea <walkaddr>
    8000503c:	862a                	mv	a2,a0
    if(pa == 0)
    8000503e:	dd55                	beqz	a0,80004ffa <exec+0xf0>
    if(sz - i < PGSIZE)
    80005040:	409987bb          	subw	a5,s3,s1
    80005044:	893e                	mv	s2,a5
    80005046:	fcfcf2e3          	bgeu	s9,a5,8000500a <exec+0x100>
    8000504a:	8956                	mv	s2,s5
    8000504c:	bf7d                	j	8000500a <exec+0x100>
    sz = sz1;
    8000504e:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005052:	2d05                	addiw	s10,s10,1
    80005054:	e0843783          	ld	a5,-504(s0)
    80005058:	0387869b          	addiw	a3,a5,56
    8000505c:	e8845783          	lhu	a5,-376(s0)
    80005060:	06fd5d63          	bge	s10,a5,800050da <exec+0x1d0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005064:	e0d43423          	sd	a3,-504(s0)
    80005068:	876e                	mv	a4,s11
    8000506a:	e1840613          	addi	a2,s0,-488
    8000506e:	4581                	li	a1,0
    80005070:	8552                	mv	a0,s4
    80005072:	fffff097          	auipc	ra,0xfffff
    80005076:	b8e080e7          	jalr	-1138(ra) # 80003c00 <readi>
    8000507a:	21b51363          	bne	a0,s11,80005280 <exec+0x376>
    if(ph.type != ELF_PROG_LOAD)
    8000507e:	e1842783          	lw	a5,-488(s0)
    80005082:	4705                	li	a4,1
    80005084:	fce797e3          	bne	a5,a4,80005052 <exec+0x148>
    if(ph.memsz < ph.filesz)
    80005088:	e4043603          	ld	a2,-448(s0)
    8000508c:	e3843783          	ld	a5,-456(s0)
    80005090:	20f66a63          	bltu	a2,a5,800052a4 <exec+0x39a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005094:	e2843783          	ld	a5,-472(s0)
    80005098:	963e                	add	a2,a2,a5
    8000509a:	20f66863          	bltu	a2,a5,800052aa <exec+0x3a0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000509e:	85a6                	mv	a1,s1
    800050a0:	855a                	mv	a0,s6
    800050a2:	ffffc097          	auipc	ra,0xffffc
    800050a6:	406080e7          	jalr	1030(ra) # 800014a8 <uvmalloc>
    800050aa:	dea43c23          	sd	a0,-520(s0)
    800050ae:	20050163          	beqz	a0,800052b0 <exec+0x3a6>
    if((ph.vaddr % PGSIZE) != 0)
    800050b2:	e2843b83          	ld	s7,-472(s0)
    800050b6:	de843783          	ld	a5,-536(s0)
    800050ba:	00fbf7b3          	and	a5,s7,a5
    800050be:	1c079363          	bnez	a5,80005284 <exec+0x37a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050c2:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050c6:	00098663          	beqz	s3,800050d2 <exec+0x1c8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050ca:	e2042c03          	lw	s8,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050ce:	4481                	li	s1,0
    800050d0:	bfa9                	j	8000502a <exec+0x120>
    sz = sz1;
    800050d2:	df843483          	ld	s1,-520(s0)
    800050d6:	bfb5                	j	80005052 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050d8:	4481                	li	s1,0
  iunlockput(ip);
    800050da:	8552                	mv	a0,s4
    800050dc:	fffff097          	auipc	ra,0xfffff
    800050e0:	ace080e7          	jalr	-1330(ra) # 80003baa <iunlockput>
  end_op();
    800050e4:	fffff097          	auipc	ra,0xfffff
    800050e8:	2d6080e7          	jalr	726(ra) # 800043ba <end_op>
  p = myproc();
    800050ec:	ffffd097          	auipc	ra,0xffffd
    800050f0:	98e080e7          	jalr	-1650(ra) # 80001a7a <myproc>
    800050f4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800050f6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800050fa:	6985                	lui	s3,0x1
    800050fc:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800050fe:	99a6                	add	s3,s3,s1
    80005100:	77fd                	lui	a5,0xfffff
    80005102:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005106:	6609                	lui	a2,0x2
    80005108:	964e                	add	a2,a2,s3
    8000510a:	85ce                	mv	a1,s3
    8000510c:	855a                	mv	a0,s6
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	39a080e7          	jalr	922(ra) # 800014a8 <uvmalloc>
    80005116:	8a2a                	mv	s4,a0
    80005118:	e115                	bnez	a0,8000513c <exec+0x232>
    proc_freepagetable(pagetable, sz);
    8000511a:	85ce                	mv	a1,s3
    8000511c:	855a                	mv	a0,s6
    8000511e:	ffffd097          	auipc	ra,0xffffd
    80005122:	abe080e7          	jalr	-1346(ra) # 80001bdc <proc_freepagetable>
  return -1;
    80005126:	557d                	li	a0,-1
    80005128:	79fe                	ld	s3,504(sp)
    8000512a:	7a5e                	ld	s4,496(sp)
    8000512c:	7abe                	ld	s5,488(sp)
    8000512e:	7b1e                	ld	s6,480(sp)
    80005130:	6bfe                	ld	s7,472(sp)
    80005132:	6c5e                	ld	s8,464(sp)
    80005134:	6cbe                	ld	s9,456(sp)
    80005136:	6d1e                	ld	s10,448(sp)
    80005138:	7dfa                	ld	s11,440(sp)
    8000513a:	bdb9                	j	80004f98 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000513c:	75f9                	lui	a1,0xffffe
    8000513e:	95aa                	add	a1,a1,a0
    80005140:	855a                	mv	a0,s6
    80005142:	ffffc097          	auipc	ra,0xffffc
    80005146:	596080e7          	jalr	1430(ra) # 800016d8 <uvmclear>
  stackbase = sp - PGSIZE;
    8000514a:	800a0b93          	addi	s7,s4,-2048
    8000514e:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80005152:	e0043783          	ld	a5,-512(s0)
    80005156:	6388                	ld	a0,0(a5)
  sp = sz;
    80005158:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    8000515a:	4481                	li	s1,0
    ustack[argc] = sp;
    8000515c:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005160:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80005164:	c135                	beqz	a0,800051c8 <exec+0x2be>
    sp -= strlen(argv[argc]) + 1;
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	d74080e7          	jalr	-652(ra) # 80000eda <strlen>
    8000516e:	0015079b          	addiw	a5,a0,1
    80005172:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005176:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000517a:	13796e63          	bltu	s2,s7,800052b6 <exec+0x3ac>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000517e:	e0043d83          	ld	s11,-512(s0)
    80005182:	000db983          	ld	s3,0(s11)
    80005186:	854e                	mv	a0,s3
    80005188:	ffffc097          	auipc	ra,0xffffc
    8000518c:	d52080e7          	jalr	-686(ra) # 80000eda <strlen>
    80005190:	0015069b          	addiw	a3,a0,1
    80005194:	864e                	mv	a2,s3
    80005196:	85ca                	mv	a1,s2
    80005198:	855a                	mv	a0,s6
    8000519a:	ffffc097          	auipc	ra,0xffffc
    8000519e:	570080e7          	jalr	1392(ra) # 8000170a <copyout>
    800051a2:	10054c63          	bltz	a0,800052ba <exec+0x3b0>
    ustack[argc] = sp;
    800051a6:	00349793          	slli	a5,s1,0x3
    800051aa:	97e6                	add	a5,a5,s9
    800051ac:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd6000>
  for(argc = 0; argv[argc]; argc++) {
    800051b0:	0485                	addi	s1,s1,1
    800051b2:	008d8793          	addi	a5,s11,8
    800051b6:	e0f43023          	sd	a5,-512(s0)
    800051ba:	008db503          	ld	a0,8(s11)
    800051be:	c509                	beqz	a0,800051c8 <exec+0x2be>
    if(argc >= MAXARG)
    800051c0:	fb8493e3          	bne	s1,s8,80005166 <exec+0x25c>
  sz = sz1;
    800051c4:	89d2                	mv	s3,s4
    800051c6:	bf91                	j	8000511a <exec+0x210>
  ustack[argc] = 0;
    800051c8:	00349793          	slli	a5,s1,0x3
    800051cc:	f9078793          	addi	a5,a5,-112
    800051d0:	97a2                	add	a5,a5,s0
    800051d2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800051d6:	00349693          	slli	a3,s1,0x3
    800051da:	06a1                	addi	a3,a3,8
    800051dc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051e0:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800051e4:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800051e6:	f3796ae3          	bltu	s2,s7,8000511a <exec+0x210>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051ea:	e9040613          	addi	a2,s0,-368
    800051ee:	85ca                	mv	a1,s2
    800051f0:	855a                	mv	a0,s6
    800051f2:	ffffc097          	auipc	ra,0xffffc
    800051f6:	518080e7          	jalr	1304(ra) # 8000170a <copyout>
    800051fa:	f20540e3          	bltz	a0,8000511a <exec+0x210>
  p->trapframe->a1 = sp;
    800051fe:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005202:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005206:	df043783          	ld	a5,-528(s0)
    8000520a:	0007c703          	lbu	a4,0(a5)
    8000520e:	cf11                	beqz	a4,8000522a <exec+0x320>
    80005210:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005212:	02f00693          	li	a3,47
    80005216:	a029                	j	80005220 <exec+0x316>
  for(last=s=path; *s; s++)
    80005218:	0785                	addi	a5,a5,1
    8000521a:	fff7c703          	lbu	a4,-1(a5)
    8000521e:	c711                	beqz	a4,8000522a <exec+0x320>
    if(*s == '/')
    80005220:	fed71ce3          	bne	a4,a3,80005218 <exec+0x30e>
      last = s+1;
    80005224:	def43823          	sd	a5,-528(s0)
    80005228:	bfc5                	j	80005218 <exec+0x30e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000522a:	4641                	li	a2,16
    8000522c:	df043583          	ld	a1,-528(s0)
    80005230:	158a8513          	addi	a0,s5,344
    80005234:	ffffc097          	auipc	ra,0xffffc
    80005238:	c70080e7          	jalr	-912(ra) # 80000ea4 <safestrcpy>
  oldpagetable = p->pagetable;
    8000523c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005240:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005244:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005248:	058ab783          	ld	a5,88(s5)
    8000524c:	e6843703          	ld	a4,-408(s0)
    80005250:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005252:	058ab783          	ld	a5,88(s5)
    80005256:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000525a:	85ea                	mv	a1,s10
    8000525c:	ffffd097          	auipc	ra,0xffffd
    80005260:	980080e7          	jalr	-1664(ra) # 80001bdc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005264:	0004851b          	sext.w	a0,s1
    80005268:	79fe                	ld	s3,504(sp)
    8000526a:	7a5e                	ld	s4,496(sp)
    8000526c:	7abe                	ld	s5,488(sp)
    8000526e:	7b1e                	ld	s6,480(sp)
    80005270:	6bfe                	ld	s7,472(sp)
    80005272:	6c5e                	ld	s8,464(sp)
    80005274:	6cbe                	ld	s9,456(sp)
    80005276:	6d1e                	ld	s10,448(sp)
    80005278:	7dfa                	ld	s11,440(sp)
    8000527a:	bb39                	j	80004f98 <exec+0x8e>
    8000527c:	7b1e                	ld	s6,480(sp)
    8000527e:	b311                	j	80004f82 <exec+0x78>
    80005280:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005284:	df843583          	ld	a1,-520(s0)
    80005288:	855a                	mv	a0,s6
    8000528a:	ffffd097          	auipc	ra,0xffffd
    8000528e:	952080e7          	jalr	-1710(ra) # 80001bdc <proc_freepagetable>
  if(ip){
    80005292:	79fe                	ld	s3,504(sp)
    80005294:	7abe                	ld	s5,488(sp)
    80005296:	7b1e                	ld	s6,480(sp)
    80005298:	6bfe                	ld	s7,472(sp)
    8000529a:	6c5e                	ld	s8,464(sp)
    8000529c:	6cbe                	ld	s9,456(sp)
    8000529e:	6d1e                	ld	s10,448(sp)
    800052a0:	7dfa                	ld	s11,440(sp)
    800052a2:	b1c5                	j	80004f82 <exec+0x78>
    800052a4:	de943c23          	sd	s1,-520(s0)
    800052a8:	bff1                	j	80005284 <exec+0x37a>
    800052aa:	de943c23          	sd	s1,-520(s0)
    800052ae:	bfd9                	j	80005284 <exec+0x37a>
    800052b0:	de943c23          	sd	s1,-520(s0)
    800052b4:	bfc1                	j	80005284 <exec+0x37a>
  sz = sz1;
    800052b6:	89d2                	mv	s3,s4
    800052b8:	b58d                	j	8000511a <exec+0x210>
    800052ba:	89d2                	mv	s3,s4
    800052bc:	bdb9                	j	8000511a <exec+0x210>

00000000800052be <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052be:	7179                	addi	sp,sp,-48
    800052c0:	f406                	sd	ra,40(sp)
    800052c2:	f022                	sd	s0,32(sp)
    800052c4:	ec26                	sd	s1,24(sp)
    800052c6:	e84a                	sd	s2,16(sp)
    800052c8:	1800                	addi	s0,sp,48
    800052ca:	892e                	mv	s2,a1
    800052cc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800052ce:	fdc40593          	addi	a1,s0,-36
    800052d2:	ffffe097          	auipc	ra,0xffffe
    800052d6:	a70080e7          	jalr	-1424(ra) # 80002d42 <argint>
    800052da:	04054163          	bltz	a0,8000531c <argfd+0x5e>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052de:	fdc42703          	lw	a4,-36(s0)
    800052e2:	47bd                	li	a5,15
    800052e4:	02e7ee63          	bltu	a5,a4,80005320 <argfd+0x62>
    800052e8:	ffffc097          	auipc	ra,0xffffc
    800052ec:	792080e7          	jalr	1938(ra) # 80001a7a <myproc>
    800052f0:	fdc42703          	lw	a4,-36(s0)
    800052f4:	00371793          	slli	a5,a4,0x3
    800052f8:	0d078793          	addi	a5,a5,208
    800052fc:	953e                	add	a0,a0,a5
    800052fe:	611c                	ld	a5,0(a0)
    80005300:	c395                	beqz	a5,80005324 <argfd+0x66>
    return -1;
  if(pfd)
    80005302:	00090463          	beqz	s2,8000530a <argfd+0x4c>
    *pfd = fd;
    80005306:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000530a:	4501                	li	a0,0
  if(pf)
    8000530c:	c091                	beqz	s1,80005310 <argfd+0x52>
    *pf = f;
    8000530e:	e09c                	sd	a5,0(s1)
}
    80005310:	70a2                	ld	ra,40(sp)
    80005312:	7402                	ld	s0,32(sp)
    80005314:	64e2                	ld	s1,24(sp)
    80005316:	6942                	ld	s2,16(sp)
    80005318:	6145                	addi	sp,sp,48
    8000531a:	8082                	ret
    return -1;
    8000531c:	557d                	li	a0,-1
    8000531e:	bfcd                	j	80005310 <argfd+0x52>
    return -1;
    80005320:	557d                	li	a0,-1
    80005322:	b7fd                	j	80005310 <argfd+0x52>
    80005324:	557d                	li	a0,-1
    80005326:	b7ed                	j	80005310 <argfd+0x52>

0000000080005328 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005328:	1101                	addi	sp,sp,-32
    8000532a:	ec06                	sd	ra,24(sp)
    8000532c:	e822                	sd	s0,16(sp)
    8000532e:	e426                	sd	s1,8(sp)
    80005330:	1000                	addi	s0,sp,32
    80005332:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005334:	ffffc097          	auipc	ra,0xffffc
    80005338:	746080e7          	jalr	1862(ra) # 80001a7a <myproc>
    8000533c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000533e:	0d050793          	addi	a5,a0,208
    80005342:	4501                	li	a0,0
    80005344:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005346:	6398                	ld	a4,0(a5)
    80005348:	cb19                	beqz	a4,8000535e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000534a:	2505                	addiw	a0,a0,1
    8000534c:	07a1                	addi	a5,a5,8
    8000534e:	fed51ce3          	bne	a0,a3,80005346 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005352:	557d                	li	a0,-1
}
    80005354:	60e2                	ld	ra,24(sp)
    80005356:	6442                	ld	s0,16(sp)
    80005358:	64a2                	ld	s1,8(sp)
    8000535a:	6105                	addi	sp,sp,32
    8000535c:	8082                	ret
      p->ofile[fd] = f;
    8000535e:	00351793          	slli	a5,a0,0x3
    80005362:	0d078793          	addi	a5,a5,208
    80005366:	963e                	add	a2,a2,a5
    80005368:	e204                	sd	s1,0(a2)
      return fd;
    8000536a:	b7ed                	j	80005354 <fdalloc+0x2c>

000000008000536c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000536c:	715d                	addi	sp,sp,-80
    8000536e:	e486                	sd	ra,72(sp)
    80005370:	e0a2                	sd	s0,64(sp)
    80005372:	fc26                	sd	s1,56(sp)
    80005374:	f84a                	sd	s2,48(sp)
    80005376:	f44e                	sd	s3,40(sp)
    80005378:	f052                	sd	s4,32(sp)
    8000537a:	ec56                	sd	s5,24(sp)
    8000537c:	0880                	addi	s0,sp,80
    8000537e:	89ae                	mv	s3,a1
    80005380:	8a32                	mv	s4,a2
    80005382:	8ab6                	mv	s5,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005384:	fb040593          	addi	a1,s0,-80
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	dca080e7          	jalr	-566(ra) # 80004152 <nameiparent>
    80005390:	892a                	mv	s2,a0
    80005392:	12050d63          	beqz	a0,800054cc <create+0x160>
    return 0;

  ilock(dp);
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	5ac080e7          	jalr	1452(ra) # 80003942 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000539e:	4601                	li	a2,0
    800053a0:	fb040593          	addi	a1,s0,-80
    800053a4:	854a                	mv	a0,s2
    800053a6:	fffff097          	auipc	ra,0xfffff
    800053aa:	a8a080e7          	jalr	-1398(ra) # 80003e30 <dirlookup>
    800053ae:	84aa                	mv	s1,a0
    800053b0:	c539                	beqz	a0,800053fe <create+0x92>
    iunlockput(dp);
    800053b2:	854a                	mv	a0,s2
    800053b4:	ffffe097          	auipc	ra,0xffffe
    800053b8:	7f6080e7          	jalr	2038(ra) # 80003baa <iunlockput>
    ilock(ip);
    800053bc:	8526                	mv	a0,s1
    800053be:	ffffe097          	auipc	ra,0xffffe
    800053c2:	584080e7          	jalr	1412(ra) # 80003942 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053c6:	4789                	li	a5,2
    800053c8:	02f99463          	bne	s3,a5,800053f0 <create+0x84>
    800053cc:	0444d783          	lhu	a5,68(s1)
    800053d0:	37f9                	addiw	a5,a5,-2
    800053d2:	17c2                	slli	a5,a5,0x30
    800053d4:	93c1                	srli	a5,a5,0x30
    800053d6:	4705                	li	a4,1
    800053d8:	00f76c63          	bltu	a4,a5,800053f0 <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800053dc:	8526                	mv	a0,s1
    800053de:	60a6                	ld	ra,72(sp)
    800053e0:	6406                	ld	s0,64(sp)
    800053e2:	74e2                	ld	s1,56(sp)
    800053e4:	7942                	ld	s2,48(sp)
    800053e6:	79a2                	ld	s3,40(sp)
    800053e8:	7a02                	ld	s4,32(sp)
    800053ea:	6ae2                	ld	s5,24(sp)
    800053ec:	6161                	addi	sp,sp,80
    800053ee:	8082                	ret
    iunlockput(ip);
    800053f0:	8526                	mv	a0,s1
    800053f2:	ffffe097          	auipc	ra,0xffffe
    800053f6:	7b8080e7          	jalr	1976(ra) # 80003baa <iunlockput>
    return 0;
    800053fa:	4481                	li	s1,0
    800053fc:	b7c5                	j	800053dc <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    800053fe:	85ce                	mv	a1,s3
    80005400:	00092503          	lw	a0,0(s2)
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	3aa080e7          	jalr	938(ra) # 800037ae <ialloc>
    8000540c:	84aa                	mv	s1,a0
    8000540e:	c521                	beqz	a0,80005456 <create+0xea>
  ilock(ip);
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	532080e7          	jalr	1330(ra) # 80003942 <ilock>
  ip->major = major;
    80005418:	05449323          	sh	s4,70(s1)
  ip->minor = minor;
    8000541c:	05549423          	sh	s5,72(s1)
  ip->nlink = 1;
    80005420:	4785                	li	a5,1
    80005422:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005426:	8526                	mv	a0,s1
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	44e080e7          	jalr	1102(ra) # 80003876 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005430:	4705                	li	a4,1
    80005432:	02e98a63          	beq	s3,a4,80005466 <create+0xfa>
  if(dirlink(dp, name, ip->inum) < 0)
    80005436:	40d0                	lw	a2,4(s1)
    80005438:	fb040593          	addi	a1,s0,-80
    8000543c:	854a                	mv	a0,s2
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	c20080e7          	jalr	-992(ra) # 8000405e <dirlink>
    80005446:	06054b63          	bltz	a0,800054bc <create+0x150>
  iunlockput(dp);
    8000544a:	854a                	mv	a0,s2
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	75e080e7          	jalr	1886(ra) # 80003baa <iunlockput>
  return ip;
    80005454:	b761                	j	800053dc <create+0x70>
    panic("create: ialloc");
    80005456:	00003517          	auipc	a0,0x3
    8000545a:	19a50513          	addi	a0,a0,410 # 800085f0 <etext+0x5f0>
    8000545e:	ffffb097          	auipc	ra,0xffffb
    80005462:	0f8080e7          	jalr	248(ra) # 80000556 <panic>
    dp->nlink++;  // for ".."
    80005466:	04a95783          	lhu	a5,74(s2)
    8000546a:	2785                	addiw	a5,a5,1
    8000546c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005470:	854a                	mv	a0,s2
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	404080e7          	jalr	1028(ra) # 80003876 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000547a:	40d0                	lw	a2,4(s1)
    8000547c:	00003597          	auipc	a1,0x3
    80005480:	18458593          	addi	a1,a1,388 # 80008600 <etext+0x600>
    80005484:	8526                	mv	a0,s1
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	bd8080e7          	jalr	-1064(ra) # 8000405e <dirlink>
    8000548e:	00054f63          	bltz	a0,800054ac <create+0x140>
    80005492:	00492603          	lw	a2,4(s2)
    80005496:	00003597          	auipc	a1,0x3
    8000549a:	17258593          	addi	a1,a1,370 # 80008608 <etext+0x608>
    8000549e:	8526                	mv	a0,s1
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	bbe080e7          	jalr	-1090(ra) # 8000405e <dirlink>
    800054a8:	f80557e3          	bgez	a0,80005436 <create+0xca>
      panic("create dots");
    800054ac:	00003517          	auipc	a0,0x3
    800054b0:	16450513          	addi	a0,a0,356 # 80008610 <etext+0x610>
    800054b4:	ffffb097          	auipc	ra,0xffffb
    800054b8:	0a2080e7          	jalr	162(ra) # 80000556 <panic>
    panic("create: dirlink");
    800054bc:	00003517          	auipc	a0,0x3
    800054c0:	16450513          	addi	a0,a0,356 # 80008620 <etext+0x620>
    800054c4:	ffffb097          	auipc	ra,0xffffb
    800054c8:	092080e7          	jalr	146(ra) # 80000556 <panic>
    return 0;
    800054cc:	84aa                	mv	s1,a0
    800054ce:	b739                	j	800053dc <create+0x70>

00000000800054d0 <sys_dup>:
{
    800054d0:	7179                	addi	sp,sp,-48
    800054d2:	f406                	sd	ra,40(sp)
    800054d4:	f022                	sd	s0,32(sp)
    800054d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054d8:	fd840613          	addi	a2,s0,-40
    800054dc:	4581                	li	a1,0
    800054de:	4501                	li	a0,0
    800054e0:	00000097          	auipc	ra,0x0
    800054e4:	dde080e7          	jalr	-546(ra) # 800052be <argfd>
    return -1;
    800054e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054ea:	02054763          	bltz	a0,80005518 <sys_dup+0x48>
    800054ee:	ec26                	sd	s1,24(sp)
    800054f0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800054f2:	fd843483          	ld	s1,-40(s0)
    800054f6:	8526                	mv	a0,s1
    800054f8:	00000097          	auipc	ra,0x0
    800054fc:	e30080e7          	jalr	-464(ra) # 80005328 <fdalloc>
    80005500:	892a                	mv	s2,a0
    return -1;
    80005502:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005504:	00054f63          	bltz	a0,80005522 <sys_dup+0x52>
  filedup(f);
    80005508:	8526                	mv	a0,s1
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	2c0080e7          	jalr	704(ra) # 800047ca <filedup>
  return fd;
    80005512:	87ca                	mv	a5,s2
    80005514:	64e2                	ld	s1,24(sp)
    80005516:	6942                	ld	s2,16(sp)
}
    80005518:	853e                	mv	a0,a5
    8000551a:	70a2                	ld	ra,40(sp)
    8000551c:	7402                	ld	s0,32(sp)
    8000551e:	6145                	addi	sp,sp,48
    80005520:	8082                	ret
    80005522:	64e2                	ld	s1,24(sp)
    80005524:	6942                	ld	s2,16(sp)
    80005526:	bfcd                	j	80005518 <sys_dup+0x48>

0000000080005528 <sys_read>:
{
    80005528:	7179                	addi	sp,sp,-48
    8000552a:	f406                	sd	ra,40(sp)
    8000552c:	f022                	sd	s0,32(sp)
    8000552e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005530:	fe840613          	addi	a2,s0,-24
    80005534:	4581                	li	a1,0
    80005536:	4501                	li	a0,0
    80005538:	00000097          	auipc	ra,0x0
    8000553c:	d86080e7          	jalr	-634(ra) # 800052be <argfd>
    return -1;
    80005540:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005542:	04054163          	bltz	a0,80005584 <sys_read+0x5c>
    80005546:	fe440593          	addi	a1,s0,-28
    8000554a:	4509                	li	a0,2
    8000554c:	ffffd097          	auipc	ra,0xffffd
    80005550:	7f6080e7          	jalr	2038(ra) # 80002d42 <argint>
    return -1;
    80005554:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005556:	02054763          	bltz	a0,80005584 <sys_read+0x5c>
    8000555a:	fd840593          	addi	a1,s0,-40
    8000555e:	4505                	li	a0,1
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	804080e7          	jalr	-2044(ra) # 80002d64 <argaddr>
    return -1;
    80005568:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000556a:	00054d63          	bltz	a0,80005584 <sys_read+0x5c>
  return fileread(f, p, n);
    8000556e:	fe442603          	lw	a2,-28(s0)
    80005572:	fd843583          	ld	a1,-40(s0)
    80005576:	fe843503          	ld	a0,-24(s0)
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	3fa080e7          	jalr	1018(ra) # 80004974 <fileread>
    80005582:	87aa                	mv	a5,a0
}
    80005584:	853e                	mv	a0,a5
    80005586:	70a2                	ld	ra,40(sp)
    80005588:	7402                	ld	s0,32(sp)
    8000558a:	6145                	addi	sp,sp,48
    8000558c:	8082                	ret

000000008000558e <sys_write>:
{
    8000558e:	7179                	addi	sp,sp,-48
    80005590:	f406                	sd	ra,40(sp)
    80005592:	f022                	sd	s0,32(sp)
    80005594:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005596:	fe840613          	addi	a2,s0,-24
    8000559a:	4581                	li	a1,0
    8000559c:	4501                	li	a0,0
    8000559e:	00000097          	auipc	ra,0x0
    800055a2:	d20080e7          	jalr	-736(ra) # 800052be <argfd>
    return -1;
    800055a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055a8:	04054163          	bltz	a0,800055ea <sys_write+0x5c>
    800055ac:	fe440593          	addi	a1,s0,-28
    800055b0:	4509                	li	a0,2
    800055b2:	ffffd097          	auipc	ra,0xffffd
    800055b6:	790080e7          	jalr	1936(ra) # 80002d42 <argint>
    return -1;
    800055ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055bc:	02054763          	bltz	a0,800055ea <sys_write+0x5c>
    800055c0:	fd840593          	addi	a1,s0,-40
    800055c4:	4505                	li	a0,1
    800055c6:	ffffd097          	auipc	ra,0xffffd
    800055ca:	79e080e7          	jalr	1950(ra) # 80002d64 <argaddr>
    return -1;
    800055ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055d0:	00054d63          	bltz	a0,800055ea <sys_write+0x5c>
  return filewrite(f, p, n);
    800055d4:	fe442603          	lw	a2,-28(s0)
    800055d8:	fd843583          	ld	a1,-40(s0)
    800055dc:	fe843503          	ld	a0,-24(s0)
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	46c080e7          	jalr	1132(ra) # 80004a4c <filewrite>
    800055e8:	87aa                	mv	a5,a0
}
    800055ea:	853e                	mv	a0,a5
    800055ec:	70a2                	ld	ra,40(sp)
    800055ee:	7402                	ld	s0,32(sp)
    800055f0:	6145                	addi	sp,sp,48
    800055f2:	8082                	ret

00000000800055f4 <sys_close>:
{
    800055f4:	1101                	addi	sp,sp,-32
    800055f6:	ec06                	sd	ra,24(sp)
    800055f8:	e822                	sd	s0,16(sp)
    800055fa:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055fc:	fe040613          	addi	a2,s0,-32
    80005600:	fec40593          	addi	a1,s0,-20
    80005604:	4501                	li	a0,0
    80005606:	00000097          	auipc	ra,0x0
    8000560a:	cb8080e7          	jalr	-840(ra) # 800052be <argfd>
    return -1;
    8000560e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005610:	02054563          	bltz	a0,8000563a <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005614:	ffffc097          	auipc	ra,0xffffc
    80005618:	466080e7          	jalr	1126(ra) # 80001a7a <myproc>
    8000561c:	fec42783          	lw	a5,-20(s0)
    80005620:	078e                	slli	a5,a5,0x3
    80005622:	0d078793          	addi	a5,a5,208
    80005626:	953e                	add	a0,a0,a5
    80005628:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000562c:	fe043503          	ld	a0,-32(s0)
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	1ec080e7          	jalr	492(ra) # 8000481c <fileclose>
  return 0;
    80005638:	4781                	li	a5,0
}
    8000563a:	853e                	mv	a0,a5
    8000563c:	60e2                	ld	ra,24(sp)
    8000563e:	6442                	ld	s0,16(sp)
    80005640:	6105                	addi	sp,sp,32
    80005642:	8082                	ret

0000000080005644 <sys_fstat>:
{
    80005644:	1101                	addi	sp,sp,-32
    80005646:	ec06                	sd	ra,24(sp)
    80005648:	e822                	sd	s0,16(sp)
    8000564a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000564c:	fe840613          	addi	a2,s0,-24
    80005650:	4581                	li	a1,0
    80005652:	4501                	li	a0,0
    80005654:	00000097          	auipc	ra,0x0
    80005658:	c6a080e7          	jalr	-918(ra) # 800052be <argfd>
    return -1;
    8000565c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000565e:	02054563          	bltz	a0,80005688 <sys_fstat+0x44>
    80005662:	fe040593          	addi	a1,s0,-32
    80005666:	4505                	li	a0,1
    80005668:	ffffd097          	auipc	ra,0xffffd
    8000566c:	6fc080e7          	jalr	1788(ra) # 80002d64 <argaddr>
    return -1;
    80005670:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005672:	00054b63          	bltz	a0,80005688 <sys_fstat+0x44>
  return filestat(f, st);
    80005676:	fe043583          	ld	a1,-32(s0)
    8000567a:	fe843503          	ld	a0,-24(s0)
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	280080e7          	jalr	640(ra) # 800048fe <filestat>
    80005686:	87aa                	mv	a5,a0
}
    80005688:	853e                	mv	a0,a5
    8000568a:	60e2                	ld	ra,24(sp)
    8000568c:	6442                	ld	s0,16(sp)
    8000568e:	6105                	addi	sp,sp,32
    80005690:	8082                	ret

0000000080005692 <sys_link>:
{
    80005692:	7169                	addi	sp,sp,-304
    80005694:	f606                	sd	ra,296(sp)
    80005696:	f222                	sd	s0,288(sp)
    80005698:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000569a:	08000613          	li	a2,128
    8000569e:	ed040593          	addi	a1,s0,-304
    800056a2:	4501                	li	a0,0
    800056a4:	ffffd097          	auipc	ra,0xffffd
    800056a8:	6e2080e7          	jalr	1762(ra) # 80002d86 <argstr>
    return -1;
    800056ac:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056ae:	12054663          	bltz	a0,800057da <sys_link+0x148>
    800056b2:	08000613          	li	a2,128
    800056b6:	f5040593          	addi	a1,s0,-176
    800056ba:	4505                	li	a0,1
    800056bc:	ffffd097          	auipc	ra,0xffffd
    800056c0:	6ca080e7          	jalr	1738(ra) # 80002d86 <argstr>
    return -1;
    800056c4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056c6:	10054a63          	bltz	a0,800057da <sys_link+0x148>
    800056ca:	ee26                	sd	s1,280(sp)
  begin_op();
    800056cc:	fffff097          	auipc	ra,0xfffff
    800056d0:	c6e080e7          	jalr	-914(ra) # 8000433a <begin_op>
  if((ip = namei(old)) == 0){
    800056d4:	ed040513          	addi	a0,s0,-304
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	a5c080e7          	jalr	-1444(ra) # 80004134 <namei>
    800056e0:	84aa                	mv	s1,a0
    800056e2:	c949                	beqz	a0,80005774 <sys_link+0xe2>
  ilock(ip);
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	25e080e7          	jalr	606(ra) # 80003942 <ilock>
  if(ip->type == T_DIR){
    800056ec:	04449703          	lh	a4,68(s1)
    800056f0:	4785                	li	a5,1
    800056f2:	08f70863          	beq	a4,a5,80005782 <sys_link+0xf0>
    800056f6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800056f8:	04a4d783          	lhu	a5,74(s1)
    800056fc:	2785                	addiw	a5,a5,1
    800056fe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	172080e7          	jalr	370(ra) # 80003876 <iupdate>
  iunlock(ip);
    8000570c:	8526                	mv	a0,s1
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	2fa080e7          	jalr	762(ra) # 80003a08 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005716:	fd040593          	addi	a1,s0,-48
    8000571a:	f5040513          	addi	a0,s0,-176
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	a34080e7          	jalr	-1484(ra) # 80004152 <nameiparent>
    80005726:	892a                	mv	s2,a0
    80005728:	cd35                	beqz	a0,800057a4 <sys_link+0x112>
  ilock(dp);
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	218080e7          	jalr	536(ra) # 80003942 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005732:	854a                	mv	a0,s2
    80005734:	00092703          	lw	a4,0(s2)
    80005738:	409c                	lw	a5,0(s1)
    8000573a:	06f71063          	bne	a4,a5,8000579a <sys_link+0x108>
    8000573e:	40d0                	lw	a2,4(s1)
    80005740:	fd040593          	addi	a1,s0,-48
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	91a080e7          	jalr	-1766(ra) # 8000405e <dirlink>
    8000574c:	04054763          	bltz	a0,8000579a <sys_link+0x108>
  iunlockput(dp);
    80005750:	854a                	mv	a0,s2
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	458080e7          	jalr	1112(ra) # 80003baa <iunlockput>
  iput(ip);
    8000575a:	8526                	mv	a0,s1
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	3a4080e7          	jalr	932(ra) # 80003b00 <iput>
  end_op();
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	c56080e7          	jalr	-938(ra) # 800043ba <end_op>
  return 0;
    8000576c:	4781                	li	a5,0
    8000576e:	64f2                	ld	s1,280(sp)
    80005770:	6952                	ld	s2,272(sp)
    80005772:	a0a5                	j	800057da <sys_link+0x148>
    end_op();
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	c46080e7          	jalr	-954(ra) # 800043ba <end_op>
    return -1;
    8000577c:	57fd                	li	a5,-1
    8000577e:	64f2                	ld	s1,280(sp)
    80005780:	a8a9                	j	800057da <sys_link+0x148>
    iunlockput(ip);
    80005782:	8526                	mv	a0,s1
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	426080e7          	jalr	1062(ra) # 80003baa <iunlockput>
    end_op();
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	c2e080e7          	jalr	-978(ra) # 800043ba <end_op>
    return -1;
    80005794:	57fd                	li	a5,-1
    80005796:	64f2                	ld	s1,280(sp)
    80005798:	a089                	j	800057da <sys_link+0x148>
    iunlockput(dp);
    8000579a:	854a                	mv	a0,s2
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	40e080e7          	jalr	1038(ra) # 80003baa <iunlockput>
  ilock(ip);
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	19c080e7          	jalr	412(ra) # 80003942 <ilock>
  ip->nlink--;
    800057ae:	04a4d783          	lhu	a5,74(s1)
    800057b2:	37fd                	addiw	a5,a5,-1
    800057b4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	0bc080e7          	jalr	188(ra) # 80003876 <iupdate>
  iunlockput(ip);
    800057c2:	8526                	mv	a0,s1
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	3e6080e7          	jalr	998(ra) # 80003baa <iunlockput>
  end_op();
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	bee080e7          	jalr	-1042(ra) # 800043ba <end_op>
  return -1;
    800057d4:	57fd                	li	a5,-1
    800057d6:	64f2                	ld	s1,280(sp)
    800057d8:	6952                	ld	s2,272(sp)
}
    800057da:	853e                	mv	a0,a5
    800057dc:	70b2                	ld	ra,296(sp)
    800057de:	7412                	ld	s0,288(sp)
    800057e0:	6155                	addi	sp,sp,304
    800057e2:	8082                	ret

00000000800057e4 <sys_unlink>:
{
    800057e4:	7151                	addi	sp,sp,-240
    800057e6:	f586                	sd	ra,232(sp)
    800057e8:	f1a2                	sd	s0,224(sp)
    800057ea:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057ec:	08000613          	li	a2,128
    800057f0:	f3040593          	addi	a1,s0,-208
    800057f4:	4501                	li	a0,0
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	590080e7          	jalr	1424(ra) # 80002d86 <argstr>
    800057fe:	1a054763          	bltz	a0,800059ac <sys_unlink+0x1c8>
    80005802:	eda6                	sd	s1,216(sp)
  begin_op();
    80005804:	fffff097          	auipc	ra,0xfffff
    80005808:	b36080e7          	jalr	-1226(ra) # 8000433a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000580c:	fb040593          	addi	a1,s0,-80
    80005810:	f3040513          	addi	a0,s0,-208
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	93e080e7          	jalr	-1730(ra) # 80004152 <nameiparent>
    8000581c:	84aa                	mv	s1,a0
    8000581e:	c165                	beqz	a0,800058fe <sys_unlink+0x11a>
  ilock(dp);
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	122080e7          	jalr	290(ra) # 80003942 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005828:	00003597          	auipc	a1,0x3
    8000582c:	dd858593          	addi	a1,a1,-552 # 80008600 <etext+0x600>
    80005830:	fb040513          	addi	a0,s0,-80
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	5e2080e7          	jalr	1506(ra) # 80003e16 <namecmp>
    8000583c:	14050963          	beqz	a0,8000598e <sys_unlink+0x1aa>
    80005840:	00003597          	auipc	a1,0x3
    80005844:	dc858593          	addi	a1,a1,-568 # 80008608 <etext+0x608>
    80005848:	fb040513          	addi	a0,s0,-80
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	5ca080e7          	jalr	1482(ra) # 80003e16 <namecmp>
    80005854:	12050d63          	beqz	a0,8000598e <sys_unlink+0x1aa>
    80005858:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000585a:	f2c40613          	addi	a2,s0,-212
    8000585e:	fb040593          	addi	a1,s0,-80
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	5cc080e7          	jalr	1484(ra) # 80003e30 <dirlookup>
    8000586c:	892a                	mv	s2,a0
    8000586e:	10050f63          	beqz	a0,8000598c <sys_unlink+0x1a8>
    80005872:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	0ce080e7          	jalr	206(ra) # 80003942 <ilock>
  if(ip->nlink < 1)
    8000587c:	04a91783          	lh	a5,74(s2)
    80005880:	08f05663          	blez	a5,8000590c <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005884:	04491703          	lh	a4,68(s2)
    80005888:	4785                	li	a5,1
    8000588a:	08f70963          	beq	a4,a5,8000591c <sys_unlink+0x138>
  memset(&de, 0, sizeof(de));
    8000588e:	fc040993          	addi	s3,s0,-64
    80005892:	4641                	li	a2,16
    80005894:	4581                	li	a1,0
    80005896:	854e                	mv	a0,s3
    80005898:	ffffb097          	auipc	ra,0xffffb
    8000589c:	4b4080e7          	jalr	1204(ra) # 80000d4c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058a0:	4741                	li	a4,16
    800058a2:	f2c42683          	lw	a3,-212(s0)
    800058a6:	864e                	mv	a2,s3
    800058a8:	4581                	li	a1,0
    800058aa:	8526                	mv	a0,s1
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	44e080e7          	jalr	1102(ra) # 80003cfa <writei>
    800058b4:	47c1                	li	a5,16
    800058b6:	0af51863          	bne	a0,a5,80005966 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    800058ba:	04491703          	lh	a4,68(s2)
    800058be:	4785                	li	a5,1
    800058c0:	0af70b63          	beq	a4,a5,80005976 <sys_unlink+0x192>
  iunlockput(dp);
    800058c4:	8526                	mv	a0,s1
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	2e4080e7          	jalr	740(ra) # 80003baa <iunlockput>
  ip->nlink--;
    800058ce:	04a95783          	lhu	a5,74(s2)
    800058d2:	37fd                	addiw	a5,a5,-1
    800058d4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058d8:	854a                	mv	a0,s2
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	f9c080e7          	jalr	-100(ra) # 80003876 <iupdate>
  iunlockput(ip);
    800058e2:	854a                	mv	a0,s2
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	2c6080e7          	jalr	710(ra) # 80003baa <iunlockput>
  end_op();
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	ace080e7          	jalr	-1330(ra) # 800043ba <end_op>
  return 0;
    800058f4:	4501                	li	a0,0
    800058f6:	64ee                	ld	s1,216(sp)
    800058f8:	694e                	ld	s2,208(sp)
    800058fa:	69ae                	ld	s3,200(sp)
    800058fc:	a065                	j	800059a4 <sys_unlink+0x1c0>
    end_op();
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	abc080e7          	jalr	-1348(ra) # 800043ba <end_op>
    return -1;
    80005906:	557d                	li	a0,-1
    80005908:	64ee                	ld	s1,216(sp)
    8000590a:	a869                	j	800059a4 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    8000590c:	00003517          	auipc	a0,0x3
    80005910:	d2450513          	addi	a0,a0,-732 # 80008630 <etext+0x630>
    80005914:	ffffb097          	auipc	ra,0xffffb
    80005918:	c42080e7          	jalr	-958(ra) # 80000556 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000591c:	04c92703          	lw	a4,76(s2)
    80005920:	02000793          	li	a5,32
    80005924:	f6e7f5e3          	bgeu	a5,a4,8000588e <sys_unlink+0xaa>
    80005928:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000592a:	4741                	li	a4,16
    8000592c:	86ce                	mv	a3,s3
    8000592e:	f1840613          	addi	a2,s0,-232
    80005932:	4581                	li	a1,0
    80005934:	854a                	mv	a0,s2
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	2ca080e7          	jalr	714(ra) # 80003c00 <readi>
    8000593e:	47c1                	li	a5,16
    80005940:	00f51b63          	bne	a0,a5,80005956 <sys_unlink+0x172>
    if(de.inum != 0)
    80005944:	f1845783          	lhu	a5,-232(s0)
    80005948:	e7a5                	bnez	a5,800059b0 <sys_unlink+0x1cc>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000594a:	29c1                	addiw	s3,s3,16
    8000594c:	04c92783          	lw	a5,76(s2)
    80005950:	fcf9ede3          	bltu	s3,a5,8000592a <sys_unlink+0x146>
    80005954:	bf2d                	j	8000588e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005956:	00003517          	auipc	a0,0x3
    8000595a:	cf250513          	addi	a0,a0,-782 # 80008648 <etext+0x648>
    8000595e:	ffffb097          	auipc	ra,0xffffb
    80005962:	bf8080e7          	jalr	-1032(ra) # 80000556 <panic>
    panic("unlink: writei");
    80005966:	00003517          	auipc	a0,0x3
    8000596a:	cfa50513          	addi	a0,a0,-774 # 80008660 <etext+0x660>
    8000596e:	ffffb097          	auipc	ra,0xffffb
    80005972:	be8080e7          	jalr	-1048(ra) # 80000556 <panic>
    dp->nlink--;
    80005976:	04a4d783          	lhu	a5,74(s1)
    8000597a:	37fd                	addiw	a5,a5,-1
    8000597c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005980:	8526                	mv	a0,s1
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	ef4080e7          	jalr	-268(ra) # 80003876 <iupdate>
    8000598a:	bf2d                	j	800058c4 <sys_unlink+0xe0>
    8000598c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000598e:	8526                	mv	a0,s1
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	21a080e7          	jalr	538(ra) # 80003baa <iunlockput>
  end_op();
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	a22080e7          	jalr	-1502(ra) # 800043ba <end_op>
  return -1;
    800059a0:	557d                	li	a0,-1
    800059a2:	64ee                	ld	s1,216(sp)
}
    800059a4:	70ae                	ld	ra,232(sp)
    800059a6:	740e                	ld	s0,224(sp)
    800059a8:	616d                	addi	sp,sp,240
    800059aa:	8082                	ret
    return -1;
    800059ac:	557d                	li	a0,-1
    800059ae:	bfdd                	j	800059a4 <sys_unlink+0x1c0>
    iunlockput(ip);
    800059b0:	854a                	mv	a0,s2
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	1f8080e7          	jalr	504(ra) # 80003baa <iunlockput>
    goto bad;
    800059ba:	694e                	ld	s2,208(sp)
    800059bc:	69ae                	ld	s3,200(sp)
    800059be:	bfc1                	j	8000598e <sys_unlink+0x1aa>

00000000800059c0 <sys_open>:

uint64
sys_open(void)
{
    800059c0:	7131                	addi	sp,sp,-192
    800059c2:	fd06                	sd	ra,184(sp)
    800059c4:	f922                	sd	s0,176(sp)
    800059c6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059c8:	08000613          	li	a2,128
    800059cc:	f5040593          	addi	a1,s0,-176
    800059d0:	4501                	li	a0,0
    800059d2:	ffffd097          	auipc	ra,0xffffd
    800059d6:	3b4080e7          	jalr	948(ra) # 80002d86 <argstr>
    return -1;
    800059da:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059dc:	0c054963          	bltz	a0,80005aae <sys_open+0xee>
    800059e0:	f4c40593          	addi	a1,s0,-180
    800059e4:	4505                	li	a0,1
    800059e6:	ffffd097          	auipc	ra,0xffffd
    800059ea:	35c080e7          	jalr	860(ra) # 80002d42 <argint>
    return -1;
    800059ee:	57fd                	li	a5,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059f0:	0a054f63          	bltz	a0,80005aae <sys_open+0xee>
    800059f4:	f526                	sd	s1,168(sp)

  begin_op();
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	944080e7          	jalr	-1724(ra) # 8000433a <begin_op>

  if(omode & O_CREATE){
    800059fe:	f4c42783          	lw	a5,-180(s0)
    80005a02:	2007f793          	andi	a5,a5,512
    80005a06:	c3e1                	beqz	a5,80005ac6 <sys_open+0x106>
    ip = create(path, T_FILE, 0, 0);
    80005a08:	4681                	li	a3,0
    80005a0a:	4601                	li	a2,0
    80005a0c:	4589                	li	a1,2
    80005a0e:	f5040513          	addi	a0,s0,-176
    80005a12:	00000097          	auipc	ra,0x0
    80005a16:	95a080e7          	jalr	-1702(ra) # 8000536c <create>
    80005a1a:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a1c:	cd51                	beqz	a0,80005ab8 <sys_open+0xf8>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a1e:	04449703          	lh	a4,68(s1)
    80005a22:	478d                	li	a5,3
    80005a24:	00f71763          	bne	a4,a5,80005a32 <sys_open+0x72>
    80005a28:	0464d703          	lhu	a4,70(s1)
    80005a2c:	47a5                	li	a5,9
    80005a2e:	0ee7e363          	bltu	a5,a4,80005b14 <sys_open+0x154>
    80005a32:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	d2c080e7          	jalr	-724(ra) # 80004760 <filealloc>
    80005a3c:	892a                	mv	s2,a0
    80005a3e:	cd6d                	beqz	a0,80005b38 <sys_open+0x178>
    80005a40:	ed4e                	sd	s3,152(sp)
    80005a42:	00000097          	auipc	ra,0x0
    80005a46:	8e6080e7          	jalr	-1818(ra) # 80005328 <fdalloc>
    80005a4a:	89aa                	mv	s3,a0
    80005a4c:	0e054063          	bltz	a0,80005b2c <sys_open+0x16c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a50:	04449703          	lh	a4,68(s1)
    80005a54:	478d                	li	a5,3
    80005a56:	0ef70e63          	beq	a4,a5,80005b52 <sys_open+0x192>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a5a:	4789                	li	a5,2
    80005a5c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005a60:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005a64:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005a68:	f4c42783          	lw	a5,-180(s0)
    80005a6c:	0017f713          	andi	a4,a5,1
    80005a70:	00174713          	xori	a4,a4,1
    80005a74:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a78:	0037f713          	andi	a4,a5,3
    80005a7c:	00e03733          	snez	a4,a4
    80005a80:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a84:	4007f793          	andi	a5,a5,1024
    80005a88:	c791                	beqz	a5,80005a94 <sys_open+0xd4>
    80005a8a:	04449703          	lh	a4,68(s1)
    80005a8e:	4789                	li	a5,2
    80005a90:	0cf70863          	beq	a4,a5,80005b60 <sys_open+0x1a0>
    itrunc(ip);
  }

  iunlock(ip);
    80005a94:	8526                	mv	a0,s1
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	f72080e7          	jalr	-142(ra) # 80003a08 <iunlock>
  end_op();
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	91c080e7          	jalr	-1764(ra) # 800043ba <end_op>

  return fd;
    80005aa6:	87ce                	mv	a5,s3
    80005aa8:	74aa                	ld	s1,168(sp)
    80005aaa:	790a                	ld	s2,160(sp)
    80005aac:	69ea                	ld	s3,152(sp)
}
    80005aae:	853e                	mv	a0,a5
    80005ab0:	70ea                	ld	ra,184(sp)
    80005ab2:	744a                	ld	s0,176(sp)
    80005ab4:	6129                	addi	sp,sp,192
    80005ab6:	8082                	ret
      end_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	902080e7          	jalr	-1790(ra) # 800043ba <end_op>
      return -1;
    80005ac0:	57fd                	li	a5,-1
    80005ac2:	74aa                	ld	s1,168(sp)
    80005ac4:	b7ed                	j	80005aae <sys_open+0xee>
    if((ip = namei(path)) == 0){
    80005ac6:	f5040513          	addi	a0,s0,-176
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	66a080e7          	jalr	1642(ra) # 80004134 <namei>
    80005ad2:	84aa                	mv	s1,a0
    80005ad4:	c90d                	beqz	a0,80005b06 <sys_open+0x146>
    ilock(ip);
    80005ad6:	ffffe097          	auipc	ra,0xffffe
    80005ada:	e6c080e7          	jalr	-404(ra) # 80003942 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ade:	04449703          	lh	a4,68(s1)
    80005ae2:	4785                	li	a5,1
    80005ae4:	f2f71de3          	bne	a4,a5,80005a1e <sys_open+0x5e>
    80005ae8:	f4c42783          	lw	a5,-180(s0)
    80005aec:	d3b9                	beqz	a5,80005a32 <sys_open+0x72>
      iunlockput(ip);
    80005aee:	8526                	mv	a0,s1
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	0ba080e7          	jalr	186(ra) # 80003baa <iunlockput>
      end_op();
    80005af8:	fffff097          	auipc	ra,0xfffff
    80005afc:	8c2080e7          	jalr	-1854(ra) # 800043ba <end_op>
      return -1;
    80005b00:	57fd                	li	a5,-1
    80005b02:	74aa                	ld	s1,168(sp)
    80005b04:	b76d                	j	80005aae <sys_open+0xee>
      end_op();
    80005b06:	fffff097          	auipc	ra,0xfffff
    80005b0a:	8b4080e7          	jalr	-1868(ra) # 800043ba <end_op>
      return -1;
    80005b0e:	57fd                	li	a5,-1
    80005b10:	74aa                	ld	s1,168(sp)
    80005b12:	bf71                	j	80005aae <sys_open+0xee>
    iunlockput(ip);
    80005b14:	8526                	mv	a0,s1
    80005b16:	ffffe097          	auipc	ra,0xffffe
    80005b1a:	094080e7          	jalr	148(ra) # 80003baa <iunlockput>
    end_op();
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	89c080e7          	jalr	-1892(ra) # 800043ba <end_op>
    return -1;
    80005b26:	57fd                	li	a5,-1
    80005b28:	74aa                	ld	s1,168(sp)
    80005b2a:	b751                	j	80005aae <sys_open+0xee>
      fileclose(f);
    80005b2c:	854a                	mv	a0,s2
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	cee080e7          	jalr	-786(ra) # 8000481c <fileclose>
    80005b36:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005b38:	8526                	mv	a0,s1
    80005b3a:	ffffe097          	auipc	ra,0xffffe
    80005b3e:	070080e7          	jalr	112(ra) # 80003baa <iunlockput>
    end_op();
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	878080e7          	jalr	-1928(ra) # 800043ba <end_op>
    return -1;
    80005b4a:	57fd                	li	a5,-1
    80005b4c:	74aa                	ld	s1,168(sp)
    80005b4e:	790a                	ld	s2,160(sp)
    80005b50:	bfb9                	j	80005aae <sys_open+0xee>
    f->type = FD_DEVICE;
    80005b52:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005b56:	04649783          	lh	a5,70(s1)
    80005b5a:	02f91223          	sh	a5,36(s2)
    80005b5e:	b719                	j	80005a64 <sys_open+0xa4>
    itrunc(ip);
    80005b60:	8526                	mv	a0,s1
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	ef2080e7          	jalr	-270(ra) # 80003a54 <itrunc>
    80005b6a:	b72d                	j	80005a94 <sys_open+0xd4>

0000000080005b6c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b6c:	7175                	addi	sp,sp,-144
    80005b6e:	e506                	sd	ra,136(sp)
    80005b70:	e122                	sd	s0,128(sp)
    80005b72:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	7c6080e7          	jalr	1990(ra) # 8000433a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b7c:	08000613          	li	a2,128
    80005b80:	f7040593          	addi	a1,s0,-144
    80005b84:	4501                	li	a0,0
    80005b86:	ffffd097          	auipc	ra,0xffffd
    80005b8a:	200080e7          	jalr	512(ra) # 80002d86 <argstr>
    80005b8e:	02054963          	bltz	a0,80005bc0 <sys_mkdir+0x54>
    80005b92:	4681                	li	a3,0
    80005b94:	4601                	li	a2,0
    80005b96:	4585                	li	a1,1
    80005b98:	f7040513          	addi	a0,s0,-144
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	7d0080e7          	jalr	2000(ra) # 8000536c <create>
    80005ba4:	cd11                	beqz	a0,80005bc0 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	004080e7          	jalr	4(ra) # 80003baa <iunlockput>
  end_op();
    80005bae:	fffff097          	auipc	ra,0xfffff
    80005bb2:	80c080e7          	jalr	-2036(ra) # 800043ba <end_op>
  return 0;
    80005bb6:	4501                	li	a0,0
}
    80005bb8:	60aa                	ld	ra,136(sp)
    80005bba:	640a                	ld	s0,128(sp)
    80005bbc:	6149                	addi	sp,sp,144
    80005bbe:	8082                	ret
    end_op();
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	7fa080e7          	jalr	2042(ra) # 800043ba <end_op>
    return -1;
    80005bc8:	557d                	li	a0,-1
    80005bca:	b7fd                	j	80005bb8 <sys_mkdir+0x4c>

0000000080005bcc <sys_mknod>:

uint64
sys_mknod(void)
{
    80005bcc:	7135                	addi	sp,sp,-160
    80005bce:	ed06                	sd	ra,152(sp)
    80005bd0:	e922                	sd	s0,144(sp)
    80005bd2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	766080e7          	jalr	1894(ra) # 8000433a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bdc:	08000613          	li	a2,128
    80005be0:	f7040593          	addi	a1,s0,-144
    80005be4:	4501                	li	a0,0
    80005be6:	ffffd097          	auipc	ra,0xffffd
    80005bea:	1a0080e7          	jalr	416(ra) # 80002d86 <argstr>
    80005bee:	04054a63          	bltz	a0,80005c42 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005bf2:	f6c40593          	addi	a1,s0,-148
    80005bf6:	4505                	li	a0,1
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	14a080e7          	jalr	330(ra) # 80002d42 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c00:	04054163          	bltz	a0,80005c42 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c04:	f6840593          	addi	a1,s0,-152
    80005c08:	4509                	li	a0,2
    80005c0a:	ffffd097          	auipc	ra,0xffffd
    80005c0e:	138080e7          	jalr	312(ra) # 80002d42 <argint>
     argint(1, &major) < 0 ||
    80005c12:	02054863          	bltz	a0,80005c42 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c16:	f6841683          	lh	a3,-152(s0)
    80005c1a:	f6c41603          	lh	a2,-148(s0)
    80005c1e:	458d                	li	a1,3
    80005c20:	f7040513          	addi	a0,s0,-144
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	748080e7          	jalr	1864(ra) # 8000536c <create>
     argint(2, &minor) < 0 ||
    80005c2c:	c919                	beqz	a0,80005c42 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c2e:	ffffe097          	auipc	ra,0xffffe
    80005c32:	f7c080e7          	jalr	-132(ra) # 80003baa <iunlockput>
  end_op();
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	784080e7          	jalr	1924(ra) # 800043ba <end_op>
  return 0;
    80005c3e:	4501                	li	a0,0
    80005c40:	a031                	j	80005c4c <sys_mknod+0x80>
    end_op();
    80005c42:	ffffe097          	auipc	ra,0xffffe
    80005c46:	778080e7          	jalr	1912(ra) # 800043ba <end_op>
    return -1;
    80005c4a:	557d                	li	a0,-1
}
    80005c4c:	60ea                	ld	ra,152(sp)
    80005c4e:	644a                	ld	s0,144(sp)
    80005c50:	610d                	addi	sp,sp,160
    80005c52:	8082                	ret

0000000080005c54 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c54:	7135                	addi	sp,sp,-160
    80005c56:	ed06                	sd	ra,152(sp)
    80005c58:	e922                	sd	s0,144(sp)
    80005c5a:	e14a                	sd	s2,128(sp)
    80005c5c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c5e:	ffffc097          	auipc	ra,0xffffc
    80005c62:	e1c080e7          	jalr	-484(ra) # 80001a7a <myproc>
    80005c66:	892a                	mv	s2,a0
  
  begin_op();
    80005c68:	ffffe097          	auipc	ra,0xffffe
    80005c6c:	6d2080e7          	jalr	1746(ra) # 8000433a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c70:	08000613          	li	a2,128
    80005c74:	f6040593          	addi	a1,s0,-160
    80005c78:	4501                	li	a0,0
    80005c7a:	ffffd097          	auipc	ra,0xffffd
    80005c7e:	10c080e7          	jalr	268(ra) # 80002d86 <argstr>
    80005c82:	04054d63          	bltz	a0,80005cdc <sys_chdir+0x88>
    80005c86:	e526                	sd	s1,136(sp)
    80005c88:	f6040513          	addi	a0,s0,-160
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	4a8080e7          	jalr	1192(ra) # 80004134 <namei>
    80005c94:	84aa                	mv	s1,a0
    80005c96:	c131                	beqz	a0,80005cda <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c98:	ffffe097          	auipc	ra,0xffffe
    80005c9c:	caa080e7          	jalr	-854(ra) # 80003942 <ilock>
  if(ip->type != T_DIR){
    80005ca0:	04449703          	lh	a4,68(s1)
    80005ca4:	4785                	li	a5,1
    80005ca6:	04f71163          	bne	a4,a5,80005ce8 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005caa:	8526                	mv	a0,s1
    80005cac:	ffffe097          	auipc	ra,0xffffe
    80005cb0:	d5c080e7          	jalr	-676(ra) # 80003a08 <iunlock>
  iput(p->cwd);
    80005cb4:	15093503          	ld	a0,336(s2)
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	e48080e7          	jalr	-440(ra) # 80003b00 <iput>
  end_op();
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	6fa080e7          	jalr	1786(ra) # 800043ba <end_op>
  p->cwd = ip;
    80005cc8:	14993823          	sd	s1,336(s2)
  return 0;
    80005ccc:	4501                	li	a0,0
    80005cce:	64aa                	ld	s1,136(sp)
}
    80005cd0:	60ea                	ld	ra,152(sp)
    80005cd2:	644a                	ld	s0,144(sp)
    80005cd4:	690a                	ld	s2,128(sp)
    80005cd6:	610d                	addi	sp,sp,160
    80005cd8:	8082                	ret
    80005cda:	64aa                	ld	s1,136(sp)
    end_op();
    80005cdc:	ffffe097          	auipc	ra,0xffffe
    80005ce0:	6de080e7          	jalr	1758(ra) # 800043ba <end_op>
    return -1;
    80005ce4:	557d                	li	a0,-1
    80005ce6:	b7ed                	j	80005cd0 <sys_chdir+0x7c>
    iunlockput(ip);
    80005ce8:	8526                	mv	a0,s1
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	ec0080e7          	jalr	-320(ra) # 80003baa <iunlockput>
    end_op();
    80005cf2:	ffffe097          	auipc	ra,0xffffe
    80005cf6:	6c8080e7          	jalr	1736(ra) # 800043ba <end_op>
    return -1;
    80005cfa:	557d                	li	a0,-1
    80005cfc:	64aa                	ld	s1,136(sp)
    80005cfe:	bfc9                	j	80005cd0 <sys_chdir+0x7c>

0000000080005d00 <sys_exec>:

uint64
sys_exec(void)
{
    80005d00:	7145                	addi	sp,sp,-464
    80005d02:	e786                	sd	ra,456(sp)
    80005d04:	e3a2                	sd	s0,448(sp)
    80005d06:	fb4a                	sd	s2,432(sp)
    80005d08:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d0a:	08000613          	li	a2,128
    80005d0e:	f4040593          	addi	a1,s0,-192
    80005d12:	4501                	li	a0,0
    80005d14:	ffffd097          	auipc	ra,0xffffd
    80005d18:	072080e7          	jalr	114(ra) # 80002d86 <argstr>
    return -1;
    80005d1c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d1e:	10054463          	bltz	a0,80005e26 <sys_exec+0x126>
    80005d22:	e3840593          	addi	a1,s0,-456
    80005d26:	4505                	li	a0,1
    80005d28:	ffffd097          	auipc	ra,0xffffd
    80005d2c:	03c080e7          	jalr	60(ra) # 80002d64 <argaddr>
    80005d30:	0e054b63          	bltz	a0,80005e26 <sys_exec+0x126>
    80005d34:	ff26                	sd	s1,440(sp)
    80005d36:	f74e                	sd	s3,424(sp)
    80005d38:	f352                	sd	s4,416(sp)
    80005d3a:	ef56                	sd	s5,408(sp)
    80005d3c:	eb5a                	sd	s6,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005d3e:	10000613          	li	a2,256
    80005d42:	4581                	li	a1,0
    80005d44:	e4040513          	addi	a0,s0,-448
    80005d48:	ffffb097          	auipc	ra,0xffffb
    80005d4c:	004080e7          	jalr	4(ra) # 80000d4c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d50:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d54:	89a6                	mv	s3,s1
    80005d56:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d58:	e3040a13          	addi	s4,s0,-464
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d5c:	6a85                	lui	s5,0x1
    if(i >= NELEM(argv)){
    80005d5e:	02000b13          	li	s6,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d62:	00391513          	slli	a0,s2,0x3
    80005d66:	85d2                	mv	a1,s4
    80005d68:	e3843783          	ld	a5,-456(s0)
    80005d6c:	953e                	add	a0,a0,a5
    80005d6e:	ffffd097          	auipc	ra,0xffffd
    80005d72:	f3a080e7          	jalr	-198(ra) # 80002ca8 <fetchaddr>
    80005d76:	02054a63          	bltz	a0,80005daa <sys_exec+0xaa>
    if(uarg == 0){
    80005d7a:	e3043783          	ld	a5,-464(s0)
    80005d7e:	cba1                	beqz	a5,80005dce <sys_exec+0xce>
    argv[i] = kalloc();
    80005d80:	ffffb097          	auipc	ra,0xffffb
    80005d84:	dd0080e7          	jalr	-560(ra) # 80000b50 <kalloc>
    80005d88:	85aa                	mv	a1,a0
    80005d8a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d8e:	cd11                	beqz	a0,80005daa <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d90:	8656                	mv	a2,s5
    80005d92:	e3043503          	ld	a0,-464(s0)
    80005d96:	ffffd097          	auipc	ra,0xffffd
    80005d9a:	f64080e7          	jalr	-156(ra) # 80002cfa <fetchstr>
    80005d9e:	00054663          	bltz	a0,80005daa <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    80005da2:	0905                	addi	s2,s2,1
    80005da4:	09a1                	addi	s3,s3,8
    80005da6:	fb691ee3          	bne	s2,s6,80005d62 <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005daa:	f4040913          	addi	s2,s0,-192
    80005dae:	6088                	ld	a0,0(s1)
    80005db0:	c52d                	beqz	a0,80005e1a <sys_exec+0x11a>
    kfree(argv[i]);
    80005db2:	ffffb097          	auipc	ra,0xffffb
    80005db6:	c9a080e7          	jalr	-870(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dba:	04a1                	addi	s1,s1,8
    80005dbc:	ff2499e3          	bne	s1,s2,80005dae <sys_exec+0xae>
  return -1;
    80005dc0:	597d                	li	s2,-1
    80005dc2:	74fa                	ld	s1,440(sp)
    80005dc4:	79ba                	ld	s3,424(sp)
    80005dc6:	7a1a                	ld	s4,416(sp)
    80005dc8:	6afa                	ld	s5,408(sp)
    80005dca:	6b5a                	ld	s6,400(sp)
    80005dcc:	a8a9                	j	80005e26 <sys_exec+0x126>
      argv[i] = 0;
    80005dce:	0009079b          	sext.w	a5,s2
    80005dd2:	e4040593          	addi	a1,s0,-448
    80005dd6:	078e                	slli	a5,a5,0x3
    80005dd8:	97ae                	add	a5,a5,a1
    80005dda:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005dde:	f4040513          	addi	a0,s0,-192
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	128080e7          	jalr	296(ra) # 80004f0a <exec>
    80005dea:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dec:	f4040993          	addi	s3,s0,-192
    80005df0:	6088                	ld	a0,0(s1)
    80005df2:	cd11                	beqz	a0,80005e0e <sys_exec+0x10e>
    kfree(argv[i]);
    80005df4:	ffffb097          	auipc	ra,0xffffb
    80005df8:	c58080e7          	jalr	-936(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dfc:	04a1                	addi	s1,s1,8
    80005dfe:	ff3499e3          	bne	s1,s3,80005df0 <sys_exec+0xf0>
    80005e02:	74fa                	ld	s1,440(sp)
    80005e04:	79ba                	ld	s3,424(sp)
    80005e06:	7a1a                	ld	s4,416(sp)
    80005e08:	6afa                	ld	s5,408(sp)
    80005e0a:	6b5a                	ld	s6,400(sp)
    80005e0c:	a829                	j	80005e26 <sys_exec+0x126>
  return ret;
    80005e0e:	74fa                	ld	s1,440(sp)
    80005e10:	79ba                	ld	s3,424(sp)
    80005e12:	7a1a                	ld	s4,416(sp)
    80005e14:	6afa                	ld	s5,408(sp)
    80005e16:	6b5a                	ld	s6,400(sp)
    80005e18:	a039                	j	80005e26 <sys_exec+0x126>
  return -1;
    80005e1a:	597d                	li	s2,-1
    80005e1c:	74fa                	ld	s1,440(sp)
    80005e1e:	79ba                	ld	s3,424(sp)
    80005e20:	7a1a                	ld	s4,416(sp)
    80005e22:	6afa                	ld	s5,408(sp)
    80005e24:	6b5a                	ld	s6,400(sp)
}
    80005e26:	854a                	mv	a0,s2
    80005e28:	60be                	ld	ra,456(sp)
    80005e2a:	641e                	ld	s0,448(sp)
    80005e2c:	795a                	ld	s2,432(sp)
    80005e2e:	6179                	addi	sp,sp,464
    80005e30:	8082                	ret

0000000080005e32 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e32:	7139                	addi	sp,sp,-64
    80005e34:	fc06                	sd	ra,56(sp)
    80005e36:	f822                	sd	s0,48(sp)
    80005e38:	f426                	sd	s1,40(sp)
    80005e3a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e3c:	ffffc097          	auipc	ra,0xffffc
    80005e40:	c3e080e7          	jalr	-962(ra) # 80001a7a <myproc>
    80005e44:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e46:	fd840593          	addi	a1,s0,-40
    80005e4a:	4501                	li	a0,0
    80005e4c:	ffffd097          	auipc	ra,0xffffd
    80005e50:	f18080e7          	jalr	-232(ra) # 80002d64 <argaddr>
    return -1;
    80005e54:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e56:	0e054363          	bltz	a0,80005f3c <sys_pipe+0x10a>
  if(pipealloc(&rf, &wf) < 0)
    80005e5a:	fc840593          	addi	a1,s0,-56
    80005e5e:	fd040513          	addi	a0,s0,-48
    80005e62:	fffff097          	auipc	ra,0xfffff
    80005e66:	d3a080e7          	jalr	-710(ra) # 80004b9c <pipealloc>
    return -1;
    80005e6a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e6c:	0c054863          	bltz	a0,80005f3c <sys_pipe+0x10a>
  fd0 = -1;
    80005e70:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e74:	fd043503          	ld	a0,-48(s0)
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	4b0080e7          	jalr	1200(ra) # 80005328 <fdalloc>
    80005e80:	fca42223          	sw	a0,-60(s0)
    80005e84:	08054f63          	bltz	a0,80005f22 <sys_pipe+0xf0>
    80005e88:	fc843503          	ld	a0,-56(s0)
    80005e8c:	fffff097          	auipc	ra,0xfffff
    80005e90:	49c080e7          	jalr	1180(ra) # 80005328 <fdalloc>
    80005e94:	fca42023          	sw	a0,-64(s0)
    80005e98:	06054b63          	bltz	a0,80005f0e <sys_pipe+0xdc>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e9c:	4691                	li	a3,4
    80005e9e:	fc440613          	addi	a2,s0,-60
    80005ea2:	fd843583          	ld	a1,-40(s0)
    80005ea6:	68a8                	ld	a0,80(s1)
    80005ea8:	ffffc097          	auipc	ra,0xffffc
    80005eac:	862080e7          	jalr	-1950(ra) # 8000170a <copyout>
    80005eb0:	02054063          	bltz	a0,80005ed0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005eb4:	4691                	li	a3,4
    80005eb6:	fc040613          	addi	a2,s0,-64
    80005eba:	fd843583          	ld	a1,-40(s0)
    80005ebe:	95b6                	add	a1,a1,a3
    80005ec0:	68a8                	ld	a0,80(s1)
    80005ec2:	ffffc097          	auipc	ra,0xffffc
    80005ec6:	848080e7          	jalr	-1976(ra) # 8000170a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005eca:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ecc:	06055863          	bgez	a0,80005f3c <sys_pipe+0x10a>
    p->ofile[fd0] = 0;
    80005ed0:	fc442783          	lw	a5,-60(s0)
    80005ed4:	078e                	slli	a5,a5,0x3
    80005ed6:	0d078793          	addi	a5,a5,208
    80005eda:	97a6                	add	a5,a5,s1
    80005edc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ee0:	fc042783          	lw	a5,-64(s0)
    80005ee4:	078e                	slli	a5,a5,0x3
    80005ee6:	0d078793          	addi	a5,a5,208
    80005eea:	00f48533          	add	a0,s1,a5
    80005eee:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ef2:	fd043503          	ld	a0,-48(s0)
    80005ef6:	fffff097          	auipc	ra,0xfffff
    80005efa:	926080e7          	jalr	-1754(ra) # 8000481c <fileclose>
    fileclose(wf);
    80005efe:	fc843503          	ld	a0,-56(s0)
    80005f02:	fffff097          	auipc	ra,0xfffff
    80005f06:	91a080e7          	jalr	-1766(ra) # 8000481c <fileclose>
    return -1;
    80005f0a:	57fd                	li	a5,-1
    80005f0c:	a805                	j	80005f3c <sys_pipe+0x10a>
    if(fd0 >= 0)
    80005f0e:	fc442783          	lw	a5,-60(s0)
    80005f12:	0007c863          	bltz	a5,80005f22 <sys_pipe+0xf0>
      p->ofile[fd0] = 0;
    80005f16:	078e                	slli	a5,a5,0x3
    80005f18:	0d078793          	addi	a5,a5,208
    80005f1c:	97a6                	add	a5,a5,s1
    80005f1e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005f22:	fd043503          	ld	a0,-48(s0)
    80005f26:	fffff097          	auipc	ra,0xfffff
    80005f2a:	8f6080e7          	jalr	-1802(ra) # 8000481c <fileclose>
    fileclose(wf);
    80005f2e:	fc843503          	ld	a0,-56(s0)
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	8ea080e7          	jalr	-1814(ra) # 8000481c <fileclose>
    return -1;
    80005f3a:	57fd                	li	a5,-1
}
    80005f3c:	853e                	mv	a0,a5
    80005f3e:	70e2                	ld	ra,56(sp)
    80005f40:	7442                	ld	s0,48(sp)
    80005f42:	74a2                	ld	s1,40(sp)
    80005f44:	6121                	addi	sp,sp,64
    80005f46:	8082                	ret
	...

0000000080005f50 <kernelvec>:
    80005f50:	7111                	addi	sp,sp,-256
    80005f52:	e006                	sd	ra,0(sp)
    80005f54:	e40a                	sd	sp,8(sp)
    80005f56:	e80e                	sd	gp,16(sp)
    80005f58:	ec12                	sd	tp,24(sp)
    80005f5a:	f016                	sd	t0,32(sp)
    80005f5c:	f41a                	sd	t1,40(sp)
    80005f5e:	f81e                	sd	t2,48(sp)
    80005f60:	fc22                	sd	s0,56(sp)
    80005f62:	e0a6                	sd	s1,64(sp)
    80005f64:	e4aa                	sd	a0,72(sp)
    80005f66:	e8ae                	sd	a1,80(sp)
    80005f68:	ecb2                	sd	a2,88(sp)
    80005f6a:	f0b6                	sd	a3,96(sp)
    80005f6c:	f4ba                	sd	a4,104(sp)
    80005f6e:	f8be                	sd	a5,112(sp)
    80005f70:	fcc2                	sd	a6,120(sp)
    80005f72:	e146                	sd	a7,128(sp)
    80005f74:	e54a                	sd	s2,136(sp)
    80005f76:	e94e                	sd	s3,144(sp)
    80005f78:	ed52                	sd	s4,152(sp)
    80005f7a:	f156                	sd	s5,160(sp)
    80005f7c:	f55a                	sd	s6,168(sp)
    80005f7e:	f95e                	sd	s7,176(sp)
    80005f80:	fd62                	sd	s8,184(sp)
    80005f82:	e1e6                	sd	s9,192(sp)
    80005f84:	e5ea                	sd	s10,200(sp)
    80005f86:	e9ee                	sd	s11,208(sp)
    80005f88:	edf2                	sd	t3,216(sp)
    80005f8a:	f1f6                	sd	t4,224(sp)
    80005f8c:	f5fa                	sd	t5,232(sp)
    80005f8e:	f9fe                	sd	t6,240(sp)
    80005f90:	c0dfc0ef          	jal	80002b9c <kerneltrap>
    80005f94:	6082                	ld	ra,0(sp)
    80005f96:	6122                	ld	sp,8(sp)
    80005f98:	61c2                	ld	gp,16(sp)
    80005f9a:	7282                	ld	t0,32(sp)
    80005f9c:	7322                	ld	t1,40(sp)
    80005f9e:	73c2                	ld	t2,48(sp)
    80005fa0:	7462                	ld	s0,56(sp)
    80005fa2:	6486                	ld	s1,64(sp)
    80005fa4:	6526                	ld	a0,72(sp)
    80005fa6:	65c6                	ld	a1,80(sp)
    80005fa8:	6666                	ld	a2,88(sp)
    80005faa:	7686                	ld	a3,96(sp)
    80005fac:	7726                	ld	a4,104(sp)
    80005fae:	77c6                	ld	a5,112(sp)
    80005fb0:	7866                	ld	a6,120(sp)
    80005fb2:	688a                	ld	a7,128(sp)
    80005fb4:	692a                	ld	s2,136(sp)
    80005fb6:	69ca                	ld	s3,144(sp)
    80005fb8:	6a6a                	ld	s4,152(sp)
    80005fba:	7a8a                	ld	s5,160(sp)
    80005fbc:	7b2a                	ld	s6,168(sp)
    80005fbe:	7bca                	ld	s7,176(sp)
    80005fc0:	7c6a                	ld	s8,184(sp)
    80005fc2:	6c8e                	ld	s9,192(sp)
    80005fc4:	6d2e                	ld	s10,200(sp)
    80005fc6:	6dce                	ld	s11,208(sp)
    80005fc8:	6e6e                	ld	t3,216(sp)
    80005fca:	7e8e                	ld	t4,224(sp)
    80005fcc:	7f2e                	ld	t5,232(sp)
    80005fce:	7fce                	ld	t6,240(sp)
    80005fd0:	6111                	addi	sp,sp,256
    80005fd2:	10200073          	sret
    80005fd6:	00000013          	nop
    80005fda:	00000013          	nop
    80005fde:	0001                	nop

0000000080005fe0 <timervec>:
    80005fe0:	34051573          	csrrw	a0,mscratch,a0
    80005fe4:	e10c                	sd	a1,0(a0)
    80005fe6:	e510                	sd	a2,8(a0)
    80005fe8:	e914                	sd	a3,16(a0)
    80005fea:	6d0c                	ld	a1,24(a0)
    80005fec:	7110                	ld	a2,32(a0)
    80005fee:	6194                	ld	a3,0(a1)
    80005ff0:	96b2                	add	a3,a3,a2
    80005ff2:	e194                	sd	a3,0(a1)
    80005ff4:	4589                	li	a1,2
    80005ff6:	14459073          	csrw	sip,a1
    80005ffa:	6914                	ld	a3,16(a0)
    80005ffc:	6510                	ld	a2,8(a0)
    80005ffe:	610c                	ld	a1,0(a0)
    80006000:	34051573          	csrrw	a0,mscratch,a0
    80006004:	30200073          	mret
    80006008:	0001                	nop

000000008000600a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000600a:	1141                	addi	sp,sp,-16
    8000600c:	e406                	sd	ra,8(sp)
    8000600e:	e022                	sd	s0,0(sp)
    80006010:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006012:	0c000737          	lui	a4,0xc000
    80006016:	4785                	li	a5,1
    80006018:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000601a:	c35c                	sw	a5,4(a4)
}
    8000601c:	60a2                	ld	ra,8(sp)
    8000601e:	6402                	ld	s0,0(sp)
    80006020:	0141                	addi	sp,sp,16
    80006022:	8082                	ret

0000000080006024 <plicinithart>:

void
plicinithart(void)
{
    80006024:	1141                	addi	sp,sp,-16
    80006026:	e406                	sd	ra,8(sp)
    80006028:	e022                	sd	s0,0(sp)
    8000602a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000602c:	ffffc097          	auipc	ra,0xffffc
    80006030:	a1a080e7          	jalr	-1510(ra) # 80001a46 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006034:	0085171b          	slliw	a4,a0,0x8
    80006038:	0c0027b7          	lui	a5,0xc002
    8000603c:	97ba                	add	a5,a5,a4
    8000603e:	40200713          	li	a4,1026
    80006042:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006046:	00d5151b          	slliw	a0,a0,0xd
    8000604a:	0c2017b7          	lui	a5,0xc201
    8000604e:	97aa                	add	a5,a5,a0
    80006050:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006054:	60a2                	ld	ra,8(sp)
    80006056:	6402                	ld	s0,0(sp)
    80006058:	0141                	addi	sp,sp,16
    8000605a:	8082                	ret

000000008000605c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000605c:	1141                	addi	sp,sp,-16
    8000605e:	e406                	sd	ra,8(sp)
    80006060:	e022                	sd	s0,0(sp)
    80006062:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006064:	ffffc097          	auipc	ra,0xffffc
    80006068:	9e2080e7          	jalr	-1566(ra) # 80001a46 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000606c:	00d5151b          	slliw	a0,a0,0xd
    80006070:	0c2017b7          	lui	a5,0xc201
    80006074:	97aa                	add	a5,a5,a0
  return irq;
}
    80006076:	43c8                	lw	a0,4(a5)
    80006078:	60a2                	ld	ra,8(sp)
    8000607a:	6402                	ld	s0,0(sp)
    8000607c:	0141                	addi	sp,sp,16
    8000607e:	8082                	ret

0000000080006080 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006080:	1101                	addi	sp,sp,-32
    80006082:	ec06                	sd	ra,24(sp)
    80006084:	e822                	sd	s0,16(sp)
    80006086:	e426                	sd	s1,8(sp)
    80006088:	1000                	addi	s0,sp,32
    8000608a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000608c:	ffffc097          	auipc	ra,0xffffc
    80006090:	9ba080e7          	jalr	-1606(ra) # 80001a46 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006094:	00d5179b          	slliw	a5,a0,0xd
    80006098:	0c201737          	lui	a4,0xc201
    8000609c:	97ba                	add	a5,a5,a4
    8000609e:	c3c4                	sw	s1,4(a5)
}
    800060a0:	60e2                	ld	ra,24(sp)
    800060a2:	6442                	ld	s0,16(sp)
    800060a4:	64a2                	ld	s1,8(sp)
    800060a6:	6105                	addi	sp,sp,32
    800060a8:	8082                	ret

00000000800060aa <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060aa:	1141                	addi	sp,sp,-16
    800060ac:	e406                	sd	ra,8(sp)
    800060ae:	e022                	sd	s0,0(sp)
    800060b0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060b2:	479d                	li	a5,7
    800060b4:	06a7c863          	blt	a5,a0,80006124 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    800060b8:	00020717          	auipc	a4,0x20
    800060bc:	f4870713          	addi	a4,a4,-184 # 80026000 <disk>
    800060c0:	972a                	add	a4,a4,a0
    800060c2:	6789                	lui	a5,0x2
    800060c4:	97ba                	add	a5,a5,a4
    800060c6:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800060ca:	e7ad                	bnez	a5,80006134 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060cc:	00451793          	slli	a5,a0,0x4
    800060d0:	00022717          	auipc	a4,0x22
    800060d4:	f3070713          	addi	a4,a4,-208 # 80028000 <disk+0x2000>
    800060d8:	6314                	ld	a3,0(a4)
    800060da:	96be                	add	a3,a3,a5
    800060dc:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800060e0:	6314                	ld	a3,0(a4)
    800060e2:	96be                	add	a3,a3,a5
    800060e4:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800060e8:	6314                	ld	a3,0(a4)
    800060ea:	96be                	add	a3,a3,a5
    800060ec:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800060f0:	6318                	ld	a4,0(a4)
    800060f2:	97ba                	add	a5,a5,a4
    800060f4:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800060f8:	00020717          	auipc	a4,0x20
    800060fc:	f0870713          	addi	a4,a4,-248 # 80026000 <disk>
    80006100:	972a                	add	a4,a4,a0
    80006102:	6789                	lui	a5,0x2
    80006104:	97ba                	add	a5,a5,a4
    80006106:	4705                	li	a4,1
    80006108:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000610c:	00022517          	auipc	a0,0x22
    80006110:	f0c50513          	addi	a0,a0,-244 # 80028018 <disk+0x2018>
    80006114:	ffffc097          	auipc	ra,0xffffc
    80006118:	3ae080e7          	jalr	942(ra) # 800024c2 <wakeup>
}
    8000611c:	60a2                	ld	ra,8(sp)
    8000611e:	6402                	ld	s0,0(sp)
    80006120:	0141                	addi	sp,sp,16
    80006122:	8082                	ret
    panic("free_desc 1");
    80006124:	00002517          	auipc	a0,0x2
    80006128:	54c50513          	addi	a0,a0,1356 # 80008670 <etext+0x670>
    8000612c:	ffffa097          	auipc	ra,0xffffa
    80006130:	42a080e7          	jalr	1066(ra) # 80000556 <panic>
    panic("free_desc 2");
    80006134:	00002517          	auipc	a0,0x2
    80006138:	54c50513          	addi	a0,a0,1356 # 80008680 <etext+0x680>
    8000613c:	ffffa097          	auipc	ra,0xffffa
    80006140:	41a080e7          	jalr	1050(ra) # 80000556 <panic>

0000000080006144 <virtio_disk_init>:
{
    80006144:	1141                	addi	sp,sp,-16
    80006146:	e406                	sd	ra,8(sp)
    80006148:	e022                	sd	s0,0(sp)
    8000614a:	0800                	addi	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000614c:	00002597          	auipc	a1,0x2
    80006150:	54458593          	addi	a1,a1,1348 # 80008690 <etext+0x690>
    80006154:	00022517          	auipc	a0,0x22
    80006158:	fd450513          	addi	a0,a0,-44 # 80028128 <disk+0x2128>
    8000615c:	ffffb097          	auipc	ra,0xffffb
    80006160:	a5e080e7          	jalr	-1442(ra) # 80000bba <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006164:	100017b7          	lui	a5,0x10001
    80006168:	4398                	lw	a4,0(a5)
    8000616a:	2701                	sext.w	a4,a4
    8000616c:	747277b7          	lui	a5,0x74727
    80006170:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006174:	0ef71563          	bne	a4,a5,8000625e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006178:	100017b7          	lui	a5,0x10001
    8000617c:	43dc                	lw	a5,4(a5)
    8000617e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006180:	4705                	li	a4,1
    80006182:	0ce79e63          	bne	a5,a4,8000625e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006186:	100017b7          	lui	a5,0x10001
    8000618a:	479c                	lw	a5,8(a5)
    8000618c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000618e:	4709                	li	a4,2
    80006190:	0ce79763          	bne	a5,a4,8000625e <virtio_disk_init+0x11a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006194:	100017b7          	lui	a5,0x10001
    80006198:	47d8                	lw	a4,12(a5)
    8000619a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000619c:	554d47b7          	lui	a5,0x554d4
    800061a0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061a4:	0af71d63          	bne	a4,a5,8000625e <virtio_disk_init+0x11a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061a8:	100017b7          	lui	a5,0x10001
    800061ac:	4705                	li	a4,1
    800061ae:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061b0:	470d                	li	a4,3
    800061b2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061b4:	10001737          	lui	a4,0x10001
    800061b8:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061ba:	c7ffe6b7          	lui	a3,0xc7ffe
    800061be:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd575f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061c2:	8f75                	and	a4,a4,a3
    800061c4:	100016b7          	lui	a3,0x10001
    800061c8:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061ca:	472d                	li	a4,11
    800061cc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061ce:	473d                	li	a4,15
    800061d0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061d2:	6705                	lui	a4,0x1
    800061d4:	d698                	sw	a4,40(a3)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061d6:	0206a823          	sw	zero,48(a3) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061da:	5adc                	lw	a5,52(a3)
    800061dc:	2781                	sext.w	a5,a5
  if(max == 0)
    800061de:	cbc1                	beqz	a5,8000626e <virtio_disk_init+0x12a>
  if(max < NUM)
    800061e0:	471d                	li	a4,7
    800061e2:	08f77e63          	bgeu	a4,a5,8000627e <virtio_disk_init+0x13a>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061e6:	100017b7          	lui	a5,0x10001
    800061ea:	4721                	li	a4,8
    800061ec:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    800061ee:	6609                	lui	a2,0x2
    800061f0:	4581                	li	a1,0
    800061f2:	00020517          	auipc	a0,0x20
    800061f6:	e0e50513          	addi	a0,a0,-498 # 80026000 <disk>
    800061fa:	ffffb097          	auipc	ra,0xffffb
    800061fe:	b52080e7          	jalr	-1198(ra) # 80000d4c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006202:	00020717          	auipc	a4,0x20
    80006206:	dfe70713          	addi	a4,a4,-514 # 80026000 <disk>
    8000620a:	00c75793          	srli	a5,a4,0xc
    8000620e:	2781                	sext.w	a5,a5
    80006210:	100016b7          	lui	a3,0x10001
    80006214:	c2bc                	sw	a5,64(a3)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006216:	00022797          	auipc	a5,0x22
    8000621a:	dea78793          	addi	a5,a5,-534 # 80028000 <disk+0x2000>
    8000621e:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006220:	00020717          	auipc	a4,0x20
    80006224:	e6070713          	addi	a4,a4,-416 # 80026080 <disk+0x80>
    80006228:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000622a:	00021717          	auipc	a4,0x21
    8000622e:	dd670713          	addi	a4,a4,-554 # 80027000 <disk+0x1000>
    80006232:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006234:	4705                	li	a4,1
    80006236:	00e78c23          	sb	a4,24(a5)
    8000623a:	00e78ca3          	sb	a4,25(a5)
    8000623e:	00e78d23          	sb	a4,26(a5)
    80006242:	00e78da3          	sb	a4,27(a5)
    80006246:	00e78e23          	sb	a4,28(a5)
    8000624a:	00e78ea3          	sb	a4,29(a5)
    8000624e:	00e78f23          	sb	a4,30(a5)
    80006252:	00e78fa3          	sb	a4,31(a5)
}
    80006256:	60a2                	ld	ra,8(sp)
    80006258:	6402                	ld	s0,0(sp)
    8000625a:	0141                	addi	sp,sp,16
    8000625c:	8082                	ret
    panic("could not find virtio disk");
    8000625e:	00002517          	auipc	a0,0x2
    80006262:	44250513          	addi	a0,a0,1090 # 800086a0 <etext+0x6a0>
    80006266:	ffffa097          	auipc	ra,0xffffa
    8000626a:	2f0080e7          	jalr	752(ra) # 80000556 <panic>
    panic("virtio disk has no queue 0");
    8000626e:	00002517          	auipc	a0,0x2
    80006272:	45250513          	addi	a0,a0,1106 # 800086c0 <etext+0x6c0>
    80006276:	ffffa097          	auipc	ra,0xffffa
    8000627a:	2e0080e7          	jalr	736(ra) # 80000556 <panic>
    panic("virtio disk max queue too short");
    8000627e:	00002517          	auipc	a0,0x2
    80006282:	46250513          	addi	a0,a0,1122 # 800086e0 <etext+0x6e0>
    80006286:	ffffa097          	auipc	ra,0xffffa
    8000628a:	2d0080e7          	jalr	720(ra) # 80000556 <panic>

000000008000628e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000628e:	711d                	addi	sp,sp,-96
    80006290:	ec86                	sd	ra,88(sp)
    80006292:	e8a2                	sd	s0,80(sp)
    80006294:	e4a6                	sd	s1,72(sp)
    80006296:	e0ca                	sd	s2,64(sp)
    80006298:	fc4e                	sd	s3,56(sp)
    8000629a:	f852                	sd	s4,48(sp)
    8000629c:	f456                	sd	s5,40(sp)
    8000629e:	f05a                	sd	s6,32(sp)
    800062a0:	ec5e                	sd	s7,24(sp)
    800062a2:	e862                	sd	s8,16(sp)
    800062a4:	1080                	addi	s0,sp,96
    800062a6:	89aa                	mv	s3,a0
    800062a8:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062aa:	00c52b83          	lw	s7,12(a0)
    800062ae:	001b9b9b          	slliw	s7,s7,0x1
    800062b2:	1b82                	slli	s7,s7,0x20
    800062b4:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800062b8:	00022517          	auipc	a0,0x22
    800062bc:	e7050513          	addi	a0,a0,-400 # 80028128 <disk+0x2128>
    800062c0:	ffffb097          	auipc	ra,0xffffb
    800062c4:	994080e7          	jalr	-1644(ra) # 80000c54 <acquire>
  for(int i = 0; i < NUM; i++){
    800062c8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062ca:	00020b17          	auipc	s6,0x20
    800062ce:	d36b0b13          	addi	s6,s6,-714 # 80026000 <disk>
    800062d2:	6a89                	lui	s5,0x2
  for(int i = 0; i < 3; i++){
    800062d4:	4a0d                	li	s4,3
    800062d6:	a88d                	j	80006348 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800062d8:	00fb0733          	add	a4,s6,a5
    800062dc:	9756                	add	a4,a4,s5
    800062de:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062e2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062e4:	0207c563          	bltz	a5,8000630e <virtio_disk_rw+0x80>
  for(int i = 0; i < 3; i++){
    800062e8:	2905                	addiw	s2,s2,1
    800062ea:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    800062ec:	1b490063          	beq	s2,s4,8000648c <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    800062f0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800062f2:	00022717          	auipc	a4,0x22
    800062f6:	d2670713          	addi	a4,a4,-730 # 80028018 <disk+0x2018>
    800062fa:	4781                	li	a5,0
    if(disk.free[i]){
    800062fc:	00074683          	lbu	a3,0(a4)
    80006300:	fee1                	bnez	a3,800062d8 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    80006302:	2785                	addiw	a5,a5,1
    80006304:	0705                	addi	a4,a4,1
    80006306:	fe979be3          	bne	a5,s1,800062fc <virtio_disk_rw+0x6e>
    idx[i] = alloc_desc();
    8000630a:	57fd                	li	a5,-1
    8000630c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000630e:	03205163          	blez	s2,80006330 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006312:	fa042503          	lw	a0,-96(s0)
    80006316:	00000097          	auipc	ra,0x0
    8000631a:	d94080e7          	jalr	-620(ra) # 800060aa <free_desc>
      for(int j = 0; j < i; j++)
    8000631e:	4785                	li	a5,1
    80006320:	0127d863          	bge	a5,s2,80006330 <virtio_disk_rw+0xa2>
        free_desc(idx[j]);
    80006324:	fa442503          	lw	a0,-92(s0)
    80006328:	00000097          	auipc	ra,0x0
    8000632c:	d82080e7          	jalr	-638(ra) # 800060aa <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006330:	00022597          	auipc	a1,0x22
    80006334:	df858593          	addi	a1,a1,-520 # 80028128 <disk+0x2128>
    80006338:	00022517          	auipc	a0,0x22
    8000633c:	ce050513          	addi	a0,a0,-800 # 80028018 <disk+0x2018>
    80006340:	ffffc097          	auipc	ra,0xffffc
    80006344:	eb6080e7          	jalr	-330(ra) # 800021f6 <sleep>
  for(int i = 0; i < 3; i++){
    80006348:	fa040613          	addi	a2,s0,-96
    8000634c:	4901                	li	s2,0
    8000634e:	b74d                	j	800062f0 <virtio_disk_rw+0x62>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006350:	00022717          	auipc	a4,0x22
    80006354:	cb073703          	ld	a4,-848(a4) # 80028000 <disk+0x2000>
    80006358:	973e                	add	a4,a4,a5
    8000635a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000635e:	00020897          	auipc	a7,0x20
    80006362:	ca288893          	addi	a7,a7,-862 # 80026000 <disk>
    80006366:	00022717          	auipc	a4,0x22
    8000636a:	c9a70713          	addi	a4,a4,-870 # 80028000 <disk+0x2000>
    8000636e:	6314                	ld	a3,0(a4)
    80006370:	96be                	add	a3,a3,a5
    80006372:	00c6d583          	lhu	a1,12(a3) # 1000100c <_entry-0x6fffeff4>
    80006376:	0015e593          	ori	a1,a1,1
    8000637a:	00b69623          	sh	a1,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000637e:	fa842683          	lw	a3,-88(s0)
    80006382:	630c                	ld	a1,0(a4)
    80006384:	97ae                	add	a5,a5,a1
    80006386:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000638a:	20050593          	addi	a1,a0,512
    8000638e:	0592                	slli	a1,a1,0x4
    80006390:	95c6                	add	a1,a1,a7
    80006392:	57fd                	li	a5,-1
    80006394:	02f58823          	sb	a5,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006398:	00469793          	slli	a5,a3,0x4
    8000639c:	00073803          	ld	a6,0(a4)
    800063a0:	983e                	add	a6,a6,a5
    800063a2:	6689                	lui	a3,0x2
    800063a4:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    800063a8:	96b2                	add	a3,a3,a2
    800063aa:	96c6                	add	a3,a3,a7
    800063ac:	00d83023          	sd	a3,0(a6)
  disk.desc[idx[2]].len = 1;
    800063b0:	6314                	ld	a3,0(a4)
    800063b2:	96be                	add	a3,a3,a5
    800063b4:	4605                	li	a2,1
    800063b6:	c690                	sw	a2,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063b8:	6314                	ld	a3,0(a4)
    800063ba:	96be                	add	a3,a3,a5
    800063bc:	4809                	li	a6,2
    800063be:	01069623          	sh	a6,12(a3)
  disk.desc[idx[2]].next = 0;
    800063c2:	6314                	ld	a3,0(a4)
    800063c4:	97b6                	add	a5,a5,a3
    800063c6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063ca:	00c9a223          	sw	a2,4(s3)
  disk.info[idx[0]].b = b;
    800063ce:	0335b423          	sd	s3,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063d2:	6714                	ld	a3,8(a4)
    800063d4:	0026d783          	lhu	a5,2(a3)
    800063d8:	8b9d                	andi	a5,a5,7
    800063da:	0786                	slli	a5,a5,0x1
    800063dc:	96be                	add	a3,a3,a5
    800063de:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800063e2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063e6:	6718                	ld	a4,8(a4)
    800063e8:	00275783          	lhu	a5,2(a4)
    800063ec:	2785                	addiw	a5,a5,1
    800063ee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063f2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063f6:	100017b7          	lui	a5,0x10001
    800063fa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063fe:	0049a783          	lw	a5,4(s3)
    80006402:	02c79163          	bne	a5,a2,80006424 <virtio_disk_rw+0x196>
    sleep(b, &disk.vdisk_lock);
    80006406:	00022917          	auipc	s2,0x22
    8000640a:	d2290913          	addi	s2,s2,-734 # 80028128 <disk+0x2128>
  while(b->disk == 1) {
    8000640e:	84be                	mv	s1,a5
    sleep(b, &disk.vdisk_lock);
    80006410:	85ca                	mv	a1,s2
    80006412:	854e                	mv	a0,s3
    80006414:	ffffc097          	auipc	ra,0xffffc
    80006418:	de2080e7          	jalr	-542(ra) # 800021f6 <sleep>
  while(b->disk == 1) {
    8000641c:	0049a783          	lw	a5,4(s3)
    80006420:	fe9788e3          	beq	a5,s1,80006410 <virtio_disk_rw+0x182>
  }

  disk.info[idx[0]].b = 0;
    80006424:	fa042903          	lw	s2,-96(s0)
    80006428:	20090713          	addi	a4,s2,512
    8000642c:	0712                	slli	a4,a4,0x4
    8000642e:	00020797          	auipc	a5,0x20
    80006432:	bd278793          	addi	a5,a5,-1070 # 80026000 <disk>
    80006436:	97ba                	add	a5,a5,a4
    80006438:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000643c:	00022997          	auipc	s3,0x22
    80006440:	bc498993          	addi	s3,s3,-1084 # 80028000 <disk+0x2000>
    80006444:	00491713          	slli	a4,s2,0x4
    80006448:	0009b783          	ld	a5,0(s3)
    8000644c:	97ba                	add	a5,a5,a4
    8000644e:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006452:	854a                	mv	a0,s2
    80006454:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006458:	00000097          	auipc	ra,0x0
    8000645c:	c52080e7          	jalr	-942(ra) # 800060aa <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006460:	8885                	andi	s1,s1,1
    80006462:	f0ed                	bnez	s1,80006444 <virtio_disk_rw+0x1b6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006464:	00022517          	auipc	a0,0x22
    80006468:	cc450513          	addi	a0,a0,-828 # 80028128 <disk+0x2128>
    8000646c:	ffffb097          	auipc	ra,0xffffb
    80006470:	898080e7          	jalr	-1896(ra) # 80000d04 <release>
}
    80006474:	60e6                	ld	ra,88(sp)
    80006476:	6446                	ld	s0,80(sp)
    80006478:	64a6                	ld	s1,72(sp)
    8000647a:	6906                	ld	s2,64(sp)
    8000647c:	79e2                	ld	s3,56(sp)
    8000647e:	7a42                	ld	s4,48(sp)
    80006480:	7aa2                	ld	s5,40(sp)
    80006482:	7b02                	ld	s6,32(sp)
    80006484:	6be2                	ld	s7,24(sp)
    80006486:	6c42                	ld	s8,16(sp)
    80006488:	6125                	addi	sp,sp,96
    8000648a:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000648c:	fa042503          	lw	a0,-96(s0)
    80006490:	00451613          	slli	a2,a0,0x4
  if(write)
    80006494:	00020597          	auipc	a1,0x20
    80006498:	b6c58593          	addi	a1,a1,-1172 # 80026000 <disk>
    8000649c:	20050793          	addi	a5,a0,512
    800064a0:	0792                	slli	a5,a5,0x4
    800064a2:	97ae                	add	a5,a5,a1
    800064a4:	01803733          	snez	a4,s8
    800064a8:	0ae7a423          	sw	a4,168(a5)
  buf0->reserved = 0;
    800064ac:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    800064b0:	0b77b823          	sd	s7,176(a5)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064b4:	00022717          	auipc	a4,0x22
    800064b8:	b4c70713          	addi	a4,a4,-1204 # 80028000 <disk+0x2000>
    800064bc:	6314                	ld	a3,0(a4)
    800064be:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064c0:	6789                	lui	a5,0x2
    800064c2:	0a878793          	addi	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    800064c6:	97b2                	add	a5,a5,a2
    800064c8:	97ae                	add	a5,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064ca:	e29c                	sd	a5,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064cc:	631c                	ld	a5,0(a4)
    800064ce:	97b2                	add	a5,a5,a2
    800064d0:	46c1                	li	a3,16
    800064d2:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064d4:	631c                	ld	a5,0(a4)
    800064d6:	97b2                	add	a5,a5,a2
    800064d8:	4685                	li	a3,1
    800064da:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800064de:	fa442783          	lw	a5,-92(s0)
    800064e2:	6314                	ld	a3,0(a4)
    800064e4:	96b2                	add	a3,a3,a2
    800064e6:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800064ea:	0792                	slli	a5,a5,0x4
    800064ec:	6314                	ld	a3,0(a4)
    800064ee:	96be                	add	a3,a3,a5
    800064f0:	05898593          	addi	a1,s3,88
    800064f4:	e28c                	sd	a1,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    800064f6:	6318                	ld	a4,0(a4)
    800064f8:	973e                	add	a4,a4,a5
    800064fa:	40000693          	li	a3,1024
    800064fe:	c714                	sw	a3,8(a4)
  if(write)
    80006500:	e40c18e3          	bnez	s8,80006350 <virtio_disk_rw+0xc2>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006504:	00022717          	auipc	a4,0x22
    80006508:	afc73703          	ld	a4,-1284(a4) # 80028000 <disk+0x2000>
    8000650c:	973e                	add	a4,a4,a5
    8000650e:	4689                	li	a3,2
    80006510:	00d71623          	sh	a3,12(a4)
    80006514:	b5a9                	j	8000635e <virtio_disk_rw+0xd0>

0000000080006516 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006516:	1101                	addi	sp,sp,-32
    80006518:	ec06                	sd	ra,24(sp)
    8000651a:	e822                	sd	s0,16(sp)
    8000651c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000651e:	00022517          	auipc	a0,0x22
    80006522:	c0a50513          	addi	a0,a0,-1014 # 80028128 <disk+0x2128>
    80006526:	ffffa097          	auipc	ra,0xffffa
    8000652a:	72e080e7          	jalr	1838(ra) # 80000c54 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000652e:	100017b7          	lui	a5,0x10001
    80006532:	53bc                	lw	a5,96(a5)
    80006534:	8b8d                	andi	a5,a5,3
    80006536:	10001737          	lui	a4,0x10001
    8000653a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000653c:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006540:	00022797          	auipc	a5,0x22
    80006544:	ac078793          	addi	a5,a5,-1344 # 80028000 <disk+0x2000>
    80006548:	6b94                	ld	a3,16(a5)
    8000654a:	0207d703          	lhu	a4,32(a5)
    8000654e:	0026d783          	lhu	a5,2(a3)
    80006552:	06f70563          	beq	a4,a5,800065bc <virtio_disk_intr+0xa6>
    80006556:	e426                	sd	s1,8(sp)
    80006558:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000655a:	00020917          	auipc	s2,0x20
    8000655e:	aa690913          	addi	s2,s2,-1370 # 80026000 <disk>
    80006562:	00022497          	auipc	s1,0x22
    80006566:	a9e48493          	addi	s1,s1,-1378 # 80028000 <disk+0x2000>
    __sync_synchronize();
    8000656a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000656e:	6898                	ld	a4,16(s1)
    80006570:	0204d783          	lhu	a5,32(s1)
    80006574:	8b9d                	andi	a5,a5,7
    80006576:	078e                	slli	a5,a5,0x3
    80006578:	97ba                	add	a5,a5,a4
    8000657a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000657c:	20078713          	addi	a4,a5,512
    80006580:	0712                	slli	a4,a4,0x4
    80006582:	974a                	add	a4,a4,s2
    80006584:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006588:	e731                	bnez	a4,800065d4 <virtio_disk_intr+0xbe>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000658a:	20078793          	addi	a5,a5,512
    8000658e:	0792                	slli	a5,a5,0x4
    80006590:	97ca                	add	a5,a5,s2
    80006592:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006594:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006598:	ffffc097          	auipc	ra,0xffffc
    8000659c:	f2a080e7          	jalr	-214(ra) # 800024c2 <wakeup>

    disk.used_idx += 1;
    800065a0:	0204d783          	lhu	a5,32(s1)
    800065a4:	2785                	addiw	a5,a5,1
    800065a6:	17c2                	slli	a5,a5,0x30
    800065a8:	93c1                	srli	a5,a5,0x30
    800065aa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065ae:	6898                	ld	a4,16(s1)
    800065b0:	00275703          	lhu	a4,2(a4)
    800065b4:	faf71be3          	bne	a4,a5,8000656a <virtio_disk_intr+0x54>
    800065b8:	64a2                	ld	s1,8(sp)
    800065ba:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    800065bc:	00022517          	auipc	a0,0x22
    800065c0:	b6c50513          	addi	a0,a0,-1172 # 80028128 <disk+0x2128>
    800065c4:	ffffa097          	auipc	ra,0xffffa
    800065c8:	740080e7          	jalr	1856(ra) # 80000d04 <release>
}
    800065cc:	60e2                	ld	ra,24(sp)
    800065ce:	6442                	ld	s0,16(sp)
    800065d0:	6105                	addi	sp,sp,32
    800065d2:	8082                	ret
      panic("virtio_disk_intr status");
    800065d4:	00002517          	auipc	a0,0x2
    800065d8:	12c50513          	addi	a0,a0,300 # 80008700 <etext+0x700>
    800065dc:	ffffa097          	auipc	ra,0xffffa
    800065e0:	f7a080e7          	jalr	-134(ra) # 80000556 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
