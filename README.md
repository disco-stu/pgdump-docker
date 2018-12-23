# Description

This repository contains the content to create a simple pgdump container image.

The container runs as postgres user and dumps one specific database. If DUMPGLOBALS=1 is set it also creates a globals only dump. A md5sum file is created for each dump or sql file.

*Caution*: No retention is applied.

# Usage

## Docker

The following example shows how to run this container using docker:

```
docker run -it --rm --name pgdump -e PGHOST=xxx.xxx.xxx.xxx -e PGUSER=dumpuser -e PGPASSWORD=dumpuserpass -e PGDATABASE=postgres -v $(pwd)/dumps:/dumps discostu42/pgdump:10
```

Adjust DUMPGLOBALS to create a additionally "globals" dump.

```
docker run -it --rm --name pgdump -e PGHOST=xxx.xxx.xxx.xxx -e PGUSER=dumpuser -e PGPASSWORD=dumpuserpass -e PGDATABASE=postgres -e DUMPGLOBALS=1 -v $(pwd)/dumps:/dumps discostu42/pgdump:10
```

## Kubernetes

The following example shows how to create a cronjob that uses this image. It also contains a PVC that is used within the crontab.

*Make sure to adjust required settings variables and storage requirements.*

```
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-dumps
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: rbd
  resources:
    requests:
      storage: 30Gi
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: pgdump
spec:
  schedule: "10 */4 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          securityContext:
            runAsUser: 999
            fsGroup: 999
          containers:
          - name: pgdump
            imagePullPolicy: Always
            image: discostu42/pgdump:10
            volumeMounts:
              - mountPath: "/dumps"
                name: dumps
            env:
              - name: PGUSER
			    value: dumpuser
              - name: PGPASSWORD
			    value: dumpuserpass
              - name: PGHOST
                value: postgresql-host
              - name: PGDATABASE
                value: mydatabase
          volumes:
            - name: dumps
              persistentVolumeClaim:
                claimName: database-dumps
          restartPolicy: OnFailure
```
