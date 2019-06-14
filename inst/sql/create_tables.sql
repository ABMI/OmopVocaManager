CREATE TABLE @schema_name.[CONCEPT](
	[concept_id] [varchar](50) NULL,
	[concept_name] [varchar](500) NULL,
	[domain_id] [varchar](50) NULL,
	[vocabulary_id] [varchar](50) NULL,
	[concept_class_id] [varchar](50) NULL,
	[standard_concept] [varchar](50) NULL,
	[concept_code] [varchar](50) NULL,
	[valid_start_date] [date] NULL,
	[valid_end_date] [date] NULL,
	[invalid_reason] [varchar](50) NULL
);

CREATE TABLE @schema_name.[CONCEPT_ANCESTOR](
	[ancestor_concept_id] [varchar](50) NULL,
	[descendant_concept_id] [varchar](50) NULL,
	[min_levels_of_separation] [varchar](50) NULL,
	[max_levels_of_separation] [varchar](50) NULL
);

CREATE TABLE @schema_name.[CONCEPT_CLASS](
	[concept_class_id] [varchar](50) NULL,
	[concept_class_name] [varchar](500) NULL,
	[concept_class_concept_id] [varchar](50) NULL
);

CREATE TABLE @schema_name.[CONCEPT_RELATIONSHIP](
	[concept_id_1] [varchar](50) NULL,
	[concept_id_2] [varchar](50) NULL,
	[relationship_id] [varchar](50) NULL,
	[valid_start_date] [varchar](50) NULL,
	[valid_end_date] [varchar](50) NULL,
	[invalid_reason] [varchar](50) NULL
);

CREATE TABLE @schema_name.[CONCEPT_SYNONYM](
	[concept_id] [varchar](50) NULL,
	[concept_synonym_name] [nvarchar](1000) NULL,
	[language_concept_id] [varchar](50) NULL
);

CREATE TABLE @schema_name.[DOMAIN](
	[domain_id] [varchar](50) NULL,
	[domain_name] [varchar](500) NULL,
	[domain_concept_id] [varchar](50) NULL
);

CREATE TABLE @schema_name.[DRUG_STRENGTH](
	[drug_concept_id] [varchar](50) NULL,
	[ingredient_concept_id] [varchar](50) NULL,
	[amount_value] [varchar](50) NULL,
	[amount_unit_concept_id] [varchar](50) NULL,
	[numerator_value] [varchar](50) NULL,
	[numerator_unit_concept_id] [varchar](50) NULL,
	[denominator_value] [varchar](50) NULL,
	[denominator_unit_concept_id] [varchar](50) NULL,
	[box_size] [varchar](50) NULL,
	[valid_start_date] [varchar](50) NULL,
	[valid_end_date] [varchar](50) NULL,
	[invalid_reason] [varchar](50) NULL
);

CREATE TABLE @schema_name.[RELATIONSHIP](
	[relationship_id] [varchar](50) NULL,
	[relationship_name] [varchar](500) NULL,
	[is_hierarchical] [varchar](50) NULL,
	[defines_ancestry] [varchar](50) NULL,
	[reverse_relationship_id] [varchar](50) NULL,
	[relationship_concept_id] [varchar](50) NULL
);

CREATE TABLE @schema_name.[VOCABULARY](
	[vocabulary_id] [varchar](50) NULL,
	[vocabulary_name] [varchar](500) NULL,
	[vocabulary_reference] [varchar](500) NULL,
	[vocabulary_version] [varchar](500) NULL,
	[vocabulary_concept_id] [varchar](50) NULL
);


