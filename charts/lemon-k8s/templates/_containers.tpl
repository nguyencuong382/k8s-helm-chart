{{- define "lemon-k8s.containerBody" -}}
{{- $fullName := (include "baseName.fullname" .root) -}}
- name: {{ .container.name }}
  image: "{{ .Values.global.image.registry }}/{{ .container.repository }}:{{ .container.tag }}"
  imagePullPolicy: {{ $.Values.global.image.pullPolicy }}

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
