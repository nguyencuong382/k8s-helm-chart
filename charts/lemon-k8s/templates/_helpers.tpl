
#======================================
# Base helpers
#======================================
{{- define "baseName.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "baseName.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "baseName.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

#======================================
# Common helpers
#======================================
{{- define "common.env" }}
{{- range $key, $value := .Values.deployment.environments }}
- name: "{{ $key }}"
  value: "{{ $value }}"
{{- end }}
{{- end }}


#======================================
# Secret helpers
#======================================
{{- define "secret.name" -}}
{{- printf "%s-secret" (.Chart.Name | default "") | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "secret.env" }}
{{- range .Values.secrets}}
{{- range $key, $value := .volumeMount.env }}
- name: "{{  $key }}"
  value: "{{ $value }}"
{{- end }}
{{- end }}
{{- end }}

{{- define "secret.volumeMounts" }}
{{- range .Values.secrets}}
{{- if .volumeMount.mountPath }}
- name: "{{ .name }}"
  mountPath: "{{ .volumeMount.mountPath }}"
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{- define "secret.volume" }}
{{- range .Values.secrets}}
{{- if .volumeMount.mountPath }}
- name: {{ .name }}
  secret:
    secretName: {{ .name }}
{{- end }}
{{- end }}
{{- end }}
