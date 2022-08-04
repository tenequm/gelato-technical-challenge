{{/*
Useful links:
https://itnext.io/helm-reusable-chart-named-templates-and-a-generic-chart-for-multiple-applications-13d9b26e9244
https://www.replex.io/blog/9-best-practices-and-examples-for-working-with-kubernetes-labels
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "gelato-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gelato-server.labels" -}}
{{ include "gelato-server.selectorLabels" . }}
heritage: {{ .Release.Service }}
environment: {{ .Values.env }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gelato-server.selectorLabels" -}}
application: {{ include "gelato-server.name" . }}
{{- end }}