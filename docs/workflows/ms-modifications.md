# Protein Modifications in Mass Spectrometry｜蛋白质质谱分析中的修饰设置

## Quick Lookup｜速查表 { #quick-lookup }

| Parameter | Modification | Mass Change | Type |
|---|---|---:|---|
| [`--met-excision`](#met-excision) | N-terminal Met removal｜N端甲硫氨酸切除 | -131.0405 Da* | Special processing |
| [`--unimod4`](#unimod4) | Cysteine carbamidomethylation｜半胱氨酸烷基化 | +57.021464 Da | Fixed |
| [`--var-mods 1`](#var-mods) | Maximum variable modifications｜可变修饰数量限制 | — | Search setting |
| [`UniMod:35`](#unimod35) | Methionine oxidation｜甲硫氨酸氧化 | +15.994915 Da | Variable |
| [`UniMod:1`](#unimod1) | Protein N-terminal acetylation｜蛋白质N端乙酰化 | +42.010565 Da | Variable |

\*Met 切除的质量变化按甲硫氨酸残基质量计算，实际肽段质量变化还需结合具体序列和末端情况理解。

---

## 1. Overall Principle｜核心原理 { #principle }

蛋白质由氨基酸组成。实验中，我们通常会先提取蛋白质，再通过酶切（例如 Trypsin，胰蛋白酶）把蛋白质切成很多小片段，这些小片段叫做肽段（Peptides）。质谱仪（Mass Spectrometer, MS）测量这些肽段的质量，并据此识别肽段和蛋白质。

Proteins are made up of amino acids. In proteomics experiments, proteins are usually extracted and digested into peptides using enzymes such as trypsin. A mass spectrometer (MS) measures the mass of these peptides, allowing researchers to identify peptides and proteins.

真实样本中的蛋白质不一定是原始状态，有些氨基酸会发生化学修饰（Chemical Modifications），使肽段质量发生变化。因此在数据库搜索（Database Search）时，需要提前告诉软件：

However, proteins in biological samples may carry chemical modifications that change peptide masses. During database searching, we need to tell the software:

- 哪些氨基酸可能发生修饰？｜Which amino acids can be modified?
- 修饰会让质量增加或减少多少？｜How much mass does each modification add or remove?
- 哪些修饰是固定发生的？｜Which modifications are fixed?
- 哪些修饰只是可能发生的？｜Which modifications are variable?

---

## 2. Cysteine Alkylation with IAA｜为什么要用 IAA 对半胱氨酸烷基化 { #alkylation }

### 2.1 Cysteine and Disulfide Bonds｜半胱氨酸与二硫键 { #cysteine }

半胱氨酸（Cysteine，C）的侧链上有一个巯基（Thiol group，-SH）。这个巯基比较活泼，两个半胱氨酸之间可以发生氧化反应，形成二硫键（Disulfide Bond）。二硫键能维持蛋白质的三维结构，但在质谱实验中会影响蛋白质的充分展开和酶切。

Cysteine contains a reactive thiol group (-SH). Two cysteine residues can be oxidized to form a disulfide bond, which stabilizes protein structure but interferes with protein unfolding and digestion.

```text
Cys-SH + HS-Cys
       ↓ Oxidation（氧化）
Cys-S-S-Cys
```

### 2.2 Reduction｜还原：打开二硫键 { #reduction }

使用 DTT 或 TCEP 等还原剂（Reducing Agents）把二硫键打开，两个半胱氨酸就分开了。但打开后的巯基仍然活泼，可能再次氧化、重新形成二硫键。

Reducing agents such as DTT or TCEP break disulfide bonds. The exposed thiol groups remain reactive and may oxidize again, reforming disulfide bonds.

```text
Cys-S-S-Cys
       ↓ Reduction（还原）
Cys-SH     HS-Cys
```

### 2.3 Alkylation｜烷基化：给 C 加上保护帽 { #iaa }

为防止二硫键重新形成，使用 IAA（Iodoacetamide，碘乙酰胺）进行烷基化（Alkylation）。IAA 与巯基反应，给 C 加上一个化学基团，这个修饰叫 **Carbamidomethylation（氨甲酰甲基化）**，使半胱氨酸质量增加 **+57.021464 Da**。

To prevent disulfide bonds from reforming, IAA (Iodoacetamide) is used for alkylation. It adds a carbamidomethyl group to cysteine (**Carbamidomethylation**), increasing its mass by **+57.021464 Da**.

```text
Cys-SH + IAA
       ↓ Alkylation（烷基化）
Cys-S-CH2-CONH2
```

!!! tip "打个比方｜Analogy"
    还原是把打结的绳子解开，烷基化就是给解开的线头套上保护帽，防止它们重新打结。

    Reduction opens the disulfide bonds; alkylation acts like a protective cap that keeps them from forming again.

---

## 3. Parameters｜参数逐项解释 { #parameters }

```bash
# Modifications
--met-excision
--unimod4
--var-mods 1
--var-mod UniMod:35,15.994915,M
--var-mod UniMod:1,42.010565,*n
```

!!! note "DIA-NN 2.x 提示"
    在新版 DIA-NN 中，半胱氨酸 Carbamidomethyl（+57.021）已是内置默认固定修饰，
    `--unimod4` 属遗留写法；实际命令模板见 [DIA-NN](../software/dia-nn.md)。
    下文仍逐项解释它的含义，便于理解旧命令。

### 3.1 `--met-excision` { #met-excision }

**N-terminal Methionine Excision｜N端甲硫氨酸切除** · Special processing

蛋白质合成时第一个氨基酸通常是甲硫氨酸（Methionine，M），在蛋白质成熟过程中它有时会被酶切除。这个参数让软件同时考虑切除前和切除后两种情况。

The first amino acid of a newly synthesized protein is often methionine (M), which may be removed during protein maturation. This parameter tells the software to consider both the excised and non-excised forms.

```text
Original protein:   M-A-K-L-V-G-T
After Met excision: A-K-L-V-G-T
```

### 3.2 `--unimod4` { #unimod4 }

**Cysteine Carbamidomethylation｜半胱氨酸烷基化** · **+57.021464 Da** · Fixed

实验中用 IAA 对 C 进行烷基化（见 [2.3](#iaa)）。通常假设所有 C 都已被烷基化，所以它是固定修饰（Fixed Modification）：软件看到 C，就自动加上 57.021464 Da。

Cysteine residues are alkylated with IAA during sample preparation. Because all cysteines are assumed to be modified, this is a fixed modification: the software automatically adds 57.021464 Da to every C.

```text
Original peptide: PEPTCIDEK
After alkylation: PEPTC(+57.021464)IDEK
```

### 3.3 `--var-mods 1` { #var-mods }

**Maximum Number of Variable Modifications｜可变修饰数量限制** · Search setting

每条肽段最多允许出现 1 个可变修饰。允许的修饰越多，软件要搜索的组合越多，计算量增加，也更容易出现错误匹配。

Each peptide may carry at most one variable modification. More allowed modifications mean more combinations to search, higher computational cost and more chance of false matches.

- 固定修饰不计入这个数量｜Fixed modifications do not count toward this limit.
- 这是每条肽段的限制，不是整个蛋白质的限制｜The limit is per peptide, not per protein.

### 3.4 `--var-mod UniMod:35,15.994915,M` { #unimod35 }

**Methionine Oxidation｜甲硫氨酸氧化** · **+15.994915 Da** · Variable

甲硫氨酸（M）容易氧化，但并不是所有 M 都一定被氧化，所以它是可变修饰（Variable Modification）。软件会同时考虑两种可能：M 未氧化（质量不变）和 M 氧化（+15.994915 Da）。

Methionine (M) is easily oxidized, but not every methionine is, so this is a variable modification. The software considers both the unmodified and the oxidized (+15.994915 Da) forms.

```text
Unmodified: PEPTMIDEK
Oxidized:   PEPTM(ox)IDEK
```

### 3.5 `--var-mod UniMod:1,42.010565,*n` { #unimod1 }

**Protein N-terminal Acetylation｜蛋白质N端乙酰化** · **+42.010565 Da** · Variable

乙酰化（Acetylation）是常见的翻译后修饰（Post-translational Modification, PTM），通常发生在蛋白质 N 端。`*n` 表示**蛋白质**的 N 端（Protein N-terminus），而不是任意肽段的 N 端。并非所有蛋白质都会被乙酰化，所以它是可变修饰。

Acetylation is a common post-translational modification (PTM) at the protein N-terminus. `*n` means the **protein** N-terminus, not the N-terminus of any internal peptide. Not all proteins are acetylated, so this is a variable modification.

```text
Original:                     M-A-K-L-V-G-T
After N-terminal acetylation: Ac-M-A-K-L-V-G-T
```

---

## 4. How the Software Uses These Parameters｜软件如何使用这些参数 { #workflow }

以肽段 `MACK` 为例｜Take the peptide `MACK` as an example:

### Step 1: Met excision｜考虑 N 端 M 是否被切除 { #step1 }

```text
MACK → ACK
```

### Step 2: Fixed modifications｜应用固定修饰 { #step2 }

C 一定增加 +57.021464 Da｜Cysteine always receives +57.021464 Da.

```text
MACK → MA(C+57)K
```

### Step 3: Variable modifications｜考虑可变修饰 { #step3 }

每条肽段最多考虑一个可变修饰｜At most one variable modification per peptide:

- M 未氧化｜Methionine remains unoxidized
- M 氧化（+15.994915 Da）｜Methionine is oxidized
- 蛋白质 N 端乙酰化（+42.010565 Da）｜Protein N-terminal acetylation

只有真正位于蛋白质 N 端的肽段才会考虑 N 端乙酰化。｜N-terminal acetylation applies only to peptides at the protein N-terminus.

### Step 4: Matching｜与质谱数据匹配 { #step4 }

软件计算各种允许情况下的理论肽段质量，与质谱仪实际测量的质量比较；理论值足够接近、且碎片离子等证据支持时，即认为匹配成功。

The software calculates theoretical peptide masses for every allowed combination and compares them with measured masses. A match is accepted when masses agree and supporting evidence such as fragment ions confirms it.

---

## 5. Key Takeaways｜核心逻辑 { #takeaways }

| # | 要点 | Key point |
|---|---|---|
| 1 | 样品制备：还原 + 烷基化处理 C，防止二硫键重新形成 | Sample prep: reduction and alkylation prevent disulfide bonds from reforming |
| 2 | 固定修饰：C 已被烷基化，+57.021464 Da | Fixed modification: +57.021464 Da on every cysteine |
| 3 | 可变修饰：M 可能氧化，蛋白质 N 端可能乙酰化 | Variable modifications: Met oxidation and protein N-terminal acetylation |
| 4 | 搜索限制：每条肽段最多 1 个可变修饰 | Search restriction: at most one variable modification per peptide |
| 5 | 最终目的：算出准确的理论质量，与实验数据匹配，提高鉴定准确性 | Goal: accurate theoretical masses for reliable protein identification |

!!! success "一句话记住｜Take-home message"
    这些参数本质上是在告诉质谱搜索软件：蛋白质可能发生了哪些化学变化、这些变化会让质量改变多少，以及软件应该按照什么规则搜索。

    These parameters tell the search software which chemical modifications may occur, how they change peptide masses, and what rules to use to identify proteins accurately.
