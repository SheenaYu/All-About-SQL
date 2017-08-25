/*  The Report */
select (case b.grade<8 when true then NULL else a.name end), b.grade, a.marks
from students a
join grades b
on a.marks between b.min_mark and b.max_mark
order by b.grade desc, a.name, a.marks

/* Top Competitors */
select h.hacker_id, h.name
from submissions s
join hackers h on h.hacker_id = s.hacker_id
join challenges c on c.challenge_id = s.challenge_id
join difficulty d on d.difficulty_level = c.difficulty_level
where s.score = d.score
group by s.hacker_id, h.name
having count(s.challenge_id) > 1
order by count(s.challenge_id) desc, s.hacker_id

/* Ollivander's Inventory */
select w.id, p.age, w.coins_needed, w.power 
from Wands as w 
join Wands_Property as p 
on (w.code = p.code) 
where p.is_evil = 0 
  and w.coins_needed = (select min(coins_needed) 
                        from Wands as w1 
                        join Wands_Property as p1 
                        on (w1.code = p1.code) 
                        where w1.power = w.power and p1.age = p.age) 
order by w.power desc, p.age desc

