---
name: debugging
description: >
  Validates a diagnostic before it gets trusted as evidence for a conclusion.
  Use when the user cites grep output, log contents, a counter, a probe, or
  an assertion to support a claim, e.g. "these logs show zero errors, is the
  service healthy", "the counter says 134 restarts", "grep found nothing so
  it's not there", or when interpreting an error message that cites
  `file:line`, errno text naming a syscall, a symptom that only reproduces in
  a test environment, or "A cannot reach B" network connectivity. Covers
  instrument validation before belief, positive-control checks against
  all-zero results, sanity-checking numbers against physical possibility,
  distinguishing "log shows X" from "X is true", reading errors as source
  references rather than prose, and a lookup table of known traps (`pipefail`
  plus `grep -q`/`grep -c` interactions, log rotation, `console=ttyS0` scope,
  D-Bus startup races).
---

# Trusting the instrument

Applies whenever conclusion rests on diagnostic: grep, log read, counter, probe, assertion. Measurement is code and can be wrong; unvalidated measurement reported as finding is worse than no measurement, because it is believed.

- Validate instrument before believing it. Run against known-true case and known-false case first: grep must match something known present and miss something known absent. Takes seconds; not optional for anything whose output becomes evidence.
- Zero is not evidence without positive control in same output. All-zero table is indistinguishable from broken table. Every diagnostic prints at least one marker that MUST be non-zero if channel works, alongside interesting ones.
- Sanity-check numbers against physical possibility before interpreting. "134 starts of `Type=oneshot` unit with no `Restart=`" cannot happen: that counter was measuring log re-appends. Ask "can this value occur at all?".
- Distinguish "log shows X" from "X is true". State which one you have. Do not silently upgrade inference drawn through one unvalidated filter into "definitive" or "root cause found".
- Failing wait means: print what waited-on command actually returns, before theorising about content. Wrong theories cluster on filter and data when bug is in shell semantics of pipeline.
- After first instrumentation bug in session, re-verify other diagnostics rather than only fixing one that broke. Same class recurs when each fix is applied locally instead of swept for.

## Reading errors

Error message is claim by program about its own state. Interpreting it without reading emitting code is same failure as trusting unvalidated measurement.

- Error citing `file.c:line` is source reference, not prose. Open that line before theorising; costs one command. `ERROR launcher_run_child @ launcher.c +344: No such file or directory` read like missing executable and was `sd_id128_get_machine()` failing on absent `/etc/machine-id`. Eight runs spent checking binaries, all present. If source unavailable, tag interpretation "not verified".
- Generic errno text describes failing syscall, not surrounding function name. ENOENT inside function called `*_run_child` was `open()` of config file, not `exec()` of child. When wording implies subsystem, confirm from source that failing call is in that subsystem.
- Symptom reproduced only in test environment, not production: diff the two builds BEFORE debugging symptom. Environment exists to reproduce production, so divergence is the lead. Compare package sets, image build scripts, config files shipped by upstream vs hand-written substitutes.
- Upstream shipping a file (policy, unit, config, hosts) means install THAT file. Hand-written substitute drifts silently and is not covered by upstream's own testing.

## Check the endpoint exists before debugging the path

When A cannot reach B, confirm A can transmit at all before investigating B. Cheapest question first, and it is usually one command.

- Every server-side check can pass while the client has no interface. kea was active, bound, correctly classed, zero errors, zero packets received; `ip -br link` in the guest showed `lo` only. Four theories about the server and the bridge were raised and disproved before that one line ran.
- "Receives nothing" and "receives and rejects" have disjoint causes. Establish which one you have before reading any server config.
- Missing driver looks like a service fault. Guest booted with `-kernel` and no initrd had VIRTIO_BLK but not VIRTIO_NET: disk worked, NIC never appeared, and every symptom pointed at DHCP.

## Known traps

- `set -euo pipefail` (NixOS test driver uses it): `producer | grep -q PATTERN` reports FAILURE when pattern IS found (grep exits early, producer dies of SIGPIPE, pipefail propagates). `grep -c` exits 1 on zero matches, aborting command substitution. Use `... | grep -c PATTERN > /dev/null`, or pipe through `cat`.
- Deduplicating or `tail`-ing log that concatenates several boots/runs collapses them into one and hides interesting line.
- `console=ttyS0` routes only kernel messages. Unit output needs journald `ForwardToConsole=yes`.
- `systemctl` before D-Bus is up returns "Transport endpoint is not connected", surfacing as `ConditionResult: no`, identical to genuinely failed condition.
- Log file read once may be different file by the time you read it: check whether producer recreates or rotates it in place.
