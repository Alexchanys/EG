import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.SpecialFunctions.Complex.Arg
/-!
# Standard ℝ²

This file defines the standard inner product real vector space of dimension two.

## Important definitions

* `Dir` : the class of unit vectors in the 2d real vector space
* `Proj` : the class of `Dir` quotient by `±1`, in other words, `ℝP¹` . 

## Notation

## Implementation Notes

In section `Vec`, we define all of the sturctures on the standard 2d inner product real vector space `ℝ × ℝ`. We use defs and do NOT use instances here in order to avoid conflicts to existing instance of such stuctures on `ℝ × ℝ` which is based on `L^∞` norm of the product space. Then we define the angle of two vectors, which takes value in `(-π, π]`. Notice that if any one of the two vector is `0`, the angle is defined to be `0`.

Then we define the class `Dir` of vectors of unit length. We equip it with the structure of commutative group. The quotient `Proj` of `Dir` by `±1` is automatically a commutative group.

## Further Works
Inequalities about `ℝ²` should be written at the beginning of this file.

The current definition is far from being general enough. Roughly speaking, it suffices to define the Euclidean Plane to be a `NormedAddTorsor` over any 2 dimensional normed real inner product spaces `V` with a choice of an orientation on `V`, rather than over the special `ℝ × ℝ`. All further generalizations in this file should be done together with Plane.lean.
-/

noncomputable section
namespace EuclidGeom

scoped notation "π" => Real.pi

/- structures on `ℝ × ℝ`-/
namespace Vec

