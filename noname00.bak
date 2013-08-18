Program SetModer;

Uses DOS, crt;

Type TLongInt=Record
WordL,WordH:Word;
End;

Var Regs:Registers;
i, j: longint;
bl: word;

Procedure SetBlock(Block:Word);
Begin
Regs.ax:=$4F05;
Regs.bx:=$0000;
Regs.dx:=Block;
Intr($10,Regs);
End;

Procedure SetPixel(Offset,Color:LongInt);
var
  b: word;
Begin
{b:=TLongInt(Offset).WordH;
if b<>bl then
begin
  SetBlock(b);
  bl:=b;
end; }
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