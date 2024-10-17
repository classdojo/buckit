import * as pulumi from "@pulumi/pulumi";
import * as kubernetes from "@pulumi/kubernetes";
import { DatadogMonitor } from "pulumi-types/datadog/nodejs/datadoghq/v1alpha1/datadogMonitor.js";

// Get some values from the stack configuration, or use defaults
const config = new pulumi.Config();
const k8sNamespace = config.get("namespace") || "buckit";

// Create a new namespace
const buckit = new kubernetes.core.v1.Namespace(
  "buckit",
  {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
      annotations: {
        "classdojo-ops.com/repo": "buckit",
        "classdojo-ops.com/team": "notifications",
      },
      labels: {
        "kubernetes.io/metadata.name": "buckit",
        name: "buckit",
      },
      name: "buckit",
    },
    spec: {
      finalizers: ["kubernetes"],
    },
  },
  {
    protect: true,
  }
);

const datadogMonitor = new DatadogMonitor("buckit-datadog-monitor", {
  metadata: {
    name: "buckit-datadog-monitor",
  },
  spec: {
    query: "avg(last_1h):sum:system.net.bytes_rcvd{host:host1} > 100",
  },
});
