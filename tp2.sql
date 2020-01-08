
-- Script fait par 
	-- KOUACHI Abdeljalil
	-- MEMOUCHE Kahina
	-- PLATINI Michael

--les reponses suivent lordre des réponse etablis dans le rapport apartir du point 2 Contraites


/* 2. Les Contraintes

2.1. la modification des tables afin d’ajouter les contraintes
suivantes en SQL */

/*	2.1.1. La note d'un étudiant doit être comprise entre 0 et 20.	*/

alter table RESULTATS add constraint ck_note check (POINTS between 0 and 20);

/* 2.1.2. Le sexe d'un étudiant doit être dans la liste : 'm', 'M', 'f', 'F'
ou Null.  */ 

alter table ELEVES add constraint ck_sexe check (SEXE IN ('M', 'm', 'F', 'f')); 

/* 2.1.3. Contrainte horizontale : Le salaire de base d’un professeur
doit être inférieur au salaire actuel.   */

alter table PROFESSEURS add constraint ck_salaire check (SALAIRE_BASE < SALAIRE_ACTUEL);

Insert into PROFESSEURS (Num_prof, nom, specialite, Date_entree, Der_prom, Salaire_base, Salaire_actuel)
Values(4, 'Pastecnov','sql','01-10-1975','',2500000,2500000);

Insert into PROFESSEURS (Num_prof, nom, specialite, Date_entree, Der_prom, Salaire_base, Salaire_actuel)
Values(5, 'Selector','sql','15-10-1982','01-10-1988',1900000,1900000);


/* 2.1.4. Contrainte verticale : Le salaire d'un professeur ne doit pas
dépasser le double de la moyenne des salaires des enseignants
de la même spécialité.  */

CREATE OR REPLACE TRIGGER profSALARY
before insert on professeurs
for each row
declare
 moyenne number;
begin
   select AVG(SALAIRE_ACTUEL) into moyenne from professeurs where SPECIALITE = :new.SPECIALITE;

   if(:new.SALAIRE_ACTUEL > moyenne) then
       raise_application_error(-20066,'Le salaire d un professeur ne doit pas dépasser le double de la moyenne des salires des enseignants de la meme spécialité');
   end if;
end;
/

select avg(SALAIRE_ACTUEL) from professeurs where specialite = 'sql';

INsert into PROFESSEURS (Num_prof,nom , specialite, Date_entree, Der_prenom, Salaire_base, Salaire_actuel )
values(1, 'Vilplusplus','sql','25-04-1990','05-06-1994',1900000, 2400000);



/************ 3. Les Triggers  ****************/

/********    3.1.
la création d’un trigger permettant de vérifier la contrainte : « Le salaire d'un Professeur ne peut pas diminuer ».  ****/

create or replace Trigger salaireUPDATE 
before update on PROFESSEURS
For each row
	BEGIN
		if (:old.SALAIRE_ACTUEL > : new.SALAIRE_ACTUEL) then
			raise_application_eoor(-20014,'ERROT: Le salaire d un professeur ne peut pas diminuer');
		end if;
	END;
/

/*  Teste */
update professeurs set SALAIRE_ACTUEL = SALAIRE_ACTUEL - 1 whare NUM_PROF=1;

/******     3.2. Gestion automatique de la redondance   *******/

/* 3.2.1. Créez la table PROF_SPECIALITE : */

CREATE TABLE PROF_SPECIALITE ( SPECIALITE VARCHAR2 (20), NB_PROFESSEURS NUMBER );

/*  3.2.2. Créez un trigger permettant de remplir et mettre à jour
automatiquement, cette table suite à chaque opération de MAJ
(insertion, suppression, modification) sur la table des
professeurs. */
 
/*****    //Trigger pour remplir prof_specialite   ******/

CREATE OR REPLACE PROCEDURE remplir_PROF_SPECIALITE
AS
NB_PROF INTEGER ;
cursor cr is select distinct(SPECIALITE) ,  count(NUM_PROF) as NB_PROF
		from PROFESSEURS
		group by (SPECIALITE);

