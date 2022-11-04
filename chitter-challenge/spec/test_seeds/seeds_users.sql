TRUNCATE TABLE users RESTART IDENTITY CASCADE;
TRUNCATE TABLE peeps RESTART IDENTITY;

INSERT INTO users (name, email, password) VALUES ('Tom', 'tom@gmail.com', 'password123');
INSERT INTO users (name, email, password) VALUES ('Sarah', 'sarah@gmail.com', '!@£$%^456');

INSERT INTO peeps (message_content, time_created, user_id) VALUES ('Eating breakfast!', '2022-09-01 10:00:00', 1);
INSERT INTO peeps (message_content, time_created, user_id) VALUES ('Going on holiday!', '2022-09-10 06:00:00', 2);