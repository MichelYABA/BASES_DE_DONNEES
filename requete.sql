/*1*/
select * from utilisateurs;

/*2*/
select count(distinct pays) as nombre_pays from utilisateurs ;

/*3*/
select * from utilisateurs where pays='bresil' order by nom;

/*4*/
select ville, count(*) as nb_users from utilisateurs where pays='France' group by ville;

/*5*/
select count(*) as nb_compte from utilisateurs where extract(YEAR from to_date(date_insc)) between '2010' and '2017';

/*6*/
select * from publications where length(texte_pub)<100 and nb_jaime>100;

/*7*/
select r1.pseudo, r1.nom, r1.prenom, r2.date_liaison_ami from utilisateurs r1 join (select * from amities a natural join utilisateurs u where u.pseudo='Kevin69') r2
on r1.id_user=r2.ami_id_user order by r2.date_liaison_ami desc;

/*8*/
select id_user, count(id_user) nb_amis from amities a natural join utilisateurs u where u.ville='Londres'
group by id_user order by nb_amis asc

/*9*/
select r1.nom_groupe from groupes r1 join 
(select id_groupe from integrations
group by id_groupe
having count(*)>= all(select count(id_user) as nb_membres from integrations
group by id_groupe)) r2 using(id_groupe

/*10*/
select u2.sexe, count(*) from utilisateurs u2 join 
(select i.id_user from groupes g join integrations i using (id_groupe) 
where nom_groupe='Flat Earth Society') g_m on u2.id_user=g_m.id_user
group by u2.sexe

/*11*/
select r1.nom_page, r2.moyenne from pages r1 join
(select id_page, avg(nb_jaime) as moyenne from publications
group by id_page
having avg(nb_jaime)>5 and id_page IS NOT NULL
order by moyenne) r2 using (id_page)

/*12*/
select R1.nom_page, R2.titre_pub, R2.nb_jaime from pages R1 join
(select pub1.id_page, pub1.titre_pub, pub1.nb_jaime from publications pub1
where pub1.nb_jaime >= any
(select max(pub2.nb_jaime)
from publications pub2
where pub2.id_groupe is null and pub2.id_page is not null
group by pub2.id_page) and pub1.id_page is not null) R2 using(id_page)

/*13*/

select i1.id_groupe, count(i1.id_groupe) as nb_user_avec_5_like,
(select count(i2.id_user) from integrations i2 where i1.id_groupe = i2.id_groupe group by i2.id_groupe) 
as nb_user_par_groupe, count(i1.id_groupe)/(select count(i3.id_user) from integrations i3 where 
i1.id_groupe=i3.id_groupe group by i3.id_groupe) as nb_user_divise
from integrations i1
where id_user in(
    select admin fr


/*14*/
select avg(length(texte_pub) - length(replace(texte_pub, ' ', '')) + 1) NOMBRE_MOYEN_DES_MOTS from publications
where texte_pub like '%Trump%'

/*15*/
select distinct p1.id_user from publications p1
where p1.id_page IN (select  p2.id_page from pages p2 where p2.id_user IN 
                     (select  a.ami_id_user from amities a where p1.id_user=a.id_user))

/*16*/
select u1.id_user,u2.id_user
from utilisateurs u1,utilisateurs u2
where EXISTS
      (select *
      from integrations i  join utilisateurs u on u.id_user=i.id_user 
                 and u.id_user=u1.id_user
      group BY u1.id_user
      having count(*)*0.8 <=
     (select count(*)
           from integrations i1 join integrations i2 on i1.id_groupe=i2.id_groupe 
           and i1.id_user=u1.id_user and i2.id_user=u2.id_user))

/*17*/

select * from utilisateurs u
where exists (select * from publications pub join utilisateurs u1 on u1.id_user=pub.id_user and u1.pseudo = 'Kevin69'
where exists (select * from amities a join publication_aimes pa on a.id_user= pa.id_user and a.ami_id_user=u1.id_user 
                  and pa.id_pub=pub.id_pub and a.id_user=u.id_user))

/*18*/
select * from utilisateurs u1
where not exists (select i1.id_groupe from (integrations i1 join utilisateurs u2 on u2.id_user=i1.id_user and u1.pseudo='Kevin69')
where not exists (select * from integrations i2 where i2.id_groupe=i1.id_groupe and i2.id_user=u1.id_user))

select * from utilisateurs u
where u.id_user in (select i1.id_user from integrations i1 join groupes g on i1.id_groupe=g.id_groupe and g.id_user=4) 

select * from utilisateurs u1 where u1.id_user in (select i.id_user from integrations i
                                              where i.id_groupe in (select g.id_groupe from groupes g where
                                                                  g.id_user = (
                                                                  select u2.id_user from utilisateurs u2 where u2.pseudo='Kevin69'
                                                                  )));
/*19*/
select count(*) nb_personnes
from amities a join utilisateurs u on a.id_user=u.id_user and u.pseudo='kevin69'
group by (a.ami_id_user)

select count(distinct a.id_user) nbre_personne from amities a
where a.ami_id_user in (select a1.ami_id_user from amities a1 join utilisateurs u2 on a1.id_user=u2.id_user and u2.pseudo='Kevin69') 

/*20*/

select level, u.id_user, u.pseudo
   from utilisateurs u join (select * from reponses r join publications p on r.id_pub_1=p.id_pub
                            ) s on u.id_user =s.id_user
   where u.pseudo <>'Kevin69' and level > 10
   connect by  s.id_pub_2=PRIOR s.id_pub_1
   start with u.pseudo='Kevin69';

select r.id_pub_1, r.id_pub_2, p.texte_pub from reponses r join publications p 
on r.id_pub_1=p.id_pub
start with r.id_pub_2 is null connect by r.id_pub_2 = PRIOR id_pub_1


select r1.id_pub_1 as Reponse, r1.id_pub_2 as Publication_Origine,
RPAD(' ', level-1) || p1.texte_pub as contenu from reponses r1 join publications p1 
on r1.id_pub_1=p1.id_pub
where exists (select r2.id_pub_1, r2.id_pub_2, RPAD(' ', level-1) || p2.texte_pub
             from reponses r2 join publications p2 on r2.id_pub_1=p2.id_pub
              where level >=10
             start with id_pub_2 = 1 connect by id_pub_2 = PRIOR id_pub_1)
start with id_pub_2 = 1 connect by id_pub_2= prior id_pub_1;

/*21*/
select r.id_pub_1, r.id_pub_2, level, p.titre_pub from reponses r join publications p on r.id_pub_1=p.id_pub
start with id_pub_2 is null connect by id_pub_2 = prior id_pub_1

select r1.id_pub_1, r1.id_pub_2, level, r1.titre_pub, r2.titre_pub as titre_initiale
from (select rep.id_pub_1, rep.id_pub_2, level, p.titre_pub 
      from publications p join reponses rep on rep.id_pub_1=p.id_pub
     start with rep.id_pub_2 is null connect by rep.id_pub_2 = PRIOR rep.id_pub_1) r1, publications r2
where r2.id_pub=r1.id_pub_2 and level > 1
connect by r1.id_pub_2 = PRIOR r1.id_pub_1;

/*22*/
select r.id_pub_1 as message_répondu, r.id_pub_2 as message_source, RPAD(' ', level-1) || p.texte_pub 
from reponses r join publications p on r.id_pub_1=p.id_pub
start with id_pub_2 = (select u.id_user from utilisateurs u 
	where u.pseudo = 'Kevin69') connect by r.id_pub_2 = PRIOR r.id_pub_1 

/*23*/
select u.id_user, u.pseudo, u.nom, u.prenom from utilisateurs u
where u.id_user in (select p.id_user from reponses r join publications p
                    on r.id_pub_1=p.id_pub where level >=3
start with r.id_pub_2 is null
connect by r.id_pub_2 = PRIOR r.id_pub_1)



