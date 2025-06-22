```sh
helm package ./charts/lemon-k8s/
```

```sh
helm repo index --url https://nguyencuong382.github.io/k8s-helm-chart . --merge index.yaml
```

```sh
helm repo add lemon-k8s https://nguyencuong382.github.io/k8s-helm-chart
```

```sh
helm template lemon-k8s/lemon
```

```sh
helm template ./charts/lemon-k8s -f ./values/redis.yaml
```
