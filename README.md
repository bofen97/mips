## MIPS sub-arch

### 指令格式

---

**R type : [op 6, rs 5, rt 5, rd 5, shamt 5,funct 6]**

- rs，rt 源寄存器，rd 目的寄存器。

#### example

```asm

add $s0,$s1,$s2; --> 000000 10001 10010 10000 00000 100000

sub $t0,$t3,$t5; --> 000000 01011 01101 01000 00000 100010
```

---

---

**I type :[op 6, rs 5, rt 5, imm 16]**

- rs,imm 源寄存器和源操作数，rt 目的寄存器。

#### example

```asm
addi $s0,$1,5; --> 001000 10001 10000 0000000000000101

ld $t2,32($0); --> 100011 00000 01010 0000000000100000

sw $s1,4($t1); --> 101011 01001 10001 0000000000000100
```

---

---

**J type :[op 6, addr 26]**

- addr 目标地址

#### example
```asm
j label --> opcode addr of label
```
---
---
### 控制器

##### 不同的逻辑

对于 R type 指令，有固定的 opcode，逻辑上是 rd = rs op rt ，抽象来看，有两个寄存器的读和一个寄存器的存操作，具体的 op 根据 aluop 和 funct 计算。

对于 I type 指令，逻辑上是 rt = rs of function(imm) ，opcode 不同导致 op 的逻辑不同，并且根据特定情况来决定是否进行 imm 的符号扩展或 0 扩展。

##### 控制信号生成

对于微体系结构最基本的处理

Q1. 如何根据 PC 寻址 ？

- 一般的，RAM 存储指令可以是 [31:0] RAM [63:0] ，32 位的指令，并且存储器深度是 64。
  即，32 位（4 Byte aligned ），所以我们的 PC 是 4 的倍数，PC = PC + 4。在这个设计中，默认 PC = PC + 4，如果遇到跳转指令，那么需要计算 target address = PC+4 + n ，其中 n 是下一条指令到 target address 指令的间隔数。那么，我们 PCBranch = PC+4 + signext(n)<< 2，最后会根据 **PCsrc** 控制信号来选择 PC next 是什么。在指令周期的开始，会拿到 PC，即，PC <= PCnext, 然后从 RAM 中获得指令，再根据 OPCode 生成控制信号 ，从而根据 OPCode 决定 PCnext 的地址。

Q2. 如何根据 opcode 生成控制信号 ？

- 控制信号决定了 DataPath 的数据流向，生成过程抽象来看是 OPCode -> DataPath control signal && ALUOp signal -> **ALUOp signal** or **funct** -> alucontrolle 。

  **_example_**

  ```reStructuredText
  对于R type 指令，opcode是000000，其aluop signal是 10，即，需要根据funct来选择 aluop add sub or and e.t.
  对于I type 指令，opcode不同，aluop也不一定相同。
  
  ```

### Tips

对于 I type 指令，需要对 imm 进行符号扩展，16->32。对于逻辑 op，往往需要 0 扩展。


# 流水线微结构

实现了控制冲突和数据冲突，支持beq 和 j 指令，数据冲突解决了read after write （RAW），解决方法使用了寄存器重定向和阻塞，六个分支记录了开发过程，从最早的单周期到多周期，到流水线的数据路径的实现，到实现寄存器重定向，流水线阻塞，到解决beq，和 j 指令的控制冲突。最后测试成功mems.v中的代码。

这个分支（estage）和之前的不同之处在于，将比较器放到了执行级，这样周期长度可以减少。
在自带的测试代码中，有一条beq指令，所以整个代码的执行多了一个周期，即相较之前版本，会多刷掉一条指令。但通过理论计算，周期长度可以减少。这样整个处理器的速度会相应提高。

## 数据冲突和控制冲突的设计和思考
首先，数据冲突往往可以被寄存器重定向来解决，不妨考虑如下三条指令
``` asm
add r1,r0,r3;
sub r2,r0,r4;
add r5,r1,r2;
```
当流水线，按照指令顺序，执行三条指令时，当add处于执行级的时候，
r1还未被写回，第一条指令处于Memory级，r2也未被写回，第二条指令
处于WriteBack级，这个时候使用重定向，可以解决这种冲突。

``` verilog
      if ((RsE!=0) && (RsE == WriteRegM ) && RegWriteM)
          ForwardAE = 2'b10;
      else if ((RsE!=0) && (RsE == WriteRegW) && RegWriteW)
          ForwardAE = 2'b01;
      else
          ForwardAE = 2'b00;
```
上述重定向代码，意思是如果执行级的源寄存器rs，和memory或writeback级的目的寄存器相等时，
并且写信号enable，这个时候重定向源寄存器。

类似的，对于另一个源寄存器rt，也是如此

``` verilog

    if ((RtE!=0) && (RtE == WriteRegM ) && RegWriteM)
        ForwardBE = 2'b10;
    else if ((RtE!=0) && (RtE == WriteRegW) && RegWriteW)
        ForwardBE = 2'b01;
    else
        ForwardBE = 2'b00;
```

一般的，我们考虑如下代码
``` asm
lw r1,r0(8);
sub r2,r1,r0;
```
流水线，按照顺序执行这两条指令，会发生什么？
- 当sub处于执行级的时候需要使用存储器中的数据，这个时候，lw指令处于memory级，
如果不加干涉，那么sub指令的r1将是错误的数据。所以，我们这个时候阻塞一个周期流水线的执行。
让sub保持在执行级，让lw进行到writeback级，这个时候便可以用上述寄存器重定向解决本次数据冲突。
- 在什么阶段阻塞流水线？
在D和E级都可以阻塞，要做到阻塞阶段前的流水线寄存器保持不变，后的流水线寄存器要清空。
不妨考虑在D级阻塞，这样我们识别出lw之后，要保持FD流水线不变，pc不变，并且清空DE流水线寄存器。

