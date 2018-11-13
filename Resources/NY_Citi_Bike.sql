LOAD DATA INFILE '201305-citibike-tripdata.csv'
INTO TABLE citibike_tripdata_v2
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
tripduration,
starttime,
stoptime,
start_station_id,
start_station_name,
start_station_latitude,
start_station_longitude,
end_station_id,
end_station_name,
end_station_latitude,
end_station_longitude,
bike_id,
user_type,
@birth_year,
gender
)
SET birth_year = if(@birth_year="",null,@birth_year)
-- SET birth_year = if(@birth_year="NULL",null,@birth_year)
-- SET birth_year = if(@birth_year="\N",null,@birth_year)
;

select 
cast(substring_index(starttime,'-',1) as unsigned) as Year,
cast(substring_index(substring_index(starttime,'-',2),'-',-1) as unsigned) as Month,
count(*)

from citibike_dash_data where substring(starttime,1,4) in ('2013','2014','2015','2016')
group by
	cast(substring_index(starttime,'-',1) as unsigned),
	cast(substring_index(substring_index(starttime,'-',2),'-',-1) as unsigned)

union

(
select
cast(substring_index(substring_index(starttime,' ',1),'/',-1) as unsigned) as Year,
cast(substring_index(starttime,'/',1) as unsigned) as Month, 
count(*)

from citibike_slash_data where substring_index(substring_index(starttime,' ',1),'/',-1) in ('2013','2014','2015','2016')

group by
cast(substring_index(substring_index(starttime,' ',1),'/',-1) as unsigned),
cast(substring_index(starttime,'/',1) as unsigned)
);

select count(*) from citibike_tripdata;




	-- cast(substring_index(substring_index(starttime,' ',1),'/',-1) as unsigned),

-- select count(*) from citibike_tripdata_v2 where substring(starttime,1,4) = '2015';

-- select count(*) from citibike_tripdata_v2 where substring_index(substring_index(starttime,' ',1),'/',-1) = '2014';

-- select extract(year from cast(starttime as datetime)) as Year, extract(month from cast(starttime as datetime)) as Month, count(*) from citibike_tripdata_v2
-- group by extract(year from cast(starttime as datetime)), extract(month from cast(starttime as datetime));


-- select substring(starttime,1,4), count(*) from citibike_tripdata_v2
-- group by substring(starttime,1,4);

-- select extract(month from starttime) as start_month, count(*) from citibike_tripdata
-- where extract(year from starttime)=2016
-- group by extract(month from starttime);


-- delete from citibike_tripdata_v2 where substring(starttime,1,1)=6;

-- SHOW VARIABLES LIKE "secure_file_priv";


