# palworld

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

This chart can provide an rAthena emulator installation on a Kubernetes cluster.

**Homepage:** <https://github.com/thijsvanloef/palworld-server-docker>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Filipe Souza | <filipe.souza@mestre8d.com> | <https://github.com/Filipe-Souza> |

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
| server.config.labels | object | `{}` | Additional labels to the resources |
| server.config.max_players | int | `16` | The max number of players supported. |
| server.config.multithreading | bool | `true` | Enables the multithreading, allowing the usage of up to 4 cores (needs citation) |
| server.config.query_port | string | `27015` | The query port of the game. |
| server.config.rcon | dict |  | Remote connection configuration. Allows the remote connection and management for the server. Those are directly connected with the container image, providing multiple environment variables to the scripts. |
| server.config.rcon.enable | bool | `true` | Enables/disables the rcon port. |
| server.config.rcon.password | string | `""` | If not provided, a random password will be generated and stored on the secret. |
| server.config.rcon.port | string | `25575` | The port for rcon. If you change this, make sure to change the service.ports and server.ports accordingly. |
| server.image | dict |  | Define the parameters for the server image container |
| server.image.imagePullPolicy | string | `"IfNotPresent"` | Define the pull policy for the server image. |
| server.image.name | string | `"thijsvanloef/palworld-server-docker"` | Name of the image, without the tag. |
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
| server.service.labels | object | `{}` | Additional labels to the resources |
| server.service.ports | dict |  | Change the ports to be mapped to the service. If you change those, make sure to change the server.config and server.ports accordingly. |
| server.service.ports[0] | dict | `{"name":"game","port":8211,"protocol":"UDP","targetPort":8211}` | The "game" port definition. If you change this, make sure to change the server.ports.game and server.config.port accordingly. |
| server.service.ports[1] | dict | `{"name":"query","port":27015,"protocol":"UDP","targetPort":27015}` | The "query" port definition . If you change this, make sure to change the server.ports.query and server.config.query_port accordingly. |
| server.service.ports[2] | dict | `{"name":"rcon","port":25575,"protocol":"UDP","targetPort":25575}` | The "rcon" port definition . If you change this, make sure to change the server.ports.rcon and server.config.rcon.port accordingly. |
| server.service.ports[3] | dict | `{"name":"healthz","port":80,"protocol":"TCP","targetPort":80}` | The "healthz" port definition . Used only to create a health check for load balancers on cloud services. |
| server.service.type | string | `"LoadBalancer"` | The type of service to be created. |
| server.storage | dict | `{"external":false,"externalName":"","preventDelete":false,"size":"10Gi","storageClassName":""}` | Define some parameters for the storage volume |
| server.storage.external | bool | `false` | Define if it will use an existing PVC containing the installation data. |
| server.storage.externalName | bool | `""` | The external PVC name to use. |
| server.storage.preventDelete | bool | `false` | Keeps helm from deleting the PVC. By default, helm does not delete pvcs. |
| server.storage.size | string | `"10Gi"` | The size of the pvc storage. |
| server.storage.storageClassName | string | `""` | The storage class name. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
