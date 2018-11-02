/* Constantes  */
#define L 10	/* taille max du plus gros message */
#define MSG_ECS 10
#define MSG_FCS 5
#define MSG_LGS 3
#define MSG_MDS 10


/* niveau de criticite */
mtype { faible, elevee };

/* Canal  */
chan buff_ECS = [MSG_ECS] of {byte, mtype};
chan buff_FCS = [MSG_FCS] of {byte, mtype};
chan buff_LGS = [MSG_LGS] of {byte, mtype};
chan buff_MDS = [MSG_MDS] of {byte, mtype};
chan buff_destination = [MSG_MDS] of {byte, mtype};
	
/* Variables globales */
bit tour = 0;
bit droitFonction = 0;
bit actif[NBR_FONCTIONS] = { 0,0 };
bit panne[NBR_FONCTIONS] = { 0,0 };

proctype M_1() {
	byte n_msg_ECS = MSG_ECS;
	byte n_msg_FCS = MSG_FCS;
	do
		::n_msg_ECS > 0 -> n_msg_ECS--; buff_ECS!20 + n_msg_ECS, faible;
		::n_msg_FCS > 0 -> n_msg_FCS--; buff_FCS!40 + n_msg_FCS, elevee;
		::else; break;
	od;
}

proctype M_2() {
	byte n_msg_LGS = MSG_LGS;
	do
		::n_msg_LGS > 0 -> n_msg_LGS--; buff_ECS!60 + n_msg_LGS, elevee;
		::else; break;
	od;
}

proctype switch(){
	byte a;
	mtype temp_lvl;
	byte n_msg_MDS = MSG_MDS;
	do	
		:: (msg_MDS > 0) ->
			n_msg_MDS--;
			if
				::buffer_ECS??a, faible -> buffer_MDS!a, faible;
				::buffer_FCS??a, elevee -> buffer_MDS!a, elevee;
				::buffer_LGS??a, elevee -> buffer_MDS!a, elevee;
				::else->
				if
					::buffer_ECS?a,temp_lvl->buffer_MDS!a,temp_lvl;
					::buffer_FCS?a,temp_lvl->buffer_MDS!a,temp_lvl;
					::buffer_LGS?a,temp_lvl->buffer_MDS!a,temp_lvl;
				fi;
			fi;
		::else; break;
	od;
}

proctype destination() {
	byte a;
	mtype priorite;
	do
		::buffer_MDS?a, priorite; buffer_destination!a, priorite;
		::timeout; break; // sortir si toutes les fonctions sont blocantes
	od
}

init {
	run M_1();
	run M_2();
	run switch();
	run destination();		
}

// 6.2
byte m;
mtype lvl;

ltl regleA		{ (!buffer_destination?[m] U (buffer_ECS??[m]||buffer_FCS??[m]||buffer_LGS??[m])) }
ltl regleB		{ []((buffer_ECS?[m, lvl]||buffer_FCS?[m, lvl]||buffer_LGS?[m, lvl]) -> <>buffer_destination??[m, lvl]) }
