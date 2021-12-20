data segment
    
    enbuyuk dw ?                                               ;dizinin en buyuk elemani
    Yaz1  DB  'Dizinin elemanlarini giriniz :',0DH,0AH,'$'     ;0DH,0AH yeni satir komutu
    Yaz2  DB  'En buyuk dizi elemani : $'                      ;tum elemanlarinin degeri bos olan bir dizi
    dizi  DW 10 dup(?)  
ends  




stack segment
    dw   128  dup(0)
ends
       
       
       
code segment
main proc    
             
    
    mov ax, data    ; basla
    mov ds, ax
    mov es, ax
           
           
      
    lea si,dizi     ; dizinin ilk adresini si'ye ata
    
     
    mov BX, 10      ; Dongu adedi                
    lea DX, Yaz1    ; Yaz1 degiskeninin adresini dx ata               
    mov AH, 9       ; Prompt'a Yaz1'i yaz
    int 21H  
          
     

    call diziyi_Al  ; diziyi klavyeden almak icin diziyi_Al prosedurunu cagir             
           
    lea si,dizi     ; dizinin ilk adresini si'ye ata
    
    mov bx, [si]    ;dizinin ilk adresini bx'e ata  yani ilk eleamani bx'e ata
    mov cx, 18      ;dizinin elemanlari 0 dan 9'a kadar indisli
                    ;herbir eleman dw oldugunda 9x2=18 cx'e atanir       
    
    dongu:
    add si,2        ;elemanlar 2 bayt oldugundan 2'ser olarak artacak
    
    cmp bx,[si]     ;bx ile elemani karsilstir diger sonraki dizi elamanini karsilastir
    jb degis        ;bx buyukse degistir.
    devam:
    loop dongu      ;aksi taktirde donguye tekrar devam et
    
    jmp son         ;eger dogu bittiyse donguyu sonlandir
    
    degis:          ;takas islemlerini yap
    mov bx,[si]
    jmp devam       ;sonra donguye devam et



    son:
    mov enbuyuk,bx  ;dongunden sonra bx'te dizinin en buyuk elemani kalir onu enbuyuk degiskenine ata  
        
 
    
     LEA DX, Yaz2   ;Yaz2 string'ini yaz             
     MOV AH, 9     
     INT 21H 
              
 
     LEA SI, enbuyuk                ; enbuyuk elemanin offset adresini si'ye ata

     CALL sayiyi_Yaz                ; sayiyi_Yaz prosedurunu cagir             


        
     mov ax, 4c00h                   ;Bitir
     int 21h  
      
main endp          
      
                
                

 ;**************************************************************************;      
 ;diziyi_Al proseduru dizi elemanlarini klavyeden teker teker alir
 ;girdiler:  SI = verilen dizinin offset adresi
 ;           BX = dizinin eleman sayisi 
 ;cikti   : yok
 ;**************************************************************************;    
 diziyi_Al proc


   push ax           ; ax 'i yigina ekle                   
   push cx           ; cx 'i yigina ekle              
   push dx           ; dx 'i yigina ekle              

   mov cx, bx        ; bx dizinin eleman sayisidir bunu cx'e ata             

   @diziyi_Al:                   
     call yazim_Denetimi      ;yazim denetimi yapan prosedur             

     mov [si], ax             ;[si] = ax atamasi yap   
     add si, 2                ;si = si+2 atamasi yap    

     mov dl, 0AH              ;her eleman icin bir satir     
     mov ah, 2                ;bir karakter yaz    
     int 21H                      
   loop @diziyi_Al            ;cx sifir olmadigi muddetce donguye devam et 

   pop DX                     ;yigindan dx'e ata    
   pop CX                     ;yigindan cx'e ata    
   pop AX                     ;yiginden ax'e ata    

   ret                         
 diziyi_Al endp               ;cagiran prosedure geri don   
            
            
            
