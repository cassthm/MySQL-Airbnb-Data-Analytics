use airbnb;

# host insert
load data infile 'listings.csv' ignore into table host fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n' ignore 1 lines 
(@C1,@C2,@C3,@C4,@C5,@C6,@C7,@C8,@C9,@C10,@C11,@C12,@C13,@C14,@C15)
set host_id=@c3,host_name=@c4;

# customer insert
load data infile 'reviews_summary.csv' ignore into table customer fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n' ignore 1 lines 
(@C1,@C2,@C3,@C4,@C5,@c6)
set cust_id=@c4,cust_name=@c5;

# property data insert
# property_id propertyx_name host_id neighbourhood room_type price min_nights
load data infile 'listings.csv' ignore into table property fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n' ignore 1 lines
(@C1,@C2,@C3,@C4,@C5,@C6,@C7,@C8,@C9,@C10,@C11,@C12,@C13,@C14,@C15)
set property_id=@c1,property_name=@c2, host_id=@c3,neighbourhood_group=@c5,room_type=@c9,price=@c10,min_nights=@c11;

# review insert
load data infile 'reviews_summary.csv' 
ignore into table review 
FIELDS TERMINATED BY ',' ESCAPED BY '' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@C1,@C2,@C3,@C4,@C5,@C6)
set reviewer_id=@c4,reviewer_name=@c5,listing_id=@c1,reviewer_comment=@c6,date=@c3;


#################################### queries ####################################
# 1.Average rental price of the properties by neighbourhood group, attached with the number of reviews
select h.host_id, h.host_name, p.neighbourhood_group, p.room_type,avg(p.price) AvgPrice from property p
join host h
where p.host_id = h.host_id
group by p.neighbourhood_group;

# 2.Properties that require least minimum nights of stay for reservation by neighbourhood group, and the greatest number of reviews
select p.property_id,p.property_name, p.neighbourhood_group, p.room_type, min(p.min_nights) minNights, num.numReview from property p
join (
	select listing_id, count(listing_id) numReview from review group by listing_id
) num
where num.listing_id = p.property_id
group by neighbourhood_group;

# 3.Top 10 properties that have the maximum price, attached with the customer reviews
select mp.property_id, mp.property_name, mp.price,r.reviewer_name,r.reviewer_comment from review r
right join (
select * from property order by price desc limit 10
) mp
on mp.property_id = r.listing_id;


# 4.Top 10 properties that have the minimum price, attached with the customer reviews
select mp.property_id, mp.property_name, mp.price,r.reviewer_name,r.reviewer_comment from review r
right join (
select * from property order by price asc limit 10
) mp
on mp.property_id = r.listing_id;

# Top 5 properties with the total number of reviews of the properties by the latest month in descending order
select f.listing_id, p.property_name, count(f.listing_id) reviewNum, f.date from (select * from review
where date_format(date, '%Y.%m') = (select date_format(date, '%Y.%m') month from review
order by date desc limit 1)) f
join property p
where p.property_id = f.listing_id
group by f.listing_id
limit 5;










