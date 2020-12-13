/***
* Name: tutorie5
* Author: jeremie
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model tutorie5

global {
	file imgPieton<-image_file("../includes/images/pieton.png"); // image pour représenter les pietons
	file imgPolicier<-image_file("../includes/images/policier.png");
	file imgCamion<-image_file("../includes/images/camion.png");
	file imgVoiture<-image_file("../includes/images/voiture.png");
	file imgMoto<-image_file("../includes/images/moto.png");
	file vRoute <- file("../includes/Intersection/Road2.shp");
	file vTournerLeft <- file("../includes/Intersection/Target Left.shp");
	file vTournerRight <- file("../includes/Intersection/Target Right.shp");
	file vTournerDown <- file("../includes/Intersection/Target Down.shp");
	file vTournerUp <- file("../includes/Intersection/Target Up.shp");
	file vIntersection <- file("../includes/Intersection/Intersection.shp");
	
	int N_Pieton <- 25 parameter:"Nb Pietons"category:"Pieton" min:1 max:50; 
	int N_Moto <- 5 parameter:"Nb Moto"category:"Moy. Transp." min:1 max:10;
	int N_Voiture<-5 parameter: "Nb Voiture" category: "Moy. Transp." min:5 max:20;
	int N_Camion<-5 parameter: "Nb Camion" category: "Moy. Transp." min:5 max:20;
	/** Insert the global definitions, variables and actions here */
	geometry shape <- envelope(vRoute);
	graph cheminRoute;
	graph TournerGauche;
	graph TournerDroite;
	graph TournerUp;
	graph TournerDown;
	init{
		
		create Intersection from: vIntersection;
		create Route from: vRoute;
		create RouteLeft from: vTournerLeft;
		create RouteRight from: vTournerRight;
		create RouteDown from: vTournerDown;
		create RouteUp from: vTournerUp;
		cheminRoute<-as_edge_graph(Route);
		TournerDroite<-as_edge_graph(RouteRight);
		TournerGauche<-as_edge_graph(RouteLeft);
		TournerDown<-as_edge_graph(RouteLeft);
		TournerUp<-as_edge_graph(RouteLeft);
		
		/*create Pieton number: N_Pieton{
			//location<-any_location_in(one_of(Route));
			destination<-(any_location_in(one_of(Route)));
		}
		create Policier number: 1{
		//	location<-(point(rnd(1,10),rnd(10,20)));
		}
		*/create Moto number: N_Moto{
			location<-any_location_in(one_of(Route));
			//DestinationPossible<-list(one_of());
			destination<-(any_location_in(one_of(Route)));
			VitesseInitiale<-2.0;
			VitesseActuelle<-VitesseInitiale;
		}
		
		create Voiture number: N_Voiture{
			location<-any_location_in(one_of(Route));
			Destination<-one_of(detinationPossible);
			
			
		}
		create Camion number: N_Camion{
			location<-any_location_in(one_of(Route));
			Destination<-one_of(detinationPossible);
			VitesseInitiale<-3.0;
			VitesseActuelle<-VitesseInitiale;
		}
		create FeuTricolor number: 2{
			currentColor<-#red;
			//location<-(point(rnd(1,10),rnd(10,20)));
		}
		create FeuTricolor number: 2{
			currentColor<-#green;
			//location<-(point(rnd(1,10),rnd(10,20)));
		}
	}
}

species FeuTricolor {
	point location;
	rgb currentColor;
	int durChangerCouleur<-5;
	int conteur<-0;
	aspect basic{draw circle(10) color:currentColor;}
	
	reflex fonctionement{
		conteur+<-1;
		if(conteur=durChangerCouleur){
			if (currentColor=#green){
				currentColor<-#green;
			}
			else {
				currentColor<-#green;				
			}
		}
	}
}

/*species Policier{
	point location;
	string instruction;
	//point Destination;
	
	aspect basic{draw imgPolicier size:80;}
	
	reflex AfficherInstruction{
		
	}
}*/

/*species Pieton skills:[moving]{
	point location;
	point Destination;
	float RayonObs;
	float Vitesse;
	aspect basic{draw imgPieton size:50;}
	
	reflex SeDeplacer{
		//do wander ;
		do goto target: Destination;
	}
}*/
	
species MoyenTransport skills:[moving]{
	point location;
	point Destination;
	list<point> detinationPossible;
	float DisatnceDeSecurite;	
	float VitesseInitiale;	
	float VitesseActuelle;	
	reflex SeDeplacer {
		//do wander on: cheminRoute;
		
		//communication avec les autre moyen de transport
		ask target:((agents of_generic_species MoyenTransport) at_distance DisatnceDeSecurite){
			if(self.VitesseActuelle=0){
				do Stop;
			}else{
				do DiminuerVitesse;
			}						
		}
		//communication avec les feu tricolor
		ask target:((agents of_generic_species FeuTricolor) at_distance DisatnceDeSecurite){
			if(self.currentColor=#red){
				myself.VitesseActuelle<-0.0;
			}
			else{
				myself.VitesseActuelle<-myself.VitesseInitiale;
			}			
		}
		//se déplacer pour aler 
		do goto target: self.Destination speed: VitesseActuelle on: cheminRoute;		
	}
	
	action DiminuerVitesse{
			VitesseActuelle<-VitesseActuelle-1.0;
		}
	action Stop{
			VitesseActuelle<-0.0;
		}
	reflex Mourir{
		if(location=Destination){
			create one_of((Voiture),(Camion),(Moto)) number: 1{
			location<-any_location_in(one_of(Route));
			destination<-(any_location_in(one_of(Route)));
			}	
			do die;
		}
	}
	
}

species Voiture parent:  MoyenTransport{
	init{
	VitesseInitiale<-5.0;
	VitesseActuelle<-VitesseInitiale;}
	aspect basic{draw imgVoiture size:50;}
	
	}
	
species Camion parent:  MoyenTransport{
	init{
	VitesseInitiale<-3.0;
	VitesseActuelle<-VitesseInitiale;}
	aspect basic{draw imgCamion size:50;}	
}	

species Moto parent:  MoyenTransport{
	init{
		VitesseInitiale<-2.0;
		VitesseActuelle<-VitesseInitiale;
		}
	aspect basic{draw imgMoto size:50;}	
}
species RouteDown{
	aspect basic {
		draw shape color: #gray ;
	}
}
species Intersection{
	aspect basic {
		draw shape color: #gray ;
	}
}
species RouteUp{
	aspect basic {
		draw shape color: #gray ;
	}
}
	
species Route{
	aspect basic {
		draw shape color: #black ;
	}
}

species RouteLeft{
	aspect basic {
		draw shape color: #black ;
	}
}
species RouteRight{
	aspect basic {
		draw shape color: #black ;
	}
}
experiment tutorie5 type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
					display "Predateur et proie"type: opengl 
			{ 
				species Intersection aspect: basic;
				species RouteDown aspect: basic;
				species RouteUp aspect: basic;
				species Route aspect: basic;
				species RouteLeft aspect: basic;
				species RouteRight aspect: basic;
				//species Pieton aspect:basic;
				//species Policier aspect:basic;
				species Camion aspect:basic;
				species Moto aspect:basic;
				species Voiture aspect:basic;				
				species FeuTricolor aspect:basic;	
		}
	}
}
