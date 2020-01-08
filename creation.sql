

CREATE TABLE UTILISATEURS(
			id_user NUMBER, pseudo VARCHAR2(10) not null, mdp VARCHAR2(10) not null,
			 nom VARCHAR2(20) not null, prenom VARCHAR2(20) not null, date_nais DATE not null, 
			 sexe CHAR(1) not null, email VARCHAR2(50) not null, tel VARCHAR2(10) not null, 
			 date_insc DATE not null, date_ferm DATE, pays VARCHAR2(20) not null, 
			 ville VARCHAR2(20) not null);

CREATE TABLE GROUPES(id_groupe NUMBER, nom_groupe VARCHAR2(20) not null, type_groupe VARCHAR2(20) not null,
									id_user NUMBER not null);

CREATE TABLE PAGES(id_page NUMBER, nom_page VARCHAR2(20) not null, type_page VARCHAR2(20) not null, 
	id_user NUMBER not null);

CREATE TABLE PUBLICATIONS(id_pub NUMBER, titre_pub VARCHAR2(20) not null, date_pub DATE not null, 
	texte_pub VARCHAR2(255) not null, nb_jaime NUMBER, id_user NUMBER not null, id_page NUMBER, id_groupe NUMBER);

CREATE TABLE INTEGRATIONS(id_user NUMBER, id_groupe NUMBER);

CREATE TABLE PAGE_AIMES(id_user NUMBER, id_page NUMBER);

CREATE TABLE PUBLICATION_AIMES(id_user NUMBER, id_pub NUMBER);

CREATE TABLE REPONSES(id_pub_1 NUMBER, id_pub_2 NUMBER);

CREATE TABLE TCHATS(id_user_1 NUMBER, id_user_2 NUMBER, message VARCHAR2(255), 
					date_msge DATE);

CREATE TABLE AMITIES(id_user NUMBER, ami_id_user NUMBER, date_liaison_ami DATE not null);

CREATE TABLE COUPLES(id_user NUMBER, couple_id_user NUMBER, date_liaison_couple DATE not null);

/*CREATE TABLE POSTS_GROUPE(id_user NUMBER, id_groupe NUMBER, id_pub NUMBER);

CREATE TABLE POSTS_PAGE(id_user NUMBER, id_pub NUMBER, id_page NUMBER);
*/
