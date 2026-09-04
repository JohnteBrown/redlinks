Red [
    Title: "SQLite storage smoke test"
]

; Expect the database and SQL command directory to exist before the migration is considered complete.
db-file: %../keys/keys.sqlite3
sql-dir: %../keys/sql

if not exists? to-file db-file [
    print ["Missing database:" db-file]
    quit 1
]

if not exists? to-file sql-dir [
    print ["Missing SQL directory:" sql-dir]
    quit 1
]

print "SQLite storage test passed"