如何检测到前一条指令是lw ？
在D级检测E的流水线寄存器，MemtoRegE 是否enable，E级的目标寄存器rt是否和D级的rs rt相同。
``` verilog
  if (((RsD == RtE) || (RtD == RtE)) && MemtoRegE) begin

            StallD = 1;
            StallF = 1;
            FlushE = 1;

        end
```

如果我们的执行单元在D级（比如BEQ的相等检测），如何考虑重定向问题？
考虑如下指令
``` asm
add r1,r0,r3;
sub r2,r0,r4;
beq r1,r2,#LABEL;
```
流水线寄存器按照顺序加载指令，
beq处于D级的时候，add 和 sub 分别在E 和 M 级，
这个时候，r1和r2 都没有被写回，其中r2，刚开始执行写入到流水线寄存器EM（E级），
r1，虽然没有被写回，但是拿到了计算结果（M级），ALUOutM，所以我们可以利用重定向，
获取r1的值，但是r2还不能被解决，需要阻塞一次。

如果，我们在sub和beq之间，插入一条nop空指令，那么当beq处于D级的时候，
sub处于M级别，add处于W级，这种情况下，r2可以用重定向来解决，r1会在前半周期写入到寄存器，
并且在后半周期读到正确值。所以可以顺利解决这个数据冲突。

所以我们的数据重定向，对于D级的rs和rt，只能考虑ALUOutM;

```verilog
    
    
    if ((RsD!=0) && (RsD==WriteRegM) && RegWriteM)
        ForwardAD = 1'b1;
    else
        ForwardAD = 1'b0;

    if ((RtD!=0) && (RtD==WriteRegM) && RegWriteM)
        ForwardBD = 1'b1;
    else
        ForwardBD = 1'b0;

```
解决上述问题，还需要阻塞一次，以便两个操作数都准备好。
即，检测E级的流水线寄存器。D级的rs和rt是否和E级的写入寄存器一样。


```verilog
  if (BranchD && RegWriteE && (RsD == WriteRegE || RtD == WriteRegE)) begin
            StallD = 1;
            StallF = 1;
            FlushE = 1;
  end
```
为什么要有BranchD？
考虑这样一组指令
```asm
  add r1,r0,r3;
  sub r2,r0,r4;
  add r5,r1,r2;

```
第三条指令在D级，第二条在E级，第一条在M级。如果没有BranchD，那么，这三条指令会产生冲突，
并且阻塞一个周期，但是这个可以被重定向解决，所以BranchD用于区别beq和其他指令。

考虑如下指令
```asm

lw r1,r0(8);
add r2,r0,r4;
beq r1,r2,#LABEL;

```
beq处于D，add处于E，lw处于M级，这个时候会阻塞一次，从而
beq处于D，add处于M，lw处于W级。这个冲突可以被上述重定向来解决。
lw会在周期的开始写入到寄存器，后半周期读到r1，add会被ALUOutM重定向来解决。

如果我们交换lw和add 的顺序

```asm
 
  add r2,r0,r4;
  lw r1,r0(8);
  beq r1,r2,#LABEL;

```
beq处于D，lw处于E，add处于M级,这个时候会被阻塞一次。
beq处于D，lw处于M，add处于W级。add的r2成功写回，可以直接使用，
但是lw的r1还在M级，还不能使用，所以还需要阻塞一次，直到其到W级。

于是，我们需要检测D级的rs和rt 和 M级别的MemtoRegM是否enable和
rsD rtD 是不是和WriteRegM一样。

``` verilog
if  (BranchD && MemtoRegM && (RsD == WriteRegM || RtD == WriteRegM) ) begin

            StallD = 1;
            StallF = 1;
            FlushE = 1;
end

```
从而我们阻塞两个周期，来解决上述数据冲突。回到问题，为什么要BranchD？

```asm
 
  add r2,r0,r4;
  lw r1,r0(8);
  add r1,r2,#LABEL;

```
考虑这个代码顺序，
指令3处于D，指令2处于E，指令1处于M，从而阻塞一次。
然后 ，指令3处于D，指令2处于M，指令1处于W。
再下一个周期，指令3处于E，指令2处于W，指令1完成。
这个时候指令2的r1，可以通过重定向解决。如果不加BranchD，
则会在指令3处于D，指令2处于M，指令1处于W的时候再阻塞一次。


考虑将beq的检测放到E级
```asm
  add r2,r0,r4;
  lw r1,r0(8);
  beq r1,r2,#LABEL;
```
beq处于E，lw处于M，add处于W。
这个时候add的r2可以被重定向解决，但是lw需要到W级才行。
所以我们在D级阻塞一个周期。

即beq - D， lw - E， add - M， blocked 1；
beq - D， lw - M， add - W，next 1
beq - E， lw - W， add - ok 。

所以在这个设计中，可以把beq的相等检测放到D或E级，而不用修改冲突控制器。

此外，什么时候使用这些冲突阻塞信号？
  D级做冲突检测，如果阻塞则保持流水线寄存器PC和FD不变，并且刷掉DE。
  D级检测Jump指令，如果跳转，则刷掉FD。
  E级别检测BEQ，如果跳转，刷掉FD，DE。

# 这路刚刚开始,2022.4.10,特别感谢大王的咖啡支持。
