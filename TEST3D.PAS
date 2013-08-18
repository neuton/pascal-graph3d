uses vectors, graph3d, primitiv, crt;
var
  {p1, p2, }c1, c2: tobject;
  mat: tmaterial;
  v, m: tvector;
  a: single;
  i, j: byte;
begin
  opengraph(200, 320, 200);
  addlight(-1, 0, 0.8);
  {make_pyramid(p1, 5, 0, 0, 20);
  make_pyramid(p2, -5, 0, 0, 20);}
  make_cube(c1, 6);
  make_cube(c2, 4);
  loadbitmap(mat.bitmap, 'nt1.bmp');
  setmaterial(c1, mat);
  setmaterial(c2, mat);
  setvector(m, 0, 0, 20);
  moveobject(m, c1);
  moveobject(m, c2);
  setvector(m, 0, 0, 0);
  setvector(v, 0, 1, 0);
  repeat
    render;
    {rotateobject(p1.center, v, 0.01, p1);
    rotateobject(p2.center, v, 0.004, p2);}
    moveobject(m, c1);
    m[1]:=-m[1];
    moveobject(m, c2);
    rotateobject(c1.center, v, -0.02, c1);
    rotateobject(c2.center, v, 0.07, c2);
    setvector(v, sin(a), 1, cos(a));
    m[1]:=cos(a)/16;
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