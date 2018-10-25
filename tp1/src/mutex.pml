/* Constantes  */
#define N 5	/* number of processes in the ring */
#define L 10	/* 2xN */
#define BLOQUE 0
#define ACCESSIBLE 1

/* Variables globales */
bit statutEntree = ACCESSIBLE;
byte n = 0;
mtype = { FCS, ECS };
etatFonction = { operationnel, enPanne };

/* Cannaux  */
chan canal[N] = [L] of { mtype, byte};

proctype M_1() {
	do
	:: (statutEntree == ACCESSIBLE);
		statutEntree = BLOQUE;
		/* section critique */
		n = n + 1;
		assert (n == 1);
		/* fin section critique */
		n = n - 1;
		statutEntree = ACCESSIBLE;
		/* section non-critique */
		do
		:: (true) -> skip
		:: break
		od
	od
}

init {
	atomic {
		run M_1(); run M_1()
		
	}
}
