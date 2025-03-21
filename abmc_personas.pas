unit ABMC_PERSONAS;

interface

uses
  CLASSES, SysUtils, crt, ARCHIVO_PERSONAS, ARBOL_PERSONA, USA_ARCH_PERSONA, USA_ARCH_TERRENO, ARCHIVO_TERRENO;
VAR BAJAS:BYTE;
  PROCEDURE ALTA_PERSONA(VAR RAIZNOM:T_PUNT; VAR RAIZDNI:T_PUNT; VAR ARCH:T_ARCHIVO_PROP);
PROCEDURE BAJA_PERSONA (VAR RAIZNOM:T_PUNT;VAR RAIZDNI:T_PUNT; VAR ARCH_PROP:T_ARCHIVO_PROP; VAR ARCH_TERR:T_ARCHIVO_TERR);
PROCEDURE MODIFICAR_PERSONA (VAR ARCH:T_ARCHIVO_PROP; VAR RAIZDNI:T_PUNT; VAR RAIZNOM:T_PUNT);
PROCEDURE CONSULTAR_PERSONA (VAR ARCH:T_ARCHIVO_PROP; VAR RAIZDNI:T_PUNT; VAR RAIZNOM:T_PUNT);

implementation

PROCEDURE ALTA_PERSONA(VAR RAIZNOM:T_PUNT; VAR RAIZDNI:T_PUNT; VAR ARCH:T_ARCHIVO_PROP);
VAR
    X:T_DATO_PROP;
    POS:BYTE;
    I:INTEGER;
    RES,RES2:STRING[2];
    NOM,DNIBUSCADO,NUM,DNI2:STRING;
    ERROR,ENC:BOOLEAN;
