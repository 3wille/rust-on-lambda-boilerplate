# rust-on-lambda-boilerplate

## Requirements
* [cargo lambda](https://www.cargo-lambda.info/)
* [terraform](https://www.terraform.io/)

## Build

```shell
cargo lambda build --release -o zip --arm64 --bins
```

## Deploy

Within ``/infrastructure``:
```
terraform apply
```

## Add new HTTP function

1. ``cargo lambda new <name>``
2. enter ``y`` to create an HTTP function
3. Select ``Amazon Api Gateway HTTP Api``
4. Add crate to workspace members in ``/Cargo.toml``
5. Add ``resource_function`` module call in ``/infrastructure/main.tf``
6. re-build and re-deploy
