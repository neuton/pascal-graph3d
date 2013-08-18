uses vectors, graph3d, primitiv, crt;
var
  c1, c2: tobject;
  mat, mat1: tmaterial;
  v, m, v0, v1: tvector;
  a: single;
  i, j: longint;
begin
  opengraph(200, 320, 200);
  setvector(v, -1, 1, -1);
  normalizevector(v);
  addlight(v);
  //setvector(v, 1, -1, 0.5);
  //addlight(v);
  make_cube(c1, 8);
  make_cube(c2, 5);
  mat1.color:=31; mat.color:=31;
  loadbitmap(mat1.bitmap, mat1.width, '31.bmp');
  loadbitmap(mat1.bumpmap, mat1.width, 'tb0.bmp');
  loadbitmap(mat.bitmap, mat.width, '31.bmp');
  loadbitmap(mat.bumpmap, mat.width, 'tb0.bmp');
  c1.setmaterial(mat1);
  c2.setmaterial(mat);
  setvector(m, 0, 0, 0);
  c1.move(m);
  c2.move(m);
  setvector(m, 0, 0, 0);
  setvector(v, 1, 0, 0);
  setvector(v0, 0, 0, 0);
  setvector(v1, -10, 1, 1);
  //normalizevector(v1);
  with camera do
  begin
    setvector(position, 0, -24, 0);
    subtractvector(v0, position, direction);
    normalizevector(direction);
  end;
  repeat
    render;
    {with camera do
    begin
      rotatevector(v0, up, 0.003, position);
      subtractvector(v0, position, direction);
      normalizevector(direction);
    end;   }
    c1.move(m);
    m[1]:=-m[1];
    c2.move(m);
    //rotatevector(v0, camera.direction, 0.01, v1);
    //v1[1]:=v1[1]-10;
    v1[1]:=v1[1]+0.1;
    //normalizevector(v1);
    v1[1]:=-2;
    v1[2]:=1;
    v1[3]:=-1;
    normalizevector(v1);
    c1.setdirection(v1);
    c1.rotate(c1.position, v, -0.01);
    c2.rotate(c2.position, v, 0.07);
    setvector(v, sin(a), 1, cos(a));
    m[1]:=cos(a)/18;
    normalizevector(v);
    a:=a+0.01;
    if a>2*pi then a:=a-2*pi;
  until keypressed;
  closegraph;
end.