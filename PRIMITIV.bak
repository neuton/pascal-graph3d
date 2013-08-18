unit primitiv;


interface

uses graph3d, vectors;

procedure make_pyramid(var o: tobject; s: single);
procedure make_cube(var o: tobject; s: single);
procedure make_cone(var o: tobject; h, r: single; c: integer);


implementation

procedure make_pyramid(var o: tobject; s: single);
var
  a, b, c, d: integer;
  t: array [1..4] of integer;
begin
  for a:=1 to 4 do
    t[a]:=a+trianglescount;
  a:=verticescount+1; b:=a+1; c:=b+1; d:=c+1;
  with o do
  begin
    setvector(vertex[a], 0, 0, 0);
    setvector(vertex[b], s, 0, 0);
    setvector(vertex[c], 0, s, 0);
    setvector(vertex[d], 0, 0, s);
    setvector(center, 0, 0, 0);
    triangle[t[1]][1]:=a; triangle[t[1]][2]:=b; triangle[t[1]][3]:=c;
    triangle[t[2]][1]:=a; triangle[t[2]][2]:=c; triangle[t[2]][3]:=d;
    triangle[t[3]][1]:=a; triangle[t[3]][2]:=d; triangle[t[3]][3]:=b;
    triangle[t[4]][1]:=b; triangle[t[4]][2]:=d; triangle[t[4]][3]:=c;
    for a:=1 to 4 do
      triangle[t[a]][4]:=31+random(72);
    firstvertex:=verticescount+1;
    firsttriangle:=trianglescount+1;
    verticescount:=verticescount+4;
    trianglescount:=trianglescount+4;
    lastvertex:=verticescount;
    lasttriangle:=trianglescount;
  end;
end;

procedure make_cube(var o: tobject; s: single);
var
  a, b, c, d, e, f, g, h: integer;
  t: array [1..12] of integer;
begin
  s:=s/2;
  for a:=1 to 12 do
    t[a]:=a+trianglescount;
  a:=verticescount+1; b:=a+1; c:=b+1; d:=c+1; e:=d+1; f:=e+1; g:=f+1; h:=g+1;
  with o do
  begin
    setvector(vertex[a], s, s, -s);
    setvector(vertex[b], s, s, s);
    setvector(vertex[c], -s, s, s);
    setvector(vertex[d], -s, s, -s);
    setvector(vertex[e], s, -s, -s);
    setvector(vertex[f], s, -s, s);
    setvector(vertex[g], -s, -s, s);
    setvector(vertex[h], -s, -s, -s);
    setvector(center, 0, 0, 0);
    triangle[t[1]][1]:=a; triangle[t[1]][2]:=b; triangle[t[1]][3]:=c;
    triangle[t[2]][1]:=a; triangle[t[2]][2]:=c; triangle[t[2]][3]:=d;
    triangle[t[3]][1]:=e; triangle[t[3]][2]:=a; triangle[t[3]][3]:=d;
    triangle[t[4]][1]:=e; triangle[t[4]][2]:=d; triangle[t[4]][3]:=h;
    triangle[t[5]][1]:=h; triangle[t[5]][2]:=d; triangle[t[5]][3]:=c;
    triangle[t[6]][1]:=h; triangle[t[6]][2]:=c; triangle[t[6]][3]:=g;
    triangle[t[7]][1]:=g; triangle[t[7]][2]:=c; triangle[t[7]][3]:=b;
    triangle[t[8]][1]:=g; triangle[t[8]][2]:=b; triangle[t[8]][3]:=f;
    triangle[t[9]][1]:=f; triangle[t[9]][2]:=b; triangle[t[9]][3]:=a;
    triangle[t[10]][1]:=f; triangle[t[10]][2]:=a; triangle[t[10]][3]:=e;
    triangle[t[11]][1]:=e; triangle[t[11]][2]:=h; triangle[t[11]][3]:=g;
    triangle[t[12]][1]:=e; triangle[t[12]][2]:=g; triangle[t[12]][3]:=f;
    for a:=1 to 12 do
      triangle[t[a]][4]:=31;
    firstvertex:=verticescount+1;
    firsttriangle:=trianglescount+1;
    verticescount:=verticescount+8;
    trianglescount:=trianglescount+12;
    lastvertex:=verticescount;
    lasttriangle:=trianglescount;
  end;
end;

procedure make_cone(var o: tobject; h, r: single; c: integer);
begin

end;

end.