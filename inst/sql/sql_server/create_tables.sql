{@dropIfExists}?{
	IF OBJECT_ID('@vocabularyDatabaseSchema.concept', 'U') IS NOT NULL
    	        DROP TABLE @vocabularyDatabaseSchema.concept;
	IF OBJECT_ID('@vocabularyDatabaseSchema.vocabulary', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.vocabulary;
	IF OBJECT_ID('@vocabularyDatabaseSchema.domain', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.domain;
	IF OBJECT_ID('@vocabularyDatabaseSchema.concept_class', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.concept_class;
	IF OBJECT_ID('@vocabularyDatabaseSchema.concept_relationship', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.concept_relationship;
	IF OBJECT_ID('@vocabularyDatabaseSchema.relationship', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.relationship;
	IF OBJECT_ID('@vocabularyDatabaseSchema.concept_synonym', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.concept_synonym;
	IF OBJECT_ID('@vocabularyDatabaseSchema.concept_ancestor', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.concept_ancestor;
	IF OBJECT_ID('@vocabularyDatabaseSchema.drug_strength', 'U') IS NOT NULL
					DROP TABLE @vocabularyDatabaseSchema.drug_strength;
}
		CREATE TABLE @vocabularyDatabaseSchema.concept (
		  concept_id			    INTEGER			NOT NULL ,
		  concept_name			  	VARCHAR(255)	NOT NULL ,
		  domain_id				    VARCHAR(20)		NOT NULL ,
		  vocabulary_id			  	VARCHAR(20)		NOT NULL ,
		  concept_class_id			VARCHAR(20)		NOT NULL ,
		  standard_concept			VARCHAR(1)		NULL ,
		  concept_code			  	VARCHAR(50)		NOT NULL ,
		  valid_start_date			DATE			NOT NULL ,
		  valid_end_date		  	DATE			NOT NULL ,
		  invalid_reason		  	VARCHAR(1)		NULL
		);

		CREATE TABLE @vocabularyDatabaseSchema.vocabulary (
		  vocabulary_id			    VARCHAR(20)		NOT NULL,
		  vocabulary_name		    VARCHAR(255)	NOT NULL,
		  vocabulary_reference		VARCHAR(255)	NOT NULL,
		  vocabulary_version	  	VARCHAR(255)	NULL,
		  vocabulary_concept_id		INTEGER			NOT NULL
		);

		CREATE TABLE @vocabularyDatabaseSchema.domain (
		  domain_id			    VARCHAR(20)		NOT NULL,
		  domain_name		    VARCHAR(255)	NOT NULL,
		  domain_concept_id		INTEGER			NOT NULL
		);

		CREATE TABLE @vocabularyDatabaseSchema.concept_class (
		  concept_class_id			    VARCHAR(20)		NOT NULL,
		  concept_class_name		    VARCHAR(255)	NOT NULL,
		  concept_class_concept_id		INTEGER			NOT NULL
		);

		CREATE TABLE @vocabularyDatabaseSchema.concept_relationship (
		  concept_id_1			INTEGER			NOT NULL,
		  concept_id_2			INTEGER			NOT NULL,
		  relationship_id		VARCHAR(20)		NOT NULL,
		  valid_start_date		DATE			NOT NULL,
		  valid_end_date		DATE			NOT NULL,
		  invalid_reason		VARCHAR(1)		NULL
		  );

		CREATE TABLE @vocabularyDatabaseSchema.relationship (
		  relationship_id			VARCHAR(20)		NOT NULL,
		  relationship_name			VARCHAR(255)	NOT NULL,
		  is_hierarchical			VARCHAR(1)		NOT NULL,
		  defines_ancestry			VARCHAR(1)		NOT NULL,
		  reverse_relationship_id	VARCHAR(20)		NOT NULL,
		  relationship_concept_id	INTEGER			NOT NULL
		);

		CREATE TABLE @vocabularyDatabaseSchema.concept_synonym (
		  concept_id			  INTEGER		NOT NULL,
		  concept_synonym_name	  VARCHAR(1000)	NOT NULL,
		  language_concept_id	  INTEGER		NOT NULL
		);

		CREATE TABLE @vocabularyDatabaseSchema.concept_ancestor (
		  ancestor_concept_id		    INTEGER		NOT NULL,
		  descendant_concept_id		  	INTEGER		NOT NULL,
		  min_levels_of_separation		INTEGER		NOT NULL,
		  max_levels_of_separation		INTEGER		NOT NULL
		);

		CREATE TABLE @vocabularyDatabaseSchema.drug_strength (
		  drug_concept_id				INTEGER		  NOT NULL,
		  ingredient_concept_id			INTEGER		  NOT NULL,
		  amount_value					FLOAT		  NULL,
		  amount_unit_concept_id		INTEGER		  NULL,
		  numerator_value				FLOAT		  NULL,
		  numerator_unit_concept_id		INTEGER		  NULL,
		  denominator_value				FLOAT		  NULL,
		  denominator_unit_concept_id	INTEGER		  NULL,
		  box_size						INTEGER		  NULL,
		  valid_start_date				DATE		  NOT NULL,
		  valid_end_date				DATE		  NOT NULL,
		  invalid_reason				VARCHAR(1) 	  NULL
		);