BEGIN
 CLRSCR;
 ABRIR_P(ARCH);
 TEXTBACKGROUND(3);
 GOTOXY(47,7);
 WRITELN('   ALTA DE PERSONA   ');
 TEXTBACKGROUND(8);
 GOTOXY(43,11);
 ERROR:=FALSE;
 REPEAT
   REPEAT
      CLRSCR;
      TEXTBACKGROUND(3);
      GOTOXY(47,7);
      WRITELN('   ALTA DE PERSONA   ');
      TEXTBACKGROUND(8);
      IF ERROR=TRUE THEN
      BEGIN
         GOTOXY(56,11);
         WRITELN('                                        ');
         TEXTBACKGROUND(4);
         GOTOXY(43,12);
         WRITELN('EL DNI INGRESADO NO ES VALIDO, INTENTE NUEVAMENTE.');
         TEXTBACKGROUND(8);
      END;
      GOTOXY(43,11);
      WRITELN('INGRESE DNI:');
      GOTOXY(56,11);
      READLN(DNI2);
      ERROR:=FALSE;
      IF NOT(TRYSTRTOINT(DNI2,I))  THEN
       BEGIN
            ERROR:=TRUE;
       END
      ELSE X.DNI := DNI2;
   UNTIL  ERROR=FALSE;
   GOTOXY(43,12);
   WRITELN(UTF8TOANSI('¿ES CORRECTO EL DNI INGRESADO?  (SI/NO)                             '));
   GOTOXY(43,13);
   READLN(RES2);
 UNTIL (RES2='SI') OR (RES2='Si') OR (RES2='si') OR (RES2='sI');
 GOTOXY(43,12);
 WRITELN('                                                            ');
 GOTOXY(43,13);
 WRITELN('                                                            ');
 DNIBUSCADO:=X.DNI;
 ENC:=FALSE;
 IF FILESIZE(ARCH)>=1 THEN
  BEGIN
   BUSCAR_ARCH_DNI2_P(ARCH,DNIBUSCADO,POS,ENC);
  END
 ELSE
   ENC:=FALSE;
  IF NOT(ENC) THEN
  BEGIN
    NUM:= INTTOSTR(FILESIZE(ARCH));
    X.NRO_CONTR:=NUM;
    CARGAR_PERSONA(X);
    GOTOXY(43,20);
    WRITELN(UTF8TOANSI('¿CONFIRMA LOS DATOS INGRESADOS? (SI/NO)'));
    GOTOXY(43,21);
    READLN(RES);
    IF (RES='SI') OR (RES='Si') OR (RES='si') OR (RES='sI') THEN
    BEGIN
       AGREGAR_PERSONA(ARCH,X);                                     //AGREGA EN ULTIMA POSICION
       AGREGAR_ARBOL(RAIZDNI, X.DNI);
       NOM:=CONCAT(X.AP+' '+X.NOM);
       AGREGAR_ARBOL(RAIZNOM, NOM);
       GOTOXY(43,22);
       WRITELN('LA PERSONA SE HA DADO DE ALTA EXITOSAMENTE.');
       GOTOXY(43,23);
       WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
       GOTOXY(43,24);
       READKEY;
       CLRSCR;
       CERRAR_P(ARCH);
    END
    ELSE
    BEGIN
    ALTA_PERSONA(RAIZNOM, RAIZDNI, ARCH);
    END;
  END
  ELSE
  BEGIN
  SEEK(ARCH,POS);
  READ(ARCH,X);
   IF X.ESTADO THEN
   BEGIN
    GOTOXY(43,13);
    WRITELN('LA PERSONA SUJETA AL DNI INGRESADO YA SE ENCUENTRA REGISTRADA');
    GOTOXY(43,15);
    WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
    GOTOXY(43,16);
    READKEY;
    CLRSCR;
   END
   ELSE
   BEGIN
    GOTOXY(43,13);
    WRITELN('LA PERSONA SUJETA AL DNI INGRESADO FUE REGISTRADA Y DADA DE BAJA.');
    GOTOXY(43,14);
    WRITELN(UTF8TOANSI('¿DESEA DARLA DE ALTA NUEVAMENTE?  (SI/NO)'));
    GOTOXY(43,15);
    READLN(RES2);
    IF (RES2='SI') OR (RES2='Si') OR (RES2='si')OR (RES2='sI') THEN
     BEGIN
      BAJAS:= BAJAS-1;
      X.ESTADO:=TRUE;
      SEEK(ARCH,POS);
      WRITE(ARCH,X);
      GOTOXY(43,16);
      WRITELN('LA PERSONA HA SIDO DADA DE ALTA EXITOSAMENTE.');
      GOTOXY(43,17);
      WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
      GOTOXY(43,18);
      READKEY;
     END
    ELSE
    BEGIN
      GOTOXY(43,16);
      WRITELN('LA PERSONA NO HA SIDO DADA DE ALTA.');
      GOTOXY(43,17);
      WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
      GOTOXY(43,18);
      READKEY;
    END;
   END;
   CERRAR_P(ARCH);
 END;
END;


PROCEDURE BAJA_PERSONA(VAR RAIZNOM:T_PUNT;VAR RAIZDNI:T_PUNT; VAR ARCH_PROP:T_ARCHIVO_PROP; VAR ARCH_TERR:T_ARCHIVO_TERR);
 VAR
    I:INTEGER;
    DNIBUSCADO,DNI,DNI2,NOM,NRO_CONTR,OP: STRING;
    X,NUEVO:T_DATO_PROP;
    Y:T_DATO_TERR;
    POS,POS2,POS3,L,ACGOTOXY,B,A,AC: BYTE;
    R,RES2:STRING[2];
    R2:1..2;
    ENC,ERROR:BOOLEAN;

