1. Export to csv from postgreSQL

    \copy (select * from vehicle_locations where location = 'twincities' and created_at > '2016-11-16') TO '~/tc_locs_since_nov_16_16_ex.csv' CSV HEADER

    \copy (select * from vehicle_locations where location = 'sandiego' and created_at > '2016-11-16') TO '~/sd_locs_since_nov_16_16_ex.csv' CSV HEADER

    \copy (select * from vehicle_locations where location = 'miami' and created_at > '2015-01-01') TO '~/miami_locs_since_jan_01_15_ex.csv' CSV HEADER

    \copy (select * from vehicle_locations where location like 'k%' and created_at > '2016-01-01') TO '~/k_locs_since_jan_01_01_ex.csv' CSV HEADER

    \copy (select * from vehicle_locations where location = 'stockholm' and created_at > '2016-11-01') TO '~/sh_locs_since_nov_01_16_ex.csv' CSV HEADER




1. Group by filename since created at is insertion time, not data time

    select count(*), date_trunc('day', created_at)
      from vehicle_locations
     where location = 'twincities' 
       and created_at > '2016-11-15'
    group by date_trunc('day', created_at)
    order by date_trunc('day', created_at);


    select count(*), substr(filename, 0, 20)
      from vehicle_locations
     where location = 'twincities' 
       and created_at > '2016-12-01'
    group by substr(filename, 0, 20)
    order by substr(filename, 0, 20);

    select count(*), filename
      from vehicle_locations
     where location = 'twincities' 
       and created_at > '2016-12-01'
    group by filename
    order by filename;