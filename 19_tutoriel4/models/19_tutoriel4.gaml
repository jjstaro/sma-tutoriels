/***
* Name: 19tutoriel4
* Author: jeremie
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model tutoriel4

global {
	/** Insert the global definitions, variables and actions here */
	file imgHerbre<-image_file("../includes/herbre.png"); // image pour représenter les herbre
	file imgLoup<-image_file("../includes/loup.png"); // image pour représenter les loup
	file imgAgneau<-image_file("../includes/agneau.png"); // image pour représenter les agneau
	
	int N_Herbre <- 25 parameter:"Nombre d'herbe"category:"Herbe" min:15 max:30; //nombre d'herbres
	int AgeMax_H<- 10 parameter:"Age maxi d'herbre"category:"Herbe" min:5 max:20; //nombrage max d'herbres
	float SizeMax_H<-15.0 parameter: "Taille Maxi" category: "Herbe" min:10.0 max:20.0;//taille maxi herbre
	float SizeMature_H<-5.0 parameter: "Taille Mature" category: "Herbe" min:10.5 max:15.0;//taille mature herbre
	
	int N_Loup <- 5 parameter:"Nombre de Loup"category:"Loup" min:1 max:50; //nombre de Loup
	int AgeMax_L<-3 parameter: "Age Maxi" category: "Loup" min:1 max:5;//age maxi loup
	float SizeMax_L<-5.0 parameter: "Taille Maxi" category: "Loup" min:2.5 max:5.0;//taille maxi loup	
	float SizeMature_L<-2.5 parameter: "Taille Mature" category: "Loup" min:1.5 max:5.0;//taille mature agneau
	
	int N_Agneau <- 25 parameter:"Nombre d'agneau"category:"Agneau" min:1 max:50; //nombre de Agneau
	int AgeMax_A <- 5 parameter:"Age Max agneau"category:"Agneau" min:1 max:10; //nombre de Agneau
	float SizeMax_A<-15.0 parameter: "Taille Maxi" category: "Agneau" min:10.5 max:20.0;//taille maxi agneau
	float SizeMature_A<-12.0 parameter: "Taille Mature" category: "Agneau" min:10.5 max:15.0;//taille mature agneau
	
	float speedGrandir;
	float speedReproduir<-2.0;
	float ageMature;
	float RayonObs <- 5.0 parameter:"Rayon Observation"category:"Général" min:1.0 max:5.0; //Rayon d'observation des Robots
	float RayonManger <- 1.0 parameter:"Rayon de manger"category:"Général" min:5.0 max:30.0; //Rayon de communcation des Robots
	float tempsCreerEnfant<-5.0 parameter:"CréerEnfant"category:"Général";
	float QteMangePossible<-3.0 parameter:"CréerEnfant"category:"Général";
	init{
		create Herbre number: N_Herbre{
			size<-5.0;			
		}
		create Agneau number: N_Agneau{
			age<-0.5;
			size<-10.0;	
			QteMange<-0.0;
			SpeedDeplacement<-rnd(0.5,5.0);	
		}
		create Loup number: N_Loup{
			age<-0.5;
			size<-10.0;	
			QteMange<-0.0;	
			SpeedDeplacement<-rnd(0.5,5.0);		
		}

	}	
}


species Creature  {
	point location;
	float size;
	float age;
	float tempsEnfant;
}


species Herbre parent: Creature {
	
	aspect basic{draw imgHerbre size: size color:#green;}	
	reflex Grandir when:(size<SizeMax_H){
		size<-size+(0.5);
	}
	reflex CreerEnfant when:(age>=ageMature and tempsEnfant>=tempsCreerEnfant){
		 ask target:(self neighbors_at RayonObs){
		 	create Herbre number:1{
				self.size<-5.0;	
				self.location<-location+int(RayonObs);		
			} 
			//réinitialisé temps enfant
			tempsEnfant<-0.0;
		
		 }
	}
	action HerbeEtreManger{
		size<-size-1.0;

	}
	reflex vivant{
		tempsEnfant<-tempsEnfant+1.0;
	}
	

}

species Animal parent: Creature skills:[moving]{	
	
	float ageMature;
	float QteMangePossible;
	float QteMange;
	float SpeedDeplacement;
	bool AvoirFaim<-true;
	int tempsSuppManger<-3;
	
	
	

}


species Agneau parent: Animal {
	aspect basic{draw imgAgneau size: size;}	
	
	reflex ChercherHerbe when:QteMange<QteMangePossible {
		do wander speed:SpeedDeplacement;		
		//chercher herbre manger 
		 ask target:((agents of_species Herbre) at_distance RayonObs){		 		
		 //manger
		 	//if (self.size>=SizeMature_H){
		 		do HerbeEtreManger;
		 		myself.QteMange<-myself.QteMange+1.0;
		 		myself.tempsSuppManger<-3;
		 	//}	 	
		}

	}
	reflex CreerEnfant when:(age>=ageMature and tempsEnfant>=tempsCreerEnfant){
		 ask target:(self neighbors_at RayonObs){
		 	create Herbre number:1{
				self.size<-5.0;	
				self.location<-location+int(RayonObs);		
			} 
			//réinitialisé temps enfant
			tempsEnfant<-0.0;
		
		 }
	}
	action AgneauEtreManger{
		size<-size-5.0;
		if((size=0.0) or (age=AgeMax_A)){do AgneauEtreMort;}
	}
	
	action AgneauEtreMort {			
		do die;	
		
	}
	reflex vivant{
		age<-age+1.0;
		//grandir
		if(size<SizeMax_A){size<-size+(1.0);}
		QteMange<-QteMange-1.0;
		tempsCreerEnfant<-tempsCreerEnfant+1;
		tempsSuppManger<-tempsSuppManger-1;
	}
	

	
}	
	

species Loup parent: Animal skills:[moving]{
	aspect basic{draw imgLoup size: size;}	

	reflex ChercherAgneau when:QteMange<QteMangePossible {
		do wander speed:SpeedDeplacement;		
		//chercher herbre manger 
		 ask target:((agents of_species Agneau) at_distance RayonObs){		 		
		 //manger
		 	//if (self.size>=SizeMature_H){
		 		do AgneauEtreManger;
		 		myself.QteMange<-myself.QteMange+5.0;
		 		myself.tempsSuppManger<-3;
		 	//}	 	
		}

	}
	

	reflex Grandir when:(size<SizeMax_L){
		size<-size+(0.5);
	}
	reflex CreerEnfant when:(age>=ageMature and tempsEnfant>=tempsCreerEnfant){
		 ask target:(self neighbors_at RayonObs){
		 	create Herbre number:1{
				self.size<-5.0;	
				self.location<-location+int(RayonObs);		
			} 
			//réinitialisé temps enfant
			tempsEnfant<-0.0;
		
		 }
	}
	action HerbeEtreManger{
		size<-size-1.0;
	//	if((size=0.0) or (age=AgeMax_H)){do HerbeEtreMort;}
	}
		reflex vivant{
		age<-age+1.0;
		//grandir
		if(size<SizeMax_H){size<-size+(1.0);}
		QteMange<-QteMange-1.0;
		tempsEnfant<-tempsEnfant+1;
		tempsSuppManger<-tempsSuppManger-1;
	}
	
}




experiment tutoriel4 type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
			display "Predateur et proie"type: opengl 
			{ 
				species Herbre aspect:basic;
				species Agneau aspect:basic;
				species Loup aspect:basic;
				
		}
	}
}