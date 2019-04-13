; Keyboard Commands : e -> Eraser Mode , g -> Green Color , w -> White Color , y -> Yellow Color

.data
n db 8 ; 320/40 & 200/25 both equals 8 
temp DB 1
COLOR DB 1
BRUSH DB 1 
.code
mov al, 13h
mov ah, 0
int 10h ; Setup Graphics

mov ax, 0
int 33h ;init mouse
mov BH , 0
;------------ SOME RUBUSH TO GIVE TIME TO MAXIMIZE THE SCREEN
mov cx , 10
LBL:
push CX
mov al , '.'
mov ah, 09h
mov BH , 0  
MOV cx , 2  
int 10h
POP CX
loop LBL
;------------ SOME RUBUSH TO GIVE TIME TO MAXIMIZE THE SCREEN END
mov cx ,4 
mov dh , 2

mov COLOR ,  1111b ; Set Default Color
mov BRUSH , '*'    ; Set Default Brush

GREEN:  MOV BL , 0010b ;Green 
        call DrawColorBoxex
        loop GREEN
          
mov cx ,4        
add dh , 3        
WHITE:  MOV BL , 1111b ;White 
        call DrawColorBoxex
        loop WHITE

mov cx ,4        
add dh , 3        
Yellow: MOV BL , 1110b ;Yellow 
        call DrawColorBoxex
        loop Yellow



MOV BL , 1111b ;White
add dh ,1
        
MOV AL , '/'
Call DrawBrush
MOV AL , '*'
Call DrawBrush
MOV AL , '$'
Call DrawBrush
          
          
          
L1: 
    mov AH ,01h
    int 16h
    jz p2 ;If nothing pressed by user continue
    cmp AL , 'g'
    jne ChangeToWhite
    mov COLOR ,  0010b
    
    
    ChangeToWhite:
    cmp AL , 'w'
    jne ChangeYellow
    mov COLOR ,  1111b
    
    ChangeYellow:
    cmp AL , 'y'
    jne MakeEraser
    mov COLOR ,  1110b
    
    MakeEraser:
    cmp AL , 'e'
    jne Flush
    mov COLOR ,  0

    
    Flush:
    mov AH ,0ch
    int 21h ;FLush KeyBoard
    
    p2:
    push DX
    mov ax , 3 
    int 33h   
    CMP BX , 1
    JNE NEXT ; if mouse is not clicked dont draw
    push CX
    push DX
    shr CX , 4
    shr DX , 3
    
    ; ----- Check Color Changed -------------
    cmp CX , 3 ; If Exceeded Column 3 Color Won't Be Changed
    ja ColornotChanged
    
    CheckGreen:
    cmp DX , 2 ;Check If Green Clicked From 2 til 5
    jb  CheckWhite
    cmp DX , 5
    ja  CheckWhite
    mov BL , 0010b ;Change Color To Green
    jmp AFTER_COLOR_CHANGED
    
    CheckWhite:
    cmp DX , 9 ;Check IfWhite Clicked From 9 til 12
    jb  CheckYellow
    cmp DX , 12
    ja  CheckYellow
    mov BL , 1111b ;Change Color To WHITE
    jmp AFTER_COLOR_CHANGED
    
    CheckYellow:
    cmp DX , 16 ;Check If Yellow Clicked From 16 til 19
    jb  CheckSlash
    cmp DX , 19
    ja  CheckSlash
    mov BL , 1110b ;Change Color To Yellow
    jmp AFTER_COLOR_CHANGED
    
    
    
    ; ----- Check Brush Changed -------------
    
    CheckSlash:
    cmp DX , 21 ;Check / On Line 21
    jne  CheckASterisk
    mov BRUSH , '/'
    jmp NEXT
    
    CheckASterisk:
    cmp DX , 22 ;Check * On Line 22
    jne  CheckDollar
    mov BRUSH , '*'
    jmp NEXT
    
    CheckDollar:
    cmp DX , 23 ;Check $ On Line 23
    jne  ColornotChanged
    mov BRUSH , '$'
    jmp NEXT
    
    
    AFTER_COLOR_CHANGED:
    mov COLOR , BL
    jmp NEXT
    
    ColornotChanged:POP DX 
                    POP CX
                    Call DrawChar
    NEXT: jmp L1 
              
proc DrawChar
    mov bh , 0 ; PAGE NUMBER
    shr cx , 1 ; CX is Doubled , DIV by 2 
    mov AX , CX
    div n
    mov temp , al ; not to loose data after the second division
    mov ax , dx
    div n
    ; After Converting X & Y to their corresponding ROW AND COL assign them for drawing
    mov dh , al
    mov dl , temp 
    
    mov ah, 2
	int 10h ; Set Cursor Position
     
    mov al , BRUSH ;CHAR 
    MOV BL , COLOR ;COLOR
    ;MOV BL , 1100b ;COLOR
    MOV cx , 1  
    mov ah , 09h 
    int 10h 
    ret
endP DrawChar   

proc DrawColorBoxex USES CX ;Parameters BL -> Color
    push CX
    mov ah, 2 
    mov dl , 0
	int 10h ; Set Cursor Position 
	mov al , '*' ;CHAR
    MOV cx , 4  
    mov ah , 09h 
    int 10h
    add dh , 1
    pop CX 
    ret
endP DrawColorBoxex  


proc DrawBrush ;Parameters AL -> BRUSH
    push CX
    mov ah, 2 
    mov dl , 0
	int 10h ; Set Cursor Position 
    MOV cx , 1  
    mov ah , 09h 
    int 10h
    add dh , 1
    pop CX 
    ret
endP DrawBrush 