# watts
Useful Serverless Subsystems Living in the Stacks

## Usage

### Deploy a Stack

Deploy a stack via `make` using the directory name as the target, e.g.

```
make namespace=test lambda-s3
```

### Describe a Stack

Describe a stack via `make` by specifying the `action=describe`, again using the directory name as the target, e.g.

```
make namespace=test action=describe lambda-s3
```

### Delete a Stack

Delete a stack via `make` by specifying the `action=delete`, again using the directory name as the target, e.g.

```
make namespace=test action=describe lambda-s3
```


### Test a Stack

Test a stack with the associated `smoke.sh` script in each directory. Some scripts require the `namespace` as the first argument, e.g.

```
./lambda-s3/smoke.sh test  # <- test is the namespace used above
```
