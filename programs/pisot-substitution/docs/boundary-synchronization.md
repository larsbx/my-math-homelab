# Boundary synchronization reduction

Let

- `sigma_+(a)` be the first letter of `sigma(a)`;
- `sigma_-(a)` be the last letter of `sigma(a)`.

For a finite map `h: A -> A`, a pair `(a,b)` is `h`-synchronizing if `h^m(a) = h^m(b)` for some `m >= 0`.

For a zero-return boundary `k` inside `(sigma^n(u), sigma^n(v))`, record:

- left boundary pair `(a_-, b_-) = (sigma^n(u)[k-1], sigma^n(v)[k-1])` if `k > 0`;
- right boundary pair `(a_+, b_+) = (sigma^n(u)[k], sigma^n(v)[k])` if `k < length`.

## Boundary Synchronization Lemma

If some zero-return boundary has right pair in `Sync_+` or left pair in `Sync_-`, then the SCC is productive.

Right side: an inherited zero-return boundary remains a zero-return after inflation, and its right pair evolves under `sigma_+`. If it synchronizes to `(c,c)`, then the one-tile interval to its right is a coincidence sibling.

Left side: the left pair evolves under `sigma_-`. If it synchronizes to `(c,c)`, then subtracting the same `e_c` from the equal prefix Parikh vectors at the inherited zero-return shows the previous position is also a zero-return; the one-tile interval to the left is a coincidence sibling.

## Caveat

The synchronizing-end criterion is only a sufficient condition. It catches substitutions with globally synchronizing `sigma_+` or `sigma_-`, but examples such as Smith can still be caught by the full lemma through a specific synchronizing boundary pair even when neither endpoint map is globally synchronizing.
