import NoveltyLab.IntrinsicSelectionF7

namespace NoveltyLab.FourierPlacementF7

open NoveltyLab.IntrinsicSelectionF7

/-- Binary character table valued in F7; 8=1, so no normalization root is needed. -/
def fourier : Matrix := matrix fun i j =>
  if ((i % 2)*(j % 2) + ((i/2) % 2)*((j/2) % 2) + (i/4)*(j/4)) % 2 == 0
  then 1 else 6

def translation (t : Nat) : Matrix := matrix fun i j =>
  if j == Nat.xor i t then 1 else 0

def placed : List Matrix := patterns.map fun row =>
  mul phi (mul fourier (mul (diagonal row) (mul fourier phiInv)))

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Concrete Fourier bridge and exact identification of every placed defect. -/
theorem fourier_placement_certificates :
    (mul (transpose fourier) fourier == identity &&
     mul (transpose (mul phi fourier)) (mul gram (mul phi fourier)) == identity &&
     placed == [0,4,2,6,1,5,3,7].map translation) = true := by
  decide

end NoveltyLab.FourierPlacementF7
