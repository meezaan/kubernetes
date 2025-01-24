# Kubernetes Helper Scripts

## Install

### Master

```
curl -sL https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/install/[version]/master.sh | bash -s -- [hostname] [control_plane_endpoint] [service_dns_domain]
```

### Worker

```
curl -sL https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/install/[version]/worker.sh | bash -s -- [hostname]
```

## Upgrade

### First Node

Ideally, this is your master, if you have just one.

```
curl -sL https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/upgrade/to/[version]/first.sh
```


### Other Nodes


```
curl -sL https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/upgrade/to/[version]/others.sh
```

