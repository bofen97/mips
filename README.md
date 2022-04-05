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

- 控制信号决定了 DataPath 的数据流向，生成过程抽象来看是 OPCode -> DataPath control signal && ALUOp signal -> **ALUOp signal** or **funct** -> alucontrol 。

  **_example_**

  ```reStructuredText
  对于R type 指令，opcode是000000，其aluop signal是 10，即，需要根据funct来选择 aluop add sub or and e.t.
  对于I type 指令，opcode不同，aluop也不一定相同。
  
  ```

### Tips

对于 I type 指令，需要对 imm 进行符号扩展，16->32。对于逻辑 op，往往需要 0 扩展。





## 多周期处理器

### 设计一个控制器

#### 在指令周期的开始，cycle 1。  Fetch S0
IorD = 0 
MemWrite = 0 
IRWrite = 1
PCWrite = 1
Branch = 0 
PCSrc  = 2'b00 
ALUOp =  2'b00
ALUSrcB = 2'b01
ALUSrcA = 0
RegWrite = 0
RegDst = 0
MemToReg = 0

在这个时钟周期，已经拿到了pcnext = pc+ 4 , Instr寄存器;




#### decode ，cycle 2。  Decode S1
IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0 
PCSrc  = 2'b00 
ALUOp =  2'b00
ALUSrcB = 2'b11
ALUSrcA = 0
RegWrite = 0
RegDst = 0
MemToReg = 0

decode，并且计算出 pc + SignImml2 放到ALUResult。
假设下一条指令是beq，否则ALUResult会被覆盖丢弃。

#### LW or SW ，cycle 3   MemAdr S2         
IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0 
PCSrc  = 2'b00 
ALUOp =  2'b00
ALUSrcB = 2'b10
ALUSrcA = 1
RegWrite = 0
RegDst = 0
MemToReg = 0

计算出源寄存器和立即数的结果到ALUResult，上一步中的结果pc + SignImml2 会流向ALUOUt。


#### LW，cycle 4      MemRead S3             

IorD = 1           
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0 
PCSrc  = 2'b00 
ALUOp = 2'b00
ALUSrcB = 2'b00 
ALUSrcA = 0
RegWrite = 0
RegDst = 0
MemToReg = 0

这个cycle中，源寄存器和立即数的ALUResult流向ALUout。
从而在下一步中将memory RD 写入到Data。



#### SW，cycle 4      MemWrite S5             


IorD = 1           
MemWrite = 1 
IRWrite = 0
PCWrite = 0
Branch = 0 
PCSrc  = 2'b00 
ALUOp =  2'b00
ALUSrcB = 2'b00 
ALUSrcA = 0
RegWrite = 0
RegDst = 0
MemToReg = 0

这个cycle中，源寄存器和立即数的ALUResult流向ALUout。



#### LW cycle 5   MemWriteBack S4

IorD = 0
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0 
PCSrc  = 2'b00 
ALUOp =  2'b00
ALUSrcB = 2'b00 
ALUSrcA = 0
RegWrite = 1
RegDst = 0
MemToReg = 1

memory RD的数据写入到Data。



#### R Type ，cycle 3   Execute S6         
IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0 
PCSrc  = 2'b00 
ALUOp =  2'b10
ALUSrcB = 2'b00
ALUSrcA = 1
RegWrite = 0
RegDst = 0
MemToReg = 0

#### R Type ，cycle 4   ALUWriteBack S7         
IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0 
PCSrc  = 2'b00 
ALUOp =  2'b00
ALUSrcB = 2'b00
ALUSrcA = 0
RegWrite = 1
RegDst = 1
MemToReg = 0


#### BEQ ， cycle 3  Branch S8

IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 1
PCSrc  = 2'b01 
ALUOp =  2'b01 
ALUSrcB = 2'b00
ALUSrcA = 1
RegWrite = 0
RegDst = 0
MemToReg = 0

#### BEQ ， cycle 3  ADDI S9


IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0
PCSrc  = 2'b00 
ALUOp =  2'b00 
ALUSrcB = 2'b10
ALUSrcA = 1
RegWrite = 0
RegDst = 0
MemToReg = 0

#### BEQ ， cycle 4 ADDI WriteBack   S10
IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 0
Branch = 0
PCSrc  = 2'b00 
ALUOp =  2'b00 
ALUSrcB = 2'b00
ALUSrcA = 0
RegWrite = 1
RegDst = 0
MemToReg = 0

#### BEQ ， cycle 3 Jump   S11
IorD = 0 
MemWrite = 0 
IRWrite = 0
PCWrite = 1
Branch = 0
PCSrc  = 2'b10
ALUOp =  2'b00 
ALUSrcB = 2'b00
ALUSrcA = 0
RegWrite = 0
RegDst = 0
MemToReg = 0