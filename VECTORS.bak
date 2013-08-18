unit vectors;


interface

type
  tvector=array[1..3] of single;

procedure setvector(var v: tvector; x, y, z: single);
procedure copyvector(var v1: tvector; const v2: tvector);
procedure nullvector(var v: tvector);
procedure addvector(const v1, v2: tvector; var v: tvector);
procedure subtractvector(const v1, v2: tvector; var v: tvector);
procedure scalevector(var v: tvector; a: single);
procedure normalizevector(var v: tvector);
function vectorlength(const v: tvector): single;
procedure vectorproduct(const v1, v2: tvector; var v: tvector);
function vectordotproduct(const v1, v2: tvector): single;
function vectoranglecos(const v1, v2: tvector): single;
function vectorangle(const v1, v2: tvector): single;
procedure rotatevector(c, n: tvector; a: single; var v: tvector);


implementation

procedure setvector(var v: tvector; x, y, z: single);
begin
  v[1]:=x;
  v[2]:=y;
  v[3]:=z;
end;

procedure copyvector(var v1: tvector; const v2: tvector);
begin
  v1[1]:=v2[1];
  v1[2]:=v2[2];
  v1[3]:=v2[3];
end;

procedure nullvector(var v: tvector);
begin
  v[1]:=0;
  v[2]:=0;
  v[3]:=0;
end;

procedure addvector(const v1, v2: tvector; var v: tvector);
begin
  v[1]:=v1[1]+v2[1];
  v[2]:=v1[2]+v2[2];
  v[3]:=v1[3]+v2[3];
end;

procedure subtractvector(const v1, v2: tvector; var v: tvector);
begin
  v[1]:=v1[1]-v2[1];
  v[2]:=v1[2]-v2[2];
  v[3]:=v1[3]-v2[3];
end;

procedure scalevector(var v: tvector; a: single);
begin
  v[1]:=v[1]*a;
  v[2]:=v[2]*a;
  v[3]:=v[3]*a;
end;

procedure normalizevector(var v: tvector);
var
  d: single;
begin
  d:=vectorlength(v);
  v[1]:=v[1]/d;
  v[2]:=v[2]/d;
  v[3]:=v[3]/d;
end;

function vectorlength(const v: tvector): single;
begin
  vectorlength:=sqrt(sqr(v[1])+sqr(v[2])+sqr(v[3]));
end;

procedure vectorproduct(const v1, v2: tvector; var v: tvector);
begin
  v[1]:=v1[2]*v2[3]-v1[3]*v2[2];
  v[2]:=v1[3]*v2[1]-v1[1]*v2[3];
  v[3]:=v1[1]*v2[2]-v1[2]*v2[1];
end;

function vectordotproduct(const v1, v2: tvector): single;
begin
  vectordotproduct:=v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3];
end;

function vectoranglecos(const v1, v2: tvector): single;
begin
  vectoranglecos:=vectordotproduct(v1, v2)/(vectorlength(v1)*vectorlength(v2));
end;

function vectorangle(const v1, v2: tvector): single;
var
  v: tvector;
begin
  vectorproduct(v1, v2, v);
  vectorangle:=arctan(vectorlength(v)/vectordotproduct(v1, v2));
end;

procedure rotatevector(c, n: tvector; a: single; var v: tvector);
var
  si, co: single;
  tv: tvector;
begin
  si:=sin(a);
  co:=cos(a);
  subtractvector(v, c, tv);
  v[1]:=c[1]+(co+(1-co)*sqr(n[1]))*tv[1] + ((1-co)*n[1]*n[2]-si*n[3])*tv[2] + ((1-co)*n[1]*n[3]+si*n[2])*tv[3];
  v[2]:=c[2]+((1-co)*n[1]*n[2]+si*n[3])*tv[1] + (co+(1-co)*sqr(n[2]))*tv[2] + ((1-co)*n[2]*n[3]-si*n[1])*tv[3];
  v[3]:=c[3]+((1-co)*n[1]*n[3]-si*n[2])*tv[1] + ((1-co)*n[3]*n[2]+si*n[1])*tv[2] + (co+(1-co)*sqr(n[3]))*tv[3];
end;

end.