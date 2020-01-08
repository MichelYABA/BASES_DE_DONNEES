/*I. création de types et de tables 

I.1. Créez un type adresse_type avec un numéro de rue, un nom de rue
et un nom de ville*/

create or replace type adresse_type as object (
num_rue Number,
nom_rue varchar2(40),
nom_ville varchar2(40)
)
/
/*I.2. Créez un type personne_type avec un nom et un prénom*/

create or replace type personne_type as object(
nom varchar2(30)
prenom varchar2(30)
)
/
/*I.3. Créez les types activites_type et cours_type
I.3.1. activites_type*/
create or replace type activites_type as object (
niveau number(1),
nom varchar2(20),
equipe varchar2(20)
)
/
/*I.3.2. cours_type*/
create or replace type cours_type as object (
num_cours Number(2),
nom varchar2(20),
nbheures number(2),
annees number(2)
)
/

/*I.4. Créez les tables personnes, activites et cours associées à ces 3
types (personne_type, activites_type et cours_type)
I.4.1. table personnes */

create table personnes of personne_type(
constraint PK_personne primary key (nom,prenom)
);

/*I.4.2. table activites*/
create table activites of activites_type ( 
constraint PK_activites primary key (niveau, nom)
);

/*I.4.3. table cours */
create table cours of cours_type ( 
constraint PK_cours primary key (num_cours),
constraint nn_nom_cours check ( nom is not null)
);

/*I.5. Utilisez describe pour voir les descriptions des types et tables qu'on vient
de créer
I.5.1. description des tables */
desc personnes;
desc activites;
desc cours;

/*I.5.2. description des types*/
desc personne_type;
desc activites_type;
desc cours_type;

/*II. Ajout et modification de données, requêtes
II.1. Ajouter des données dans les trois tables (personnes, activites et
cours) 
II.1.1. table personnes*/
insert into personne values (personne_type('Brisfer', 'Benoit'));
insert into personne values (personne_type('Génial', 'Olivier'));
insert into personne values (personne_type('Jourdan', 'Gil'));

/*II.1.2. table activites*/
insert into activites values (activites_type(1,'Volley ball', 'avs80'));
insert into activites values (activites_type(2,'Mini Foot', 'Amc Indus'));
insert into activites values (activites_type(3,'Tennis', 'Ace Club'));

/*II.1.3. table cours*/
insert into cours values (cours_type(1,'Réseaux', 15,1));
insert into cours values (cours_type(2,'sgbd', 30,1));
insert into cours values (cours_type(3,'programmation', 15,1));

/*II.2. Vérifier qu’il s’agit bien de tables objets et non de tables relationnelles
 select table_name from user_object_tables;
ps: quand on a exécuté la requête ci-dessous on a eu aucun résultat ce
qui prouve qu'on a que des tables objets */
select table_name from user_tables;

/*II.3. Ecrire les requêtes suivantes :

II.3.1. Liste des cours avec toutes les informations associées*/
select * from cours;

/*II.3.2. Nombre d’équipe par activité*/
select nom, count(equipe) as nbr_equipe from activites group by nom;

/*II.3.3. Liste des cours dont le nombre d’heures est supérieure ou égale à 25*/
select nom, sum(nbheure) as nbr_heures from cours group by nom having 
sum(nbheure) >=25;

/*II.3.4.Ajouter une activité ski pour l’´equipe Ace Club (niveau 1)*/
insert into activites values (ativites_type(1,'ski','Ace Club'));

select count(*) as newIN from activites where niveau=1 and 
equipe='Ace Club' and nom='ski';

update activites a set a.niveau=3 where a.equipe='avs80';
select * from activites where equipe = 'Avs80';

/*III. Héritage
III. 1. une nouvelle définition du type personne_type*/
drop table personne;
drop type personne_type;

create or replace type personne_type as object (
nom varchar2(20);
prenom varchar2(20);
)
not final not instantiable
/

/*III. 2. Créer un type professeur_type qui hérite de personne_type */
create or replace type professeur_type under personne_type(
specialite varchar2(20),
date_entree date,
derniere_prom date,
salaire_base number,
salaire_actuel number)
/
desc professeur_type;

/*III. 3. Créez un type eleve_type qui hérite de personne_type */
create or replace type eleve_type under personne_type(
date_naiss date,
poids number,
annee number, 
sexe char(1),
adresse adresse_type
)
/
desc eleve_type;

/*III. 4. Créer les tables eleves et professeurs
III.4.1. table eleves*/
create table eleves of eleve_type(
constraint pk_eleves primary key(nom,prenom)
);

/*III. 4.2. table professeur*/ 
create table professeurs of professeur_type (
constraint pk_professeur primary key (nom,prenom)
);

