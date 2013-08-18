unit graph3d;




interface


uses dos, vectors, useful, bitmap;


const
  buffersize=64000;
  maxverticescount=1000;
  maxtrianglescount=1000;
  maxlightscount=10;
  precision=0.0001;


type
  tscrbuffer = array [0..buffersize-1] of byte;
  twbuffer = array [0..buffersize-1] of single;
  tcamera = record
    position, direction, up: tvector;
    end;
  tmaterial = record
    color, width: byte;
    bitmap, bumpmap: tbitmap;
    end;
  tobject = object
    firstvertex, lastvertex, firsttriangle, lasttriangle: longint;
    position, direction, up: tvector;
    procedure show;
    procedure hide;
    procedure move(const v: tvector);
    procedure rotate(const c, n: tvector; a: single);
    procedure setposition(const p: tvector);
    procedure setdirection(const d: tvector);
    procedure setup(const u: tvector);
    procedure setmaterial(var m: tmaterial);
    end;
  ttriangle = record
    visible: boolean;
    vertexid: array [1..3] of longint;
    tc: array [1..3] of array [1..2] of single;
    material: ^tmaterial;
    end;


procedure opengraph(ss, sw, sh: integer);
procedure closegraph;
procedure updatescreen;
procedure addlight(const p: tvector);
function computelighting(n: longint): single;
function computelightingcolor(color: byte; l: single): byte;
procedure drawline(x1, y1, x2, y2: integer; color: byte);
procedure drawtriangle(n: integer);
procedure worldtocamera(const x: tvector; var v: tvector);
procedure cameratoscreen(const v: tvector; var x, y: integer);
procedure worldtoscreen(const v: tvector; var x, y: integer );
procedure rendertobuffer;
procedure render;
procedure loadbitmap(var b: tbitmap; var w: byte; n: string);


var
  screen, buffer: ^tscrbuffer;
  wbuffer: ^twbuffer;
  scrsc, scrwidth, scrheight, trianglescount, verticescount: integer;
  vertex: array [1..maxverticescount] of tvector;
  scrvertex: array [1..maxverticescount] of array [1..2] of integer;
  zvertex: array [1..maxverticescount] of single;
  triangle: array [1..maxtrianglescount] of ttriangle;
  light: array [1..maxlightscount] of tvector;
  lightscount, backgroundcolor: byte;
  camera: tcamera;




implementation



procedure tobject.show;
var
  i: longint;
begin
  for i:=firsttriangle to lasttriangle do
    triangle[i].visible:=true;
end;


procedure tobject.hide;
var
  i: longint;
begin
  for i:=firsttriangle to lasttriangle do
    triangle[i].visible:=false;
end;


procedure tobject.move(const v: tvector);
var
  i: integer;
begin
  for i:=firstvertex to lastvertex do
    addvector(v, vertex[i], vertex[i]);
  addvector(v, position, position);
end;


procedure tobject.rotate(const c, n: tvector; a: single);
var
  i: integer;
  v: tvector;
begin
  for i:=firstvertex to lastvertex do
    rotatevector(c, n, a, vertex[i]);
  rotatevector(c, n, a, position);
  nullvector(v);
  rotatevector(v, n, a, direction);
  rotatevector(v, n, a, up);
end;

procedure tobject.setposition(const p: tvector);
var
  v: tvector;
begin
  subtractvector(p, position, v);
  move(v);
end;


procedure tobject.setdirection(const d: tvector);
var
  v, v1: tvector;
  l: single;
begin
{  subtractvector(d, direction, v1);
  l:=vectorlength(v1);
  if l>precision then
  begin
    if 2-l>precision then
    begin
      subtractvector(d, up, v1);
      l:=vectorlength(v1);
      if (l>precision) and (2-l>precision) then
      begin
        vectorproduct(d, up, v1);
        vectorproduct(up, v1, v);
        normalizevector(v);
        subtractvector(v, direction, v1);
        l:=vectorlength(v1);
        if l>precision then
        begin
          if 2-l>precision then
          begin
            vectorproduct(direction, v, v1);
            normalizevector(v1);
            rotate(position, v1, vectorangle(direction, v));
          end
          else
            rotate(position, up, pi);
        end;
        subtractvector(d, direction, v1);
        if vectorlength(v1)>precision then
        begin
          vectorproduct(direction, d, v1);
          normalizevector(v1);
          rotate(position, v1, vectorangle(direction, d));
        end;
      end
      else
      begin
        vectorproduct(direction, d, v1);
        normalizevector(v1);
        rotate(position, v1, pi/2);
      end;
    end
    else
      rotate(position, up, pi);
  end;                           }
end;


procedure tobject.setup(const u: tvector);
var
  v, v1: tvector;
  l: single;
