

```sh
helm package ./charts/lemon-k8s/
```

```sh
helm repo index --url https://nguyencuong382.github.io/k8s-helm-chart . --merge index.yaml
```

