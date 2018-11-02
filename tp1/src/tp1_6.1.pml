/* Nombres de messages  */
#define MSG_ECS 10
#define MSG_FCS 5
#define MSG_LGS 3
#define MSG_MDS 10
#define MSG_DEST 10

/* contenu des messages */
#define CONT_ECS 10
#define CONT_FCS 20
#define CONT_LGS 30

/* niveau de criticite */
mtype = { faible, elevee };

/* Canal  */
chan buff_ECS = [MSG_ECS] of {byte, mtype}
chan buff_FCS = [MSG_FCS] of {byte, mtype}
chan buff_LGS = [MSG_LGS] of {byte, mtype}
chan buff_MDS = [MSG_MDS] of {byte, mtype}
chan buff_destination = [MSG_DEST] of {byte, mtype} // On veut transmettre les messages du switch
					// pour ne pas perdre de messages

// ECS et FCS mettre vers switch
proctype M_1() {
	byte n_msg_ECS = MSG_ECS;
	byte n_msg_FCS = MSG_FCS;

	// On envoie tous les messages en faisant un decompte des msg
	do
		::n_msg_ECS > 0 -> n_msg_ECS--; buff_ECS!CONT_ECS + n_msg_ECS, faible
		::n_msg_FCS > 0 -> n_msg_FCS--; buff_FCS!CONT_FCS + n_msg_FCS, elevee
		::else; break;
	od
}

// LGS mettre vers switch
proctype M_2() {
	byte n_msg_LGS = MSG_LGS;

	// On envoie tous les messages en faisant un decompte des msg
	do
		::n_msg_LGS > 0 -> n_msg_LGS--; buff_ECS!CONT_LGS + n_msg_LGS, elevee
		::else; break;
	od
}

//ecouter, et switch mettre vers destination
proctype switch() {
	byte m; //message lu puis envoye
	mtype temp_criticite;
	byte n_msg_MDS = 10;

	// Transmettre des messages a la destination
	do	
		::n_msg_MDS > 0 -> // decompte
			n_msg_MDS--;
			if
				::buff_ECS??m, faible -> buff_MDS!m, faible;
				::buff_FCS??m, elevee -> buff_MDS!m, elevee;
				::buff_LGS??m, elevee -> buff_MDS!m, elevee;
				::else ->
				if
					::buff_ECS?m,temp_criticite -> buff_MDS!m,temp_criticite;
					::buff_FCS?m,temp_criticite -> buff_MDS!m,temp_criticite;
					::buff_LGS?m,temp_criticite -> buff_MDS!m,temp_criticite;
				fi
			fi
		::else; break;
	od
}

//Ecouter de MDS
proctype destination() {
	byte m; //message lu puis envoye
	mtype priorite;
	do
		::buff_MDS?m, priorite; buff_destination!m, priorite
		::timeout; break; // sortir si toutes les fonctions sont blocantes
	od
}

init {
	run destination();	
	run M_1();
	run M_2();
	run switch();
}

// 6.2
byte m; //message du canal
mtype niv; //niveau de criticite

ltl regleA		{ (! buff_destination?[m] U (buff_ECS??[m] || buff_FCS??[m] || buff_LGS??[m])) }
ltl regleB		{ [] ((buff_ECS?[m, niv] || buff_FCS?[m, niv] || buff_LGS?[m, niv]) -> <> buff_destination??[m, niv]) }

