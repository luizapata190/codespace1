**Free
      //------------------------------------------------------------------------
      // PROGRAMA.: VTSPGZCID
      // AUTOR....: César Augusto González Loaiza
      // FECHA....: 2021-11-18
      // DESCRIP..: Retorna campaña actual, con base a la compáñia y la zona
      //
      //   - Se crea módulo
      //        CRTSQLRPGI OBJ(VOTREP00/VTSPGZCID) SRCFILE(VOTREP00/QRPGLESRC)
      //                 COMMIT(*NONE) OBJTYPE(*MODULE)
      //                 CLOSQLCSR(*ENDACTGRP) REPLACE(*YES)
      //                 DBGVIEW(*SOURCE)
      //
      //   - Se crea programa
      //          CRTPGM PGM(VOTREP00/VTSPGZCID)
      //                 MODULE(VOTREP00/VTSPGZCID)
      //                 TEXT('Retorna campaña actual')
      //                 ENTMOD(VOTREP00/VTSPGZCID) ACTGRP(SPGZCID)
      //------------------------------------------------------------------------
      CTL-opt OPTIon(*NODEBUGIO);
      CTL-OPT DATEDIT(*YMD);

      DCL-S Wsql Char(600) Inz(' ');
      DCL-S Wcom Char(1) Inz('''');
      DCL-S WLib Char(20) Inz('''');

      //Definiciòn de Prototipos de Trabajo
      DCL-PR MAIN EXTPGM('Main');
        pcia Char(10);
        pZon  Char(3);
        pCamp Char(4);
      END-PR;

      DCL-PI MAIN;
        pcia Char(10);
        pZon  Char(3);
        pCamp Char(4);
      END-PI;

      //-------------------
      //PROGRAMA PRINCIPAL
      //-------------------
      //pruebas bugfix

        Clear pCamp;
        Clear Wsql;
        Clear WLib;


        WLib = 'OPF'+%Trim(pcia)+'/PMTCMP';

        Wsql =
          'WITH ' +
          'REG_OPICTL AS ( ' +
            'Select IFNULL(Max(CAMCTL), 0) AS CAMPANA1 ' +
            'From VOTREA00/OPICTLF0 ' +
            'Where CIACTL = '+Wcom+%Trim(pcia)+Wcom+' And ' +
                  'ZONCTL = '+Wcom+%Trim(pZon)+Wcom+'), ' +
          'REG_OPIEST AS( ' +
            'Select IFNULL(Max(ESTCAM), 0) AS CAMPANA2 ' +
            'From ORDERP00/OPIESTF1 ' +
            'Where ESTCIA = '+Wcom+%Trim(pcia)+Wcom+' And ' +
                  'ESTZON = '+Wcom+%Trim(pZon)+Wcom+'), ' +
          'REG_PMTCMT AS( ' +
            'Select IFNULL(Max(Gcmeda), 0) AS CAMPANA3 From ' +
                    %Trim(WLib)+') ' +
          'Select CASE ' +
            'When CAMPANA1 <> 0 Then CAMPANA1 ' +
            'When CAMPANA2 <> 0 Then CAMPANA2 ' +
            'When CAMPANA3 <> 0 Then CAMPANA3 ' +
            'Else 0 ' +
            'END AS CAMPANA ' +
          'From REG_OPICTL,REG_OPIEST,REG_PMTCMT';

        Exec Sql PREPARE S1 FROM :Wsql;
        Exec Sql DECLARE RegistroSQL1 CURSOR FOR S1;
        Exec Sql OPEN RegistroSQL1;
        Exec Sql FETCH FROM RegistroSQL1 INTO :pCamp;
        Exec Sql CLOSE RegistroSQL1;

        *InLr = *ON;