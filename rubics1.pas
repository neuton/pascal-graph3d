uses vectors, graph3d, primitiv, crt;

var
  c: array [-1..1, -1..1, -1..1] of tobject;
  t: array [-1..1, -1..1, -1..1] of ^tobject;
  m: array [1..9] of ^tobject;
  tnormal, v, v0, tv, v1, v2: tvector;
  a, b, tb: single;
  mat, white, yellow, red, green, blue, orange: tmaterial;
  key: char;
  n: byte;

procedure setcoloredmaterials;
begin
  mat.color:=31;
  white.color:=31;
  yellow.color:=44;
  red.color:=39;
  green.color:=46;
  blue.color:=32;
  orange.color:=41;
end;

procedure settexturedmaterials;
begin
  mat.color:=21;
  white.color:=31;
  yellow.color:=44;
  loadbitmap(red.bitmap, red.width, 'nt1.bmp');
  //loadbitmap(red.bumpmap, red.width, 'nt1.bmp');
  green.color:=45;
  blue.color:=32;
  orange.color:=41;
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
            moveobject(m, c[i,j,k]);
            setmaterial(c[i,j,k], mat);
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
    rotateobject(v0, tnormal, a, m[i]^);
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
  i, j, k: shortint;
  v: tvector;
begin
  for i:=-1 to 1 do
    for j:=-1 to 1 do
      for k:=-1 to 1 do
        begin
        t[round(c[i,j,k].center[1]), round(c[i,j,k].center[2]), round(c[i,j,k].center[3])]:=@c[i,j,k];
        setvector(v, round(c[i,j,k].center[1]), round(c[i,j,k].center[2]), round(c[i,j,k].center[3]));
        subtractvector(v, c[i,j,k].center, v);
        moveobject(v, c[i,j,k]);
        end;
end;

procedure mix;
var
  i: byte;
begin
  randomize;
  for i:=10 downto 0 do
  begin
    turn(random(5)+1, pi/2);
    update;
  end;
end;

begin
  opengraph(200, 320, 200);
  nullvector(v0);
  setvector(camera.position, 0, -8, 0);
  addlight(1, 0, 0);
  copyvector(light[1], camera.direction);
  setcoloredmaterials;
  //settexturedmaterials;
  createcube;
  mix;
  b:=0.1;
  repeat
    render;
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
        '1': begin update; n:=1; tb:=0; end;
        '2': begin update; n:=2; tb:=0; end;
        '3': begin update; n:=3; tb:=0; end;
        '4': begin update; n:=4; tb:=0; end;
        '5': begin update; n:=5; tb:=0; end;
        '6': begin update; n:=6; tb:=0; end;
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
      a:=a*0.7;
    end;
    if tb>=0 then
    begin
      turn(n, b);
      tb:=tb+b;
      if tb>pi/2 then begin tb:=-1; update; end;
      //setturningface(1,0,0);
      //turnface(b);
    end;
  until key=#27;
  closegraph;
end.