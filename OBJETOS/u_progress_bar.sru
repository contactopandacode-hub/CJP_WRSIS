$PBExportHeader$u_progress_bar.sru
$PBExportComments$Progress meter, similar to the ones found in the Setup programs.
forward
global type u_progress_bar from UserObject
end type
type p_1 from picture within u_progress_bar
end type
type st_1 from statictext within u_progress_bar
end type
type st_2 from statictext within u_progress_bar
end type
type st_3 from statictext within u_progress_bar
end type
type ln_1 from line within u_progress_bar
end type
end forward

global type u_progress_bar from UserObject
int Width=1377
int Height=81
boolean Border=true
long BackColor=12632256
long PictureMaskColor=25166016
long TabTextColor=33554432
long TabBackColor=67108864
p_1 p_1
st_1 st_1
st_2 st_2
st_3 st_3
ln_1 ln_1
end type
global u_progress_bar u_progress_bar

type variables
// Determines if the progress bar has touched the 
// percentage text
boolean    ib_invert
int iv_width
end variables

forward prototypes
public subroutine uf_set_position (decimal ac_pct_complete)
public subroutine uf_check (boolean par_check)
end prototypes

public subroutine uf_set_position (decimal ac_pct_complete);//////////////////////////////////////////////////////////////////////
//
// Function: uf_set_position
//
// Purpose: expands the progress meter and updates the percentage
//				to the percentage argument passed to this function
//
//	Scope: public
//
//	Arguments: ac_pct_complete		the percentage that the progress meter
//											should be set to
//	
//	Returns: none
//
//////////////////////////////////////////////////////////////////////

long	ll_color




//////////////////////////////////////////////////////////////////////
// Reset instance variable and colors if progress meter has been restarted
//////////////////////////////////////////////////////////////////////
if Int (ac_pct_complete) = 0 then
	ib_invert = false
	st_1.TextColor = st_2.BackColor
	st_1.BackColor = this.BackColor
end if


//////////////////////////////////////////////////////////////////////
// expand the progess bar
//////////////////////////////////////////////////////////////////////
st_2.width = ac_pct_complete / 100.0 * iv_width

//////////////////////////////////////////////////////////////////////
// update the percentage text
//////////////////////////////////////////////////////////////////////
st_1.text = String (ac_pct_complete / 100.0, "##0%")


//////////////////////////////////////////////////////////////////////
// check to see if the progress bar touches the percentage text.  
// If so, invert the percentage text colors.
//////////////////////////////////////////////////////////////////////
if not ib_invert then
	if st_2.width >= st_1.x then
		ib_invert = true
		ll_color = st_1.textcolor
		st_1.TextColor = st_2.TextColor
		st_1.BackColor = st_2.BackColor
	end if
end if

end subroutine

public subroutine uf_check (boolean par_check);p_1.Visible = par_check
end subroutine

on constructor;
uf_check(FALSE)
p_1.PictureName = "sc_aprog.bmp"		

p_1.Width = 110
iv_width = this.width - p_1.Width

p_1.x = iv_width + 5
p_1.y =  int(this.Height / 2) - int(p_1.Height / 2)

this.Border = FALSE

// ST_2 Azul
st_1.TextColor = st_2.BackColor

st_2.BringToTop = TRUE
st_2.x=0
st_2.y=0
st_2.Width = 0
st_2.Height = this.Height - 10

// ST_1 Texto

st_1.BringToTop = TRUE
st_1.X = int(iv_width / 2) - int(st_1.Width / 2)
st_1.Y = int(this.Height / 2) - int(st_1.Height / 2)

st_3.x=0
st_3.y=0
st_3.Width = iv_width - 5
st_3.Height = this.Height - 10

uf_set_position(0)
end on

on u_progress_bar.create
this.p_1=create p_1
this.st_1=create st_1
this.st_2=create st_2
this.st_3=create st_3
this.ln_1=create ln_1
this.Control[]={ this.p_1,&
this.st_1,&
this.st_2,&
this.st_3,&
this.ln_1}
end on

on u_progress_bar.destroy
destroy(this.p_1)
destroy(this.st_1)
destroy(this.st_2)
destroy(this.st_3)
destroy(this.ln_1)
end on

type p_1 from picture within u_progress_bar
int X=1180
int Y=293
int Width=106
int Height=65
string PictureName="s:\develop\sc_aprog.bmp"
boolean FocusRectangle=false
end type

type st_1 from statictext within u_progress_bar
int X=449
int Y=185
int Width=138
int Height=53
string Text="0%"
boolean FocusRectangle=false
long TextColor=16777215
long BackColor=12632256
long BorderColor=16711680
int TextSize=-9
int Weight=700
string FaceName="Helv"
FontFamily FontFamily=Swiss!
FontPitch FontPitch=Variable!
end type

type st_2 from statictext within u_progress_bar
int X=599
int Y=249
int Width=124
int Height=61
boolean Enabled=false
boolean Border=true
BorderStyle BorderStyle=StyleLowered!
boolean FocusRectangle=false
long TextColor=16777215
long BackColor=8388608
int TextSize=-9
int Weight=700
string FaceName="MS Sans Serif"
FontFamily FontFamily=Swiss!
FontPitch FontPitch=Variable!
end type

type st_3 from statictext within u_progress_bar
int X=23
int Y=293
int Width=1148
int Height=61
boolean Enabled=false
boolean Border=true
BorderStyle BorderStyle=StyleLowered!
boolean FocusRectangle=false
long BackColor=12632256
int TextSize=-9
int Weight=700
string FaceName="MS Sans Serif"
FontFamily FontFamily=Swiss!
FontPitch FontPitch=Variable!
end type

type ln_1 from line within u_progress_bar
boolean Enabled=false
int BeginX=179
int BeginY=245
int EndX=179
int EndY=289
int LineThickness=5
end type

