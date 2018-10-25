/* Constantes  */
#define N 5	/* number of processes in the ring */
#define L 10	/* 2xN */
#define BLOQUE 0
#define ACCESSIBLE 1

/* Variables globales */

/* Cannaux  */
chan communication = [L] of { byte};
bit statutCritique = ACCESSIBLE;

proctype ordonnancer(chan sortie; bit critique) {
	do
	::	if
		::	(statutCritique == ACCESSIBLE) ->
			ressource :
			printf("tour %d", statutCritique);
			if
				
				::	communication!1
				::	printf("sort"); break
			fi;
			statutCritique = !critique
		fi;
	od;
}

// pour canal pseudo-infini
proctype libererCanal(chan entree) {
	byte c;
	do
	:: entree?c;
		printf("ecouter pour liberer")
	od;
}

init {
	statutCritique = BLOQUE;
	printf("init de l'ordonnancement");
	run ordonnancer (communication, BLOQUE);
	run ordonnancer (communication, ACCESSIBLE);
	run libererCanal (communication);
}

