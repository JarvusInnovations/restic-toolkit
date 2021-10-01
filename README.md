# restic-toolkit

A container image containing restic plus some other tools useful for backups in Kubernetes and other container environments

## Example usage

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  namespace: myapp-production
  name: myapp-backup
spec:
  schedule: 15 * * * *
  concurrencyPolicy: Forbid
  startingDeadlineSeconds: 86400 # one day
  jobTemplate:
    spec:
      activeDeadlineSeconds: 7200 # two hours
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: restic-toolkit
              image: 'ghcr.io/jarvusinnovations/restic-toolkit:1.0.0'
              imagePullPolicy: IfNotPresent
              envFrom:
                - secretRef:
                    name: restic-env
              env:
                - name: PGHOST
                  value: mydb
                - name: PGPORT
                  valueFrom:
                    secretKeyRef:
                      key: POSTGRES_PORT
                      name: postgres-production
                - name: PGDATABASE
                  valueFrom:
                    secretKeyRef:
                      key: POSTGRES_DB
                      name: postgres-production
                - name: PGUSER
                  valueFrom:
                    secretKeyRef:
                      key: POSTGRES_USER
                      name: postgres-production
                - name: PGPASSWORD
                  valueFrom:
                    secretKeyRef:
                      key: POSTGRES_PASSWORD
                      name: postgres-production
              command: ["/bin/bash", "-c"]
              args:
              - |

                  # snapshot current database
                  pg_dumpall --clean \
                  | gzip --rsyncable \
                  | restic backup \
                    --host myapp \
                    --stdin \
                    --stdin-filename database.sql.gz

                  # prune aged snapshots
                  restic forget \
                    --host myapp \
                    --keep-last 36 \
                    --keep-daily 7 \
                    --keep-weekly 52
```
