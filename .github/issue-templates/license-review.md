The scheduled ORT license review reported policy findings.

This does not necessarily mean the build is unsafe or non-compliant.
A human should review the ORT report artifact and decide whether the finding is acceptable, needs an exception, or requires remediation.

Workflow run: {{RUN_URL}}

Suggested review steps:

- Check whether the finding is production, development, test, build, or transitive.
- Check whether the license is already approved by policy.
- Check whether the finding is a false positive or needs curation.
- If acceptable, document the rationale in the ORT configuration.
- If not acceptable, replace or remove the dependency.

The workflow itself should only be treated as broken if ORT failed to run or reports were not generated.