;**************************************************************************;            
;Bu prosedur klavyeden sayilari ondalik formatinda okutur.
;Girdi: yok
;Cikti: sayilarin ikilik formatini AX'e atar
;**************************************************************************;       
             
 yazim_Denetimi proc

   push bx           ; bx 'i yigina ekle                 
   push cx           ; cx 'i yigina ekle                 
   push dx           ; dx 'i yigina ekle                

   jmp @oku          ; oku etiketine git            

   @backspace_Atla:  ; backspace tusuna basilirsa geri islem yapar             
   mov ah, 2         ; cikti fonksiyonunu ayarla             
   mov dl, 20H       ; dl ye ' ' ata             
   int 21H           ; karakter yaz             

   @oku:                         
   xor bx, bx        ; bx'i sil             
   xor cx, cx        ; cx'i sil             
   xor dx, dx        ; dx'i sil             

   mov ah, 1         ; girdi fonksiyonunu ayarla             
   int 21H           ; bir karakter oku             

   cmp al, "-"       ; al'i - ile karsilastir             
   je @eksi          ; al'de - varsa @eksi etiketine git            

   cmp al, "+"       ; al'i + ile karsilastir             
   je @arti          ; al'de + varsa @arti etiketine git             

   JMP @girisi_Atla  ;              

   @eksi:                        
   mov ch, 1         ; ch=2 ata             
   inc cl            ; cl=cl+1 arttir             
   jmp @giris                    
   
   @arti:                         
   mov ch, 2         ; ch=2 ata             
   inc cl            ; cl=cl+1 arttir             

   @giris:                        
     mov ah, 1       ; giris fonksiyonunu ayarla             
     int 21H         ; bir karakter oku             

     @girisi_Atla:               ; etikete git  
                                 
     cmp al, 0DH                 ; AL ile CR'yi kiyasla 
     je @giris_Sonlandir         ; @giris_Sonlandir etiketine git

     cmp al, 8H                  ; al'yi 8H ile kiyasla 
     jne @backspace_Degil        ; ch!=8 ise @backspace_Degil etiketine git   

     cmp ch, 0                   ; ch'yi 0 ile kiyasla  
     jne @eksi_yok_kontrol       ; ch!=0 ise @eksi_yok_kontrol etiketine git 

     cmp cl, 0                   ; cl'yi 0 ile kiyasla  
     je @backspace_Atla          ; cl=0 ise  @backspace etiketine git 
     jmp @geri_Git               ; @geri_Git etiketine git 

     @eksi_yok_kontrol:         

     cmp ch, 1                   ; ch ile 1'i kiyasla 
     jne @arti_yok_kontrol       ; ch!=1 ise @arti_yok_kontrol etiketine atla

     cmp cl, 1                   ; cl ile 1'i kiyasla 
     je @arti_eksi_at            ; cl=1 ise @arti_eksi_at etiketine git

     @arti_yok_kontrol:              

     cmp cl, 1                   ; CL ile 1'i kiyasla 
     je @arti_eksi_at            ; cl=1 ise @arti_eksi_at etiketine git
     jmp @geri_Git               ; @geeri_Git etiketine git

     @arti_eksi_at:          
       mov ah, 2                 ; cikis fonksiyonunu ayarla
       mov dl, 20H               ; DL=' ' ata 
       int 21H                   ; bir karakter yazdir 

       mov dl, 8H                ; DL=8H ata 
       int 21H                   ; bir karakter yazdir 

       jmp @oku                  ; @oku etiketine git
                                  
     @geri_Git:                  
                                 
     mov ax, bx                  ; AX=BX ata
     mov bx, 10                  ; BX=10 ata  
     div bx                      ; AX=AX/BX

     mov bx, ax                  ; bx=ax ata

     mov ah, 2                   ; cikis fonksiyonunu ayarla 
     mov dl, 20H                 ; DL = ' ' ata
     int 21H                     ; bir karakter yaz 

     mov dl, 8H                  ; DL = 8H 
     int 21H                     ; bir karakter yaz 

     xor dx, dx                  ; DX'i sil 
     dec cl                      ; CL=CL-1 azalt

     jmp @giris                   

     @backspace_Degil:              

     inc cl                      ; CL = CL+1 arttir 

     cmp al, 30H                 ; AL ile 0'i kiyasla 
     jl @hata                    ; AL<0 ise @hata etiketine git

     cmp al, 39H                 ; AL ile 9'u kiyasla
     jg @hata                    ; AL>0 ise @hata etiketine git

     and ax, 000FH               ; ascii'yi ondalik sayiya cevir 

     push ax                     ; AX'i yigina ekle 
                                 
     mov ax, 10                  ; AX=10 ata 
     mul bx                      ; AX=AX*BX ata
     mov bx, ax                  ; BX=AX ata

     pop ax                      ; yigindan bir degeri AX'e ata

     add bx, ax                  ; BX=AX+BX ata 
     JS @hata                    ; SF=1 ise @hata etiketine git
   JMP @giris                    ; @giris etiketine git 

   @hata:                        
                                 
   mov ah, 2                     ; cikis fonksiyonunu ayarla
   mov dl, 7H                    ; DL=7H ata 
   int 21H                       ; bir karakter yaz 

   xor ch, ch                    ; CH'yi sil                     

   @temizle:                        
     mov dl, 8H                  ; DL=8 ata 
     int 21H                     ; bir karakter yaz 

     mov dl, 20H                 ; DL= ' ' ata 
     int 21H                     ; bir karakter yaz 

     mov dl, 8H                  ; DL=8H ata   
     int 21H                     ; bir karakter yaz 
   loop @temizle                 ; CX!=0 ise @temzile etiketine git   

   jmp @oku                      ; @oku etiketine git

   @giris_Sonlandir:                    

   cmp ch, 1                     ; CH'yi 1 ile kiyasla   
   jne @cik                      ; CH!=1 ise @cik etiketine git
   neg bx                        ; BX'i degille (Tumleyenini al) 

   @cik:                         

   mov ax, bx                    ; AX=BX ata

   pop dx                         
   pop cx                        ; Yigindan bir degeri DX'e ata 
   pop bx                        ; Yigindan bir degeri CX'e ata
                                 ; Yigindan bir degeri BX'e ata
   ret                            
 yazim_Denetimi endp           
             



