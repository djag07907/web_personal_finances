{{flutter_js}}
{{flutter_build_config}}

// Override the build config to force HTML renderer
_flutter.buildConfig = {
  "engineRevision": _flutter.buildConfig.engineRevision,
  "builds": [{
    "compileTarget": "dart2js",
    "renderer": "html",
    "mainJsPath": "main.dart.js"
  }]
};

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      renderer: "html",
    });
    await appRunner.runApp();
  }
});