BEGIN
  CLRSCR;
  ABRIR_P(ARCH_PROP);
  ABRIR_T(ARCH_TERR);
  TEXTBACKGROUND(3);
  GOTOXY(47,7);
  WRITELN('   BAJA DE PERSONA   ');
  TEXTBACKGROUND(8);
  GOTOXY(43,11);
  WRITELN('INGRESE DNI DE LA PERSONA A DAR DE BAJA:');
  GOTOXY(43,12);
  REPEAT
    REPEAT
       ERROR:=FALSE;
       CLRSCR;
       GOTOXY(50,7);
       WRITELN('BAJA DE PERSONA');
       GOTOXY(43,11);
       WRITELN('INGRESE DNI:');
       GOTOXY(56,11);
       READLN(DNI2);
       IF NOT(TRYSTRTOINT(DNI2,I))THEN
        BEGIN
             GOTOXY(56,11);
             WRITELN('                                        ');
             GOTOXY(43,12);
             WRITELN('EL DNI INGRESADO ES INVALIDO, INTENTE NUEVAMENTE.');
             ERROR:=TRUE;
          END
       ELSE
       BEGIN
       STRTOINT(DNI2);
       DNIBUSCADO:=DNI2;
       END;
    UNTIL  ERROR=FALSE;
    GOTOXY(43,12);
    WRITELN(UTF8TOANSI('¿ES CORRECTO EL DNI INGRESADO?  (SI/NO)                             '));
    GOTOXY(43,13);
    READLN(RES2);
  UNTIL (RES2='SI') OR (RES2='si') OR (RES2='Si') OR (RES2='sI');
  ENC:=FALSE;
  BUSCAR_ARCH_DNI_P(ARCH_PROP,DNIBUSCADO,POS,ENC);
  IF ENC THEN
  BEGIN
    SEEK(ARCH_PROP,POS);
    READ(ARCH_PROP,X);
    GOTOXY(43,14);
    WRITELN('DATOS DE LA PERSONA: ');
    GOTOXY(8,16);
    CAMPOS_PERSONA();
    L:=17;
    MOSTRAR_PERSONA(X,L);
    GOTOXY(43,19);
    WRITELN(UTF8TOANSI('¿DESEA DAR DE BAJA A ESTA PERSONA? (SI/NO)'));
    GOTOXY(43,20);
    READLN(R);
    IF (R='SI') OR (R='si') OR (R='Si')OR (R='sI') THEN
    BEGIN
      NRO_CONTR:=X.NRO_CONTR;
      NOM:=CONCAT(X.AP+' '+X.NOM);
      ACGOTOXY:=23;
      BUSCAR_TERRENO_CONTR(ARCH_TERR,NRO_CONTR,NOM,ACGOTOXY);
      BAJAS:=BAJAS+1;
      IF ACGOTOXY<>23 THEN
      BEGIN
        GOTOXY(1,22);
        WRITELN(' APELLIDO Y NOMBRE|');
        GOTOXY(20,22);
        CAMPOS_T();
        ACGOTOXY:=ACGOTOXY+1;
        GOTOXY(27,ACGOTOXY);
        WRITELN(UTF8TOANSI('ESTOS TERRENOS ESTÁN SUJETOS A LA PERSONA QUE SE DESEA DAR DE BAJA, ELIJA UNA OPCIÓN.'));
        ACGOTOXY := ACGOTOXY+1;
        GOTOXY(43,ACGOTOXY);
        WRITELN(UTF8TOANSI('1-DAR DE BAJA LOS TERRENOS.'));
        ACGOTOXY := ACGOTOXY+1;
        GOTOXY(43,ACGOTOXY);
        WRITELN(UTF8TOANSI('2-CAMBIAR DE PROPIETARIOS LOS TERRENOS.'));
        ACGOTOXY := ACGOTOXY+1;
        GOTOXY(43,ACGOTOXY);
        ACGOTOXY := ACGOTOXY+1;
        AC:=1;
        REPEAT
         IF AC=2 THEN
         BEGIN
          GOTOXY(43,ACGOTOXY-1);
          WRITELN('                                        ');
          GOTOXY(43,ACGOTOXY);
          WRITELN('LA OPCION INGRESADA ES INVALIDA, INTENTE NUEVAMENTE.');
         END;
         ERROR:=FALSE;
         READLN(OP);
         IF NOT(TRYSTRTOINT(OP,I)) THEN
         BEGIN
             GOTOXY(43,ACGOTOXY-1);
             WRITELN('                                        ');
             GOTOXY(43,ACGOTOXY);
             WRITELN('LA OPCION INGRESADA ES INVALIDA, INTENTE NUEVAMENTE.');
             ERROR:=TRUE;
          END
         ELSE
         BEGIN
         STRTOINT(OP);
         R2:=STRTOINT(OP);
         END;
         AC:=2;
        UNTIL ((R2=1) OR (R2=2)) AND (ERROR=FALSE);

      IF R2=1 THEN                         //ELIMINA LOS TERRENOS
      BEGIN
        FOR B:=1 TO ACGOTOXY-22 DO
        BEGIN
         ABRIR_T(ARCH_TERR);
         SEEK(ARCH_TERR,0);
         WHILE NOT(EOF(ARCH_TERR)) DO
         BEGIN
          READ(ARCH_TERR,Y);
          IF Y.NRO_CONTR=X.NRO_CONTR THEN
          BEGIN
               POS2:=FILEPOS(ARCH_TERR)-1;
               ELIMINAR_TERRENO(ARCH_TERR,POS2);
          END;
         END;
        END;
        CLRSCR;
        TEXTBACKGROUND(3);
        GOTOXY(47,7);
        WRITELN('   BAJA DE PERSONA   ');
        TEXTBACKGROUND(8);
        GOTOXY(43,11);
        WRITELN('LOS TERRENOS SE HAN DADO DE BAJA EXITOSAMENTE.');
        GOTOXY(43,12);
        WRITELN('PRESIONE UNA TECLA PARA CONTINUAR');
        GOTOXY(43,13);
        READKEY;
       END
      ELSE                           //CAMBIA DE PROPIETARIOS
      BEGIN
        ABRIR_T(ARCH_TERR);
        SEEK(ARCH_TERR,0);
        WHILE NOT(EOF(ARCH_TERR)) DO
        BEGIN
          READ(ARCH_TERR,Y);
          IF Y.NRO_CONTR=X.NRO_CONTR THEN
          BEGIN                                     //POS3 : POS DE NUEVO PROPIETARIO
               POS2:=FILEPOS(ARCH_TERR)-1;              //POS2 : POS DE TERRENOS A QUE CAMBIAR
               CLRSCR;                              //POS  : POS DE LA PERSONA A DAR DE BAJA
               TEXTBACKGROUND(3);                  //X    : PROPIETARIO A DAR DE BAJA
               GOTOXY(47,7);                       //Y    : TERRENOS A CAMBIAR DE PROPIETARIO
               WRITELN('   BAJA DE PERSONA   ');
               TEXTBACKGROUND(8);
               GOTOXY(8,11);
               CAMPOS_T();
               A:=12;
               MOSTRAR_DATOS(Y,A);
               GOTOXY(43,14);
               WRITELN('INGRESE DNI DEL NUEVO PROPIETARIO/A:');
               REPEAT
                 REPEAT
                 ERROR:=FALSE;
                 GOTOXY(80,14);
                 READLN(DNI2);
                 IF NOT(TRYSTRTOINT(DNI2,I)) THEN
                 BEGIN
                   GOTOXY(80,14);
                   WRITELN('                                        ');
                   GOTOXY(43,15);
                   WRITELN('EL DNI INGRESADO ES INVALIDO, INTENTE NUEVAMENTE.');
                   ERROR:=TRUE;
                  END
                 ELSE
                 BEGIN
                   STRTOINT(DNI2);
                   DNI:=DNI2;
                  END;
                UNTIL  ERROR=FALSE;
                GOTOXY(43,16);
                WRITELN(UTF8TOANSI('¿ES CORRECTO EL DNI INGRESADO?  (SI/NO)                             '));
                GOTOXY(43,17);
                READLN(RES2);
               UNTIL (RES2='SI') OR (RES2='Si') OR (RES2='si') OR (RES2='sI');
               ENC:=FALSE;
               BUSCAR_ARCH_DNI_P(ARCH_PROP,DNI,POS3,ENC);
               IF NOT(ENC) THEN
               BEGIN
               GOTOXY(43,16);
               WRITELN('LA PERSONA NO SE ENCUENTRA REGISTRADA.    ');
               GOTOXY(43,17);
               WRITELN(UTF8TOANSI('¿DESEA DAR DE ALTA AL NUEVO PROPIETARIO? (SI/NO)'));
               GOTOXY(43,18);
               READLN(R);
               IF (R='SI') OR (R='Si') OR (R='si') OR (R='sI') THEN
               BEGIN
               ALTA_PERSONA(RAIZNOM, RAIZDNI, ARCH_PROP);
               END
               ELSE
               BEGIN
               BAJA_PERSONA(RAIZNOM,RAIZDNI,ARCH_PROP,ARCH_TERR);
               END;
               END;
               ABRIR_P(ARCH_PROP);
               ENC:=FALSE;
               BUSCAR_ARCH_DNI_P(ARCH_PROP,DNI,POS3,ENC);
               IF (ENC) THEN
               BEGIN
               SEEK(ARCH_PROP,POS3);
               READ(ARCH_PROP,NUEVO);
               Y.NRO_CONTR:=NUEVO.NRO_CONTR;
               SEEK(ARCH_TERR,POS2);
               WRITE(ARCH_TERR,Y);
               GOTOXY(43,18);
               WRITELN('EL TERRENO HA CAMBIADO DE PROPIETARIO EXITOSAMENTE.');
               GOTOXY(43,19);
               WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
               GOTOXY(43,20);
               READKEY;
               CLRSCR;
               END;
          END;
        END;
      END;
    END;
      ABRIR_P(ARCH_PROP);
    X.ESTADO:=FALSE;                                 //ELIMINA AL PROPIETARIO
    SEEK(ARCH_PROP,POS);
    WRITE(ARCH_PROP,X);
    ELIMINAR_ARBOL(RAIZDNI,X.DNI);
    NOM:=CONCAT(X.AP+' '+X.NOM);
    ELIMINAR_ARBOL(RAIZNOM,NOM);
    CLRSCR;
    TEXTBACKGROUND(3);
    GOTOXY(47,7);
    WRITELN('   BAJA DE PERSONA   ');
    TEXTBACKGROUND(8);
    GOTOXY(43,11);
    WRITELN('LA PERSONA SE HA DADO DE BAJA EXITOSAMENTE.');
    GOTOXY(43,12);
    WRITELN('PRESIONA UNA TECLA PARA CONTINUAR.');
    GOTOXY(43,13);
    READKEY();
    CLRSCR;
    END ELSE
    BEGIN
      GOTOXY(43,22);
      WRITELN('NO SE HA DADO DE BAJA A LA PERSONA.');
      GOTOXY(43,23);
      WRITELN('PRESIONA UNA TECLA PARA CONTINUAR.');
      GOTOXY(43,24);
      READKEY();
      CLRSCR;
    END;
  END
  ELSE
  BEGIN
    GOTOXY(43,14);
    WRITELN('NO SE HA ENCONTRADO A LA PERSONA');
    GOTOXY(43,15);
    WRITELN('PRESIONA UNA TECLA PARA CONTINUAR');
    GOTOXY(43,16);
    READKEY();
  END;
  CLRSCR;
  CERRAR_P(ARCH_PROP);
  CERRAR_T(ARCH_TERR);
