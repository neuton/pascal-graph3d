uses vectors, graph3d, primitiv, crt, mouse;

var
  c: array [-1..1, -1..1, -1..1] of tobject;
  t: array [-1..1, -1..1, -1..1] of ^tobject;
  m: array [1..9] of ^tobject;
  tnormal, v, v0, tv, v1, v2: tvector;
  a, b, tb: single;
  mat, white, yellow, red, green, blue, orange, cursor: tmaterial;
  key: char;
  n, button: byte;
  sign: shortint;
  ret: array [1..1000] of byte;
  steps, mx, my: integer;
  x, y: word;
  returning: boolean;
  ti, tj, tk: shortint;


function isontriangle(x, y, i1, i2, i3: integer): boolean;
var
  v1, v2, v3: array [1..2] of integer;
  a1, a2, a3: integer;
begin
  v1[1]:=scrvertex[i1][1]-x; v1[2]:=scrvertex[i1][2]-y;
  v2[1]:=scrvertex[i2][1]-x; v2[2]:=scrvertex[i2][2]-y;
  v3[1]:=scrvertex[i3][1]-x; v3[2]:=scrvertex[i3][2]-y;
  a1:=v1[1]*v2[2]-v1[2]*v2[1];
  a2:=v2[1]*v3[2]-v2[2]*v3[1];
  a3:=v3[1]*v1[2]-v3[2]*v1[1];
  if (abs(a1)+abs(a2)+abs(a3)=abs(a1+a2+a3))
     and ((scrvertex[i3][1]-scrvertex[i1][1])*(scrvertex[i2][2]-scrvertex[i1][2])
         -(scrvertex[i3][2]-scrvertex[i1][2])*(scrvertex[i2][1]-scrvertex[i1][1])<0)
     and (zvertex[i1]<=1/wbuffer^[scrvertex[i1][1]+320*scrvertex[i1][2]]+0.1)
     and (zvertex[i2]<=1/wbuffer^[scrvertex[i2][1]+320*scrvertex[i2][2]]+0.1)
     and (zvertex[i3]<=1/wbuffer^[scrvertex[i3][1]+320*scrvertex[i3][2]]+0.1)   then
    isontriangle:=true
  else isontriangle:=false;
end;

function min3s(a, b, c: single): single;
var
  min: single;
begin
  if a<b then min:=a else min:=b;
  if min>c then min3s:=c else min3s:=min;
end;

function getundermouse: integer;
var
  i, j, k: shortint;
  zmin: single;
  l, tr: integer;
begin
  tr:=0;
  zmin:=100;
  for i:=-1 to 1 do
    for j:=-1 to 1 do
      for k:=-1 to 1 do
        if (i<>0) or (j<>0) or (k<>0) then
          for l:=c[i,j,k].firsttriangle to c[i,j,k].lasttriangle do
            if ((zmin>zvertex[triangle[l].vertexid[1]]) or (zmin>zvertex[triangle[l].vertexid[2]]) or (zmin>zvertex[triangle[l].vertexid[3]]))
               and isontriangle(x, y, triangle[l].vertexid[1], triangle[l].vertexid[2], triangle[l].vertexid[3]) then
            begin
              zmin:=min3s(zvertex[triangle[l].vertexid[1]], zvertex[triangle[l].vertexid[2]], zvertex[triangle[l].vertexid[3]]);
              tr:=l;
            end;
  getundermouse:=tr;
end;

procedure drawlinedtriangle(l: integer; color: byte);
begin
  drawline(scrvertex[triangle[l].vertexid[1]][1], scrvertex[triangle[l].vertexid[1]][2], scrvertex[triangle[l].vertexid[2]][1], scrvertex[triangle[l].vertexid[2]][2], color);
  drawline(scrvertex[triangle[l].vertexid[2]][1], scrvertex[triangle[l].vertexid[2]][2], scrvertex[triangle[l].vertexid[3]][1], scrvertex[triangle[l].vertexid[3]][2], color);
  drawline(scrvertex[triangle[l].vertexid[3]][1], scrvertex[triangle[l].vertexid[3]][2], scrvertex[triangle[l].vertexid[1]][1], scrvertex[triangle[l].vertexid[1]][2], color);
end;

procedure drawcursor(x, y: integer);
var
  i, j, w: byte;
begin
  w:=cursor.width;
  for i:=0 to w-1 do
    for j:=0 to w-1 do
      if cursor.bitmap^[i+w*j]<>cursor.bitmap^[w*(w-1)] then
        buffer^[x+i+scrwidth*(j+y)]:=cursor.bitmap^[i+w*j];
end;

procedure setcoloredmaterials;
begin
  mat.color:=29;
  white.color:=31;
  yellow.color:=44;
  red.color:=39;
  green.color:=46;
  blue.color:=32;
  orange.color:=41;
end;

