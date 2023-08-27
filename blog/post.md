---
layout: post
title: Run and expose Kubernetes Pod based Application using Quadlet and Inlets
description: As a Kubernetes user, you can use the same YAML file to expose your application using Inlets
author: Ygal Blum & Valentin Rothberg
tags: podman quadlet containers
author_img: ygal
image: /images/2021-09-compose/writing.jpg
date: 2023-08-23
---

[Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) is a new way of running containerized workloads in systemd with Podman. Running Podman in systemd achieves a high degree of robustness and automation since systemd can take care of the lifecycle management and monitoring of the workloads. More advanced features such as [Podman auto updates](https://docs.podman.io/en/latest/markdown/podman-auto-update.1.html) and [custom health-check actions](https://www.redhat.com/sysadmin/podman-edge-healthcheck) make Quadlet a handy tool for modern Edge Computing.

This tutorial is inspired by a previous post from Alex Ellis's on [running inlets with compose](https://inlets.dev/blog/2021/09/09/compose-and-inlets.html). But instead of Compose, we want to show how deploy inlets via Quadlet and make use of Podman's Kubernetes capabilities. Hence, we are going to run a `.kube` file via Quadlet and Podman. In addition, we'll use Quadlet to run the containerized version of Inlets Server as well.

## Accompanying Code

The code that accompanies this blog post uses [Terraform](https://www.terraform.io/) to provision resources on AWS and [Ansible](https://www.ansible.com/) to deploy the applications. The code can be found [here](https://github.com/ygalblum/blog-inlets).

## Prerequisites

This tutorial uses [Jinja Templates](https://jinja.palletsprojects.com/en/3.1.x/).
In order to use them you will need to install `j2`
```bash
pip install jinja2
```

## Deploy the Inlets Server

Use Quadlet to run the Inlets server.

### Inlets Token Secret

The Quadlet depends on a Podman Secret named `inlets-token` to get the Inlets Token.
Since the server will run as a rootful container, make sure to create the secret also as root.

```bash
echo -n < TOKEN > | podman secret create inlets-token -
```

### Quadlet

#### Generate the Quadlet `inlets.container` file
1. Use the following jinja template `inlets.container.j2`:
    ```jinja
    [Install]
    WantedBy=multi-user.target

    [Container]
    Image=ghcr.io/inlets/inlets-pro:{{ inlets_version | default('0.9.20') }}
    ContainerName=inlets
    Exec=http server --auto-tls --auto-tls-san={{ inlets_server_ip }} --token-env=INLETS_TOKEN --letsencrypt-domain={{ inlets_server_domain }} --letsencrypt-email={{ lets_encrypt_user | default('webmaster') }}@{{ inlets_server_domain }} --letsencrypt-issuer={{ lets_encrypt_issuer | default('staging') }}
    PublishPort=80:80
    PublishPort=443:443
    PublishPort=8123:8123
    AddCapability=NET_BIND_SERVICE
    Secret=inlets-token,type=env,target=INLETS_TOKEN
    ```
    You may notice that the structure of the above Quadlet file looks like an ordinary systemd unit. And that's exactly it! Quadlet is an extension of the systemd-unit syntax and adds a number of new tables to it. The `[Container]` table for single-container workloads and the `[Kube]` table for running Kubernetes workloads. There are also tables for volumes, networks and secrets. Feel free to refer to the [man page](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) for details.

2. Create the `data.json` file
    ```json
    {
        "inlets_server_ip": "192.168.1.1",
        "inlets_server_domain": "ghost.example.com"
    }
    ```
3. Generate the `inlets.container` file
    ```bash
    j2 inlets.container.j2 data.json > inlets.container
    ```

#### Create and run the Quadlet
To install a Quadlet, it must be placed at specific location (see [docs](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)). Then, you can reload the systemd service or user session, and you are ready to go. Since we are running the workload as root, we need to place the Quadlet in `/etc`.

1. Copy the `inlets.container` file to `/etc/containers/systemd`
    ``` bash
    sudo cp inlets.container /etc/containers/systemd
    ```
2. Reload the systemd daemon
    ```bash
    sudo systemctl daemon-reload
    ```
3. Start the service
    ```bash
    sudo systemctl start inlets.service
    ```

## Running GHost along with Inlets client

You can run Ghost on your local computer, a Raspberry Pi, or an additional EC2 instance.

### Secrets

The Inlets client depends on two secrets `inlets-license` and `inlets-token`.
However, because these secrets are consumed by a Kubernetes Pod, they also must take the form of a Kubernetes Secret

#### Inlets Token Secret

1. Use the following jinja template `inlets-token-secret.yml.j2`:
    ```jinja
    apiVersion: v1
    kind: Secret
    metadata:
        name: inlets-token
    stringData:
        inlets-token: "{{ inlets_token }}"
    ```

2. Create the `data.json` file
    ```json
    {
        "inlets_token": "< TOKEN >"
    }
    ```
3. Generate the secret
    ```bash
    j2 inlets-token-secret.yml.j2 data.json | podman secret create inlets-token -

#### Inlets License Secret

1. Use the following jinja template `inlets-license-secret.yml.j2`:
    ```jinja
    apiVersion: v1
    kind: Secret
    metadata:
        name: inlets-license
    stringData:
        inlets-token: "{{ inlets_license }}"
    ```

2. Create the `data.json` file
    ```json
    {
        "inlets_license": "< LICENSE >"
    }
    ```
3. Generate the secret
    ```bash
    j2 inlets-license-secret.yml.j2 data.json | podman secret create inlets-license -
    ```

### Kubernetes YAML and Quadlet

#### Kubernetes Pod YAML
1. Use the following jinja template `inlets-ghost.yml.j2`:

    ```jinja
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: ghost-pv-claim
      labels:
        app: ghost
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 20Gi
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: inlets-ghost-demo
    spec:
      containers:
      - name: ghost
        image: docker.io/library/ghost:5.59.0-alpine
        env:
        - name: url
          value: https://{{ inlets_server_domain }}
        - name: NODE_ENV
          value: development
        volumeMounts:
        - name: ghost-persistent-storage
          mountPath: /var/lib/ghost/content
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
      - name: inlets
        image: ghcr.io/inlets/inlets-pro:{{ inlets_version | default('0.9.20') }}
        args:
        - "http"
        - "client"
        - "--url=wss://{{ inlets_server_ip }}:8123"
        - "--token-file=/var/secrets/inlets-token/inlets-token"
        - "--license-file=/var/secrets/inlets-license/inlets-license"
        - "--upstream=http://127.0.0.1:2368"
        volumeMounts:
        - mountPath: /var/secrets/inlets-token
          name: inlets-token
        - mountPath: /var/secrets/inlets-license
          name: inlets-license
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
      volumes:
      - name: ghost-persistent-storage
        persistentVolumeClaim:
          claimName: ghost-pv-claim
      - name: inlets-license
        secret:
          secretName: inlets-license
      - name: inlets-token
        secret:
          secretName: inlets-token
    ```
2. Create the `data.json` file
    ```json
    {
        "inlets_server_ip": "192.168.1.1",
        "inlets_server_domain": "ghost.example.com"
    }
    ```
3. Generate the `inlets-ghost.yaml` file
    ```bash
    j2 inlets-ghost.yaml.j2 data.json > inlets-ghost.yaml
    ```

#### Quadlet `inlets-ghost.kube` file
```
[Kube]
Yaml=inlets-ghost.yml
```

#### Create and run the Quadlet
1. Copy the `inlets-ghost.yaml` and `inlets-ghost.kube` files to `/etc/containers/systemd`
    ``` bash
    sudo cp inlets-ghost.yaml inlets-ghost.kube /etc/containers/systemd
    ```
2. Reload the systemd daemon
    ```bash
    sudo systemctl daemon-reload
    ```
3. Start the service
    ```bash
    sudo systemctl start inlets-ghost.service
    ```

## Access the blog

Once all resources are up and running you can access you blog at your at `https://< inlets_server_domain >`

To create your admin account, add `/ghost` to the end of the URL.