END;

PROCEDURE MODIFICAR_PERSONA(VAR ARCH:T_ARCHIVO_PROP; VAR RAIZDNI:T_PUNT; VAR RAIZNOM:T_PUNT);
VAR
  DNIBUSCADO:STRING;
  X:T_DATO_PROP;
  POS,L,AC:BYTE;
  R,R3:STRING[2];
  R2:1..9;
  ENC,ERROR:BOOLEAN;
  NOM,OP:STRING;
  I:INTEGER;
  BEGIN
    CLRSCR;
    ENC:=FALSE;
    TEXTBACKGROUND(3);
    GOTOXY(47,7);
    WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
    TEXTBACKGROUND(8);
    GOTOXY(43,11);
    WRITELN('INGRESE DNI DE LA PERSONA A MODIFICAR:');
    GOTOXY(43,12);
    READLN(DNIBUSCADO);
    ABRIR_P(ARCH);
    SEEK(ARCH,0);
    BUSCAR_ARCH_DNI_P(ARCH,DNIBUSCADO,POS,ENC);
    IF ENC THEN
    BEGIN
      SEEK(ARCH,POS);
      READ(ARCH,X);
      GOTOXY(8,14);
      CAMPOS_PERSONA();
      L:=15;
      MOSTRAR_PERSONA(X,L);
      GOTOXY(43,17);
      WRITELN(UTF8TOANSI('¿DESEA MODIFICAR ALGUN CAMPO DE LA PERSONA? (SI/NO)'));
      GOTOXY(43,18);
      READLN(R);
      IF (R='SI') OR (R='Si') OR (R='si') OR (R='sI') THEN
       BEGIN
        REPEAT                          // UN REPEAT PARA MODIFICAR MAS DE UN CAMPO.
          CLRSCR;
          TEXTBACKGROUND(3);
          GOTOXY(47,7);
          WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
          TEXTBACKGROUND(8);
          GOTOXY(43,11);
          WRITELN('INGRESE EL CAMPO QUE DESEE MODIFICAR: ');
          GOTOXY(43,12);
          WRITELN('1-APELLIDO');
          GOTOXY(43,13);
          WRITELN('2-NOMBRE');
          GOTOXY(43,14);
          WRITELN(UTF8TOANSI('3-DIRECCIÓN'));
          GOTOXY(43,15);
          WRITELN('4-CIUDAD');
          GOTOXY(43,16);
          WRITELN('5-FECHA DE NACIMIENTO');
          GOTOXY(43,17);
          WRITELN(UTF8TOANSI('6-TELÉFONO'));
          GOTOXY(43,18);
          WRITELN('7-EMAIL');
          AC:=1;
             REPEAT
              IF AC=2 THEN
                BEGIN
                  GOTOXY(43,19);
                  WRITELN('                                        ');
                  GOTOXY(43,20);
                  WRITELN('LA OPCION INGRESADA ES INVALIDA, INTENTE NUEVAMENTE.');
                END;
              ERROR:=FALSE;
              GOTOXY(43,19);
              READLN(OP);
                IF NOT(TRYSTRTOINT(OP,I))  THEN
                 BEGIN
                  GOTOXY(43,19);
                  WRITELN('                                        ');
                  GOTOXY(43,20);
                  WRITELN('LA OPCION INGRESADA ES INVALIDA, INTENTE NUEVAMENTE.');
                  ERROR:=TRUE;
                 END
                ELSE
                 BEGIN
                  STRTOINT(OP);
                  R2:=STRTOINT(OP)
                 END;
                AC:=2;
             UNTIL ((R2=0) OR (R2=1) OR (R2=2) OR (R2=3) OR (R2=4) OR (R2=5) OR (R2=6) OR (R2=7)) AND (ERROR=FALSE);

                CLRSCR;
                CASE R2 OF

                1: BEGIN
                  CLRSCR;
                  NOM:=CONCAT(X.AP+' '+X.NOM);                        //SI SE ELIMINA UN NOMBRE O APELLIDO, SE LO ELIMINA DEL ARBOL
                  ELIMINAR_ARBOL(RAIZNOM,NOM);                                  //Y SE LO VUELVE A AGREGAR NUEVAMENTE.
                  TEXTBACKGROUND(3);
                  GOTOXY(47,7);
                  WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
                  TEXTBACKGROUND(8);
                  GOTOXY(43,11);
                  WRITELN('INGRESE NUEVO APELLIDO');
                  GOTOXY(43,12);
                  READLN(X.AP);
                  NOM:=CONCAT(X.AP+' '+X.NOM);
                  AGREGAR_ARBOL(RAIZNOM,NOM);
                  END;
                2: BEGIN
                  CLRSCR;
                  NOM:=CONCAT(X.AP+' '+X.NOM);
                  ELIMINAR_ARBOL(RAIZNOM,NOM);
                  TEXTBACKGROUND(3);
                  GOTOXY(47,7);
                  WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
                  TEXTBACKGROUND(8);
                  GOTOXY(43,11);
                  WRITELN('INGRESE NUEVO NOMBRE');
                  GOTOXY(43,12);
                  READLN(X.NOM);
                  NOM:=CONCAT(X.AP+' '+X.NOM);
                  AGREGAR_ARBOL(RAIZNOM,NOM);
                  END;
                3: BEGIN
                  CLRSCR;
                  TEXTBACKGROUND(3);
                  GOTOXY(47,7);
                  WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
                  TEXTBACKGROUND(8);
                  GOTOXY(43,11);
                  WRITELN(UTF8TOANSI('INGRESE NUEVA DIRECCIÓN'));
                  GOTOXY(43,12);
                  READLN(X.DIR);
                  END;
                4: BEGIN
                  CLRSCR;
                  TEXTBACKGROUND(3);
                  GOTOXY(47,7);
                  WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
                  TEXTBACKGROUND(8);
                  GOTOXY(43,11);
                  WRITELN('INGRESE NUEVA CIUDAD');
                  GOTOXY(43,12);
                  READLN(X.CIUDAD);
                  END;
                5: BEGIN
                  CLRSCR;
                  TEXTBACKGROUND(3);
                  GOTOXY(47,7);
                  WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
                  TEXTBACKGROUND(8);
                  GOTOXY(43,11);
                  WRITELN('INGRESE NUEVA FECHA DE NACIMIENTO');
                  GOTOXY(43,12);
                  READLN(X.FECHA_NAC);
                  END;
                6: BEGIN
                  CLRSCR;
                  TEXTBACKGROUND(3);
                  GOTOXY(47,7);
                  WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
                  TEXTBACKGROUND(8);
                  GOTOXY(43,11);
                  WRITELN(UTF8TOANSI('INGRESE NUEVO TELÉFONO'));
                  GOTOXY(43,12);
                  READLN(X.TEL);
                  END;
                7: BEGIN
                  CLRSCR;
                  TEXTBACKGROUND(3);
                  GOTOXY(47,7);
                  WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
                  TEXTBACKGROUND(8);
                  GOTOXY(43,11);
                  WRITELN('INGRESE NUEVO EMAIL');
                  GOTOXY(43,12);
                  READLN(X.EMAIL);
                  END;

                END;
                GOTOXY(43,14);
                WRITELN(UTF8TOANSI('¿DESEA MODIFICAR OTRO CAMPO? (SI/NO)'));
                GOTOXY(43,15);
                READ(R3);

        UNTIL (R3='NO') OR (R3='No') OR (R3='no') OR (R3='nO');             //AQUI SE TERMINO DE MODIFICAR LOS CAMPOS DE LA PERSONA
        SEEK(ARCH,POS);
        WRITE(ARCH,X);
        CLRSCR;
        TEXTBACKGROUND(3);
        GOTOXY(47,7);
        WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
        TEXTBACKGROUND(8);
        GOTOXY(43,11);
        WRITELN('LOS CAMPOS DE LA PERSONA SE HAN MODIFICADO EXITOSAMENTE.');
        GOTOXY(43,12);
        WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
        GOTOXY(43,13);
        READKEY;
        CLRSCR;
       END
      ELSE     // ENTRA AQUI SI SE ENCONTRO LA PERSONA PERO NO DESEA MODIFICARLE NADA
       BEGIN
          GOTOXY(43,28);
          WRITELN('NO SE MODIFICO NINGUN CAMPO DE LA PERSONA');
          GOTOXY(43,29);
          WRITELN('PRESIONE UNA TECLA PARA CONTINUAR');
          GOTOXY(43,30);
          READKEY;
          CLRSCR;
       END;
    END
    ELSE                                     //SI NO ENCONTRO A LA PERSONA BUSCADA
    BEGIN
     CLRSCR;
     TEXTBACKGROUND(3);
     GOTOXY(47,7);
     WRITELN(UTF8TOANSI('   MODIFICACIÓN DE PERSONA   '));
     TEXTBACKGROUND(8);
     GOTOXY(43,11);
     WRITELN('NO SE HA ENCONTRADO A LA PERSONA.');
     GOTOXY(43,12);
     WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
     GOTOXY(43,14);
     READKEY;
    END;
    CLRSCR;
    CERRAR_P(ARCH);
  END;
 PROCEDURE CONSULTAR_PERSONA(VAR ARCH:T_ARCHIVO_PROP; VAR RAIZDNI:T_PUNT; VAR RAIZNOM:T_PUNT);
