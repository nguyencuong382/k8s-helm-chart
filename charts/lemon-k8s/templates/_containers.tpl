{{- define "lemon-k8s.containerBody" -}}
{{- $fullName := (include "baseName.fullname" .root) -}}
- name: {{ .container.name }}
  image: "{{ .Values.global.image.registry }}/{{ .container.repository }}:{{ .container.tag }}"
  imagePullPolicy: {{ $.Values.global.image.pullPolicy }}
  {{/*
    command — chọn CHƯƠNG TRÌNH nào chạy trong ảnh.

    Cần vì quy ước MỘT KHO = MỘT DOCKERFILE = MỘT ẢNH: mọi cmd của kho nằm chung
    một ảnh, nơi triển khai khai rõ chạy cái nào. Ví dụ:
        command: [".venv/bin/python", "-m", "cmd.summary.main"]

    Thay cho lối cũ ENV `CMD_MODULE` — ảnh tự đọc biến rồi tự chọn. Khác biệt:
    argv sai thì container chết NGAY lúc khởi động ("No module named ..."), còn
    ENV sai thì dễ rơi vào nhánh mặc định và chạy nhầm chương trình trong im lặng.
    Hỏng to tiếng hơn hỏng lặng lẽ.

    KHÔNG khai ⇒ dùng CMD mặc định trong Dockerfile (giữ nguyên hành vi cũ, nên
    thêm trường này KHÔNG phá bất kỳ values nào đang chạy).
  */}}{{- with .container.command }}
  command:
  {{- toYaml . | nindent 2 }}
  {{- end }}

  {{- if .Values.deployment.args }}
  args:
  {{- toYaml .Values.deployment.args | nindent 2 }}
  {{- end }}

  ports:
  {{- range $_, $port := .container.ports }}
    - name: {{ $port.name }}
      containerPort: {{ $port.value }}
      protocol: TCP
  {{- end }}

  volumeMounts:
  {{- if .Values.deployment.volumeMounts }}
  {{- toYaml .Values.deployment.volumeMounts | nindent 4 }}
  {{- end }}
  {{- if and (.Values.pvc) (.Values.pvc.enabled) }}
    - name: {{ $fullName }}
      mountPath: {{ .Values.pvc.mountPath }}
  {{- end }}

  {{- if .container.livenessHttpGet }}
  livenessProbe:
    httpGet:
      path: {{ .container.livenessHttpGet }}
      port: http
      scheme: {{ .container.scheme | default "HTTP" }}
    initialDelaySeconds: {{ .container.initialDelaySeconds | default 0 }}
    failureThreshold: {{ .container.failureThreshold | default 3 }}
  readinessProbe:
    httpGet:
      path: {{ .container.readinessHttpGet | default .container.livenessHttpGet }}
      port: http
      scheme: {{ .container.scheme | default "HTTP" }}
    initialDelaySeconds: {{ .container.initialDelaySeconds | default 0 }}
  {{- end }}

  env:
  {{- include "common.env" .Values.deployment | indent 4 }}
  {{- if .Values.deployment.envFrom }}
  {{- toYaml .Values.deployment.envFrom | nindent 4 }}
  {{- end }}
  {{- include "common.env" .container | indent 4 }}

  {{- if and (.Values.secret) (.Values.secret.enabled) }}
  envFrom:
    - secretRef:
        name: {{ .Values.secret.name | default $fullName }}
  {{- end }}

  {{- if .container.resources }}
  resources:
  {{- toYaml .container.resources | nindent 4 }}
  {{- end }}

{{- end }}
