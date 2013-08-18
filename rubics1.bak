uses vectors, graph3d, primitiv, crt;

var
  c: array [-1..1, -1..1, -1..1] of tobject;
  v, m: tvector;
  a: single;
  i, j: byte;

procedure createcube;
var
   i, j, k: shortint;
begin
for i:=-1 to 1 do
    for j:=-1 to 1 do
        for k:=-1 to 1 do
            begin
            make_cube(c[i,j,k], 0.9);
            setvector(m, i-2, j-2, k-2+10);
            moveobject(m, c[i,j,k]);
            end;
end;

begin
  opengraph(200, 320, 100);
  addlight(0, 0, 1);
  createcube;
  repeat
        render;
  until keypressed;
  closegraph;
end.