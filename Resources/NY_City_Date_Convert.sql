-- Create ny_bike_trip_summary
/*
create table NY_Bike_Trip_Summary
(Year int(4), Month int(2), Day int(2), trip_minutes int(11),
 start_station_id int(11), start_station_name varchar(60), start_station_latitude float, start_station_longitude float,
 end_station_id int(11), end_station_name varchar(60), end_station_latitude float, end_station_longitude float,
 bike_id int(11), user_type varchar(45), birth_year int(11), gender varchar(10), trip_count int(11))

-- Add dash data to ny_bike_trip_summary
as select 
cast(substring_index(starttime,'-',1) as unsigned) as Year,
cast(substring_index(substring_index(starttime,'-',2),'-',-1) as unsigned) as Month,
cast(substring_index(substring_index(starttime,'-',-1),' ',1) as unsigned) as Day,
round(tripduration/60,0) as trip_minutes,
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
birth_year,
gender,
count(*) as trip_count

from citibike_dash_data

group by
cast(substring_index(starttime,'-',1) as unsigned),
cast(substring_index(substring_index(starttime,'-',2),'-',-1) as unsigned),
cast(substring_index(substring_index(starttime,'-',-1),' ',1) as unsigned),
round(tripduration/60,0),
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
birth_year,
gender
;

   
-- Add slash data to NY_Bike_Trip_Summmary table


insert into ny_bike_trip_summary

select 

cast(substring_index(substring_index(trim(starttime),' ',1),'/',-1) as unsigned) as Year,
cast(substring_index(trim(starttime),'/',1) as unsigned) as Month,
cast(substring_index(substring_index(trim(starttime),'/',2),'/',-1) as unsigned) as Day,
round(tripduration/60,0) as trip_minutes,
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
birth_year,
gender,
count(*) as trip_count

from citibike_slash_data

group by
cast(substring_index(substring_index(trim(starttime),' ',1),'/',-1) as unsigned),
cast(substring_index(trim(starttime),'/',1) as unsigned),
cast(substring_index(substring_index(trim(starttime),'/',2),'/',-1) as unsigned),
round(tripduration/60,0),
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
birth_year,
gender
;

insert into ny_bike_trip_summary

select 

cast(extract(year from starttime) as unsigned) as Year,
cast(extract(month from starttime) as unsigned) as Month,
cast(extract(day from starttime) as unsigned) as Day,
round(tripduration/60,0) as trip_minutes,
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
birth_year,
gender,
count(*) as trip_count

from citibike_tripdata

group by
cast(extract(year from starttime) as unsigned),
cast(extract(month from starttime) as unsigned),
cast(extract(day from starttime) as unsigned),
round(tripduration/60,0),
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
birth_year,
gender;
*/

-- Create hourly_bike_station_activity table
/*
create table hourly_bike_station_activity_incl_season
(hour int(2), season varchar(32), station_id int(11), station_name varchar(64), station_latitude float, station_longitude float, start_end varchar(10), trip_count int(11))
as select
case when extract(month from starttime) in (1, 2) then 'Winter'
	 when extract(month from starttime) in (6, 7, 8) then 'Summer'
     when extract(month from starttime) in (3, 4, 5) then 'Spring'
     else 'Fall' end as season,
extract(hour from starttime)as hour,
start_station_id as station_id,
start_station_name as station_name,
start_station_latitude as station_latitude,
start_station_longitude as station_longitude,
"start" as start_end,
count(*) as trip_count
from citibike_tripdata where extract(year from starttime)=2018
group by
case when extract(month from starttime) in (1, 2) then 'Winter'
	 when extract(month from starttime) in (6, 7, 8) then 'Summer'
     when extract(month from starttime) in (3, 4, 5) then 'Spring'
     else 'Fall' end,
extract(hour from starttime),
start_station_id,
start_station_name,
start_station_latitude,
start_station_longitude;
*/

/*
insert into hourly_bike_station_activity
select
extract(hour from stoptime)as hour,
end_station_id as station_id,
end_station_name as station_name,
end_station_latitude as station_latitude,
end_station_longitude as station_longitude,
"end" as start_end,
count(*) as trip_count
from citibike_tripdata where extract(year from stoptime)=2018
group by
extract(hour from stoptime),
end_station_id,
end_station_name,
end_station_latitude,
end_station_longitude;
*/

