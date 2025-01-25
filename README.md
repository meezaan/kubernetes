# Kubernetes Helper Scripts

## Install

### Master

```
curl -sLO https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/install/[version]/master.sh && sh master.sh [hostname] [control_plane_endpoint] [service_dns_domain] && rm master.sh
```

### Worker

```
curl -sLO https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/install/[version]/worker.sh && sh worker.sh [hostname] && rm worker.sh
```

## Upgrade

### First Node

Ideally, this is your master, if you have just one.

```
curl -sLO https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/upgrade/to/[version]/first.sh && sh first.sh && rm first.sh
```


### Other Nodes


```
curl -sLO https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/upgrade/to/[version]/others.sh && sh others.sh && rm others.sh
```
