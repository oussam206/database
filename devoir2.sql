***************DEVOIR N°02 BASE DE DONNEES AVANCEE********************


------> BINOME G3 :
	   MAHRAZ AYYOUB
	   RAFIK OUSSAMA
	
C7) Compléter le script suivant qui permet de modifiant le salaire d’un pilote avec les contraintes
suivantes :
   **)Si la commission est supérieure au salaire alors on rajoute au salaire la valeur de la
	commission et la commission sera mise à la valeur nulle:
	     DECLARE
		CURSOR C_pilote IS
 		SELECT nom, sal, comm
		FROM pilote
		WHERE nopilot BETWEEN 1280 AND 1999 FOR UPDATE;
 		v_nom pilote.nom%type;
 		v_sal pilote.sal%type;
 		v_comm pilote.comm%type;
	      BEGIN

			OPEN C_pilote;
		   loop 
			fetch cp into v_nom,v_sal,v_comm;
			exit when C_pilote%notfound;
			if v_comm is null then 
				DELETE PILOTE WHERE CURRENT OF C_pilote;
			elsif v_comm > v_sal then 
				update pilote set sal = comm + sal where current of C_pilote ;
				
			end if;
		   end loop;
		      close C_pilote;
		END;

   **)- Si la valeur de la commission est nulle alors supprimer le pilote du curseur.

	     DECLARE
		CURSOR C_pilote IS
 		SELECT nom, sal, comm
		FROM pilote
		WHERE nopilot BETWEEN 1280 AND 1999 FOR UPDATE;
 		v_nom pilote.nom%type;
 		v_sal pilote.sal%type;
 		v_comm pilote.comm%type;
	      BEGIN
		open C_pilote;
		loop
			FETCH C_pilote INTO v_sal, v_comm;
			IF C_pilote%NOTFOUND then
				exit;
			END IF;
			IF v_comm > v_sal then
				update pilote
					set sal = sal + v_comm;
						comm = NULL
					WHERE current of C_pilote;
			END IF;
			IF v_comm is NULL then
					DELETE
					FROM pilote
					WHERE current of C_pilote;
			END IF;
		end loop;
	END;

C8) Écrire une procédure PL/SQL qui réalise l’accès à la table PILOTE par l’attribut nopilote.Si le
    numéro de pilote existe, elle envoie dans la table ERREUR, le message « NOM PILOTE-OK »
    sinon le message « PILOTE INCONNU ». De plus si sal<comm, elle envoie dans la table
    ERREUR le message « « NOM PILOTE, COMM >SAL ».

	CREATE TABLE ERREUR (M varchar2(60));
	
	CREATE OR REPLACE PROCEDURE acces_pilote(nopil pilote.nopilot%type )
	IS
		v_nopil      pilote.nopilot%type ;
		v_exception  exception ;
		v_data       pilote%rowtype;
	BEGIN
		SELECT count (*) into v_nopil FROM pilote WHERE nopilot=nopil ;
		IF v_nopil=0 then 
			raise v_exception ;
		ELSE
			SELECT * INTO v_data FROM pilote WHERE nopilot = nopil;
			IF(v_data.comm > v_data.sal ) then
				INSERT INTO ERREUR values ( v_data.nom ||',COMM > sal ');
			ELSE
				INSERT INTO ERREUR values ( v_data.nom ||' -OK') ;
			END IF;
		END IF;

	EXCEPTION
		when v_exception then 
		INSERT INTO ERREUR values ('PILOTE INCONU') ;
	END;


-*-*->D-CREATION DES VUES :

 D1)Créer une vue (v-pilote) constituant une restriction de la table pilote, aux pilote qui habitent
    Paris.

	CREATE VIEW v_pilote 
		as SELECT * FROM pilote WHERE ville = 'PARIS';

 D2)Vérifier est ce qu’il est possible de modifier les salaires des pilotes habitant Paris à travers la vue
    v-pilote.
	
	ALTER VIEW v_pilote SET salaire = 1,1 * salaire;
	//C'est pas possible de modifier les salaires des piote a travers la vue.

 D3)Créer une vue (dervol) qui donne la date du dernier vol réalisé par chaque avion

	CREATE VIEW dervol as SELECT avion,max(date_vol) as Max_time FROM Affectation group by avion;


 D4)Une vue peut être utilisée pour contrôler l’intégrité des données grâce à la clause ‘CHECK
  OPTION’.
  Créer une vue (cr_pilote) qui permette de vérifier lors de la modification ou de l’insertion d’un
  pilote dans la table PILOTE les critères suivants :
  - Un pilote habitant Paris a toujours une commission
  - Un pilote qui n’habite pas Paris n’a jamais de valeur de commission.

	 CREATE VIEW cr_pilote as 
   	 SELECT * FROM pilote WHERE 
   	 (comm is not null and ville = 'PARIS') 
   	 OR
    	 (ville not in 'PARIS' and comm is null)with CHECK OPTION;

 D5) Créer une vue (nomcomm) qui permette de valider, en saisie et mise à jour, le montant
     commission d’un pilote selon les critères suivant :
     - Un pilote qui n’est affecté à au moins un vol, ne peut pas avoir de commission
     - Un pilote qui est affecté à au moins un vol peut recevoir une commission.
       Vérifier les résultats par des mises à jour sur la vue nomcomm.

	CREATE nomcomm as 
        SELECT * FROM pilote WHERE 
    	(nopilot in (SELECT pilote FROM Affectation WHERE comm is NOT NULL)) 
    	or 
    	(nopilot NOT in (SELECT pilote FROM affectation WHERE comm is NULL ))with CHECK OPTION;
 
