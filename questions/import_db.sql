DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS questions_follow;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);


CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE questions_follow(
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  reply TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE table question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (1, 1),
  (2,1),
  (3,2);

INSERT INTO
  users (fname, lname)
VALUES
  ("Kevin", "Oo"),
  ("Kevin", "Yeeeeeeeeee"),
  ("Kevin", "Brennan"),
  ("Kevin", "Hart"),
  ("Kevin", "Love");

INSERT INTO
  questions (title, body, user_id)
VALUES
  ("what is 1 + 1", "shit what is it", 1),
  ("what is love", "what the shit is it", 5);

INSERT INTO
  questions_follow (user_id, question_id)
VALUES
  (1, 1),
  (2, 1),
  (3, 1),
  (4, 2);

INSERT INTO
  questions_follow (user_id, question_id)
VALUES
  (1, 1),
  (5, 2);

INSERT INTO
  replies (question_id, user_id, reply, parent_id)
VALUES
  (1, 2, "4", NULL),
  (1, 3, "Youre stupid it's 65", 1),
  (2, 4, "im kevin hart", NULL);

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (2,1),
  (1,2),
  (4,1);
