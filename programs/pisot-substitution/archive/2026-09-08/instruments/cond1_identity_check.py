"""
Check the identity  r = (C_comp - 1) - b1  on KNOWN homological-Pisot reducible
substitutions: the BBJS cr=3 triple covers (Examples 1,2 from BBJS), which ARE
homological Pisot (dim H^1 = d) with C_comp=3, b1=0 stated in the paper.

For these: r = #nonzero roots of q = chi_{N}/chi_{minpoly(beta)}.
Predicted by identity: r = (3-1) - 0 = 2.
And homological-Pisot condition (1) says those 2 nonzero q-roots are roots of unity (=1,
since mult(1)=C_comp-1=2). So q should be (x-1)^2 * x^(deg-2).
"""
import numpy as np, sympy as sp
x=sp.symbols('x')

# BBJS Example 1 (d=1) abelianization of phi_2 (6x6), eigenvalues 9,1,1,0,0,0
M1 = sp.Matrix([
 [3,2,1,3,1,2],
 [1,2,3,0,4,2],
 [2,2,2,3,1,2],
 [1,1,1,1,1,1],
 [1,1,1,0,2,1],
 [1,1,1,2,0,1]])
chi1 = M1.charpoly(x).as_expr()
print("Example 1 (d=1): char poly factored:")
print(" ", sp.factor(chi1))
# dilatation N=9, minpoly = x-9. q = chi / (x-9).
q1 = sp.simplify(chi1/(x-9))
print("  q =", sp.factor(q1))
roots1 = sp.roots(sp.Poly(q1,x))
nz1 = sum(m for r,m in roots1.items() if r!=0)
print(f"  nonzero roots of q (r) = {nz1}; predicted (C_comp-1)-b1 = (3-1)-0 = 2")
print(f"  nonzero roots: { {complex(r):m for r,m in roots1.items() if r!=0} }")

# BBJS Example 2 (d=2) abelianization (6x6), eigenvalues 6+3sqrt5, 6-3sqrt5, 1,1,0,0
M2 = sp.Matrix([
 [4,3,2,3,1,2],
 [2,3,4,0,4,2],
 [3,3,3,3,1,2],
 [2,2,2,1,1,1],
 [2,2,2,0,2,1],
 [2,2,2,2,0,1]])
chi2 = M2.charpoly(x).as_expr()
print("\nExample 2 (d=2): char poly factored:")
print(" ", sp.factor(chi2))
# minpoly of dilatation 6+3sqrt5: x^2 - 12x + 9 (since (6+3r5)(6-3r5)=36-45=-9, sum=12)
minp2 = x**2 - 12*x + 9
q2,rem = sp.div(sp.Poly(chi2,x), sp.Poly(minp2,x))
print("  divides evenly:", rem==sp.Poly(0,x))
print("  q =", sp.factor(q2.as_expr()))
roots2=sp.roots(q2)
nz2=sum(m for r,m in roots2.items() if r!=0)
print(f"  nonzero roots of q (r) = {nz2}; predicted (3-1)-0 = 2")
print(f"  nonzero roots: { {complex(r):m for r,m in roots2.items() if r!=0} }")
print("\nIf r=2 and the nonzero roots are BOTH =1, the identity r=(C_comp-1)-b1 and")
print("condition(1)[all RoU] both hold on these known homological-Pisot reducible examples.")
