ipl_analysis.sql 

-- IPL DATA ANALYSIS PROJECT
-- Author: Vardhan Gundu
-- Tools Used: MySQL, Python, Power BI
-- This script contains table creation, analysis queries, and views.

    
create database ipl_analysis;
use ipl_analysis;

create table Matches (
id int primary key,
season int,
city varchar(50),
date DATE,
match_type varchar(20),
player_of_match varchar(100),
venue VARCHAR(100),
    team1 VARCHAR(100),
    team2 VARCHAR(100),
    toss_winner VARCHAR(100),
    toss_decision VARCHAR(20),
    winner VARCHAR(100),
    result VARCHAR(20),
    result_margin INT,
    target_runs INT,
    target_overs FLOAT,
    super_over VARCHAR(10),
    method VARCHAR(20),
    umpire1 VARCHAR(100),
    umpire2 VARCHAR(100)
);

CREATE TABLE deliveries (
    match_id INT,
    inning INT,
    batting_team VARCHAR(100),
    bowling_team VARCHAR(100),
    overr INT,
    ball INT,
    batter VARCHAR(100),
    bowler VARCHAR(100),
    non_striker VARCHAR(100),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    extras_type VARCHAR(50),
    is_wicket INT,
    player_dismissed VARCHAR(100),
    dismissal_kind VARCHAR(50),
    fielder VARCHAR(100)
);

select * from Matches;

select * from deliveries;

select * from matches;

select count(*) from matches;
select count(*) from deliveries;

/* Total Matches Won by Each Team /*
SELECT winner, COUNT(*) AS total_wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY total_wins DESC
limit 10;

/* Toss Impact Analysis */
SELECT toss_decision,
       COUNT(*) AS matches,
       SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS toss_win_match_win
FROM matches
GROUP BY toss_decision;

/*  Best Batters (Total Runs)    /*

select batter, sum(batsman_runs)  as total_runs
from deliveries
group by batter
order by total_runs desc
limit 10;


/* Best Bowlers (Most Wickets */
select bowler, count(*) as total_wickts
from deliveries
where is_wicket = 1
and dismissal_kind not in ('run out')
group by bowler
order by total_wickts desc
limit 10; 

/* Best Venue for Batting   /*

select venue, avg(total_score) as av_runs
from (
      select m.id, m.venue, sum(d.total_runs) as total_score
      from matches m
      join deliveries d
      on m.id = d.match_id
      group by m.id, m.venue
      ) t 
group by venue 
order by av_runs desc;


create index idx_match_id on deliveries(match_id);


CREATE VIEW match_totals AS
SELECT m.id,
       m.season,
       m.venue,
       SUM(d.total_runs) AS total_runs
FROM matches m
JOIN deliveries d
ON m.id = d.match_id
GROUP BY m.id, m.season, m.venue;

CREATE VIEW player_batting_stats AS
SELECT batter,
       SUM(batsman_runs) AS total_runs,
       COUNT(ball) AS balls_played
FROM deliveries
GROUP BY batter;

CREATE VIEW player_bowling_stats AS
SELECT bowler,
       COUNT(CASE 
             WHEN is_wicket = 1 
             AND dismissal_kind NOT IN ('run out') 
             THEN 1 END) AS wickets,
       SUM(total_runs) AS runs_conceded,
       COUNT(ball) AS balls_bowled
FROM deliveries
GROUP BY bowler;

