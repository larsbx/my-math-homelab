# Graph modular bicycle theorem

Claim: ABC-GRAPH-MODULAR-BICYCLE.

## Standing data and statement

Let $G=(V,E)$ be a finite, nonempty, connected **undirected** graph.
Parallel edges and loops are allowed. Choose an orientation and put

$$
B_e=e_{\mathrm{head}(e)}-e_{\mathrm{tail}(e)},\qquad L=BB^\top.
$$

A loop has zero incidence column. Write

$$
D^0(G)=\{d\in\mathbb Z^V:\textstyle\sum_v d_v=0\},\qquad
K(G)=D^0(G)/L\mathbb Z^V.
$$

This is the finite critical group, equivalently the torsion subgroup of
$\operatorname{coker}L$. For an integer $n\ge2$, set

$$
\operatorname{Bic}_n(G)=\operatorname{im}(B^\top:(\mathbb Z/n)^V
\longrightarrow(\mathbb Z/n)^E)\cap
\ker(B:(\mathbb Z/n)^E\longrightarrow(\mathbb Z/n)^V).
$$

**Theorem.** There is a canonical $\mathbb Z/n$-module isomorphism

$$
\Phi_n:\operatorname{Bic}_n(G)\longrightarrow K(G)[n],\qquad
\Phi_n(B^\top y\bmod n)=[Ly/n],
\tag{1}
$$

where $y\in\mathbb Z^V$ is any integral potential lifting the given
modular gradient. Its inverse is

$$
\Psi_n([d])=B^\top y\bmod n\quad\text{for any }Ly=nd.
\tag{2}
$$

These maps are equivariant under graph isomorphisms and changes of edge
orientation. They commute with the reduction and inflation maps specified
in Section 6 below. There is no assertion of functoriality under arbitrary
graph homomorphisms.

## 1. Two integral facts

**Constant-potential lemma.** For every modulus $n\ge2$,
$\ker(B^\top\bmod n)=(\mathbb Z/n)\mathbf1$.
Indeed, every nonloop edge imposes equality of its endpoint potentials;
following paths proves that all potentials agree. This uses no division
and holds over composite residue rings. Consequently

