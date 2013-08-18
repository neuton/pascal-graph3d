unit graph3d;


interface

uses dos, vectors, useful;

const
  buffersize=64000;

type
  tscrbuffer = array [0..buffersize-1] of byte;
  twbuffer = array [0..buffersize-1] of single;
  tobject = record
    firstvertex, lastvertex, firsttriangle, lasttriangle: integer;
    center: tvector;
  end;

procedure opengraph(ss, sw, sh: integer);
procedure closegraph;
procedure updatescreen;
procedure drawline(x1, y1, x2, y2: integer; color: byte);
procedure drawtriangle(x1, y1, x2, y2, x3, y3: integer; uz1, uz2, uz3: single; color: byte);
procedure cameratoscreen(v: tvector; var x, y: integer);
procedure render;
procedure rotateobject(c, n: tvector; a: single; var o: tobject);

var
  screen, buffer: ^tscrbuffer;
  wbuffer: ^twbuffer;
  scrsc, scrwidth, scrheight, trianglescount, verticescount: integer;
  vertex: array [1..1000] of tvector;
  triangle: array [1..1000] of array [1..4] of integer;


implementation

procedure opengraph(ss, sw, sh: integer);
var
  regs: registers;
begin
  scrsc:=ss;
  scrwidth:=sw;
  scrheight:=sh;
  regs.ah:=$00;
  regs.al:=$13;
  intr($10, regs);
  screen:=ptr($a000, 0);
  new(buffer);
  new(wbuffer);
end;

procedure closegraph;
var
  regs: registers;
begin
  regs.ah:=$00;
  regs.al:=$03;
  intr($10, regs);
  dispose(buffer);
  buffer:=nil;
  dispose(wbuffer);
  wbuffer:=nil;
end;

procedure updatescreen;
var
  i: longint;
begin
  for i:=buffersize-1 downto 0 do
  begin
    screen^[i]:=buffer^[i];
    buffer^[i]:=0;
    wbuffer^[i]:=0;
  end;
end;

procedure drawline(x1, y1, x2, y2: integer; color: byte);
var
  d: single;
  i, dx, dy: integer;
begin
  dx:=x2-x1;
  dy:=y2-y1;
  if abs(dx)>=abs(dy) then
  begin
    d:=dy/dx;
    if x1>x2 then begin swapi(x1, x2); swapi(y1, y2); end;
    for i:=x2-x1 downto 0 do
      buffer^[x1+i+round(d*i+y1)*scrwidth]:=color;
  end
  else
  begin
    d:=dx/dy;
    if y1>y2 then begin swapi(x1, x2); swapi(y1, y2); end;
    for i:=y2-y1 downto 0 do
      buffer^[round(d*i+x1)+(y1+i)*scrwidth]:=color;
  end;
end;

procedure drawtriangle(x1, y1, x2, y2, x3, y3: integer; uz1, uz2, uz3: single; color: byte);
var
  v1, v2, v: tvector;
  i, j, ti1, ti2, sj, t1, t2: integer;
  d1, d3, duz, duz1, duz3, tuz1, tuz2, tz: single;
begin
  v1[1]:=x2-x1; v1[2]:=y2-y1; v1[3]:=0;
  v2[1]:=x3-x1; v2[2]:=y3-y1; v2[3]:=0;
  vectorproduct(v1, v2, v);
  if v[3]<0 then
  begin
    if y1>y2 then begin swapi(y1, y2); swapi(x1, x2); swaps(uz1, uz2); end;
    if y2>y3 then
    begin
      swapi(y2, y3); swapi(x2, x3); swaps(uz2, uz3);
      if y1>y2 then begin swapi(y1, y2); swapi(x1, x2); swaps(uz1, uz2); end;
    end;
    duz3:=(uz3-uz1)/(y3-y1);
    duz1:=(uz2-uz1)/(y2-y1);
    d3:=(x3-x1)/(y3-y1);
    d1:=(x2-x1)/(y2-y1);
    ti1:=x1-round(y1*d1);
    ti2:=x1-round(y1*d3);
    sj:=y1*scrwidth;
    for j:=y1 to y2 do
      begin
      t1:=ti1+round(j*d1)+sj;
      t2:=ti2+round(j*d3)+sj;
      tuz1:=uz1+(j-y1)*duz1;
      tuz2:=uz1+(j-y1)*duz3;
      duz:=(tuz2-tuz1)/(t2-t1);
      if t1<t2 then
      for i:=t1 to t2 do
        begin
        tz:=(i-t1)*duz+tuz1;
        if tz>wbuffer^[i] then
          begin
          buffer^[i]:=color;
          wbuffer^[i]:=tz;
          end;
        end
      else
      for i:=t2 to t1 do
        begin
        tz:=(i-t1)*duz+tuz1;
        if tz>wbuffer^[i] then
          begin
          buffer^[i]:=color;
          wbuffer^[i]:=tz;
          end;
        end;
      sj:=sj+scrwidth;
      end;
    duz1:=(uz3-uz2)/(y3-y2);
    d1:=(x3-x2)/(y3-y2);
    ti1:=x3-round(y3*d1);
    ti2:=x3-round(y3*d3);
    sj:=y2*scrwidth;
    for j:=y2 to y3 do
      begin
      t1:=ti1+round(j*d1)+sj;
      t2:=ti2+round(j*d3)+sj;
      tuz1:=uz2+(j-y2)*duz1;
      tuz2:=uz1+(j-y1)*duz3;
      duz:=(tuz2-tuz1)/(t2-t1);
      if t1<t2 then
      for i:=t1 to t2 do
        begin
        tz:=(i-t1)*duz+tuz1;
        if tz>wbuffer^[i] then
          begin
          buffer^[i]:=color;
          wbuffer^[i]:=tz;
          end;
        end
      else
      for i:=t2 to t1 do
        begin
        tz:=(i-t1)*duz+tuz1;
        if tz>wbuffer^[i] then
          begin
          buffer^[i]:=color;
          wbuffer^[i]:=tz;
          end;
        end;
      sj:=sj+scrwidth;
      end;
  end;
end;

procedure cameratoscreen(v: tvector; var x, y: integer);
var
    v3: single;
begin
    v3:=scrsc/v[3];
  x:=(scrwidth shr 1)+round(v3*v[1]);
  y:=(scrheight shr 1)-round(v3*v[2]);
end;

procedure render;
var
  m: array [1..1000] of array [1..2] of integer;
  i: integer;
begin
  for i:=1 to verticescount do
    cameratoscreen(vertex[i], m[i][1], m[i][2]);
  for i:=1 to trianglescount do
    drawtriangle(m[triangle[i][1]][1], m[triangle[i][1]][2],
        m[triangle[i][2]][1], m[triangle[i][2]][2],
        m[triangle[i][3]][1], m[triangle[i][3]][2],
        1/vertex[triangle[i][1]][3], 1/vertex[triangle[i][2]][3], 1/vertex[triangle[i][3]][3],
        triangle[i][4]);
  updatescreen;
end;

procedure rotateobject(c, n: tvector; a: single; var o: tobject);
var
  i: integer;
begin
  for i:=o.firstvertex to o.lastvertex do
    rotatevector(c, n, a, vertex[i]);
end;

end.