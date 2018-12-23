#!/bin/sh

set -eu

NOW=$(date +"%Y-%m-%d_%H%M%S")

# Dump filenames
FILENAME="${PGDATABASE}_${NOW}.dump"
MD5SUMFILENAME="${FILENAME}.md5sum"

# Globals filenames
GLOBALSFILENAME="globals_${NOW}.sql"
GLOBALSMD5SUMFILENAME="${GLOBALSFILENAME}.md5sum"

cat <<EOF
Start pg_dump:
  database  "$PGDATABASE"
  host:     "$PGHOST"
  port:     "$PGPORT"
  username: "$PGUSER"
  filename: "$FILENAME"
  path:     "$DUMPPATH"
  globals:  "$DUMPGLOBALS"
EOF

pg_dump --verbose -Fc -f "${DUMPPATH}/${FILENAME}"

echo "done (current time: $(date +"%Y-%m-%d_%H%M%S"))"

MD5SUM=$(md5sum "${DUMPPATH}/${FILENAME}")
echo "md5sum: ${MD5SUM}"

echo "writing md5sum file"
echo "$MD5SUM" > "${DUMPPATH}/${MD5SUMFILENAME}"

if [ "$DUMPGLOBALS" -eq 1 ]; then
    echo Dumping global database objects

    pg_dumpall -g -f "${DUMPPATH}/${GLOBALSFILENAME}"

    GLOBALSMD5SUM=$(md5sum "${DUMPPATH}/${GLOBALSFILENAME}")
    echo "globals md5sum: ${GLOBALSMD5SUM}"
    
    echo "writing globals md5sum file"
    echo "$GLOBALSMD5SUM" > "${DUMPPATH}/${GLOBALSMD5SUMFILENAME}"
fi

ls -lah "$DUMPPATH"
