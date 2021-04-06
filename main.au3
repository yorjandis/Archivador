#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=logo.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_ProductName=Archivador
#AutoIt3Wrapper_Res_CompanyName=YPG
#AutoIt3Wrapper_Res_LegalCopyright=Ing. Yorjandis PG
#AutoIt3Wrapper_Res_Language=1034
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.4
 Author:         Yorjandi PG
 Contact:

 Script Function: Archivador de contenido. Permite archivar información en categorias y secciones, en una forma cifrada.
Algoritmo de cifrado ustilizado: AES 256

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <WindowsConstants.au3>
#include <Crypt.au3>
#include <String.au3>
#include <INet.au3>
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode


;Constantes globales
Global $G_C_key
Const $G_C_KeyFile="qkOtsasa&fwe**de3sT\PDa80lTyr4@\jE"
Global $G_BDFile

$Form1 = GUICreate("Archivador V.1.0 YPG", 910, 382, 236, 123,-1,$WS_EX_ACCEPTFILES)
GUISetOnEvent($GUI_EVENT_CLOSE,"GUIClose")
GUISetOnEvent($GUI_EVENT_DROPPED,"DragAndDrop")

;área del menu
$MenuItem1 = GUICtrlCreateMenu("Archivo")
$MenuItem2 = GUICtrlCreateMenuItem("Abrir BD Archivos...", $MenuItem1)
GUICtrlSetOnEvent(-1, "m_AbrirBD")
$MenuItem2_2= GUICtrlCreateMenuItem("Abrir BD en Google Drive...", $MenuItem1)
GUICtrlSetOnEvent(-1, "m_AbrirBDDrive")

$MenuItem3 = GUICtrlCreateMenuItem("Crear BD", $MenuItem1)
GUICtrlSetOnEvent(-1, "m_CrearBD")
$MenuItem5 = GUICtrlCreateMenuItem("Salir", $MenuItem1)
GUICtrlSetOnEvent(-1,"m_Salir")
$MenuItem4 = GUICtrlCreateMenu("Ayuda")
$MenuItem6 = GUICtrlCreateMenuItem("Ayuda", $MenuItem4)
$MenuItem7 = GUICtrlCreateMenuItem("Créditos", $MenuItem4)
GUICtrlSetOnEvent(-1,"Creditos")
;área del menu FIN


$Group2 = GUICtrlCreateGroup("Categorías", 16, 20, 153, 330)
$List1 = GUICtrlCreateList("", 24, 42, 137, 270, BitOR($LBS_NOTIFY,$WS_HSCROLL,$WS_VSCROLL,$WS_BORDER))
GUICtrlSetState(-1,$GUI_DROPACCEPTED)
GUICtrlSetOnEvent(-1,"list_Listbox1")

$Button2 = GUICtrlCreateButton("Agregar", 24, 316, 57, 25)
GUICtrlSetOnEvent(-1,"btn_AnadirCateg")
$Button5 = GUICtrlCreateButton("Eliminar", 112, 316, 49, 25)
GUICtrlSetOnEvent(-1,"btn_DelCateg")
GUICtrlCreateGroup("", -99, -99, 1, 1)

