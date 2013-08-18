uses vectors, graph3d, primitiv, crt;
var
  {p1, p2, }c1, c2: tobject;
  mat, mat1: tmaterial;
  v, m, v0: tvector;
  a: single;
  i, j: longint;
begin
  opengraph(200, 320, 200);
  addlight(-1, 1, -0.5);
  addlight(1, -1, 0.5);
  make_cube(c1, 8);
  make_cube(c2, 5);
  mat1.color:=31; mat.color:=31;
  loadbitmap(mat1.bitmap, mat1.width, 'nt1.bmp');
  //for i:=sizeof(mat1.bitmap^)-1 downto 0 do mat1.bitmap^[i]:=31;
  //loadbitmap(mat1.bumpmap, mat1.width, 'nt1.bmp');
  loadbitmap(mat.bitmap, mat.width, 'nt1.bmp');
  //loadbitmap(mat.bumpmap, mat.width, 'tb.bmp');
  setmaterial(c1, mat1);
  setmaterial(c2, mat);
  setvector(m, 0, 0, 0);
  moveobject(m, c1);
  moveobject(m, c2);
  setvector(m, 0, 0, 0);
  setvector(v, 1, 0, 0);
  setvector(v0, 0, 0, 0);
  with camera do
  begin
    setvector(position, 0, -24, 0);
    subtractvector(v0, position, direction);
    normalizevector(direction);
  end;
  repeat
    render;
    with camera do
    begin
      rotatevector(v0, up, 0.003, position);
      //rotatevector(v0, direction, 0.01, up);
      subtractvector(v0, position, direction);
      normalizevector(direction);
    end;
    moveobject(m, c1);
    m[1]:=-m[1];
    moveobject(m, c2);
    rotateobject(c1.center, v, -0.02, c1);
    rotateobject(c2.center, v, 0.07, c2);
    setvector(v, sin(a), 1, cos(a));
    m[1]:=cos(a)/18;
    normalizevector(v);
    a:=a+0.01;
    if a>2*pi then a:=a-2*pi;
  until keypressed;
  {for j:=0 to 15 do
  for i:=0 to 255 do screen^[i+j*scrwidth]:=i;
  repeat until keypressed;       }
  {loadbitmap(mat.bitmap, 't.bmp');
  for j:=0 to 127 do
  for i:=0 to 127 do
    screen^[i+j*scrwidth]:=mat.bitmap^[i+j*128];
  repeat until keypressed;  }
  closegraph;
end.