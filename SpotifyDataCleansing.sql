-- Spotify Data Cleansing --

SELECT *
FROM Spotify.dbo.Spotify2021


-- Changing data type of date column from nvarchar(255) to date --

ALTER TABLE Spotify.dbo.Spotify2021
ALTER COLUMN release_date DATE;

-- Standardizing album names

SELECT DISTINCT(album_name)
FROM Spotify.dbo.Spotify2021

SELECT album_name,
CASE WHEN album_name = 'evermore (deluxe version)' THEN 'evermore'
	ELSE album_name
	END
FROM Spotify.dbo.Spotify2021

UPDATE Spotify2021
SET album_name = CASE WHEN album_name = 'evermore (deluxe version)' THEN 'evermore'
	ELSE album_name
	END


-- Simplifying genres and creating dummy variables

-- Removing brackets and quotation marks from genre list
SELECT DISTINCT(artist_name),
REPLACE(SUBSTRING(artist_genres, 2, LEN(artist_genres)-2), '''', '')
FROM Spotify.dbo.Spotify2021

-- There are many specific genres, so I will add broader genre encodings

SELECT DISTINCT(artist_name),
CASE WHEN artist_genres LIKE '%emo%' THEN '1'
	ELSE 0
	END
	AS emo,
CASE WHEN artist_genres LIKE '%punk%' THEN '1'
	ELSE 0
	END
	AS punk,
CASE WHEN artist_genres LIKE '%indie%' THEN '1'
	ELSE 0
	END
	AS indie,
CASE WHEN artist_genres LIKE '%rock%' THEN '1'
	ELSE 0
	END
	AS rock,
CASE WHEN artist_genres LIKE '%grunge%' THEN '1'
	ELSE 0
	END
	AS grunge,
CASE WHEN artist_genres LIKE '%alternative%' THEN '1'
	ELSE 0
	END
	AS alternative,
CASE WHEN artist_genres LIKE '%core%' THEN '1'
	ELSE 0
	END
	AS metal,
CASE WHEN artist_genres LIKE '%pop%' THEN '1'
	ELSE 0
	END
	AS pop
FROM Spotify.dbo.Spotify2021

ALTER TABLE Spotify.dbo.Spotify2021
ADD emo int,
punk int,
indie int,
rock int,
grunge int,
alternative int,
metal int,
pop int;

UPDATE Spotify2021
SET emo = CASE WHEN artist_genres LIKE '%emo%' THEN '1'
	ELSE 0
	END,
	punk = CASE WHEN artist_genres LIKE '%punk%' THEN '1'
	ELSE 0
	END,
	indie = CASE WHEN artist_genres LIKE '%indie%' THEN '1'
	ELSE 0
	END,
	rock = CASE WHEN artist_genres LIKE '%rock%' THEN '1'
	ELSE 0
	END,
	grunge = CASE WHEN artist_genres LIKE '%grunge%' THEN '1'
	ELSE 0
	END,
	alternative = CASE WHEN artist_genres LIKE '%alternative%' THEN '1'
	ELSE 0
	END,
	metal = CASE WHEN artist_genres LIKE '%core%' THEN '1'
	ELSE 0
	END,
	pop = CASE WHEN artist_genres LIKE '%pop%' THEN '1'
	ELSE 0
	END