$Group3 = GUICtrlCreateGroup("Entradas", 176, 20, 720, 330)
$List2 = GUICtrlCreateList("", 184, 42, 230, 275, BitOR($LBS_NOTIFY,$WS_HSCROLL,$WS_VSCROLL,$WS_BORDER))
GUICtrlSetState(-1,$GUI_DROPACCEPTED)
GUICtrlSetFont(-1,12,400)
GUICtrlSetOnEvent(-1,"list_Listbox2")
$Button3 = GUICtrlCreateButton("Agregar", 184, 316, 57, 25)
GUICtrlSetOnEvent(-1,"btn_AddEntrada")
$Button4 = GUICtrlCreateButton("Eliminar", 256, 316, 57, 25)
GUICtrlSetOnEvent(-1,"btn_DelEntrada")
$Button6 = GUICtrlCreateButton("Modificar", 336, 316, 57, 25)
GUICtrlSetOnEvent(-1,"Btn_ModifEntrada")
$Edit1 = GUICtrlCreateEdit("", 424, 40, 465, 300)
GUICtrlSetFont(-1,12,400)
GUICtrlSetState(-1,$GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###



While 1
    Sleep(100) ; Sleep to reduce CPU usage
WEnd

;Cierra la GUI
Func GUIClose()
	Exit
EndFunc



;Créditos
Func Creditos()
	MsgBox(0,"Créditos","Nombre: Archivador V1.0"&@CRLF&"Lenguaje de Programación:AutoIt V3"&@CRLF&"Programador:Ing. Yorjandi PG")
EndFunc




;Descarga y gestiona una BD almacenada en google drive (Experimental)
func m_AbrirBDDrive()
local $temp, $KQ, $idownload
;~ $url = "https://drive.google.com/file/d/1c0OVp3eSfC5LpQfeax2U1kBtW0c0lbT0/view?usp=sharing"

$url = InputBox("Función Experimental","Coloque el enlace público de la BD. Se Creará una copia local con prefijo 'DrvBD_*.yrt'")

;chequeando el enlace y preparando la descarga
if $url = "" or StringInStr($url, "folders") then
MsgBox(0,"","Error al cargar el archivo")
Return
EndIf

$KQ = StringRegExp($url,"[-\w]{25,}",1)
$url = "https://drive.google.com/uc?export=download&id=" & $KQ[0]

$idownload = InetGet($url,@ScriptDir&"\DrvBD_"&@YDAY&@MON&@MSEC&".yrt",$INET_FORCERELOAD, $INET_DOWNLOADWAIT)


if $idownload = 0 then
MsgBox(0,"Error","No se ha podido recuperar el fichero de la BD")
return
EndIf

	$G_BDFile = @ScriptDir&"\DrvBD_"&@YDAY&@MON&@MSEC&".yrt"  ;Actualiza la direccion global del fichro BD

	GUICtrlSetData($List1,"")
	GUICtrlSetData($List2,"")
	GUICtrlSetData($Edit1,"")
	GUICtrlSetData($Button6,"Modificar")
	GUICtrlSetState($Edit1,$GUI_DISABLE)

	tufmo();Genera la clave de cifrado
	Y_LoadBD()

EndFunc



;Función de Arrastrar y soltar
func DragAndDrop()
Local $temp

$G_BDFile = @GUI_DragFile  ;Actualiza la direccion global del fichro BD

GUICtrlSetData($List1,"")
GUICtrlSetData($List2,"")
GUICtrlSetData($Edit1,"")
GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)

if tufmo() = 0 then return ;si falla la modificación de la clave de cifrado sale.




Y_LoadBD()

EndFunc





;Crear estructura de BD por defecto
func m_CrearBD()
Local $temp

$temp = FileOpenDialog("Crear Estructura por defecto de BD",@ScriptDir,"All (*.*)")


if tufmo() = 0 then return ;si falla la modificación de la clave de cifrado sale.




IniWriteSection($temp,Y_CipherText("NOTAS"),"")
IniWriteSection($temp,Y_CipherText("IDENTIDAD"),"")
IniWriteSection($temp,Y_CipherText("BANCOS"),"")
IniWriteSection($temp,Y_CipherText("TARGETAS"),"")
IniWriteSection($temp,Y_CipherText("CONTRASEÑAS"),"")
IniWriteSection($temp,Y_CipherText("FINANZAS"),"")
IniWriteSection($temp,Y_CipherText("WEBS"),"")

EndFunc

;Abre la BD de datos
func m_AbrirBD()
Local $temp



$temp = FileOpenDialog("Abrir fichero BD",@ScriptDir,"Text Files(*.*)",$FD_FILEMUSTEXIST)
if @error <> 0 then
	MsgBox(0,"ERROR","No se ha podido cargar la base de datos")
	return
EndIf

$G_BDFile = $temp  ;Actualiza la direccion global del fichro BD

GUICtrlSetData($List1,"")
GUICtrlSetData($List2,"")
GUICtrlSetData($Edit1,"")
GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)
tufmo();Genera la clave de cifrado
Y_LoadBD()

EndFunc


;Menu salir
func m_Salir()
Exit
EndFunc


