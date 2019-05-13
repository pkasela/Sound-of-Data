# numbers of CPU core of the machine, default is 4
#core=4
#By Default it will take the maximum amount of available processors.
#main database folder is in /var/lib/neo4j/data/databases/
cd ../demo_results/results
neo4j-import --into SoundofData.db --nodes artist.tsv --nodes release.tsv --nodes track.tsv --nodes label.tsv --relationships release_label.tsv --delimiter="\t" --quote="\""

#or use neo4j-admin it should inport in the altready existing db
#sudo neo4j-admin import --nodes artist.tsv --nodes=release.tsv --nodes=track.tsv --nodes=label.tsv --relationships=release_label.tsv --delimiter="\t" --quote="\""

#sudo cp Sound-of-Data.db /var/lib/neo4j/data/databases/
#sudo mv SoundofData.db /var/lib/neo4j/data/databases/
# so, it seems too easy but it is not: we have to change the tsv
# structure to fit this script, it is not so easy but we have to do
# it.
# What does change: everything, so I just write a simple structure of
# how files have to be constructed to be insered in the graph:
# (fill free to modify the structure, but first and last columns of
# nodes table must be nodes'id and nodes'type
#                              (first:last {prop1, prop2...})
#
#
#
# SELECT id, gid, name, gender, type, "Artist" AS ":LABEL" FROM artist
#
# artist.tsv (id, gid, name, gender, type, :LABEL)
# artist.id        <-- node's ID
# artist.gid       <-- here the attributes do start
# artist.name
# artist.gender
# artist.type      <-- here the attributes do end (@Question do we need it?)
# "Artist"         <-- a column just composed by the string "Artist"
#
#
#
# SELECT id, gid, name, language, "Release" AS ":LABEL" FROM release
#
# release.tsv (id, gid, name, language, :LABEL)
# release.id
# release.gid
# release.name
# release.language
# "Release"
#
#
#
# SELECT id, gid, name, length, "Track" AS ":LABEL" FROM track
#
# track.tsv (id, gid, name, lenght, :LABEL)
# track.id
# track.gid
# track.name
# track.lenght
# "Track"
#
#
#
# SELECT id, gid, name, "LABEL" as ":LABEL" FROM label
#
# label.tsv (id, gid, name, type, :LABEL)
# label.id
# label.gid
# label.name
# label.type (è type_name rinominato)
# :LABEL           <-- a column of, ironically, "Label"
#
#
#
# SELECT artist_credit_name.artist AS ":START_ID",
#        release.id AS ":END_ID",
#        "RELEASED" AS ":TYPE",
#   FROM artist_credit_name
#   JOIN release USING (artist_credit)
#
# artist_release.tsv (:START_ID, :END_ID, :TYPE)
# artist.id        <-- start point, I suggest artist.id
# release.id       <-- end point, release.id
# "RELEASED"       <-- the name of the relationship: "RELEASED" (?)
#    ^- As I mentioned above if you don't know how to name something
#        thou ought to call it ``Banana''.
#
#
#
# SELECT release.id AS ":START_ID",
#        track.number AS "number",
#        track.id AS ":END_ID",
#        "CONTAINS" AS ":TYPE"
#   FROM release
#   JOIN track USING (artist_credit)
#     ^- This one is a triple JOIN, No it's not I'm triple Stupid
#
# release_track.tsv (:START_ID, number, :END_ID, :TYPE)
#
# release.id
# track.number
# track.id
# "CONTAINS"
#
#
#
# SELECT release AS ":START_ID",
#        label AS ":END_ID",
#        "SPONSORED_BY" AS ":TYPE"
#   FROM release_label
#
# release_label (:START_ID, :END_ID, :TYPE)
#
# release.id
# label.id
# "SPONSORED_BY"