begin
{  subtractvector(u, up, v1);
  l:=vectorlength(v1);
  if l>precision then
  begin
    if 2-l>precision then
    begin
      subtractvector(u, direction, v1);
      l:=vectorlength(v1);
      if (l>precision) and (2-l>precision) then
      begin
        vectorproduct(u, direction, v1);
        vectorproduct(direction, v1, v);
        normalizevector(v);
        subtractvector(v, u, v1);
        l:=vectorlength(v1);
        if l>precision then
        begin
          if 2-l>precision then
          begin
            vectorproduct(up, v, v1);
            normalizevector(v1);
            rotate(position, v1, vectorangle(up, v));
          end
          else
            rotate(position, direction, pi);
        end;
      end;
    end
    else
      rotate(position, direction, pi);
  end;                                      }
end;


procedure tobject.setmaterial(var m: tmaterial);
var
  i: integer;
begin
  for i:=firsttriangle to lasttriangle do
    triangle[i].material:=@m;
end;



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
  trianglescount:=0;
  verticescount:=0;
  lightscount:=0;
  backgroundcolor:=0;
  with camera do
  begin
    setvector(position, 0, 0, 0);
    setvector(direction, 0, 1, 0);
    setvector(up, 0, 0, 1);
  end;
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
    buffer^[i]:=backgroundcolor;
    wbuffer^[i]:=0;
  end;
end;


procedure addlight(const p: tvector);
begin
  inc(lightscount);
  light[lightscount]:=p;
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
  normalizevector(v);
  l:=0;
  for i:=1 to lightscount do
  begin
    tl:=vectordotproduct(v, light[i]);
    if tl>0 then l:=l+tl;
    if l>=1 then begin l:=1; break; end;
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


procedure drawtriangle(n: integer);

var
  v1, v2, v3, v: tvector;
  x1, y1, x2, y2, x3, y3, tcx1, tcy1, tcx2, tcy2, tcx3, tcy3, i, j, ti1, ti2, sj, t1, t2, w, dcx, dcy, dcx1, dcy1, dcx2, dcy2: integer;
  p: longint;
  ttcx1, ttcx2, ttcy1, ttcy2, cl, k: byte;
  uz1, uz2, uz3, d1, d3, duz, duz1, duz3, tuz1, tuz2, tz, tn, z1, z2, z3, tz1, tz2, dtz, dtz1, l, t, tl, dz, dz1, dz2, dy, dy1, dy2, j1, j3: single;
  btm, bmm: tbitmap;
  bump: boolean;
  normlight: array [1..maxlightscount] of tvector;
  drawstring: procedure;

function computebump: single;
begin
  setvector(v, (bmm^[p-1]-bmm^[p])/128, 1, (bmm^[p-w]-bmm^[p])/128);
  normalizevector(v);
  t:=0;
  for k:=1 to lightscount do
  begin
    tl:=vectordotproduct(v, normlight[k]);
    if tl>0 then t:=t+tl;
    if t>=1 then begin t:=1; break; end;
  end;
  computebump:=t;
end;

procedure drawcoloredstring; far;
begin
  if t1>t2 then
  begin
    tz:=(t2-t1)*duz+tuz1;
    swapi(t1, t2);
  end
  else tz:=tuz1;
  for i:=t1 to t2-1 do
  begin
    if tz>wbuffer^[i] then
    begin
      buffer^[i]:=cl;
      wbuffer^[i]:=tz;
    end;
    tz:=tz+duz;
  end;
end;

procedure drawtexturedstring; far;
begin
  if t1>t2 then
  begin
    tz:=(t2-t1)*duz+tuz1;
    swapi(t1, t2);
  end
  else tz:=tuz1;
  if abs(tz2-tz1)<precision then
  begin
    tn:=(j-dy)*dy1;
    ttcx1:=dcx+trunc(dcx1*tn); ttcy1:=dcy+trunc(dcy1*tn);
    tn:=(j-y1)*dy2;
    ttcx2:=tcx1+trunc(dcx2*tn); ttcy2:=tcy1+trunc(dcy2*tn);
    dtz:=1/(t2-t1);
    tn:=0;
    for i:=t1 to t2-1 do
    begin
      if tz>wbuffer^[i] then
      begin
        p:=ttcx1+trunc((ttcx2-ttcx1)*tn)+w*trunc((ttcy1+(ttcy2-ttcy1)*tn));
        if bump then l:=computebump;
        buffer^[i]:=computelightingcolor(btm^[p], l);
        wbuffer^[i]:=tz;
      end;
      tn:=tn+dtz;
      tz:=tz+duz;
    end;
  end
  else
  begin
    tn:=(tz1-dz)*dz1;
    ttcx1:=dcx+trunc(dcx1*tn); ttcy1:=dcy+trunc(dcy1*tn);
    tn:=(tz2-z1)*dz2;
    ttcx2:=tcx1+trunc(dcx2*tn); ttcy2:=tcy1+trunc(dcy2*tn);
    dtz:=1/(tz2-tz1);
    dtz1:=tz1*dtz;
    for i:=t1 to t2-1 do
    begin
      tn:=dtz/tz-dtz1;
      if tz>wbuffer^[i] then
      begin
        p:=ttcx1+trunc((ttcx2-ttcx1)*tn)+w*trunc((ttcy1+(ttcy2-ttcy1)*tn));
        if bump then l:=computebump;
        buffer^[i]:=computelightingcolor(btm^[p], l);
        wbuffer^[i]:=tz;
      end;
      tz:=tz+duz;
    end;
  end;
