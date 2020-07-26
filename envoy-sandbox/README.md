# [Envoy v1.12.3 sandbox](./envoy-1.12.3)
This sandbox runs a couple of simple apps with Envoy. It can be used to experiment and iterate on Envoy config quickly locally. Here we are using it with OTel.


Note: that there are significant API changes between v1.12.3 and the latest.

Based on the Envoy example with a few tweaks.
- Example docs https://www.envoyproxy.io/docs/envoy/v1.12.3/start/sandboxes/zipkin_tracing
- Example code https://github.com/envoyproxy/envoy/tree/release/v1.12/examples/zipkin-tracing
- Envoy tracing config docs https://www.envoyproxy.io/docs/envoy/v1.12.3/api-v2/config/trace/v2/trace.proto#envoy-api-msg-config-trace-v2-tracing

Envoy is configured to send traces to the OTel agent in Zipkin format. OTel agent forwards to the OTel collector. Collector forwards to local logs, local Zipikin backend instnace, and Honeycomb backend. This simulates the chain in a real production environment except we'll run a OTel agent per task.

```
                                        local logs
                                      /
Envoy -> OTel Agent -> OTel collector - Zipkin local instance
                                      \ 
                                        Honeycomb
```


To start 
- `./start.sh`
- to generate load `./generate-request-load.sh`


To debug 
```sh
$ docker-compose pull
$ docker-compose build
$ docker-compose up
$ docker-compose ps
$ ./generate-request-load.sh
```
`docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"`

Ref Docs


Tracing config SoT in code https://github.com/envoyproxy/envoy/blob/v1.12.3/api/envoy/config/trace/v2/trace.proto#L27