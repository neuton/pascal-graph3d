unit useful;


interface

procedure swapi(var a, b: integer);
procedure swaps(var a, b: single);
procedure sort3i(var a1, a2, a3: integer);
function max2i(a, b: integer): integer;
function min2i(a, b: integer): integer;


implementation

procedure swapi(var a, b: integer);
var
	t: integer;
begin
	t:=a;
	a:=b;
	b:=t;
end;

procedure swaps(var a, b: single);
var
	t: single;
begin
	t:=a;
	a:=b;
	b:=t;
end;

procedure sort3i(var a1, a2, a3: integer);
begin
	if a1>a2 then swapi(a1, a2);
	if a2>a3 then
	begin
		swapi(a2, a3);
		if a1>a2 then swapi(a1, a2);
	end;
end;

function max2i(a, b: integer): integer;
begin
	if a>b then max2i:=a
	else max2i:=b;
end;

function min2i(a, b: integer): integer;
begin
	if a<b then min2i:=a
	else min2i:=b;
end;

end.
