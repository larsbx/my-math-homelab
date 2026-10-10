# Authority boundary

Julia Oracle Lab independently recomputes results, generates witnesses, runs differential tests, and hosts research spikes. It is deliberately outside every trusted acceptance boundary.

## Allowed outcomes

- `agrees`
- `disagrees`
- `inconclusive`
- `oracle_error`

The lab must never emit `accepted`, `proved`, `authorized`, or a deployment verdict.

Every durable oracle binds to a domain claim, an authoritative checker repository, and a boundary identifier. Missing or unknown critical binding data fails closed. Disagreement creates an investigation obligation; it does not transfer authority to Julia.

Forgejo remains canonical source and merge authority where configured. Woodpecker remains canonical CI. GitHub is a review mirror.
