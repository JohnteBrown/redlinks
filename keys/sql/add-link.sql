INSERT INTO links (name, path)
VALUES ('__NAME__', '__PATH__')
ON CONFLICT(name) DO UPDATE SET path = excluded.path;
