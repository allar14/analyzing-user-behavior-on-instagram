--Find 5 oldest users.
select id, username,created_at 
from users
order by created_at
limit 5;

--We need to figure out when to schedule an ad campgain
--What day of the week do most users register on? 
SELECT DAYNAME(created_at) as week_day, count(DAYNAME(created_at)) as q_ty
from users
GROUP by week_day
order by week_day;

--We want to target our inactive users with an email campaign. 
--Find the users who have never posted a photo.
select u.username
from users u
where u.id not in(select p.user_id from photos p);

--We're running a new contest to see who can get the most likes on a single photo. 
--Who won?
select u.username,p.id,p.image_url, li.Total_Likes
from photos p
join users u on p.user_id = u.id
join (select photo_id, count(*) Total_Likes from likes group by photo_id) li on p.id = li.photo_id
order by  li.Total_Likes DESC
limit 1;

--Our Investors want to know...How many times does the average user post?
select ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2) as avg_user_post

--User ranking by postings higher to lower
select u.username,count(p.image_url) as total
from users u
join photos p on u.id=p.user_id
group by u.username,u.id
order by total desc;

--Total Posts by users
SELECT COUNT(*)as total_posts
FROM photos

--Total numbers of users who have posted at least one time
select count(distinct user_id) as  total_number_of_users_with_posts
from photos

-- What are the top 5 most commonly used hashtags?
SELECT t.tag_name, count(p.tag_id)as total
from photo_tags p
join tags t on t.id = p.tag_id
group by t.tag_name
order by total desc
limit 5;

--We have a small problem with bots on our site. 
--Find users who have liked every single photo on the site.
SELECT u.id, u.username,count(l.photo_id)as total_likes_by_user
from users u
join likes l on u.id = l.user_id
group by u.id, u.username
having count(l.photo_id) =(select count(distinct photo_id) from likes)

--We also have a problem with celebrities. 
--Find users who have never commented on a photo.
SELECT username,(select comment_text from comments where created_at is null) comment_text
from users
where id not IN (select user_id from comments)

--Are we overrun with bots and celebrity accounts? 
--Find the percentage of our users who have either 
--never commented on a photo or have commented on every photo.
with
tab1 as (select count(user_1) as user_no_comment from (select u.username as user_1, c.comment_text from users u
left join comments c on u.id = c.user_id
where c.comment_text is null) t),
tab2 as (select count(user_2) as user_all from (select u.id, u.username as user_2, t.total_likes_by_user from users u
join
(select user_id, count(*) as total_likes_by_user from likes
group by user_id
order by count(*) desc) t on u.id = t.user_id
where total_likes_by_user = (select count(*) from photos)
order by u.id) t2)
select user_no_comment, user_all*100/(select count(*) from users) as percentage, user_all from tab1, tab2

--Find users who have ever commented on a photo.
select  u.username, c.comment_text
from users u
join 
(SELECT id, photo_id, comment_text, user_id 
FROM comments
WHERE id IN (
    SELECT MAX(id)
    FROM comments
    GROUP BY user_id ))as c on c.user_id = u.id
     
--Find the percentage of our users who have either never commented on a photo 
--or have commented on photos before.

with
tab1 as (select count(user_1) as user_no_comment from (select u.username as user_1, c.comment_text from users u
left join comments c on u.id = c.user_id
where c.comment_text is null) t),
tab2 as (select count(user_2) as user_with_comment from (select u.id, u.username as user_2, t.total_comments_by_user from users u
join
(select user_id, count(*) as total_comments_by_user from comments
group by user_id
order by count(*) desc)t on u.id = t.user_id
where total_comments_by_user > 1
order by u.id) t2)
select user_no_comment, user_with_comment*100/(select count(*) from users) as percentage, user_with_comment from tab1, tab2


