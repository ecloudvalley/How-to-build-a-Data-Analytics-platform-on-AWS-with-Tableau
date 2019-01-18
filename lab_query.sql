create table rating_with_info with(
format='PARQUET',
external_location='s3://[your name]-athena-table/result/')
as (
select basics.*, averagerating, numvotes from basics
left join ratings
on basics.tconst = ratings.tconst where ratings.averagerating is not null and basics.startyear is not null)