c_rec cr%rowtype;
BEGIN 
	for c_rec in cr loop
		INSERT INTO PROF_SPECIALITE VALUES(c_rec.SPECIALITE, c_rec.NB_PROF);
	exit when cr%notfound;
	end loop;
END;
/

/* Executer le trigger */
execute remplir_PROF_SPECIALITE();

/* Affihcer la table Prof_specialité */
select * from prof_specialite;



/***** Trigger pour mettre à jour automatiquement la table prof_specialite   ******/



create or replace Trigger TRAITEMENT_PROF_SPECIALITE
	AFTER INSERT or UPDATE or DELETE on PROFESSEURS
	For each row
	declare 
	nbr number;
	begin
		if inserting then
			begin 
			    select PROF_SPECIALITE.NB_PROFESSEURS into nbr from PROF_SPECIALITE
			    where PROF_SPECIALITE.SPECIALITE = :new.SPECIALITE;

			    EXCEPTION
			    WHEN No_Data_Found THEN
			        INSERT INTO PROF_SPECIALITE VALUES (:new.SPECIALITE,0);
			end;

			update PROF_SPECIALITE set NB_PROFESSEURS = NB_PROFESSEURS + 1 
			where PROF_SPECIALITE.SPECIALITE = :new.SPECIALITE;
		end if;

		if deleting then
			update PROF_SPECIALITE set NB_PROFESSEURS = NB_PROFESSEURS - 1
			where PROF_SPECIALITE.SPECIALITE = :new.SPECIALITE;
		end if;

		if updating then
			update PROF_SPECIALITE set NB_PROFESSEURS = NB_PROFESSEURS - 1
			where PROF_SPECIALITE.SPECIALITE = :old.SPECIALITE;
			begin 
		    	select PROF_SPECIALITE.NB_PROFESSEURS into nbr from PROF_SPECIALITE
			    where PROF_SPECIALITE.SPECIALITE = :new.SPECIALITE;

                EXCEPTION
                    WHEN No_Data_Found THEN
                    INSERT INTO PROF_SPECIALITE VALUES (:new.SPECIALITE,0);
                end;
                
                update PROF_SPECIALITE set NB_PROFESSEURS = NB_PROFESSEURS + 1 
                where PROF_SPECIALITE.SPECIALITE = :new.SPECIALITE;
		END IF;
	END;
	/


/******       TestER de ce dernier trigger :     ******/


insert into PROFESSEURS (Num_prof, nom, specialite, Date_entree, Der_prom, Salaire_base, Salaire_actuel)
Values(23,'Pucette','aa','06-12-1988','29-02-1996', 2000, 20000);

update professeurs set specialite = 'sql' where num_prof = 23;

delete from professeurs where num_prof = 23;

/*****    3.3. Mise à jour en cascade :          *******/
/* un trigger qui met à jour la table CHARGE lorsqu’on supprime un professeur
dans la table PROFESSEUR ou que l’on change son numéro*/

create or replace trigger updateChargeProf
after delete or update on PROFESSEURS
for each row
begin
	if deleting then
	delete from charge where num_prof = :old.num_prof;
	end if;
	if updating then
	update charge set num_prof = :new num_prof where num_prof = :old.num_prof;
	end if;
end;
/

/*****        Test de ce trigger               **********/

select c.num_prof, p.num as professeur, c.num_cours, cr.nom as cours from charge c, professeurs p, cours cr
where c.num_prof = p.num_prof and c.num_cours = cr.num_cours;

/*******      tester la suppression d’un professeur          *******/
select c.num_prof, p.nom as professeurs, c.num_cours, cr.nom as cours from charge c, professeurs p, cours cr
where c.num_prof = p.num_prof and c.num_cours = cr.num_cours;


/*****       3.4. Sécurité : enregistrement des accès             *********/


/*****      3.4.1. Créez la table audit_resultats             *******/


