{{/*
Expand the name of the chart.
*/}}
{{- define "argocd-namespaced.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argocd-namespaced.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argocd-namespaced.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "argocd-namespaced.labels" -}}
helm.sh/chart: {{ include "argocd-namespaced.chart" . }}
{{ include "argocd-namespaced.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argocd-namespaced.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argocd-namespaced.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "argocd-namespaced.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argocd-namespaced.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Template for Argo CD Managed Namespaces Releases
*/}}
{{- define "argocd-namespaced.managed.roles" -}}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: argocd-manager-role
  namespace: {{ .managedNamespace }}
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: argocd-manager-role-binding
  namespace: {{ .managedNamespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: argocd-manager-role
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: {{ .hostedNamespace }}
{{- end }}

{{/*
Template for Argo CD Managed Namespaces
*/}}
{{- define "argocd-namespaced.managed.namespaces" -}}
{{ if .Values.argocd.namespaces.create }}
{{- range $managedNamespace := .Values.argocd.managedNamespaces }}
{{ if ne $managedNamespace $.Release.Namespace }}
---
apiVersion: v1
kind: Namespace
metadata:
  name: {{ $managedNamespace }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create Namespace Configuration
*/}}
{{- define "argocd-namespaced.managed.configs" -}}
{{- if .Values.argocd.managedNamespaces }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: {{ .Release.Namespace }}
{{- range $managedNamespace := .Values.argocd.managedNamespaces }}
{{$data := dict "hostedNamespace" $.Release.Namespace "managedNamespace" $managedNamespace }}
{{ include "argocd-namespaced.managed.roles" $data }}
{{- end}}
{{- end }}
{{- end }}
