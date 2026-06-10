# collect-dotnet-dump.sh

Collects a .NET process dump from a running Docker container.

The script uses `docker inspect` to find the host PID of the container and then runs `dotnet-dump collect` against process ID `1` inside the container namespace. The dump is first created inside the container's `/tmp` directory and then copied back to the current host directory.

## Usage

```bash
./collect-dotnet-dump.sh <container_id_or_name> <dump_name>
```

Example:

```bash
./collect-dotnet-dump.sh my-super-service service_dump
```

This creates a dump file with a timestamped name:

```text
service_dump_20260610_143022.dmp
```

## Script permissions

If a script cannot be executed directly, make it executable:

```bash
chmod +x <script-name>.sh
```

Example:

```bash
chmod +x collect-dotnet-dump.sh
```


## Arguments

* `<container_id_or_name>`
  Docker container ID or container name.

* `<dump_name>`
  Base name for the generated dump file. A timestamp and `.dmp` extension are added automatically.

## Requirements

* Linux host
* Docker
* `dotnet-dump` installed on the host
* `sudo` access
* The target container must be running a .NET application as process ID `1`

The script expects `dotnet-dump` here:

```bash
~/.dotnet/tools/dotnet-dump
```

Install it with:

```bash
dotnet tool install --global dotnet-dump
```

## Output

The final dump file is copied to the current working directory.

Example:

```text
service_dump_20260610_143022.dmp
```

The script also changes the file ownership back to the current user, so the dump can be opened without `sudo`.

## Notes

This script is useful when a .NET service is running inside a Docker container and you need to collect a dump for later analysis with tools such as `dotnet-dump analyze` or JetBrains DotMemory.


Temporary dump files are removed from the container after the dump is copied to the host.

## Future work

* Support collecting dumps from multiple containers
* Automatically detect and allow selecting the target .NET process instead of relying on PID = 1
* Support periodic dump collection (snapshotting)

