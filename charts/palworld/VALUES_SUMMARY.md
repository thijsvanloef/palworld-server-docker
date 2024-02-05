# palworld

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

This chart will provide a Palworld server installation on a kubernetes cluster

**Homepage:** <https://github.com/thijsvanloef/palworld-server-docker>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Filipe Souza | <filipe.souza@mestre8d.com> | <https://github.com/Filipe-Souza> |
| Twinki |  | <https://github.com/Twinki14> |

## Source Code

* <https://github.com/thijsvanloef/palworld-server-docker>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespace | string | `"palworld"` | Namespace where the resources will be created |
| server | dict |  | The server configuration |
| server.annotations | object | `{}` | Additional annotations to the resources |
| server.config | dict |  | Change the game server configuration. If you change those, make sure to change the service.ports and server.ports accordingly. Those are directly connected with the container image, providing multiple environment variables to the scripts. |
| server.config.annotations | object | `{}` | Additional annotations to the resources |
| server.config.community.enable | bool | `true` | Enables/disables the visibility of this server on Steam community servers list. |
| server.config.community.password | string | `""` | If not provided, a random password will be generated and stored on the secret. |
| server.config.daily_reboot.enable | bool | `false` | Enable daily reboot. Disabled by default |
| server.config.daily_reboot.role | string | `"daily-reboot"` | The name of the role performing the daily reboot. |
| server.config.daily_reboot.serviceAccount | string | `"daily-reboot"` | The name of the Service Account used to perform the reboot. |
| server.config.daily_reboot.time | string | `"30 9 * * *"` | The time (UTC) the server will perform the reboot. By default, this schedules the restart at 9:30am UTC. Please note, this is using cron syntax. |
| server.config.labels | object | `{}` | Additional labels to the resources |
| server.config.max_players | int | `16` | The max number of players supported. |
| server.config.multithreading | bool | `true` | Enables the multithreading, allowing the usage of up to 4 cores (needs citation) |
| server.config.public_ip | string | `""` | You can manually specify the global IP address of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration. |
| server.config.public_port | string | `""` | You can manually specify the port number of the network on which the server running. If not specified, it will be detected automatically. If it does not work well, try manual configuration. |
| server.config.query_port | string | `27015` | The query port of the game. |
| server.config.rcon | dict |  | Remote connection configuration. Allows the remote connection and management for the server. Those are directly connected with the container image, providing multiple environment variables to the scripts. |
| server.config.rcon.enable | bool | `true` | Enables/disables the rcon port. |
| server.config.rcon.password | string | `""` | If not provided, a random password will be generated and stored on the secret. |
| server.config.rcon.port | string | `25575` | The port for rcon. If you change this, make sure to change the service.ports and server.ports accordingly. |
| server.config.server_description | string | `""` | Your server description to be shown in game |
| server.config.timezone | string | `"UTC"` | The timezone used for time stamping backup server. Use the IANA TZ format with Area/Location See the [list of TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations) |
| server.config.update_on_boot | string | `true` | Update/Install the server when the container starts. THIS HAS TO BE ENABLED THE FIRST TIME YOU RUN THE CONTAINER |
| server.config.world_parameters | object |  | Configures the game world settings. The key:values here should represent in game accepted values. Wrap all values with quotes here to avoid validation issues. |
| server.image | dict |  | Define the parameters for the server image container |
| server.image.imagePullPolicy | string | `"IfNotPresent"` | Define the pull policy for the server image. |
| server.image.repository | string | `"thijsvanloef/palworld-server-docker"` | Repository of the image, without the tag. |
| server.image.tag | string | `"latest"` | The tag of the image. |
| server.labels | object | `{}` | Additional labels to the resources |
| server.ports | dict |  | Change the ports to be mapped to the pod. If you change those, make sure to change the service.ports and server.config accordingly. |
| server.ports[0] | dict | `{"containerPort":8211,"name":"game","protocol":"UDP"}` | The "game" port definition. If you change this, make sure to change the service.ports.game and server.config accordingly. |
| server.ports[1] | dict | `{"containerPort":27015,"name":"query","protocol":"UDP"}` | The "query" port definition . If you change this, make sure to change the service.ports.query_port and server.config accordingly. |
| server.ports[2] | dict | `{"containerPort":25575,"name":"rcon","protocol":"UDP"}` | The "rcon" port definition . If you change this, make sure to change the service.ports.rcon and server.config accordingly. |
| server.resources | dict | `{"limits":{"cpu":4,"memory":"12Gi"},"requests":{"cpu":4,"memory":"8Gi"}}` | Resources limits for the container. |
| server.service | dict |  | Change the service configuration. If you change those, make sure to change the server.config and server.ports accordingly. |
| server.service.annotations | object | `{}` | Additional annotations to the resources |
| server.service.enabled | bool | `true` | Enables the creation of the service component. |
| server.service.healthz | dict | `{"enabled":false,"name":"healthz","port":80,"protocol":"TCP","targetPort":80}` | The "healthz" definition . Use if you need to create a TCP health check for load balancers on cloud services. |
| server.service.labels | object | `{}` | Additional labels to the resources |
| server.service.ports | dict |  | Change the ports to be mapped to the service. If you change those, make sure to change the server.config and server.ports accordingly. |
| server.service.ports[0] | dict | `{"name":"game","port":8211,"protocol":"UDP","targetPort":8211}` | The "game" port definition. If you change this, make sure to change the server.ports.game and server.config.port accordingly. |
| server.service.ports[1] | dict | `{"name":"query","port":27015,"protocol":"UDP","targetPort":27015}` | The "query" port definition . If you change this, make sure to change the server.ports.query and server.config.query_port accordingly. |
| server.service.ports[2] | dict | `{"name":"rcon","port":25575,"protocol":"UDP","targetPort":25575}` | The "rcon" port definition . If you change this, make sure to change the server.ports.rcon and server.config.rcon.port accordingly. |
| server.service.type | string | `"ClusterIP"` | The type of service to be created. For minikube, set this to NodePort, elsewhere use LoadBalancer Use ClusterIP if your setup includes ingress controller |
| server.storage | dict | `{"external":false,"externalName":"","preventDelete":false,"size":"12Gi","storageClassName":""}` | Define some parameters for the storage volume |
| server.storage.external | bool | `false` | Define if it will use an existing PVC containing the installation data. |
| server.storage.externalName | bool | `""` | The external PVC name to use. |
| server.storage.preventDelete | bool | `false` | Keeps helm from deleting the PVC. By default, helm does not delete pvcs. |
| server.storage.size | string | `"12Gi"` | The size of the pvc storage. |
| server.storage.storageClassName | string | `""` | The storage class name. |
| server.strategy | string | `"Recreate"` | Change the deployment strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.2](https://github.com/norwoodj/helm-docs/releases/v1.11.2)