;**************************************************************************;
; sayiyi_Yaz Proseduru 
; Bu prosedur herhangi bir sayiyi ekrana yazar
; Girdi : SI=sayinin offset adresi
; Cikti : yok
;**************************************************************************; 


sayiyi_Yaz proc


   push ax                        ; Yigina AX'i ekler   
   push cx                        ; Yigina CX'i ekler 
   push dx                        ; Yigina DX'i ekler 

   mov cx, bx                     ; CX=BX ata

     mov ax, [si]                 ; AX=AX+[SI] ata

     call cikis_yazim_Denetimi    ; cikis_yazim_Denetimi prosedurunu cagir

     mov ah, 2                    ; cikis fonksiyonunu ayarla
     mov dl, 20H                  ; DL=20H ata
     int 21H                      ; bir karakter yazdir
     
   pop dx                         ; Yigindan bir degeri DX'e getir
   pop cx                         ; Yigindan bir degeri CX'e getir
   pop ax                         ; Yigindan bir degeri AX'e getir

   ret                            ; cagiran prosedure gerti don
 sayiyi_Yaz endp


       
         
;**************************************************************************;
; cikis_yazim_Denetimi Proseduru 
; bu prosedur sayiyi ondalik olarak yazar
; Girdi : AX
; Cikti : yok
;**************************************************************************;

 cikis_yazim_Denetimi proc

   push bx                        ; Yigina BX'i ekler
   push cx                        ; Yigina CX'i ekler
   push dx                        ; Yigina DX'i ekler

   cmp ax, 0                      ; AX 0 ile kiyasla
   jge @baslangic                 ; AX>=0 ise @baslangic etiketine git

   push ax                        ; Yigina AX'i ekle

   mov ah, 2                      ; cikis fonksiyonunu ayarla
   mov dl, "-"                    ; DL='-' ata
   int 21H                        ; bir karakter yazdir

   pop ax                         ; Yigindan bir degeri AX'e ata

   neg ax                         ; AX'in 2'ye tumleyenini al

   @baslangic:                    

   xor cx, cx                     ; CX'i sil
   mov bx, 10                     ; BX=10 ata

   @cikti:                        
     xor dx, dx                   ; DX'i sil
     div bx                       ; AX'i BX'e bol
     push dx                      ; Yigina DX'i ekle
     inc cx                       ; CX'i arttir
     or ax, ax                    ; AX'in VEYA islemine sok
   jne @cikti                     ; ZF=0 ise @cikti etiketine git

   mov ah, 2                      ; cikis fonksiyonunu ayarla

   @goster:                      
     pop dx                       ; Yigindan bir degeri DX'e ata
     or dl, 30H                   ; Ondalik sayiyi ascii koda cevir
     int 21H                      ; bir karakter yaz
   loop @goster                   ; CX!=0 ise @goster etiketine git

   pop dx                         ; Yigindan bir degeri DX'e getir
   pop cx                         ; Yigindan bir degeri CX'e getir
   pop bx                         ; Yigindan bir degeri BX'e getir

   ret                            ; cagiran prosedure don
 cikis_yazim_Denetimi endp