procedure setwhitematerials;
begin
  mat.color:=20;
  white.color:=31;
  yellow.color:=31;
  red.color:=31;
  green.color:=31;
  blue.color:=31;
  orange.color:=31;
end;

procedure settexturedmaterials;
begin
  mat.color:=21;
  loadbitmap(red.bitmap, red.width, 'red.bmp');
  loadbitmap(green.bitmap, green.width, 'green.bmp');
  loadbitmap(blue.bitmap, blue.width, 'blue.bmp');
  loadbitmap(white.bitmap, white.width, 'white.bmp');
  loadbitmap(yellow.bitmap, yellow.width, 'yellow.bmp');
  loadbitmap(orange.bitmap, orange.width, 'orange.bmp');
  //loadbitmap(red.bumpmap, red.width, 'tile.bmp');
end;

procedure createcube;
var
   i, j, k: shortint;
   m: tvector;
begin
for i:=-1 to 1 do
    for j:=-1 to 1 do
        for k:=-1 to 1 do
          if (i<>0) or (j<>0) or (k<>0) then
          begin
            make_cube(c[i,j,k], 0.95);
            t[i,j,k]:=@c[i,j,k];
            setvector(m, i, j, k);
            c[i,j,k].move(m);
            c[i,j,k].setmaterial(mat);
            if j=-1 then
            begin
              triangle[trianglescount].material:=@green;
              triangle[trianglescount-1].material:=@green;
            end;
            if i=1 then
            begin
              triangle[trianglescount-2].material:=@red;
              triangle[trianglescount-3].material:=@red;
            end;
            if k=1 then
            begin
              triangle[trianglescount-4].material:=@white;
              triangle[trianglescount-5].material:=@white;
            end;
            if i=-1 then
            begin
              triangle[trianglescount-6].material:=@orange;
              triangle[trianglescount-7].material:=@orange;
            end;
            if k=-1 then
            begin
              triangle[trianglescount-8].material:=@yellow;
              triangle[trianglescount-9].material:=@yellow;
            end;
            if j=1 then
            begin
              triangle[trianglescount-10].material:=@blue;
              triangle[trianglescount-11].material:=@blue;
            end;
          end;
end;

procedure createasymmetriccube;
var
  i: integer;
begin
  createcube;
  for i:=1 to verticescount do
  begin
    if vertex[i][1]>1 then vertex[i][1]:=2
    else if vertex[i][1]<-1 then vertex[i][1]:=-1;
    if vertex[i][2]>1 then vertex[i][2]:=1.8
    else if vertex[i][2]<-1 then vertex[i][2]:=-1.2;
    if vertex[i][3]>1 then vertex[i][3]:=1.6
    else if vertex[i][3]<-1 then vertex[i][3]:=-1.4;
  end;
end;

procedure createstrangecube;
var
  i: integer;
begin
  createcube;
  for i:=1 to verticescount do
    if ((abs(vertex[i][1])>1) and (abs(vertex[i][2])<1) and (abs(vertex[i][3])<1))
    or ((abs(vertex[i][1])<1) and (abs(vertex[i][2])>1) and (abs(vertex[i][3])<1))
    or ((abs(vertex[i][1])<1) and (abs(vertex[i][2])<1) and (abs(vertex[i][3])>1)) then
    begin
      vertex[i][1]:=vertex[i][1]*1.2;
      vertex[i][2]:=vertex[i][2]*1.2;
      vertex[i][3]:=vertex[i][3]*1.2;
    end
    else if (abs(vertex[i][1])>1) and (abs(vertex[i][2])>1) and (abs(vertex[i][3])>1) then
    begin
      vertex[i][1]:=vertex[i][1]*0.87;
      vertex[i][2]:=vertex[i][2]*0.87;
      vertex[i][3]:=vertex[i][3]*0.87;
    end;
end;

procedure setturningface(i, j, k: shortint);
begin
  setvector(tnormal, i, j, k);
  if i<>0 then
    for j:=-1 to 1 do
      for k:=-1 to 1 do
        m[3*j+k+5]:=t[i,j,k]
  else if j<>0 then
    for i:=-1 to 1 do
      for k:=-1 to 1 do
        m[3*i+k+5]:=t[i,j,k]
  else if k<>0 then
    for i:=-1 to 1 do
      for j:=-1 to 1 do
        m[3*i+j+5]:=t[i,j,k];
end;

procedure turnface(a: single);
var
  i: byte;
begin
  for i:=1 to 9 do
    m[i]^.rotate(v0, tnormal, a);
end;

procedure turn(n: byte; a: single);
begin
  case n of
  1:
    setturningface(1, 0, 0);
  2:
    setturningface(-1, 0, 0);
  3:
    setturningface(0, 1, 0);
  4:
    setturningface(0, -1, 0);
  5:
    setturningface(0, 0, 1);
  6:
    setturningface(0, 0, -1);
  end;
  turnface(a);
