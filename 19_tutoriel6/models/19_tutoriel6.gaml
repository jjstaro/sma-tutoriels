/***
* Name: 19tutoriel6
* Author: JEREMIE
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model tutoriel6

global {
	file vBatiment<-file("../includes/shap/batiment.shp");
	file vSortie<-file("../includes/shap/exit.shp");
	file vExtincteur<-file("../includes/shap/extincteur.shp");
	file vRoute<-file("../includes/shap/route.shp");
	file vSonneur<-file("../includes/shap/sonneur.shp");
	
	file imgExit<-image_file("../includes/images/exit.png");
	file imgExtincteur<-image_file("../includes/images/extincteur.png");
	file imgFeu<-image_file("../includes/images/feu.png");
	file imgPersonne<-image_file("../includes/images/personne.png");
	file imgPompier<-image_file("../includes/images/pompier.png");
	
	int Nb_Feu <- 1 parameter:"Nb Feu"category:"Feu" min:1 max:5;
	int Nb_Evacue <- 10 parameter:"Nb évacués"category:"Feu" min:10 max:50;
	int Nb_Police <- 5 parameter:"Nb Feu"category:"Police" min:5 max:20;
	
	geometry shape <- envelope(envelope(vBatiment) + envelope(vRoute)+envelope(vSortie)+envelope(vExtincteur)+envelope(vSonneur));
	graph cheminRoute;
	//geometry shape1 <- envelope(vRoute) ;
	
	init{
		create Batiment from: vBatiment;
		create Exit from: vSortie;
		create PlaceExtincteur from: vExtincteur;
		create Route from: vRoute;
		create PlaceSonneur from: vSonneur;
		
		cheminRoute<-as_edge_graph(Route);
		
		create PanneauSortie number: 29{
			location<-any_location_in(one_of(Exit));
		}
		
		create Extincteur number: 16{
			location<-any_location_in(one_of(PlaceExtincteur));
		}
		
		create Policier number: Nb_Police{
			location<-any_location_in(one_of(Batiment));
		}
		
		create Evacue number: Nb_Evacue{
			location<-any_location_in(one_of(Batiment));
		}
		
		create Sonneur number: 20{
			location<-any_location_in(one_of(PlaceSonneur));
		}
		create Feu number: Nb_Feu{
			location<-any_location_in(one_of(Batiment));
			locationPosible<-1 points_at(8);
			tempPropager<-40;
			tempVie<-50.0;
		}
	}
}

species Personne skills: [moving]{
	float Taille<-3000.0;
	float PuissanceRestant<-5.0;
	float speed<-3000.0;
	float RayonObs<-3.0;
	point target;
	
	aspect basic {
		draw imgPersonne size:Taille;
	}
}

species Evacue parent: Personne{
	
	aspect basic {
		draw imgPersonne size:Taille;
	}
	reflex Sortir{
		ask target:((agents of_species Exit) at_distance RayonObs){
			myself.destination<-self.location;
			
		} 
	}
	
	bool incendi<-true;
		
	reflex Sortir when: incendi{
		do wander speed:speed;
		
		ask target:((agents of_species Feu) at_distance RayonObs){
			myself.incendi<-true;
		} 
		if (incendi=true){
			ask target:((agents of_species Exit) at_distance RayonObs){
				myself.destination<-self.location;							
			}
			do goto target:destination on: cheminRoute; 
			if(location=destination){
				do die();
			}
		}
			
	}

}
species Policier parent: Personne{
	float Taille<-5000.0;	
	bool incendi<-true;
	aspect basic {
		draw imgPompier size:Taille ;
	}
	reflex ChercherSonneur
	{
		do wander speed:speed;
		ask target:((agents of_species Sonneur) at_distance RayonObs){
			myself.incendi<-true;
		} 
		if (incendi=true){
			ask target:((agents of_species Extincteur) at_distance RayonObs){
				myself.destination<-self.location;							
			}
			do goto target:destination on: cheminRoute; 
			if(location=destination){
				ask target:((agents of_species Feu) at_distance RayonObs){
				myself.destination<-self.location;	
										
			}
			}
		}
		
	}
	
}
species Feu{
	float intensite<-2.0;
	int rayonAffecte<-1;
	int tempPropager;
	float Taille<-5000.0;
	float tempVie;
	list<point> locationPosible;
	
	aspect basic {
		draw imgFeu size:Taille ;
	}
	reflex Propager {
		
		if (tempPropager=0){
			create Feu number: 1 {
				self.location<-any_point_in(myself.locationPosible[]);	
				//self.tempPropager<-40;	
				//self.tempVie<-50.0;	
			}
			
		}
		else
		{
			tempPropager<-tempPropager-1;
			tempVie<-tempVie-1;
			if(tempVie=0){
				do die();
			}
			
		}
	//rayonAffecte<-rayonAffecte+1;			
	}

}

species Extincteur{
	float Taille<-5000.0;
	aspect basic {
		draw imgExtincteur size: Taille ;
	}
}
species PanneauSortie{
	float Taille<-5000.0;	
	aspect basic {
		draw imgExit size: Taille;
	}
}
species Sonneur{
	float Taille<-10.0;
	string Etat<-"Arret";
	
	aspect basic {
		draw circle(Taille) color:#blue ;
	}
	action AllumerSonnerie{
		Etat<-"Marche";
	}
	action CouperSonerie{
		Etat<-"Arret";
	}
}


species Batiment{
	float Taille<-5.0;
	aspect basic {
		draw shape color:#gray ;
	}
}
species Exit{
	float Taille<-5.0;
	aspect basic {
		draw shape color:#green ;
	}
}
species PlaceExtincteur{
	float Taille<-5.0;
	aspect basic {
		draw shape color:#red ;
	}
}
species Route{
	aspect basic {
		draw shape color:#black ;
	}
}
species PlaceSonneur{
	float Taille<-10.0;
	aspect basic {
		draw shape color:#blue;
	}
}
/* Insert your model definition here */
//Creation des medecins
experiment Incendie type: gui {	
	output {	
	
	 	display "Evacuation incendie"type: opengl { 
			species Batiment aspect: basic;
			species Route aspect: basic;
			species Exit aspect: basic;			
			species PlaceSonneur aspect: basic;
			species PlaceExtincteur aspect: basic;
			
			species PanneauSortie aspect: basic;
			species Sonneur aspect: basic;
			species Extincteur aspect: basic;
			species Policier aspect: basic;
			species Evacue aspect: basic;
			species Feu aspect: basic;
	 	}
	}
}

