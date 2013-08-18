uses crt, vectors, graph3d, primitiv;
var
  c: array [-5..5] of array [-5..5] of array [-5..5] of tobject;
  mat: tmaterial;
  v: tvector;
  i, j, k: integer;
begin
  opengraph(200, 320, 200);
  setvector(v, 2, 3, -1);
  normalizevector(v);
  addlight(v); addlight(v);
  mat.color:=31;
  //loadbitmap(mat.bitmap, mat.width, 'tb1.bmp');
  for i:=-5 to 5 do
    for j:=-5 to 5 do
      for k:=-5 to 5 do
      begin
        make_cube(c[i,j,k], 0.8);
        setvector(v, i, j, k);
        c[i,j,k].move(v);
        c[i,j,k].setmaterial(mat);
      end;
  nullvector(v);
  with camera do
  begin
    setvector(position, 0, -20, 10);
    subtractvector(v, position, direction);
    normalizevector(direction);
  end;
  repeat
    render;
    with camera do
    begin
      rotatevector(v, up, 0.02, position);
      subtractvector(v, position, direction);
      normalizevector(direction);
      copyvector(light[1], direction);
    end;
  until keypressed;
  closegraph;
end.