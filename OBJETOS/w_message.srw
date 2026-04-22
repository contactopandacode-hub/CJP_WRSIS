$PBExportHeader$w_message.srw
forward
global type w_message from Window
end type
type uo_progress from u_progress_bar within w_message
end type
type st_message from statictext within w_message
end type
end forward

global type w_message from Window
int X=563
int Y=873
int Width=1797
int Height=289
boolean Enabled=false
long BackColor=12632256
WindowType WindowType=popup!
uo_progress uo_progress
st_message st_message
end type
global w_message w_message

type variables
 
end variables

on timer;uo_progress.uf_set_position(100)
uo_progress.uf_check(true)
setpointer(arrow!)
timer(0,this)
close(this)
 
	


end on

on open;st_message.text = message.stringparm
setpointer(hourglass!)
timer(1,this)
uo_progress.uf_set_position(0)
uo_progress.uf_check(false)

end on

on w_message.create
this.uo_progress=create uo_progress
this.st_message=create st_message
this.Control[]={ this.uo_progress,&
this.st_message}
end on

on w_message.destroy
destroy(this.uo_progress)
destroy(this.st_message)
end on

type uo_progress from u_progress_bar within w_message
int X=311
int Y=169
int TabOrder=1
end type

on uo_progress.destroy
call u_progress_bar::destroy
end on

type st_message from statictext within w_message
int X=19
int Y=57
int Width=1756
int Height=73
boolean Enabled=false
string Text="Message"
Alignment Alignment=Center!
boolean FocusRectangle=false
long BackColor=12632256
int TextSize=-11
int Weight=700
string FaceName="Arial"
FontFamily FontFamily=Swiss!
FontPitch FontPitch=Variable!
end type

