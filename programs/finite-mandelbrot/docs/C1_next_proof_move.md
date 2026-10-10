# C1 Next Proof Move

Status: immediate next research task.

The project is now narrowed around C1:

```text
finite rational-ray nest stabilization
  iff triviality of Mandelbrot fibers
  iff MLC
```

The next proof move is not to add more implementation infrastructure. It is to make PO-1 and PO-3 precise enough that the equivalence is no longer a slogan.

## Immediate target

Write the finite-to-classical dictionary:

| finite-regime object | classical/fiber-theory object |
|---|---|
| `RayAddrFinite` | rational external address |
| `LandingTag` | cited rational ray landing theorem instance |
| `LandedRay` | rational ray known to land |
| `SeparationLine` | Schleicher-style rational-ray separation line |
| `SeparationCatalogue(k)` | finite depth-k enumeration of certified separation lines |
| `SameFiber_k(a,b)` | no depth-k certified line separates `a` and `b` |
| `FiberNest(a)` | descending non-separation classes |
| `Stabilizes(a)` | meta-level singleton/triviality condition |

## Proof sketch to fill next

### Lemma 1 — grammar adequacy

Every finite `SeparationLine` accepted by the grammar corresponds to a classical rational-ray separation line.

### Lemma 2 — catalogue exhaustion

The increasing sequence of catalogues exhausts the countable rational-ray separation lines used in the fiber definition.

### Lemma 3 — finite non-separation limit

For incidence vertices `a,b`:

```text
a and b are never separated by any finite catalogue
  iff a and b lie in the same Schleicher fiber.
```

### Lemma 4 — stabilization/triviality

```text
FiberNest(a) stabilizes to one incidence class
  iff the associated classical fiber is trivial.
```

### Theorem C1

By Schleicher's fiber-local-connectivity theorem:

```text
global finite nest stabilization iff MLC.
```

## Guardrail

Do not claim Lemma 4 for generic boundary data as a finite certificate. Generic singleton stabilization is exactly the open frontier.