CREATE TABLE AUDIT_RESULTATS (
	UTILISATEUR VARCHAR2(50),
	DATE_MAJ date,
	DESC_MAJ VARCHAR2(20),
	NUM_ELEVE NUMBER (4) NOT NULL,
	NUM_COURS NUMBER (4) NOT NULL,
	POINTS NUMBER
);

/******      3.4.2. Créez un trigger qui met à jours la table ​ audit_resultats  *****/

create or replace trigger updateAUDIT_RESULTATS
after insert or update or delete on resultats
for each row
begin
	if inserting then
		INSERT INTO audit_resultats VALUES(USER ,SYSDATE, 'INSERT',:NEW.NUM_ELEVE, :NEW.NUM_COURS, :NEW.POINTS);
	enf if;

	if deleting then
		INSERT INTO audit_resultats VALUES(USER ,SYSDATE, 'DELETE',:OLD.NUM_ELEVE, :OLD.NUM_COURS, :OLD.POINTS);
	end if;

	if updating then
		INSERT INTO audit_resultats VALUES(USER ,SYSDATE, 'ANCIEN',:OLD.NUM_ELEVE, :OLD.NUM_COURS, :OLD.POINTS);
		INSERT INTO audit_resultats VALUES(USER ,SYSDATE, 'NOUVEAU',:NEW.NUM_ELEVE, :NEW.NUM_COURS, :NEW.POINTS);
	end if;
end;
/

/*****      Teste de ce trigger                ******/

Insert into eleves(num_eleve, nom, prenom, date_naissance, poids, annee, sexe)
Values (70,'MACHOUCHE','Kahina','08-04-1995', 60, 4,'F');

Insert into cours(Num_cours, Nom,Nbheures, annee)
Values(6, 'Data Mining', 50, 4);

Insert into RESULTATS (Num_eleve, Num_cours, points)
Values(70,6,18);



UPDATE RESULTATS SET POINTS = 18.5 WHERE NUM_ELEVE = 70;
select * from audit_resultats;

delete from resultats where num_eleve = 70;
select * frm audit_resultats;


/********           3.5. Confidentialité             *********/

create or replace trigger checkUSER
before update on PROFESSEURS
for each row
begin
	if(:OLD.SALAIRE_ACTUEL*(20/100) + :OLD.SALAIRE_ACTUEL < :OLD.SALAIRE_ACTUEL) then 
        if(USER != 'GrandChe') then
        	raise_application_error(-20002,'Modification interdite');
        end if;
	end if;
end;
/

/********             Test de ce trigger           ********/

Insert into professeurs (Num_prof, nom, specialite, Date_entree, Der_pron, Salaire_base, Salaire_actuel)
Values(58,'Fabien Laurent','Data Mining', '30-10-1980', '15-04-1998', 20000,25000)
update professeurs set SALAIRE_ACTUEL = SALAIRE_ACTUEL*(20/100)+ SALAIRE_ACTUEL+1 where num_prof = 58;

/********           Linge de mise a jour :          *******/

update professeurs
set SALAIRE_ACTUEL = SALAIRE_ACTUEL*(20/100)+ SALAIRE_ACTUEL-1 where num_prof = 99;


/*****           4. Fonctions et procédures           ********/

/*******        4.1. Créer une fonction fn_moyenne calculant la moyenne d’un étudiant passé en paramètre.    ******/

CREATE OR REPLACE FUNCTION fn_moyenne(numEleve eleves.num_eleve%type) return Number
is
cursor cr is select r.num_eleve, r.points from resultats r where numEleve = r.num_eleve;
    c_rec cr%rowtype;
        cpt number := 0;
        moyenne Number :=0;
	BEGIN
		for c_rec in cr loop
			moyenne := moyenne + c_rec.points;
			cpt := cpt +1;
		 exit when cr%notfound;
		end loop;
		    return (moyenne/cpt);
	END;
/


/*********            procedure studentAVERAGE            ***********/

Create or replace procedure studentAVERAGE( numEleve eleves.NUM_ELEVE%type ) as
    moyenne number;
    numero number;
    name eleves.NOM%type;