VAR
  R:1..2;
  X,OP:STRING;
  ENC,ERROR:BOOLEAN;
  POS,L:BYTE;
  J:T_DATO_PROP;
  AC:BYTE;
  I:INTEGER;
BEGIN
  ABRIR_P(ARCH);
  CLRSCR;
  TEXTBACKGROUND(3);
  GOTOXY(47,7);
  WRITELN('   CONSULTA DE PERSONA   ');
  TEXTBACKGROUND(8);
  GOTOXY(43,11);
  WRITELN('1-CONSULTA POR DNI');
  GOTOXY(43,12);
  WRITELN('2-CONSULTA POR NOMBRE Y APELLIDO');
  AC:=1;
  REPEAT
       IF AC=2 THEN
       BEGIN
          GOTOXY(43,13);
          WRITELN('                                        ');
          GOTOXY(43,14);
          WRITELN('LA OPCION INGRESADA ES INVALIDA, INTENTE NUEVAMENTE.');
       END;
       ERROR:=FALSE;
       GOTOXY(43,13);
       READLN(OP);
       IF NOT(TRYSTRTOINT(OP,I))  THEN
        BEGIN
          GOTOXY(43,13);
          WRITELN('                                        ');
          GOTOXY(43,14);
          WRITELN('LA OPCION INGRESADA ES INVALIDA, INTENTE NUEVAMENTE.');
          ERROR:=TRUE;
        END
       ELSE
        BEGIN
          STRTOINT(OP);
          R:=STRTOINT(OP);
        END;
       AC:=2;
  UNTIL ((R=1) OR (R=2)) AND (ERROR=FALSE);

  IF FILESIZE(ARCH)=0 THEN
    BEGIN
     CLRSCR;
     TEXTBACKGROUND(3);
     GOTOXY(47,7);
     WRITELN('   CONSULTA DE PERSONA   ');
     TEXTBACKGROUND(8);
     GOTOXY(43,11);
     WRITELN('EL ARCHIVO DE PERSONAS ESTA VACIO.');
     GOTOXY(43,12);
     WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
     GOTOXY(43,13);
     READKEY;
     CLRSCR;
    END
  ELSE
  BEGIN
   CLRSCR;
   TEXTBACKGROUND(3);
   GOTOXY(47,7);
   WRITELN('   CONSULTA DE PERSONA   ');
   TEXTBACKGROUND(8);
   GOTOXY(43,11);
   IF R=1 THEN WRITELN('INGRESE DNI DE LA PERSONA A BUSCAR: ')
   ELSE
   BEGIN
      IF R=2 THEN WRITELN('INGRESE APELLIDO Y NOMBRE DE LA PERSONA A BUSCAR: ');
   END;
   GOTOXY(43,12);
   READLN (X);
   ENC:=FALSE;
   IF R=1 THEN
   BEGIN
    BUSCAR_ARCH_DNI_P(ARCH,X,POS,ENC);
   END
   ELSE
   BEGIN
      IF R=2 THEN
      BEGIN
         BUSCAR_ARCH_NOM_P(ARCH,X,POS,ENC);
      END;
   END;
   IF NOT(ENC) THEN
   BEGIN
      GOTOXY(43,15);
      WRITELN ('NO SE HA ENCONTRADO A LA PERSONA');
      GOTOXY(43,16);
      WRITELN('PRESIONE UNA TECLA PARA CONTINUAR');
      GOTOXY(43,17);
      READKEY;
      CLRSCR;
   END
   ELSE
   BEGIN
      CLRSCR;
      SEEK(ARCH,POS);
      READ(ARCH,J);
      TEXTBACKGROUND(3);
      GOTOXY(47,7);
      WRITELN('   CONSULTA DE PERSONA   ');
      TEXTBACKGROUND(8);
      GOTOXY(43,12);
      WRITELN('DATOS DE LA PERSONA BUSCADA:');
      GOTOXY(8,14);
      CAMPOS_PERSONA();
      L:=15;
      MOSTRAR_PERSONA(J,L);
      GOTOXY(43,17);
      WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
      GOTOXY(43,18);
      READKEY;
      CLRSCR;
   END;
  END;
  CERRAR_P(ARCH);
END;

END.