end;

begin
  with triangle[n] do
  begin
    x1:=scrvertex[vertexid[1]][1]; y1:=scrvertex[vertexid[1]][2];
    x2:=scrvertex[vertexid[2]][1]; y2:=scrvertex[vertexid[2]][2];
    x3:=scrvertex[vertexid[3]][1]; y3:=scrvertex[vertexid[3]][2];
    v1[1]:=x2-x1; v1[2]:=y2-y1; v1[3]:=0;
    v2[1]:=x3-x1; v2[2]:=y3-y1; v2[3]:=0;
    vectorproduct(v1, v2, v);
    if v[3]>0 then
    begin
      z1:=zvertex[vertexid[1]]; z2:=zvertex[vertexid[2]]; z3:=zvertex[vertexid[3]];
      w:=material^.width;
      if material^.bitmap<>nil then
      begin
        dec(w);
        tcx1:=trunc(tc[1][1]*w); tcy1:=trunc(tc[1][2]*w);
        tcx2:=trunc(tc[2][1]*w); tcy2:=trunc(tc[2][2]*w);
        tcx3:=trunc(tc[3][1]*w); tcy3:=trunc(tc[3][2]*w);
        inc(w);
        btm:=material^.bitmap;
        bump:=false;
        if material^.bumpmap=nil then l:=computelighting(n)
        else
        begin
          bump:=true;
          for i:=1 to lightscount do
          begin
            copyvector(normlight[i], light[i]);
            v1[1]:=vertex[vertexid[2]][1]-vertex[vertexid[1]][1];
            v1[2]:=vertex[vertexid[2]][2]-vertex[vertexid[1]][2];
            v1[3]:=vertex[vertexid[2]][3]-vertex[vertexid[1]][3];
            v2[1]:=vertex[vertexid[3]][1]-vertex[vertexid[1]][1];
            v2[2]:=vertex[vertexid[3]][2]-vertex[vertexid[1]][2];
            v2[3]:=vertex[vertexid[3]][3]-vertex[vertexid[1]][3];
            vectorproduct(v1, v2, v);
            setvector(v2, 0, 1, 0);
            vectorproduct(v, v2, v1);
            normalizevector(v1);
            nullvector(v3);
            rotatevector(v3, v1, vectorangle(v, v2), normlight[i]);
          end;
          bmm:=material^.bumpmap;
        end;
        drawstring:=drawtexturedstring;
      end
      else
      begin
        cl:=computelightingcolor(material^.color, computelighting(n));
        drawstring:=drawcoloredstring;
      end;
      if y1>y2 then begin swapi(y1, y2); swapi(x1, x2); swaps(z1, z2); swapi(tcx1, tcx2); swapi(tcy1, tcy2); end;
      if y2>y3 then
      begin
        swapi(y2, y3); swapi(x2, x3); swaps(z2, z3); swapi(tcx2, tcx3); swapi(tcy2, tcy3);
        if y1>y2 then begin swapi(y1, y2); swapi(x1, x2); swaps(z1, z2); swapi(tcx1, tcx2); swapi(tcy1, tcy2); end;
      end;
      uz1:=1/z1; uz2:=1/z2; uz3:=1/z3;
      duz3:=(uz3-uz1)/(y3-y1); duz1:=(uz2-uz1)/(y2-y1);
      d3:=(x3-x1)/(y3-y1); d1:=(x2-x1)/(y2-y1);
      ti1:=x1-trunc(y1*d1); ti2:=x1-trunc(y1*d3);
      sj:=y1*scrwidth;
      tuz1:=uz1; tuz2:=uz1;
      dcx1:=tcx2-tcx1; dcy1:=tcy2-tcy1; dz1:=1/(z2-z1); dcx:=tcx1; dcy:=tcy1;
      dcx2:=tcx3-tcx1; dcy2:=tcy3-tcy1; dz2:=1/(z3-z1); dz:=z1;
      dy:=y1; dy1:=1/(y2-y1); dy2:=1/(y3-y1);
      j1:=y1*d1; j3:=y1*d3;
      for j:=y1 to y2 do
        begin
        tz1:=1/tuz1; tz2:=1/tuz2;
        t1:=ti1+trunc(j1)+sj; t2:=ti2+trunc(j3)+sj;
        j1:=j1+d1; j3:=j3+d3;
        duz:=(tuz2-tuz1)/(t2-t1);
        drawstring;
        sj:=sj+scrwidth;
        tuz1:=tuz1+duz1; tuz2:=tuz2+duz3;
        end;
      duz1:=(uz3-uz2)/(y3-y2);
      d1:=(x3-x2)/(y3-y2);
      ti1:=x3-trunc(y3*d1); ti2:=x3-trunc(y3*d3);
      tuz1:=uz2; tuz2:=uz1+(y2-y1)*duz3;
      dcx1:=tcx3-tcx2; dcy1:=tcy3-tcy2; dz1:=1/(z3-z2); dz:=z2; dcx:=tcx2; dcy:=tcy2;
      dy:=y2; dy1:=1/(y3-y2);
      j1:=y2*d1; j3:=y2*d3;
      for j:=y2+1 to y3 do
        begin
        j1:=j1+d1; j3:=j3+d3;
        t1:=ti1+trunc(j1)+sj; t2:=ti2+trunc(j3)+sj;
        tuz1:=tuz1+duz1; tuz2:=tuz2+duz3;
        tz1:=1/tuz1; tz2:=1/tuz2;
        duz:=(tuz2-tuz1)/(t2-t1);
        drawstring;
        sj:=sj+scrwidth;
        end;
    end;
  end;
