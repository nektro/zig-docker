# zig-docker

Zig bindings for the Docker Engine API.

API docs: https://docs.docker.com/engine/api/v1.41/

WIP as its based on the partially-incomplete Swagger API (https://github.com/moby/moby/issues/27919)

## Updating
```
$ zig build run
$ zig fmt src/direct.zig
```

## Example Program
```
$ zig build test
```
