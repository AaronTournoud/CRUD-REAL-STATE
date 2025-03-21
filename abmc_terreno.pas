UNIT ABMC_TERRENO;

INTERFACE                                                                // UNIT PARA ABMC DE TERRENOS

USES
  CLASSES, SYSUTILS, CRT, ARCHIVO_TERRENO, USA_ARCH_TERRENO, ARCHIVO_PERSONAS, USA_ARCH_PERSONA, ABMC_PERSONAS, ARBOL_PERSONA;

PROCEDURE ALTA_TERRENO(VAR ARCHT:T_ARCHIVO_TERR;VAR ARCHP:T_ARCHIVO_PROP;VAR RAIZDNI:T_PUNT; VAR RAIZNOM:T_PUNT);
PROCEDURE BAJA_TERRENO(VAR ARCHT:T_ARCHIVO_TERR;VAR ARCHP:T_ARCHIVO_PROP);
PROCEDURE CONSULTA_TERRENO(VAR ARCH:T_ARCHIVO_TERR);
PROCEDURE MODIFICAR_TERRENO(VAR ARCH:T_ARCHIVO_TERR);


IMPLEMENTATION

PROCEDURE ALTA_TERRENO(VAR ARCHT:T_ARCHIVO_TERR;VAR ARCHP:T_ARCHIVO_PROP; VAR RAIZDNI:T_PUNT; VAR RAIZNOM:T_PUNT);
VAR
  X:T_DATO_TERR;
  Y:T_DATO_PROP;
  I:INTEGER;
  DNI2,DNI:STRING;
  RES1,RES2,RES3:STRING[2];
  ERROR,ENC:BOOLEAN;
  POS:BYTE;
BEGIN
  CLRSCR;
  ABRIR_T(ARCHT);
  ABRIR_P(ARCHP);
  REPEAT                                        //SE REPITE HASTA QUE SE RESPONDA QUE EL DNI SE INGRESO CORRECTAMENTE
    REPEAT                                      //SE REPITE HASTA QUE SE VERIFIQUE QUE EL DNI SE TYPEO BIEN
       ERROR:=FALSE;
       CLRSCR;
       TEXTBACKGROUND(3);
       GOTOXY(47,7);
       WRITELN('   ALTA DE TERRENO   ');
       TEXTBACKGROUND(8);
       GOTOXY(43,11);
       WRITELN('INGRESE DNI DEL PROPIETARIO/A DEL TERRENO:');
       GOTOXY(86,11);
       READLN(DNI2);
       IF NOT(TRYSTRTOINT(DNI2,I)) THEN
        BEGIN
           GOTOXY(86,11);
           WRITELN('                                        ');
           GOTOXY(43,12);
           WRITELN('EL DNI INGRESADO ES INVALIDO, INTENTE NUEVAMENTE.');
           ERROR:=TRUE;
        END
       ELSE
        BEGIN
        STRTOINT(DNI2);
        DNI:=DNI2;
        END;
    UNTIL  ERROR=FALSE;
    GOTOXY(43,12);
    WRITELN(UTF8TOANSI('¿ES CORRECTO EL DNI INGRESADO?  (SI/NO)                                '));
    GOTOXY(43,13);
    READLN(RES2);
  UNTIL (RES2='SI') OR (RES2='Si') OR (RES2='si')OR (RES2='sI');
  GOTOXY(43,12);
  WRITELN('                                                       ');
  ENC:=FALSE;
  BUSCAR_ARCH_DNI_P(ARCHP,DNI,POS,ENC);
  IF ENC THEN
  BEGIN
     SEEK(ARCHP,POS);
     READ(ARCHP,Y);
     X.NRO_CONTR:=Y.NRO_CONTR;
     CARGAR_TERRENO(X);
     VALORIZAR(X);
     SEEK(ARCHT,FILESIZE(ARCHT));
     IF FILESIZE(ARCHT)>=2 THEN
     BEGIN
        ORDENAR_TERRENO(ARCHT);
     END;
     GOTOXY(43,19);
     WRITELN(UTF8TOANSI('AVALÚO: $'),FLOATTOSTR(X.AVALUO));
     GOTOXY(43,21);
     WRITELN(UTF8TOANSI('¿DESEA DAR DE ALTA EL TERRENO?   (SI/NO)'));
     GOTOXY(43,22);
     READLN(RES3);
     IF (RES3='SI') OR (RES3='si') OR (RES3='Si') OR (RES3='sI')THEN
      BEGIN
        WRITE(ARCHT,X);
        GOTOXY(43,21);
        WRITELN('TERRENO DADO DE ALTA EXITOSAMENTE.                    ');
        GOTOXY(43,22);
        WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.                    ');
        GOTOXY(43,23);
        READKEY;
        CLRSCR;
      END
     ELSE
      BEGIN
        GOTOXY(43,21);
        WRITELN('EL TERRENO NO SE HA DADO DE ALTA.                        ');
        GOTOXY(43,22);
        WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.                    ');
        GOTOXY(43,23);
        READKEY;
        CLRSCR;
      END;
   END
  ELSE
  BEGIN
     GOTOXY(43,12);
     WRITELN('LA PERSONA PROPIETARIA DEL TERRENO NO SE ENCUENTRA REGISTRADA.');
     GOTOXY(43,13);
     WRITELN(UTF8TOANSI('¿DESEA REGISTRARLA?   (SI/NO)'));
     GOTOXY(43,14);
     READLN(RES1);
     IF (RES1='SI') OR (RES1='si') OR (RES1='Si')or (RES3='sI') THEN
     BEGIN
     ALTA_PERSONA(RAIZNOM,RAIZDNI,ARCHP);
     ALTA_TERRENO(ARCHT,ARCHP,RAIZDNI,RAIZNOM);
     END
  END;
