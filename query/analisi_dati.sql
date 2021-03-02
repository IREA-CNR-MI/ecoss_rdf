-- non tutte le specie in n2k hanno corrispettivo in eunis
SELECT SITECODE, SPECIESCODE, SPECIESNAME FROM "species_n2k_2019" WHERE SPECIESCODE NOT IN (SELECT DISTINCT "n2000code:text" FROM species_n2k_eunis)--INNER JOIN species_n2k_eunis ON "spn2k_2_speunis.n2000code:text"= spcode_n2k

-- non tutte le specie in n2k hanno corrispettivo in eunisSELECT COUNT(DISTINCT SPECIESCODE) FROM "species_n2k_2019" WHERE SPECIESCODE NOT IN (SELECT DISTINCT "n2000code:text" FROM species_n2k_eunis) -- -> 141 specie senza url eunis


--ESTRARRE LEGAME TRA SITI E SPECIESELECT SITECODE, SPECIESCODE AS speciesCodeN2K, SPECIESNAME AS speciesNameN2K, "eunisurl:url" AS speciesUrlEunis, "name:text" AS speciesNameEunis, "authority:text" AS speciesAuthorityEunis FROM "species_n2k_2019" LEFT JOIN species_n2k_eunis ON "n2000code:text"= SPECIESCODE

-- ESTRARRE legame tra sito e habitat. Habitat code di 2 tipi: n2k e direttiva habitats (da scrape sito web)


-- NORMALIZZAZIONE
-- Estrarre elenco siti n2K
CREATE TABLE sites AS
SELECT DISTINCT sitecode FROM species_n2k_2019;

-- estrarre legame siti-specie (1 sito -> molte specie)
CREATE TABLE sites_species AS
SELECT sitecode, speciescode AS speciesCodeN2K FROM species_n2k_2019;

CREATE TABLE  species AS
-- estrarre lista univoca specie (con i 2 ID, nome scientifico, autoritÃ )
SELECT DISTINCT speciesCodeN2K, speciesNameN2K, speciesUrlEunis, speciesNameEunis, speciesAuthorityEunis FROM speciesN2K_2_speciesEunis;
 
CREATE TABLE sites_habitats AS
-- estrarre legame siti-habitat
SELECT DISTINCT HABITATCODE AS habitatcode, SITECODE AS sitecode FROM habitats_n2k_2019;


CREATE TABLE  habitat_landingpage AS
-- ottenere landing page per habitat (da gerarchia sito web via scraping:
SELECT Code_HabitatAnnexI AS habitatcode, LandigPage_EunisEEAHabitat AS landingPage FROM HabitatAnnexI_vs_EunisLandingPage;
	-- https://eunis.eea.europa.eu/habitats-annex1-browser.jsp?expand=all,10001,10002,10011,10017,10022,10026,10030,10036,10037,10048,10056,10061,10062,10071,10081,10260,10091,10092,10097,10101,10105,10109,10110,10119,10128,10130,10136,10140,10141,10148,10153,10156,10157,10164,10169,10174,10175,10184,10204,10218,10227,10231#level_10231
-- )

-------------------
-- creare triple --
-------------------
-- sito a n2ksite; 
--      has_habitat habitat1, habitat2, ..., habitatN;
--		has_species species1, species2, ..., ..., speciesM;
-- habitat1 a habitatAnnex1_habitat;
--		webpage landingpage
-- species1 a species;
--		scientificName speciesNameEunis;
--		authority speciesAuthorityEunis;
--		webpage	speciesUrlEunis