protected def AddGroupNorm : AddGroupNorm (ℝ × ℝ) where
  toFun := fun x => Real.sqrt (x.1 * x.1  + x.2 * x.2)
  map_zero' := by simp
  add_le' := fun x y => by 
    simp only [Prod.fst_add, Prod.snd_add]
    repeat rw [← pow_two]
    apply le_of_pow_le_pow 2 (by positivity) (by positivity)
    rw [Real.sq_sqrt (by positivity)]
    nth_rw 1 [pow_two]
    nth_rw 1 [pow_two]
    nth_rw 1 [pow_two]
    simp [mul_add, add_mul]
    rw [Real.mul_self_sqrt (by positivity)]
    rw [Real.mul_self_sqrt (by positivity)]
    have P :  x.1 * y.1 + x.2 * y.2 ≤ Real.sqrt (x.1^2 + x.2^2) * Real.sqrt (y.1^2 + y.2^2) := by
      let h := (x.1 * y.1 + x.2 * y.2 ≤  0)
      by_cases h
      · apply le_trans h
        exact mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
      · apply le_of_pow_le_pow 2 (mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)) (by positivity)
        rw [mul_pow]
        simp [Real.sq_sqrt (add_nonneg (sq_nonneg _) (sq_nonneg _))]
        simp [pow_two, add_mul, mul_add]
        let h1 := two_mul_le_add_pow_two (x.1 * y.2) (x.2 * y.1)
        linarith
    rw [pow_two] at P
    simp [pow_two] at *    
    linarith

  neg' := fun _ => by simp
  eq_zero_of_map_eq_zero' := fun x => by
    simp
    intro h
    rw [Real.sqrt_eq_zero'] at h
    simp [← pow_two] at h
    let hx₁ := sq_nonneg x.1
    let hx₂ := sq_nonneg x.2
    ext
    · by_contra h₁
      simp at h₁
      rw [← Ne.def] at h₁
      have h₁₁ := sq_pos_of_ne_zero _ h₁
      linarith
    · by_contra h₁
      simp at h₁
      rw [← Ne.def] at h₁
      have h₂₁ := sq_pos_of_ne_zero _ h₁
      linarith

-- Due to a strange bug in our version of Lean4, we use @HPow.hPow to input a^n where n is a natural number, to avoid Lean4 recognize n : ℝ

protected def InnerProductSpace.Core : InnerProductSpace.Core ℝ (ℝ × ℝ) where
  inner := fun r s => r.1 * s.1 + r.2 * s.2
  conj_symm := fun _ _ => by
    simp only [map_add, map_mul, IsROrC.conj_to_real]
    ring
  nonneg_re := fun _ => by 
    simp only [map_add, IsROrC.mul_re, IsROrC.re_to_real, IsROrC.im_to_real, mul_zero, sub_zero]
    ring_nf
    positivity
  definite := fun x hx => by
    simp at hx
    rw [← pow_two, ← pow_two] at hx
    have g₁ : 0 ≤ @HPow.hPow ℝ ℕ ℝ _ x.1 2  := by positivity
    have g₂ : 0 ≤ @HPow.hPow ℝ ℕ ℝ _ x.2 2  := by positivity
    ext
    · dsimp
      by_contra h
      have h₁ : 0 < @HPow.hPow ℝ ℕ ℝ _ x.1 2  := by positivity
      linarith
    · dsimp
      by_contra h
      have h₂ : 0 < @HPow.hPow ℝ ℕ ℝ _ x.2 2  := by positivity
      linarith  
  add_left := fun _ _ _ => by 
    simp
    ring
  smul_left := fun _ _ _ => by
    simp
    ring

/- shortcuts -/
protected def NormedAddCommGroup : NormedAddCommGroup (ℝ × ℝ) := AddGroupNorm.toNormedAddCommGroup Vec.AddGroupNorm

protected def NormedAddGroup : NormedAddGroup (ℝ × ℝ) := @NormedAddCommGroup.toNormedAddGroup _ Vec.NormedAddCommGroup

protected def InnerProductSpace : @InnerProductSpace ℝ (ℝ × ℝ) _ Vec.NormedAddCommGroup := InnerProductSpace.ofCore Vec.InnerProductSpace.Core

protected def SeminormedAddCommGroup := @NormedAddCommGroup.toSeminormedAddCommGroup _ Vec.InnerProductSpace.Core.toNormedAddCommGroup

protected def SeminormedAddGroup := @SeminormedAddCommGroup.toSeminormedAddGroup _ Vec.SeminormedAddCommGroup

protected def MetricSpace := @NormedAddCommGroup.toMetricSpace _ Vec.InnerProductSpace.Core.toNormedAddCommGroup

protected def PseudoMetricSpace := @MetricSpace.toPseudoMetricSpace _ Vec.MetricSpace

protected def NormedSpace := @InnerProductSpace.Core.toNormedSpace _ _ _ _ _ Vec.InnerProductSpace.Core

protected def BoundedSMul := @NormedSpace.boundedSMul _ _ _ Vec.SeminormedAddCommGroup Vec.NormedSpace

protected def Norm := @NormedAddCommGroup.toNorm _ Vec.NormedAddCommGroup

protected def norm := @Norm.norm _ Vec.Norm

def toComplex (x : ℝ × ℝ) : ℂ := ⟨x.1, x.2⟩

/- WARNING : the arg of `0 : ℂ` is `0`, the result of quotient by `0 : ℂ` is `0 : ℂ`
protected def angle (x y : ℝ × ℝ) : ℝ := Complex.arg ((Vec.toComplex y)/(Vec.toComplex x)) -/

end Vec

theorem vec_norm_eq_abs (x : ℝ × ℝ) : Vec.norm x = Complex.abs (Vec.toComplex x) := rfl

namespace Complex

protected def toVec (c : ℂ) : ℝ × ℝ := ⟨c.1, c.2⟩

end Complex

/- the notation for class of vectors-/
scoped notation "Vec" => ℝ × ℝ

@[ext]
class Dir where
  toVec : Vec
  unit : Vec.InnerProductSpace.Core.inner toVec toVec= 1 

def Vec.normalize (x : ℝ × ℝ) (hx : x ≠ 0) : Dir where
  toVec := (Vec.norm x)⁻¹ • x 
  unit := by 
    rw [@real_inner_smul_left _ Vec.NormedAddCommGroup Vec.InnerProductSpace _ _ _, @real_inner_smul_right _ Vec.NormedAddCommGroup Vec.InnerProductSpace _ _ _, @inner_self_eq_norm_sq_to_K _ _ _ Vec.NormedAddCommGroup Vec.InnerProductSpace]
    dsimp
    rw [pow_two]
    rw [← mul_assoc _ _ (@norm (ℝ × ℝ) Vec.NormedAddCommGroup.toNorm x)]
    simp only [Vec.norm, ne_eq, inv_mul_mul_self]
    rw [inv_mul_cancel ((@norm_ne_zero_iff _ Vec.NormedAddGroup).mpr hx)]

-- Should change Dir into the following Dir'to use all instances on Dir'
def Dir' := @Metric.sphere _ Vec.PseudoMetricSpace (0: ℝ × ℝ) 1

-- Or alternatively, define CommGroup instance on Dir
namespace Dir

instance : Neg Dir where
  neg := fun x => {
      toVec := -x.toVec
      unit := by 
        rw [← unit]
        exact @inner_neg_neg _ _ _ Vec.NormedAddCommGroup Vec.InnerProductSpace _ _
    }

def mk_angle (θ : ℝ) : Dir where
  toVec := (Real.cos θ, Real.sin θ)
  unit := by 
    rw [← Real.cos_sq_add_sin_sq θ]
    rw [pow_two, pow_two]
    rfl

@[simp]
theorem re_of_toComplex_eq_fst (x : ℝ × ℝ): (Vec.toComplex x).re = x.fst := rfl

@[simp]
theorem im_of_toComplex_eq_snd (x : ℝ × ℝ): (Vec.toComplex x).im = x.snd := rfl

@[simp]
theorem mk_angle_arg_toComplex_of_nonzero_eq_normalize {x : ℝ × ℝ} (hx : x ≠ 0) : mk_angle (Complex.arg (Vec.toComplex x)) = Vec.normalize x hx := by
  ext : 1
  unfold Vec.normalize toVec mk_angle HSMul.hSMul instHSMul SMul.smul Prod.smul
  simp
  rw [vec_norm_eq_abs]
  constructor
  · rw [Complex.cos_arg, mul_comm]
    simp
    rfl
    unfold Vec.toComplex
    intro h
    rw [Complex.ext_iff] at h
    simp at h
    have g : x = 0 := by
      ext : 1
      tauto
      tauto
    tauto
  · rw [Complex.sin_arg, mul_comm]
    simp
    rfl

instance : Mul Dir where
  mul := fun z w => {
    toVec := Complex.toVec (Vec.toComplex z.toVec * Vec.toComplex w.toVec)
    unit := by
      unfold Inner.inner Vec.InnerProductSpace.Core Complex.toVec Vec.toComplex
      simp
      ring_nf
      calc 
        _ = (z.toVec.1 ^ 2 + z.toVec.2 ^ 2) * (w.toVec.1 ^ 2 + w.toVec.2 ^ 2) := by
          ring
        _ = 1 * 1 := by 
          simp only [pow_two]
          congr 1
          · exact z.unit
          · exact w.unit
        _ = 1 := one_mul 1
  } 

instance : One Dir where
  one := {
    toVec := (1, 0)
    unit := by 
      unfold Inner.inner Vec.InnerProductSpace.Core
      simp
  }

-- Put tautological theorems into simp

@[simp]
theorem fst_of_one_eq_one : (1 : Dir).1.fst = 1 := rfl

@[simp]
theorem snd_of_one_eq_zero : (1 : Dir).1.snd = 0 := rfl

@[simp]
theorem one_eq_one_toComplex : Vec.toComplex (1 : Dir).toVec = 1 := rfl

@[simp]
theorem one_toVec_eq_one : Complex.toVec (1 : ℂ) = (1, 0) := rfl

@[simp]
theorem eq_self_toComplex_toVec (x : ℝ × ℝ) : Complex.toVec (Vec.toComplex x) = x := rfl

@[simp]
theorem sq_sum_eq_one (x : Dir) : @HPow.hPow ℝ ℕ ℝ _ x.toVec.1 2 + @HPow.hPow ℝ ℕ ℝ _ x.toVec.2 2 = 1 := by
  rw [pow_two, pow_two]
  exact x.unit

-- Give a CommGroup structure to Dir by the mul structure of ℂ

instance : Semigroup Dir where
  mul_assoc _ _ _ := by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul instMulDir Complex.toVec Vec.toComplex
    simp
    ring_nf

instance : Monoid Dir where
  one_mul := fun _ => by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul instSemigroupDir instMulDir
    simp only [one_eq_one_toComplex, one_mul, eq_self_toComplex_toVec]
    rfl
  mul_one := fun _ => by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul instSemigroupDir instMulDir
    simp only [one_eq_one_toComplex, mul_one, eq_self_toComplex_toVec]
    rfl

instance : CommGroup Dir where
  inv := fun x => {
    toVec := (x.1.fst, -x.1.snd)
    unit := by
      unfold inner Vec.InnerProductSpace.Core
      simp
      exact x.2
  }
  mul_left_inv _ := by
    ext : 1
    unfold HMul.hMul Inv.inv instHMul Mul.mul Semigroup.toMul Monoid.toSemigroup instMonoidDir instSemigroupDir instMulDir Vec.toComplex Complex.toVec
    simp
    ring_nf
    ext
    simp only [sq_sum_eq_one, fst_of_one_eq_one]
    simp only [snd_of_one_eq_zero]
    
  mul_comm _ _ := by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul Monoid.toSemigroup instMonoidDir instSemigroupDir instMulDir
    simp
    ring_nf

-- Define a ± equivalence to build Proj

instance : HasDistribNeg Dir where
  neg := Neg.neg
  neg_neg _ := by
    unfold Neg.neg instNegDir
    simp
  neg_mul _ _ := by
    ext : 1
    unfold Neg.neg instNegDir toVec HMul.hMul instHMul Mul.mul instMulDir Vec.toComplex Complex.toVec toVec
    simp
    ring_nf
  mul_neg _ _ := by
    ext : 1
    unfold Neg.neg instNegDir toVec HMul.hMul instHMul Mul.mul instMulDir Vec.toComplex Complex.toVec toVec
    simp
    ring_nf

@[simp]
theorem toVec_neg_eq_neg_toVec (x : Dir) : (-x).toVec = -(x.toVec) := by
  ext
  unfold Neg.neg instNegDir toVec Prod.instNeg
  simp
  unfold Neg.neg instNegDir toVec Prod.instNeg
  simp

@[simp]
theorem fst_of_neg_one_eq_neg_one : (-1 : Dir).toVec.1 = -1 := rfl

@[simp]
theorem snd_of_neg_one_eq_zero : (-1 : Dir).toVec.2 = 0 := by
  unfold toVec Neg.neg instNegDir
  simp only [Prod.snd_neg, snd_of_one_eq_zero, neg_zero]

def angle (x y : Dir) := Complex.arg (Vec.toComplex (y * (x⁻¹)).toVec)

end Dir

def PM : Dir → Dir → Prop :=
fun x y => x = y ∨ x = -y

namespace PM

def equivalence : Equivalence PM where
  refl _ := by simp [PM]
  symm := fun h => 
    match h with
      | Or.inl h₁ => Or.inl (Eq.symm h₁)
      | Or.inr h₂ => Or.inr (Iff.mp neg_eq_iff_eq_neg (id (Eq.symm h₂)))
  trans := by
    intro _ _ _ g h
    unfold PM
    match g with
      | Or.inl g₁ => 
          rw [← g₁] at h
          exact h
      | Or.inr g₂ => 
          match h with
            | Or.inl h₁ =>
              right
              rw [← h₁, g₂]
            | Or.inr h₂ =>
              left
              rw [g₂, h₂, ← Iff.mp neg_eq_iff_eq_neg rfl]

instance con : Con Dir where
  r := PM
  iseqv := PM.equivalence
  mul' := by
    unfold Setoid.r PM
    simp
    intro _ x _ z g h
    match g with
      | Or.inl g₁ => 
        match h with
          | Or.inl h₁ =>
            left
            rw [g₁, h₁]
          | Or.inr h₂ =>
            right
            rw [g₁, h₂, ← mul_neg _ _]
      | Or.inr g₂ => 
        match h with
          | Or.inl h₁ =>
            right
            rw [g₂, h₁, ← neg_mul _ _]
          | Or.inr h₂ =>
            left
            rw[g₂, h₂, ← neg_mul_neg x z]

end PM

def Proj := Con.Quotient PM.con

namespace Proj

instance : MulOneClass Proj := Con.mulOneClass PM.con

instance : Group Proj := Con.group PM.con

instance : CommMonoid Proj := Con.commMonoid PM.con

instance : CommGroup Proj where
  mul_comm := instCommMonoidProj.mul_comm

end Proj

def Dir.toProj (v : Dir) : Proj := ⟦v⟧

instance : Coe Dir Proj where
  coe v := v.toProj

def Vec.toProj_of_nonzero (v : ℝ × ℝ) (h : v ≠ 0) : Proj := (Vec.normalize v h : Proj) 

theorem normalize_eq_normalize_smul_pos {u v : ℝ × ℝ} (hu : u ≠ 0) (hv : v ≠ 0) {t : ℝ} (h : v = t • u) (ht : 0 < t) : Vec.normalize u hu = Vec.normalize v hv := by
  ext : 1
  unfold Vec.normalize Dir.toVec
  simp
  have hv₁ : Vec.norm v ≠ 0 := Iff.mpr (@norm_ne_zero_iff _ Vec.NormedAddGroup v) hv
  have g : (Vec.norm v) • u = (Vec.norm u) • v := by
    have w₁ : (Vec.norm (t • u)) = ‖t‖ * (Vec.norm u) := @norm_smul _ _ _ Vec.SeminormedAddGroup _ Vec.BoundedSMul t u
    have w₂ : ‖t‖ = t := abs_of_pos ht
    rw [h, w₁, w₂, mul_comm]
    exact mul_smul (Vec.norm u) t u
  have g₁ : (Vec.norm u)⁻¹ • (Vec.norm v) • u = v := Iff.mpr (inv_smul_eq_iff₀ (Iff.mpr (@norm_ne_zero_iff _ Vec.NormedAddGroup _) hu)) g
  rw [smul_algebra_smul_comm _ _ _] at g₁
  rw [← Iff.mpr (inv_smul_eq_iff₀ hv₁) (Eq.symm g₁)]

theorem neg_normalize_eq_normalize_smul_neg {u v : ℝ × ℝ} (hu : u ≠ 0) (hv : v ≠ 0) {t : ℝ} (h : v = t • u) (ht : t < 0) : -Vec.normalize u hu = Vec.normalize v hv := by
  ext : 1
  unfold Vec.normalize
  simp
  have g : (-Vec.norm v) • u = (Vec.norm u) • v := by
    have w₁ : (Vec.norm (t • u)) = ‖t‖ * (Vec.norm u) := @norm_smul _ _ _ Vec.SeminormedAddGroup _ Vec.BoundedSMul t u
    have w₂ : ‖t‖ = -t := abs_of_neg ht
    rw [h, w₁, w₂, neg_mul, neg_neg, mul_comm]
    exact mul_smul (Vec.norm u) t u
  have g₁ : (Vec.norm u)⁻¹ • (-Vec.norm v) • u = v := (Iff.mpr (inv_smul_eq_iff₀ (Iff.mpr (@norm_ne_zero_iff _ Vec.NormedAddGroup _) hu)) g)
  rw [smul_algebra_smul_comm _ _ _] at g₁
  rw [neg_eq_iff_eq_neg, ← neg_smul _ _, ← inv_neg, ← Iff.mpr (inv_smul_eq_iff₀ (Iff.mpr neg_ne_zero (Iff.mpr (@norm_ne_zero_iff _ Vec.NormedAddGroup _) hv))) (Eq.symm g₁)]

theorem eq_toProj_of_smul {u v : ℝ × ℝ} (hu : u ≠ 0) (hv : v ≠ 0) {t : ℝ} (h : v = t • u) : Vec.toProj_of_nonzero u hu = Vec.toProj_of_nonzero v hv := by
  have ht : t ≠ 0 := by
    by_contra ht'
    rw [ht', zero_smul ℝ u] at h
    tauto
  have ht₁ : (0 < t) ∨ (t < 0) := Ne.lt_or_lt (Ne.symm ht)
  unfold Vec.toProj_of_nonzero Dir.toProj
  apply Quotient.sound
  unfold HasEquiv.Equiv instHasEquiv PM.con PM
  simp
  match ht₁ with
    | Or.inl ht₂ =>
      left
      exact normalize_eq_normalize_smul_pos hu hv h ht₂
    | Or.inr ht₃ =>
      right
      exact Iff.mp neg_eq_iff_eq_neg (neg_normalize_eq_normalize_smul_neg hu hv h ht₃)

theorem smul_of_eq_toProj {u v : ℝ × ℝ} {hu : u ≠ 0} {hv : v ≠ 0} (h : Vec.toProj_of_nonzero u hu = Vec.toProj_of_nonzero v hv) : ∃ (t : ℝ), v = t • u := by
  unfold Vec.toProj_of_nonzero Dir.toProj at h
  let h' := Quotient.exact h
  unfold HasEquiv.Equiv instHasEquiv PM.con PM at h'
  simp at h'
  match h' with
    | Or.inl h₁ =>
      rw [Dir.ext_iff] at h₁
      use (Vec.norm v) * (Vec.norm u)⁻¹
      have w₁ : (Vec.norm v)⁻¹ • v = (Vec.norm u)⁻¹ • u ↔ v = (Vec.norm v) • (Vec.norm u)⁻¹ • u := inv_smul_eq_iff₀ (Iff.mpr (@norm_ne_zero_iff _ Vec.NormedAddGroup v) hv)
      rw [mul_smul]
      refine (w₁.mp (Eq.symm ?_))
      exact h₁
    | Or.inr h₂ =>
      rw [Dir.ext_iff] at h₂
      use (-Vec.norm v) * (Vec.norm u)⁻¹
      have w₂ : (-Vec.norm v)⁻¹ • v = (Vec.norm u)⁻¹ • u ↔ v = (-Vec.norm v) • (Vec.norm u)⁻¹ • u := inv_smul_eq_iff₀ (Iff.mpr neg_ne_zero (Iff.mpr (@norm_ne_zero_iff _ Vec.NormedAddGroup v) hv))
      rw [mul_smul]
      refine (w₂.mp (Eq.symm ?_))
      rw [← neg_inv, neg_smul]
      exact h₂

-- The main theorem of toProj

theorem eq_toProj_iff {u v : ℝ × ℝ} (hu : u ≠ 0) (hv : v ≠ 0) : (Vec.toProj_of_nonzero u hu = Vec.toProj_of_nonzero v hv) ↔ ∃ (t : ℝ), v = t • u := by
  constructor
  · intro h
    exact smul_of_eq_toProj h
  · intro h'
    rcases h' with ⟨t, h⟩ 
    exact eq_toProj_of_smul hu hv h

-- Define two Proj is perpendicular by the mul structure of ℂ, using Complex.I
-- But first we need to define Dir.I

namespace Dir

def I : Dir where
  toVec := (0, 1)
  unit := by
    unfold inner Vec.InnerProductSpace.Core
    simp

@[simp]
theorem fst_of_I_eq_zero : I.1.1 = 0 := rfl

@[simp]
theorem snd_of_I_eq_one : I.1.2 = 1 := rfl

@[simp]
theorem I_toComplex_eq_I : Vec.toComplex I.1 = Complex.I := by
  unfold Vec.toComplex
  ext
  simp only [fst_of_I_eq_zero, Complex.I_re]
  simp only [snd_of_I_eq_one, Complex.I_im]

@[simp]
theorem fst_of_neg_one_of_C_eq_neg_one : (Complex.toVec (-1 : ℂ)).1 = -1 := rfl

@[simp]
theorem snd_of_neg_one_of_C_eq_zero : (Complex.toVec (-1 : ℂ)).2 = 0 := by
  unfold Complex.toVec Complex.im
  simp only [Complex.neg_im, Complex.one_im, neg_zero]

@[simp]
theorem I_mul_I_eq_neg_one : I * I = -(1 : Dir) := by
  ext : 1
  unfold HMul.hMul instHMul Mul.mul instMulDir
  simp only [I_toComplex_eq_I, Complex.I_mul_I, toVec_neg_eq_neg_toVec]
  ext
  rfl
  rfl

-- Theorems for mk_angle
@[simp]
theorem mk_angle_zero_eq_one : mk_angle 0 = 1 := by
  unfold mk_angle
  ext
  simp only [Real.cos_zero, Real.sin_zero, fst_of_one_eq_one]
  simp only [Real.cos_zero, Real.sin_zero, snd_of_one_eq_zero]

@[simp]
theorem mk_angle_pi_eq_neg_one : mk_angle π = -1 := by
  unfold mk_angle
  ext
  simp only [Real.cos_pi, Real.sin_pi, toVec_neg_eq_neg_toVec, Prod.fst_neg, fst_of_one_eq_one]
  simp only [Real.cos_pi, Real.sin_pi, toVec_neg_eq_neg_toVec, Prod.snd_neg, snd_of_one_eq_zero, neg_zero]

@[simp]
theorem mk_angle_neg_pi_eq_neg_one : mk_angle (-π) = -1 := by
  unfold mk_angle
  ext
  simp only [Real.cos_neg, Real.cos_pi, Real.sin_neg, Real.sin_pi, neg_zero, toVec_neg_eq_neg_toVec, Prod.fst_neg,
    fst_of_one_eq_one]
  simp only [Real.cos_neg, Real.cos_pi, Real.sin_neg, Real.sin_pi, neg_zero, toVec_neg_eq_neg_toVec, Prod.snd_neg,
    snd_of_one_eq_zero]

@[simp]
theorem mk_angle_pi_div_two_eq_I : mk_angle (π / 2) = I := by
  unfold mk_angle
  ext
  simp only [Real.cos_pi_div_two, Real.sin_pi_div_two, fst_of_I_eq_zero]
  simp only [Real.cos_pi_div_two, Real.sin_pi_div_two, snd_of_I_eq_one]

@[simp]
theorem mk_angle_neg_pi_div_two_eq_neg_I : mk_angle (-(π / 2)) = -I := by
  unfold mk_angle
  ext
  simp only [Real.cos_neg, Real.cos_pi_div_two, Real.sin_neg, Real.sin_pi_div_two, toVec_neg_eq_neg_toVec, Prod.fst_neg,
    fst_of_I_eq_zero, neg_zero]
  simp only [Real.cos_neg, Real.cos_pi_div_two, Real.sin_neg, Real.sin_pi_div_two, toVec_neg_eq_neg_toVec, Prod.snd_neg,
    snd_of_I_eq_one]

@[simp]
theorem mk_angle_neg_pi_div_two_eq_neg_I' : mk_angle ((-π) / 2) = -I := by
  rw [neg_div]
  simp only [mk_angle_neg_pi_div_two_eq_neg_I]

theorem mk_angle_neg_mul_mk_angle_eq_one (x : ℝ) : mk_angle (-x) * mk_angle x = 1 := by
  ext
  unfold toVec mk_angle HMul.hMul instHMul Mul.mul instMulDir Vec.toComplex Complex.toVec
  simp only [Real.cos_neg, Real.sin_neg, Complex.mul_re, neg_mul, sub_neg_eq_add]
  rw [← pow_two, ← pow_two, Real.cos_sq_add_sin_sq x]
  rfl
  unfold toVec mk_angle HMul.hMul instHMul Mul.mul instMulDir Vec.toComplex Complex.toVec
  simp only [Real.cos_neg, Real.sin_neg, Complex.mul_im, neg_mul]
  rw [mul_comm, add_right_neg]
  rfl

@[simp]
theorem mk_angle_neg_eq_mk_angle_inv (x : ℝ) : mk_angle (-x) = (mk_angle x)⁻¹ := by
  rw [← one_mul (mk_angle x)⁻¹, ← mk_angle_neg_mul_mk_angle_eq_one x, mul_assoc, mul_right_inv, mul_one]

end Dir

namespace Proj

def I : Proj := Dir.I

@[simp]
theorem neg_one_eq_one_of_Proj : ((-1 : Dir) : Proj) = (1 : Proj) := by
  unfold Dir.toProj
  apply Quotient.sound
  unfold HasEquiv.Equiv instHasEquiv PM.con PM
  simp

@[simp]
theorem I_mul_I_eq_one_of_Proj : I * I = 1 := by
  have h : Dir.toProj (Dir.I * Dir.I) = (Dir.toProj Dir.I) * (Dir.toProj Dir.I):= rfl
  have h' : Dir.toProj Dir.I = (I : Proj) := rfl
  rw [← neg_one_eq_one_of_Proj, ← Dir.I_mul_I_eq_neg_one, h, h']

def perp : Proj → Proj := fun x => I * x

@[simp]
theorem perp_perp_eq_self (x : Proj) : x.perp.perp = x := by
  unfold perp
  rw [← mul_assoc]
  simp only [I_mul_I_eq_one_of_Proj, one_mul]

end Proj

-- Start proving theorems about intersecting two lines

section LinearAlgebra

theorem det_eq_zero_iff (u v : ℝ × ℝ) (hu : u ≠ 0) : u.1 * v.2 - u.2 * v.1 = 0 ↔ (∃ (t : ℝ), v = t • u) := by
  have h : (u.fst ≠ 0) ∨ (u.snd ≠ 0) := by
    by_contra _
    have hfst : u.fst = 0 := by tauto
    have hsnd : u.snd = 0 := by tauto
    have hu' : u = (0, 0) := by exact Prod.ext hfst hsnd
    tauto
  constructor
  · intro e
    match h with 
    | Or.inl h₁ =>
      use v.fst * (u.fst⁻¹)
      unfold HSMul.hSMul instHSMul SMul.smul Prod.smul
      ext
      simp only [smul_eq_mul, ne_eq]
      exact Iff.mp (div_eq_iff h₁) rfl
      simp only [smul_eq_mul]
      rw [mul_comm v.fst u.fst⁻¹, mul_assoc, mul_comm v.fst u.snd]
      rw [sub_eq_zero] at e
      exact Iff.mpr (eq_inv_mul_iff_mul_eq₀ h₁) e
    | Or.inr h₂ =>
      use v.snd * (u.snd⁻¹)
      unfold HSMul.hSMul instHSMul SMul.smul Prod.smul
      ext
      simp only [smul_eq_mul]
      rw [mul_comm v.snd u.snd⁻¹, mul_assoc]
      rw [sub_eq_zero, mul_comm u.fst v.snd] at e
      exact Iff.mpr (eq_inv_mul_iff_mul_eq₀ h₂) (id (Eq.symm e))
      simp only [smul_eq_mul, ne_eq]
      exact Iff.mp (div_eq_iff h₂) rfl
  · intro e'
    rcases e' with ⟨t, e⟩
    unfold HSMul.hSMul instHSMul SMul.smul Prod.smul at e
    simp at e
    rcases e
    simp
    ring

theorem linear_combination_of_not_colinear {u v w : ℝ × ℝ} (hu : u ≠ 0) (h' : ¬(∃ (t : ℝ), v = t • u)) : ∃ (cu cv : ℝ), w = cu • u + cv • v := by
  have h₁ : (¬ (∃ (t : ℝ), v = t • u)) → (¬ (u.1 * v.2 - u.2 * v.1 = 0)) := by
    intro _
    by_contra h₂
    let _ := (det_eq_zero_iff u v hu).1 h₂
    tauto
  let d := u.1 * v.2 - u.2 * v.1
  have h₃ : d ≠ 0 := h₁ h'
  use d⁻¹ * (w.1 * v.2 - v.1 * w.2) 
  use d⁻¹ * (u.1 * w.2 - w.1 * u.2)
  symm
  rw [mul_smul, mul_smul, ← smul_add]
  apply ((inv_smul_eq_iff₀ h₃).2)
  unfold HSMul.hSMul instHSMul SMul.smul MulAction.toSMul Prod.mulAction Prod.smul
  ext
  simp only [smul_eq_mul, Prod.mk_add_mk]
  ring
  simp only [smul_eq_mul, Prod.mk_add_mk]
  ring

theorem linear_combination_of_not_colinear' {u v w : ℝ × ℝ} (hu : u ≠ 0) (hv : v ≠ 0) (h' : Vec.toProj_of_nonzero u hu ≠ Vec.toProj_of_nonzero v hv) : ∃ (cu cv : ℝ), w = cu • u + cv • v := by
  have h₁ : (Vec.toProj_of_nonzero u hu ≠ Vec.toProj_of_nonzero v hv) → ¬(∃ (t : ℝ), v = t • u) := by
    intro _
    by_contra h₂
    let _ := (eq_toProj_iff hu hv).2 h₂
    tauto
  exact linear_combination_of_not_colinear hu (h₁ h')

end LinearAlgebra

end EuclidGeom