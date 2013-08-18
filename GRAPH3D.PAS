unit graph3d;


interface

uses dos, vectors, useful, bitmap;

const
  buffersize=64000;
  maxverticescount=10000;
  maxtrianglescount=5000;
  maxlightscount=10;

type
  tscrbuffer = array [0..buffersize-1] of byte;
  twbuffer = array [0..buffersize-1] of single;
  tobject = record
    firstvertex, lastvertex, firsttriangle, lasttriangle: longint;
    center: tvector;
    end;
  tmaterial = record
    color: byte;
    bitmap: tbitmap;
    end;
  ttriangle = record
    vertexid: array [1..3] of longint;
    tc: array [1..3] of array [1..2] of single;
    material: ^tmaterial;
    end;

procedure opengraph(ss, sw, sh: integer);
procedure closegraph;
procedure updatescreen;
procedure addlight(x, y, z: single);
function computelighting(n: longint): single;
function computelightingcolor(color: byte; l: single): byte;
procedure drawline(x1, y1, x2, y2: integer; color: byte);
procedure drawtriangle(x1, y1, x2, y2, x3, y3: integer; uz1, uz2, uz3: single; tcx1, tcy1, tcx2, tcy2, tcx3, tcy3: integer; mat: ^tmaterial; l: single);
procedure cameratoscreen(const v: tvector; var x, y: integer);
procedure render;
procedure moveobject(const v: tvector; var o: tobject);
procedure rotateobject(const c, n: tvector; a: single; var o: tobject);
procedure loadbitmap(var b: tbitmap; n: string);
procedure setmaterial(const o: tobject; var m: tmaterial);

var
  screen, buffer: ^tscrbuffer;
  wbuffer: ^twbuffer;
  scrsc, scrwidth, scrheight, trianglescount, verticescount: integer;
  vertex: array [1..maxverticescount] of tvector;
  triangle: array [1..maxtrianglescount] of ttriangle;
  light: array [1..maxlightscount] of tvector;
  lightscount: byte;


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
  {regs.ax:=$1017;
  regs.bx:=0;
  regs.cx:=256;
  regs.dx:=ofs(palette);
  regs.es:=seg(palette);
  intr($10, regs);  }
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

procedure addlight(x, y, z: single);
begin
  inc(lightscount);
  setvector(light[lightscount], x, y, z);
end;

function computelighting(n: longint): single;
var
  i: byte;
  v1, v2, v: tvector;
  l, tl: single;
begin
  with triangle[n] do
  begin
    v1[1]:=vertex[vertexid[2]][1]-vertex[vertexid[1]][1];
    v1[2]:=vertex[vertexid[2]][2]-vertex[vertexid[1]][2];
    v1[3]:=vertex[vertexid[2]][3]-vertex[vertexid[1]][3];
    v2[1]:=vertex[vertexid[3]][1]-vertex[vertexid[1]][1];
    v2[2]:=vertex[vertexid[3]][2]-vertex[vertexid[1]][2];
    v2[3]:=vertex[vertexid[3]][3]-vertex[vertexid[1]][3];
  end;
  vectorproduct(v1, v2, v);
  l:=0;
  for i:=1 to lightscount do
  begin
    tl:=vectoranglecos(v, light[i]);
    if tl>0 then l:=l+tl;
    if l>1 then l:=1;
    if l=1 then break;
  end;
  computelighting:=l;
end;

function computelightingcolor(color: byte; l: single): byte;
var
  i: byte;
begin
  if color<32 then
    computelightingcolor:=round((color-16)*l)+16
  else
    if l=0 then computelightingcolor:=0
    else
      begin
      i:=round((2-((color-32) div 72))*(1-l));
      computelightingcolor:=i shl 6 + i shl 3 + color;
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

procedure drawtriangle(x1, y1, x2, y2, x3, y3: integer; uz1, uz2, uz3: single; tcx1, tcy1, tcx2, tcy2, tcx3, tcy3: integer; mat: ^tmaterial; l: single);
var
  v1, v2, v: tvector;
  i, j, ti1, ti2, sj, t1, t2, s, ttcx1, ttcx2, ttcy1, ttcy2: integer;
  d1, d3, duz, duz1, duz3, tuz1, tuz2, tz, tn, z1, z2, z3, tz1, tz2: single;
