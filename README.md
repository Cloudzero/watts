![Watts](https://github.com/Cloudzero/watts/watts.png)

# watts
Useful Serverless Subsystems Living in the Stacks

Though AWS provides many example CloudFormation and [SAM Templates](https://github.com/awslabs/serverless-application-model), 
I often find myself [scrabbling in Stack Overflow](https://stackoverflow.com/search?q=cloudformation) for help building 
serverless applications. This repository contains a bunch of serverless building block stacks that have been useful to me.

Also, IMHuO, this repo contains a pretty kickass `Makefile`.

## Prep

You need the AWS CLI and AWS SAM Local CLI (for testing). You can install these on your own, or use the provided `Makefile`.

I suggest using a python virtual environment when installing the requirements. Once in your virtualenv, simply use `make init` to
install the needed CLI tools and dependencies. `I use `pyenv`, so my commands are:

```
pyenv activate watts
make init
```


## Usage

### Deploy a Stack

Deploy a stack via `make` using the directory name as the target, e.g.

```
make namespace=test bucket=<an S3 bucket for compiled template> lambda-s3
```

### Describe a Stack

Describe a stack via `make` by specifying the `action=describe`, again using the directory name as the target, e.g.

```
make namespace=test action=describe lambda-s3
```

### Delete a Stack

Delete a stack via `make` by specifying the `action=delete`, again using the directory name as the target, e.g.

```
make namespace=test action=delete lambda-s3
```


### Test a Stack

Test a stack with the associated `smoke.sh` script in each directory. Some scripts require the `namespace` as the first argument, e.g.

```
./lambda-s3/smoke.sh test  # <- test is the namespace used above
```