;lista de categorias
Func list_Listbox1()

GUICtrlSetData($List2,""); clear
GUICtrlSetData($Edit1,""); clear

GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)
GUICtrlSetState($List2,$GUI_FOCUS)


Y_LoadSecction()
EndFunc


; lista de entradas para las categorias disponibles
func list_Listbox2()

GUICtrlSetData($Edit1,"")

GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)
GUICtrlSetState($List2,$GUI_FOCUS)

Y_LoadItem()

EndFunc


;botón añadir nueva categoría
func btn_AnadirCateg()
Local $temp, $flag


GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)


$temp = InputBox("Añadir una nueva categoría","Coloque el nombre de la nueva categoría, sin espacios")
$temp = StringStripWS($temp,$STR_STRIPALL)

if $temp = "NOTAS" or $temp = "IDENTIDAD" or $temp = "BANCOS"  or $temp = "TARGETAS" or $temp = "CONTRASEÑAS"  _
or $temp = "FINANZAS" or $temp = "WEBS" then
$flag = 1
EndIf

if $flag = 1 then
	MsgBox(0,"Información","La nueva categoría no debe ser una por defecto")
	Return
EndIf

IniWriteSection($G_BDFile,Y_CipherText($temp),"")
GUICtrlSetData($List1,"")
GUICtrlSetData($List2,"")
Y_LoadBD()

EndFunc

;boton eliminar nueva categoría
func btn_DelCateg()
Local $temp, $flag


GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)


$temp = GUICtrlRead($List1)

if  $temp = "NOTAS" or $temp = "IDENTIDAD" or $temp = "BANCOS"  or $temp = "TARGETAS" or $temp = "CONTRASEÑAS"  _
or $temp = "FINANZAS" or $temp = "WEBS" then
$flag = 1
EndIf

if $flag = 1 then
MsgBox(0,"Información","No se puede eliminar una categoría por defecto")
Return
EndIf


$temp = MsgBox($MB_OKCANCEL,"Advertencia","Se eliminará la categoría y todas sus entradas asociadas. ¿Proceder?")

if $temp = $IDOK then
	IniDelete($G_BDFile,Y_CipherText(GUICtrlRead($List1)))
	GUICtrlSetData($List1,"")
	GUICtrlSetData($List2,"")
	Y_LoadBD()
EndIf

EndFunc


;botón Adiciona una nueva entrada para una categoria
func btn_AddEntrada()
Local $temp, $temp2, $flag, $i, $index

GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)


$temp = StringStripWS(InputBox("Agregar una nueva entrada","Coloque una nueva entrada"),$STR_STRIPALL)

if $temp = "" then return

;Determinar si es una entrada ya existente:
$temp2 = _GUICtrlListBox_GetCount ( $List2 )
for $i = 0 to $temp2-1
	if $temp = _GUICtrlListBox_GetText ( $List2, $i ) then $flag = 1
Next

if $flag = 1 Then
	MsgBox(0,"Información","No es posible establecer entradas duplicadas")
	Return
EndIf

$index = _GUICtrlListBox_GetCurSel ( $List1 )
IniWrite($G_BDFile,Y_CipherText(GUICtrlRead($List1)),Y_CipherText($temp),"")
GUICtrlSetData($List2,"")
Y_LoadBD()
_GUICtrlListBox_SetCurSel($List1,$index)
Y_LoadSecction()
EndFunc


;botón Eliminar una entrada para una categoría
Func btn_DelEntrada()
Local $temp

GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)


if MsgBox($MB_OKCANCEL,"Advertencia","¿Desea eliminar este elemento?") = $IDCANCEL  then return

$temp =  _GUICtrlListBox_GetCurSel ( $List1 ); Guarda la posición del elemento actual
IniDelete($G_BDFile,Y_CipherText(GUICtrlRead($List1)),Y_CipherText(GUICtrlRead($List2)))
GUICtrlSetData($List2,"")
Y_LoadBD()
_GUICtrlListBox_SetCurSel($List1,$temp)
Y_LoadSecction()
EndFunc


;botón modificar contenido de entrada entrada
func Btn_ModifEntrada()

