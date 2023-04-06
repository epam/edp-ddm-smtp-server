{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mailu.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mailu.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the claimName: existingClaim if provided, otherwise claimNameOverride if provided, otherwise mailu-storage (or other fullname if overriden)
*/}}
{{- define "mailu.claimName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else if .Values.persistence.claimNameOverride -}}
{{- .Values.persistence.claimNameOverride -}}
{{- else -}}
{{ include "mailu.fullname" . }}-storage
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mailu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mailu.labels" -}}
app.kubernetes.io/name: {{ include "mailu.name" . }}
helm.sh/chart: {{ include "mailu.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{ define "mailu.rspamdClamavAdminClaimName"}}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.rspamd_clamav_admin_persistence.claimNameOverride | default (printf "%s-rspamd-clamav-admin" (include "mailu.fullname" .)) }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mailu.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mailu.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Initial admin account password
*/}}
{{- define "mailu.initialAccount.password" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "mailu-admin-credentials") }}
{{- if $secret }}
{{- $secret.data.password }}
{{- else }}
{{- uuidv4 | b64enc }}
{{- end }}
{{- end }}

{{/*
Session encryption key for admin and webmail
*/}}
{{- define "mailu.sessionEncryptionKey" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "mailu-session-encryption-key") }}
{{- if $secret }}
{{- $secret.data.key }}
{{- else }}
{{- uuidv4 | b64enc }}
{{- end }}
{{- end }}

{{- define "imageRegistry" -}}
{{- if .Values.global -}}
{{- if .Values.global.imageRegistry -}}
{{- printf "%s/" .Values.global.imageRegistry -}}
{{- else -}}
{{- end -}}
{{- end -}}
{{- end }}