$$
B^\top(y'-y)\equiv0\pmod n
\quad\Longrightarrow\quad y'-y=c\mathbf1+nz
\quad(c\in\mathbb Z,\ z\in\mathbb Z^V).
\tag{3}
$$

**Integral Laplacian lemma.**
$\ker(L:\mathbb Z^V\to\mathbb Z^V)=\mathbb Z\mathbf1$.
If $Lw=0$, then the integer identity

$$
0=w^\top Lw=\sum_{e\in E}(w_{\mathrm{head}(e)}-
w_{\mathrm{tail}(e)})^2
$$

forces each difference to vanish. Connectedness now applies. The same
argument after clearing denominators gives $\ker L$ over $\mathbb Q$
equal to the constant potentials. Since the image has degree zero and
rank $|V|-1$, $L\mathbb Z^V$ has finite index in $D^0(G)$.
The degree homomorphism on $\operatorname{coker}L$ has kernel $K(G)$
and a free cyclic quotient, so this kernel is precisely its torsion subgroup.

## 2. Definition and representative independence of $\Phi_n$

For a bicycle $b=B^\top y\bmod n$, the cycle condition gives
$Ly\equiv0\pmod n$. Thus $d=Ly/n$ is integral; it has degree zero
because $\mathbf1^\top L=0$. Moreover $n[d]=[Ly]=0$, so (1) lands
in $K(G)[n]$.

Changing a lift $y$ to $y+nz$ changes $d$ by $Lz$. More generally,
two potentials representing the same $b$ satisfy (3), and therefore

$$
Ly'/n-Ly/n=Lz.
$$

Their critical-group classes coincide. This proves independence both of
integral lifts and of modular potential representatives. Add potentials
to add bicycles; multiply them by integers to scale bicycles. Formula
(1) is consequently a homomorphism, and it is $\mathbb Z/n$-linear
because its target is annihilated by $n$.

## 3. Injectivity

Suppose $\Phi_n(b)=0$. Then $Ly/n=Lz$ for an integral $z$, so
$L(y-nz)=0$. The integral Laplacian lemma gives $y-nz=c\mathbf1$.
Hence $B^\top y=nB^\top z$, and $b=0$.

This is an integral kernel argument, not a modular rank calculation.

## 4. Surjectivity and independence of $\Psi_n$

Let $[d]\in K(G)[n]$ and choose a degree-zero integral representative
$d$. The condition $n[d]=0$ means, by the definition of the quotient,
that an integral $y$ exists with $Ly=nd$. Set $b=B^\top y\bmod n$.
It is a cut by construction and a cycle because $Bb=Ly\equiv0\pmod n$.
Equation (1) gives $\Phi_n(b)=[d]$, proving surjectivity.

If $Ly'=nd$ as well, the integral Laplacian lemma makes $y'-y$
constant, so their gradients agree even integrally. If the divisor
representative changes to $d'=d+Lz$, use $y'=y+nz$; its gradient
has the same reduction modulo $n$. Any other solution differs from
$y'$ by a constant. Thus (2) is independent of both choices.

## 5. Both inverse identities

Starting from $b=B^\top y\bmod n$, use $d=Ly/n$. The same $y$
solves $Ly=nd$, and (2) returns $b$. Hence
$\Psi_n\Phi_n=\mathrm{id}$.

Starting from $[d]$, choose $Ly=nd$. Formula (1) applied to the
gradient in (2) returns $[Ly/n]=[d]$. Hence
$\Phi_n\Psi_n=\mathrm{id}$.

In particular the isomorphism has both directions without deducing
either from a cardinality computation.

## 6. Compatibility across moduli

Let $m=kn$, with $n\ge2$ and $k\ge1$. There are two canonical
coefficient maps, with different critical-group counterparts:

| Bicycle map | Critical-group map | Compatibility identity |
| --- | --- | --- |
| $\rho_{m,n}(b)=b\bmod n$ | $\mu_k:K(G)[m]\to K(G)[n],\ x\mapsto kx$ | $\Phi_n\rho_{m,n}=\mu_k\Phi_m$ |
| $\iota_{n,m}(b)=kb\bmod m$ | Inclusion $j_{n,m}:K(G)[n]\hookrightarrow K(G)[m]$ | $\Phi_m\iota_{n,m}=j_{n,m}\Phi_n$ |

Reduction preserves cuts and cycles. For $b=B^\top y\bmod m$,

$$
\Phi_n(\rho_{m,n}b)=[Ly/n]=k[Ly/m].
$$

Inflation is well defined: changing an edge representative by $nz$
changes $kb$ by $mz$. It is injective on the ambient edge modules.
If $b=B^\top y\bmod n$, use the potential $ky$ modulo $m$. Its
Laplacian is divisible by $m$, and

$$
\Phi_m(\iota_{n,m}b)=[L(ky)/m]=[Ly/n].
$$

For $n\mid m\mid\ell$, both families compose transitively: reduction
composes by ordinary reduction, and inflation composes because
$(\ell/m)(m/n)=\ell/n$. Also

$$
\rho_{m,n}\iota_{n,m}=k\,\mathrm{id}_{\operatorname{Bic}_n},\qquad
\iota_{n,m}\rho_{m,n}=k\,\mathrm{id}_{\operatorname{Bic}_m}.
$$

Coefficient reduction need **not** be surjective on bicycles. For the
two-edge parallel graph, $K(G)=\mathbb Z/2$. Reduction from modulus
$4$ to $2$ corresponds to multiplication by $2$, hence is zero,
even though both bicycle modules are nonzero. Identifying the two tower
maps with the same critical-group map would be incorrect.

## 7. Graph naturality and computational coordinates

Changing orientations or edge order is a signed permutation $S$ of
edge coordinates: $B'=BS$, $L'=L$, and $b'=S^\top b$. Thus
$\Phi'_n(S^\top b)=\Phi_n(b)$. A graph isomorphism with vertex
permutation $P$ and signed edge permutation $S$ gives
$B'=PBS$, $L'=PLP^\top$, and sends $[d]$ to $[Pd]$.
Substituting $Py$ in (1) proves equivariance.

The theorem requires no distinguished vertex. Computation may choose a
root $r$. Dropping coordinate $r$ identifies $D^0(G)$ with
$\mathbb Z^{V\setminus\{r\}}$. Since $L\mathbf1=0$, dropping
coordinate $r$ also identifies its image lattice with the columns of
the reduced Laplacian $L_r$: subtract the root value from any potential
before applying $L$. It follows that

$$
K(G)\cong\operatorname{coker}L_r.
$$

The rational vector $L_r^{-1}d_{\ne r}\bmod\mathbb Z^{V\setminus\{r\}}$
is a faithful coordinate for the class $[d]$: it vanishes exactly when
$d=Lz$ for an integral potential, reconstructed with root value zero.
For (2), solving $L_r y_{\ne r}=nd_{\ne r}$ gives integral coordinates
exactly when $[d]$ is $n$-torsion. The omitted row then holds because
both sides have coordinate sum zero. Changing the computational root
does not change $[d]$ or the resulting modular gradient.

## 8. Examples and independent evidence

If the positive Smith factors of $L_r$ are $s_1\mid\cdots\mid s_t$,
then

$$
K(G)[n]\cong\bigoplus_i\mathbb Z/\gcd(s_i,n),\qquad
|\operatorname{Bic}_n(G)|=\prod_i\gcd(s_i,n).
$$

| Graph | Critical group | Prime example | Prime-power example | Mixed composite example |
| --- | --- | --- | --- | --- |
| $C_3$ | $\mathbb Z/3$ | $n=3:\ \mathbb Z/3$ | $n=9:\ \mathbb Z/3$ | $n=6:\ \mathbb Z/3$ |
| $C_4$ | $\mathbb Z/4$ | $n=2:\ \mathbb Z/2$ | $n=4:\ \mathbb Z/4$ | $n=12:\ \mathbb Z/4$ |
| $C_6$ | $\mathbb Z/6$ | $n=3:\ \mathbb Z/3$ | $n=4:\ \mathbb Z/2$ | $n=6:\ \mathbb Z/6$ |
| $K_4$ | $(\mathbb Z/4)^2$ | $n=2:\ (\mathbb Z/2)^2$ | $n=8:\ (\mathbb Z/4)^2$ | $n=12:\ (\mathbb Z/4)^2$ |

The pinned fixtures also cover a tree, a single vertex with loops,
parallel edges, and a triangle with a pendant edge and loop.
The two-edge parallel graph and $C_4$ both have a one-dimensional
bicycle space modulo $2$, but have respectively $2$ and $4$
bicycles modulo $4$. This detects a torsion-exponent error that
prime-field ranks cannot detect.

The independent oracle computes Smith factors from gcds of **all minors**
of each reduced integral Laplacian using exact Bareiss determinants.
It constructs the Laplacian directly from edge multiplicities, enumerates
cycles using chord values and leaf elimination, tests the cut condition
by path integration, and compares divisor classes by Cramer's rule.
It imports no candidate-kernel code. The candidate implementation instead
enumerates normalized potentials and uses rational Gauss-Jordan elimination.
Element-order distributions and every mapped class are checked in addition
to group sizes. See [conformance](../conformance/README.md) for replay commands.

## 9. Authority and scope

This proof is a repository-local integral argument. The exact fixtures
audit its implementations over finite cases; they are not a proof by
enumeration. [Source context](../sources/graph-critical-group-background.md)
records background references; no novelty claim is made.

The result applies to the graph case only. It does not promote
ABC-REGULAR-MODULAR-BICYCLE, representation independence for regular
matroids, or arithmetic-matroid realization invariance. Replacing $B$
by an arbitrary integral matrix would require additional hypotheses:
the constant-potential lemma and its consequences were proved here for
connected graph incidence matrices.
