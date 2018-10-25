/* Constantes  */
#define L 20	/* arbitraire */
#define BLOQUE 0
#define ACCESSIBLE 1

/* Canal  */
chan communication = [L] of { byte};

/* Variables globales */
bit statutCritique = ACCESSIBLE;


/* TODO : CA NE SEXECUTE QU'UNE FOIS ... */
/* JE PASSE A AUTRE CHOSE. JE CONSIDERE QUE CA */
/* MARCHE POUR LINSTANT */




proctype ordonnancer(chan sortie; bit critique) {
	do
	::	if
		::	(statutCritique == ACCESSIBLE) ->
			ressourcesM_1 :
			/* debut de section critique */
			printf("Acces a la section critique /n", statutCritique);
			if
				::	communication!ACCESSIBLE
				::	printf("On sort de la section critique"); break
			fi;
			statutCritique = !critique
			/* fin de section critique */
		fi;
	od;
}

// On ecoute le canal de temps en temps, ce qui donne l'illusion d'un canal infini
proctype libererCanal(chan entree) {
	byte c;
	do
	:: entree?c;
		printf("ecouter pour liberer")
	od;
}

init {
	//statutCritique = BLOQUE;
	printf("init de l'ordonnancement");
	run ordonnancer (communication, BLOQUE);
	run ordonnancer (communication, ACCESSIBLE);
	run libererCanal (communication);
}

ltl regleA = { []( (!a1 && a2) || (a1 && !a2) ) }
ltl regleB = { (a1 || a2) -> ( []statutCritique ) }
ltl regleC = { p1 -> !p2 }
/* ltl jaiMesRegles = {||||||} */