end;


procedure worldtocamera(const x: tvector; var v: tvector);
var
  x1, x2: tvector;
  e, s: array [1..3] of tvector;
  udet: single;
begin
  with camera do
  begin
    vectorproduct(up, direction, x1);
    normalizevector(x1);
    vectorproduct(direction, x1, x2);
    normalizevector(x2);
    copyvector(e[1], x1);
    copyvector(e[2], x2);
    copyvector(e[3], direction);
  end;
  udet:=1/(e[1][1]*e[2][2]*e[3][3]+e[2][1]*e[3][2]*e[1][3]+e[3][1]*e[1][2]*e[2][3]-
       e[3][1]*e[2][2]*e[1][3]-e[2][1]*e[1][2]*e[3][3]-e[1][1]*e[3][2]*e[2][3]);
  s[1][1]:=e[2][2]*e[3][3]-e[3][2]*e[2][3];
  s[2][1]:=e[3][2]*e[1][3]-e[1][2]*e[3][3];
  s[3][1]:=e[1][2]*e[2][3]-e[2][2]*e[1][3];
  s[1][2]:=e[3][1]*e[2][3]-e[2][1]*e[3][3];
  s[2][2]:=e[1][1]*e[3][3]-e[3][1]*e[1][3];
  s[3][2]:=e[2][1]*e[1][3]-e[1][1]*e[2][3];
  s[1][3]:=e[2][1]*e[3][2]-e[3][1]*e[2][2];
  s[2][3]:=e[3][1]*e[1][2]-e[1][1]*e[3][2];
  s[3][3]:=e[1][1]*e[2][2]-e[2][1]*e[1][2];
  copyvector(x1, x);
  subtractvector(x1, camera.position, x1);
  v[1]:=-(s[1][1]*x1[1]+s[1][2]*x1[2]+s[1][3]*x1[3])*udet;
  v[2]:=(s[2][1]*x1[1]+s[2][2]*x1[2]+s[2][3]*x1[3])*udet;
  v[3]:=(s[3][1]*x1[1]+s[3][2]*x1[2]+s[3][3]*x1[3])*udet;
end;


procedure cameratoscreen(const v: tvector; var x, y: integer);
var
  v3: single;
begin
  v3:=scrsc/v[3];
  x:=(scrwidth shr 1)+round(v3*v[1]);
  y:=(scrheight shr 1)-round(v3*v[2]);
end;


procedure worldtoscreen(const v: tvector; var x, y: integer );
var
  v1: tvector;
begin
  worldtocamera(v, v1);
  cameratoscreen(v1, x, y);
end;


procedure rendertobuffer;
var
  i: longint;
  v: tvector;
begin
  for i:=1 to verticescount do
  begin
    worldtocamera(vertex[i], v);
    zvertex[i]:=v[3];
    cameratoscreen(v, scrvertex[i][1], scrvertex[i][2]);
  end;
  for i:=1 to trianglescount do if triangle[i].visible then drawtriangle(i);
end;


procedure render;
begin
  rendertobuffer;
  updatescreen;
end;


procedure loadbitmap(var b: tbitmap; var w: byte; n: string);
var
  p: tpalette;
  t: string;
begin
  t:=n;
  delete(t, 1, length(n)-3);
  if t='bmp' then
    bmpload(b, w, p, n);
end;



end.