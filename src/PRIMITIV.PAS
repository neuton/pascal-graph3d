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
    setvector(position, 0, 0, 0);
    setvector(direction, 1, 0, 0);
    setvector(up, 0, 0, 1);
    triangle[t[1]].vertexid[1]:=a; triangle[t[1]].vertexid[2]:=b; triangle[t[1]].vertexid[3]:=c;
    triangle[t[2]].vertexid[1]:=a; triangle[t[2]].vertexid[2]:=c; triangle[t[2]].vertexid[3]:=d;
    triangle[t[3]].vertexid[1]:=a; triangle[t[3]].vertexid[2]:=d; triangle[t[3]].vertexid[3]:=b;
    triangle[t[4]].vertexid[1]:=b; triangle[t[4]].vertexid[2]:=d; triangle[t[4]].vertexid[3]:=c;
    firstvertex:=verticescount+1;
    firsttriangle:=trianglescount+1;
    verticescount:=verticescount+4;
    trianglescount:=trianglescount+4;
    lastvertex:=verticescount;
    lasttriangle:=trianglescount;
    show;
  end;
end;

procedure make_cube(var o: tobject; s: single);
var
  a, b, c, d, e, f, g, h: integer;
  t: array [1..12] of integer;
  at, bt, ct, dt: array [1..2] of single;
begin
  s:=s/2;
  for a:=1 to 12 do
    t[a]:=a+trianglescount;
  a:=verticescount+1; b:=a+1; c:=b+1; d:=c+1; e:=d+1; f:=e+1; g:=f+1; h:=g+1;
  at[1]:=0; at[2]:=1; bt[1]:=0; bt[2]:=0; ct[1]:=1; ct[2]:=0; dt[1]:=1; dt[2]:=1;
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
    setvector(position, 0, 0, 0);
    setvector(direction, 1, 0, 0);
    setvector(up, 0, 0, 1);
    with triangle[t[1]] do
    begin
      vertexid[1]:=a; vertexid[2]:=b; vertexid[3]:=c;
      //tc[1][1]:=0; tc[1][2]:=1; tc[2][1]:=0; tc[2][2]:=0; tc[3][1]:=1; tc[3][2]:=0;
      tc[1]:=at; tc[2]:=bt; tc[3]:=ct;
    end;
    with triangle[t[2]] do
    begin
      vertexid[1]:=a; vertexid[2]:=c; vertexid[3]:=d;
      tc[1]:=at; tc[2]:=ct; tc[3]:=dt;
    end;
    with triangle[t[3]] do
    begin
      vertexid[1]:=e; vertexid[2]:=a; vertexid[3]:=d;
      tc[1]:=at; tc[2]:=bt; tc[3]:=ct;
    end;
    with triangle[t[4]] do
    begin
      vertexid[1]:=e; vertexid[2]:=d; vertexid[3]:=h;
      tc[1]:=at; tc[2]:=ct; tc[3]:=dt;
    end;
    with triangle[t[5]] do
    begin
      vertexid[1]:=h; vertexid[2]:=d; vertexid[3]:=c;
      tc[1]:=at; tc[2]:=bt; tc[3]:=ct;
    end;
    with triangle[t[6]] do
    begin
      vertexid[1]:=h; vertexid[2]:=c; vertexid[3]:=g;
      tc[1]:=at; tc[2]:=ct; tc[3]:=dt;
    end;
    with triangle[t[7]] do
    begin
      vertexid[1]:=g; vertexid[2]:=c; vertexid[3]:=b;
      tc[1]:=at; tc[2]:=bt; tc[3]:=ct;
    end;
    with triangle[t[8]] do
    begin
      vertexid[1]:=g; vertexid[2]:=b; vertexid[3]:=f;
      tc[1]:=at; tc[2]:=ct; tc[3]:=dt;
    end;
    with triangle[t[9]] do
    begin
      vertexid[1]:=f; vertexid[2]:=b; vertexid[3]:=a;
      tc[1]:=at; tc[2]:=bt; tc[3]:=ct;
    end;
    with triangle[t[10]] do
    begin
      vertexid[1]:=f; vertexid[2]:=a; vertexid[3]:=e;
      tc[1]:=at; tc[2]:=ct; tc[3]:=dt;
    end;
    with triangle[t[11]] do
    begin
      vertexid[1]:=e; vertexid[2]:=h; vertexid[3]:=g;
      tc[1]:=at; tc[2]:=bt; tc[3]:=ct;
    end;
    with triangle[t[12]] do
    begin
      vertexid[1]:=e; vertexid[2]:=g; vertexid[3]:=f;
      tc[1]:=at; tc[2]:=ct; tc[3]:=dt;
    end;
    {for a:=1 to 12 do
      triangle[t[a]].color:=31{31+random(72)};
    firstvertex:=verticescount+1;
    firsttriangle:=trianglescount+1;
    verticescount:=verticescount+8;
    trianglescount:=trianglescount+12;
    lastvertex:=verticescount;
    lasttriangle:=trianglescount;
    show;
  end;
end;

procedure make_cone(var o: tobject; h, r: single; c: integer);
begin

end;

end.