END;
PROCEDURE BAJA_TERRENO(VAR ARCHT:T_ARCHIVO_TERR;VAR ARCHP:T_ARCHIVO_PROP);
VAR
    RESP:STRING[2];
    POS,POS1,L:BYTE;
    X,Y:T_DATO_TERR;
    PROP:T_DATO_PROP;
    BUSCADO,BUSCADO1:STRING;
    ENC,ENC1:BOOLEAN;

BEGIN
  CLRSCR;
  ENC:=FALSE;
  ABRIR_T(ARCHT);
  TEXTBACKGROUND(3);
  GOTOXY(47,7);
  WRITELN('   BAJA DE TERRENO   ');
  TEXTBACKGROUND(8);
  GOTOXY(43,11);
  WRITELN('INGRESE EL NUMERO DE PLANO DEL');
  GOTOXY(43,12);
  WRITELN('TERRENO QUE DESEA DAR DE BAJA: ');
  GOTOXY(74,12);
  READLN(BUSCADO);
  WHILE NOT(EOF(ARCHT)) DO
  BEGIN
    READ(ARCHT,X);
    IF (X.NRO_PLANO = BUSCADO) THEN
    BEGIN
      ENC:=TRUE;
      GOTOXY(8,15);
      WRITELN('                                                                             ');
      GOTOXY(43,19);
      WRITELN('                                                                             ');
      GOTOXY(43,20);
      WRITELN('                                                                             ');
      GOTOXY(43,21);
      WRITELN('                                                                             ');
      GOTOXY(8,14);
      CAMPOS_T();
      L:=15;
      MOSTRAR_DATOS(X,L);
      GOTOXY(43,18);
      WRITELN(UTF8TOANSI('¿DESEA ELIMINAR ESTE TERRENO? (SI/NO)'));
      GOTOXY(43,19);
      READLN(RESP);
      IF (RESP='SI') OR (RESP='Si') OR (RESP='si') OR (RESP='sI')THEN
      BEGIN
        POS:=FILEPOS(ARCHT)-1;
        ELIMINAR_TERRENO(ARCHT,POS);
        SEEK(ARCHT,0);
        ENC1:=FALSE;
        WHILE NOT(EOF(ARCHT)) DO
        BEGIN
           READ(ARCHT,Y);
           IF X.NRO_CONTR=Y.NRO_CONTR THEN       //POR SI LA MISMA PERSONA TIENE OTRO TERRENO
           BEGIN
             ENC1:=TRUE;
           END;
        END;
        IF NOT(ENC1) THEN
        BEGIN
             BUSCADO1:=X.NRO_CONTR;
             ABRIR_P(ARCHP);
             ENC1:=FALSE;
             BUSCAR_ARCH_P(ARCHP,BUSCADO1,POS1,ENC1);
             IF ENC1 THEN
             BEGIN
               SEEK(ARCHP,POS1);
               READ(ARCHP,PROP);
               PROP.ESTADO:=FALSE;
               SEEK(ARCHP,POS1);
               WRITE(ARCHP,PROP);
               GOTOXY(43,20);
               WRITELN('LA PERSONA PROPIETARIA DEL TERRENO HA SIDO DADA DE BAJA,');
               GOTOXY(43,21);
               WRITELN(UTF8TOANSI('POR SER EL TERRENO QUE SE HA ELIMINADO EL ÚNICO EN SU POSESIÓN.'));
             END;
        END;
        GOTOXY(43,22);
        WRITELN('EL TERRENO SE DIO DE BAJA EXITOSAMENTE.');
        GOTOXY(43,23);
        WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
        GOTOXY(43,24);
        READKEY;
      END
      ELSE
      BEGIN
        GOTOXY(43,20);
        WRITELN('EL TERRENO NO SE HA DADO DE BAJA.');
        GOTOXY(43,21);
        WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
        GOTOXY(43,22);
        READKEY;
      END;
    END
  END;
  IF NOT(ENC) THEN
  BEGIN
    GOTOXY(43,15);
    WRITELN('TERRENO NO ENCONTRADO.');
    GOTOXY(43,17);
    WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
    GOTOXY(43,18);
    READKEY;
  END;
  CERRAR_T(ARCHT);
  CLRSCR;
