# Thinking Sequence

Use this order whenever creating or revisiting tests in interactive mode.

## 1. Behavior First
- State what the function should do in one sentence.
- State what the current increment will not do.

## 2. Minimal Real-Input Knowledge
- Identify the real command or API that will supply production data.
- Inspect only the properties the function actually needs.
- Do not model the full object if only a few fields matter.

## 3. Test Design
- Build fake objects containing only the required properties.
- Write assertions for returned values or side effects.
- Keep the test focused on one behavior slice.

## 4. Implementation
- Write the smallest code that satisfies the test.
- Preserve the production path by falling back to the real command when test data is not injected.

## Example
- Behavior: return non-system, non-boot disks.
- Real command: `Get-Disk`.
- Required properties: `Number`, `IsSystem`, `IsBoot`.
- Test object: `[pscustomobject]` with only those fields.
- Implementation: optional `-Disks` parameter plus `Get-Disk` fallback.