begin
  v1[1]:=x2-x1; v1[2]:=y2-y1; v1[3]:=0;
  v2[1]:=x3-x1; v2[2]:=y3-y1; v2[3]:=0;
  vectorproduct(v1, v2, v);
  if v[3]<0 then
  begin
    if y1>y2 then begin swapi(y1, y2); swapi(x1, x2); swaps(uz1, uz2); swapi(tcx1, tcx2); swapi(tcy1, tcy2); end;
    if y2>y3 then
    begin
      swapi(y2, y3); swapi(x2, x3); swaps(uz2, uz3); swapi(tcx2, tcx3); swapi(tcy2, tcy3);
      if y1>y2 then begin swapi(y1, y2); swapi(x1, x2); swaps(uz1, uz2); swapi(tcx1, tcx2); swapi(tcy1, tcy2); end;
    end;
    s:=round(sqrt(sizeof(mat^.bitmap^)));
    z1:=1/uz1; z2:=1/uz2; z3:=1/uz3;
    duz3:=(uz3-uz1)/(y3-y1); duz1:=(uz2-uz1)/(y2-y1);
    d3:=(x3-x1)/(y3-y1); d1:=(x2-x1)/(y2-y1);
    ti1:=x1-round(y1*d1); ti2:=x1-round(y1*d3);
    sj:=y1*scrwidth;
    tuz1:=uz1; tuz2:=uz1;
    for j:=y1 to y2 do
      begin
      tz1:=1/tuz1; tz2:=1/tuz2;
      t1:=ti1+round(j*d1)+sj; t2:=ti2+round(j*d3)+sj;
      duz:=(tuz2-tuz1)/(t2-t1);
      tn:=(tz1-z1)/(z2-z1);
      ttcx1:=tcx1+round((tcx2-tcx1)*tn); ttcy1:=tcy1+round((tcy2-tcy1)*tn);
      tn:=(tz2-z1)/(z3-z1);
      ttcx2:=tcx1+round((tcx3-tcx1)*tn); ttcy2:=tcy1+round((tcy3-tcy1)*tn);
      if t1>t2 then
      begin
        tz:=(t2-t1)*duz+tuz1;
        swapi(t1, t2);
      end
      else tz:=tuz1;
      for i:=t1 to t2-1 do
        begin
        tn:=(1/tz-tz1)/(tz2-tz1);
        if tz>wbuffer^[i] then
          begin
          buffer^[i]:=computelightingcolor(mat^.bitmap^[ttcx1+round((ttcx2-ttcx1)*tn)+s*round((ttcy1+(ttcy2-ttcy1)*tn))], l);
          wbuffer^[i]:=tz;
          end;
        tz:=tz+duz;
        end;
      sj:=sj+scrwidth;
      tuz1:=tuz1+duz1; tuz2:=tuz2+duz3;
      end;
    duz1:=(uz3-uz2)/(y3-y2);
    d1:=(x3-x2)/(y3-y2);
    ti1:=x3-round(y3*d1); ti2:=x3-round(y3*d3);
    tuz1:=uz2; tuz2:=uz1+(y2-y1)*duz3;
    for j:=y2+1 to y3 do
      begin
      t1:=ti1+round(j*d1)+sj; t2:=ti2+round(j*d3)+sj;
      tuz1:=tuz1+duz1; tuz2:=tuz2+duz3;
      tz1:=1/tuz1; tz2:=1/tuz2;
      duz:=(tuz2-tuz1)/(t2-t1);
      tn:=(tz1-z2)/(z3-z2);
      ttcx1:=tcx2+round((tcx3-tcx2)*tn); ttcy1:=tcy2+round((tcy3-tcy2)*tn);
      tn:=(tz2-z1)/(z3-z1);
      ttcx2:=tcx1+round((tcx3-tcx1)*tn); ttcy2:=tcy1+round((tcy3-tcy1)*tn);
      if t1>t2 then
      begin
        tz:=(t2-t1)*duz+tuz1;
        swapi(t1, t2);
      end
      else tz:=tuz1;
      for i:=t1 to t2-1 do
        begin
        tn:=(1/tz-tz1)/(tz2-tz1);
        if tz>wbuffer^[i] then
          begin
          buffer^[i]:=computelightingcolor(mat^.bitmap^[ttcx1+round((ttcx2-ttcx1)*tn)+s*round((ttcy1+(ttcy2-ttcy1)*tn))], l);
          wbuffer^[i]:=tz;
          end;
        tz:=tz+duz;
        end;
      sj:=sj+scrwidth;
      end;
  end;
end;

procedure cameratoscreen(const v: tvector; var x, y: integer);
var
    v3: single;
begin
    v3:=scrsc/v[3];
  x:=(scrwidth shr 1)+round(v3*v[1]);
  y:=(scrheight shr 1)-round(v3*v[2]);
end;

procedure render;
var
  m: array [1..maxverticescount] of array [1..2] of integer;
  i, s: integer;
begin
  for i:=1 to verticescount do
    cameratoscreen(vertex[i], m[i][1], m[i][2]);
  for i:=1 to trianglescount do
    with triangle[i] do
      begin
      s:=round(sqrt(sizeof(material^.bitmap^)))-1;
      drawtriangle(m[vertexid[1]][1], m[vertexid[1]][2],
                   m[vertexid[2]][1], m[vertexid[2]][2],
                   m[vertexid[3]][1], m[vertexid[3]][2],
                   1/vertex[vertexid[1]][3], 1/vertex[vertexid[2]][3], 1/vertex[vertexid[3]][3],
                   round(tc[1][1]*s), round(tc[1][2]*s), round(tc[2][1]*s), round(tc[2][2]*s), round(tc[3][1]*s), round(tc[3][2]*s),
                   material, computelighting(i));
      end;
  updatescreen;
end;

procedure moveobject(const v: tvector; var o: tobject);
var
  i: integer;
begin
  for i:=o.firstvertex to o.lastvertex do
    addvector(v, vertex[i], vertex[i]);
  addvector(v, o.center, o.center);
end;

procedure rotateobject(const c, n: tvector; a: single; var o: tobject);
var
  i: integer;
begin
  for i:=o.firstvertex to o.lastvertex do
    rotatevector(c, n, a, vertex[i]);
  rotatevector(c, n, a, o.center);
end;

procedure loadbitmap(var b: tbitmap; n: string);
var
  p: tpalette;
  t: string;
begin
t:=n;
delete(t, 1, length(n)-3);
if t='bmp' then
bmpload(b, p, n);
end;

procedure setmaterial(const o: tobject; var m: tmaterial);
var
  i: integer;
begin
for i:=o.firsttriangle to o.lasttriangle do
  triangle[i].material:=@m;
end;

end.