if GUICtrlRead($Button6) = "Modificar" Then
GUICtrlSetData($Button6,"Actualizar")
GUICtrlSetState($Edit1,$GUI_ENABLE)
GUICtrlSetState($Edit1,$GUI_FOCUS)
Else ; LLevar a cabo una actualizazión

if IniWrite($G_BDFile,Y_CipherText(GUICtrlRead($List1)),Y_CipherText(GUICtrlRead($List2)),Y_CipherText(GUICtrlRead($Edit1))) = 0 then MsgBox(0,"Error","No se ha podido modificar la entrada")
GUICtrlSetData($Button6,"Modificar")
GUICtrlSetState($Edit1,$GUI_DISABLE)
GUICtrlSetState($List2,$GUI_FOCUS)


endif

EndFunc














;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::  FUNCIONES INTERNAS ::::::::::::::::::::::::::::::::::::::::::::::





;Descifra el fichero y carga el contenido en la GUI
func Y_LoadBD()
Local $temp, $i

$temp = IniReadSectionNames ( $G_BDFile)
if @error <> 0 then
	MsgBox(0,"ERROR","No se ha podido cargar el contenido de la base de datos")
	return
EndIf



;Carga las entradas cifradas
for $i = 1 to $temp[0]
	if $temp[$i]= "" then ContinueLoop  ;obvia las secciones en blanco
GUICtrlSetData($List1,Y_DesCipherText($temp[$i]))
Next


EndFunc





;Carga el contenido de una sección cuando esta se selecciona en el list1
func Y_LoadSecction()
Local $temp, $temp2, $i

$temp = IniReadSection($G_BDFile,Y_CipherText(GUICtrlRead($List1)))

if @error <> 0 then return


for $i = 1 to $temp[0][0]
GUICtrlSetData($List2,Y_DesCipherText($temp[$i][0]))
next

EndFunc




;Carga el contenido de un item en particular
func Y_LoadItem()
Local $temp
$temp = IniRead($G_BDFile,Y_CipherText(GUICtrlRead($List1)),Y_CipherText(GUICtrlRead($List2)),"")
GUICtrlSetData($Edit1,Y_DesCipherText($temp))
EndFunc


;Cifra un texto determiando y devuelve el texto cifrado
Func Y_CipherText($text)
Local $temp

$temp = _Crypt_EncryptData($text,$G_C_key,$CALG_AES_256)

if @error <> 0 then ;error
Return 1
EndIf

Return $temp

EndFunc



;DesCifra un texto determiando y devuelve el texto descifrado
Func Y_DesCipherText($textCifrado)
Local $temp


$temp = _Crypt_DecryptData($textCifrado,$G_C_key,$CALG_AES_256)

if @error <> 0 then Return "";error

$temp = BinaryToString($temp); Pasando el valor descifrado a cadena
if @error = 1 then Return ""

return $temp
EndFunc



;Clave única en tiempo de ejecución !!!!Advertencia esta clave no puede ser olvidada!!!
;Retorna 0 si ha habido algún error
;Retorna 1 si todo OK
func tufmo()
Local $temp,$temp2, $i

;Modificando la clave principal de cifrado con una clave dada en tiempo de ejecución
$temp = InputBox("Subclave flotante","!No puede olvidar esta clave!.","","-")
$temp = StringStripWS($temp,8)

if StringLen($temp) < 4 then ;si no se ha dado clave salir del programa
	MsgBox(0,"Error","La clave debe contener al menos 4 caracteres. No se permite espacios")
	return 0
EndIf

;estableciendo la base de la clave
$G_C_key="^RJaX$,dcn%wfwf*rf306-ET*-by3=O"



;Generando permutaciones entre esta clave y la clave principal
;número de ciclos de permutaciones:
for $i = 1 to 4
	$temp2 = StringLeft ( $temp, $i )
$G_C_key = _StringInsert ( $G_C_key, $temp2, $i+3 )
$G_C_key = _StringInsert ( $G_C_key, $temp2, -1 * ($i+4) )
$G_C_key = _StringInsert ( $G_C_key, $temp2, -1 * ($i+5) )
next


ClipPut($G_C_key)
return 1 ; Todo OKOK
EndFunc