/*III. 5. les triggers
en suivant l'énoncé du tp nous avons crée le type personne_type 
sans l’attribut numéro, en arrivant à cette question nous avons supprimer 
tout les types et tables (personne,eleves et professeurs) et rajouter 
l’attribut "numéro" dans le type personne_type et comme cela n'apparait pas 
dans nos captures précédantes on a refait la capture ci_dessous
desc eleves;

III. 5.1. insertion des élèves */
create or replace trigger num_eleve
before insert on eleves 
for each row
declare
nbr number;
begin 
select count(*) into nbr from professeurs where numero=: new.numero;
if (nbr>0) then 
raise_application_error(-20099,'le numéro que vous avez choisi a déjà été pris');
end if;
end;

/*III. 5.2. insertion des professeurs*/
create or replace trigger numprofesseur
befor insert on professeurs 
for each row 
declare 
nbr number;
begin 
	select count(*) into nbr from eleves where numero =: new.numero;
	if(nbr>0)	then
		raise_application_error(-20098,'le numéro que vous avez choisi a déjà été pris');
	end if;
end;

/*III. 5.3. test 
III. 5.3.1. insertion dans les deux tables */
insert into eleves values(10,'Brisfer','Benoit','10-12-1978',35,1,'M',adresse_type(10,'rue de la pointe raquet','paris'));

select * from eleves;

insert into professeurs values(12,'Bottle','poésie','BDD','01-10-1970','01-10-1988', 200000,260000);

select * from eleves;

/*III. 5.3.2. test pour un eleve avec un numéro existant dans professeur*/
insert into eleves values(12,'Brisfer','Benoit','10-12-1978',35,1,'M', adresse_type(10,'rue de la pointe raquet','paris'));

/*III. 5.3.3. test pour un professeur avec un numéro existant dans eleve*/
insert into professeurs values(10,'Bottle','poésie','BDD','01-10-1970','01-10-1988' 200000,260000);

/*III. 6. Insérez des données dans les tables eleves et professeurs.
III. 6.1. table eleve*/
insert into eleves values(1,'Génial','Olivier','10-0-1978',42,1,'M', adresse_type(26,'rue du boulvard','paris'));

insert into eleves values(2,'Jordan','Gil','28-06-1974',72,2,'M', adresse_type(30,'rue chouhada','alger'));

insert into eleves values(3,'Spring','jerry','16-02-1974',78,3,'M', adresse_type(15,'rue bidul','Bejaia'));

insert into eleves values(4,'Abc','Def','07-07-1977',52,4,'M', adresse_type(13,'rue truc','Madrid'));

/*III. 6.2. table professeur*/
insert into professeurs values(1,'Bolenov','A','réseau','15-11-1968', 01-10-1998,1900000,2468000);

insert into professeurs values(2,'Tonilaclasse','B','poo','01-10-1979', 001-01-1989,1900000,2360000);

insert into professeurs values(3,'Pastecnov','C','sql','01-10-1975',' ',2500000,2500000);

insert into professeurs values(4,'Selector','D','sql','01-10-1988', 1900000,1900000);
/*III. 7. Afficher la liste des professeurs avec toutes les informations associées*/
select * from professeurs;

/*IV. Collections
IV.1. Créer le type UE_type */
create type les_cours as varray (5) of ref cours_type;

create type UE_type as object(
nom varchar2(20),
cours les_cours
)/

/*IV.2. Créer la table UE avec insertion */

create table UE of UE_type(
constraint pk_ue primary key (nom)
);
/*IV.3. Modifiez le type eleve_type et la table eleves 
pour ce faire, on supprime la table eleves puis on procède à la modification
du type*/

drop table eleves;

create or replace type resultat_type as object(
nom_cours varchar2(20),
point number(2)
)/

create or replace type les_resultats as table of resultat_type;

create or replace eleves_type under personne_type(
date_naissance date,
poids number,
annee number,
sexe char(1),
adresse adresse_type,
resultat les_resultats
)/

create table eleves of eleves_type(
constraint pk_eleves primary key(numero),
constraint nn_eleve_nom check(nom is not null),
constraint nn_eleve_prenom check(prenom is not null),
)
nested table resultat store as tab_resultat/
/*IV.4. Insérez des données dans la nouvelle table eleves*/

/*IV.5. Ajoutez à chaque étudiant, un cours Service Web ainsi qu’une note
associée à ce cours*/
declare
cursor cr is select * from eleves;
c_rec cr%rowtype;
begin
for c_rec in cr loop 
 insert into table ( select e.resultat from eleves e where e.numero = c_rec.numero)
values (resultat_type('WEB SERVICE', 15));
exit when cr%notfound;
end loop;
end;

/*IV.6. Afficher les étudiants dont la note du cours d’Analyse est >= 10*/
 select * from eleves e 
where exists ( 
select * from table(
select elm.reultat from eleves elm where elm.numero = e.numero) dt
where dt.nom_cours='ANALYSE' and dt.points>=10
);








   