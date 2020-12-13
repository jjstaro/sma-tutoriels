/***
* Name: tutoriel1
* Author: jeremie
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model tutoriel1
global{
	float TotalDistance;
	float Moyenne;
	int nn;
	int totalChangeCouleur;
	int nb_KPoints <- 3 parameter:"Nombre de Centres" category:"Point" min:1 max:5; //nombre de centres
	int nb_Points <- 50 parameter:"Nombre de points" category:"Point" min:20 max:100; //nombre de points
	geometry var0 <- geometry_collection([{0,0}, {0,10}, {10,10}, {10,0}]); // var0 equals a geometry composed of the 4 points (multi-point).

	
	init{
    	//Initialisation des agents
    	create  unPoint number: nb_Points;
    	//création des centres
    	create unCentre number:nb_KPoints{
    		location <- any_location_in(one_of(BasicAgent));
    		Couleur<-rgb(rnd(1,255),rnd(1,255),rnd(1,255));
    	}
    }
/* Insert your model definition here */
species BasicAgent{
	point location;
	rgb Couleur<-#black;
	aspect basic{draw circle(1) color: Couleur;}
	}
		
}
species unCentre parent: BasicAgent{
	reflex MettreAjour{
		TotalDistance<-0.0;
		//recuper la liste des des points qui son de memte couleur		
		ask target:(agents of_generic_species BasicAgent) where(each.Couleur=self.Couleur) {
		TotalDistance <-TotalDistance+ distance_to(location, self.location);
		Moyenne<-TotalDistance / agents of_generic_species BasicAgent count (each.Couleur=self.Couleur);
		}
	}

}


species unPoint parent: BasicAgent{
	reflex CalculDistance{
		
	
	float dist<-0.0;
	//liste des centres
	ask target:(agents of_generic_species unCentre) where(each.Couleur=self.Couleur) {	
		//Changer la couleur en fonction de la distance
		if(dist < distance_to(location, self.location)){
			dist<- distance_to(location, self.location);
			Couleur<-self.Couleur;
		}
	}
	
	}
}


experiment "k-mean" type: gui {

	
	// Define parameters here if necessary
	// parameter "My parameter" category: "My parameters" var: one_global_attribute;
	
	// Define attributes, actions, a init section and behaviors if necessary
	// init { }
	
	
	output {
	// Define inspectors, browsers and displays here
	
	// inspect one_or_several_agents;
	//
	// display "My display" { 
	//		species one_species;
	//		species another_species;
	// 		grid a_grid;
	// 		...
	// }
	display "Tutoriel K-mean"type: opengl { 
			species unCentre aspect: basic;
			species unPoint aspect: basic;
	 	}
	}
}