BEGIN
	SELECT distinct r.NUM_ELEVE into numero from resultats r where r.NUM_ELEVE = numEleve;
	   moyenne := fn_moyenne(numEleve);
		SELECT nom into name from ELEVES where NUM_ELEVE = numEleve;
		    dbms_output.put_line('la moyenne de '||name||' est :'||moyenne||' ');
		EXCEPTION
		 WHEN NO_DATA_FOUND then
		 BEGIN
		    RAISE_APPLICATION_ERROR(-20098,'no data about this student ID, please check if you are using the right ID');
		END;
END;
/
 
/******        4.2. Créez une procédure pr_resultat permettant d’afficher la moyenne de chaque élève avec la mention adéquate *******/

create or replace procedure displayAVERAGE 
    as
    cursor cr is select distinct r.num_eleve from resultats r;
    c_rec cr%rowtype;
    moyenne number;
    name eleves.nom%type;
    mention VARCHAR2(20);
	BEGIN
		for c_rec in cr loop
            moyenne := fn_moyenne(c_rec.num_eleve);
            select nom into name from ELEVES where num_eleve = c_rec.num_eleve;
                        if(moyenne < 10) THEN
                            mention := 'echec';
                        end if;
                        if(moyenne >= 10 and moyenne <= 10.5) then
                            mention := 'passable';
                        end if;
                        if(moyenne > 10.5 and moyenne < 13.8) THEN
                            mention := 'assez bien';
                        end if;
                        if(moyenne >= 13.8 and moyenne < 15) THEN
                            mention := 'bien';
                        end if;
                        if(moyenne >= 15) THEN
                            mention := 'très bien';
                        end if;

		    dbms_output.put_line('la moyenne de '||name||' est : '||moyenne||' avec une mention : '||mention||' ');
		        exit  when cr%notfound;
		end loop;
	END;
/


/*********  4.3. Créez un package contenant ces fonction et procédures  ********/

create or replace package  kadriPG is
	procedure studentAVERAGE(numEleve eleves.num_eleve%type);
	procedure displayAVERAGE;
END kadriPG;
/


/***** Implémentation des procedures et fonctions déclarer dans le package précédente :  ******/

create or replace package body kadriPG is
            procedure studentAVERAGE( numEleve eleves.NUM_ELEVE%type ) as
                moyenne number;
                numero number;
                name eleves.NOM%type;
            BEGIN
                SELECT distinct r.NUM_ELEVE into numero from resultats r where r.NUM_ELEVE = numEleve;
                   moyenne := fn_moyenne(numEleve);
                    SELECT nom into name from ELEVES where NUM_ELEVE = numEleve;
                        dbms_output.put_line('la moyenne de '||name||' est :'||moyenne||' ');
                    EXCEPTION
                     WHEN NO_DATA_FOUND then
                     BEGIN
                        RAISE_APPLICATION_ERROR(-20098,'no data about this student ID, please check if you are using the right ID');
                    END;
            END;

            procedure displayAVERAGE as
            cursor cr is select distinct r.num_eleve from resultats r;
            c_rec cr%rowtype;
            moyenne number;
            name eleves.nom%type;
            mention VARCHAR2(20);
            BEGIN
                for c_rec in cr loop
                    moyenne := fn_moyenne(c_rec.num_eleve);
                    select nom into name from ELEVES where num_eleve = c_rec.num_eleve;
                                if(moyenne < 10) THEN
                                    mention := 'echec';
                                end if;
                                if(moyenne >= 10 and moyenne <= 10.5) then
                                    mention := 'passable';
                                end if;
                                if(moyenne > 10.5 and moyenne < 13.8) THEN
                                    mention := 'assez bien';
                                end if;
                                if(moyenne >= 13.8 and moyenne < 15) THEN
                                    mention := 'bien';
                                end if;
                                if(moyenne >= 15) THEN
                                    mention := 'très bien';
                                end if;

                    dbms_output.put_line('la moyenne de '||name||' est : '||moyenne||' avec une mention : '||mention||' ');
                        exit  when cr%notfound;
                end loop;
            END;
END kadriPG;
/