-- Add station_distance in miles to ny_bike_trip_summmary
/*
create table station_distance
(start_station_id int(11), start_station_name varchar(60), start_station_latitude float, start_station_longitude float,
 end_station_id int(11), end_station_name varchar(60), end_station_latitude float, end_station_longitude float)
as select
start_station_id, start_station_name, start_station_latitude, start_station_longitude, end_station_id, end_station_name, end_station_latitude, end_station_longitude
from ny_bike_trip_summary
group by
start_station_id, start_station_name, start_station_latitude, start_station_longitude, end_station_id, end_station_name, end_station_latitude, end_station_longitude;

alter table ny_bike_trip_summary
add column station_dist_miles float;

update ny_bike_trip_summary
set station_dist_miles = (3959*acos(cos(radians(90 - start_station_latitude))*cos(radians(90 - end_station_latitude))+sin(radians(90 - start_station_latitude))*sin(radians(90 - end_station_latitude))*cos(radians(start_station_longitude - end_station_longitude))))
;

select * from ny_bike_trip_summary limit 100;
*/

-- Create bike_id_time_series table
/*
create table bike_id_time_series
(Year int(4), Month int(2), bike_id int(11), trip_count int(11), bike_mileage float)
as select
Year, Month, bike_id, sum(trip_count) as trip_count, sum(station_dist_miles) as bike_mileage
from ny_bike_trip_summary
group by Year, Month, bike_id;

alter table bike_id_time_series
add column YYYY_MM varchar(10);

update bike_id_time_series
set YYYY_MM = concat(Year,"_",Month);

create table bike_fleet
(bike_id int(11), start_date varchar(10), last_date varchar(10), service_months int(11), trip_count int(11), bike_mileage int(11))
as select
bike_id,
min(YYYY_MM) as start_date,
max(YYYY_MM) as last_date,
((cast(left(max(YYYY_MM),4) as signed) - cast(left(min(YYYY_MM),4) as signed))*12) +
 (cast(substring_index(max(YYYY_MM),'_',-1) as signed) - cast(substring_index(min(YYYY_MM),'_',-1) as signed)) as service_months,
sum(trip_count) as trip_count,
sum(bike_mileage) as bike_mileage
from bike_id_time_series
group by bike_id;

select * from bike_fleet order by bike_mileage desc;
*/

-- Create NY_bike_program_series table

create table ny_bike_program_time_series_incl_user_type
(Year int(4), Month int(2), YYYY_MM varchar(10), user_type varchar(45), gender varchar(10), station_count int(11), bike_count int(11), trip_count int(11), trip_miles float, trip_minutes int(11))
as select 
Year,
Month,
concat(Year,"_",Month) as YYYY_MM,
user_type,
left(trim(gender),1)as gender,
count(distinct start_station_id)as station_count,
count(distinct bike_id) as bike_count,
sum(trip_count) as trip_count,
sum(station_dist_miles) as trip_miles,
sum(trip_minutes) as trip_minutes
from ny_bike_trip_summary
group by
Year,
Month,
user_type,
left(trim(gender),1)
;

select count(*) from ny_bike_program_time_series_incl_user_type;
*/

-- Create NY_bike_station_series table
/*
create table ny_bike_station_time_series
(Year int(4), Month int(2), YYYY_MM varchar(10), start_station_id int(11), start_station_name varchar(60), start_station_latitude float, start_station_longitude float, trip_count int(11))
as select 
Year,
Month,
concat(Year,"_",Month) as YYYY_MM,
start_station_id,
start_station_name,
start_station_latitude,
start_station_longitude,
sum(trip_count) as trip_count
from ny_bike_trip_summary
group by
Year,
Month,
concat(Year,"_",Month),
start_station_id,
start_station_name,
start_station_latitude,
start_station_longitude;

select count(*) from ny_bike_station_time_series;
*/

create table ny_bike_program_station_time_series
(Year int(4), Month int(2), YYYY_MM varchar(10), start_station_id int(11), start_station_name varchar(60),
start_station_latitude float, start_station_longitude float, station_trip_count int(11),
station_count int(11), bike_count int(11), trip_count int(11), trip_miles float, trip_minutes int(11))
as select 
ts1.Year,
ts1.Month,
ts1.YYYY_MM,
ts1.start_station_id,
ts1.start_station_name,
ts1.start_station_latitude,
ts1.start_station_longitude,
ts1.trip_count as station_trip_count,
ts2.station_count,
ts2.bike_count,
ts2.trip_count,
ts2.trip_miles,
ts2.trip_minutes

from ny_bike_station_time_series ts1
left join
ny_bike_program_time_series ts2
on ts1.YYYY_MM = ts2.YYYY_MM
group by
ts1.Year,
ts1.Month,
ts1.YYYY_MM,
ts1.start_station_id,
ts1.start_station_name,
ts1.start_station_latitude,
ts1.start_station_longitude;

create table Sep_2018_Bike_Data
as select * from ny_bike_trip_summary
where Year = 2018 and Month = 9;


