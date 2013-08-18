Program SetModer;

Uses DOS, crt;

Var Regs:Registers;
i, j: longint;

Procedure SetBlock(Block:Word);
Begin
Regs.ax:=$4F05;
Regs.bx:=$0000;
Regs.dx:=Block;
Intr($10,Regs);
End;

Procedure SetPixel(Offset,Color:LongInt);
Type TLongInt=Record
WordL,WordH:Word;
End;
Begin
SetBlock(TLongInt(Offset).WordH);
MemL[$A000:TLongInt(Offset).WordL]:=Color;
End;

Procedure PutPixel(x,y:Word;Color:LongInt);
Begin
SetPixel((LongInt(y)*1024+x)*4,Color); { 1024 - ширина }
End;


BEGIN
Regs.ax:=$4F02;
Regs.bx:=$0118; { Или $0123 }
Intr($10,Regs);
for i:=0 to 1023 do
for j:=0 to 767 do
PutPixel(i,j,i); { Точка в центре }
repeat until keypressed;
  regs.ah:=$00;
  regs.al:=$03;
  intr($10, regs);
END.