# Certificate incidence handoff

The active finite ontology is:

```text
MisiurewiczCertificate
  RootHandle(poly, box, krawczyk-witness)
  RayAddressDatum(symbolic Q/Z data)
  DyadicBox(name)
  JointCertificateStatus(localization + exclusions + tags)
  CertificateIncidenceStatus(PointVertex over finite carrier)
```

## Rule

A root handle is not a classical point. A coordinate record is not a classical point. A singleton box is not a classical point.

The only admissible point-like object in the finite core is:

```text
PointVertex(VertexSet{RootHandle, RayAddressSet, DyadicBox})
```

This means "point as vertex of vertices": a finite incidence package tying together the root handle, the ray-address set, and the isolating dyadic box.

## Consequence

Landing and fiber statements cannot bind to analytic singletons inside the verifier. They bind to the finite incidence package plus named theorem tags:

- `RationalRayLanding`
- `MisiurewiczFiberTriviality`

The theorem tags may refer to the classical interpretation externally, but the certificate payload remains finite.

## Current examples

- `c_minus_2_certificate()` is accepted because its Krawczyk witness, exact-type exclusions, ray data, theorem tags, and incidence package all accept.
- `m41_certificate_placeholder()` is structurally present but rejected until the native `P_4_1` Krawczyk witness lands.

## Next implementation target

Wire native interval polynomial evaluation for `P_4_1` into the Krawczyk witness, then feed the accepted witness into `MisiurewiczCertificate` so `M_4_1` becomes the first nontrivial accepted multi-ray incidence certificate.
