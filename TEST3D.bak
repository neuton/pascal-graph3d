uses vectors, graph3d, primitiv, crt;
var
  {p1, p2, }c1, c2: tobject;
  v: tvector;
  a: single;
begin
  opengraph(200, 320, 200);
  {make_pyramid(p1, 5, 0, 0, 20);
  make_pyramid(p2, -5, 0, 0, 20);}
  make_cube(c1, 5, 0, 0, 20);
  make_cube(c2, 4.5, 0, 0, 20);
  setvector(v, 0, 1, 0);
  repeat
    render;
    {rotateobject(p1.center, v, 0.01, p1);
    rotateobject(p2.center, v, 0.004, p2);}
    rotateobject(c1.center, v, -0.01, c1);
    rotateobject(c2.center, v, 0.02, c2);
    setvector(v, sin(a), 1, cos(a));
    normalizevector(v);
    a:=a+0.001;
    if a>2*pi then a:=a-2*pi;
    {delay(100);}
  until keypressed;
  closegraph;
end.