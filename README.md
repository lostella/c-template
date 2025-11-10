# c-template

C project scaffolding for everyone!

## Usage

```sh
make init     # initialize directory structure
make build    # build project
make test     # run tests
make help     # get help
```

## Directory structure

```
c-template/
├── Makefile
├── src/
│   └── bin/
├── include/
├── tests/
└── build/
    ├── debug/
    │   ├── bin/
    │   └── tests/
    └── release/     # if RELEASE=1
        ├── bin/
        └── tests/
```