end;

procedure update;
var
  i, j, k, pb: shortint;
  pv: tvector;
  pa: single;
begin
  for i:=-1 to 1 do
    for j:=-1 to 1 do
      for k:=-1 to 1 do
        if (i<>0) or (j<>0) or (k<>0) then
          t[round(c[i,j,k].position[1]), round(c[i,j,k].position[2]), round(c[i,j,k].position[3])]:=@c[i,j,k];
end;

procedure mix(n: integer);
var
  i, t: byte;
begin
  randomize;
  for i:=n-1 downto 0 do
  begin
    t:=random(5)+1;
    turn(t, pi/2);
    inc(steps);
    ret[steps]:=t;
    update;
  end;
end;

procedure turncamera(mx, my: integer);
var
  tv1, tv2: tvector;
begin
  nullvector(v0);
  with camera do
  begin
    rotatevector(v0, up, mx*0.01, position);
    vectorproduct(up, direction, tv1);
    normalizevector(tv1);
    rotatevector(v0, tv1, my*0.01, position);
    subtractvector(v0, position, direction);
    normalizevector(direction);
    vectorproduct(up, direction, tv2);
    vectorproduct(direction, tv2, up);
    normalizevector(up);
    copyvector(light[1], direction);
  end;
end;

begin
  clrscr;
  writeln('Select type of cube (1-3):');
  readln(mx);
  writeln('Select type of texturing (1-3):');
  readln(my);
  opengraph(200, 320, 200);
  //backgroundcolor:=31;
  reset_mouse(returning, button);
  mouse_gotoXY(320, 100);
  loadbitmap(cursor.bitmap, cursor.width, 'mouse.bmp');
  //show_cursor;
  setvector(camera.position, 0, -8, 0);
  setvector(v0, 1, 0, 0);
  addlight(v0);
  //setvector(v0, 2, 1, 0);
  //addlight(v0);
  nullvector(v0);
  copyvector(light[1], camera.direction);
  case my of
    1: setcoloredmaterials;
    2: settexturedmaterials;
    3: setwhitematerials;
    end;
  case mx of
    1: createcube;
    2: createasymmetriccube;
    3: createstrangecube;
    end;
  steps:=0;
  update;
  //mix(222);
  b:=pi*0.1;
  sign:=1;
  tb:=-1;
  returning:=false;
  repeat
    rendertobuffer;
    drawlinedtriangle(getundermouse, 15);
    drawcursor(x, y);
    updatescreen;
    if keypressed then
    begin
      key:=readkey;
      nullvector(v);
      with camera do
      case key of
        'a': begin a:=-0.5; copyvector(v, up); end;
        'd': begin a:=0.5; copyvector(v, up); end;
        'w': begin a:=-0.5; vectorproduct(direction, up, v); normalizevector(v); end;
        's': begin a:=0.5; vectorproduct(direction, up, v); normalizevector(v); end;
        '1': if tb=-1 then begin n:=1; tb:=0; sign:=1; inc(steps); ret[steps]:=n; end;
        '2': if tb=-1 then begin n:=2; tb:=0; sign:=1; inc(steps); ret[steps]:=n; end;
        '3': if tb=-1 then begin n:=3; tb:=0; sign:=1; inc(steps); ret[steps]:=n; end;
        '4': if tb=-1 then begin n:=4; tb:=0; sign:=1; inc(steps); ret[steps]:=n; end;
        '5': if tb=-1 then begin n:=5; tb:=0; sign:=1; inc(steps); ret[steps]:=n; end;
        '6': if tb=-1 then begin n:=6; tb:=0; sign:=1; inc(steps); ret[steps]:=n; end;
        'r': if (tb=-1) and (steps>0) then begin n:=ret[steps]; dec(steps); returning:=true; tb:=0; sign:=-1; end;
        'm': if tb=-1 then mix(random(100));
      end;
    end;
    if abs(a)>0.01 then
    with camera do
    begin
      rotatevector(v0, v, a, position);
      subtractvector(v0, position, direction);
      normalizevector(direction);
      vectorproduct(up, direction, tv);
      vectorproduct(direction, tv, up);
      normalizevector(up);
      copyvector(light[1], direction);
      a:=a*0.6;
    end;
    if tb>=0 then
    begin
      turn(n, sign*b);
      tb:=tb+b;
      if tb+b>pi/2 then
      begin
        turn(n, sign*(pi/2-tb));
        tb:=-1;
        update;
        if returning then
          if steps>0 then
          begin
            n:=ret[steps];
            dec(steps);
            tb:=0;
          end
          else
            returning:=false;
      end;
    end;
    get_mouse_status(button, x, y);
    x:=x shr 1;
    if button=2 then
      turncamera(mx-x, y-my);
    mx:=x; my:=y;
  until key=#27;
  closegraph;
end.