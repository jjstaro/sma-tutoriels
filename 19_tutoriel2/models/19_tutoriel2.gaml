/***
* Name: 19_tutoriel2
* Author: jeremie
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model tutoriel2

global {
	/** Insert the global definitions, variables and actions here */
geometry var0 <- geometry_collection([{0,0}, {0,10}, {10,10}, {10,0}]); // var0 equals a geometry composed of the 4 points (multi-point).
int N<- 25 parameter:"Nombre de fourmies"category:"Fourmie" min:1 max:50; //nombre de fourmies
int nb_Nid <- 1 parameter:"Nombre de Nid"category:"Fourmie" min:1 max:5; //nombre de Nids
int nb_PointNourriture <- 1 parameter:"Source Nourriture"category:"Nourriture" min:1 max:5; //nombre de sources				
float Rayon<- 1.5 parameter:"Rayon d'observation"category:"Fourmie" min:1.0 max:5.0; //nombre de fourmies
float speed<-5.0;
float Qte;
init{
	create Nid number: nb_Nid;
	create Fourmie number: N{
		location<-one_of(list(Nid)).location;
		NidDorigine<-location;
	}
	
	create Nourriture number: nb_PointNourriture;
}

}
species BasicAgent{
	point location;
	rgb Couleur<-#black;

	}
	
species Fourmie parent: BasicAgent{
	point target<-nil;
	rgb Couleur<-#black;
	float PoidsMax<-rnd(0.1,3.0);
	float Vitesse;
	point NidDorigine;
	bool SavoirNourriture<-false;
	string Etat<-"PaChargé";//Chargé,PasChargé,
	list<Nourriture> food;
	aspect basic{draw circle(1) color: Couleur;}
	//list<Nourriture> listNouriTmp <-((list(Nourriture) where ((each distance_to self) <=Rayon)	;
	
	reflex ChercherNourriture when: (Etat="PasChargé") and (!SavoirNourriture){
		
		//chercher la nouriture
		list<Nourriture> listNourTmp;
		ask target: ((list(Nourriture)) where ((each distance_to self) <=Rayon))
		{
			listNourTmp <-list(Nourriture) where ((each distance_to self) <=Rayon);
			food<- food+ (one_of(listNourTmp));		
			SavoirNourritre<-true;
			target<-listNourTmp.location;
		}
		
		//chercher les marque
		list<Marque>listMarqueTmp;	
		ask target: (list(Marque)) where ((each distance_to self) <=Rayon)
		{
			listMarqueTmp<-(list(Marque)) where ((each distance_to self) <=Rayon);
			food<- food + distinct((one_of(listMarqueTmp)));			
			SavoirNourritre<-true;
			target<-listMarqueTmp.LieuNourriture;
		}
		//chercher d'autres fourmies
		list<Fourmie>listFourmieTmp;		
		ask target: (list(Fourmie)) where ((each distance_to self) <=Rayon) and (each.SavoirNourriture)
		{
			listFourmieTmp<-(list(Fourmie)) where ((each distance_to self) <=Rayon) and (each.SavoirNourriture);
			food <-food +(distinct(one_of(Fourmie)));			
			SavoirNourritre<-true;
			target<-Fourmie.LieuNourriture;
		}		
		
		
	}
	
	reflex AllerChargerNourriture when: (Etat="PasChargé") and (SavoirNourriture){		
		target<-one_of(Nourriture.location);
		if (location=target){
			Nourriture.size<-Nourriture.size-PoidsMax;
			Etat<-"Chargé";
			Qte<-myself.PoidsMax;
		}
		
	}
	
	
	reflex RetournerAuNid when: (Etat="Chargé") And (location!=NidDorigine){
		target<-NidDorigine;
		go to target;
		if(location=target){
			Etat<-"PasChargé";			
		}
	}
	
	}
	
species Nid parent: BasicAgent{
	int size<-rnd(5,10);
	rgb Couleur<-#blue;
	aspect basic{draw circle(size) color: Couleur;}	
	}
	
species Nourriture parent: BasicAgent{
	int size<-rnd(5,10);
	int amount;
	rgb Couleur<-#green;
	aspect basic{draw circle(size) color: Couleur;}
	
	reflex MAJTaille{
		size <- amount+Qte;
		if (amount=0.0){
			do die();
		}
	}
}
	
species Marque parent: BasicAgent{
	point LieuNourriture;
	float DureDeVie<-2.0;
	rgb couleur<-#red;
	float size<-rnd(3.0,5.0);
	
	reflex decrease{
		
		DureDeVie<-DureDeVie-1;
	}
}
experiment tutoriel2 type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display "Simulation fourmies"type: opengl { 
			species Nourriture aspect:basic transparency:0.6;
			species Fourmie aspect:basic;
			species Nid aspect:basic transparency:0.6;
				
		}
		
	}
}
