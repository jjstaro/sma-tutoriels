/***
* Name: 19tutoriel3
* Author: jeremie
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model tutoriel3

global {
	/** Insert the global definitions, variables and actions here */
	int N_Robot <- 5 parameter:"Nombre de Robot"category:"Robo" min:1 max:50; //nombre de Robot
	float RayonObs <- 5.0 parameter:"Rayon Observation de Robot"category:"Robot" min:1.0 max:5.0; //Rayon d'observation des Robots
	float RayonCom <- 10.0 parameter:"Rayon Communication des Robot"category:"Robot" min:5.0 max:30.0; //Rayon de communcation des Robots
	int M_PointDangeureux <- rnd(5,30) parameter:"Nombre de Point danger"category:"Danger" min:5 max:30; //nombre de sources
	file imgRobot<-image_file("../includes/robot.png"); // image pour représenter les robots
	geometry background<-shape;
	geometry zone_visite;	
	float speed<-1.5;			
	init{
			create Robot number: N_Robot;
			create PointDangereux number: M_PointDangeureux;
			create CentreDeControle number: 1{
				location<-{0,rnd(10,50)};
			}
			
	}
}

species Robot skills:[moving] {
	point location;
	//float RayonObs<-rnd(1.0,2.0);
	//float RayonCom<-rnd(5.0,10.0);
	float VitessDep;
	list<PointDangereux> ListDangers<-nil;
	geometry ZoneVisite<-nil;
	geometry ZoneNonVisite<-shape;
	int size<-3;
	aspect basic{draw imgRobot size: size color:#blue;}
	point tmpPoint;
	reflex Decouvrir when:(ZoneNonVisite!=nil){
		//choisir point à visiter
		tmpPoint<-any_location_in(ZoneNonVisite);
		do goto target:tmpPoint;
		ZoneNonVisite<-ZoneNonVisite+(circle(RayonObs));
		
		//rencontrer autre robot
		 ask target:((agents of_generic_species Robot) at_distance RayonObs){
			myself.ZoneVisite<-myself.ZoneVisite+self.ZoneVisite;
			ListDangers<-self.ListDangers+self.ListDangers;	
		}	
		
		//créer un paneau
		 ask target:((agents of_species PointDangereux) at_distance RayonObs){
			myself.ListDangers<-myself.ListDangers+self.location;
			create PanneauDangereux number: 1{
				self.location<-myself.location;
				self.InfoNiveauDanger<-myself.NiveauDanger;				
			}
		}	
		
				//crommuniquer avec le centre et envoyer les point dangeureux
		 ask target:((agents of_species CentreDeControle) at_distance RayonCom){
			self.ListePointDangers<-self.ListePointDangers+myself.ListDangers;
		}
	}
	
	
	reflex RetournerAuCentre when: (ZoneVisite=background) {
		do goto target:CentreDeControle(location);
	}

}
	
species CentreDeControle{
	point location;
	rgb Couleur<-#green;	
	list<PointDangereux> ListePointDangers;
	aspect basic{draw triangle(5) color: Couleur;}	
	
	reflex RecevoirInfodeRobot{
		
	}
}
		
species PointDangereux{
	point location;
	float NiveauDanger<- rnd(2.0,5.0);
	aspect basic{draw circle(NiveauDanger) color: #red;}
	}
	
species PanneauDangereux{
	point location;
	float InfoNiveauDanger;
	aspect basic{draw square(1) color: #yellow;}
	}
		
experiment tutoriel3 type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display "Danger Mapping"type: opengl { 
			species Robot aspect:basic;
			species CentreDeControle aspect:basic transparency:0.1;
			species PointDangereux aspect:basic transparency:0.3;
			species PanneauDangereux aspect: basic;
	}
	
	}
	
	
}