END;
 PROCEDURE MODIFICAR_TERRENO(VAR ARCH:T_ARCHIVO_TERR);
 VAR
     I:INTEGER;
     POS,L,AC:BYTE;
     X:T_DATO_TERR;
     BUSCADO,OP:STRING;
     RESP,RESP3:STRING[2];
     RESP2:1..10;
     ENC,ERROR:BOOLEAN;
 BEGIN
       CLRSCR;
       ABRIR_T(ARCH);
       TEXTBACKGROUND(3);
       GOTOXY(47,7);
       WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
       TEXTBACKGROUND(8);
       GOTOXY(43,11);
       WRITELN('INGRESE EL NUMERO DE PLANO');
       GOTOXY(43,12);
       WRITELN('DEL TERRENO QUE DESEA MODIFICAR: ');
       GOTOXY(43,13);
       READLN(BUSCADO);
       ENC:=FALSE;
       BUSCAR_TERRENO(ARCH,BUSCADO,POS,ENC);
       IF ENC THEN
       BEGIN
             SEEK(ARCH,POS);
             READ(ARCH,X);
             GOTOXY(8,15);
             CAMPOS_T();
             L:=16;
             MOSTRAR_DATOS(X,L);
             GOTOXY(43,18);
             WRITELN(UTF8TOANSI('¿DESEA MODIFICAR ESTE REGISTRO DE TERRENO? (SI/NO)'));
             GOTOXY(43,19);
             READLN(RESP);
             IF (RESP='SI') OR (RESP='Si') OR (RESP='si') OR (RESP='sI')THEN
             BEGIN
             REPEAT
               CLRSCR;
               TEXTBACKGROUND(3);
               GOTOXY(47,7);
               WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
               TEXTBACKGROUND(8);
               GOTOXY(43,11);
               WRITELN('INGRESE EL CAMPO QUE DESEE MODIFICAR: ');
               GOTOXY(43,12);
               WRITELN('1-NUMERO DE CONTRIBUYENTE');
               GOTOXY(43,13);
               WRITELN('2-NUMERO DE PLANO');
               GOTOXY(43,14);
               WRITELN(UTF8TOANSI('3-FECHA DE INSCRIPCIÓN'));
               GOTOXY(43,15);
               WRITELN('4-DOMICILIO PARCELARIO');
               GOTOXY(43,16);
               WRITELN('5-SUPERFICIE');
               GOTOXY(43,17);
               WRITELN('6-ZONA');
               GOTOXY(43,18);
               WRITELN(UTF8TOANSI('7-EDIFICACIÓN'));

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
               IF NOT (TRYSTRTOINT(OP,I)) THEN
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
               RESP2:=STRTOINT(OP);
               END;
               AC:=2;
              UNTIL ((RESP2=1) OR (RESP2=2) OR (RESP2=3) OR (RESP2=4) OR (RESP2=5) OR (RESP2=6) OR (RESP2=7)) AND (ERROR=FALSE);
               CLRSCR;
               CASE RESP2 OF
                  1:BEGIN
                         CLRSCR;
                         TEXTBACKGROUND(3);
                         GOTOXY(47,7);
                         WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
                         TEXTBACKGROUND(8);
                         GOTOXY(43,11);
                         WRITELN('INGRESE NUEVO NUMERO DE CONTRIBUYENTE:');
                         GOTOXY(43,12);
                         READLN(X.NRO_CONTR);

                  END;
                  2:BEGIN
                         CLRSCR;
                         TEXTBACKGROUND(3);
                         GOTOXY(47,7);
                         WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
                         TEXTBACKGROUND(8);
                         GOTOXY(43,11);
                         WRITELN('INGRESE NUEVO NUMERO DE PLANO:');
                         GOTOXY(43,12);
                         READLN(X.NRO_PLANO);
                  END;
                  3:BEGIN
                         CLRSCR;
                         TEXTBACKGROUND(3);
                         GOTOXY(47,7);
                         WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
                         TEXTBACKGROUND(8);
                         GOTOXY(43,11);
                         WRITELN(UTF8TOANSI('INGRESE NUEVA FECHA DE INSCRIPCIÓN:'));
                         GOTOXY(43,12);
                         READLN(X.FECHA_INSC);
                  END;
                  4:BEGIN
                         CLRSCR;
                         TEXTBACKGROUND(3);
                         GOTOXY(47,7);
                         WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
                         TEXTBACKGROUND(8);
                         GOTOXY(43,11);
                         WRITELN('INGRESE NUEVO DOMICILIO PARCELARIO :');
                         GOTOXY(43,12);
                         READLN(X.DOM_PARC);
                  END;
                  5:BEGIN
                         CLRSCR;
                         TEXTBACKGROUND(3);
                         GOTOXY(47,7);
                         WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
                         TEXTBACKGROUND(8);
                         GOTOXY(43,11);
                         WRITELN('INGRESE NUEVO SUPERFICIE:');
                         GOTOXY(43,12);
                         READLN(X.SUP);
                  END;
                  6:BEGIN
                         CLRSCR;
                         TEXTBACKGROUND(3);
                         GOTOXY(47,7);
                         WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
                         TEXTBACKGROUND(8);
                         GOTOXY(43,11);
                         WRITELN('INGRESE NUEVA ZONA:');
                         GOTOXY(43,12);
                         READLN(X.ZONA);
                  END;
                  7:BEGIN
                         CLRSCR;
                         TEXTBACKGROUND(3);
                         GOTOXY(47,7);
                         WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
                         TEXTBACKGROUND(8);
                         GOTOXY(43,11);
                         WRITELN(UTF8TOANSI('INGRESE NUEVO NUMERO DE EDIFICACIÓN:'));
                         GOTOXY(43,12);
                         READLN(X.EDIF);
                  END;
               END;
               VALORIZAR(X);
               SEEK(ARCH,POS);
               WRITE(ARCH,X);
               GOTOXY(43,14);
               WRITELN(UTF8TOANSI('¿DESEA MODIFICAR OTRO CAMPO DE ESTE REGISTRO DE TERRENO? (SI/NO)'));
               GOTOXY(43,15);
               READLN(RESP3);
               UNTIL (RESP3='NO') OR (RESP3='No') OR (RESP3='no') OR (RESP3='nO');
               CLRSCR;
               TEXTBACKGROUND(3);
               GOTOXY(47,7);
               WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
               TEXTBACKGROUND(8);
               GOTOXY(43,11);
               WRITELN('LOS CAMPOS DEL TERRENO SE HAN MODIFICADO EXITOSAMENTE.');
               GOTOXY(43,12);
               WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
               GOTOXY(43,13);
               READKEY;
               END
               ELSE    //SI LA RESPUESTA A MODIFICAR ALGUN CAMPO FUE NEGATIVA
               BEGIN
               CLRSCR;
               TEXTBACKGROUND(3);
               GOTOXY(47,7);
               WRITELN(UTF8TOANSI('   MODIFICACIÓN DE TERRENO   '));
               TEXTBACKGROUND(8);
               GOTOXY(43,11);
               WRITELN('NO SE HA MODIFICADO NINGUN CAMPO DEL TERRENO.');
               GOTOXY(43,12);
               WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
               GOTOXY(43,13);
               READKEY;
               END;
       END
       ELSE          //SI NO SE ENCONTRO EL TERRENO
       BEGIN
         GOTOXY(43,15);
         WRITELN('NO SE HA ENCONTRADO EL TERRENO.');
         GOTOXY(43,16);
         WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
         GOTOXY(43,17);
         READKEY;
       END;
       CERRAR_T(ARCH);
       CLRSCR;
 END;

 PROCEDURE CONSULTA_TERRENO(VAR ARCH:T_ARCHIVO_TERR);
 VAR
     X:T_DATO_TERR;
     BUSCADO:STRING;
     POS,L:BYTE;
     ENC:BOOLEAN;
 BEGIN
   CLRSCR;
   ABRIR_T(ARCH);
   GOTOXY(47,7);
   TEXTBACKGROUND(3);
   WRITELN('   CONSULTA DE TERRENO   ');
   TEXTBACKGROUND(8);
   GOTOXY(43,11);
   WRITELN('INGRESE EL NUMERO DE PLANO DEL');
   GOTOXY(43,12);
   WRITELN('TERRENO QUE DESEA CONSULTAR: ');
   GOTOXY(43,13);
   READLN(BUSCADO);
   ENC:=FALSE;
   BUSCAR_TERRENO(ARCH,BUSCADO,POS,ENC);
   IF ENC THEN
   BEGIN
         SEEK(ARCH,POS);
         READ(ARCH,X);
         GOTOXY(8,15);
         CAMPOS_T();
         L:=16;
         MOSTRAR_DATOS(X,L);
         GOTOXY(43,18);
         WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
         GOTOXY(43,19);
         READKEY;
   END
   ELSE
   BEGIN
     GOTOXY(43,15);
     WRITELN('NO SE HA ENCONTRADO EL TERRENO.');
     GOTOXY(43,17);
     WRITELN('PRESIONE UNA TECLA PARA CONTINUAR.');
     GOTOXY(43,18);
     READKEY;
   END;
   CERRAR_T(ARCH);
   CLRSCR;
 END;

 END.



