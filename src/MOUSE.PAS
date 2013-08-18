unit mouse;

interface

type
    str6 = String[6];

procedure reset_mouse(var mouse_OK: Boolean; var button: Byte);
procedure show_cursor;
procedure hide_cursor;
procedure get_mouse_status(var button: Byte; var x, y: Word);
procedure mouse_gotoXY(x, y: word);
procedure get_mouse_button_press(var button: Byte; var count, x, y: Word);
function double_click(timeout: longint): boolean;
procedure get_mouse_button_release(var button: byte; var count, x, y: Word);
procedure set_cursor_x_lim(min_x, max_x: Word);
procedure set_cursor_y_lim(min_y, max_y: Word);
procedure set_graph_cursor_shape(hot_x, hot_y: integer; address: pointer);
procedure set_text_cursor_shape(screen_mask, cursor_mask: Word);
procedure get_relative_move(var x, y:integer);
procedure set_hide_cursor_window(x0, y0, x1, y1: word);
procedure get_mouse_state_size(var size: word);
procedure save_mouse_driver_state(address: Pointer);
procedure get_mouse_page(var page:word);
procedure set_mouse_page(page: word);
procedure reset_mouse_software(var installed: boolean; var no_buttons: word);
procedure get_mouse_info(var ver: str6; var port, irq:byte);


implementation

uses dos, crt;

var
   regs: registers;

procedure reset_mouse(var mouse_ok: Boolean; var button: byte);
begin
     regs.AX := $00;
     intr($33, regs);
     mouse_ok := odd(regs.AX);
     button:=regs.bx;
end;

procedure show_cursor;
begin
     regs.AX := $01;
     intr($33, regs);
end;


procedure hide_cursor;
begin
     regs.AX := $02;
     intr($33, regs);
end;

procedure get_mouse_status(var button: byte; var x, y: word);
begin
     regs.AX := $03;
     intr($33, regs);
     with regs do
     begin
          button := bl;
          x := CX;
          y := dx;
     end;
end;

procedure mouse_gotoXY(x, y:word);
begin
     with regs do
     begin
          AX:=$04;
          cx:=x;
          dx:=y;
     end;
     intr($33, regs);
end;

procedure get_mouse_button_press(var button: Byte; var count, x, y: word);
begin
    regs.AX := $05;
    regs.bL := button;
    intr($33, regs);
    with regs do
    begin
         button := al;
         count := bx;
         x := cx;
         y := dx;
    end;
end;

function double_click(timeout: longint): boolean;
var
   x, y: word;
   k: longint;
   button: byte;
begin
     double_click := false;

     repeat
           get_mouse_status(button, x, y);
     until button and $01 = 0;

     repeat
           get_mouse_status(button, x, y);
     until button and $01 = 1;

     repeat
           get_mouse_status(button, x, y);
     until button and $01 = 0;

     repeat
           delay(1);
           inc(k);
           get_mouse_status(button, x, y);
    until (button and $01 = 1) or (k=timeout);
    if k = timeout then exit;
    repeat
          delay(1);
          inc(k);
          get_mouse_status(button, x, y);
    until (button and $01 = 0) or (k=timeout);
    double_click := (k < timeout);
end;

procedure get_mouse_button_release(var button: byte; var count, x, y: word);
begin
     regs.ax := $06;
     regs. dl:= button;
     intr($33, regs);
     with regs do
     begin
        button:=al;
        count:=bx;
        x:=cx;
        y:=dx;
     end;
end;

procedure set_cursor_x_lim(min_x, max_x: word);
begin
     with regs do
     begin
          AX := $07;
          CX := min_x;
          DX := max_x;
     end;
     intr($33, regs);
end;

procedure set_cursor_y_lim(min_y, max_y: word);
begin
     with regs do
     begin
          AX := $08;
          CX := min_y;
          DX := max_y;
     end;
     intr($33, regs);
end;

procedure set_graph_cursor_shape(hot_x, hot_y: integer; address: Pointer);
begin
     with regs do
     begin
          ax:=$09;
          bx:=word(hot_x);
          cx:=word(hot_y);
          es:=seg(address^);
          dx:=ofs(address^);
     end;
     intr($33, regs);
end;

procedure set_text_cursor_shape(screen_mask, cursor_mask: Word);
begin
     with regs do
     begin
          ax := $0A;
          bx := $00;
          cx := screen_mask;
          dx := cursor_mask;
     end;
     intr($33, regs);
end;

procedure get_relative_move(var x, y: integer);
begin
     regs.ax := $0B;
     intr($33, regs);
     x:= integer(regs.cx);
     y:= integer(regs.dx);
end;

procedure set_hide_cursor_window(x0, y0, x1, y1: word);
begin
     with regs do
     begin
          ax:=$10;
          cx:=x0;
          dx:=y0;
          si:=x1;
          di:=y1;
     end;
     intr($33, regs);
end;

procedure get_mouse_state_size(var size: word);
begin
    regs.ax:= $15;
    intr($33, regs);
    size:= regs.bx;
end;

procedure save_mouse_driver_state(address: Pointer);
begin
     with regs do
     begin
          ax:=$16;
          es:=seg(address^);
          dx:=ofs(address^);
     end;
     intr($33, regs);
end;

procedure restore_mouse_driver_state(address: Pointer);
begin
     with regs do
     begin
          ax:=$17;
          es:=seg(address^);
          dx:=ofs(address^);
     end;
     intr($33, regs);
end;

procedure set_mouse_page(page: word);
begin
     regs.ax:=$1d;
     regs.bx:=page;
     intr($33, regs);
end;

procedure get_mouse_page(var page: word);
begin
     regs.ax:=$1e;
     intr($33, regs);
     page:=regs.bx;
end;

procedure reset_mouse_software(var installed: boolean; var no_buttons: word);
begin
     regs.ax := $21;
     intr($33, regs);
     installed:= regs.ax = $ffff;
     no_buttons:=regs.bx;
end;

procedure get_mouse_info(var ver:str6; var port, IRQ: byte);
var ss:str6;
begin
     {regs.ax:= $24;
     intr($33, regs);
     with regs do
     begin
          str(bh, ver); str(BL, ss);
          ver:= ver+'.'+ss;
          port:= ch; irq:=cl;
     end;    }
end;

end.