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