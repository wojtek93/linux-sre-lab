# KUB-13 Jobs and CronJobs

## Goal

Understand how Kubernetes Jobs and CronJobs work, how to inspect their Pods and logs, and how retry behavior works when a Job fails.

---

## Job

A Job is used for a task that should:

```text
start
↓
do some work
↓
finish
```

Unlike a Deployment, a Job is not expected to run forever.

---

## Job example

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-job

spec:
  template:
    spec:
      restartPolicy: Never

      containers:
        - name: hello
          image: busybox:latest
          command:
            - sh
            - -c
            - "echo Job started; sleep 3; echo Job finished"
```

---

## Job flow

```text
Job
↓
creates Pod
↓
Pod runs command
↓
command finishes
↓
Pod = Succeeded
↓
Job = Complete
```

---

## Apply Job

```bash
kubectl apply -f job.yaml
```

Check Job:

```bash
kubectl get jobs
```

Check Pod:

```bash
kubectl get pods
```

---

## Job logs

Logs can be read directly using the Job resource:

```bash
kubectl logs job/hello-job
```

Result:

```text
Job started
Job finished
```

---

## Successful Job

The Pod showed:

```text
Status: Succeeded
Reason: Completed
Exit Code: 0
```

Meaning:

```text
exit 0
=
successful command
```

---

## Deployment vs Job

```text
Deployment
= application should keep running

Job
= perform task and finish
```

---

## BusyBox

The lab used:

```text
busybox
```

BusyBox is a small Linux container image containing basic commands such as:

```text
sh
echo
sleep
cat
ls
date
```

It is useful for simple Kubernetes tests and short tasks.

---

# CronJob

A CronJob creates Jobs according to a schedule.

Conceptually:

```text
CronJob
↓
schedule
↓
Job
↓
Pod
↓
command
```

---

## CronJob example

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cronjob

spec:
  schedule: "*/1 * * * *"

  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never

          containers:
            - name: hello
              image: busybox:latest
              command:
                - sh
                - -c
                - 'echo "CronJob run at $(date)"'
```

---

## Schedule

```text
*/1 * * * *
```

means:

```text
run every minute
```

---

## Apply CronJob

```bash
kubectl apply -f cronjob.yaml
```

Check:

```bash
kubectl get cronjobs
```

Check generated Jobs:

```bash
kubectl get jobs
```

Check generated Pods:

```bash
kubectl get pods
```

---

## CronJob behavior

The CronJob created Jobs such as:

```text
hello-cronjob-29787457
hello-cronjob-29787458
hello-cronjob-29787459
```

Each Job created its own Pod.

---

## CronJob logs

Example:

```bash
kubectl logs job/hello-cronjob-29787458
```

Result:

```text
CronJob run at Thu Aug 20 17:38:01 UTC 2026
```

---

## Stop CronJob

Delete it:

```bash
kubectl delete cronjob hello-cronjob
```

This prevents new Jobs from being created.

---

## Suspend CronJob

CronJob can also be paused without deleting it:

```bash
kubectl patch cronjob hello-cronjob \
  -p '{"spec":{"suspend":true}}'
```

Resume:

```bash
kubectl patch cronjob hello-cronjob \
  -p '{"spec":{"suspend":false}}'
```

---

# Failed Job

A Job can retry when its Pod fails.

Example:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: failed-job

spec:
  backoffLimit: 2

  template:
    spec:
      restartPolicy: Never

      containers:
        - name: fail
          image: busybox:latest
          command:
            - sh
            - -c
            - "echo Job failing; exit 1"
```

---

## exit 1

The command:

```bash
exit 1
```

means the process finishes with an error.

Conceptually:

```text
exit 0
= success

exit non-zero
= failure
```

---

## backoffLimit

```yaml
backoffLimit: 2
```

controls how many retries the Job is allowed after failures.

In the lab the result was:

```text
0 Succeeded
3 Failed
```

This represents:

```text
initial attempt
+
2 retry attempts
```

---

## Failed Job flow

```text
Job
↓
creates Pod
↓
Pod runs command
↓
exit 1
↓
Pod fails
↓
Job retries
↓
another Pod fails
↓
retry limit reached
↓
Job = Failed
```

---

## Inspect failed Job

```bash
kubectl describe job failed-job
```

The output showed:

```text
Backoff Limit: 2
```

and:

```text
Job has reached the specified backoff limit
```

---

## Failure handling

A typical troubleshooting flow:

```text
Job not completing
↓
kubectl get jobs
↓
kubectl get pods
↓
kubectl describe job
↓
kubectl describe pod
↓
kubectl logs
```

---

## Useful commands

Create Job:

```bash
kubectl apply -f job.yaml
```

Check Jobs:

```bash
kubectl get jobs
```

Check Pods:

```bash
kubectl get pods
```

Read Job logs:

```bash
kubectl logs job/hello-job
```

Create CronJob:

```bash
kubectl apply -f cronjob.yaml
```

Check CronJobs:

```bash
kubectl get cronjobs
```

Delete CronJob:

```bash
kubectl delete cronjob hello-cronjob
```

Suspend CronJob:

```bash
kubectl patch cronjob hello-cronjob \
  -p '{"spec":{"suspend":true}}'
```

Create failed Job:

```bash
kubectl apply -f failed-job.yaml
```

Inspect failed Job:

```bash
kubectl describe job failed-job
```

---

## Key takeaways

```text
Job performs a one-time task

Job creates one or more Pods

successful Job finishes with Completed / Succeeded

CronJob creates Jobs according to a schedule

each CronJob execution creates a separate Job

Job logs can be read with kubectl logs job/<name>

exit 0 means success

non-zero exit code means failure

backoffLimit controls retry attempts

failed Jobs can create multiple failed Pods

CronJob can be deleted or suspended
```

---

## Mental model

Job:

```text
Job
↓
Pod
↓
task
↓
Completed
```

CronJob:

```text
CronJob
↓
schedule
↓
Job
↓
Pod
↓
task
↓
Completed
```

Failed Job:

```text
Job
↓
Pod
↓
failure
↓
retry
↓
backoffLimit
↓
Job Failed
```

---

## Interview summary

A Kubernetes Job is used to run a finite task that should complete successfully.

A CronJob creates Jobs according to a cron schedule.

Jobs create Pods to execute their workload, and successful Jobs finish once the required work is complete.

If a Job fails, Kubernetes can retry it. The `backoffLimit` controls how many retry attempts are allowed before the Job is marked as failed.
