/* Constantes  */
#define L 0	/* pour canal infini */
#define NBR_FONCTIONS 2

/* Canal  */
chan CC = [L] of {byte};

/* Variables globales */
bit tour = 0;
bit actif[NBR_FONCTIONS] = { 0,0 };
bit panne[NBR_FONCTIONS] = { 0,0 };

proctype executerFonction(chan canalSortie; bit tourCritique) {
	do
		::if
		:: (tour == tourCritique) -> // si le tour est correctement assigne
			
			atomic { 
				/* debut de section critique */

				actif[tourCritique] = 1;
				if	//ecrire ou tomber en panne
					::canalSortie!1;
					::break;
				fi;
				actif[tourCritique] = 0;
				tour = !tourCritique;

				/* fin de section critique */
			} 
			
		:: skip -> skip
		:: skip -> skip
		:: skip -> skip
		:: skip -> skip
		:: break;	// si le if est blocant, on a une chance sur 5 de break. 
			// Ceci est un nombre arbitraire qui permet de rester
			// plus longtemps dans le proctype executerFonction.
		fi;
	od;

}

// On ecoute le canal de temps en temps, ce qui donne l'illusion d'un canal infini
proctype libererCanal(chan entree) {
	byte c;
	do
		::entree?c;
	od;
}

init {
	// lancer et ordonnancer
	run executerFonction(CC, tour);
	run executerFonction(CC, tour);
	run libererCanal(CC);
	do
		::timeout -> panne[tour] == 1 // sortir de panne de maniere non deterministe
		if
			::panne[0] == 0; tour = 0;
			::panne[1] == 0; tour = 1;
			::else; break;
		fi;
	od;
	
}

// 5.3
ltl regleA		{ []( (!actif[0]) || (!actif[1]) ) }
ltl regleB1		{ [](<>actif[0] || panne[1]) }
ltl regleB2		{ [](<>actif[1] || panne[0]) }
ltl regleC		{ panne[1] -> [](<>actif[0] || panne[0]) }

